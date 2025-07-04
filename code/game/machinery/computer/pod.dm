/obj/machinery/computer/pod
	name = "mass drivers and pod doors control"
	desc = "Элемент управления для запуска капсул. Некоторые предпочитают запускать из них мехов."
	icon_screen = "mass_driver"
	light_color = "#555555"
	circuit = /obj/item/circuitboard/pod
	var/initial_set = FALSE
	var/list/id_tags
	var/list/door_only_tags
	var/list/synced
	var/list/timings
	var/list/times
	var/list/maxtimes
	var/list/powers
	var/list/loopings
	var/static/list/deathsquad_teles


/obj/machinery/computer/pod/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(driver_sync)), 0.5 SECONDS)


/obj/machinery/computer/pod/proc/driver_sync()
	initial_set = TRUE
	door_only_tags = list()
	synced = list()
	timings = list()
	times = list()
	maxtimes = list()
	powers = list()
	loopings = list()
	deathsquad_teles = list()
	for(var/obj/machinery/mass_driver/driver in SSmachines.get_by_type(/obj/machinery/mass_driver))
		if(driver.z != src.z)
			continue

		for(var/ident_tag in id_tags)
			if((driver.id_tag == ident_tag) && !(ident_tag in synced))
				synced += ident_tag
				timings += ident_tag
				timings[ident_tag] = 0.0
				times += ident_tag
				times[ident_tag] = 30.0
				maxtimes += ident_tag
				maxtimes[ident_tag] = 30.0
				powers += ident_tag
				powers[ident_tag] = 1.0
				loopings += ident_tag
				loopings[ident_tag] = 0
				break

	for(var/obj/machinery/door/poddoor/poddoor in GLOB.airlocks)
		if(poddoor.z != src.z)
			continue
		for(var/ident_tag in id_tags)
			if((poddoor.id_tag == ident_tag) && !(ident_tag in synced) && !(ident_tag in door_only_tags))
				door_only_tags += ident_tag
				break


/obj/machinery/computer/pod/proc/solo_sync(ident_tag)
	for(var/obj/machinery/mass_driver/driver in SSmachines.get_by_type(/obj/machinery/mass_driver))
		if(driver.z != src.z)
			continue
		if((driver.id_tag == ident_tag) && !(ident_tag in synced))
			synced += ident_tag
			timings += ident_tag
			timings[ident_tag] = 0.0
			times += ident_tag
			times[ident_tag] = 30.0
			maxtimes += ident_tag
			maxtimes[ident_tag] = 30.0
			powers += ident_tag
			powers[ident_tag] = 1.0
			loopings += ident_tag
			loopings[ident_tag] = 0
			break

	if(!(ident_tag in synced))
		for(var/obj/machinery/door/poddoor/poddoor in GLOB.airlocks)
			if(poddoor.z != src.z)
				continue
			if((poddoor.id_tag == ident_tag) && !(ident_tag in synced) && !(ident_tag in door_only_tags))
				door_only_tags += ident_tag
				break


/obj/machinery/computer/pod/proc/launch_sequence(ident_tag)
	if(stat & (NOPOWER|BROKEN))
		return

	var/anydriver = FALSE
	for(var/obj/machinery/mass_driver/M in SSmachines.get_by_type(/obj/machinery/mass_driver))
		if(M.z != src.z)
			continue
		if(M.id_tag == ident_tag)
			anydriver = TRUE

	if(!anydriver)
		visible_message("Cannot locate any mass driver of that ID. Cancelling firing sequence!")
		return

	for(var/obj/machinery/door/poddoor/poddoor in GLOB.airlocks)
		if(poddoor.z != src.z)
			continue
		if(poddoor.id_tag == ident_tag)
			INVOKE_ASYNC(poddoor, TYPE_PROC_REF(/obj/machinery/door, open))

	sleep(2 SECONDS)
	for(var/obj/machinery/mass_driver/driver in SSmachines.get_by_type(/obj/machinery/mass_driver))
		if(driver.z != src.z)
			continue
		if(driver.id_tag == ident_tag)
			driver.drive()

	sleep(5 SECONDS)
	for(var/obj/machinery/door/poddoor/poddoor in GLOB.airlocks)
		if(poddoor.z != src.z)
			continue
		if(poddoor.id_tag == ident_tag)
			INVOKE_ASYNC(poddoor, TYPE_PROC_REF(/obj/machinery/door, close))


/obj/machinery/computer/pod/attack_ai(var/mob/user as mob)
	src.add_hiddenprint(user)
	return attack_hand(user)


/obj/machinery/computer/pod/attack_hand(var/mob/user as mob)
	if(..())
		return

	var/dat = {"<tt><b>[name]</b>(<a href='byond://?src=[UID()];rename=1'>rename</a>)"}
	user.set_machine(src)
	dat += "<br><a href = '?src=[UID()];sync=1'>Reset Connections</a><br>"
	if(synced.len)
		dat += "<br><a href = '?src=[UID()];massfire=1'><b>Fire All Connected Drivers</b></a><br>"
	if(istype(src,/obj/machinery/computer/pod/deathsquad))
		dat += "<br><a href = '?src=[UID()];dstele=1'><b>Set Teleporter Destination Z-Level</b></a><br>"
	for(var/ident_tag in id_tags)
		if(!(ident_tag in door_only_tags))
			dat += "<br><br><b>[ident_tag]</b> <a href='byond://?src=[UID()];remove=1;driver=[ident_tag]'>remove</a>"
		if(ident_tag in synced)
			var/d2 = ""
			if(timings[ident_tag])	//door controls do not need timers.
				d2 = "<a href='byond://?src=[UID()];time=0;driver=[ident_tag]'>Stop Time Launch</a>"
			else
				d2 = "<a href='byond://?src=[UID()];time=1;driver=[ident_tag]'>Initiate Time Launch</a>"
			var/second = times[ident_tag] % 60
			var/minute = (times[ident_tag] - second) / 60
			var/maxsecond = maxtimes[ident_tag] % 60
			var/maxminute = (maxtimes[ident_tag] - maxsecond) / 60
			dat += "<hr>\nTimer System: [d2]\nTime Left: [minute ? "[minute]:" : null][second]/[maxminute ? "[maxminute]:" : null][maxsecond] <a href='byond://?src=[UID()];tp=-30;driver=[ident_tag]'>-</a> <a href='byond://?src=[UID()];tp=-1;driver=[ident_tag]'>-</a> <a href='byond://?src=[UID()];tp=1;driver=[ident_tag]'>+</a> <a href='byond://?src=[UID()];tp=30;driver=[ident_tag]'>+</a>"
			dat += "<br>Set timer to loop: [loopings[ident_tag] ? "<a href = '?src=[UID()];loop=0;driver=[ident_tag]'>Yes</a>" : "<a href = '?src=[UID()];loop=1;driver=[ident_tag]'>No</a>"]"
			var/temp = ""
			var/list/L = list( 0.25, 0.5, 1, 2, 4, 8, 16 )
			for(var/t in L)
				if( powers[ident_tag] == t)
					temp += "<b><a href = '?src=[UID()];power=[t];driver=[ident_tag]'>[t]</a></b> "
				else
					temp += "<a href = '?src=[UID()];power=[t];driver=[ident_tag]'>[t]</a> "
			dat += "<hr>\nPower Level: [temp]<br>\n<a href = '?src=[UID()];launch=1;driver=[ident_tag]'><b>Fire Drive!</b></a><br>\n<a href = '?src=[UID()];door=1;driver=[ident_tag]'>Toggle Pod Doors</a><br>"

	for(var/ident_tag in door_only_tags)
		dat += "<br><br><b>[ident_tag]</b> <a href='byond://?src=[UID()];remove=1;driver=[ident_tag]'>remove</a>"
		dat += "<br>\n<a href = '?src=[UID()];door=1;driver=[ident_tag]'>Toggle Pod Doors</a><br>"

	dat += "<br><a href='byond://?src=[UID()];add=1'>add another id_tag</a>"

	dat += "<br><br><a href='byond://?src=[user.UID()];mach_close=computer'>Close</a></tt>"
	var/datum/browser/popup = new(user, "pod_computer", "Mass Driver", 400, 500)
	popup.set_content(dat)
	popup.open(TRUE)
	add_fingerprint(usr)
	onclose(user, "pod_computer")
	return

/obj/machinery/computer/pod/process()
	if(!..() || !initial_set)
		return
	for(var/ident_tag in id_tags)
		if(timings[ident_tag])
			if(times[ident_tag] > 0)
				times[ident_tag] = round(times[ident_tag]) - 1
			else
				INVOKE_ASYNC(src, PROC_REF(launch_sequence), ident_tag)
				if(loopings[ident_tag])
					times[ident_tag] = maxtimes[ident_tag]
				else
					times[ident_tag] = 0
					timings[ident_tag] = 0
		else
			times[ident_tag] = maxtimes[ident_tag]
		updateDialog()


/obj/machinery/computer/pod/Topic(href, href_list)
	if(..())
		return 1
	else
		usr.set_machine(src)
		if(href_list["add"])
			var/new_id_tag = tgui_input_text(usr, "Enter a new id_tag", "Mass Driver Controls", "id_tag")
			if(!(new_id_tag in id_tags))
				id_tags += new_id_tag
				solo_sync(new_id_tag)
		if(href_list["remove"])
			var/ident_tag = href_list["driver"]
			if(ident_tag in synced)
				synced -= ident_tag
			if(ident_tag in door_only_tags)
				door_only_tags -= ident_tag
			timings -= ident_tag
			times -= ident_tag
			powers -= ident_tag
			loopings -= ident_tag
			id_tags -= ident_tag
		if(href_list["dstele"])
			var/choices = list(0)
			var/list/reachable_levels = levels_by_trait(REACHABLE)
			for(var/z in reachable_levels)
				choices += z
			var/obj/machinery/computer/pod/deathsquad/D = src
			var/input = tgui_input_list(usr, "Enter the destination Z-Level. The mechs will arrive from the East. Leave 0 if you don't want to set a specific ZLevel", "Mass Driver Controls", choices, 0) 
			D.teleporter_dest = input

		if(href_list["massfire"])
			for(var/ident_tag in synced)
				INVOKE_ASYNC(src, PROC_REF(launch_sequence), ident_tag)
		if(href_list["power"])
			var/ident_tag = href_list["driver"]
			var/t = text2num(href_list["power"])
			t = min(max(0.25, t), 16)
			for(var/obj/machinery/mass_driver/M in SSmachines.get_by_type(/obj/machinery/mass_driver))
				if(M.id_tag == ident_tag)
					M.power = t
			powers[ident_tag] = t
		if(href_list["launch"])
			launch_sequence(href_list["driver"])
		if(href_list["time"])
			var/ident_tag = href_list["driver"]
			timings[ident_tag] = text2num(href_list["time"])
		if(href_list["loop"])
			var/ident_tag = href_list["driver"]
			loopings[ident_tag] = text2num(href_list["loop"])
		if(href_list["sync"])
			driver_sync()
		if(href_list["tp"])
			var/ident_tag = href_list["driver"]
			var/tp = text2num(href_list["tp"])
			maxtimes[ident_tag] += tp
			maxtimes[ident_tag] = min(max(round(maxtimes[ident_tag]), 0), 120)
		if(href_list["door"])
			var/ident_tag = href_list["driver"]
			for(var/obj/machinery/door/poddoor/poddoor in GLOB.airlocks)
				if(poddoor.z != src.z)
					continue
				if(poddoor.id_tag == ident_tag)
					if(poddoor.density)
						INVOKE_ASYNC(poddoor, TYPE_PROC_REF(/obj/machinery/door, open))
					else
						INVOKE_ASYNC(poddoor, TYPE_PROC_REF(/obj/machinery/door, close))
		if(href_list["rename"])
			var/new_title = tgui_input_text(usr, "Enter a new title", "[name]", "[name]")
			if(new_title)
				name = new_title
		updateUsrDialog()
	return



/obj/machinery/computer/pod/old
	icon_state = "oldcomp"
	icon_screen = "library"
	icon_keyboard = null
	name = "DoorMex Control Computer"
	circuit = /obj/item/circuitboard/olddoor


/obj/machinery/computer/pod/old/syndicate
	name = "external airlock controls"
	desc = "Синдикат работает в условиях ограниченного бюджета. Управляет внешними шлюзами."
	req_access = list(ACCESS_SYNDICATE)
	circuit = /obj/item/circuitboard/syndicatedoor
	light_color = "#00FFFF"

/obj/machinery/computer/pod/old/syndicate/attack_hand(var/mob/user as mob)
	if(!allowed(user))
		to_chat(user, span_warning("Access Denied"))
		playsound(src, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)
		return
	else
		..()

/obj/machinery/computer/pod/old/swf
	name = "\improper Magix System IV"
	desc = "Таинственный артефакт, в котором сконцентрировано огромное количество магической энергии."
	circuit = /obj/item/circuitboard/swfdoor


/obj/machinery/computer/pod/deathsquad
	id_tags = list("ASSAULT0","ASSAULT1","ASSAULT2","ASSAULT3")
	var/teleporter_dest = 0
	circuit = /obj/item/circuitboard/pod/deathsquad


/obj/machinery/computer/pod/deathsquad/launch_sequence(ident_tag)
	if(stat & (NOPOWER|BROKEN))
		return

	var/anydriver = FALSE
	for(var/obj/machinery/mass_driver/M in SSmachines.get_by_type(/obj/machinery/mass_driver))
		if(M.z != src.z)
			continue
		if(M.id_tag == ident_tag)
			anydriver = TRUE

	if(!anydriver)
		visible_message("Cannot locate any mass driver of that ID. Cancelling firing sequence!")
		return

	var/list/spawn_marauder = list()
	for(var/obj/effect/landmark/landmark as anything in GLOB.landmarks_list)
		if(landmark.name == "Marauder Entry")
			spawn_marauder.Add(landmark)

	for(var/obj/effect/landmark/landmark as anything in GLOB.landmarks_list)
		if(landmark.name == "Marauder Exit")
			var/obj/effect/landmark/target_landmark = pick_n_take(spawn_marauder)
			var/obj/effect/portal/portal = new(landmark.loc, target_landmark.loc)
			portal.invisibility = INVISIBILITY_ABSTRACT	//So it is not seen by anyone.
			portal.failchance = 0	//So it has no fail chance when teleporting.
			portal.can_mecha_pass = TRUE

	for(var/obj/machinery/door/poddoor/poddoor in GLOB.airlocks)
		if(poddoor.z != src.z)
			continue
		if(poddoor.id_tag == ident_tag)
			INVOKE_ASYNC(poddoor, TYPE_PROC_REF(/obj/machinery/door, open))

	sleep(2 SECONDS)
	for(var/obj/machinery/mass_driver/driver in SSmachines.get_by_type(/obj/machinery/mass_driver))
		if(driver.z != src.z)
			continue
		if(driver.id_tag == ident_tag)
			driver.drive()

	sleep(5 SECONDS)
	for(var/obj/machinery/door/poddoor/poddoor in GLOB.airlocks)
		if(poddoor.z != src.z)
			continue
		if(poddoor.id_tag == ident_tag)
			INVOKE_ASYNC(poddoor, TYPE_PROC_REF(/obj/machinery/door, close))

	for(var/obj/structure/deathsquad_tele/tele in GLOB.deathsquad_teles)
		if(tele.z != src.z)
			continue
		if(tele.id_tag == ident_tag)
			tele.working = TRUE
			tele.update_icon(UPDATE_ICON_STATE)


GLOBAL_LIST_EMPTY(deathsquad_teles)

/obj/structure/deathsquad_tele
	name = "Mech Teleporter"
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "tele0"
	var/ztarget = 0
	var/id_tag = ""
	var/working = FALSE


/obj/structure/deathsquad_tele/Initialize(mapload)
	. = ..()
	GLOB.deathsquad_teles += src


/obj/structure/deathsquad_tele/Destroy()
	GLOB.deathsquad_teles -= src
	return ..()


/obj/structure/deathsquad_tele/update_icon_state()
	icon_state = "tele[working]"


/obj/structure/deathsquad_tele/Bumped(atom/movable/moving_atom)
	. = ..()
	if(!ztarget || !working)
		return .
	INVOKE_ASYNC(src, PROC_REF(async_bump_effect), moving_atom)


/obj/structure/deathsquad_tele/proc/async_bump_effect(atom/movable/moving_atom)
	if(QDELETED(moving_atom))
		return

	moving_atom.z = ztarget
	moving_atom.y = moving_atom.y
	moving_atom.x = world.maxx - TRANSITIONEDGE - 2
	moving_atom.dir = 8
	var/atom/target = get_edge_target_turf(moving_atom, moving_atom.dir)
	moving_atom.throw_at(target, 50, 1)

