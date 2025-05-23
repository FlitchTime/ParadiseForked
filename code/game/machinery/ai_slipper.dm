/obj/machinery/ai_slipper
	name = "\improper AI liquid dispenser"
	icon = 'icons/obj/device.dmi'
	icon_state = "liquid_dispenser"
	layer = 3
	plane = FLOOR_PLANE
	anchored = TRUE
	max_integrity = 200
	armor = list(melee = 50, bullet = 20, laser = 20, energy = 20, bomb = 0, bio = 0, rad = 0, fire = 50, acid = 30)
	interaction_flags_click = ALLOW_SILICON_REACH
	var/uses = 20
	var/disabled = TRUE
	var/locked = TRUE
	var/cooldown_time = 10 SECONDS
	var/cooldown_on = FALSE
	req_access = list(ACCESS_AI_UPLOAD)


/obj/machinery/ai_slipper/examine(mob/user)
	. = ..()
	. += span_notice("A small counter shows it has: [uses] use\s remaining.")


/obj/machinery/ai_slipper/power_change()
	..() //we don't check return here because we also care about the BROKEN flag
	if(stat & NOPOWER)
		disabled = TRUE
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/ai_slipper/attackby(obj/item/I, mob/user, params)
	if(stat & (NOPOWER|BROKEN) || user.a_intent == INTENT_HARM)
		return ..()

	if(issilicon(user))
		attack_hand(user)
		return ATTACK_CHAIN_BLOCKED_ALL

	add_fingerprint(user)
	if(!allowed(user)) // trying to unlock the interface
		to_chat(user, span_warning("Access denied."))
		return ATTACK_CHAIN_PROCEED

	. = ATTACK_CHAIN_BLOCKED_ALL
	locked = !locked
	to_chat(user, span_notice("You [locked ? "lock" : "unlock"] the device."))
	if(locked)
		if(user.machine == src)
			user.unset_machine()
			close_window(user, "ai_slipper")
	else
		if(user.machine == src)
			attack_hand(user)


/obj/machinery/ai_slipper/proc/ToggleOn()
	if(stat & (NOPOWER|BROKEN))
		return
	disabled = !disabled
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/ai_slipper/proc/Activate(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return
	if(!uses)
		to_chat(user, span_warning("[src] is empty!"))
		return
	if(cooldown_on)
		to_chat(user, span_warning("[src] is still recharging!"))
		return

	var/datum/effect_system/fluid_spread/foam/s = new()
	s.set_up(range = 3, location = loc)
	s.start()

	uses--
	cooldown_on = TRUE
	update_icon(UPDATE_ICON_STATE)
	addtimer(CALLBACK(src, PROC_REF(recharge)), cooldown_time)


/obj/machinery/ai_slipper/proc/recharge()
	if(!uses)
		return
	cooldown_on = FALSE
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/ai_slipper/update_icon_state()
	if((stat & (NOPOWER|BROKEN)) || disabled || cooldown_on || !uses)
		icon_state = "liquid_dispenser"
	else
		icon_state = "liquid_dispenser_on"


/obj/machinery/ai_slipper/attack_ai(mob/user)
	return attack_hand(user)


/obj/machinery/ai_slipper/attack_ghost(mob/user)
	return attack_hand(user)


/obj/machinery/ai_slipper/attack_hand(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return

	if(get_dist(src, user) > 1 && (!issilicon(user) && !user.can_admin_interact()))
		to_chat(user, span_warning("Too far away."))
		user.unset_machine()
		var/datum/browser/popup = new(user, "ai_slipper")
		popup.set_content(null)
		popup.open(FALSE)
		return

	user.set_machine(src)
	var/area/myarea = get_area(src)
	var/t = "<tt><b>AI Liquid Dispenser</b> ([myarea.name])<hr>"

	if(locked && (!issilicon(user) && !user.can_admin_interact()))
		t += "<i>(Swipe ID card to unlock control panel.)</i><br></tt>"
	else
		add_fingerprint(user)
		t += "Dispenser [disabled ? "deactivated" : "activated"] - <a href='byond://?src=[UID()];toggleOn=1'>[disabled ? "Enable" : "Disable"]</a><br>\n"
		t += "Uses Left: [uses]. <a href='byond://?src=[UID()];toggleUse=1'>Activate the dispenser</a><br>\n</tt>"

	var/datum/browser/popup = new(user, "ai_slipper", "AI Liquid Dispenser", 575, 450)
	popup.set_content(t)
	popup.open(TRUE)
	onclose(user, "ai_slipper")


/obj/machinery/ai_slipper/Topic(href, href_list)
	if(..())
		return 1

	if(locked && (!issilicon(usr) && !usr.can_admin_interact()))
		to_chat(usr, "Control panel is locked!")
		return 1

	if(href_list["toggleOn"])
		ToggleOn()

	if(href_list["toggleUse"])
		Activate(usr)

	attack_hand(usr)

