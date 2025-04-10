/obj/machinery/particle_accelerator/control_box
	name = "Particle Accelerator Control Console"
	desc = "This part controls the density of the particles."
	icon = 'icons/obj/engines_and_power/particle_accelerator.dmi'
	icon_state = "control_box"
	reference = "control_box"
	anchored = FALSE
	density = TRUE
	use_power = NO_POWER_USE
	idle_power_usage = 500
	active_power_usage = 10000
	construction_state = 0
	active = 0
	dir = 1
	var/strength_upper_limit = 2
	var/interface_control = 1
	var/list/obj/structure/particle_accelerator/connected_parts
	var/assembled = 0
	var/parts = null
	var/datum/wires/particle_acc/control_box/wires = null

/obj/machinery/particle_accelerator/control_box/Initialize(mapload)
	. = ..()
	wires = new(src)
	connected_parts = list()
	update_icon(UPDATE_ICON_STATE)
	use_log = list()

/obj/machinery/particle_accelerator/control_box/Destroy()
	SStgui.close_uis(wires)
	if(active)
		toggle_power()
	QDEL_NULL(wires)
	return ..()

/obj/machinery/particle_accelerator/control_box/attack_ghost(user as mob)
	return attack_hand(user)

/obj/machinery/particle_accelerator/control_box/attack_hand(mob/user as mob)
	if(..())
		return TRUE

	add_fingerprint(user)
	if(construction_state >= 3)
		interact(user)
	else if(construction_state == 2) // Wires exposed
		wires.Interact(user)

/obj/machinery/particle_accelerator/control_box/multitool_act(mob/living/user, obj/item/I)
	if(construction_state == 2) // Wires exposed
		wires.Interact(user)
		return TRUE

/obj/machinery/particle_accelerator/control_box/update_state()
	if(construction_state < 3)
		use_power = NO_POWER_USE
		assembled = 0
		active = 0
		for(var/obj/structure/particle_accelerator/part in connected_parts)
			part.strength = null
			part.powered = 0
			part.update_icon(UPDATE_ICON_STATE)
		connected_parts = list()
		return
	if(!part_scan())
		use_power = IDLE_POWER_USE
		active = 0
		connected_parts = list()


/obj/machinery/particle_accelerator/control_box/update_icon_state()
	if(active)
		icon_state = "[reference]p[strength]"
	else
		if(stat & NOPOWER)
			icon_state = "[reference]w"
			return
		else if(use_power && assembled)
			icon_state = "[reference]p"
		else
			switch(construction_state)
				if(0)
					icon_state = "[reference]"
				if(1)
					icon_state = "[reference]"
				if(2)
					icon_state = "[reference]w"
				else
					icon_state = "[reference]c"


/obj/machinery/particle_accelerator/control_box/Topic(href, href_list)
	if(..(href, href_list))
		return 1

	if(!interface_control)
		to_chat(usr, "<span class='error'>ERROR: Request timed out. Check wire contacts.</span>")
		return

	if(href_list["close"])
		close_window(usr, "pacontrol")
		usr.unset_machine()
		return
	if(href_list["togglep"])
		if(!wires.is_cut(WIRE_PARTICLE_POWER))
			toggle_power()

	else if(href_list["scan"])
		part_scan()

	else if(href_list["strengthup"])
		if(!wires.is_cut(WIRE_PARTICLE_STRENGTH))
			add_strength()

	else if(href_list["strengthdown"])
		if(!wires.is_cut(WIRE_PARTICLE_STRENGTH))
			remove_strength()

	updateDialog()
	update_icon(UPDATE_ICON_STATE)
	return


/obj/machinery/particle_accelerator/control_box/proc/strength_change()
	for(var/obj/structure/particle_accelerator/part in connected_parts)
		part.strength = strength
		part.update_icon(UPDATE_ICON_STATE)

/obj/machinery/particle_accelerator/control_box/proc/add_strength(var/s)
	if(assembled)
		strength++
		if(strength > strength_upper_limit)
			strength = strength_upper_limit
		else
			message_admins("PA Control Computer increased to [strength] by [key_name_admin(usr)] in [ADMIN_COORDJMP(src)]")
			add_game_logs("increased PA Control Computer to [strength] in [COORD(src)]", usr)
			investigate_log("increased to <span style='color: red;'>[strength]</span> by [key_name_log(usr)]", INVESTIGATE_ENGINE)
			use_log += text("\[[time_stamp()]\] <span style='color: red;'>[usr.name] ([key_name(usr)]) has increased the PA Control Computer to [strength].</span>")

			investigate_log("increased to <span style='color: red;'>[strength]</span> by [key_name_log(usr)]", INVESTIGATE_ENGINE)
		strength_change()

/obj/machinery/particle_accelerator/control_box/proc/remove_strength(var/s)
	if(assembled)
		strength--
		if(strength < 0)
			strength = 0
		else
			message_admins("PA Control Computer decreased to [strength] by [key_name_admin(usr)] in [ADMIN_COORDJMP(src)]")
			add_game_logs("decreased PA Control Computer to [strength] in [COORD(src)]", usr)
			investigate_log("decreased to <span style='color: green;'>[strength]</span> by [key_name_log(usr)]", INVESTIGATE_ENGINE)
			use_log += text("\[[time_stamp()]\] <span style='color: orange;'>[usr.name] ([key_name(usr)]) has decreased the PA Control Computer to [strength].</span>")

		strength_change()

/obj/machinery/particle_accelerator/control_box/power_change(forced = FALSE)
	..()
	if(stat & NOPOWER)
		active = 0
		use_power = NO_POWER_USE
	else if(!stat && construction_state <= 3)
		use_power = IDLE_POWER_USE
	update_icon(UPDATE_ICON_STATE)

	if((stat & NOPOWER) || (!stat && construction_state <= 3)) //Only update the part icons if something's changed (i.e. any of the above condition sets are met).
		for(var/obj/structure/particle_accelerator/part in connected_parts)
			part.strength = null
			part.powered = 0
			part.update_icon(UPDATE_ICON_STATE)


/obj/machinery/particle_accelerator/control_box/process()
	if(active)
		//a part is missing!
		if(length(connected_parts) < 6)
			investigate_log("lost a connected part; It <span style='color: red;>powered down</span>.", INVESTIGATE_ENGINE)
			toggle_power()
			return
		//emit some particles
		for(var/obj/structure/particle_accelerator/particle_emitter/PE in connected_parts)
			if(PE)
				PE.emit_particle(strength)


/obj/machinery/particle_accelerator/control_box/proc/part_scan()
	for(var/obj/structure/particle_accelerator/fuel_chamber/F in orange(1,src))
		dir = F.dir
	connected_parts = list()
	var/tally = 0
	var/ldir = turn(dir,-90)
	var/rdir = turn(dir,90)
	var/odir = turn(dir,180)
	var/turf/T = loc
	T = get_step(T,rdir)
	if(check_part(T,/obj/structure/particle_accelerator/fuel_chamber))
		tally++
	T = get_step(T,odir)
	if(check_part(T,/obj/structure/particle_accelerator/end_cap))
		tally++
	T = get_step(T,dir)
	T = get_step(T,dir)
	if(check_part(T,/obj/structure/particle_accelerator/power_box))
		tally++
	T = get_step(T,dir)
	if(check_part(T,/obj/structure/particle_accelerator/particle_emitter/center))
		tally++
	T = get_step(T,ldir)
	if(check_part(T,/obj/structure/particle_accelerator/particle_emitter/left))
		tally++
	T = get_step(T,rdir)
	T = get_step(T,rdir)
	if(check_part(T,/obj/structure/particle_accelerator/particle_emitter/right))
		tally++
	if(tally >= 6)
		assembled = 1
		return 1
	else
		assembled = 0
		return 0


/obj/machinery/particle_accelerator/control_box/proc/check_part(var/turf/T, var/type)
	if(!(T)||!(type))
		return 0
	var/obj/structure/particle_accelerator/PA = locate(/obj/structure/particle_accelerator) in T
	if(istype(PA, type))
		if(PA.connect_master(src))
			if(PA.report_ready(src))
				connected_parts.Add(PA)
				return 1
	return 0


/obj/machinery/particle_accelerator/control_box/proc/toggle_power()
	active = !active
	investigate_log("turned [active?"<span style='color: red;'>ON</span>":"<span style='color: green;'>OFF</span>"] by [usr ? key_name_log(usr) : "outside forces"]", INVESTIGATE_ENGINE)
	if(active)
		message_admins("PA Control Computer turned ON by [key_name_admin(usr)]", ATKLOG_FEW)
		add_game_logs("turned ON PA Control Computer in [COORD(src)]", usr)
		use_log += text("\[[time_stamp()]\] <span style='color: red;'>[key_name(usr)] has turned on the PA Control Computer.</pan>")
	if(active)
		use_power = ACTIVE_POWER_USE
		for(var/obj/structure/particle_accelerator/part in connected_parts)
			part.strength = strength
			part.powered = 1
			part.update_icon(UPDATE_ICON_STATE)
	else
		use_power = IDLE_POWER_USE
		for(var/obj/structure/particle_accelerator/part in connected_parts)
			part.strength = null
			part.powered = 0
			part.update_icon(UPDATE_ICON_STATE)
	return 1


/obj/machinery/particle_accelerator/control_box/interact(mob/user)
	if(((get_dist(src, user) > 1) && !isobserver(user)) || (stat & (BROKEN|NOPOWER)))
		if(!istype(user, /mob/living/silicon))
			user.unset_machine()
			close_window(user, "pacontrol")
			return
	user.set_machine(src)

	var/dat = ""
	dat += "<a href='byond://?src=[UID()];close=1'>Close</a><br><br>"
	dat += "<h3>Status</h3>"
	if(!assembled)
		dat += "Unable to detect all parts!<br>"
		dat += "<a href='byond://?src=[UID()];scan=1'>Run Scan</a><br><br>"
	else
		dat += "All parts in place.<br><br>"
		dat += "Power:"
		if(active)
			dat += "On<br>"
		else
			dat += "Off <br>"
		dat += "<a href='byond://?src=[UID()];togglep=1'>Toggle Power</a><br><br>"
		dat += "Particle Strength: [strength] "
		dat += "<a href='byond://?src=[UID()];strengthdown=1'>--</a>|<a href='byond://?src=[UID()];strengthup=1'>++</a><br><br>"

	//onclose(user, "pacontrol")
	var/datum/browser/popup = new(user, "pacontrol", name, 420, 500, src)
	popup.set_content(dat)
	popup.open()
	return
