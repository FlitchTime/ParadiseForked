/*
FIRE ALARM
*/

GLOBAL_LIST_EMPTY(firealarms)

#define FIRE_ALARM_FRAME	0
#define FIRE_ALARM_UNWIRED	1
#define FIRE_ALARM_READY	2

/obj/machinery/firealarm
	name = "fire alarm"
	desc = "<i>\"Pull this in case of emergency\"</i>. Thus, keep pulling it forever."
	icon = 'icons/obj/machines/monitors.dmi'
	icon_state = "firealarm_on"
	anchored = TRUE
	max_integrity = 250
	integrity_failure = 100
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 100, rad = 100, fire = 90, acid = 30)
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = ENVIRON
	resistance_flags = FIRE_PROOF

	var/buildstage = FIRE_ALARM_READY
	var/wiresexposed = FALSE
	var/detecting = TRUE
	var/working = TRUE
	/// Should triggered fire alarms also trigger an actual alarm?
	var/report_fire_alarms = TRUE
	/// Should fire alarms display the current alert level?
	var/show_alert_level = TRUE
	/// Used to prevent pulling spam by same persons
	var/last_time_pulled

/obj/machinery/firealarm/Initialize(mapload, direction, building)
	. = ..()

	GLOB.firealarms += src

	if(building)
		buildstage = FIRE_ALARM_FRAME
		wiresexposed = TRUE
		setDir(direction)
		set_pixel_offsets_from_dir(26, -26, 26, -26)

	if(istype(get_area(src), /area))
		LAZYADD(GLOB.station_fire_alarms["[z]"], src)

	myArea = get_area(src)
	LAZYADD(myArea.firealarms, src)
	update_fire_light()
	update_icon()


/obj/machinery/firealarm/Destroy()
	GLOB.firealarms -= src
	LAZYREMOVE(GLOB.station_fire_alarms["[z]"], src)
	LAZYREMOVE(myArea.firealarms, src)
	return ..()


/obj/machinery/firealarm/no_alarm
	report_fire_alarms = FALSE

/obj/machinery/firealarm/syndicate
	report_fire_alarms = FALSE
	show_alert_level = FALSE

/obj/machinery/firealarm/syndicate/taipan
	report_fire_alarms = TRUE
	show_alert_level = FALSE


/obj/machinery/firealarm/update_icon_state()
	if(wiresexposed)
		icon_state = "firealarm_b[buildstage]"
		return
	if(stat & BROKEN)
		icon_state = "firealarm_broken"
		return
	if(stat & NOPOWER)
		icon_state = "firealarm_off"
		return

	var/area/area = get_area(src)
	if(area.fire)
		icon_state = "firealarm_alarming"
		return
	if(!detecting)
		icon_state = "firealarm_detect"
		return
	else
		icon_state = "firealarm_on"


/obj/machinery/firealarm/update_overlays()
	. = ..()
	underlays.Cut()

	if(stat & (NOPOWER|BROKEN))
		return

	if(is_station_contact(z) && show_alert_level)

		. += "overlay_[get_security_level()]"
		underlays += emissive_appearance(icon, "firealarm_overlay_lightmask", src)

	if(!wiresexposed)
		underlays += emissive_appearance(icon, "firealarm_lightmask", src)


/obj/machinery/firealarm/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		if(user)
			user.visible_message(span_warning("Sparks fly out of the [src]!"), span_notice("You emag [src], disabling its thermal sensors."))
		playsound(loc, 'sound/effects/sparks4.ogg', 50, 1)

/obj/machinery/firealarm/temperature_expose(datum/gas_mixture/air, temperature, volume)
	..()
	if(!emagged && detecting && temperature > T0C + 200)
		alarm()			// added check of detector status here

/obj/machinery/firealarm/attack_ai(mob/user)
	add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/firealarm/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		toggle_alarm(user)

/obj/machinery/firealarm/emp_act(severity)
	if(prob(50/severity))
		alarm(rand(30/severity, 60/severity))
	..()


/obj/machinery/firealarm/attackby(obj/item/I, mob/user, params)
	if(!wiresexposed || user.a_intent == INTENT_HARM)
		return ..()

	switch(buildstage)
		if(FIRE_ALARM_UNWIRED)
			if(istype(I, /obj/item/stack/cable_coil))
				add_fingerprint(user)
				var/obj/item/stack/cable_coil/coil = I
				if(!coil.use(5))
					to_chat(user, span_warning("You need more cable for this!"))
					return ATTACK_CHAIN_PROCEED
				buildstage = FIRE_ALARM_READY
				playsound(get_turf(src), I.usesound, 50, 1)
				to_chat(user, span_notice("You wire [src]!"))
				update_icon()
				return ATTACK_CHAIN_PROCEED_SUCCESS

		if(FIRE_ALARM_FRAME)
			if(istype(I, /obj/item/firealarm_electronics))
				if(!user.drop_transfer_item_to_loc(I, src))
					return ..()
				add_fingerprint(user)
				to_chat(user, span_notice("You insert the circuit!"))
				qdel(I)
				buildstage = FIRE_ALARM_UNWIRED
				update_icon()
				return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/machinery/firealarm/crowbar_act(mob/user, obj/item/I)
	if(buildstage != FIRE_ALARM_UNWIRED)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	CROWBAR_ATTEMPT_PRY_CIRCUIT_MESSAGE
	if(!I.use_tool(src, user, 20, volume = I.tool_volume) || buildstage != FIRE_ALARM_UNWIRED)
		return
	new /obj/item/firealarm_electronics(drop_location())
	buildstage = FIRE_ALARM_FRAME
	update_icon()
	CROWBAR_PRY_CIRCUIT_SUCCESS_MESSAGE

/obj/machinery/firealarm/multitool_act(mob/user, obj/item/I)
	if(buildstage != FIRE_ALARM_READY)
		return
	. = TRUE
	if(!wiresexposed)
		to_chat(user, span_warning("You need to expose the wires first!"))
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	detecting = !detecting
	update_icon()
	if(detecting)
		user.visible_message(span_warning("[user] has reconnected [src]'s detecting unit!"), "You have reconnected [src]'s detecting unit.")
	else
		user.visible_message(span_warning("[user] has disconnected [src]'s detecting unit!"), "You have disconnected [src]'s detecting unit.")

/obj/machinery/firealarm/screwdriver_act(mob/user, obj/item/I)
	if(buildstage != FIRE_ALARM_READY)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	wiresexposed = !wiresexposed
	if(wiresexposed)
		SCREWDRIVER_OPEN_PANEL_MESSAGE
	else
		SCREWDRIVER_CLOSE_PANEL_MESSAGE
	update_icon()

/obj/machinery/firealarm/wirecutter_act(mob/user, obj/item/I)
	if(buildstage != FIRE_ALARM_READY)
		return
	. = TRUE
	if(!wiresexposed)
		to_chat(user, span_warning("You need to expose the wires first!"))
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	WIRECUTTER_SNIP_MESSAGE
	new /obj/item/stack/cable_coil(drop_location(), 5)
	buildstage = FIRE_ALARM_UNWIRED
	update_icon()


/obj/machinery/firealarm/wrench_act(mob/user, obj/item/I)
	if(buildstage != FIRE_ALARM_FRAME)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	WRENCH_UNANCHOR_WALL_MESSAGE
	new /obj/item/mounted/frame/firealarm(get_turf(user))
	qdel(src)

/obj/machinery/firealarm/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(.) //damage received
		if(obj_integrity > 0 && !(stat & BROKEN) && buildstage != 0)
			if(prob(33))
				alarm()

/obj/machinery/firealarm/singularity_pull(S, current_size)
	if (current_size >= STAGE_FIVE) // If the singulo is strong enough to pull anchored objects, the fire alarm experiences integrity failure
		deconstruct()
	..()

/obj/machinery/firealarm/obj_break(damage_flag)
	if(!(stat & BROKEN) && !(obj_flags & NODECONSTRUCT) && buildstage != 0) //can't break the electronics if there isn't any inside.
		stat |= BROKEN
		LAZYREMOVE(myArea.firealarms, src)
		update_icon()

/obj/machinery/firealarm/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(loc, 1)
		if(!(stat & BROKEN))
			var/obj/item/I = new /obj/item/firealarm_electronics(loc)
			if(!disassembled)
				I.obj_integrity = I.max_integrity * 0.5
		new /obj/item/stack/cable_coil(loc, 3)
	qdel(src)


/obj/machinery/firealarm/proc/update_fire_light()
	if(stat & NOPOWER)
		set_light_on(FALSE)
		return

	if(GLOB.security_level == SEC_LEVEL_EPSILON)
		set_light(2, 1, COLOR_WHITE, TRUE)
		return

	if(myArea?.fire)
		set_light(3, 1, "#ff3232", TRUE)
	else
		set_light_on(FALSE)


/obj/machinery/firealarm/power_change(forced = FALSE)
	. = ..()
	if(.)
		update_fire_light()
		update_icon()


/obj/machinery/firealarm/attack_hand(mob/user)
	if(stat & (NOPOWER|BROKEN) || buildstage != 2)
		return TRUE

	if(user.incapacitated())
		return TRUE

	. = FALSE

	if(fingerprintslast == user.ckey && world.time < last_time_pulled + 5 SECONDS) //no spamming >:C
		to_chat(user, span_warning("[src] is still processing your earlier command."))
		return .

	toggle_alarm(user)


/obj/machinery/firealarm/proc/toggle_alarm(mob/user)
	var/area/A = get_area(src)
	if(istype(A))
		add_fingerprint(user)
		last_time_pulled = world.time
		if(A.fire)
			reset()
		else
			alarm()


/obj/machinery/firealarm/examine(mob/user)
	. = ..()
	switch(buildstage)
		if(FIRE_ALARM_FRAME)
			. += "<span class='notice'>It's missing a <i>circuit board<i> and the <b>bolts</b> are exposed.</span>"
		if(FIRE_ALARM_UNWIRED)
			. += "<span class='notice'>The control board needs <i>wiring</i> and can be <b>pried out</b>.</span>"
		if(FIRE_ALARM_READY)
			if(wiresexposed)
				. += "<span class='notice'>The fire alarm's <b>wires</b> are exposed by the <i>unscrewed</i> panel.</span>"
				. += "<span class='notice'>The detection circuitry can be turned <b>[detecting ? "off" : "on"]</b> by <i>pulsing</i> the board.</span>"

	. += "It shows the alert level as: <b><u>[capitalize(get_security_level())]</u></b>."


/obj/machinery/firealarm/proc/reset()
	if(!working || !report_fire_alarms)
		return
	myArea?.firereset(src)


/obj/machinery/firealarm/proc/alarm()
	if(!working || !report_fire_alarms)
		return
	myArea?.firealert(src)


/*
FIRE ALARM CIRCUIT
Just a object used in constructing fire alarms
*/
/obj/item/firealarm_electronics
	name = "fire alarm electronics"
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_electronics"
	desc = "A circuit. It has a label on it, it says \"Can handle heat levels up to 40 degrees celsius!\""
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=50, MAT_GLASS=50)
	origin_tech = "engineering=2;programming=1"
	toolspeed = 1
	usesound = 'sound/items/deconstruct.ogg'


#undef FIRE_ALARM_FRAME
#undef FIRE_ALARM_UNWIRED
#undef FIRE_ALARM_READY

