/obj/machinery/computer/robotics
	name = "robotics control console"
	desc = "Используется для дистанционной блокировки или подрыва привязанных киборгов."
	icon = 'icons/obj/machines/computer.dmi'
	icon_keyboard = "tech_key"
	icon_screen = "robot"
	req_access = list(ACCESS_ROBOTICS)
	circuit = /obj/item/circuitboard/robotics
	var/temp = null

	light_color = LIGHT_COLOR_PURPLE

	var/safety = 1

/obj/machinery/computer/robotics/attack_ai(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/robotics/attack_hand(var/mob/user as mob)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return
	ui_interact(user)

/obj/machinery/computer/robotics/proc/is_authenticated(mob/user)
	if(!istype(user))
		return FALSE
	if(user.can_admin_interact())
		return TRUE
	if(allowed(user))
		return TRUE
	return FALSE

/**
  * Does this borg show up in the console
  *
  * Returns TRUE if a robot will show up in the console
  * Returns FALSE if a robot will not show up in the console
  * Arguments:
  * * R - The [mob/living/silicon/robot] to be checked
  */
/obj/machinery/computer/robotics/proc/console_shows(mob/living/silicon/robot/R)
	if(!istype(R))
		return FALSE
	if(isdrone(R))
		return FALSE
	if(iscogscarab(R))
		return FALSE
	if(iscogscarab(R))
		return FALSE
	if(R.scrambledcodes)
		return FALSE
	if(!are_zs_connected(src, R))
		return FALSE
	return TRUE

/**
  * Check if a user can send a lockdown/detonate command to a specific borg
  *
  * Returns TRUE if a user can send the command (does not guarantee it will work)
  * Returns FALSE if a user cannot
  * Arguments:
  * * user - The [mob/user] to be checked
  * * R - The [mob/living/silicon/robot] to be checked
  * * telluserwhy - Bool of whether the user should be sent a to_chat message if they don't have access
  */
/obj/machinery/computer/robotics/proc/can_control(mob/user, mob/living/silicon/robot/R, telluserwhy = FALSE)
	if(!istype(user))
		return FALSE
	if(!console_shows(R))
		return FALSE
	if(isAI(user))
		if(R.connected_ai != user)
			if(telluserwhy)
				to_chat(user, span_warning("AIs can only control cyborgs which are linked to them."))
			return FALSE
	if(isrobot(user))
		if(R != user)
			if(telluserwhy)
				to_chat(user, span_warning("Cyborgs cannot control other cyborgs."))
			return FALSE
	return TRUE

/obj/machinery/computer/robotics/proc/can_detonate_any(mob/user, telluserwhy = FALSE)
	if(ispulsedemon(user))
		if(telluserwhy)
			to_chat(user, "<span class='warning'>The console's authentication circuits reject your control!</span>")
		return FALSE
	return TRUE

/// Checks if a user can detonate a specific cyborg, does a can_control check first.
/obj/machinery/computer/robotics/proc/can_detonate(mob/user, mob/living/silicon/robot/R, telluserwhy = FALSE)
	if(!can_control(user, R, telluserwhy))
		return FALSE
	if(!can_detonate_any(user, telluserwhy))
		return FALSE
	return TRUE



/**
  * Check if the user is the right kind of entity to be able to hack borgs
  *
  * Returns TRUE if a user is a traitor AI, or aghost
  * Returns FALSE otherwise
  * Arguments:
  * * user - The [mob/user] to be checked
  */
/obj/machinery/computer/robotics/proc/can_hack_any(mob/user)
	if(!istype(user))
		return FALSE
	if(user.can_admin_interact())
		return TRUE
	if(!isAI(user))
		return FALSE
	return (user.mind.special_role && user.mind.is_original_mob(user))


/**
  * Check if the user is allowed to hack a specific borg
  *
  * Returns TRUE if a user can hack the specific cyborg
  * Returns FALSE if a user cannot
  * Arguments:
  * * user - The [mob/user] to be checked
  * * R - The [mob/living/silicon/robot] to be checked
  */
/obj/machinery/computer/robotics/proc/can_hack(mob/user, mob/living/silicon/robot/R)
	if(!can_hack_any(user))
		return FALSE
	if(!istype(R))
		return FALSE
	if(R.emagged)
		return FALSE
	if(R.connected_ai != user)
		return FALSE
	return TRUE


/obj/machinery/computer/robotics/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RoboticsControlConsole", name)
		ui.open()

/obj/machinery/computer/robotics/ui_data(mob/user)
	var/list/data = list()
	data["auth"] = is_authenticated(user)
	data["can_hack"] = can_hack_any(user)
	data["cyborgs"] = list()
	data["safety"] = safety
	for(var/mob/living/silicon/robot/R in GLOB.mob_list)
		if(!console_shows(R))
			continue
		var/area/A = get_area(R)
		var/turf/T = get_turf(R)
		var/list/cyborg_data = list(
			name = R.name,
			uid = R.UID(),
			locked_down = R.lockcharge,
			locstring = "[A.name] ([T.x], [T.y])",
			status = R.stat,
			health = round(R.health * 100 / R.maxHealth, 0.1),
			charge = R.cell ? round(R.cell.percent()) : null,
			cell_capacity = R.cell ? R.cell.maxcharge : null,
			module = R.module ? R.module.name : "No Module Detected",
			synchronization = R.connected_ai,
			is_hacked =  R.connected_ai && R.emagged,
			hackable = can_hack(user, R),
		)
		data["cyborgs"] += list(cyborg_data)
	data["show_detonate_all"] = (data["auth"] && length(data["cyborgs"]) > 0 && ishuman(user))
	return data

/obj/machinery/computer/robotics/ui_act(action, params)
	if(..())
		return
	. = FALSE
	if(!is_authenticated(usr) || (GLOB.disable_robotics_consoles && iscarbon(usr)))
		to_chat(usr, span_warning("Access denied."))
		playsound(src, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)
		return
	switch(action)
		if("arm") // Arms the emergency self-destruct system
			if(issilicon(usr))
				to_chat(usr, span_danger("Access Denied (silicon detected)"))
				playsound(src, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)
				return
			safety = !safety
			to_chat(usr, span_notice("You [safety ? "disarm" : "arm"] the emergency self destruct."))
			. = TRUE
		if("nuke") // Destroys all accessible cyborgs if safety is disabled
			if(issilicon(usr))
				to_chat(usr, span_danger("Access Denied (silicon detected)"))
				playsound(src, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)
				return
			if(!can_detonate_any(usr, TRUE))
				return
			if(safety)
				to_chat(usr, span_danger("Self-destruct aborted - safety active"))
				return
			message_admins(span_notice("[ADMIN_LOOKUPFLW(usr)] detonated all cyborgs!"))
			add_game_logs("detonated all cyborgs!", usr)
			for(var/mob/living/silicon/robot/R in GLOB.mob_list)
				if(isdrone(R))
					continue
				// Ignore antagonistic cyborgs
				if(R.scrambledcodes)
					continue
				to_chat(R, span_danger("Self-destruct command received."))
				if(R.connected_ai)
					to_chat(R.connected_ai, "<br><br><span class='alert'>ALERT - Cyborg detonation detected: [R.name]</span><br>")
				R.self_destruct()
			. = TRUE
		if("killbot") // destroys one specific cyborg
			var/mob/living/silicon/robot/R = locateUID(params["uid"])
			if(!can_detonate(usr, R, TRUE))
				return
			if(R.mind && R.mind.special_role && R.emagged)
				to_chat(R, span_userdanger("Extreme danger!  Termination codes detected.  Scrambling security codes and automatic AI unlink triggered."))
				R.ResetSecurityCodes()
				. = TRUE
				return
			var/turf/T = get_turf(R)
			message_admins(span_notice("[ADMIN_LOOKUPFLW(usr)] detonated [key_name_admin(R)] ([ADMIN_COORDJMP(T)])!"))
			add_game_logs("detonated [key_name_log(R)]!", usr)
			to_chat(R, span_danger("Self-destruct command received."))
			if(R.connected_ai)
				to_chat(R.connected_ai, "<br><br><span class='alert'>ALERT - Cyborg detonation detected: [R.name]</span><br>")
			R.self_destruct()
			. = TRUE
		if("stopbot") // lock or unlock the borg
			if(isrobot(usr))
				to_chat(usr, span_danger("Access Denied."))
				playsound(src, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)
				return
			var/mob/living/silicon/robot/R = locateUID(params["uid"])
			if(!can_control(usr, R, TRUE))
				return
			message_admins(span_notice("[ADMIN_LOOKUPFLW(usr)] [!R.lockcharge ? "locked down" : "released"] [ADMIN_LOOKUPFLW(R)]!"))
			add_game_logs("[!R.lockcharge ? "locked down" : "released"] [key_name_log(R)]!", usr)
			R.SetLockdown(!R.lockcharge)
			to_chat(R, "[!R.lockcharge ? span_notice("Your lockdown has been lifted!") : span_alert("You have been locked down!")]")
			if(R.connected_ai)
				to_chat(R.connected_ai, "[!R.lockcharge ? span_notice("NOTICE - Cyborg lockdown lifted") : span_alert("ALERT - Cyborg lockdown detected")]: <a href='byond://?src=[R.connected_ai.UID()];track=[html_encode(R.name)]'>[R.name]</a></span><br>")
			. = TRUE
		if("hackbot") // AIs hacking/emagging a borg
			var/mob/living/silicon/robot/R = locateUID(params["uid"])
			if(!can_hack(usr, R))
				return
			var/choice = input("Really hack [R.name]? This cannot be undone.") in list("Yes", "No")
			if(choice != "Yes")
				return
			add_game_logs("emagged [key_name_log(R)] using robotic console!", usr)
			message_admins(span_notice("[ADMIN_LOOKUPFLW(usr)] emagged [key_name_admin(R)] using robotic console!"))
			R.emagged = TRUE
			to_chat(R, span_notice("Failsafe protocols overriden. New tools available."))
			. = TRUE
