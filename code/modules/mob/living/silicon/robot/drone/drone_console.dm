/obj/machinery/computer/drone_control
	name = "maintenance drone control console"
	desc = "Используется для наблюдения за популяцией дронов на станции и сборщиком, который их обслуживает."
	icon_screen = "power"
	icon_keyboard = "power_key"
	req_access = list(ACCESS_ENGINE_EQUIP)
	circuit = /obj/item/circuitboard/drone_control

	//Used when pinging drones.
	var/drone_call_area = "Engineering"
	//Used to enable or disable drone fabrication.
	var/obj/machinery/drone_fabricator/dronefab
	var/request_cooldown = 30 SECONDS
	var/last_drone_request_time = 0

/obj/machinery/computer/drone_control/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)


/obj/machinery/computer/drone_control/attack_hand(var/mob/user as mob)
	if(..())
		return

	if(!allowed(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		playsound(src, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)
		return

	interact(user)

/obj/machinery/computer/drone_control/attack_ghost(mob/user as mob)
	interact(user)

/obj/machinery/computer/drone_control/interact(mob/user)

	user.set_machine(src)
	var/dat = ""
	dat += "<b>Maintenance Units</b><br>"

	for(var/mob/living/silicon/robot/drone/D in GLOB.silicon_mob_list)
		dat += "<br>[D.real_name] ([D.stat == 2 ? "<span style='color: red;'>INACTIVE" : "<span style='color: green;'>ACTIVE"]</span>)"
		dat += "<span style='font-size: 9;'><br>Cell charge: [D.cell.charge]/[D.cell.maxcharge]."
		dat += "<br>Currently located in: [get_area(D)]."
		dat += "<br><a href='byond://?src=[UID()];resync=\ref[D]'>Resync</a> | <a href='byond://?src=[UID()];shutdown=\ref[D]'>Shutdown</a></span>"

	dat += "<br><b><a href='byond://?src=[UID()];request_help=1'>Request a new drone</a></b>"

	dat += "<br><br><b>Request drone presence in area:</b> <a href='byond://?src=[UID()];setarea=1'>[drone_call_area]</a> (<a href='byond://?src=[UID()];ping=1'>Send ping</a>)"

	dat += "<br><br><b>Drone fabricator</b>: "
	dat += "[dronefab ? "<a href='byond://?src=[UID()];toggle_fab=1'>[(dronefab.produce_drones && !(dronefab.stat & NOPOWER)) ? "ACTIVE" : "INACTIVE"]</a>" : "<span style='color: red;'><b>FABRICATOR NOT DETECTED.</b></span> (<a href='byond://?src=[UID()];search_fab=1'>search</a>)"]"
	var/datum/browser/popup = new(user, "droncomputer", "Drone Computer", 400, 500)
	popup.set_content(dat)
	popup.open(TRUE)
	onclose(user, "droncomputer")
	return

/obj/machinery/computer/drone_control/proc/request_help()
	if((last_drone_request_time + request_cooldown) > world.time)
		return
	notify_ghosts(message = "A Maintenance Drone is requested to repair and serve.", ghost_sound = null,
		title="Drone Fabricator", source = dronefab, action = NOTIFY_ATTACK)
	last_drone_request_time = world.time

/obj/machinery/computer/drone_control/Topic(href, href_list)
	if(..())
		return

	if(!allowed(usr) && !usr.can_admin_interact())
		to_chat(usr, "<span class='warning'>Access denied.</span>")
		playsound(src, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)
		return

	if((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.set_machine(src)

	if(href_list["setarea"])

		//Probably should consider using another list, but this one will do.
		var/t_area = input("Select the area to ping.", "Set Target Area", null) as null|anything in GLOB.TAGGERLOCATIONS

		if(!t_area || GLOB.TAGGERLOCATIONS[t_area])
			return

		drone_call_area = t_area
		to_chat(usr, "<span class='notice'>You set the area selector to [drone_call_area].</span>")

	else if(href_list["request_help"])
		if(!dronefab || !dronefab.produce_drones)
			to_chat(usr, span_warning("You can't request a drone if there is no functional fabricator"))
		else
			if((last_drone_request_time + request_cooldown) > world.time)
				to_chat(usr, span_notice("You can't send a producing request too often."))
				return
			to_chat(usr, span_notice("You have sent a producing request to fabricator."))
			request_help()

	else if(href_list["ping"])

		to_chat(usr, "<span class='notice'>You issue a maintenance request for all active drones, highlighting [drone_call_area].</span>")
		for(var/mob/living/silicon/robot/drone/D in GLOB.silicon_mob_list)
			if(D.client && D.stat == 0)
				to_chat(D, "-- Maintenance drone presence requested in: [drone_call_area].")

	else if(href_list["resync"])

		var/mob/living/silicon/robot/drone/D = locate(href_list["resync"])

		if(D.stat != 2)
			to_chat(usr, "<span class='warning'>You issue a law synchronization directive for the drone.</span>")
			D.law_resync()

	else if(href_list["shutdown"])

		var/mob/living/silicon/robot/drone/D = locate(href_list["shutdown"])

		if(D.stat != 2)
			to_chat(usr, "<span class='warning'>You issue a kill command for the unfortunate drone.</span>")
			add_attack_logs(usr, src, "issued kill order from control console", ATKLOG_FEW)
			D.shut_down()

	else if(href_list["search_fab"])
		if(dronefab)
			return

		for(var/obj/machinery/drone_fabricator/fab in get_area(src))

			if(fab.stat & NOPOWER)
				continue

			dronefab = fab
			to_chat(usr, "<span class='notice'>Drone fabricator located.</span>")
			return

		to_chat(usr, "<span class='warning'>Unable to locate drone fabricator.</span>")

	else if(href_list["toggle_fab"])

		if(!dronefab)
			return

		if(get_dist(src,dronefab) > 3)
			dronefab = null
			to_chat(usr, "<span class='warning'>Unable to locate drone fabricator.</span>")
			return

		dronefab.produce_drones = !dronefab.produce_drones
		dronefab.update_icon(UPDATE_ICON_STATE)
		to_chat(usr, "<span class='notice'>You [dronefab.produce_drones ? "enable" : "disable"] drone production in the nearby fabricator.</span>")

	src.updateUsrDialog()
