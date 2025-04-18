/obj/machinery/reagentgrinder
	name = "\improper All-In-One Grinder"
	desc = "Измельчает, дробит, разжижает и извлекает вещества из предметов, помещённых внутрь. Ради всего святого, не суйте туда свои пальцы."
	ru_names = list(
		NOMINATIVE = "универсальный блендер",
		GENITIVE = "универсального блендера",
		DATIVE = "универсальному блендеру",
		ACCUSATIVE = "универсальный блендер",
		INSTRUMENTAL = "универсальным блендером",
		PREPOSITIONAL = "универсальном блендере"
	)
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "juicer1"
	layer = 2.9
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	pass_flags = PASSTABLE
	resistance_flags = ACID_PROOF
	var/operating = 0
	var/obj/item/reagent_containers/beaker = new /obj/item/reagent_containers/glass/beaker/large
	var/limit = null
	var/efficiency = null

	//IMPORTANT NOTE! A negative number is a multiplier, a positive number is a flat amount to add. 0 means equal to the amount of the original reagent
	var/list/blend_items = list (

			//Sheets
			/obj/item/stack/sheet/mineral/plasma = list("plasma_dust" = 20),
			/obj/item/stack/sheet/metal = list("iron" = 20),
			/obj/item/stack/rods = list("iron" = 10),
			/obj/item/stack/sheet/plasteel = list("iron" = 20, "plasma_dust" = 20),
			/obj/item/stack/sheet/wood = list("carbon" = 20),
			/obj/item/stack/sheet/glass = list("silicon" = 20),
			/obj/item/stack/sheet/rglass = list("silicon" = 20, "iron" = 20),
			/obj/item/stack/sheet/mineral/uranium = list("uranium" = 20),
			/obj/item/stack/sheet/mineral/bananium = list("banana" = 20),
			/obj/item/stack/sheet/mineral/tranquillite = list("nothing" = 20),
			/obj/item/stack/sheet/mineral/silver = list("silver" = 20),
			/obj/item/stack/sheet/mineral/gold = list("gold" = 20),
			/obj/item/grown/nettle/basic = list("sacid" = 0),
			/obj/item/grown/nettle/death = list("facid" = 0, "sacid" = 0),
			/obj/item/grown/novaflower = list("capsaicin" = 0, "condensedcapsaicin" = 0),
			/obj/item/stack/sheet/cheese = list("milk" = 20),

			//Blender Stuff
			/obj/item/reagent_containers/food/snacks/grown/tomato = list("ketchup" = 0),
			/obj/item/reagent_containers/food/snacks/grown/wheat = list("flour" = -5),
			/obj/item/reagent_containers/food/snacks/grown/oat = list("flour" = -5),
			/obj/item/reagent_containers/food/snacks/grown/cherries = list("cherryjelly" = 0),
			/obj/item/reagent_containers/food/snacks/grown/bluecherries = list("bluecherryjelly" = 0),
			/obj/item/reagent_containers/food/snacks/egg = list("egg" = -5),
			/obj/item/reagent_containers/food/snacks/grown/rice = list("rice" = -5),
			/obj/item/reagent_containers/food/snacks/grown/buckwheat = list("buckwheat" = -5),

			//Grinder stuff, but only if dry
			/obj/item/reagent_containers/food/snacks/grown/coffee/robusta = list("coffeepowder" = 0, "morphine" = 0),
			/obj/item/reagent_containers/food/snacks/grown/coffee = list("coffeepowder" = 0),
			/obj/item/reagent_containers/food/snacks/grown/tea/astra = list("teapowder" = 0, "salglu_solution" = 0),
			/obj/item/reagent_containers/food/snacks/grown/tea = list("teapowder" = 0),
			/obj/item/reagent_containers/food/snacks/grown/moonlight = list("moonlin" = 0),


			//All types that you can put into the grinder to transfer the reagents to the beaker. !Put all recipes above this.!
			/obj/item/slime_extract = list(),
			/obj/item/reagent_containers/food = list(),
			/obj/item/reagent_containers/honeycomb = list()
	)

	var/list/juice_items = list (

			//Juicer Stuff
			/obj/item/reagent_containers/food/snacks/grown/soybeans = list("soymilk" = 0),
			/obj/item/reagent_containers/food/snacks/grown/corn = list("corn_starch" = 0),
			/obj/item/reagent_containers/food/snacks/grown/tomato = list("tomatojuice" = 0),
			/obj/item/reagent_containers/food/snacks/grown/carrot = list("carrotjuice" = 0),
			/obj/item/reagent_containers/food/snacks/grown/berries = list("berryjuice" = 0),
			/obj/item/reagent_containers/food/snacks/grown/banana = list("banana" = 0),
			/obj/item/reagent_containers/food/snacks/grown/potato = list("potato" = 0),
			/obj/item/reagent_containers/food/snacks/grown/citrus/lemon = list("lemonjuice" = 0),
			/obj/item/reagent_containers/food/snacks/grown/citrus/orange = list("orangejuice" = 0),
			/obj/item/reagent_containers/food/snacks/grown/citrus/orange_3d = list("orangejuice" = 0),
			/obj/item/reagent_containers/food/snacks/grown/citrus/lime = list("limejuice" = 0),
			/obj/item/reagent_containers/food/snacks/grown/watermelon = list("watermelonjuice" = 0),
			/obj/item/reagent_containers/food/snacks/watermelonslice = list("watermelonjuice" = 0),
			/obj/item/reagent_containers/food/snacks/grown/berries/poison = list("poisonberryjuice" = 0),
			/obj/item/reagent_containers/food/snacks/grown/pumpkin = list("pumpkinjuice" = 0),
			/obj/item/reagent_containers/food/snacks/grown/blumpkin = list("blumpkinjuice" = 0),
			/obj/item/reagent_containers/food/snacks/grown/apple = list("applejuice" = 0),
			/obj/item/reagent_containers/food/snacks/grown/grapes = list("grapejuice" = 0),
			/obj/item/reagent_containers/food/snacks/grown/grapes/green = list("grapejuice" = 0),
			/obj/item/reagent_containers/food/snacks/grown/pineapple = list("pineapplejuice" = 0),
			/obj/item/reagent_containers/food/snacks/grown/peaslaugh = list("laughsyrup" = 0)
	)

	var/list/dried_items = list(
			//Grinder stuff, but only if dry,
			/obj/item/reagent_containers/food/snacks/grown/coffee/robusta = list("coffeepowder" = 0, "morphine" = 0),
			/obj/item/reagent_containers/food/snacks/grown/coffee = list("coffeepowder" = 0),
			/obj/item/reagent_containers/food/snacks/grown/tea/astra = list("teapowder" = 0, "salglu_solution" = 0),
			/obj/item/reagent_containers/food/snacks/grown/tea = list("teapowder" = 0),
			/obj/item/reagent_containers/food/snacks/grown/moonlight = list("moonlin" = 0)
	)

	var/list/holdingitems = list()

/obj/machinery/reagentgrinder/examine(mob/user)
	. = ..()
	if(panel_open)
		. += span_notice("Панель техобслуживания открыта.")
	if(in_range(src, user))
		. += span_info("Используйте <b>Alt + ЛКМ</b>, чтобы активировать.<br>Используйте <b>Alt + Shift + ЛКМ</b>, чтобы удалить содержимое")

/obj/machinery/reagentgrinder/click_alt(mob/living/carbon/human/human)
	if(operating)
		return NONE

	add_fingerprint(human)
	grind()
	return CLICK_ACTION_SUCCESS

/obj/machinery/reagentgrinder/CtrlShiftClick(mob/living/carbon/human/human)
	if(!istype(human) || !human.Adjacent(src))
		return

	if(human.incapacitated() || HAS_TRAIT(human, TRAIT_HANDS_BLOCKED))
		return

	if(operating)
		return

	add_fingerprint(human)
	detach(human)

/obj/machinery/reagentgrinder/empty
	icon_state = "juicer0"
	beaker = null

/obj/machinery/reagentgrinder/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/reagentgrinder(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	RefreshParts()

/obj/machinery/reagentgrinder/RefreshParts()
	var/H
	var/T
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		H += M.rating
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		T += M.rating
	limit = 10*H
	efficiency = 0.8+T*0.1

/obj/machinery/reagentgrinder/Destroy()
	QDEL_NULL(beaker)
	return ..()

/obj/machinery/reagentgrinder/ex_act(severity)
	if(beaker)
		beaker.ex_act(severity)
	..()

/obj/machinery/reagentgrinder/handle_atom_del(atom/A)
	if(A == beaker)
		beaker = null
		update_icon(UPDATE_ICON_STATE)


/obj/machinery/reagentgrinder/update_icon_state()
	icon_state = "juicer[beaker ? "1" : "0"]"


/obj/machinery/reagentgrinder/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!anchored || beaker)
		return
	if(!panel_open)
		balloon_alert(user, "панель закрыта!")
		return
	if(!I.tool_use_check(user, 0))
		return
	default_deconstruction_crowbar(user, I)

/obj/machinery/reagentgrinder/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!anchored || beaker)
		return
	if(!I.tool_use_check(user, 0))
		return
	default_deconstruction_screwdriver(user, "juicer_open", "juicer0", I)

/obj/machinery/reagentgrinder/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	default_unfasten_wrench(user, I)


/obj/machinery/reagentgrinder/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(exchange_parts(user, I))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/reagent_containers) && (I.container_type & OPENCONTAINER))
		add_fingerprint(user)
		if(panel_open)
			balloon_alert(user, "панель открыта!")
			return ATTACK_CHAIN_PROCEED
		if(beaker)
			balloon_alert(user, "слот для ёмкости занят!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		beaker = I
		balloon_alert(user, "ёмкость установлена")
		updateUsrDialog()
		update_icon(UPDATE_ICON_STATE)
		return ATTACK_CHAIN_BLOCKED_ALL

	add_fingerprint(user)
	if(is_type_in_list(I, dried_items) && istype(I, /obj/item/reagent_containers/food/snacks/grown))
		var/obj/item/reagent_containers/food/snacks/grown/grown = I
		if(!grown.dry)
			balloon_alert(user, "сначала высушите!")
			return ATTACK_CHAIN_PROCEED

	if(length(holdingitems) >= limit)
		balloon_alert(user, "нет места!")
		return ATTACK_CHAIN_PROCEED

	//Fill machine with a bag!
	if(istype(I, /obj/item/storage/bag))
		var/obj/item/storage/bag/bag = I
		var/original_contents_len = length(bag.contents)
		if(!length(bag.contents))
			balloon_alert(user, "нечего загружать!")
			return ATTACK_CHAIN_PROCEED

		for(var/obj/item/thing as anything in bag.contents)
			if(is_type_in_list(thing, blend_items) || is_type_in_list(thing, juice_items))
				bag.remove_from_storage(thing, src)
				holdingitems += thing
				if(length(holdingitems) >= limit) //Sanity checking so the blender doesn't overfill
					break

		var/new_contents_len = length(bag.contents)
		if(new_contents_len == original_contents_len)
			balloon_alert(user, "нечего загружать!")
			return ATTACK_CHAIN_PROCEED
		user.visible_message(
			span_notice("[user] загрузил[pluralize_ru(user.gender, "", "а", "о", "и")] содержимое [bag.declent_ru(GENITIVE)] в [declent_ru(ACCUSATIVE)]."),
			span_notice("Вы загрузили содержимое [bag.declent_ru(GENITIVE)] в [declent_ru(ACCUSATIVE)]."))
		balloon_alert(user, "содержимое загружено")
		updateUsrDialog()
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(!is_type_in_list(I, blend_items) && !is_type_in_list(I, juice_items))
		balloon_alert(user, "не подходит!")
		return ATTACK_CHAIN_PROCEED

	if(!user.drop_transfer_item_to_loc(I, src))
		return ..()

	holdingitems += I
	user.visible_message(
		span_notice("[user] загрузил[pluralize_ru(user.gender, "", "а", "о", "и")] [I.declent_ru(ACCUSATIVE)] в [declent_ru(ACCUSATIVE)]."),
		span_notice("Вы загрузили [I.declent_ru(ACCUSATIVE)] в [declent_ru(ACCUSATIVE)]."))
	balloon_alert(user, "загружено в камеру")
	updateUsrDialog()
	return ATTACK_CHAIN_BLOCKED_ALL



/obj/machinery/reagentgrinder/attack_ai(mob/user)
	return FALSE

/obj/machinery/reagentgrinder/attack_hand(mob/user)
	if(..())
		return TRUE
	user.set_machine(src)
	interact(user)

/obj/machinery/reagentgrinder/interact(mob/user) // The microwave Menu
		var/is_chamber_empty = 0
		var/is_beaker_ready = 0
		var/processing_chamber = ""
		var/beaker_contents = ""
		var/dat = {"<!DOCTYPE html><meta charset="UTF-8">"}

		if(!operating)
				for (var/obj/item/O in holdingitems)
						processing_chamber += "\A [O.declent_ru(NOMINATIVE)]<br>"

				if (!processing_chamber)
						is_chamber_empty = 1
						processing_chamber = "Ничего."
				if (!beaker)
						beaker_contents = "<b>Ёмкость не установлена.</b><br>"
				else
						is_beaker_ready = 1
						beaker_contents = "<b>Содержимое ёмкости:</b><br>"
						var/anything = 0
						for(var/datum/reagent/R in beaker.reagents.reagent_list)
								anything = 1
								beaker_contents += "[R.volume] - [R.name]<br>"
						if(!anything)
								beaker_contents += "Ничего<br>"


				dat += {"
		<b>Содержимое камеры:</b><br>
		[processing_chamber]<br>
		[beaker_contents]<hr>
		"}
				if (is_beaker_ready && !is_chamber_empty && !(stat & (NOPOWER|BROKEN)))
						dat += "<a href='byond://?src=[src.UID()];action=grind'>Измельчить</a><br>"
						dat += "<a href='byond://?src=[src.UID()];action=juice'>Выжать</a><br><br>"
				if(holdingitems && holdingitems.len > 0)
						dat += "<a href='byond://?src=[src.UID()];action=eject'>Вынуть содержимое камеры</a><br>"
				if (beaker)
						dat += "<a href='byond://?src=[src.UID()];action=detach'>Извлечь ёмкость</a><br>"
		else
				dat += "Пожалуйста, подождите..."

		var/datum/browser/popup = new(user, "reagentgrinder", "Универсальный блендер")
		popup.set_content(dat)
		popup.open(1)
		return

/obj/machinery/reagentgrinder/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	if(operating)
		updateUsrDialog()
		return
	switch(href_list["action"])
		if ("grind")
			grind()
		if("juice")
			juice()
		if("eject")
			eject()
		if ("detach")
			detach(usr)

/obj/machinery/reagentgrinder/proc/detach(mob/user)
	if(user.stat)
		return

	if(!beaker)
		return

	beaker.forceMove(get_turf(src))
	beaker = null
	update_icon(UPDATE_ICON_STATE)
	updateUsrDialog()

/obj/machinery/reagentgrinder/proc/eject()
		if (usr.stat != 0)
				return
		if (holdingitems && holdingitems.len == 0)
				return

		for(var/obj/item/O in holdingitems)
				O.loc = src.loc
				holdingitems -= O
		holdingitems = list()
		updateUsrDialog()

/obj/machinery/reagentgrinder/proc/is_allowed(obj/item/reagent_containers/O)
		for (var/i in blend_items)
				if(istype(O, i))
						return TRUE
		return FALSE

/obj/machinery/reagentgrinder/proc/get_allowed_by_id(obj/item/O)
		for (var/i in blend_items)
				if (istype(O, i))
						return blend_items[i]

/obj/machinery/reagentgrinder/proc/get_allowed_snack_by_id(obj/item/reagent_containers/food/snacks/O)
		for(var/i in blend_items)
				if(istype(O, i))
						return blend_items[i]

/obj/machinery/reagentgrinder/proc/get_allowed_juice_by_id(obj/item/reagent_containers/food/snacks/O)
		for(var/i in juice_items)
				if(istype(O, i))
						return juice_items[i]

/obj/machinery/reagentgrinder/proc/get_grownweapon_amount(obj/item/grown/O)
		if (!istype(O) || !O.seed)
				return 5
		else if (O.seed.potency == -1)
				return 5
		else
				return round(O.seed.potency)

/obj/machinery/reagentgrinder/proc/get_juice_amount(obj/item/reagent_containers/food/snacks/grown/O)
		if (!istype(O) || !O.seed)
				return 5
		else if (O.seed.potency == -1)
				return 5
		else
				return round(5*sqrt(O.seed.potency))

/obj/machinery/reagentgrinder/proc/remove_object(obj/item/O)
		holdingitems -= O
		qdel(O)

/obj/machinery/reagentgrinder/proc/juice()
		power_change()
		if(stat & (NOPOWER|BROKEN))
				return
		if (!beaker || (beaker && beaker.reagents.total_volume >= beaker.reagents.maximum_volume))
				return
		playsound(src.loc, 'sound/machines/juicer.ogg', 20, 1)
		var/offset = prob(50) ? -2 : 2
		animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = 250) //start shaking
		operating = 1
		updateUsrDialog()
		spawn(50)
				pixel_x = initial(pixel_x) //return to its spot after shaking
				operating = 0
				updateUsrDialog()

		//Snacks
		for (var/obj/item/reagent_containers/food/snacks/O in holdingitems)
				if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
						break

				var/allowed = get_allowed_juice_by_id(O)
				if(isnull(allowed))
						break

				for (var/r_id in allowed)

						var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
						var/amount = get_juice_amount(O)

						beaker.reagents.add_reagent(r_id, min(amount*efficiency, space))

						if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
								break

				remove_object(O)

/obj/machinery/reagentgrinder/proc/grind()

		power_change()
		if(stat & (NOPOWER|BROKEN))
				return
		if (!beaker || (beaker && beaker.reagents.total_volume >= beaker.reagents.maximum_volume))
				return
		playsound(src.loc, 'sound/machines/blender.ogg', 50, 1)
		var/offset = prob(50) ? -2 : 2
		animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = 250) //start shaking
		operating = 1
		updateUsrDialog()
		spawn(60)
				pixel_x = initial(pixel_x) //return to its spot after shaking
				operating = 0
				updateUsrDialog()

		//Snacks and Plants
		for (var/obj/item/reagent_containers/food/snacks/O in holdingitems)
				if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
						break

				var/allowed = get_allowed_snack_by_id(O)
				if(isnull(allowed))
						break

				for (var/r_id in allowed)

						var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
						var/amount = allowed[r_id]
						if(amount <= 0)
								if(amount == 0)
										if (O.reagents != null && O.reagents.has_reagent("nutriment"))
												beaker.reagents.add_reagent(r_id, min(O.reagents.get_reagent_amount("nutriment")*efficiency, space))
												O.reagents.remove_reagent("nutriment", min(O.reagents.get_reagent_amount("nutriment"), space))
										if (O.reagents != null && O.reagents.has_reagent("plantmatter"))
												beaker.reagents.add_reagent(r_id, min(O.reagents.get_reagent_amount("plantmatter")*efficiency, space))
												O.reagents.remove_reagent("plantmatter", min(O.reagents.get_reagent_amount("plantmatter"), space))
								else
										if (O.reagents != null && O.reagents.has_reagent("nutriment"))
												beaker.reagents.add_reagent(r_id, min(round(O.reagents.get_reagent_amount("nutriment")*abs(amount)*efficiency), space))
												O.reagents.remove_reagent("nutriment", min(O.reagents.get_reagent_amount("nutriment"), space))
										if (O.reagents != null && O.reagents.has_reagent("plantmatter"))
												beaker.reagents.add_reagent(r_id, min(round(O.reagents.get_reagent_amount("plantmatter")*abs(amount)*efficiency), space))
												O.reagents.remove_reagent("plantmatter", min(O.reagents.get_reagent_amount("plantmatter"), space))


						else
								O.reagents.trans_id_to(beaker, r_id, min(amount, space))

						if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
								break

				if(O.reagents.reagent_list.len == 0)
						remove_object(O)

		//Sheets
		for (var/obj/item/stack/sheet/O in holdingitems)
				var/allowed = get_allowed_by_id(O)
				if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
						break
				for(var/i = 1; i <= round(O.amount, 1); i++)
						for (var/r_id in allowed)
								var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
								var/amount = allowed[r_id]
								beaker.reagents.add_reagent(r_id,min(amount*efficiency, space))
								if (space < amount)
										break
						if (i == round(O.amount, 1))
								remove_object(O)
								break
		//Plants
		for (var/obj/item/grown/O in holdingitems)
				if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
						break
				var/allowed = get_allowed_by_id(O)
				for (var/r_id in allowed)
						var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
						var/amount = allowed[r_id]
						if (amount == 0)
								if (O.reagents != null && O.reagents.has_reagent(r_id))
										beaker.reagents.add_reagent(r_id,min(O.reagents.get_reagent_amount(r_id)*efficiency, space))
						else
								beaker.reagents.add_reagent(r_id,min(amount*efficiency, space))

						if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
								break
				remove_object(O)

		//Slime Extractis
		for (var/obj/item/slime_extract/O in holdingitems)
				if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
						break
				var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
				if (O.reagents != null)
						var/amount = O.reagents.total_volume
						O.reagents.trans_to(beaker, min(amount, space))
				if (O.Uses > 0)
						beaker.reagents.add_reagent("slimejelly",min(20*efficiency, space))
				remove_object(O)

		//Everything else - Transfers reagents from it into beaker
		for (var/obj/item/reagent_containers/O in holdingitems)
				if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
						break
				var/amount = O.reagents.total_volume
				O.reagents.trans_to(beaker, amount)
				if(!O.reagents.total_volume)
						remove_object(O)
