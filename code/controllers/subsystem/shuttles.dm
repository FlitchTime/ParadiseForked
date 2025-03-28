#define CALL_SHUTTLE_REASON_LENGTH 12
#define MAX_TRANSIT_REQUEST_RETRIES 10

SUBSYSTEM_DEF(shuttle)
	name = "Shuttle"
	wait = 1 SECONDS
	init_order = INIT_ORDER_SHUTTLE
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_SETUP | RUNLEVEL_GAME
	offline_implications = "Shuttles will no longer function and cargo will not generate points. Immediate server restart recommended."
	cpu_display = SS_CPUDISPLAY_LOW
	ss_id = "shuttle"
	var/list/mobile = list()
	var/list/stationary = list()
	var/list/transit = list()

	/// A list of all the mobile docking ports currently requesting a spot in hyperspace.
	var/list/transit_requesters = list()
	/// An associative list of the mobile docking ports that have failed a transit request, with the amount of times they've actually failed that transit request, up to MAX_TRANSIT_REQUEST_RETRIES
	var/list/transit_request_failures = list()

		//emergency shuttle stuff
	var/obj/docking_port/mobile/emergency/emergency
	var/obj/docking_port/mobile/emergency/backup/backup_shuttle
	var/emergencyCallTime = SHUTTLE_CALLTIME	//time taken for emergency shuttle to reach the station when called (in deciseconds)
	var/emergencyDockTime = SHUTTLE_DOCKTIME	//time taken for emergency shuttle to leave again once it has docked (in deciseconds)
	var/emergencyEscapeTime = SHUTTLE_ESCAPETIME	//time taken for emergency shuttle to reach a safe distance after leaving station (in deciseconds)
	var/emergency_sec_level_time = 0 // time sec level was last raised to red or higher
	var/area/emergencyLastCallLoc
	var/emergencyNoEscape
	var/list/hostile_environment = list()

		//supply shuttle stuff
	var/obj/docking_port/mobile/supply/supply
	var/ordernum = 1					//order number given to next order
	var/points = 50						//number of trade-points we have
	var/points_per_decisecond = 0.0025	//points gained every decisecond
	var/points_per_slip = 2				//points gained per slip returned
	var/points_per_crate = 5			//points gained per crate returned
	var/points_per_intel = 250			//points gained per intel returned
	var/centcom_message = null			//Remarks from Centcom on how well you checked the last order.
	var/datum/money_account/cargo_money_account
	var/list/techLevels = list()
	var/list/shoppinglist = list()
	var/list/requestlist = list()
	var/list/supply_packs = list()
	var/datum/round_event/shuttle_loan/shuttle_loan
	var/sold_atoms = ""
	var/list/hidden_shuttle_turfs = list() //all turfs hidden from navigation computers associated with a list containing the image hiding them and the type of the turf they are pretending to be
	var/list/hidden_shuttle_turf_images = list() //only the images from the above list


/datum/controller/subsystem/shuttle/Initialize()
	ordernum = rand(1,9000)

	cargo_money_account = GLOB.department_accounts["Cargo"]

	if(!emergency)
		log_runtime(EXCEPTION("No /obj/docking_port/mobile/emergency placed on the map!"))
		if(!backup_shuttle)
			message_admins("There's no emergency docking ports on the map! The game will be unresolvable. To resolve this problem load emergency shuttle template manually, and call register() on the mobile docking port.")
			log_runtime(EXCEPTION("AND NO /obj/docking_port/mobile/emergency/backup placed on the map!"))
	if(!supply)
		log_runtime(EXCEPTION("No /obj/docking_port/mobile/supply placed on the map!"))

	initial_load()

	for(var/typepath in subtypesof(/datum/supply_packs))
		var/datum/supply_packs/P = new typepath()
		if(P.name == "HEADER") continue		// To filter out group headers
		supply_packs["[P.type]"] = P
	initial_move()

	centcom_message = "<center>---[station_time_timestamp()]---</center><br>Remember to stamp and send back the supply manifests.<hr>"
	return SS_INIT_SUCCESS


/datum/controller/subsystem/shuttle/get_stat_details()
	return "M:[length(mobile)] S:[length(stationary)] T:[length(transit)]"


/datum/controller/subsystem/shuttle/proc/initial_load()
	for(var/obj/docking_port/D in world)
		D.register()
		CHECK_TICK

/datum/controller/subsystem/shuttle/fire(resumed = FALSE)
	points += points_per_decisecond * wait
	for(var/thing in mobile)
		if(!thing)
			mobile.Remove(thing)
			continue
		var/obj/docking_port/mobile/P = thing
		P.check()
		CHECK_TICK
	for(var/obj/docking_port/stationary/transit/T in transit)
		if(!T.owner)
			qdel(T, force=TRUE)
			continue
		// This next one removes transit docks/zones that aren't
		// immediately being used. This will mean that the zone creation
		// code will be running a lot.
		var/obj/docking_port/mobile/owner = T.owner
		if(owner)
			var/idle = owner.mode == SHUTTLE_IDLE
			var/not_centcom_evac = owner != emergency
			var/not_in_use = (!T.get_docked())
			if(idle && not_centcom_evac && not_in_use)
				qdel(T, force=TRUE)

	if(!SSmapping.clearing_reserved_turfs)
		while(transit_requesters.len)
			var/requester = popleft(transit_requesters)
			var/success = generate_transit_dock(requester)
			if(!success) // BACK OF THE QUEUE
				transit_request_failures[requester]++
				if(transit_request_failures[requester] < MAX_TRANSIT_REQUEST_RETRIES)
					transit_requesters += requester
				else
					var/obj/docking_port/mobile/M = requester
					M.transit_failure()
			if(MC_TICK_CHECK)
				break

/datum/controller/subsystem/shuttle/proc/getShuttle(id)
	for(var/obj/docking_port/mobile/M in mobile)
		if(M.id == id)
			return M
	log_runtime(EXCEPTION("couldn't find shuttle with id: [id]"))

/datum/controller/subsystem/shuttle/proc/getDock(id)
	for(var/obj/docking_port/stationary/S in stationary)
		if(S.id == id)
			return S
	log_runtime(EXCEPTION("couldn't find dock with id: [id]"))

/datum/controller/subsystem/shuttle/proc/secondsToRefuel()
	var/elapsed = world.time - SSticker.round_start_time
	var/remaining = round((CONFIG_GET(number/shuttle_refuel_delay) - elapsed) / 10)
	return remaining > 0 ? remaining : 0

/datum/controller/subsystem/shuttle/proc/requestEvac(mob/user, call_reason)
	if(!emergency)
		log_runtime(EXCEPTION("requestEvac(): There is no emergency shuttle, but the shuttle was called. Using the backup shuttle instead."))
		message_admins("requestEvac(): There is no emergency shuttle, but the shuttle was called. Using the backup shuttle instead.")
		if(!backup_shuttle)
			message_admins("requestEvac(): There is no emergency shuttle, or backup shuttle! The game will be unresolvable. This is possibly a mapping error. To resolve this problem load emergency shuttle template manually, and call register() on the mobile docking port.")
			WARNING("requestEvac(): There is no emergency shuttle, or backup shuttle! \
			The game will be unresolvable.This is possibly a mapping error, \
			more likely a bug with the shuttle \
			manipulation system, or badminry. It is possible to manually \
			resolve this problem by loading an emergency shuttle template \
			manually, and then calling register() on the mobile docking port. \
			Good luck.")
			return
		emergency = backup_shuttle

	if(secondsToRefuel())
		to_chat(user, "The emergency shuttle is refueling. Please wait another [abs(round(((world.time - SSticker.round_start_time) - CONFIG_GET(number/shuttle_refuel_delay))/600))] minutes before trying again.")
		return

	switch(emergency.mode)
		if(SHUTTLE_RECALL)
			to_chat(user, "The emergency shuttle may not be called while returning to Centcom.")
			return
		if(SHUTTLE_CALL)
			to_chat(user, "The emergency shuttle is already on its way.")
			return
		if(SHUTTLE_DOCKED)
			to_chat(user, "The emergency shuttle is already here.")
			return
		if(SHUTTLE_IGNITING)
			to_chat(user, "The emergency shuttle is firing its engines to leave.")
			return
		if(SHUTTLE_ESCAPE)
			to_chat(user, "The emergency shuttle is moving away to a safe distance.")
			return
		if(SHUTTLE_STRANDED)
			to_chat(user, "The emergency shuttle has been disabled by Centcom.")
			return

	call_reason = trim(html_encode(call_reason))

	if(length(call_reason) < CALL_SHUTTLE_REASON_LENGTH)
		to_chat(user, "Reason is too short. [CALL_SHUTTLE_REASON_LENGTH] character minimum.")
		return

	var/area/signal_origin = get_area(user)
	var/emergency_reason = "\nNature of emergency:\n\n[call_reason]"
	if(seclevel2num(get_security_level()) >= SEC_LEVEL_RED) // There is a serious threat we gotta move no time to give them five minutes.
		var/extra_minutes = 0
		var/priority_time = emergencyCallTime * 0.5
		if(world.time - emergency_sec_level_time < priority_time)
			extra_minutes = 5
		emergency.request(null, 0.5 + extra_minutes / (emergencyCallTime / 600), signal_origin, html_decode(emergency_reason), 1)
	else
		emergency.request(null, 1, signal_origin, html_decode(emergency_reason), 0)

	add_game_logs("has called the shuttle.", user)
	message_admins("[key_name_admin(user)] has called the shuttle.")

// Called when an emergency shuttle mobile docking port is
// destroyed, which will only happen with admin intervention
/datum/controller/subsystem/shuttle/proc/emergencyDeregister()
	// When a new emergency shuttle is created, it will override the
	// backup shuttle.
	emergency = backup_shuttle

/datum/controller/subsystem/shuttle/proc/cancelEvac(mob/user)
	if(canRecall())
		emergency.cancel(get_area(user))
		add_game_logs("has recalled the shuttle.", user)
		message_admins("[key_name_admin(user)] has recalled the shuttle.")
		return 1

/datum/controller/subsystem/shuttle/proc/canRecall()
	if(emergency.mode != SHUTTLE_CALL)
		return
	if(!emergency.canRecall)
		return
	if(SSticker.mode.name == "meteor")
		return
	if(seclevel2num(get_security_level()) >= SEC_LEVEL_RED)
		if(emergency.timeLeft(1) < emergencyCallTime * 0.25)
			return
	else
		if(emergency.timeLeft(1) < emergencyCallTime * 0.5)
			return
	return 1

/datum/controller/subsystem/shuttle/proc/autoEvac()
	var/callShuttle = 1

	for(var/thing in GLOB.shuttle_caller_list)
		if(istype(thing, /mob/living/silicon/ai))
			var/mob/living/silicon/ai/AI = thing
			if(AI.stat || !AI.client)
				continue
		else if(istype(thing, /obj/machinery/computer/communications))
			var/obj/machinery/computer/communications/C = thing
			if(C.stat & BROKEN)
				continue
		else if(istype(thing, /obj/item/circuitboard/communications))
			continue

		var/turf/T = get_turf(thing)
		if(T && is_station_level(T.z))
			callShuttle = 0
			break

	if(callShuttle)
		if(emergency.mode == SHUTTLE_IDLE)
			emergency.request(null, 2.5)
			add_game_logs("There is no means of calling the shuttle anymore. Shuttle automatically called.")
			message_admins("All the communications consoles were destroyed and all AIs are inactive. Shuttle called.")

//try to move/request to dockHome if possible, otherwise dockAway. Mainly used for admin buttons
/datum/controller/subsystem/shuttle/proc/toggleShuttle(shuttleId, dockHome, dockAway, timed)
	var/obj/docking_port/mobile/M = getShuttle(shuttleId)
	if(!M)
		return 1
	var/obj/docking_port/stationary/dockedAt = M.get_docked()
	var/destination = dockHome
	if(dockedAt && dockedAt.id == dockHome)
		destination = dockAway
	if(timed)
		if(M.request(getDock(destination)))
			return 2
	else
		if(M.dock(getDock(destination)))
			return 2
	return 0	//dock successful


/datum/controller/subsystem/shuttle/proc/moveShuttle(shuttleId, dockId, timed, mob/user)
	var/obj/docking_port/mobile/M = getShuttle(shuttleId)
	var/obj/docking_port/stationary/D = getDock(dockId)

	if(M.mode == SHUTTLE_RECHARGING)
		return SHUTTLE_CONSOLE_RECHARGING

	if(!M)
		return 1
	M.last_caller = user // Save the caller of the shuttle for later logging
	if(timed)
		if(M.request(D))
			return 2
	else
		if(M.dock(D))
			return 2
	M.areaInstance << M.fly_sound
	return 0	//dock successful


/datum/controller/subsystem/shuttle/proc/request_transit_dock(obj/docking_port/mobile/M)
	if(!istype(M))
		throw EXCEPTION("[M] is not a mobile docking port")

	if(M.assigned_transit)
		return
	else
		if(!(M in transit_requesters))
			transit_requesters += M

/datum/controller/subsystem/shuttle/proc/generate_transit_dock(obj/docking_port/mobile/M)
	// First, determine the size of the needed zone
	// Because of shuttle rotation, the "width" of the shuttle is not
	// always x.
	var/travel_dir = M.preferred_direction
	// Remember, the direction is the direction we appear to be
	// coming from
	var/dock_angle = dir2angle(M.preferred_direction) + dir2angle(M.port_direction) + 180
	var/dock_dir = angle2dir(dock_angle)

	var/transit_width = SHUTTLE_TRANSIT_BORDER * 2
	var/transit_height = SHUTTLE_TRANSIT_BORDER * 2

	// Shuttles travelling on their side have their dimensions swapped
	// from our perspective
	switch(dock_dir)
		if(NORTH, SOUTH)
			transit_width += M.width
			transit_height += M.height
		if(EAST, WEST)
			transit_width += M.height
			transit_height += M.width


	var/transit_path = /turf/space/transit
	switch(travel_dir)
		if(NORTH)
			transit_path = /turf/space/transit/north
		if(SOUTH)
			transit_path = /turf/space/transit/south
		if(EAST)
			transit_path = /turf/space/transit/east
		if(WEST)
			transit_path = /turf/space/transit/west

	var/datum/turf_reservation/proposal = SSmapping.request_turf_block_reservation(
		transit_width,
		transit_height,
		1,
		reservation_type = /datum/turf_reservation/transit,
		turf_type_override = transit_path,
	)

	if(!istype(proposal))
		return FALSE

	var/turf/bottomleft = proposal.bottom_left_turfs[1]
	// Then create a transit docking port in the middle
	var/coords = M.return_coords(0, 0, dock_dir)
	/*  0------2
        |      |
        |      |
        |  x   |
        3------1
	*/

	var/x0 = coords[1]
	var/y0 = coords[2]
	var/x1 = coords[3]
	var/y1 = coords[4]
	// Then we want the point closest to -infinity,-infinity
	var/x2 = min(x0, x1)
	var/y2 = min(y0, y1)
	// Then invert the numbers
	var/transit_x = bottomleft.x + SHUTTLE_TRANSIT_BORDER + abs(x2)
	var/transit_y = bottomleft.y + SHUTTLE_TRANSIT_BORDER + abs(y2)

	var/turf/midpoint = locate(transit_x, transit_y, bottomleft.z)
	if(!midpoint)
		return FALSE
	var/area/old_area = midpoint.loc
	old_area.turfs_to_uncontain += proposal.reserved_turfs
	var/area/shuttle/transit/A = new()
	A.parallax_movedir = travel_dir
	A.contents = proposal.reserved_turfs
	A.contained_turfs = proposal.reserved_turfs
	var/obj/docking_port/stationary/transit/new_transit_dock = new(midpoint)
	new_transit_dock.reserved_area = proposal
	new_transit_dock.name = "Transit for [M.id]/[M.name]"
	new_transit_dock.owner = M
	new_transit_dock.assigned_area = A

	// Add 180, because ports point inwards, rather than outwards
	new_transit_dock.setDir(angle2dir(dock_angle))

	M.assigned_transit = new_transit_dock
	return new_transit_dock


/datum/controller/subsystem/shuttle/proc/initial_move()
	for(var/obj/docking_port/mobile/M in mobile)
		if(!M.roundstart_move)
			continue
		M.dockRoundstart()

/datum/controller/subsystem/shuttle/proc/generateSupplyOrder(packId, _orderedby, _orderedbyRank, _comment, _crates)
	if(!packId)
		return
	var/datum/supply_packs/P = locateUID(packId)
	if(!P)
		return

	var/datum/supply_order/O = new()
	O.ordernum = ordernum++
	O.object = P
	O.orderedby = _orderedby
	O.orderedbyRank = _orderedbyRank
	O.comment = _comment
	O.crates = _crates

	requestlist += O

	return O

/datum/controller/subsystem/shuttle/proc/get_dock_overlap(x0, y0, x1, y1, z)
	. = list()
	var/list/stationary_cache = stationary
	for(var/i in 1 to stationary_cache.len)
		var/obj/docking_port/port = stationary_cache[i]
		if(!port || port.z != z)
			continue
		var/list/bounds = port.return_coords()
		var/list/overlap = get_overlap(x0, y0, x1, y1, bounds[1], bounds[2], bounds[3], bounds[4])
		var/list/xs = overlap[1]
		var/list/ys = overlap[2]
		if(xs.len && ys.len)
			.[port] = overlap

/datum/controller/subsystem/shuttle/proc/update_hidden_docking_ports(list/remove_turfs, list/add_turfs)
	var/list/remove_images = list()
	var/list/add_images = list()

	if(remove_turfs)
		for(var/T in remove_turfs)
			var/list/L = hidden_shuttle_turfs[T]
			if(L)
				remove_images += L[1]
		hidden_shuttle_turfs -= remove_turfs

	if(add_turfs)
		for(var/V in add_turfs)
			var/turf/T = V
			var/image/I
			if(remove_images.len)
				//we can just reuse any images we are about to delete instead of making new ones
				I = remove_images[1]
				remove_images.Cut(1, 2)
				I.loc = T
			else
				I = image(loc = T)
				add_images += I
			I.appearance = T.appearance
			I.override = TRUE
			hidden_shuttle_turfs[T] = list(I, T.type)

	hidden_shuttle_turf_images -= remove_images
	hidden_shuttle_turf_images += add_images

	for(var/V in GLOB.navigation_computers)
		var/obj/machinery/computer/camera_advanced/shuttle_docker/C = V
		C.update_hidden_docking_ports(remove_images, add_images)

	QDEL_LIST(remove_images)


// Allow admins to fix shuttles ports list.
/client/proc/reregister_docks()
	set category = "Debug"
	set name = "Re-register Docking Ports"

	if(!check_rights(R_DEBUG|R_ADMIN))
		return

	SSshuttle.initial_load()

	log_and_message_admins(span_notice("[key_name(usr)] re-registered docking ports for SSshuttle."))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Re-register Docking Ports") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!


#undef CALL_SHUTTLE_REASON_LENGTH
#undef MAX_TRANSIT_REQUEST_RETRIES
