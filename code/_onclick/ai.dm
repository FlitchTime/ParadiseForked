/*
	AI ClickOn()

	The AI can double click to move the camera (this was already true but is cleaner),
	or double click a mob to track them.

	Note that AI have no need for the adjacency proc, and so this proc is a lot cleaner.
*/
/mob/living/silicon/ai/DblClickOn(atom/A, params)
	if(client.click_intercept)
		// Not doing a click intercept here, because otherwise we double-tap with the `ClickOn` proc.
		// But we return here since we don't want to do regular dblclick handling
		return

	if(control_disabled || stat) return

	if(ismob(A))
		ai_actual_track(A)
	else
		A.move_camera_by_click()


/mob/living/silicon/ai/ClickOn(atom/A, params)
	if(client.click_intercept)
		client.click_intercept.InterceptClickOn(src, params, A)
		return

	if(next_click > world.time)
		return
	changeNext_click(1)

	if(control_disabled || stat)
		return

	var/turf/pixel_turf = isturf(A) ? A : get_turf_pixel(A)
	if(isnull(pixel_turf))
		return
	if(!can_see(A))
		if(isturf(A)) //On unmodified clients clicking the static overlay clicks the turf underneath
			return // So there's no point messaging admins
		message_admins("[key_name_admin(src)] might be running a modified client! (failed can_see on AI click of [A]([ADMIN_COORDJMP(pixel_turf)]))")
		var/message = "[key_name(src)] might be running a modified client! (failed can_see on AI click of [A]([COORD(pixel_turf)]))"
		add_attack_logs(src, src, message, ATKLOG_ALL)
		log_admin(message)
		SSdiscord.send2discord_simple_noadmins("**\[Warning]** [key_name(src)] might be running a modified client! (failed checkTurfVis on AI click of [A]([COORD(pixel_turf)]))")


	var/turf_visible
	if(pixel_turf)
		turf_visible = GLOB.cameranet.checkTurfVis(pixel_turf)
		if(!turf_visible)
			if(istype(loc, /obj/item/aicard) && (pixel_turf in view(client.view, loc)))
				turf_visible = TRUE
			else
				message_admins("[key_name_admin(src)] might be running a modified client! (failed can_see on AI click of [A]([ADMIN_COORDJMP(pixel_turf)]))")
				var/message = "[key_name(src)] might be running a modified client! (failed can_see on AI click of [A]([COORD(pixel_turf)]))"
				add_attack_logs(src, src, message, ATKLOG_ALL)
				log_admin(message)
				SSdiscord.send2discord_simple_noadmins("**\[Warning]** [key_name(src)] might be running a modified client! (failed checkTurfVis on AI click of [A]([COORD(pixel_turf)]))")
				return

	var/list/modifiers = params2list(params)

	if(modifiers["middle"] && modifiers["shift"] && modifiers["alt"])
		MiddleShiftAltClickOn(A)
		return
	if(modifiers["middle"] && modifiers["ctrl"])
		MiddleControlClickOn(A)
		return
	if(modifiers["middle"] && modifiers["shift"])
		MiddleShiftClickOn(A)
		return
	if(modifiers["middle"] && modifiers["alt"])
		MiddleAltClickOn(A)
		return
	if(modifiers["shift"] && modifiers["ctrl"])
		CtrlShiftClickOn(A)
		return
	if(modifiers["shift"] && modifiers["alt"])
		AltShiftClickOn(A)
		return
	if(modifiers["middle"])
		MiddleClickOn(A)
		if(controlled_mech) //Are we piloting a mech? Placed here so the modifiers are not overridden.
			controlled_mech.click_action(A, src, params) //Override AI normal click behavior.
		return
	if(modifiers["shift"])
		ShiftClickOn(A)
		return
	if(modifiers["alt"]) // alt and alt-gr (rightalt)
		ai_base_click_alt(A)
		return
	if(modifiers["ctrl"])
		CtrlClickOn(A)
		return

	if(world.time <= next_move)
		return

	if(aiCamera.in_camera_mode)
		aiCamera.camera_mode_off()
		aiCamera.captureimage(A, usr)
		return

	if(waypoint_mode)
		set_waypoint(A)
		waypoint_mode = 0
		return

	A.add_hiddenprint(src)
	A.attack_ai(src)

/*
	AI has no need for the UnarmedAttack() and RangedAttack() procs,
	because the AI code is not generic;	attack_ai() is used instead.
	The below is only really for safety, or you can alter the way
	it functions and re-insert it above.
*/
/mob/living/silicon/ai/UnarmedAttack(atom/A)
	A.attack_ai(src)

/mob/living/silicon/ai/RangedAttack(atom/A, params)
	A.attack_ai(src)

/atom/proc/attack_ai(mob/user)
	return

/*
	Since the AI handles shift, ctrl, and alt-click differently
	than anything else in the game, atoms have separate procs
	for AI shift, ctrl, and alt clicking.
*/

/mob/living/silicon/ai/CtrlShiftClickOn(atom/A)
	A.AICtrlShiftClick(src)
/mob/living/silicon/ai/AltShiftClickOn(atom/A)
	A.AIAltShiftClick(src)
/mob/living/silicon/ai/ShiftClickOn(atom/A)
	A.AIShiftClick(src)
/mob/living/silicon/ai/CtrlClickOn(atom/A)
	A.AICtrlClick(src)
/mob/living/silicon/ai/MiddleClickOn(atom/A)
    A.AIMiddleClick(src)

// DEFAULT PROCS TO OVERRIDE

/atom/proc/AICtrlShiftClick(mob/user)  // Examines
	if(user.client)
		user.examinate(src)
	return

/atom/proc/AIAltShiftClick()
	return

/atom/proc/AIShiftClick(mob/living/user) // borgs use this too
	if(user.client)
		user.examinate(src)
	return

/atom/proc/AICtrlClick(mob/living/silicon/user)
	return

/// Reimplementation of base_click_alt for AI
/mob/living/silicon/ai/proc/ai_base_click_alt(atom/target)
	// If for some reason we can't alt click
	if(SEND_SIGNAL(src, COMSIG_MOB_ALTCLICKON, target) & COMSIG_MOB_CANCEL_CLICKON)
		return

	if(!isturf(target) && can_perform_action(target, (target.interaction_flags_click | SILENT_ADJACENCY)))
		// Signal intercept
		if(SEND_SIGNAL(target, COMSIG_CLICK_ALT, src) & CLICK_ACTION_ANY)
			return

		// AI alt click interaction succeeds
		if(target.ai_click_alt(src) & CLICK_ACTION_ANY)
			return

	client.loot_panel.open(get_turf(target))

/atom/proc/ai_click_alt(mob/living/silicon/ai/user)
	return


/atom/proc/AIMiddleClick(mob/living/user)
	return

/atom/proc/AIMiddleControlClick()
	return

/atom/proc/AIMiddleShiftControlClick()
	return

/atom/proc/AIMiddleAltClick()
	return

/atom/proc/AIMiddleAltShiftClick()
	return

/mob/living/silicon/ai/TurfAdjacent(turf/T)
	return (GLOB.cameranet && GLOB.cameranet.checkTurfVis(T) && (get_dist(eyeobj, T) <= 7)) //not further than view distance


// APC

/obj/machinery/power/apc/AICtrlClick(mob/living/user) // turns off/on APCs.
	if(!can_use(user))
		to_chat(user, span_warning("AI control for \the [src] interface has been disabled."))
		return
	toggle_breaker(user)

/obj/machinery/power/apc/AIShiftClick(mob/living/user) // Bolt all Airlocks in APC room.
	if(!can_use(user))
		to_chat(user, span_warning("AI control for \the [src] interface has been disabled."))
		return
	for(var/obj/machinery/door/airlock/A in area.machinery_cache)
		A.AICtrlClick(user)

// TURRETCONTROL

/obj/machinery/turretid/AICtrlClick(mob/living/silicon/user) //turns off/on Turrets
	enabled = !enabled
	updateTurrets()

/obj/machinery/turretid/ai_click_alt(mob/living/silicon/ai/user) //toggles lethal on turrets
	if(lethal_is_configurable)
		lethal = !lethal
		updateTurrets()
	return CLICK_ACTION_SUCCESS

// AIRLOCKS

/obj/machinery/door/airlock/AIAltShiftClick(mob/user)  // Sets/Unsets Emergency Access Override
	if(!ai_control_check(user))
		return
	toggle_emergency_status(user)

/obj/machinery/door/airlock/AIShiftClick(mob/user)  // Opens and closes doors!
	if(!ai_control_check(user))
		return
	open_close(user)

/obj/machinery/door/airlock/AICtrlClick(mob/living/silicon/user) // Bolts doors
	if(!ai_control_check(user))
		return
	toggle_bolt(user)

/obj/machinery/door/airlock/ai_click_alt(mob/living/silicon/ai/user) // Electrifies doors.
	if(!ai_control_check(user))
		return CLICK_ACTION_BLOCKING
	if(wires.is_cut(WIRE_ELECTRIFY))
		to_chat(user, span_warning("The electrification wire is cut - Cannot electrify the door."))
	if(isElectrified())
		electrify(0, user, TRUE) // un-shock
	else
		electrify(-1, user, TRUE) // permanent shock
	return CLICK_ACTION_SUCCESS


/obj/machinery/door/airlock/AIMiddleClick(mob/living/user) // Toggles door bolt lights.
	if(!ai_control_check(user))
		return
	toggle_light(user)

// AI-CONTROLLED SLIP GENERATOR IN AI CORE

/obj/machinery/ai_slipper/AICtrlClick(mob/living/silicon/ai/user) //Turns liquid dispenser on or off
	ToggleOn()

/obj/machinery/ai_slipper/ai_click_alt(mob/living/silicon/ai/user) //Dispenses liquid if on
	Activate()
	return CLICK_ACTION_SUCCESS

// AREAS

/mob/living/silicon/ai/proc/MiddleControlClickOn(atom/A)
	if(!ismalfAI(mind))
		return
	var/turf/turf = get_turf(A)
	if (!turf)
		return
	var/area/area = get_area(turf)
	if (!area)
		return
	for(var/obj/machinery/door/airlock/airlock in area.machinery_cache)
		airlock.AICtrlClick(src)

/mob/living/silicon/ai/MiddleShiftClickOn(atom/A)
	if(!ismalfAI(mind))
		return
	var/turf/turf = get_turf(A)
	if (!turf)
		return
	var/area/area = get_area(turf)
	if (!area)
		return
	for(var/obj/machinery/door/airlock/airlock in area.machinery_cache)
		airlock.AIShiftClick(src)

/mob/living/silicon/ai/proc/MiddleAltClickOn(atom/A)
	if(!ismalfAI(mind))
		return
	var/turf/turf = get_turf(A)
	if (!turf)
		return
	var/area/area = get_area(turf)
	if (!area)
		return
	for(var/obj/machinery/door/airlock/airlock in area.machinery_cache)
		airlock.ai_click_alt(src)

/mob/living/silicon/ai/proc/MiddleShiftAltClickOn(atom/A)
	if(!ismalfAI(mind))
		return
	var/turf/turf = get_turf(A)
	if (!turf)
		return
	var/area/area = get_area(turf)
	if (!area)
		return
	for(var/obj/machinery/door/airlock/airlock in area.machinery_cache)
		airlock.AIAltShiftClick(src)
