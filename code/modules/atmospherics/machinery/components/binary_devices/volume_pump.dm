/*
Every cycle, the pump uses the air in air_in to try and make air_out the perfect pressure.

node1, air1, network1 correspond to input
node2, air2, network2 correspond to output

Thus, the two variables affect pump operation are set in New():
	air1.volume
		This is the volume of gas available to the pump that may be transfered to the output
	air2.volume
		Higher quantities of this cause more air to be perfected later
			but overall network volume is also increased as this increases...
*/

/obj/machinery/atmospherics/binary/volume_pump
	icon = 'icons/obj/pipes_and_stuff/atmospherics/atmos/volume_pump.dmi'
	icon_state = "map_off"

	name = "volumetric gas pump"
	desc = "A volumetric pump"

	can_unwrench = TRUE
	interaction_flags_click = NEED_HANDS | ALLOW_RESTING | ALLOW_SILICON_REACH

	on = FALSE
	var/transfer_rate = 200

	var/id = null

/obj/machinery/atmospherics/binary/volume_pump/CtrlClick(mob/living/user)
	if(!ishuman(user) && !issilicon(user))
		return
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		to_chat(user, span_warning("You can't do that right now!"))
		return
	if(!in_range(src, user) && !issilicon(user))
		return
	toggle()

/obj/machinery/atmospherics/binary/volume_pump/AICtrlClick()
	toggle()
	return ..()

/obj/machinery/atmospherics/binary/volume_pump/click_alt(mob/living/user)
	set_max()
	return CLICK_ACTION_SUCCESS

/obj/machinery/atmospherics/binary/volume_pump/ai_click_alt()
	set_max()
	return ..()


/obj/machinery/atmospherics/binary/volume_pump/proc/set_max()
	if(powered())
		transfer_rate = MAX_TRANSFER_RATE
		update_icon()

/obj/machinery/atmospherics/binary/volume_pump/Destroy()
	if(SSradio)
		SSradio.remove_object(src, frequency)
	radio_connection = null
	return ..()

/obj/machinery/atmospherics/binary/volume_pump/on
	on = 1
	icon_state = "map_on"

/obj/machinery/atmospherics/binary/volume_pump/atmos_init()
	..()
	set_frequency(frequency)

/obj/machinery/atmospherics/binary/volume_pump/update_icon_state()
	..()

	if(!powered())
		icon_state = "off"
	else
		icon_state = "[on ? "on" : "off"]"

/obj/machinery/atmospherics/binary/volume_pump/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, node1, turn(dir, -180))
		add_underlay(T, node2, dir)

/obj/machinery/atmospherics/binary/volume_pump/process_atmos()
	..()
	if((stat & (NOPOWER|BROKEN)) || !on)
		return 0

	// Pump mechanism just won't do anything if the pressure is too high/too low
	var/input_starting_pressure = air1.return_pressure()
	var/output_starting_pressure = air2.return_pressure()

	if((input_starting_pressure < 0.01) || (output_starting_pressure > 9000))
		return 1

	var/transfer_ratio = max(1, transfer_rate/air1.volume)

	var/datum/gas_mixture/removed = air1.remove_ratio(transfer_ratio)

	air2.merge(removed)


	parent1.update = 1
	parent2.update = 1

	return 1

/obj/machinery/atmospherics/binary/volume_pump/proc/broadcast_status()
	if(!radio_connection)
		return 0

	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = list(
		"tag" = id,
		"device" = "APV",
		"power" = on,
		"transfer_rate" = transfer_rate,
		"sigtype" = "status"
	)
	radio_connection.post_signal(src, signal)

	return 1

/obj/machinery/atmospherics/binary/volume_pump/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id) || (signal.data["sigtype"]!="command"))
		return 0

	var/old_on = on //for logging

	if(signal.data["power"])
		on = text2num(signal.data["power"])

	if(signal.data["power_toggle"])
		on = !on

	if(signal.data["set_transfer_rate"])
		transfer_rate = between(
			0,
			text2num(signal.data["set_transfer_rate"]),
			air1.volume
		)

	if(on != old_on)
		investigate_log("was turned [on ? "on" : "off"] by a remote signal", INVESTIGATE_ATMOS)

	if(signal.data["status"])
		spawn(2)
			broadcast_status()
		return //do not update_icon

	spawn(2)
		broadcast_status()
	update_icon()

/obj/machinery/atmospherics/binary/volume_pump/attack_hand(mob/user)
	if(..())
		return

	if(!allowed(user))
		to_chat(user, span_alert("Access denied."))
		return

	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/atmospherics/binary/volume_pump/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/atmospherics/binary/volume_pump/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosPump", name)
		ui.open()

/obj/machinery/atmospherics/binary/volume_pump/ui_data(mob/user)
	var/list/data = list(
		"on" = on,
		"rate" = round(transfer_rate),
		"max_rate" = round(MAX_TRANSFER_RATE),
		"gas_unit" = "L/s",
		"step" = 1 // This is for the TGUI <NumberInput> step. It's here since multiple pumps share the same UI, but need different values.
	)
	return data

/obj/machinery/atmospherics/binary/volume_pump/ui_act(action, list/params)
	if(..())
		return

	switch(action)
		if("power")
			toggle()
			investigate_log("was turned [on ? "on" : "off"] by [key_name_log(usr)]", INVESTIGATE_ATMOS)
			return TRUE

		if("max_rate")
			transfer_rate = MAX_TRANSFER_RATE
			. = TRUE

		if("min_rate")
			transfer_rate = 0
			. = TRUE

		if("custom_rate")
			transfer_rate = clamp(text2num(params["rate"]), 0 , MAX_TRANSFER_RATE)
			. = TRUE
	if(.)
		investigate_log("was set to [transfer_rate] L/s by [key_name_log(usr)]", INVESTIGATE_ATMOS)

/obj/machinery/atmospherics/binary/volume_pump/power_change(forced = FALSE)
	if(!..())
		return
	update_icon()


/obj/machinery/atmospherics/binary/volume_pump/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		return .

	. |= ATTACK_CHAIN_SUCCESS
	rename_interactive(user, I)

