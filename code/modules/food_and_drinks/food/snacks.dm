#define MAX_WEIGHT_CLASS WEIGHT_CLASS_SMALL
//Food items that are eaten normally and don't leave anything behind.
/obj/item/reagent_containers/food/snacks
	name = "snack"
	desc = "yummy"
	icon = 'icons/obj/food/food.dmi'
	icon_state = null
	var/bitecount = 0
	var/trash = null
	var/slice_path
	var/slices_num
	var/eatverb
	var/wrapped = 0
	var/dried_type = null
	var/dry = 0
	var/cooktype[0]
	var/cooked_type = null  //for microwave cooking. path of the resulting item after microwaving
	var/total_w_class = 0 //for the total weight an item of food can carry
	var/list/tastes  // for example list("crisps" = 2, "salt" = 1)
	var/opened = TRUE // FALSE if it needed to be opened first

/obj/item/reagent_containers/food/snacks/add_initial_reagents()
	if(tastes && tastes.len)
		if(list_reagents)
			for(var/rid in list_reagents)
				var/amount = list_reagents[rid]
				if(rid == "nutriment" || rid == "vitamin" || rid == "protein" || rid == "plantmatter")
					reagents.add_reagent(rid, amount, tastes.Copy())
				else
					reagents.add_reagent(rid, amount)
	else
		..()

/obj/item/reagent_containers/food/snacks/update_icon_state()
	if(!opened)
		icon_state = "[initial(icon_state)]-closed"
	else
		icon_state = "[initial(icon_state)]"

//Placeholder for effect that trigger on eating that aren't tied to reagents.
/obj/item/reagent_containers/food/snacks/proc/On_Consume(mob/M, mob/user)
	if(!user)
		return
	if(reagents && !reagents.total_volume)
		if(M == user)
			to_chat(user, span_notice("Вы доели [declent_ru(ACCUSATIVE)]."))
		user.visible_message(span_notice("[M] доел[genderize_ru(M.gender, "", "а", "о", "и")] [declent_ru(ACCUSATIVE)]."))
		user.drop_item_ground(src)	//so icons update :[
		Post_Consume(M)
		var/obj/item/trash_item = generate_trash(user)
		user.put_in_hands(trash_item)
		qdel(src)
	return

/obj/item/reagent_containers/food/snacks/proc/Post_Consume(mob/living/M)
	return

/obj/item/reagent_containers/food/snacks/attack_self(mob/user)
	if(!opened)
		opened = TRUE
		to_chat(user, "<span class='notice'>You open the [src].</span>")
		update_icon(UPDATE_ICON_STATE)
		return ..()
	else
		return


/obj/item/reagent_containers/food/snacks/attack(mob/living/carbon/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!iscarbon(target) || (user.a_intent == INTENT_HARM && force))
		return ..()

	. = ATTACK_CHAIN_PROCEED

	if(!opened)
		to_chat(user, span_warning("You need to open the [src]!"))
		return .

	if(reagents && !reagents.total_volume)	//Shouldn't be needed but it checks to see if it has anything left in it.
		to_chat(user, span_warning("None of [src] left, oh no!"))
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(!get_location_accessible(target, BODY_ZONE_PRECISE_MOUTH))
		if(target == user)
			to_chat(user, span_warning("Your face is obscured."))
		else
			to_chat(user, span_warning("[target]'s face is obscured."))
		return .

	if(!target.eat(src, user))
		return .

	. |= ATTACK_CHAIN_SUCCESS
	bitecount++
	On_Consume(target, user)


/obj/item/reagent_containers/food/snacks/afterattack(obj/target, mob/user, proximity, params)
	return

/obj/item/reagent_containers/food/snacks/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		if(bitecount > 0)
			if(bitecount==1)
				. += "<span class='notice'>[src] was bitten by someone!</span>"
			else if(bitecount<=3)
				. += "<span class='notice'>[src] was bitten [bitecount] times!</span>"
			else
				. += "<span class='notice'>[src] was bitten multiple times!</span>"


/obj/item/reagent_containers/food/snacks/attackby(obj/item/I, mob/user, params)
	if(is_pen(I))
		rename_interactive(user, I, use_prefix = FALSE, prompt = "What would you like to name this dish?")
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(isstorage(I))
		return ..()

	if(istype(I, /obj/item/kitchen/utensil))
		var/obj/item/kitchen/utensil/utensil = I
		if(length(utensil.contents) >= utensil.max_contents)
			to_chat(user, span_warning("You cannot fit anything else on your [utensil.name]."))
			return ATTACK_CHAIN_PROCEED
		user.visible_message(
			span_notice("[user] scoops up some [name] with [utensil]."),
			span_notice("You scoop up some [name] with [utensil]!"),
		)
		bitecount++
		var/obj/item/reagent_containers/food/snacks/collected = new type(utensil)
		collected.name = name
		collected.reagents.remove_any(collected.reagents.total_volume)
		collected.trash = null
		utensil.update_icon(UPDATE_OVERLAYS)
		if(reagents.total_volume > bitesize)
			reagents.trans_to(collected, bitesize)
			return ATTACK_CHAIN_PROCEED_SUCCESS
		reagents.trans_to(collected, reagents.total_volume)
		generate_trash(drop_location())
		if(loc == user)
			user.temporarily_remove_item_from_inventory(src, force = TRUE)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/reagent_containers/food/snacks/proc/generate_trash(atom/location)
	if(trash)
		if(ispath(trash, /obj/item))
			. = new trash(location)
			trash = null
			return
		else if(isitem(trash))
			var/obj/item/trash_item = trash
			trash_item.forceMove(location)
			. = trash
			trash = null
			return

/obj/item/reagent_containers/food/snacks/Destroy()
	if(contents)
		for(var/atom/movable/something in contents)
			something.loc = get_turf(src)
	return ..()

/obj/item/reagent_containers/food/snacks/attack_animal(mob/M)
	if(isanimal(M))
		M.changeNext_move(CLICK_CD_MELEE)
		if(isdog(M))
			var/mob/living/simple_animal/pet/dog/D = M
			if(world.time < (D.last_eaten + 300))
				to_chat(D, "<span class='notice'>You are too full to try eating [src] right now.</span>")
			else if(bitecount >= 4)
				D.visible_message("[D] [pick("burps from enjoyment", "yaps for more", "woofs twice", "looks at the area where [src] was")].","<span class='notice'>You swallow up the last part of [src].</span>")
				playsound(loc,'sound/items/eatfood.ogg', rand(10,50), 1)
				D.adjustHealth(-10)
				D.last_eaten = world.time
				D.taste(reagents)
				qdel(src)
			else
				D.visible_message("[D] takes a bite of [src].","<span class='notice'>You take a bite of [src].</span>")
				playsound(loc,'sound/items/eatfood.ogg', rand(10,50), 1)
				bitecount++
				D.last_eaten = world.time
				D.taste(reagents)
		else if(ismouse(M))
			var/mob/living/simple_animal/mouse/N = M
			to_chat(N, text("<span class='notice'>You nibble away at [src].</span>"))
			if(prob(50))
				N.visible_message("[N] nibbles away at [src].", "")
			N.adjustHealth(-2)
			N.taste(reagents)

/obj/item/reagent_containers/food/snacks/sliceable/examine(mob/user)
	. = ..()
	. += span_info("<b>Alt-click</b> to put something small inside.")

/obj/item/reagent_containers/food/snacks/sliceable/click_alt(mob/living/user)
	var/obj/item/I = user.get_active_hand()
	if(!I)
		return NONE
	if(I.w_class > WEIGHT_CLASS_SMALL)
		to_chat(user, span_warning("You cannot fit [I] in [src]!"))
		return CLICK_ACTION_BLOCKING
	var/newweight = GetTotalContentsWeight() + I.GetTotalContentsWeight() + I.w_class
	if(newweight > MAX_WEIGHT_CLASS)
		// Nope, no bluespace slice food
		to_chat(user, span_warning("You cannot fit [I] in [src]!"))
		return CLICK_ACTION_BLOCKING
	if(!user.drop_transfer_item_to_loc(I, src))
		to_chat(user, span_warning("You cannot slip [I] inside [src]!"))
		return CLICK_ACTION_BLOCKING
	to_chat(user, span_warning("You slip [I] inside [src]."))
	total_w_class += I.w_class
	add_fingerprint(user)
	return CLICK_ACTION_SUCCESS


/obj/item/reagent_containers/food/snacks/sliceable/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.) || !is_sharp(I) || (slices_num <= 0 || !slices_num) || !slice_path)
		return .

	if(!isturf(loc))
		to_chat(user, span_warning("You cannot slice [src] [ismob(loc) ? "in inventory" : "in [loc]"]."))
		return .

	var/static/list/acceptable_surfaces = typecacheof(list(
		/obj/structure/table,
		/obj/machinery/optable,
		/obj/item/storage/bag/tray,
	))
	var/acceptable = FALSE
	for(var/thing in loc)
		if(is_type_in_typecache(thing, acceptable_surfaces))
			acceptable = TRUE
			break
	if(!acceptable)
		to_chat(user, span_warning("You cannot slice [src] here! You need a table or at least a tray to do it."))
		return .

	. |= ATTACK_CHAIN_BLOCKED_ALL
	var/slices_lost = 0
	if(istype(I, /obj/item/kitchen/knife) || istype(I, /obj/item/scalpel))
		user.visible_message(
			span_notice("[user] slices [src] with [I]."),
			span_notice("You have sliced [src]."),
		)
	else
		slices_lost = rand(1, min(1, round(slices_num / 2)))
		user.visible_message(
			span_notice("[user] crudely slices [src] with [I]."),
			span_notice("You have crudely sliced [src]."),
		)
	var/reagents_per_slice = reagents.total_volume / slices_num
	for(var/i = 1 to (slices_num - slices_lost))
		var/obj/slice = new slice_path(loc)
		reagents.trans_to(slice, reagents_per_slice)
	qdel(src)


////////////////////////////////////////////////////////////////////////////////
/// FOOD END
////////////////////////////////////////////////////////////////////////////////











//////////////////////////////////////////////////
////////////////////////////////////////////Snacks
//////////////////////////////////////////////////
//Items in the "Snacks" subcategory are food items that people actually eat. The key points are that they are created
//	already filled with reagents and are destroyed when empty. Additionally, they make a "munching" noise when eaten.

//Notes by Darem: Food in the "snacks" subtype can hold a maximum of 50 units Generally speaking, you don't want to go over 40
//	total for the item because you want to leave space for extra condiments. If you want effect besides healing, add a reagent for
//	it. Try to stick to existing reagents when possible (so if you want a stronger healing effect, just use Tricordrazine). On use
//	effect (such as the old officer eating a donut code) requires a unique reagent (unless you can figure out a better way).

//The nutriment reagent and bitesize variable replace the old heal_amt and amount variables. Each unit of nutriment is equal to
//	2 of the old heal_amt variable. Bitesize is the rate at which the reagents are consumed. So if you have 6 nutriment and a
//	bitesize of 2, then it'll take 3 bites to eat. Unlike the old system, the contained reagents are evenly spread among all
//	the bites. No more contained reagents = no more bites.

//Here is an example of the new formatting for anyone who wants to add more food items.
///obj/item/reagent_containers/food/snacks/xenoburger			//Identification path for the object.
//	name = "Xenoburger"													//Name that displays in the UI.
//	desc = "Smells caustic. Tastes like heresy."						//Duh
//	icon_state = "xburger"												//Refers to an icon in food/food.dmi
//	New()																//Don't mess with this.
//		..()															//Same here.
//		reagents.add_reagent("xenomicrobes", 10)						//This is what is in the food item. you may copy/paste
//		reagents.add_reagent("nutriment", 2)							//	this line of code for all the contents.
//		bitesize = 3													//This is the amount each bite consumes.

/obj/item/reagent_containers/food/snacks/badrecipe
	name = "burned mess"
	desc = "Someone should be demoted from chef for this."
	icon_state = "badrecipe"
	filling_color = "#211F02"
	list_reagents = list("????" = 30)

/obj/item/reagent_containers/food/snacks/badrecipe/New()
	..()
	// it's burned! it should start off being classed as any cooktype that burns
	cooktype["grilled"] = 1
	cooktype["deep fried"] = 1

// MISC

/obj/item/reagent_containers/food/snacks/cereal
	name = "box of cereal"
	desc = "A box of cereal."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "cereal_box"
	list_reagents = list("nutriment" = 3)

/obj/item/reagent_containers/food/snacks/deepfryholder
	name = "Deep Fried Foods Holder Obj"
	desc = "If you can see this description the code for the deep fryer fucked up."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "deepfried_holder_icon"
	list_reagents = list("nutriment" = 3)
	foodtype = FRIED | JUNKFOOD | GROSS

#undef MAX_WEIGHT_CLASS
