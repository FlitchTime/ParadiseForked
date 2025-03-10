///proc/get_area(atom/A)
//	RETURN_TYPE(/area)
//	if(isarea(A))
//		return A
//	var/turf/T = get_turf(A)
//	return T ? T.loc : null

#define MANUAL_PICK_MESSAGE(X) "Выберите игроков для спавна. Это будет продолжаться до тех пор, пока не останется призраков для выбора или пока [X] оставшихся слотов не будут заполнены."
#define VETO_PICK_MESSAGE(X) "Выберите игроков. Это будет продолжаться до тех пор, пока не останется согласившихся призраков для выбора или пока [X] оставшихся слотов не будут заполнены."
#define MANUAL_PICK_TITLE "Активные игроки"
#define VETO_PICK_TITLE "Кандидаты"


/proc/get_area_name(atom/X, format_text = FALSE)
	var/area/A = isarea(X) ? X : get_area(X)
	if(!A)
		return null
	return format_text ? format_text(A.name) : A.name

/proc/get_location_name(atom/X, format_text = FALSE)
	var/area/A = isarea(X) ? X : get_area(X)
	if(!A)
		return null
	return format_text ? format_text(A.name) : A.name

/proc/get_areas_in_range(dist=0, atom/center=usr)
	if(!dist)
		var/turf/T = get_turf(center)
		return T ? list(T.loc) : list()
	if(!center)
		return list()

	var/list/turfs = RANGE_TURFS(dist, center)
	var/list/areas = list()
	for(var/V in turfs)
		var/turf/T = V
		areas |= T.loc
	return areas

/proc/get_open_turf_in_dir(atom/center, dir)
	var/turf/T = get_step(center, dir)
	if(T && !T.density)
		return T

/proc/get_adjacent_open_turfs(atom/center)
	var/list/hand_back = list()
	// Inlined get_open_turf_in_dir, just to be fast
	var/turf/new_turf = get_step(center, NORTH)
	if(new_turf && !new_turf.density)
		hand_back += new_turf
	new_turf = get_step(center, SOUTH)
	if(new_turf && !new_turf.density)
		hand_back += new_turf
	new_turf = get_step(center, EAST)
	if(new_turf && !new_turf.density)
		hand_back += new_turf
	new_turf = get_step(center, WEST)
	if(new_turf && !new_turf.density)
		hand_back += new_turf
	return hand_back

/proc/get_adjacent_open_areas(atom/center)
	. = list()
	var/list/adjacent_turfs = get_adjacent_open_turfs(center)
	for(var/I in adjacent_turfs)
		. |= get_area(I)

// Like view but bypasses luminosity check

/proc/hear(var/range, var/atom/source)
	var/lum = source.luminosity
	source.luminosity = 6

	var/list/heard = view(range, source)
	source.luminosity = lum

	return heard

/proc/circlerange(center=usr,radius=3)

	var/turf/centerturf = get_turf(center)
	var/list/turfs = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/atom/T in range(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			turfs += T

	//turfs += centerturf
	return turfs

/proc/circleview(center=usr,radius=3)

	var/turf/centerturf = get_turf(center)
	var/list/atoms = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/atom/A in view(radius, centerturf))
		var/dx = A.x - centerturf.x
		var/dy = A.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			atoms += A

	//turfs += centerturf
	return atoms

/proc/ff_cansee(atom/A, atom/B)
	var/AT = get_turf(A)
	var/BT = get_turf(B)
	if(AT == BT)
		return 1
	for(var/turf/T as anything in get_line(A, B))
		if(T == AT || T == BT)
			break
		if(T.density)
			return FALSE
	return TRUE


///Returns the distance between two atoms
/proc/get_dist_euclidean(atom/first_location, atom/second_location)
	var/dx = first_location.x - second_location.x
	var/dy = first_location.y - second_location.y

	var/dist = sqrt(dx ** 2 + dy ** 2)

	return dist


/proc/circlerangeturfs(center=usr,radius=3)

	var/turf/centerturf = get_turf(center)
	var/list/turfs = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/turf/T in range(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			turfs += T
	return turfs

/proc/circleviewturfs(center=usr,radius=3)		//Is there even a diffrence between this proc and circlerangeturfs()?

	var/turf/centerturf = get_turf(center)
	var/list/turfs = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/turf/T in view(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			turfs += T
	return turfs


/// Will recursively loop through an atom's contents and check for mobs, then it will loop through every atom in that atom's contents.
/// It will keep doing this until it checks every content possible. This will fix any problems with mobs, that are inside objects,
/// being unable to hear people due to being in a box within a bag.
/proc/recursive_mob_check(atom/check, list/output = list(), recursion_limit = 3, include_clientless = FALSE, include_radio = TRUE, sight_check = TRUE)
	if(!recursion_limit)
		return output

	for(var/thing in check.contents)
		var/is_mob = ismob(thing)
		if(is_mob)
			var/mob/mob = thing
			if(isnull(mob.client) && !include_clientless)
				output |= recursive_mob_check(mob, output, recursion_limit - 1, include_clientless, include_radio, sight_check)
				continue
			if(sight_check && !isInSight(mob, check))
				continue
			output |= mob

		else if(include_radio && isradio(thing))
			if(sight_check && !isInSight(thing, check))
				continue
			output |= thing

		if(is_mob || isobj(thing))
			output |= recursive_mob_check(thing, output, recursion_limit - 1, include_clientless, include_radio, sight_check)

	return output


/// The old system would loop through lists for a total of 5000 per function call, in an empty server.
/// This new system will loop at around 1000 in an empty server.
/// Returns a list of mobs in range from source. Used in radio and say code.
/proc/get_mobs_in_view(range, atom/source, include_clientless = FALSE, include_radio = TRUE)
	var/turf/source_turf = get_turf(source)
	. = list()

	if(!source_turf)
		return .

	for(var/thing in hear(range, source_turf))
		var/is_mob = ismob(thing)
		if(is_mob)
			var/mob/mob = thing
			if(include_clientless || !isnull(mob.client))
				. += mob
		else if(include_radio && isradio(thing))
			. += thing

		if(is_mob || isobj(thing))
			. |= recursive_mob_check(thing, ., 3, include_clientless, include_radio, FALSE)


/proc/get_mobs_in_radio_ranges(var/list/obj/item/radio/radios)
	. = list()
	// Returns a list of mobs who can hear any of the radios given in @radios
	var/list/speaker_coverage = list()
	for(var/obj/item/radio/R in radios)
		if(R)
			//Cyborg checks. Receiving message uses a bit of cyborg's charge.
			var/obj/item/radio/borg/BR = R
			if(istype(BR) && BR.myborg)
				var/mob/living/silicon/robot/borg = BR.myborg
				var/datum/robot_component/CO = borg.get_component("radio")
				if(!CO)
					continue //No radio component (Shouldn't happen)
				if(!borg.is_component_functioning("radio"))
					continue //No power.

			var/turf/speaker = get_turf(R)
			if(speaker)
				for(var/turf/T in hear(R.canhear_range,speaker))
					speaker_coverage[T] = T


	// Try to find all the players who can hear the message
	for(var/A in GLOB.player_list + GLOB.hear_radio_list)
		var/mob/M = A
		if(M)
			var/turf/ear = get_turf(M)
			if(ear)
				// Ghostship is magic: Ghosts can hear radio chatter from anywhere
				if(speaker_coverage[ear] || (istype(M, /mob/dead/observer) && M.get_preference(PREFTOGGLE_CHAT_GHOSTRADIO)))
					. |= M		// Since we're already looping through mobs, why bother using |= ? This only slows things down.
	return .

/proc/inLineOfSight(X1,Y1,X2,Y2,Z=1,PX1=16.5,PY1=16.5,PX2=16.5,PY2=16.5)
	var/turf/T
	if(X1==X2)
		if(Y1==Y2)
			return 1 //Light cannot be blocked on same tile
		else
			var/s = SIMPLE_SIGN(Y2-Y1)
			Y1+=s
			while(Y1!=Y2)
				T=locate(X1,Y1,Z)
				if(IS_OPAQUE_TURF(T))
					return FALSE
				Y1+=s
	else
		var/m=(32*(Y2-Y1)+(PY2-PY1))/(32*(X2-X1)+(PX2-PX1))
		var/b=(Y1+PY1/32-0.015625)-m*(X1+PX1/32-0.015625) //In tiles
		var/signX = SIMPLE_SIGN(X2-X1)
		var/signY = SIMPLE_SIGN(Y2-Y1)
		if(X1<X2)
			b+=m
		while(X1!=X2 || Y1!=Y2)
			if(round(m*X1+b-Y1))
				Y1+=signY //Line exits tile vertically
			else
				X1+=signX //Line exits tile horizontally
			T=locate(X1,Y1,Z)
			if(IS_OPAQUE_TURF(T))
				return FALSE
	return TRUE

/proc/isInSight(atom/A, atom/B)
	var/turf/Aturf = get_turf(A)
	var/turf/Bturf = get_turf(B)

	if(!Aturf || !Bturf)
		return FALSE

	return inLineOfSight(Aturf.x, Aturf.y, Bturf.x, Bturf.y, Aturf.z)

/proc/get_cardinal_step_away(atom/start, atom/finish) //returns the position of a step from start away from finish, in one of the cardinal directions
	//returns only NORTH, SOUTH, EAST, or WEST
	var/dx = finish.x - start.x
	var/dy = finish.y - start.y
	if(abs(dy) > abs (dx)) //slope is above 1:1 (move horizontally in a tie)
		if(dy > 0)
			return get_step(start, SOUTH)
		else
			return get_step(start, NORTH)
	else
		if(dx > 0)
			return get_step(start, WEST)
		else
			return get_step(start, EAST)

/proc/try_move_adjacent(atom/movable/AM)
	var/turf/T = get_turf(AM)
	for(var/direction in GLOB.cardinal)
		if(AM.Move(get_step(T, direction)))
			break

/proc/get_mob_by_key(var/key)
	for(var/mob/M in GLOB.mob_list)
		if(M.ckey == lowertext(key))
			return M
	return null

/proc/get_candidates(be_special_type, afk_bracket=3000, override_age=0, override_jobban=0)
	var/list/candidates = list()
	// Keep looping until we find a non-afk candidate within the time bracket (we limit the bracket to 10 minutes (6000))
	while(!candidates.len && afk_bracket < 6000)
		for(var/mob/dead/observer/G in GLOB.player_list)
			if(G.client != null)
				if(!(G.mind && G.mind.current && G.mind.current.stat != DEAD))
					if(!G.client.is_afk(afk_bracket) && (be_special_type in G.client.prefs.be_special))
						if(!override_jobban || (!jobban_isbanned(G, be_special_type) && !jobban_isbanned(G,"Syndicate")))
							if(override_age || player_old_enough_antag(G.client,be_special_type))
								candidates += G.client
		afk_bracket += 600 // Add a minute to the bracket, for every attempt

	return candidates

/proc/get_candidate_ghosts(be_special_type, afk_bracket=3000, override_age=0, override_jobban=0)
	var/list/candidates = list()
	// Keep looping until we find a non-afk candidate within the time bracket (we limit the bracket to 10 minutes (6000))
	while(!candidates.len && afk_bracket < 6000)
		for(var/mob/dead/observer/G in GLOB.player_list)
			if(G.client != null)
				if(!(G.mind && G.mind.current && G.mind.current.stat != DEAD))
					if(!G.client.is_afk(afk_bracket) && (be_special_type in G.client.prefs.be_special))
						if(!override_jobban || (!jobban_isbanned(G, be_special_type) && !jobban_isbanned(G,"Syndicate")))
							if(override_age || player_old_enough_antag(G.client,be_special_type))
								candidates += G
		afk_bracket += 600 // Add a minute to the bracket, for every attempt

	return candidates

/proc/ScreenText(obj/O, maptext="", screen_loc="CENTER-7,CENTER-7", maptext_height=480, maptext_width=480)
	if(!isobj(O))	O = new /atom/movable/screen/text()
	O.maptext = maptext
	O.maptext_height = maptext_height
	O.maptext_width = maptext_width
	O.screen_loc = screen_loc
	return O

/proc/Show2Group4Delay(obj/O, list/group, delay=0)
	if(!isobj(O))	return
	if(!group)	group = GLOB.clients
	for(var/client/C in group)
		C.screen += O
	if(delay)
		spawn(delay)
			for(var/client/C in group)
				C.screen -= O


/// Adds an image to a client's `.images`. Useful as a callback.
/proc/add_image_to_client(image/image_to_remove, client/add_to)
	add_to?.images += image_to_remove

/// Like add_image_to_client, but will add the image from a list of clients
/proc/add_image_to_clients(image/image_to_remove, list/show_to)
	for(var/client/add_to in show_to)
		add_to.images += image_to_remove

/// Removes an image from a client's `.images`. Useful as a callback.
/proc/remove_image_from_client(image/image_to_remove, client/remove_from)
	remove_from?.images -= image_to_remove

/// Like remove_image_from_client, but will remove the image from a list of clients
/proc/remove_image_from_clients(image/image_to_remove, list/hide_from)
	for(var/client/remove_from in hide_from)
		remove_from.images -= image_to_remove

///Add an image to a list of clients and calls a proc to remove it after a duration
/proc/flick_overlay(image/image_to_show, list/show_to, duration)
	if(!show_to || !length(show_to) || !image_to_show)
		return
	for(var/client/add_to in show_to)
		add_to.images += image_to_show
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(remove_image_from_clients), image_to_show, show_to), duration, TIMER_CLIENT_TIME)

/**
 * Helper atom that copies an appearance and exists for a period
*/
/atom/movable/flick_visual

/// Takes the passed in MA/icon_state, mirrors it onto ourselves, and displays that in world for duration seconds
/// Returns the displayed object, you can animate it and all, but you don't own it, we'll delete it after the duration
/atom/proc/flick_overlay_view(mutable_appearance/display, duration)
	if(!display)
		return null

	var/mutable_appearance/passed_appearance = \
		istext(display) \
			? mutable_appearance(icon, display, layer) \
			: display

	// If you don't give it a layer, we assume you want it to layer on top of this atom
	// Because this is vis_contents, we need to set the layer manually (you can just set it as you want on return if this is a problem)
	if(passed_appearance.layer == FLOAT_LAYER)
		passed_appearance.layer = layer + 0.1
	// This is faster then pooling. I promise
	var/atom/movable/flick_visual/visual = new()
	visual.appearance = passed_appearance
	// I hate /area
	var/atom/movable/lies_to_children = src
	lies_to_children.vis_contents += visual
	QDEL_IN_CLIENT_TIME(visual, duration)
	return visual

/area/flick_overlay_view(mutable_appearance/display, duration)
	return

/proc/get_active_player_count()
	// Get active players who are playing in the round
	var/active_players = 0
	for(var/i = 1; i <= GLOB.player_list.len; i++)
		var/mob/M = GLOB.player_list[i]
		if(M && M.client)
			if(isnewplayer(M)) // exclude people in the lobby
				continue
			else if(isobserver(M)) // Ghosts are fine if they were playing once (didn't start as observers)
				var/mob/dead/observer/O = M
				if(O.started_as_observer) // Exclude people who started as observers
					continue
			active_players++
	return active_players

/datum/projectile_data
	var/src_x
	var/src_y
	var/time
	var/distance
	var/power_x
	var/power_y
	var/dest_x
	var/dest_y

/datum/projectile_data/New(var/src_x, var/src_y, var/time, var/distance, \
						   var/power_x, var/power_y, var/dest_x, var/dest_y)
	src.src_x = src_x
	src.src_y = src_y
	src.time = time
	src.distance = distance
	src.power_x = power_x
	src.power_y = power_y
	src.dest_x = dest_x
	src.dest_y = dest_y

/proc/projectile_trajectory(var/src_x, var/src_y, var/rotation, var/angle, var/power)

	// returns the destination (Vx,y) that a projectile shot at [src_x], [src_y], with an angle of [angle],
	// rotated at [rotation] and with the power of [power]
	// Thanks to VistaPOWA for this function

	var/power_x = power * cos(angle)
	var/power_y = power * sin(angle)
	var/time = 2* power_y / 10 //10 = g

	var/distance = time * power_x

	var/dest_x = src_x + distance*sin(rotation);
	var/dest_y = src_y + distance*cos(rotation);

	return new /datum/projectile_data(src_x, src_y, time, distance, power_x, power_y, dest_x, dest_y)


/proc/mobs_in_area(var/area/the_area, var/client_needed=0, var/moblist=GLOB.mob_list)
	var/list/mobs_found[0]
	var/area/our_area = get_area(the_area)
	for(var/mob/M in moblist)
		if(client_needed && !M.client)
			continue
		if(our_area != get_area(M))
			continue
		mobs_found += M
	return mobs_found

/proc/alone_in_area(var/area/the_area, var/mob/must_be_alone, var/check_type = /mob/living/carbon)
	var/area/our_area = get_area(the_area)
	for(var/C in GLOB.alive_mob_list)
		if(!istype(C, check_type))
			continue
		if(C == must_be_alone)
			continue
		if(our_area == get_area(C))
			return 0
	return 1

/proc/lavaland_equipment_pressure_check(turf/T)
	. = FALSE
	if(!istype(T))
		return
	var/datum/gas_mixture/environment = T.return_air()
	if(!istype(environment))
		return
	var/pressure = environment.return_pressure()
	if(pressure <= LAVALAND_EQUIPMENT_EFFECT_PRESSURE)
		. = TRUE

/proc/pollCandidatesWithVeto(client/adminclient, max_slots, Question, be_special_type, antag_age_check = FALSE, poll_time = 300, ignore_respawnability = FALSE, min_hours = FALSE, flashwindow = TRUE, check_antaghud = TRUE, source, role_cleanname, reason)
	var/list/willing_ghosts = SSghost_spawns.poll_candidates(Question, be_special_type, antag_age_check, poll_time, ignore_respawnability, min_hours, flashwindow, check_antaghud, source, role_cleanname, reason)
	var/list/selected_ghosts = list()
	if(!willing_ghosts.len)
		return selected_ghosts

	var/list/candidate_ghosts = willing_ghosts.Copy()

	to_chat(adminclient, "Candidate Ghosts:");
	for(var/mob/dead/observer/G in candidate_ghosts)
		if(G.key && G.client)
			to_chat(adminclient, "- [G] ([G.key])");
		else
			candidate_ghosts -= G
	for(var/i = max_slots, (i > 0 && candidate_ghosts.len), i--)
		var/this_ghost = tgui_input_list(adminclient, VETO_PICK_MESSAGE(i), VETO_PICK_TITLE, candidate_ghosts)
		if(!this_ghost)
			continue
		candidate_ghosts -= this_ghost
		selected_ghosts += this_ghost
	return selected_ghosts


/proc/pick_candidates_manually(client/admin_client, teamsize)
	var/list/possible_ghosts = list()
	var/list/players_to_spawn = list()
	for(var/mob/dead/observer/G in GLOB.player_list)
		if(!G.client.is_afk())
			if(!(G.mind && G.mind.current && G.mind.current.stat != DEAD))
				possible_ghosts += G
	for(var/i=teamsize,(i>0&&possible_ghosts.len),i--) //Decrease with every member selected.
		var/candidate = tgui_input_list(admin_client, MANUAL_PICK_MESSAGE(i), MANUAL_PICK_TITLE, possible_ghosts) // auto-picks if only one candidate
		if(candidate == null)
			break;
		possible_ghosts -= candidate
		players_to_spawn += candidate
	return players_to_spawn

/proc/pick_candidates_all_types(client/admin_client, max_slot, question, be_special_type, antag_age_check = FALSE, poll_time = 300, ignore_respawnability = FALSE, min_hours = FALSE, flashwindow = TRUE, check_antaghud = TRUE, source, role_cleanname, reason)
	var/type = tgui_alert(admin_client,"Как вы хотите выбрать членов команды? \n \
	Случайно - призраки получат предложение занять роль. \
	После его окончания, среди них будет рандомно выбрано [max_slot] кандидатов \n \
	С вето - призраки получат предложение занять роль.\
	После его окончания, вам необходимо среди них выбрать [max_slot] кандидатов \n \
	Вручную - Вам необходимо выбрать [max_slot] кандидатов среди всех призраков. \
	(не рекомендуется, вы можете выбрать игрока на роль против его воли).",
	"Выберите способ.", list("Случайно", "С вето", "Вручную"))
	switch(type)
		if("Случайно")
			return SSghost_spawns.poll_candidates(question, be_special_type, antag_age_check, poll_time, ignore_respawnability, min_hours, flashwindow, check_antaghud, source, role_cleanname, reason)
		if("С вето")
			return pollCandidatesWithVeto(admin_client, max_slot, question, be_special_type, antag_age_check, poll_time, ignore_respawnability, min_hours, flashwindow, check_antaghud, source, role_cleanname, reason)
		if("Вручную")
			return pick_candidates_manually(admin_client, max_slot)
	return list()

/proc/window_flash(client/C)
	if(ismob(C))
		var/mob/M = C
		if(M.client)
			C = M.client
	if(!C || !(C.prefs.toggles2 & PREFTOGGLE_2_WINDOWFLASHING))
		return
	winset(C, "mainwindow", "flash=5")

/**
  * Returns a list of vents that can be used as a potential spawn if they meet the criteria set by the arguments
  *
  * Will not include parent-less vents to the returned list.
  * Arguments:
  * * unwelded_only - Whether the list should only include vents that are unwelded
  * * exclude_mobs_nearby - Whether to exclude vents that are near living mobs regardless of visibility
  * * nearby_mobs_range - The range at which to look for living mobs around the vent for the above argument
  * * exclude_visible_by_mobs - Whether to exclude vents that are visible to any living mob
  * * min_network_size - The minimum length (non-inclusive) of the vent's parent network. A smaller number means vents in small networks (Security, Virology) will appear in the list
  * * station_levels_only - Whether to only consider vents that are in a Z-level with a STATION_LEVEL trait
  * * z_level - The Z-level number to look for vents in. Defaults to all
  */
/proc/get_valid_vent_spawns(unwelded_only = TRUE, exclude_mobs_nearby = FALSE, nearby_mobs_range = world.view, exclude_visible_by_mobs = FALSE, min_network_size = 50, station_levels_only = TRUE, z_level = 0)
	ASSERT(min_network_size >= 0)
	ASSERT(z_level >= 0)

	var/num_z_levels = length(GLOB.space_manager.z_list)
	var/list/non_station_levels[num_z_levels] // Cache so we don't do is_station_level for every vent!

	. = list()
	for(var/object in GLOB.all_vent_pumps) // This only contains vent_pumps so don't bother with type checking
		var/obj/machinery/atmospherics/unary/vent_pump/vent = object
		var/vent_z = vent.z
		if(z_level && vent_z != z_level)
			continue
		if(station_levels_only && (non_station_levels[vent_z] || !is_station_level(vent_z)))
			non_station_levels[vent_z] = TRUE
			continue
		if(unwelded_only && vent.welded)
			continue
		if(exclude_mobs_nearby)
			var/turf/T = get_turf(vent)
			var/mobs_nearby = FALSE
			for(var/mob/living/M in orange(nearby_mobs_range, T))
				if(!M.is_dead())
					mobs_nearby = TRUE
					break
			if(mobs_nearby)
				continue
		if(exclude_visible_by_mobs)
			var/turf/T = get_turf(vent)
			var/visible_by_mobs = FALSE
			for(var/mob/living/M in viewers(world.view, T))
				if(!M.is_dead())
					visible_by_mobs = TRUE
					break
			if(visible_by_mobs)
				continue
		if(!vent.parent) // This seems to have been an issue in the past, so this is here until it's definitely fixed
			// Can cause heavy message spam in some situations (e.g. pipenets breaking)
			// log_debug("get_valid_vent_spawns(), vent has no parent: [vent], qdeled: [QDELETED(vent)], loc: [vent.loc]")
			continue
		if(length(vent.parent.other_atmosmch) <= min_network_size)
			continue
		. += vent

/**
 * Get a bounding box of a list of atoms.
 *
 * Arguments:
 * - atoms - List of atoms. Can accept output of view() and range() procs.
 *
 * Returns: list(x1, y1, x2, y2)
 */
/proc/get_bbox_of_atoms(list/atoms)
	var/list/list_x = list()
	var/list/list_y = list()
	for(var/_a in atoms)
		var/atom/a = _a
		list_x += a.x
		list_y += a.y
	return list(
		min(list_x),
		min(list_y),
		max(list_x),
		max(list_y))
