#define MAX_PILL_SPRITE 20 //max icon state of the pill sprites
#define MAX_PATCH_SPRITE 20 //max icon state of the patch sprites
#define MAX_MULTI_AMOUNT 20 // Max number of pills/patches that can be made at once
#define MAX_UNITS_PER_PILL 100 // Max amount of units in a pill
#define MAX_UNITS_PER_PATCH 20 // Max amount of units in a patch
#define MAX_CUSTOM_NAME_LEN 64 // Max length of a custom pill/condiment/whatever

#define CUSTOM_NAME_DISABLED null

#define TRANSFER_TO_DISPOSAL 0
#define TRANSFER_TO_BEAKER   1

/obj/machinery/chem_master
	name = "\improper ChemMaster 3000"
	desc = "Химическое оборудование, предназначенное для преобразования реагентов в таблетки, пластыри и бутылки."
	ru_names = list(
		NOMINATIVE = "ХимМастер 3000",
		GENITIVE = "ХимМастера 3000",
		DATIVE = "ХимМастеру 3000",
		ACCUSATIVE = "ХимМастер 3000",
		INSTRUMENTAL = "ХимМастером 3000",
		PREPOSITIONAL = "ХимМастере 3000"
	)
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0"
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	resistance_flags = FIRE_PROOF | ACID_PROOF

	var/obj/item/reagent_containers/beaker = null
	var/obj/item/storage/pill_bottle/loaded_pill_bottle = null
	var/mode = TRANSFER_TO_BEAKER
	var/condi = FALSE
	var/useramount = 20 // Last used amount
	var/production_mode = null
	var/bottlesprite = 1
	var/pillsprite = 1
	var/patchsprite = 1
	var/client/has_sprites = list()
	var/printing = FALSE
	var/static/list/pill_bottle_wrappers = list(
		COLOR_RED_LIGHT = "Red",
		COLOR_GREEN = "Green",
		COLOR_PALE_BTL_GREEN = "Pale Green",
		COLOR_CYAN_BLUE = "Light Blue",
		COLOR_TEAL = "Teal",
		COLOR_YELLOW = "Yellow",
		COLOR_ORANGE = "Orange",
		COLOR_PINK = "Pink",
		COLOR_MAROON = "Brown",
		COLOR_INDIGO = "Indigo",
		COLOR_VIOLET = "Violet",
		COLOR_PURPLE = "Purple"
	)
	var/list/datum/chemical_production_mode/production_modes = list()
	var/static/list/bottle_styles

/obj/machinery/chem_master/Initialize(mapload)
	. = ..()
	create_reagents(100)
	component_parts = list()
	component_parts += new /obj/item/circuitboard/chem_master(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker(null)
	RefreshParts()
	update_icon()
	if(condi)
		var/datum/chemical_production_mode/new_mode = new /datum/chemical_production_mode/condiment_packs()
		production_modes[new_mode.mode_id] = new_mode
		new_mode = new /datum/chemical_production_mode/condiment_bottles()
		production_modes[new_mode.mode_id] = new_mode
	else
		var/datum/chemical_production_mode/new_mode = new /datum/chemical_production_mode/pills()
		production_modes[new_mode.mode_id] = new_mode
		new_mode = new /datum/chemical_production_mode/patches()
		production_modes[new_mode.mode_id] = new_mode
		new_mode = new /datum/chemical_production_mode/bottles()
		production_modes[new_mode.mode_id] = new_mode
	if(isnull(production_mode))
		for(var/key in production_modes)
			production_mode = key
			break

/obj/machinery/chem_master/Destroy()
	QDEL_NULL(beaker)
	QDEL_NULL(loaded_pill_bottle)
	return ..()

/obj/machinery/chem_master/RefreshParts()
	reagents.maximum_volume = 0
	for(var/obj/item/reagent_containers/glass/beaker/B in component_parts)
		reagents.maximum_volume += B.reagents.maximum_volume

/obj/machinery/chem_master/examine(mob/user)
	. = ..()
	if(panel_open)
		. += span_notice("Панель техобслуживания открыта.")

/obj/machinery/chem_master/ex_act(severity)
	if(severity < 3)
		if(beaker)
			beaker.ex_act(severity)
		if(loaded_pill_bottle)
			loaded_pill_bottle.ex_act(severity)
		..()

/obj/machinery/chem_master/handle_atom_del(atom/A)
	..()
	if(A == beaker)
		beaker = null
		reagents.clear_reagents()
		update_icon()
	else if(A == loaded_pill_bottle)
		loaded_pill_bottle = null

/obj/machinery/chem_master/update_icon_state()
	icon_state = "mixer[beaker ? "1" : "0"][powered() ? "" : "_nopower"]"

/obj/machinery/chem_master/update_overlays()
	. = ..()
	if(powered())
		. += "waitlight"

/obj/machinery/chem_master/power_change()
	if(!..())
		return
	update_icon()


/obj/machinery/chem_master/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(exchange_parts(user, I))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/reagent_containers/glass) || istype(I, /obj/item/reagent_containers/food/drinks/drinkingglass))
		add_fingerprint(user)
		if(panel_open)
			balloon_alert(user, "техпанель открыта!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		if(beaker)
			balloon_alert(user, "ёмкость заменена")
			beaker.forceMove(drop_location())
			if(Adjacent(user) && !issilicon(user)) //Prevents telekinesis from putting in hand
				user.put_in_hands(beaker, ignore_anim = FALSE)
		else
			balloon_alert(user, "ёмкость установлена")
		beaker = I
		SStgui.update_uis(src)
		update_icon()
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/storage/pill_bottle))
		add_fingerprint(user)
		if(panel_open)
			balloon_alert(user, "техпанель открыта!")
			return ATTACK_CHAIN_PROCEED
		if(loaded_pill_bottle)
			balloon_alert(user, "слот занят!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		loaded_pill_bottle = I
		balloon_alert(user, "контейнер установлен")
		SStgui.update_uis(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/machinery/chem_master/crowbar_act(mob/user, obj/item/I)
	if(!panel_open)
		balloon_alert(user, "техпанель закрыта!")
		return
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/chem_master/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(default_deconstruction_screwdriver(user, "mixer0_nopower", "mixer0", I))
		if(beaker)
			beaker.forceMove(get_turf(src))
			beaker = null
			reagents.clear_reagents()
		if(loaded_pill_bottle)
			loaded_pill_bottle.forceMove(get_turf(src))
			loaded_pill_bottle = null
		return TRUE

/obj/machinery/chem_master/wrench_act(mob/user, obj/item/I)
	if(panel_open)
		balloon_alert(user, "техпанель открыта!")
		return
	return default_unfasten_wrench(user, I, 4 SECONDS)

/obj/machinery/chem_master/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return

	if(ui_act_modal(action, params, ui, state))
		return TRUE

	add_fingerprint(usr)

	. = TRUE
	switch(action)
		if("toggle")
			mode = !mode
		if("ejectp")
			if(loaded_pill_bottle)
				loaded_pill_bottle.forceMove(loc)
				loaded_pill_bottle = null
		if("print")
			if(printing || condi)
				return

			var/idx = text2num(params["idx"]) || 0
			var/from_beaker = text2num(params["beaker"]) || FALSE
			var/reagent_list = from_beaker ? beaker.reagents.reagent_list : reagents.reagent_list
			if(idx < 1 || idx > length(reagent_list))
				return

			var/datum/reagent/R = reagent_list[idx]

			printing = TRUE
			visible_message(span_notice("[capitalize(declent_ru(NOMINATIVE))] дребезжит, после чего из окна печати выпадает лист бумаги."))
			playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, 1)

			var/obj/item/paper/P = new /obj/item/paper(loc)
			P.info = "<center><b>Химический анализ</b></center><br>"
			P.info += "<b>Время анализа:</b> [station_time_timestamp()]<br><br>"
			P.info += "<b>Название реагента:</b> [R.name]<br>"
			if(istype(R, /datum/reagent/blood))
				var/datum/reagent/blood/B = R
				P.info += "<b>Описание:</b> Н/Д<br><b>Группа крови:</b> [B.data["blood_type"]]<br><b>ДНК:</b> [B.data["blood_species"]]"
			else
				P.info += "<b>Описание:</b> [R.description]"
			P.info += "<br><br><b>Заметки:</b><br>"
			P.name = "Химический анализ - [R.name]"
			spawn(50)
				printing = FALSE

		if("set_production_mode")
			var/new_production_mode = params["production_mode"]
			var/datum/chemical_production_mode/M = production_modes[new_production_mode]
			if(isnull(M))
				return
			production_mode = new_production_mode

		if("set_sprite_style")
			var/production_mode_key = params["production_mode"]
			var/datum/chemical_production_mode/M = production_modes[production_mode_key]
			if(isnull(M))
				return
			if(!M.sprites)
				return
			var/new_style = text2num(params["style"])
			if(!ISINDEXSAFE(M.sprites, new_style))
				return
			M.set_sprite = new_style

		if("set_items_amount")
			var/production_mode_key = params["production_mode"]
			var/datum/chemical_production_mode/M = production_modes[production_mode_key]
			if(isnull(M))
				return
			var/new_amount = text2num(params["amount"])
			if(isnull(new_amount) || new_amount < 1 || new_amount > M.max_items_amount)
				return
			M.set_items_amount = new_amount

		if("set_items_name")
			var/production_mode_key = params["production_mode"]
			var/datum/chemical_production_mode/M = production_modes[production_mode_key]
			if(isnull(M))
				return
			if(M.set_name == CUSTOM_NAME_DISABLED)
				return
			var/new_name = sanitize(params["name"])
			// Allow name to be set to empty
			if(length(new_name) < 0 || length(new_name) > MAX_CUSTOM_NAME_LEN)
				return
			M.set_name = new_name

		// Container Customization
		if("clear_container_style")
			if(!loaded_pill_bottle)
				return
			loaded_pill_bottle.wrapper_color = null
			loaded_pill_bottle.cut_overlays()

		if("set_container_style")
			if(!loaded_pill_bottle) // wat?
				return
			var/new_color = params["style"]
			if(pill_bottle_wrappers[new_color])
				loaded_pill_bottle.wrapper_color = new_color
				loaded_pill_bottle.apply_wrap()
				playsound(loc, 'sound/effects/spray.ogg', 10, TRUE)
		else
			. = FALSE

	if(. || !beaker)
		return

	. = TRUE
	var/datum/reagents/R = beaker.reagents
	switch(action)
		if("add")
			var/id = params["id"]
			var/amount = text2num(params["amount"])
			if(!id || !amount)
				return
			R.trans_id_to(src, id, amount)
		if("remove")
			var/id = params["id"]
			var/amount = text2num(params["amount"])
			if(!id || !amount)
				return
			if(mode)
				reagents.trans_id_to(beaker, id, amount)
			else
				reagents.remove_reagent(id, amount)
		if("eject")
			if(!beaker)
				return
			beaker.forceMove(get_turf(src))
			if(Adjacent(usr) && !issilicon(usr))
				usr.put_in_hands(beaker, ignore_anim = FALSE)
			beaker = null
			reagents.clear_reagents()
			update_icon()
		if("create_items")
			if(!reagents.total_volume)
				return
			var/production_mode_key = params["production_mode"]
			var/datum/chemical_production_mode/M = production_modes[production_mode_key]
			if(isnull(M))
				return
			M.synthesize(ui.user, loc, reagents, loaded_pill_bottle)

/obj/machinery/chem_master/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/chem_master/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/chem_master/attack_hand(mob/user)
	if(..())
		return TRUE
	ui_interact(user)

/obj/machinery/chem_master/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/chem_master/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemMaster", "ХимМастер 3000")
		ui.open()

/obj/machinery/chem_master/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/chem_master),
		get_asset_datum(/datum/asset/spritesheet/chem_master/large)
	)

/obj/machinery/chem_master/ui_data(mob/user)
	var/data[0]

	data["condi"] = condi
	data["loaded_pill_bottle"] = loaded_pill_bottle ? TRUE : FALSE
	if(loaded_pill_bottle)
		data["loaded_pill_bottle_style"] = loaded_pill_bottle.wrapper_color

	data["beaker"] = beaker ? TRUE : FALSE
	if(beaker)
		var/list/beaker_reagents_list = list()
		data["beaker_reagents"] = beaker_reagents_list
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beaker_reagents_list[++beaker_reagents_list.len] = list("name" = R.name, "volume" = R.volume, "id" = R.id, "description" = R.description)
		var/list/buffer_reagents_list = list()
		data["buffer_reagents"] = buffer_reagents_list
		for(var/datum/reagent/R in reagents.reagent_list)
			buffer_reagents_list[++buffer_reagents_list.len] = list("name" = R.name, "volume" = R.volume, "id" = R.id, "description" = R.description)
	else
		data["beaker_reagents"] = list()
		data["buffer_reagents"] = list()

	var/production_data = list()
	for(var/key in production_modes)
		var/datum/chemical_production_mode/M = production_modes[key]
		var/mode_data = list(
			"set_items_amount" = M.set_items_amount,
		)
		if(M.set_name != CUSTOM_NAME_DISABLED)
			mode_data["set_name"] = M.set_name
			if(reagents.total_volume)
				mode_data["placeholder_name"] = M.get_placeholder_name(reagents)
		if(M.sprites)
			mode_data["set_sprite"] = M.set_sprite
		production_data[M.mode_id] = mode_data
	data["production_data"] = production_data

	data["mode"] = mode
	data["printing"] = printing

	// Transfer modal information if there is one
	data["modal"] = ui_modal_data(src)

	data["production_mode"] = production_mode

	return data

/obj/machinery/chem_master/ui_static_data(mob/user)
	var/list/data = list()

	data["maxnamelength"] = MAX_CUSTOM_NAME_LEN

	var/static_production_data = list()
	for(var/key in production_modes)
		var/datum/chemical_production_mode/M = production_modes[key]
		var/mode_data = list(
			"name" = M.production_name,
			"icon" = M.production_icon,
			"max_items_amount" = M.max_items_amount,
			"max_units_per_item" = M.max_units_per_item,
		)
		if(M.sprites)
			var/sprites = list()
			var/indexer = 0
			for(var/sprite in M.sprites)
				sprites += list(list(
					"id" = ++indexer,
					"sprite" = sprite,
				))
			mode_data["sprites"] = sprites
		static_production_data[M.mode_id] = mode_data
	data["static_production_data"] = static_production_data

	var/pill_bottle_styles[0]
	for(var/style in pill_bottle_wrappers)
		pill_bottle_styles += list(list(
			"color" = style,
			"name" = pill_bottle_wrappers[style],
		))
	data["containerstyles"] = pill_bottle_styles

	return data

/**
  * Called in ui_act() to process modal actions
  *
  * Arguments:
  * * action - The action passed by tgui
  * * params - The params passed by tgui
  */
/obj/machinery/chem_master/proc/ui_act_modal(action, params, datum/tgui/ui, datum/ui_state/state)
	. = TRUE
	var/id = params["id"] // The modal's ID
	var/list/arguments = istext(params["arguments"]) ? json_decode(params["arguments"]) : params["arguments"]
	switch(ui_modal_act(src, action, params))
		if(UI_MODAL_OPEN)
			switch(id)
				if("analyze")
					var/idx = text2num(arguments["idx"]) || 0
					var/from_beaker = text2num(arguments["beaker"]) || FALSE
					var/reagent_list = from_beaker ? beaker.reagents.reagent_list : reagents.reagent_list
					if(idx < 1 || idx > length(reagent_list))
						return

					var/datum/reagent/R = reagent_list[idx]
					var/list/result = list("idx" = idx, "name" = R.name, "desc" = R.description)
					if(!condi && istype(R, /datum/reagent/blood))
						var/datum/reagent/blood/B = R
						result["blood_type"] = B.data["blood_type"]
						result["blood_dna"] = B.data["blood_DNA"]

					arguments["analysis"] = result
					ui_modal_message(src, id, "", null, arguments)

				if("addcustom")
					if(!beaker || !beaker.reagents.total_volume)
						return
					ui_modal_input(src, id, "Укажите объём вещества для переноса в буфер:", null, arguments, useramount)

				if("removecustom")
					if(!reagents.total_volume)
						return
					ui_modal_input(src, id, "Укажите объём вещества для [mode ? "переноса в ёмкость" : "удаления"]:", null, arguments, useramount)
				else
					return FALSE

		if(UI_MODAL_ANSWER)
			var/answer = params["answer"]
			switch(id)
				if("addcustom")
					var/amount = isgoodnumber(text2num(answer))
					if(!amount || !arguments["id"])
						return
					ui_act("add", list("id" = arguments["id"], "amount" = amount), ui, state)
				if("removecustom")
					var/amount = isgoodnumber(text2num(answer))
					if(!amount || !arguments["id"])
						return
					ui_act("remove", list("id" = arguments["id"], "amount" = amount), ui, state)
				else
					return FALSE
		else
			return FALSE

/obj/machinery/chem_master/proc/isgoodnumber(num)
	if(isnum(num))
		if(num > 200)
			num = 200
		else if(num < 0)
			num = 1
		else
			num = round(num)
		return num
	else
		return FALSE

/obj/machinery/chem_master/condimaster
	name = "\improper CondiMaster 3000"
	desc = "Химическое оборудование, специализированное под кулинарные нужды. Позволяет создавать пакеты со специями или бутыли, как вы того пожелаете."
	ru_names = list(
		NOMINATIVE = "КондиМастер 3000",
		GENITIVE = "КондиМастера 3000",
		DATIVE = "КондиМастеру 3000",
		ACCUSATIVE = "КондиМастер 3000",
		INSTRUMENTAL = "КондиМастером 3000",
		PREPOSITIONAL = "КондиМастере 3000"
	)
	condi = TRUE

/obj/machinery/chem_master/condimaster/Initialize(mapload)
	. = ..()
	QDEL_LIST(component_parts)
	component_parts += new /obj/item/circuitboard/chem_master/condi_master(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker(null)
	RefreshParts()

/datum/chemical_production_mode
	var/mode_id = ""
	var/production_name = ""
	/// FontAwesome icon name
	var/production_icon = ""
	var/obj/item/reagent_containers/item_type
	var/list/sprites
	var/max_items_amount = 0
	var/max_units_per_item = 0
	var/name_suffix = ""

	var/set_sprite = 1
	var/set_name = ""
	var/set_items_amount = 1
	var/placeholder_name = ""

	var/sprite_mask = ""
	var/sprites_amount = 0

/datum/chemical_production_mode/New()
	. = ..()
	if(!sprite_mask)
		return
	sprites = list()
	for(var/i in 1 to sprites_amount)
		sprites += "[sprite_mask][i]"


/datum/chemical_production_mode/proc/get_placeholder_name(datum/reagents/reagents)
	return get_base_placeholder_name(reagents, clamp(reagents.total_volume / set_items_amount, 0, max_units_per_item))

/datum/chemical_production_mode/proc/get_base_placeholder_name(datum/reagents/reagents, amount_per_item)
	return "[reagents.get_master_reagent_name()] ([amount_per_item] ед.)"

/**
	public

	Configures the icon of the specified container P.

	required data Data persistent through invocations in the same loop.
	required R The reagents used to make the item P.
	required P The container to configure.
*/
/datum/chemical_production_mode/proc/configure_item(data, datum/reagents/R, obj/item/reagent_containers/P)
	if(sprites)
		P.icon_state = sprites[set_sprite]

/datum/chemical_production_mode/proc/synthesize(user, location, datum/reagents/reagents, obj/item/storage/S = null)
	if(!reagents.total_volume)
		return

	var/medicine_name = set_name
	var/count = set_items_amount
	var/amount_per_item = clamp(reagents.total_volume / count, 0, max_units_per_item)
	if(!isnull(medicine_name) && length(medicine_name) <= 0)
		medicine_name = get_base_placeholder_name(reagents, amount_per_item)

	var/data = list("count" = count)
	for(var/i in 1 to count)
		if(reagents.total_volume <= 0)
			to_chat(user, span_warning("Недостаточно реагентов для создания этого предмета!"))
			return

		var/obj/item/reagent_containers/P = new item_type(location)
		if(!isnull(medicine_name))
			P.name = "[name_suffix][medicine_name]"
			if(P.ru_names)
				for(var/j = 1; j <= 6; j++)
					P.ru_names[j] = "[P.ru_names[j]] - [medicine_name]"
		P.pixel_x = rand(-7, 7) // Random position
		P.pixel_y = rand(-7, 7)
		configure_item(data, reagents, P)
		reagents.trans_to(P, amount_per_item)

		// Load the items into the bottle if there's one loaded
		if(istype(S) && S.can_be_inserted(P, TRUE))
			P.forceMove(S)

/datum/chemical_production_mode/pills
	mode_id = "pills"
	production_name = "Таблетки"
	production_icon = "pills"
	item_type = /obj/item/reagent_containers/food/pill
	max_items_amount = MAX_MULTI_AMOUNT
	max_units_per_item = MAX_UNITS_PER_PILL
	name_suffix = "pill - "
	sprite_mask = "pill"
	sprites_amount = MAX_PILL_SPRITE

/datum/chemical_production_mode/patches
	mode_id = "patches"
	production_name = "Пластыри"
	production_icon = "plus-square"
	item_type = /obj/item/reagent_containers/food/pill/patch
	max_items_amount = MAX_MULTI_AMOUNT
	max_units_per_item = MAX_UNITS_PER_PATCH
	name_suffix = "patch - "
	sprite_mask = "bandaid"
	sprites_amount = MAX_PATCH_SPRITE

/datum/chemical_production_mode/patches/proc/SafetyCheck(datum/reagents/R)
	for(var/datum/reagent/A in R.reagent_list)
		if(!GLOB.safe_chem_list.Find(A.id))
			return FALSE
	return TRUE

/datum/chemical_production_mode/patches/configure_item(data, datum/reagents/R, obj/item/reagent_containers/food/pill/patch/P)
	..()
	var/chemicals_is_safe = data["chemicals_is_safe"]

	if(isnull(chemicals_is_safe))
		chemicals_is_safe = SafetyCheck(R)
		data["chemicals_is_safe"] = chemicals_is_safe

	if(chemicals_is_safe)
		P.instant_application = TRUE

/datum/chemical_production_mode/bottles
	mode_id = "chem_bottles"
	production_name = "Бутылки"
	production_icon = "wine-bottle"
	item_type = /obj/item/reagent_containers/glass/bottle/reagent
	sprites = list("bottle", "small_bottle", "wide_bottle", "round_bottle", "reagent_bottle")

	max_items_amount = 5
	max_units_per_item = 50
	name_suffix = "bottle - "

/datum/chemical_production_mode/bottles/get_base_placeholder_name(datum/reagents/reagents, amount_per_item)
	return reagents.get_master_reagent_name()

/datum/chemical_production_mode/condiment_bottles
	mode_id = "condi_bottles"
	production_name = "Бутылки"
	production_icon = "wine-bottle"
	item_type = /obj/item/reagent_containers/food/condiment
	max_items_amount = 5
	max_units_per_item = 50

	set_name = CUSTOM_NAME_DISABLED

/datum/chemical_production_mode/condiment_packs
	mode_id = "condi_packets"
	production_name = "Упаковки для специй"
	production_icon = "bacon"
	item_type = /obj/item/reagent_containers/food/condiment/pack
	max_items_amount = 10
	max_units_per_item = 10
	name_suffix = "pack - "

/datum/chemical_production_mode/condiment_packs/get_base_placeholder_name(datum/reagents/reagents, amount_per_item)
	return reagents.get_master_reagent_name()

#undef MAX_PILL_SPRITE
#undef MAX_CUSTOM_NAME_LEN

#undef CUSTOM_NAME_DISABLED

#undef TRANSFER_TO_DISPOSAL
#undef TRANSFER_TO_BEAKER
