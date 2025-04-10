#define SHEET_VOLUME 1000 //cm3

//Baseline portable generator. Has all the default handling. Not intended to be used on it's own (since it generates unlimited power).
/obj/machinery/power/port_gen
	name = "Placeholder Generator"	//seriously, don't use this. It can't be anchored without VV magic.
	desc = "A portable generator for emergency backup power"
	icon = 'icons/obj/engines_and_power/power.dmi'
	icon_state = "portgen0_0"
	density = TRUE
	anchored = FALSE
	use_power = NO_POWER_USE
	var/datum/looping_sound/port_gen/soundloop

	var/active = 0
	var/power_gen = 5000
	var/open = 0
	var/recent_fault = 0
	var/power_output = 1
	var/base_icon = "portgen0"

/obj/machinery/power/port_gen/Initialize(mapload)
	. = ..()
	soundloop = new(list(src), active)

/obj/machinery/power/port_gen/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/obj/machinery/power/port_gen/proc/IsBroken()
	return (stat & (BROKEN|EMPED))

/obj/machinery/power/port_gen/proc/HasFuel() //Placeholder for fuel check.
	return 1

/obj/machinery/power/port_gen/proc/UseFuel() //Placeholder for fuel use.
	return

/obj/machinery/power/port_gen/proc/DropFuel()
	return

/obj/machinery/power/port_gen/proc/handleInactive()
	return

/obj/machinery/power/port_gen/update_icon_state()
	icon_state = "[base_icon]_[active]"

/obj/machinery/power/port_gen/process()
	if(active && HasFuel() && !IsBroken() && anchored && powernet)
		add_avail(power_gen * power_output)
		UseFuel()
		soundloop.start()
	else
		active = 0
		handleInactive()
		update_icon(UPDATE_ICON_STATE)
		soundloop.stop()

/obj/machinery/power/powered()
	return TRUE //doesn't require an external power source

/obj/machinery/power/port_gen/attack_hand(mob/user as mob)
	if(..())
		return
	if(!anchored)
		return

/obj/machinery/power/port_gen/examine(mob/user)
	. = ..()
	if(!in_range(user, src))
		if(active)
			. += "<span class='notice'>The generator is on.</span>"
		else
			. += "<span class='notice'>The generator is off.</span>"

/obj/machinery/power/port_gen/emp_act(severity)
	var/duration = 6000 //ten minutes
	switch(severity)
		if(1)
			stat &= BROKEN
			if(prob(75)) explode()
		if(2)
			if(prob(25)) stat &= BROKEN
			if(prob(10)) explode()
		if(3)
			if(prob(10)) stat &= BROKEN
			duration = 300

	stat |= EMPED
	if(duration)
		spawn(duration)
			stat &= ~EMPED

/obj/machinery/power/port_gen/proc/explode()
	explosion(src.loc, -1, 3, 5, -1, cause = src)
	qdel(src)

#define TEMPERATURE_DIVISOR 40
#define TEMPERATURE_CHANGE_MAX 20

//A power generator that runs on solid plasma sheets.
/obj/machinery/power/port_gen/pacman
	name = "\improper P.A.C.M.A.N.-type Portable Generator"
	desc = "A power generator that runs on solid plasma sheets. Rated for 80 kW max safe output."

	var/sheet_name = "Plasma Sheets"
	var/sheet_path = /obj/item/stack/sheet/mineral/plasma
	var/board_path = /obj/item/circuitboard/pacman

	/*
		These values were chosen so that the generator can run safely up to 80 kW
		A full 50 plasma sheet stack should last 20 minutes at power_output = 4
		temperature_gain and max_temperature are set so that the max safe power level is 4.
		Setting to 5 or higher can only be done temporarily before the generator overheats.
	*/
	power_gen = 20000			//Watts output per power_output level
	var/max_power_output = 5	//The maximum power setting without emagging.
	var/max_safe_output = 4		// For UI use, maximal output that won't cause overheat.
	var/time_per_sheet = 96		//fuel efficiency - how long 1 sheet lasts at power level 1
	var/max_sheets = 100 		//max capacity of the hopper
	var/max_temperature = 300	//max temperature before overheating increases
	var/temperature_gain = 50	//how much the temperature increases per power output level, in degrees per level

	var/sheets = 0			//How many sheets of material are loaded in the generator
	var/sheet_left = 0		//How much is left of the current sheet
	var/temperature = 0		//The current temperature
	var/overheating = 0		//if this gets high enough the generator explodes

/obj/machinery/power/port_gen/pacman/Initialize()
	. = ..()
	if(anchored)
		connect_to_network()

/obj/machinery/power/port_gen/pacman/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new board_path(null)
	RefreshParts()

/obj/machinery/power/port_gen/pacman/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new board_path(null)
	RefreshParts()

/obj/machinery/power/port_gen/pacman/Destroy()
	DropFuel()
	return ..()

/obj/machinery/power/port_gen/pacman/RefreshParts()
	var/temp_rating = 0
	for(var/obj/item/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/stock_parts/matter_bin))
			max_sheets = SP.rating * SP.rating * 50
		else if(istype(SP, /obj/item/stock_parts/micro_laser) || istype(SP, /obj/item/stock_parts/capacitor))
			temp_rating += SP.rating

	power_gen = round(initial(power_gen) * (max(2, temp_rating) / 2))

/obj/machinery/power/port_gen/pacman/examine(mob/user)
	. = ..()
	. += "<span class='notice'>\The [src] appears to be producing [power_gen*power_output] W.</span>"
	. += "<span class='notice'>There [sheets == 1 ? "is" : "are"] [sheets] sheet\s left in the hopper.</span>"
	if(IsBroken())
		. += "<span class='warning'>\The [src] seems to have broken down.</span>"
	if(overheating)
		. += "<span class='danger'>\The [src] is overheating!</span>"

/obj/machinery/power/port_gen/pacman/HasFuel()
	var/needed_sheets = power_output / time_per_sheet
	if(sheets >= needed_sheets - sheet_left)
		return 1
	return 0

//Removes one stack's worth of material from the generator.
/obj/machinery/power/port_gen/pacman/DropFuel()
	if(sheets)
		var/obj/item/stack/sheet/mineral/S = new sheet_path(loc)
		var/amount = min(sheets, S.max_amount)
		S.amount = amount
		sheets -= amount

/obj/machinery/power/port_gen/pacman/UseFuel()

	//how much material are we using this iteration?
	var/needed_sheets = power_output / time_per_sheet

	//HasFuel() should guarantee us that there is enough fuel left, so no need to check that
	//the only thing we need to worry about is if we are going to rollover to the next sheet
	if(needed_sheets > sheet_left)
		sheets--
		sheet_left = (1 + sheet_left) - needed_sheets
	else
		sheet_left -= needed_sheets

	//calculate the "target" temperature range
	//This should probably depend on the external temperature somehow, but whatever.
	var/lower_limit = 56 + power_output * temperature_gain
	var/upper_limit = 76 + power_output * temperature_gain

	/*
		Hot or cold environments can affect the equilibrium temperature
		The lower the pressure the less effect it has. I guess it cools using a radiator or something when in vacuum.
		Gives traitors more opportunities to sabotage the generator or allows enterprising engineers to build additional
		cooling in order to get more power out.
	*/
	var/datum/gas_mixture/environment = loc.return_air()
	if(environment)
		var/ratio = min(environment.return_pressure()/ONE_ATMOSPHERE, 1)
		var/ambient = environment.temperature - T20C
		lower_limit += ambient*ratio
		upper_limit += ambient*ratio

	var/average = (upper_limit + lower_limit)/2

	//calculate the temperature increase
	var/bias = 0
	if(temperature < lower_limit)
		bias = min(round((average - temperature)/TEMPERATURE_DIVISOR, 1), TEMPERATURE_CHANGE_MAX)
	else if(temperature > upper_limit)
		bias = max(round((temperature - average)/TEMPERATURE_DIVISOR, 1), -TEMPERATURE_CHANGE_MAX)

	//limit temperature increase so that it cannot raise temperature above upper_limit,
	//or if it is already above upper_limit, limit the increase to 0.
	var/inc_limit = max(upper_limit - temperature, 0)
	var/dec_limit = min(temperature - lower_limit, 0)
	temperature += between(dec_limit, rand(-7 + bias, 7 + bias), inc_limit)

	if(temperature > max_temperature)
		overheat()
	else if(overheating > 0)
		overheating--

/obj/machinery/power/port_gen/pacman/handleInactive()
	var/cooling_temperature = 20
	var/datum/gas_mixture/environment = loc.return_air()
	if(environment)
		var/ratio = min(environment.return_pressure()/ONE_ATMOSPHERE, 1)
		var/ambient = environment.temperature - T20C
		cooling_temperature += ambient*ratio

	if(temperature > cooling_temperature)
		var/temp_loss = (temperature - cooling_temperature)/TEMPERATURE_DIVISOR
		temp_loss = between(2, round(temp_loss, 1), TEMPERATURE_CHANGE_MAX)
		temperature = max(temperature - temp_loss, cooling_temperature, TCMB)
		SStgui.update_uis(src)

	if(overheating)
		overheating--

/obj/machinery/power/port_gen/pacman/proc/overheat()
	overheating++
	if(overheating > 60)
		explode()

/obj/machinery/power/port_gen/pacman/explode()
	//Vapourize all the plasma
	//When ground up in a grinder, 1 sheet produces 20 u of plasma -- Chemistry-Machinery.dm
	//1 mol = 10 u? I dunno. 1 mol of carbon is definitely bigger than a pill
	/*var/plasma = (sheets+sheet_left)*20
	var/datum/gas_mixture/environment = loc.return_air()
	if(environment)
		environment.adjust_gas("plasma", plasma/10, temperature + T0C)*/

	sheets = 0
	sheet_left = 0
	..()

/obj/machinery/power/port_gen/pacman/emag_act(mob/user)
	if(active && prob(25))
		explode() //if they're foolish enough to emag while it's running

	if(!emagged)
		add_attack_logs(user, src, "emagged")
		emagged = 1
		return 1


/obj/machinery/power/port_gen/pacman/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(exchange_parts(user, I))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, sheet_path))
		add_fingerprint(user)
		var/obj/item/stack/addstack = I
		var/amount = min((max_sheets - sheets), addstack.get_amount())
		if(amount < 1)
			to_chat(user, span_warning("The [name] is full."))
			return ATTACK_CHAIN_PROCEED
		var/cached_name = addstack.name
		if(!addstack.use(amount))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You have added [amount] sheet\s of the [cached_name] into [src]."))
		sheets += amount
		SStgui.update_uis(src)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/machinery/power/port_gen/pacman/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(active)
		to_chat(user, span_warning("You cannot [panel_open ? "close" : "open"] the access panel while [src] is working."))
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	panel_open = !panel_open
	to_chat(user, span_notice("You have [panel_open ? "opened" : "closed"] the access panel."))


/obj/machinery/power/port_gen/pacman/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(active)
		to_chat(user, span_warning("You cannot [anchored ? "unsecure" : "secure"] [src] while its working."))
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	set_anchored(!anchored)
	if(anchored)
		to_chat(user, span_notice("You have secured [src] to the floor."))
		connect_to_network()
	else
		to_chat(user, span_notice("You have unsecured [src] from the floor."))
		disconnect_from_network()


/obj/machinery/power/port_gen/pacman/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(active)
		to_chat(user, span_warning("You cannot disassemble [src] while its working."))
		return .
	if(!panel_open)
		to_chat(user, span_warning("You cannot disassemble [src] while the access panel is closed."))
		return .
	return default_deconstruction_crowbar(user, I)


/obj/machinery/power/port_gen/pacman/attack_hand(mob/user)
	..()
	ui_interact(user)

/obj/machinery/power/port_gen/pacman/attack_ai(mob/user)
	add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/power/port_gen/pacman/attack_ghost(mob/user)
	return attack_hand(user)

/obj/machinery/power/port_gen/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Pacman", name)
		ui.open()

/obj/machinery/power/port_gen/pacman/ui_data(mob/user)
	var/list/data = list()

	data["active"] = active
	if(istype(user, /mob/living/silicon/ai))
		data["is_ai"] = TRUE
	else if(istype(user, /mob/living/silicon/robot) && !Adjacent(user))
		data["is_ai"] = TRUE
	else
		data["is_ai"] = FALSE

	data["anchored"] = anchored
	data["broken"] = IsBroken()
	data["output_set"] = power_output
	data["output_max"] = max_power_output
	data["output_safe"] = max_safe_output
	data["power_gen"] = power_gen
	data["tmp_current"] = temperature
	data["tmp_max"] = max_temperature
	data["tmp_overheat"] = overheating
	data["fuel_stored"] = round((sheets * SHEET_VOLUME) + (sheet_left * SHEET_VOLUME))
	data["fuel_cap"] = round(max_sheets * SHEET_VOLUME, 0.1)
	data["fuel_usage"] = active ? round((power_output / time_per_sheet) * SHEET_VOLUME) : 0
	data["fuel_type"] = sheet_name
	data["has_fuel"] = HasFuel()

	return data

/obj/machinery/power/port_gen/pacman/ui_act(action, params)
	if(..())
		return

	add_fingerprint(usr)

	. = TRUE

	switch(action)
		if("toggle_power")
			if(!powernet) //only a warning, process will disable
				atom_say("Не подключен к электросет+и.")
			active = !active
			update_icon(UPDATE_ICON_STATE)
		if("eject_fuel")
			DropFuel()
		if("change_power")
			var/newPower = text2num(params["change_power"])
			if(newPower)
				power_output = clamp(newPower, 1, max_power_output)

/obj/machinery/power/port_gen/pacman/super
	name = "S.U.P.E.R.P.A.C.M.A.N.-type Portable Generator"
	desc = "A power generator that utilizes uranium sheets as fuel. Can run for much longer than the standard PACMAN type generators. Rated for 80 kW max safe output."
	icon_state = "portgen1_0"
	base_icon = "portgen1"
	sheet_path = /obj/item/stack/sheet/mineral/uranium
	sheet_name = "Uranium Sheets"
	time_per_sheet = 576 //same power output, but a 50 sheet stack will last 2 hours at max safe power
	board_path = /obj/item/circuitboard/pacman/super

/obj/machinery/power/port_gen/pacman/super/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new board_path(null)
	RefreshParts()

/obj/machinery/power/port_gen/pacman/super/UseFuel()
	//produces a tiny amount of radiation when in use
	if(prob(2*power_output))
		for(var/mob/living/L in range(src, 5))
			L.apply_effect(1, IRRADIATE) //should amount to ~5 rads per minute at max safe power
	..()

/obj/machinery/power/port_gen/pacman/super/explode()
	//a nice burst of radiation
	var/rads = 50 + (sheets + sheet_left)*1.5
	for(var/mob/living/L in range(src, 10))
		//should really fall with the square of the distance, but that makes the rads value drop too fast
		//I dunno, maybe physics works different when you live in 2D -- SM radiation also works like this, apparently
		L.apply_effect(max(20, round(rads/get_dist(L,src))), IRRADIATE)

	explosion(src.loc, 3, 3, 5, 3, cause = src)
	qdel(src)

/obj/machinery/power/port_gen/pacman/mrs
	name = "M.R.S.P.A.C.M.A.N.-type Portable Generator"
	desc = "An advanced power generator that runs on diamonds. Rated for 200 kW maximum safe output!"
	icon_state = "portgen2_0"
	base_icon = "portgen2"
	sheet_path = /obj/item/stack/sheet/mineral/diamond
	sheet_name = "Diamond Sheets"

	//I don't think tritium has any other use, so we might as well make this rewarding for players
	//max safe power output (power level = 8) is 200 kW and lasts for 1 hour - 3 or 4 of these could power the station
	power_gen = 25000 //watts
	max_power_output = 10
	max_safe_output = 8
	time_per_sheet = 576
	max_temperature = 800
	temperature_gain = 90
	board_path = /obj/item/circuitboard/pacman/mrs

/obj/machinery/power/port_gen/pacman/mrs/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new board_path(null)
	RefreshParts()

/obj/machinery/power/port_gen/pacman/mrs/explode()
	//no special effects, but the explosion is pretty big (same as a supermatter shard).
	explosion(src.loc, 3, 6, 12, 16, 1, cause = src)
	qdel(src)
