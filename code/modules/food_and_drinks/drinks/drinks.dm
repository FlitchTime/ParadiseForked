////////////////////////////////////////////////////////////////////////////////
/// Drinks.
////////////////////////////////////////////////////////////////////////////////
/obj/item/reagent_containers/food/drinks
	name = "drink"
	desc = "Вкусняшка."
	icon = 'icons/obj/drinks.dmi'
	icon_state = null
	container_type = OPENCONTAINER
	consume_sound = 'sound/items/drink.ogg'
	possible_transfer_amounts = list(5,10,15,20,25,30,50)
	visible_transfer_rate = TRUE
	volume = 50
	resistance_flags = NONE
	antable = FALSE
	var/chugging = FALSE
	foodtype = ALCOHOL

/obj/item/reagent_containers/food/drinks/New()
	..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)
	bitesize = amount_per_transfer_from_this
	if(bitesize < 5)
		bitesize = 5

/obj/item/reagent_containers/food/drinks/attack_self(mob/user)
	return


/obj/item/reagent_containers/food/drinks/attack(mob/living/carbon/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!iscarbon(target))
		return ..()

	. = ATTACK_CHAIN_PROCEED

	if(!reagents || !reagents.total_volume)
		balloon_alert(user, "пусто!")
		return .

	if(!is_drainable())
		balloon_alert(user, "сначала откройте!")
		return .

	if(!get_location_accessible(target, BODY_ZONE_PRECISE_MOUTH))
		if(target == user)
			balloon_alert(user, "ваш рот закрыт!")
		else
			balloon_alert(user, "рот цели закрыт!")
		return .

	if(!target.eat(src, user))
		return .

	. |= ATTACK_CHAIN_SUCCESS

	var/list/transfer_data = reagents.get_transferred_reagents(target, amount_per_transfer_from_this)
	//Cyborg modules that include drinks automatically refill themselves, but drain the borg's cell
	if(isrobot(user) && length(transfer_data))
		SynthesizeDrinkFromTransfer(user, transfer_data)


/obj/item/reagent_containers/food/drinks/proc/SynthesizeDrinkFromTransfer(mob/user, list/transfer_data)

	var/list/ids_data = list()
	var/trans = 0

	transfer_data &= GLOB.drinks

	for(var/thing in transfer_data)
		var/datum/reagent/R = thing
		ids_data[initial(R.id)] = transfer_data[R]
		trans += transfer_data[R]

	if(length(ids_data))
		if(isrobot(user)) //Cyborg modules that include drinks automatically refill themselves, but drain the borg's cell
			var/mob/living/silicon/robot/bro = user
			var/chargeAmount = max(30,4*trans)
			bro.cell.use(chargeAmount)
			to_chat(user, span_notice("Синтез <b>[trans]</b> единиц[pluralize_ru(trans, "ы", "", "")] вещества..."))
			addtimer(CALLBACK(reagents, TYPE_PROC_REF(/datum/reagents, add_reagent_list), ids_data), 30 SECONDS)
			addtimer(CALLBACK(GLOBAL_PROC, /proc/to_chat, user, span_notice("Ваш[genderize_ru(gender, "", "а", "е", "и")] [declent_ru(NOMINATIVE)] снова пол[genderize_ru(gender, "он", "на", "но", "ны")].")), 30 SECONDS)
		else
			reagents.add_reagent_list(ids_data)
	else
		return

/obj/item/reagent_containers/food/drinks/MouseDrop(atom/over_object, src_location, over_location, src_control, over_control, params) //CHUG! CHUG! CHUG!
	if(!iscarbon(over_object) || usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return ..()
	var/mob/living/carbon/chugger = over_object
	if(!(container_type & DRAINABLE))
		balloon_alert(chugger, "сначала откройте!")
		return
	if(!get_location_accessible(chugger, BODY_ZONE_PRECISE_MOUTH))
		balloon_alert(chugger, "ваш рот чем-то закрыт!")
		return
	if(reagents.total_volume && loc == chugger && src == chugger.get_active_hand())
		chugger.visible_message(span_notice("[chugger] поднос[pluralize_ru(chugger.gender, "ит", "ят")] [declent_ru(ACCUSATIVE)] к своему рту и начина[pluralize_ru(chugger.gender, "ет", "ют")] [pick("цедить", "прихлёбывать", "медленно пить", "пить", "попивать", "хлебать", "потягивать")] содержимое."),
			span_notice("Вы подносите [declent_ru(ACCUSATIVE)] к своему рту и начинаете [pick("цедить", "прихлёбывать", "медленно пить", "пить", "попивать", "хлебать", "потягивать")] содержимое."),
			span_notice("Вы слышите звуки, походящие на питьё чего-то."))
		chugging = TRUE
		while(do_after(chugger, 4 SECONDS, chugger, progress = FALSE, max_interact_count = 1, cancel_on_max = TRUE, cancel_message = span_warning("You stop chugging [src].")))
			chugger.eat(src, chugger, 25) //Half of a glass, quarter of a bottle.
			if(!reagents.total_volume) //Finish in style.
				chugger.emote("gasp")
				chugger.visible_message(span_notice("[chugger] [pick("залпом", "за раз", "в один присест", "не отрываясь от горла", "полностью", "досуха")] выпива[pluralize_ru(chugger.gender, "ет", "ют")] содержимое [declent_ru(GENITIVE)]."),
					span_notice("Вы [pick("залпом", "за раз", "в один присест", "не отрываясь от горла", "полностью", "досуха")] выпиваете содержимое [declent_ru(GENITIVE)]."),
					span_notice("Вы слышите громкие глотки и последующий громкий выдох."))
				break
		chugging = FALSE

/obj/item/reagent_containers/food/drinks/afterattack(obj/target, mob/user, proximity, params)
	if(!proximity)
		return

	if(chugging)
		return

	if(target.is_refillable() && is_drainable()) //Something like a glass. Player probably wants to transfer TO it.
		if(!reagents.total_volume)
			balloon_alert(user, "пусто!")
			return FALSE

		if(target.reagents.holder_full())
			balloon_alert(user, "нет места!")
			return FALSE

		var/list/transfer_data = reagents.get_transferred_reagents(target, amount_per_transfer_from_this)
		var/trans = reagents.trans_to(target, amount_per_transfer_from_this)

		if(isrobot(user))
			SynthesizeDrinkFromTransfer(user, transfer_data)

		to_chat(user, span_notice("Вы переливаете <b>[trans]</b> единиц[declension_ru(trans, "у", "ы", "")] вещества в [target.declent_ru(ACCUSATIVE)]."))

	else if(target.is_drainable()) //A dispenser. Transfer FROM it TO us.
		if(!is_refillable())
			balloon_alert(user, "закрыто!")
			return FALSE
		if(!target.reagents.total_volume)
			balloon_alert(user, "пусто!")
			return FALSE

		if(reagents.holder_full())
			balloon_alert(user, "нет места!")
			return FALSE

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this)
		to_chat(user, span_notice("Вы наполняете [declent_ru(ACCUSATIVE)] <b>[trans]</b> единиц[declension_ru(trans, "ей", "ами", "ами")] вещества из содержимого [target.declent_ru(ACCUSATIVE)]."))

	return FALSE

/obj/item/reagent_containers/food/drinks/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		if(!reagents || reagents.total_volume == 0)
			. += span_notice("Пусто.")
		else if(reagents.total_volume <= volume/4)
			. += span_notice("Почти пусто.")
		else if(reagents.total_volume <= volume*0.66)
			. += span_notice("Наполовину заполнено.")// We're all optimistic, right?!

		else if(reagents.total_volume <= volume*0.90)
			. += span_notice("Почти заполнено.")
		else
			. += span_notice("Заполнено.")

////////////////////////////////////////////////////////////////////////////////
/// Drinks. END
////////////////////////////////////////////////////////////////////////////////

/obj/item/reagent_containers/food/drinks/trophy
	name = "pewter cup"
	desc = "Everyone gets a trophy."
	icon_state = "pewter_cup"
	w_class = WEIGHT_CLASS_TINY
	force = 1
	throwforce = 1
	amount_per_transfer_from_this = 5
	materials = list(MAT_METAL=100)
	possible_transfer_amounts = null
	volume = 5
	flags = CONDUCT
	container_type = OPENCONTAINER
	resistance_flags = FIRE_PROOF

/obj/item/reagent_containers/food/drinks/trophy/gold_cup
	name = "gold cup"
	desc = "You're winner!"
	icon_state = "golden_cup"
	w_class = WEIGHT_CLASS_BULKY
	force = 14
	throwforce = 10
	amount_per_transfer_from_this = 20
	materials = list(MAT_GOLD=1000)
	volume = 150

/obj/item/reagent_containers/food/drinks/trophy/silver_cup
	name = "silver cup"
	desc = "Best loser!"
	icon_state = "silver_cup"
	w_class = WEIGHT_CLASS_NORMAL
	force = 10
	throwforce = 8
	amount_per_transfer_from_this = 15
	materials = list(MAT_SILVER=800)
	volume = 100

/obj/item/reagent_containers/food/drinks/trophy/bronze_cup
	name = "bronze cup"
	desc = "At least you ranked!"
	icon_state = "bronze_cup"
	w_class = WEIGHT_CLASS_SMALL
	force = 5
	throwforce = 4
	amount_per_transfer_from_this = 10
	materials = list(MAT_METAL=400)
	volume = 25


///////////////////////////////////////////////Drinks
//Notes by Darem: Drinks are simply containers that start preloaded. Unlike condiments, the contents can be ingested directly
//	rather then having to add it to something else first. They should only contain liquids. They have a default container size of 50.
//	Formatting is the same as food.


/obj/item/reagent_containers/food/drinks/coffee
	name = "Robust Coffee"
	desc = "Careful, the beverage you're about to enjoy is extremely hot."
	icon_state = "coffee"
	list_reagents = list("coffee" = 30)
	resistance_flags = FREEZE_PROOF

/obj/item/reagent_containers/food/drinks/ice
	name = "ice cup"
	desc = "Стаканчик льда. Не жуйте, а то горло болеть будет."
	ru_names = list(
        NOMINATIVE = "стаканчик льда",
        GENITIVE = "стаканчика льда",
        DATIVE = "стаканчику льда",
        ACCUSATIVE = "стаканчик льда",
        INSTRUMENTAL = "стаканчиком льда",
        PREPOSITIONAL = "стаканчике льда"
	)
	icon_state = "icecup"
	list_reagents = list("ice" = 30)

/obj/item/reagent_containers/food/drinks/tea
	name = "Duke Purple tea"
	desc = "An insult to Duke Purple is an insult to the Space Queen! Any proper gentleman will fight you, if you sully this tea."
	icon_state = "teacup"
	item_state = "coffee"
	list_reagents = list("tea" = 30)

/obj/item/reagent_containers/food/drinks/tea/Initialize(mapload)
	if(prob(20))
		reagents.add_reagent("mugwort", 3)
	. = ..()

/obj/item/reagent_containers/food/drinks/mugwort
	name = "mugwort tea"
	desc = "A bitter herbal tea."
	icon_state = "manlydorfglass"
	item_state = "coffee"
	list_reagents = list("mugwort" = 30)

/obj/item/reagent_containers/food/drinks/h_chocolate
	name = "Dutch hot coco"
	desc = "Made in Space South America."
	icon_state = "hot_coco"
	item_state = "coffee"
	list_reagents = list("hot_coco" = 30, "sugar" = 5)
	resistance_flags = FREEZE_PROOF

/obj/item/reagent_containers/food/drinks/chocolate
	name = "hot chocolate"
	desc = "Made in Space Switzerland."
	icon_state = "hot_coco"
	item_state = "coffee"
	list_reagents = list("hot_coco" = 15, "chocolate" = 6, "water" = 9)
	resistance_flags = FREEZE_PROOF

/obj/item/reagent_containers/food/drinks/weightloss
	name = "weight-loss shake"
	desc = "A shake designed to cause weight loss.  The package proudly proclaims that it is 'tapeworm free.'"
	icon_state = "weightshake"
	list_reagents = list("lipolicide" = 30, "chocolate" = 5)
	foodtype = GROSS

/obj/item/reagent_containers/food/drinks/dry_ramen
	name = "cup ramen"
	desc = "Just add 10ml of water, self heats! A taste that reminds you of your school years."
	icon_state = "ramen"
	item_state = "ramen"
	list_reagents = list("dry_ramen" = 30)

/obj/item/reagent_containers/food/drinks/dry_ramen/Initialize(mapload)
	if(prob(20))
		reagents.add_reagent("enzyme", 3)
	. = ..()

/obj/item/reagent_containers/food/drinks/chicken_soup
	name = "canned chicken soup"
	desc = "A delicious and soothing can of chicken noodle soup; just like spessmom used to microwave it."
	icon_state = "soupcan"
	item_state = "soupcan"
	list_reagents = list("chicken_soup" = 30)
	foodtype = JUNKFOOD

/obj/item/reagent_containers/food/drinks/sillycup
	name = "paper cup"
	desc = "A paper water cup."
	icon_state = "water_cup_e"
	item_state = "coffee"
	possible_transfer_amounts = null
	volume = 10


/obj/item/reagent_containers/food/drinks/sillycup/update_icon_state()
	icon_state = "water_cup[reagents.total_volume ? "" : "_e"]"


/obj/item/reagent_containers/food/drinks/sillycup/on_reagent_change()
	update_icon(UPDATE_ICON_STATE)


//////////////////////////drinkingglass and shaker//
//Note by Darem: This code handles the mixing of drinks. New drinks go in three places: In Chemistry-Reagents.dm (for the drink
//	itself), in Chemistry-Recipes.dm (for the reaction that changes the components into the drink), and here (for the drinking glass
//	icon states.

/obj/item/reagent_containers/food/drinks/shaker
	name = "shaker"
	desc = "A metal shaker to mix drinks in."
	icon_state = "shaker"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	amount_per_transfer_from_this = 10
	materials = list(MAT_METAL=1500)
	volume = 100

/obj/item/reagent_containers/food/drinks/flask
	name = "flask"
	desc = "Every good spaceman knows it's a good idea to bring along a couple of pints of whiskey wherever they go."
	icon_state = "flask"
	materials = list(MAT_METAL=250)
	volume = 60

/obj/item/reagent_containers/food/drinks/flask/barflask
	name = "flask"
	desc = "For those who can't be bothered to hang out at the bar to drink."
	icon_state = "barflask"

/obj/item/reagent_containers/food/drinks/flask/gold
	name = "captain's flask"
	desc = "A gold flask belonging to the captain."
	icon_state = "flask_gold"
	materials = list(MAT_GOLD=500)

/obj/item/reagent_containers/food/drinks/flask/detflask
	name = "detective's flask"
	desc = "The detective's only true friend."
	icon_state = "detflask"
	list_reagents = list("whiskey" = 30)

/obj/item/reagent_containers/food/drinks/flask/hand_made
	name = "handmade flask"
	desc = "A wooden flask with a silver lid and bottom. It has a matte, dark blue paint on it with the initials \"W.H.\" etched in black."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "williamhackett"
	materials = list()

/obj/item/reagent_containers/food/drinks/flask/thermos
	name = "vintage thermos"
	desc = "An older thermos with a faint shine."
	icon_state = "thermos"
	volume = 50

/obj/item/reagent_containers/food/drinks/flask/shiny
	name = "shiny flask"
	desc = "A shiny metal flask. It appears to have a Greek symbol inscribed on it."
	icon_state = "shinyflask"
	volume = 50

/obj/item/reagent_containers/food/drinks/flask/lithium
	name = "lithium flask"
	desc = "A flask with a Lithium Atom symbol on it."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "lithiumflask"
	volume = 50


/obj/item/reagent_containers/food/drinks/britcup
	name = "cup"
	desc = "A cup with the british flag emblazoned on it."
	icon_state = "britcup"
	volume = 30

/obj/item/reagent_containers/food/drinks/oilcan
	name = "oil can"
	desc = "Contains oil intended for use on cyborgs, robots, and other synthetics."
	icon = 'icons/goonstation/objects/oil.dmi'
	icon_state = "oilcan"
	volume = 100

/obj/item/reagent_containers/food/drinks/oilcan/full
	list_reagents = list("oil" = 100)


/obj/item/reagent_containers/food/drinks/zaza
	name = "Cherry Zaza"
	desc = "I possess Zaza!"
	icon_state = "zaza_can"
	item_state = "zaza_can"
	volume = 80
	foodtype = SUGAR
	container_type = NONE
	list_reagents = list("zaza" = 80)


/obj/item/reagent_containers/food/drinks/zaza/on_reagent_change()
	update_icon(UPDATE_OVERLAYS)


/obj/item/reagent_containers/food/drinks/zaza/update_overlays()
	. = ..()

	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', "[icon_state]50")

		switch(round(reagents.total_volume))
			if(1 to 50)
				filling.icon_state = "[icon_state]50"
			if(51 to 60)
				filling.icon_state = "[icon_state]60"
			if(61 to 65)
				filling.icon_state = "[icon_state]65"
			if(66 to 70)
				filling.icon_state = "[icon_state]70"
			if(71 to 75)
				filling.icon_state = "[icon_state]75"
			if(76 to INFINITY)
				filling.icon_state = "[icon_state]80"
		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		. += filling

	if(!is_open_container())
		. += "zaza_lid"


/obj/item/reagent_containers/food/drinks/zaza/attack_self(mob/user)
	if(!is_open_container())
		container_type |= OPENCONTAINER
		to_chat(user, span_notice("You put the lid on [src]."))
	else
		to_chat(user, span_notice("You take the lid off [src]."))
		container_type &= ~OPENCONTAINER
	update_icon(UPDATE_OVERLAYS)
