
///////////////////////////////////////////////Condiments
//Notes by Darem: The condiments food-subtype is for stuff you don't actually eat but you use to modify existing food. They all
//	leave empty containers when used up and can be filled/re-filled with other items. Formatting for first section is identical
//	to mixed-drinks code. If you want an object that starts pre-loaded, you need to make it in addition to the other code.

//Food items that aren't eaten normally and leave an empty container behind.
/obj/item/reagent_containers/food/condiment
	name = "condiment container"
	desc = "Just your average condiment container."
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "emptycondiment"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	container_type = OPENCONTAINER
	possible_transfer_amounts = list(1, 5)
	visible_transfer_rate = TRUE
	volume = 50
	//Possible_states has the reagent id as key and a list of, in order, the icon_state, the name and the desc as values. Used in the on_reagent_change() to change names, descs and sprites.
	var/list/possible_states = list(
	 "ketchup" = list("ketchup", "ketchup bottle", "You feel more American already."),
	 "capsaicin" = list("hotsauce", "hotsauce bottle", "You can almost TASTE the stomach ulcers now!"),
	 "enzyme" = list("enzyme", "universal enzyme bottle", "Used in cooking various dishes"),
	 "soysauce" = list("soysauce", "soy sauce bottle", "A salty soy-based flavoring"),
	 "frostoil" = list("coldsauce", "coldsauce bottle", "Leaves the tongue numb in it's passage"),
	 "sodiumchloride" = list("saltshakersmall", "salt shaker", "Salt. From space oceans, presumably"),
	 "blackpepper" = list("peppermillsmall", "pepper mill", "Often used to flavor food or make people sneeze"),
	 "cornoil" = list("oliveoil", "corn oil bottle", "A delicious oil used in cooking. Made from corn"),
	 "oliveoil" = list("oliveoil", "olive oil bottle", "A delicious oil used in cooking. Made from olives"),
	 "sugar" = list("emptycondiment", "sugar bottle", "Tasty spacey sugar!"))
	var/originalname = "condiment" //Can't use initial(name) for this. This stores the name set by condimasters.

/obj/item/reagent_containers/food/condiment/attack_self(mob/user)
	return

/obj/item/reagent_containers/food/condiment/set_APTFT()
	set hidden = FALSE
	..()

/obj/item/reagent_containers/food/condiment/empty()
	set hidden = FALSE
	..()


/obj/item/reagent_containers/food/condiment/attack(mob/living/carbon/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!iscarbon(target))
		return ..()

	. = ATTACK_CHAIN_PROCEED

	if(!reagents || !reagents.total_volume)
		to_chat(user, span_warning("None of [src] left, oh no!"))
		return .

	if(!get_location_accessible(target, BODY_ZONE_PRECISE_MOUTH))
		if(target == user)
			to_chat(user, span_warning("Your face is obscured."))
		else
			to_chat(user, span_warning("[target]'s face is obscured."))
		return .

	if(target == user)
		to_chat(target, span_notice("You swallow some of [src] contents."))
	else
		user.visible_message(
			span_warning("[user] attempts to feed [target] from [src]."),
			span_notice("You attempt to feed [target] from [src]..."),
		)
		if(!do_after(user, 3 SECONDS, target, NONE) || !get_location_accessible(target, BODY_ZONE_PRECISE_MOUTH) || !reagents || !reagents.total_volume)
			return .
		user.visible_message(
			span_warning("[user] feeds [target] from [src]."),
			span_notice("You have fed [target] from [src]."),
		)
		add_attack_logs(user, target, "Fed [src] containing [reagents.log_list()]", reagents.harmless_helper() ? ATKLOG_ALMOSTALL : null)

	var/fraction = min(10/reagents.total_volume, 1)
	reagents.reaction(target, REAGENT_INGEST, fraction)
	reagents.trans_to(target, 10)
	playsound(target.loc,'sound/items/drink.ogg', rand(10,50), TRUE)
	return .|ATTACK_CHAIN_SUCCESS


/obj/item/reagent_containers/food/condiment/afterattack(obj/target, mob/user, proximity, params)
	if(!proximity)
		return
	if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.

		if(!target.reagents.total_volume)
			to_chat(user, "<span class='warning'>[target] is empty!</span>")
			return

		if(reagents.total_volume >= reagents.maximum_volume)
			to_chat(user, "<span class='warning'>[src] is full!</span>")
			return

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You fill [src] with [trans] units of the contents of [target].</span>")

	//Something like a glass or a food item. Player probably wants to transfer TO it.
	else if(target.is_drainable() || istype(target, /obj/item/reagent_containers/food/snacks))
		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'>[src] is empty!</span>")
			return
		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, "<span class='warning'>you can't add anymore to [target]!</span>")
			return
		var/trans = reagents.trans_to(target, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You transfer [trans] units of the condiment to [target].</span>")

/obj/item/reagent_containers/food/condiment/on_reagent_change()
	if(!possible_states.len)
		return
	if(reagents.reagent_list.len > 0)
		var/main_reagent = reagents.get_master_reagent_id()
		if(main_reagent in possible_states)
			var/list/temp_list = possible_states[main_reagent]
			icon_state = temp_list[1]
			name = temp_list[2]
			desc = temp_list[3]

		else
			name = "[originalname] bottle"
			main_reagent = reagents.get_master_reagent_name()
			if(reagents.reagent_list.len==1)
				desc = "Looks like it is [lowertext(main_reagent)], but you are not sure."
			else
				desc = "A mixture of various condiments. [lowertext(main_reagent)] is one of them."
			icon_state = "mixedcondiments"
	else
		icon_state = "emptycondiment"
		name = "condiment bottle"
		desc = "An empty condiment bottle."

/obj/item/reagent_containers/food/condiment/enzyme
	name = "universal enzyme"
	desc = "Used in cooking various dishes."
	icon_state = "enzyme"
	list_reagents = list("enzyme" = 50)

/obj/item/reagent_containers/food/condiment/sugar
	name = "sugar bottle"
	desc = "Tasty spacey sugar!"
	list_reagents = list("sugar" = 50)

/obj/item/reagent_containers/food/condiment/saltshaker		//Seperate from above since it's a small shaker rather then
	name = "salt shaker"											//	a large one.
	desc = "Salt. From space oceans, presumably."
	icon_state = "saltshakersmall"
	possible_transfer_amounts = list(1,5,20) //for clown turning the lid off
	amount_per_transfer_from_this = 1
	volume = 20
	list_reagents = list("sodiumchloride" = 20)
	possible_states = list()

/obj/item/reagent_containers/food/condiment/saltshaker/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] begins to swap forms with the salt shaker! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	var/newname = "[name]"
	name = "[user.name]"
	user.name = newname
	user.real_name = newname
	desc = "Salt. From dead crew, presumably."
	return BRUTELOSS

/obj/item/reagent_containers/food/condiment/peppermill
	name = "pepper mill"
	desc = "Often used to flavor food or make people sneeze."
	icon_state = "peppermillsmall"
	possible_transfer_amounts = list(1,5,20) //for clown turning the lid off
	amount_per_transfer_from_this = 1
	volume = 20
	list_reagents = list("blackpepper" = 20)
	possible_states = list()

/obj/item/reagent_containers/food/condiment/milk
	name = "space milk"
	desc = "It's milk. White and nutritious goodness!"
	icon_state = "milk"
	item_state = "carton"
	list_reagents = list("milk" = 50)
	possible_states = list()

/obj/item/reagent_containers/food/condiment/flour
	name = "flour sack"
	desc = "A big bag of flour. Good for baking!"
	icon_state = "flour"
	item_state = "flour"
	list_reagents = list("flour" = 30)
	possible_states = list()

/obj/item/reagent_containers/food/condiment/soymilk
	name = "soy milk"
	desc = "It's soy milk. White and nutritious goodness!"
	icon_state = "soymilk"
	item_state = "carton"
	list_reagents = list("soymilk" = 50)
	possible_states = list()

/obj/item/reagent_containers/food/condiment/rice
	name = "rice sack"
	desc = "A big bag of rice. Good for cooking!"
	icon_state = "rice"
	item_state = "flour"
	list_reagents = list("rice" = 30)
	possible_states = list()

/obj/item/reagent_containers/food/condiment/soysauce
	name = "soy sauce"
	desc = "A salty soy-based flavoring."
	icon_state = "soysauce"
	list_reagents = list("soysauce" = 50)
	possible_states = list()

/obj/item/reagent_containers/food/condiment/syndisauce
	name = "\improper Chef Excellence's Special Sauce"
	desc = "Этот ароматный соус, приготовленный из мухоморов, просто восхитителен! Смерть никогда не была такой приятной на вкус."
	ru_names = list(
		NOMINATIVE = "элитарный соус шефа",
		GENITIVE = "элитарного соуса шефа",
		DATIVE = "элитарному соусу шефа",
		ACCUSATIVE = "элитарный соус шефа",
		INSTRUMENTAL = "элитарным соусом шефа",
		PREPOSITIONAL = "элитарном соусе шефа"
	)
	list_reagents = list("amanitin" = 50)
	possible_states = list()
	log_eating = TRUE

//Tomato sauce
/obj/item/reagent_containers/food/condiment/tomatosauce
	name = "tomato sauce"
	desc = "The father of all sauces. Tomatoes, a little spice and nothing extra."
	icon_state = "tomatosauce"
	list_reagents = list("tsauce" = 50)
	possible_states = list()

//Diablo sauce
/obj/item/reagent_containers/food/condiment/diablosauce
	name = "diablo sauce"
	desc = "An ancient burning sauce, its recipe has hardly changed since its creation."
	icon_state = "diablosauce"
	list_reagents = list("dsauce" = 50)
	possible_states = list()

//Cheese sauce
/obj/item/reagent_containers/food/condiment/cheesesauce
	name = "cheese sauce"
	desc = "Cheese, cream and milk... maximum protein concentration!"
	icon_state = "cheesesauce"
	list_reagents = list("csauce" = 50)
	possible_states = list()

//Mushroom sauce
/obj/item/reagent_containers/food/condiment/mushroomsauce
	name = "mushroom sauce"
	desc = "Creamy sauce with mushrooms, has a rather pungent smell."
	icon_state = "mushroomsauce"
	list_reagents = list("msauce" = 50)
	possible_states = list()

//Garlic sauce
/obj/item/reagent_containers/food/condiment/garlicsauce
	name = "garlic sauce"
	desc = "A strong sauce with garlic, its smell punches the nose. Some crewmembers will probably hiss at you and walk away."
	icon_state = "garlicsauce"
	list_reagents = list("gsauce" = 50)
	possible_states = list()

//Custard
/obj/item/reagent_containers/food/condiment/custard
	name = "Custard"
	desc = "Soft and sweet cream, used in confectionery."
	icon_state = "custard"
	list_reagents = list("custard" = 50)
	possible_states = list()

//Herbs
/obj/item/reagent_containers/food/condiment/herbs
	name = "Herbs mix"
	desc = "A mix of variouse herbs. Perfect for pizza!"
	icon_state = "herbs"
	list_reagents = list("herbsmix" = 50)
	possible_states = list()

//Food packs. To easily apply deadly toxi... delicious sauces to your food!

/obj/item/reagent_containers/food/condiment/pack
	name = "condiment pack"
	desc = "A small plastic pack with condiments to put on your food."
	icon_state = "condi_empty"
	volume = 10
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = null
	possible_states = list(
	 "ketchup" = list("condi_ketchup", "Ketchup", "You feel more American already."),
	 "capsaicin" = list("condi_hotsauce", "Hotsauce", "You can almost TASTE the stomach ulcers now!"),
	 "soysauce" = list("condi_soysauce", "Soy Sauce", "A salty soy-based flavoring"),
	 "frostoil" = list("condi_frostoil", "Coldsauce", "Leaves the tongue numb in it's passage"),
	 "sodiumchloride" = list("condi_salt", "Salt Shaker", "Salt. From space oceans, presumably"),
	 "blackpepper" = list("condi_pepper", "Pepper Mill", "Often used to flavor food or make people sneeze"),
	 "cornoil" = list("condi_cornoil", "Corn Oil", "A delicious oil used in cooking. Made from corn"),
	 "oliveoil" = list("condi_oliveoil", "Olive Oil", "A delicious oil used in cooking. Made from olives"),
	 "sugar" = list("condi_sugar", "Sugar", "Tasty spacey sugar!")
	)


/obj/item/reagent_containers/food/condiment/pack/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	return ATTACK_CHAIN_PROCEED	// Can't feed these to people directly.


/obj/item/reagent_containers/food/condiment/pack/afterattack(obj/target, mob/user, proximity, params)
	if(!proximity)
		return

	//You can tear the bag open above food to put the condiments on it, obviously.
	if(istype(target, /obj/item/reagent_containers/food/snacks))
		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'>You tear open [src], but there's nothing in it.</span>")
			qdel(src)
			return
		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, "<span class='warning'>You tear open [src], but [target] is stacked so high that it just drips off!</span>") //Not sure if food can ever be full, but better safe than sorry.
			qdel(src)
			return
		else
			to_chat(user, "<span class='notice'>You tear open [src] above [target] and the condiments drip onto it.</span>")
			reagents.trans_to(target, amount_per_transfer_from_this)
			qdel(src)


/obj/item/reagent_containers/food/condiment/pack/update_desc(updates = ALL)
	. = ..()
	if(length(reagents.reagent_list))
		var/main_reagent = reagents.get_master_reagent_id()
		if(main_reagent in possible_states)
			var/list/temp_list = possible_states[main_reagent]
			desc = temp_list[3]
		else
			desc = "A small condiment pack. The label says it contains [originalname]."
	else
		desc = "A small condiment pack. It is empty."


/obj/item/reagent_containers/food/condiment/pack/update_icon_state()
	. = ..()
	if(length(reagents.reagent_list))
		var/main_reagent = reagents.get_master_reagent_id()
		if(main_reagent in possible_states)
			var/list/temp_list = possible_states[main_reagent]
			icon_state = temp_list[1]
		else
			icon_state = "condi_mixed"
	else
		icon_state = "condi_empty"


/obj/item/reagent_containers/food/condiment/pack/on_reagent_change()
	update_appearance(UPDATE_DESC|UPDATE_ICON_STATE)


//Ketchup
/obj/item/reagent_containers/food/condiment/pack/ketchup
	name = "ketchup pack"
	originalname = "ketchup"
	list_reagents = list("ketchup" = 10)

//Hot sauce
/obj/item/reagent_containers/food/condiment/pack/hotsauce
	name = "hotsauce pack"
	originalname = "hotsauce"
	list_reagents = list("capsaicin" = 10)

/obj/item/reagent_containers/food/condiment/animalfeed
	name = "pet food package"
	desc = "Корм для домашних животных. Вы же точно не хотите это пробовать?.."
	icon = 'icons/obj/pet_bowl.dmi'
	icon_state = "pet_food"
	volume = 80
	list_reagents = list("afeed" = 80)

/obj/item/reagent_containers/food/condiment/animalfeed/on_reagent_change()
	return
