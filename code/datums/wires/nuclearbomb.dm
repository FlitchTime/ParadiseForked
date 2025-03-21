/datum/wires/nuclearbomb
	holder_type = /obj/machinery/nuclearbomb
	randomize = TRUE
	wire_count = 7 // 3 actual, 4 duds.
	proper_name = "Nuclear bomb"
	window_x = 345
	window_y = 75

/datum/wires/nuclearbomb/New(atom/_holder)
	wires = list(WIRE_BOMB_LIGHT, WIRE_BOMB_TIMING, WIRE_BOMB_SAFETY)
	return ..()

/datum/wires/nuclearbomb/interactable(mob/user)
	var/obj/machinery/nuclearbomb/N = holder
	if(N.panel_open)
		return TRUE
	return FALSE

/datum/wires/nuclearbomb/get_status()
	. = ..()
	var/obj/machinery/nuclearbomb/N = holder
	. += "The device is [N.timing ? "shaking!" : "still."]"
	. += "The device is [N.safety ? "quiet" : "whirring"]."
	. += "The lights are [N.lighthack ? "static" : "functional"]."

/datum/wires/nuclearbomb/on_pulse(wire)
	var/obj/machinery/nuclearbomb/N = holder
	switch(wire)
		if(WIRE_BOMB_LIGHT)
			N.lighthack = !N.lighthack
			N.update_icon()
			addtimer(CALLBACK(N, TYPE_PROC_REF(/obj/machinery/nuclearbomb, reset_lighthack_callback)), 10 SECONDS)

		if(WIRE_BOMB_TIMING)
			if(N.timing)
				message_admins("[key_name_admin(usr)] pulsed a nuclear bomb's detonation wire, causing it to explode [ADMIN_COORDJMP(holder)]")
				N.explode()

		if(WIRE_BOMB_SAFETY)
			N.safety = !N.safety
			N.update_icon()
			addtimer(CALLBACK(N, TYPE_PROC_REF(/obj/machinery/nuclearbomb, reset_safety_callback)), 10 SECONDS)

/datum/wires/nuclearbomb/on_cut(wire, mend)
	var/obj/machinery/nuclearbomb/N = holder
	switch(wire)
		if(WIRE_BOMB_SAFETY)
			if(N.timing)
				message_admins("[key_name_admin(usr)] cut a nuclear bomb's timing wire, causing it to explode [ADMIN_COORDJMP(holder)]")
				N.explode()

		if(WIRE_BOMB_TIMING)
			if(!N.is_syndicate)
				set_security_level(N.previous_level)
			N.timing = FALSE
			N.update_icon()
			GLOB.bomb_set = FALSE
			SSshuttle?.remove_hostile_environment(N)

		if(WIRE_BOMB_LIGHT)
			N.lighthack = !N.lighthack
