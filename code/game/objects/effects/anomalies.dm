//Anomalies, used for events. Note that these DO NOT work by themselves; their procs are called by the event datum.

/// Chance of taking a step per second
#define ANOMALY_MOVECHANCE 70

/obj/effect/anomaly
	name = "anomaly"
	desc = "A mysterious anomaly, seen commonly only in the region of space that the station orbits..."
	icon_state = "bhole3"
	density = FALSE
	anchored = TRUE
	light_range = 3
	var/movechance = ANOMALY_MOVECHANCE
	var/obj/item/assembly/signaler/anomaly/aSignal = /obj/item/assembly/signaler/anomaly
	var/area/impact_area
	/// Time in deciseconds before the anomaly triggers
	var/lifespan = 990
	var/death_time

	var/countdown_colour
	var/obj/effect/countdown/anomaly/countdown

	/// Do we drop a core when we're neutralized?
	var/drops_core = TRUE

/obj/effect/anomaly/Initialize(mapload, new_lifespan, _drops_core = TRUE)
	. = ..()
	GLOB.poi_list |= src
	START_PROCESSING(SSobj, src)
	impact_area = get_area(src)

	if(!impact_area || impact_area.outdoors)
		return INITIALIZE_HINT_QDEL

	drops_core = _drops_core

	aSignal = new aSignal(src)
	aSignal.code = rand(1, 100)
	aSignal.anomaly_type = type

	var/frequency = rand(PUBLIC_LOW_FREQ, PUBLIC_HIGH_FREQ)
	if(ISMULTIPLE(frequency, 2))//signaller frequencies are always uneven!
		frequency++
	aSignal.set_frequency(frequency)

	if(new_lifespan)
		lifespan = new_lifespan
	death_time = world.time + lifespan
	countdown = new(src)
	if(countdown_colour)
		countdown.color = countdown_colour
	countdown.start()

/obj/effect/anomaly/Destroy()
	GLOB.poi_list.Remove(src)
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(countdown)
	if(!ispath(aSignal))
		QDEL_NULL(aSignal)
	return ..()

/obj/effect/anomaly/process()
	for(var/obj/item/I in get_turf(src))
		if(!I.origin_tech)
			continue
		if (istype(I, /obj/item/relict_production/rapid_dupe))
			var/amount = rand(1, 3)
			for (var/i; i <= amount; i++)
				new /obj/item/relic(get_turf(I))
				var/datum/effect_system/fluid_spread/smoke/smoke = new
				smoke.set_up(amount = 5, location = get_turf(I))
				smoke.start()
			qdel(I)
			continue
		if (prob(2))
			new /obj/item/relic(get_turf(I))
			qdel(I)

	anomalyEffect()
	if(death_time < world.time)
		if(loc)
			detonate()
		qdel(src)

/obj/effect/anomaly/proc/anomalyEffect()
	if(prob(movechance))
		step(src, pick(GLOB.alldirs))

/obj/effect/anomaly/proc/detonate()
	return

/obj/effect/anomaly/ex_act(severity)
	if(severity == EXPLODE_DEVASTATE)
		qdel(src)

/obj/effect/anomaly/proc/anomalyNeutralize()
	new /obj/effect/particle_effect/fluid/smoke/bad(loc)

	if(drops_core)
		aSignal.forceMove(drop_location())
		aSignal = null
	// else, anomaly core gets deleted by qdel(src).

	qdel(src)


/obj/effect/anomaly/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/analyzer))
		to_chat(user, span_notice("Analyzing... [src]'s unstable field is fluctuating along frequency [format_frequency(aSignal.frequency)], code [aSignal.code]."))
	return ATTACK_CHAIN_PROCEED_SUCCESS


///////////////////////

/obj/effect/anomaly/grav
	name = "gravitational anomaly"
	icon_state = "shield2"
	density = FALSE
	appearance_flags = PIXEL_SCALE|LONG_GLIDE
	var/boing = FALSE
	var/knockdown = FALSE
	aSignal = /obj/item/assembly/signaler/anomaly/grav
	var/obj/effect/warp_effect/supermatter/warp


/obj/effect/anomaly/grav/Initialize(mapload, new_lifespan, _drops_core)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	apply_wibbly_filters(src)

	warp = new(src)
	vis_contents += warp
	apply_wibbly_filters(warp)

/obj/effect/anomaly/grav/Destroy()
	vis_contents -= warp
	QDEL_NULL(warp)  // don't want to leave it hanging
	return ..()

/obj/effect/anomaly/grav/anomalyEffect()
	..()
	boing = TRUE
	for(var/obj/O in orange(4, src))
		if(!O.anchored)
			step_towards(O,src)
	for(var/mob/living/M in range(0, src))
		gravShock(M)
	for(var/mob/living/M in orange(4, src))
		if(!M.mob_negates_gravity())
			step_towards(M,src)
	for(var/obj/O in range(0, src))
		if(!O.anchored && O.loc != src && O.move_resist < MOVE_FORCE_OVERPOWERING) // so it cannot throw the anomaly core or super big things)
			var/mob/living/target = locate() in view(4, src)
			if(target && !target.stat)
				O.throw_at(target, 5, 10)

	//anomaly quickly contracts then slowly expands it's ring
	animate(warp, time = 6, transform = matrix().Scale(0.5, 0.5))
	animate(time = 14, transform = matrix())

/obj/effect/anomaly/grav/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	gravShock(arrived)


/obj/effect/anomaly/grav/Bump(atom/bumped_atom)
	. = ..()
	if(.)
		return .
	gravShock(bumped_atom)


/obj/effect/anomaly/grav/Bumped(atom/movable/moving_atom)
	. = ..()
	gravShock(moving_atom)


/obj/effect/anomaly/grav/proc/gravShock(mob/living/A)
	if(boing && isliving(A) && !A.stat)
		if(!knockdown) // no hardstuns with megafauna
			A.Weaken(4 SECONDS)
		var/atom/target = get_edge_target_turf(A, get_dir(src, get_step_away(A, src)))
		A.throw_at(target, 5, 1)
		boing = FALSE

/////////////////////

/obj/effect/anomaly/flux
	name = "flux wave anomaly"
	icon_state = "electricity2"
	density = TRUE
	aSignal = /obj/item/assembly/signaler/anomaly/flux
	var/canshock = FALSE
	var/shockdamage = 20
	var/explosive = TRUE


/obj/effect/anomaly/flux/Initialize(mapload, new_lifespan, drops_core = TRUE, _explosive = TRUE)
	. = ..()
	explosive = _explosive
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/obj/effect/anomaly/flux/anomalyEffect()
	..()
	canshock = TRUE
	for(var/mob/living/M in get_turf(src))
		mobShock(M)


/obj/effect/anomaly/flux/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	mobShock(arrived)


/obj/effect/anomaly/flux/Bump(atom/bumped_atom)
	. = ..()
	if(.)
		return .
	mobShock(bumped_atom)

/obj/effect/anomaly/flux/Bumped(atom/movable/moving_atom)
	. = ..()
	mobShock(moving_atom)

/obj/effect/anomaly/flux/proc/mobShock(mob/living/M)
	if(canshock && istype(M))
		canshock = FALSE //Just so you don't instakill yourself if you slam into the anomaly five times in a second.
		M.electrocute_act(shockdamage, "потоковой аномалии", flags = SHOCK_NOGLOVES)

/obj/effect/anomaly/flux/detonate()
	if(explosive)
		explosion(src, 1, 4, 16, 18, cause = src) //Low devastation, but hits a lot of stuff.
	else
		new /obj/effect/particle_effect/sparks(loc)

/////////////////////

/obj/effect/anomaly/bluespace
	name = "bluespace anomaly"
	icon = 'icons/obj/weapons/projectiles.dmi'
	icon_state = "bluespace"
	density = TRUE
	var/mass_teleporting = TRUE
	aSignal = /obj/item/assembly/signaler/anomaly/bluespace

/obj/effect/anomaly/bluespace/Initialize(mapload, new_lifespan, drops_core = TRUE, _mass_teleporting = TRUE)
	. = ..()
	mass_teleporting = _mass_teleporting

/obj/effect/anomaly/bluespace/anomalyEffect()
	..()
	for(var/mob/living/M in range(1, src))
		do_teleport(M, M, 4)
		investigate_log("teleported [key_name_log(M)] to [COORD(M)]", INVESTIGATE_TELEPORTATION)

/obj/effect/anomaly/bluespace/Bumped(atom/movable/moving_atom)
	. = ..()
	if(isliving(moving_atom))
		do_teleport(moving_atom, moving_atom, 8)
		investigate_log("teleported [key_name_log(moving_atom)] to [COORD(moving_atom)]", INVESTIGATE_TELEPORTATION)

/obj/effect/anomaly/bluespace/detonate()
	if(!mass_teleporting || impact_area.outdoors)
		return
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		// Calculate new position (searches through beacons in world)
		var/obj/item/radio/beacon/chosen
		var/list/possible = list()
		for(var/obj/item/radio/beacon/W in GLOB.beacons)
			if(!is_station_level(W.z))
				continue
			possible += W

		if(length(possible))
			chosen = pick(possible)

		if(chosen)
			// Calculate previous position for transition
			var/turf/turf_from = T // the turf of origin we're travelling FROM
			var/turf/turf_to = get_turf(chosen) // the turf of origin we're travelling TO

			playsound(turf_to, 'sound/effects/phasein.ogg', 100, TRUE)
			GLOB.event_announcement.Announce("Обнаружено перемещение крупной блюспейс-аномалии.", "ВНИМАНИЕ: ОБНАРУЖЕНА АНОМАЛИЯ.")

			var/list/flashers = list()
			for(var/mob/living/carbon/C in viewers(turf_to, null))
				if(C.flash_eyes())
					flashers += C

			var/y_distance = turf_to.y - turf_from.y
			var/x_distance = turf_to.x - turf_from.x
			for(var/atom/movable/A in urange(12, turf_from)) // iterate thru list of mobs in the area
				if(istype(A, /obj/item/radio/beacon))
					continue // don't teleport beacons because that's just insanely stupid
				if(A.anchored || A.move_resist == INFINITY)
					continue

				var/turf/newloc = locate(A.x + x_distance, A.y + y_distance, turf_to.z) // calculate the new place
				if(!A.Move(newloc) && newloc) // if the atom, for some reason, can't move, FORCE them to move! :) We try Move() first to invoke any movement-related checks the atom needs to perform after moving
					A.forceMove(newloc)

				if(ismob(A) && !(A in flashers)) // don't flash if we're already doing an effect
					var/mob/M = A
					if(M.client)
						INVOKE_ASYNC(src, PROC_REF(blue_effect), M)

/obj/effect/anomaly/bluespace/proc/blue_effect(mob/M)
	var/obj/blueeffect = new /obj(src)
	blueeffect.screen_loc = "WEST,SOUTH to EAST,NORTH"
	blueeffect.icon = 'icons/effects/effects.dmi'
	blueeffect.icon_state = "shieldsparkles"
	blueeffect.layer = FLASH_LAYER
	blueeffect.plane = FULLSCREEN_PLANE
	blueeffect.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	M.client.screen += blueeffect
	sleep(20)
	M.client.screen -= blueeffect
	qdel(blueeffect)


/////////////////////

/obj/effect/anomaly/pyro
	name = "pyroclastic anomaly"
	icon_state = "mustard"
	var/ticks = 0
	var/produces_slime = TRUE
	aSignal = /obj/item/assembly/signaler/anomaly/pyro

/obj/effect/anomaly/pyro/Initialize(mapload, new_lifespan, drops_core = TRUE, _produces_slime = TRUE)
	. = ..()
	produces_slime = _produces_slime

/obj/effect/anomaly/pyro/anomalyEffect()
	..()
	ticks++
	if(ticks < 5)
		return
	else
		ticks = 0
	var/turf/simulated/T = get_turf(src)
	if(istype(T))
		T.atmos_spawn_air(LINDA_SPAWN_HEAT | LINDA_SPAWN_TOXINS | LINDA_SPAWN_OXYGEN, 5)

/obj/effect/anomaly/pyro/detonate()
	if(produces_slime)
		INVOKE_ASYNC(src, PROC_REF(makepyroslime))

/obj/effect/anomaly/pyro/proc/makepyroslime()
	var/turf/simulated/T = get_turf(src)
	if(istype(T))
		T.atmos_spawn_air(LINDA_SPAWN_HEAT | LINDA_SPAWN_TOXINS | LINDA_SPAWN_OXYGEN, 500) //Make it hot and burny for the new slime
	var/new_colour = pick("red", "orange")
	var/mob/living/simple_animal/slime/random/S = new(T, new_colour)
	S.rabid = TRUE
	S.set_nutrition(S.get_max_nutrition())

	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Do you want to play as a pyroclastic anomaly slime?", ROLE_SENTIENT, FALSE, 100, source = S, role_cleanname = "pyroclastic anomaly slime")
	if(LAZYLEN(candidates))
		var/mob/dead/observer/chosen = pick(candidates)
		S.key = chosen.key
		S.mind.special_role = SPECIAL_ROLE_PYROCLASTIC_SLIME
		add_game_logs("was made into a slime by pyroclastic anomaly at [AREACOORD(T)].", S)

/////////////////////

/obj/effect/anomaly/bhole
	name = "vortex anomaly"
	icon_state = "bhole3"
	desc = "That's a nice station you have there. It'd be a shame if something happened to it."
	aSignal = /obj/item/assembly/signaler/anomaly/vortex

/obj/effect/anomaly/bhole/anomalyEffect()
	..()
	if(!isturf(loc)) //blackhole cannot be contained inside anything. Weird stuff might happen
		qdel(src)
		return

	grav(rand(0, 3), rand(2, 3), 50, 25)

	//Throwing stuff around!
	for(var/obj/O in range(2, src))
		if(O == src)
			return //DON'T DELETE YOURSELF GOD DAMN
		if(!O.anchored)
			var/mob/living/target = locate() in view(4, src)
			if(target && !target.stat)
				O.throw_at(target, 7, 5)
		else
			O.ex_act(EXPLODE_HEAVY)

/obj/effect/anomaly/bhole/proc/grav(r, ex_act_force, pull_chance, turf_removal_chance)
	for(var/t = -r, t < r, t++)
		affect_coord(x + t, y - r, ex_act_force, pull_chance, turf_removal_chance)
		affect_coord(x - t, y + r, ex_act_force, pull_chance, turf_removal_chance)
		affect_coord(x + r, y + t, ex_act_force, pull_chance, turf_removal_chance)
		affect_coord(x - r, y - t, ex_act_force, pull_chance, turf_removal_chance)

/obj/effect/anomaly/bhole/proc/affect_coord(x, y, ex_act_force, pull_chance, turf_removal_chance)
	//Get turf at coordinate
	var/turf/T = locate(x, y, z)
	if(isnull(T))
		return

	//Pulling and/or ex_act-ing movable atoms in that turf
	if(prob(pull_chance))
		for(var/obj/O in T.contents)
			if(O.anchored)
				O.ex_act(ex_act_force)
			else
				step_towards(O, src)
		for(var/mob/living/M in T.contents)
			step_towards(M, src)

	//Damaging the turf
	if(T && prob(turf_removal_chance))
		T.ex_act(ex_act_force)

#undef ANOMALY_MOVECHANCE
