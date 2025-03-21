/obj/machinery/atmospherics/unary/cold_sink/freezer
	name = "охладитель"
	icon = 'icons/obj/machines/cryogenic2.dmi'
	icon_state = "freezer"
	density = TRUE
	var/min_temperature = 0
	anchored = TRUE
	use_power = IDLE_POWER_USE
	active_power_usage = 5000	//cooling down massive amounts of air's not cheap. This is still very low considering everything
	power_channel = EQUIP
	current_heat_capacity = 1000
	layer = 3
	plane = GAME_PLANE
	resistance_flags = null
	max_integrity = 300
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 100, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 80, "acid" = 30)

/obj/machinery/atmospherics/unary/cold_sink/freezer/New()
	..()
	initialize_directions = dir
	component_parts = list()
	component_parts += new /obj/item/circuitboard/thermomachine(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/atmospherics/unary/cold_sink/freezer/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/thermomachine(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/atmospherics/unary/cold_sink/freezer/RefreshParts()
	var/H
	var/T
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		H += M.rating
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		T += M.rating
	min_temperature = max(TCMB, T0C - (170 + (T*15)))
	current_heat_capacity = 1000 * ((H - 1) ** 2)

/obj/machinery/atmospherics/unary/cold_sink/freezer/on_construction()
	..(dir,dir)

/obj/machinery/atmospherics/unary/cold_sink/freezer/process()
	return	// need to overwrite the parent or it returns PROCESS_KILL and it stops processing/using power


/obj/machinery/atmospherics/unary/cold_sink/freezer/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(exchange_parts(user, I))
		return ATTACK_CHAIN_PROCEED_SUCCESS
	return ..()


/obj/machinery/atmospherics/unary/cold_sink/freezer/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/atmospherics/unary/cold_sink/freezer/screwdriver_act(mob/user, obj/item/I)
	if(default_deconstruction_screwdriver(user, "freezer-o", "freezer", I))
		on = FALSE
		use_power = IDLE_POWER_USE
		update_icon(UPDATE_ICON_STATE)
		return TRUE

/obj/machinery/atmospherics/unary/cold_sink/freezer/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!panel_open)
		to_chat(user, span_notice("Сначала откройте панель техобслуживания."))
		return
	var/list/choices = list("West" = WEST, "East" = EAST, "South" = SOUTH, "North" = NORTH)
	var/selected = input(user,"Выберите направление соединения.", "Направление соединения") in choices
	dir = choices[selected]
	var/node_connect = dir
	initialize_directions = dir
	for(var/obj/machinery/atmospherics/target in get_step(src,node_connect))
		if(target.initialize_directions & get_dir(target,src))
			node = target
			break
	build_network()
	update_icon()

/obj/machinery/atmospherics/unary/cold_sink/freezer/update_icon_state()
	if(panel_open)
		icon_state = "freezer-o"
	else if(on)
		icon_state = "freezer_1"
	else
		icon_state = "freezer"


/obj/machinery/atmospherics/unary/cold_sink/freezer/attack_ai(mob/user as mob)
	attack_hand(user)

/obj/machinery/atmospherics/unary/cold_sink/freezer/attack_ghost(mob/user as mob)
	attack_hand(user)

/obj/machinery/atmospherics/unary/cold_sink/freezer/attack_hand(mob/user as mob)
	if(..())
		return TRUE

	if(panel_open)
		to_chat(user, span_notice("Сначала закройте панель техобслуживания."))
		return

	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/atmospherics/unary/cold_sink/freezer/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GasFreezer", "Газоохладительная система")
		ui.open()

/obj/machinery/atmospherics/unary/cold_sink/freezer/ui_data(mob/user)
	var/list/data = list()
	data["on"] = on
	data["pressure"] = round(air_contents.return_pressure())
	data["temperature"] = round(air_contents.temperature)
	data["temperatureCelsius"] = round(air_contents.temperature - T0C, 1)
	if(air_contents.total_moles() == 0 && air_contents.temperature == 0)
		data["temperatureCelsius"] = 0
	data["min"] = round(min_temperature)
	data["max"] = round(T20C)
	data["target"] = round(current_temperature)
	data["targetCelsius"] = round(current_temperature - T0C, 1)
	return data

/obj/machinery/atmospherics/unary/cold_sink/freezer/ui_act(action, params)
	if(..())
		return
	add_fingerprint(usr)
	. = TRUE

	switch(action)
		if("power")
			on = !on
			if(on)
				use_power = ACTIVE_POWER_USE
			else
				use_power = IDLE_POWER_USE
			update_icon()
		if("minimum")
			current_temperature = min_temperature
		if("maximum")
			current_temperature = T20C
		if("temp")
			var/amount = params["temp"]
			amount = text2num(amount)
			current_temperature = clamp(amount, T20C, min_temperature)

/obj/machinery/atmospherics/unary/cold_sink/freezer/power_change(forced = FALSE)
	if(!..())
		return
	if(stat & NOPOWER)
		on = FALSE
		use_power = IDLE_POWER_USE
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/atmospherics/unary/heat_reservoir/heater/
	name = "нагреватель"
	icon = 'icons/obj/machines/cryogenic2.dmi'
	icon_state = "heater"
	density = TRUE
	var/max_temperature = 0
	anchored = TRUE
	layer = 3
	current_heat_capacity = 1000
	active_power_usage = 5000
	power_channel = EQUIP
	max_integrity = 300
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 100, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 80, "acid" = 30)

/obj/machinery/atmospherics/unary/heat_reservoir/heater/New()
	..()
	initialize_directions = dir
	var/obj/item/circuitboard/thermomachine/H = new /obj/item/circuitboard/thermomachine(null)
	H.build_path = /obj/machinery/atmospherics/unary/heat_reservoir/heater
	H.name = "circuit board (Нагреватель)"
	component_parts = list()
	component_parts += H
	component_parts += new /obj/item/stock_parts/matter_bin(src)
	component_parts += new /obj/item/stock_parts/matter_bin(src)
	component_parts += new /obj/item/stock_parts/micro_laser(src)
	component_parts += new /obj/item/stock_parts/micro_laser(src)
	component_parts += new /obj/item/stack/sheet/glass(src)
	component_parts += new /obj/item/stack/cable_coil(src, 1)
	RefreshParts()

/obj/machinery/atmospherics/unary/heat_reservoir/heater/upgraded/New()
	..()
	var/obj/item/circuitboard/thermomachine/H = new /obj/item/circuitboard/thermomachine(null)
	H.build_path = /obj/machinery/atmospherics/unary/heat_reservoir/heater
	H.name = "circuit board (Нагреватель)"
	component_parts = list()
	component_parts += H
	component_parts += new /obj/item/stock_parts/matter_bin/super(src)
	component_parts += new /obj/item/stock_parts/matter_bin/super(src)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(src)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(src)
	component_parts += new /obj/item/stack/sheet/glass(src)
	component_parts += new /obj/item/stack/cable_coil(src, 1)
	RefreshParts()

/obj/machinery/atmospherics/unary/heat_reservoir/heater/on_construction()
	..(dir,dir)

/obj/machinery/atmospherics/unary/heat_reservoir/heater/process()
	return	// need to override the parent or it stops processing, meaning it stops using power.

/obj/machinery/atmospherics/unary/heat_reservoir/heater/RefreshParts()
	var/H
	var/T
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		H += M.rating
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		T += M.rating
	max_temperature = T20C + (140 * T)
	current_heat_capacity = 1000 * ((H - 1) ** 2)


/obj/machinery/atmospherics/unary/heat_reservoir/heater/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(exchange_parts(user, I))
		return ATTACK_CHAIN_PROCEED_SUCCESS
	return ..()


/obj/machinery/atmospherics/unary/heat_reservoir/heater/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/atmospherics/unary/heat_reservoir/heater/screwdriver_act(mob/user, obj/item/I)
	if(default_deconstruction_screwdriver(user, "heater-o", "heater", I))
		on = 0
		use_power = IDLE_POWER_USE
		update_icon(UPDATE_ICON_STATE)
		return TRUE

/obj/machinery/atmospherics/unary/heat_reservoir/heater/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!panel_open)
		to_chat(user, span_notice("Сначала откройте панель техобслуживания."))
		return
	var/list/choices = list("West" = WEST, "East" = EAST, "South" = SOUTH, "North" = NORTH)
	var/selected = input(user,"Выберите направление соединения.", "Направление соединения") in choices
	dir = choices[selected]
	var/node_connect = dir
	initialize_directions = dir
	for(var/obj/machinery/atmospherics/target in get_step(src,node_connect))
		if(target.initialize_directions & get_dir(target,src))
			node = target
			break
	build_network()
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/atmospherics/unary/heat_reservoir/heater/update_icon_state()
	if(panel_open)
		icon_state = "heater-o"
	else if(on)
		icon_state = "heater_1"
	else
		icon_state = "heater"


/obj/machinery/atmospherics/unary/heat_reservoir/heater/attack_ai(mob/user as mob)
	attack_hand(user)

/obj/machinery/atmospherics/unary/heat_reservoir/heater/attack_ghost(mob/user as mob)
	src.attack_hand(user)

/obj/machinery/atmospherics/unary/heat_reservoir/heater/attack_hand(mob/user as mob)
	if(panel_open)
		to_chat(user, span_notice("Сначала закройте панель техобслуживания."))
		return

	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/atmospherics/unary/heat_reservoir/heater/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GasFreezer", "Газонагревательная система")
		ui.open()

/obj/machinery/atmospherics/unary/heat_reservoir/heater/ui_data(mob/user)
	var/list/data = list()
	data["on"] = on
	data["pressure"] = round(air_contents.return_pressure())
	data["temperature"] = round(air_contents.temperature)
	data["temperatureCelsius"] = round(air_contents.temperature - T0C, 1)
	if(air_contents.total_moles() == 0 && air_contents.temperature == 0)
		data["temperatureCelsius"] = 0
	data["min"] = round(T20C)
	data["max"] = round(T20C + max_temperature)
	data["target"] = round(current_temperature)
	data["targetCelsius"] = round(current_temperature - T0C, 1)
	return data

/obj/machinery/atmospherics/unary/heat_reservoir/heater/ui_act(action, params)
	if(..())
		return
	add_fingerprint(usr)
	. = TRUE

	switch(action)
		if("power")
			on = !on
			if(on)
				use_power = ACTIVE_POWER_USE
			else
				use_power = IDLE_POWER_USE
			update_icon()
		if("minimum")
			current_temperature = T20C
		if("maximum")
			current_temperature = max_temperature + T20C
		if("temp")
			var/amount = params["temp"]
			amount = text2num(amount)
			current_temperature = clamp(amount, T20C, T20C + max_temperature)


/obj/machinery/atmospherics/unary/heat_reservoir/heater/power_change(forced = FALSE)
	if(!..())
		return
	if(stat & NOPOWER)
		on = FALSE
		use_power = IDLE_POWER_USE
	update_icon(UPDATE_ICON_STATE)

