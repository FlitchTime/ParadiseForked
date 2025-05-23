/* Simple object type, calls a proc when "stepped" on by something */

/obj/effect/step_trigger
	var/affect_ghosts = FALSE
	var/stopper = TRUE // stops throwers
	var/mobs_only = FALSE
	invisibility = INVISIBILITY_ABSTRACT // nope cant see this shit
	anchored = TRUE


/obj/effect/step_trigger/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/obj/effect/step_trigger/proc/Trigger(atom/movable/A)
	return FALSE


/obj/effect/step_trigger/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(!arrived)
		return

	if(!affect_ghosts && isobserver(arrived))
		return

	if(mobs_only && !ismob(arrived))
		return

	INVOKE_ASYNC(src, PROC_REF(Trigger), arrived)


/obj/effect/step_trigger/singularity_act()
	return

/obj/effect/step_trigger/singularity_pull()
	return

/* Sends a message to mob when triggered*/

/obj/effect/step_trigger/message
	var/message	//the message to give to the mob
	var/once = 1
	mobs_only = TRUE

/obj/effect/step_trigger/message/Trigger(mob/M)
	if(M.client)
		to_chat(M, "<span class='info'>[message]</span>")
		if(once)
			qdel(src)

/* Tosses things in a certain direction */

/obj/effect/step_trigger/thrower
	var/direction = SOUTH // the direction of throw
	var/tiles = 3	// if 0: forever until atom hits a stopper
	var/immobilize = 1 // if nonzero: prevents mobs from moving while they're being flung
	var/speed = 1	// delay of movement
	var/nostop = 0 // if 1: will only be stopped by teleporters
	var/list/affecting = list()

/obj/effect/step_trigger/thrower/Trigger(atom/A)
	if(!A || !ismovable(A))
		return
	var/atom/movable/AM = A
	var/curtiles = 0
	var/stopthrow = 0
	for(var/obj/effect/step_trigger/thrower/T in orange(2, src))
		if(AM in T.affecting)
			return

	if(immobilize)
		ADD_TRAIT(AM, TRAIT_IMMOBILIZED, UNIQUE_TRAIT_SOURCE(src))

	affecting.Add(AM)
	while(AM && !stopthrow)
		if(tiles)
			if(curtiles >= tiles)
				break
		if(AM.z != src.z)
			break

		curtiles++

		sleep(speed)

		// Calculate if we should stop the process
		if(!nostop)
			for(var/obj/effect/step_trigger/T in get_step(AM, direction))
				if(T.stopper && T != src)
					stopthrow = 1
		else
			for(var/obj/effect/step_trigger/teleporter/T in get_step(AM, direction))
				if(T.stopper)
					stopthrow = 1

		if(AM)
			step(AM, direction)


	affecting.Remove(AM)
	if(immobilize)
		REMOVE_TRAIT(AM, TRAIT_IMMOBILIZED, UNIQUE_TRAIT_SOURCE(src))


/* Stops things thrown by a thrower, doesn't do anything */

/obj/effect/step_trigger/stopper

/* Instant teleporter */

/obj/effect/step_trigger/teleporter
	var/teleport_x = 0	// teleportation coordinates (if one is null, then no teleport!)
	var/teleport_y = 0
	var/teleport_z = 0
	density = 0
	opacity = 0

/obj/effect/step_trigger/teleporter/Trigger(atom/movable/A)
	if(teleport_x && teleport_y && teleport_z)

		A.loc = locate(teleport_x, teleport_y, teleport_z)

/* Random teleporter, teleports atoms to locations ranging from teleport_x - teleport_x_offset, etc */

/obj/effect/step_trigger/teleporter/random
	var/teleport_x_offset = 0
	var/teleport_y_offset = 0
	var/teleport_z_offset = 0

/obj/effect/step_trigger/teleporter/random/Trigger(atom/movable/A)
	if(teleport_x && teleport_y && teleport_z)
		if(teleport_x_offset && teleport_y_offset && teleport_z_offset)

			var/turf/T = locate(rand(teleport_x, teleport_x_offset), rand(teleport_y, teleport_y_offset), rand(teleport_z, teleport_z_offset))
			if (T)
				A.forceMove(T)

/* Fancy teleporter, creates sparks and smokes when used */

/obj/effect/step_trigger/teleport_fancy
	var/locationx
	var/locationy
	var/uses = 1	//0 for infinite uses
	var/entersparks = 0
	var/exitsparks = 0
	var/entersmoke = 0
	var/exitsmoke = 0

/obj/effect/step_trigger/teleport_fancy/Trigger(mob/M)
	var/dest = locate(locationx, locationy, z)
	M.Move(dest)

	if(entersparks)
		var/datum/effect_system/spark_spread/s = new
		s.set_up(4, 1, src)
		s.start()
	if(exitsparks)
		var/datum/effect_system/spark_spread/s = new
		s.set_up(4, 1, dest)
		s.start()

	if(entersmoke)
		var/datum/effect_system/fluid_spread/smoke/smoke = new
		smoke.set_up(amount = 4, location = src)
		smoke.start()

	if(exitsmoke)
		var/datum/effect_system/fluid_spread/smoke/smoke = new
		smoke.set_up(amount = 4, location = dest)
		smoke.start()

	uses--
	if(uses == 0)
		qdel(src)

/* Simple sound player, Mapper friendly! */

/obj/effect/step_trigger/sound_effect
	var/list/sound //eg. path to the sound, inside '' eg: 'growl.ogg'
	var/volume = 100
	var/freq_vary = 1 //Should the frequency of the sound vary?
	var/extra_range = 0 // eg World.view = 7, extra_range = 1, 7+1 = 8, 8 turfs radius
	var/happens_once = 0
	var/triggerer_only = 0 //Whether the triggerer is the only person who hears this


/obj/effect/step_trigger/sound_effect/Trigger(atom/movable/A)
	var/turf/T = get_turf(A)

	if(!T)
		return

	if(triggerer_only && ismob(A))
		var/mob/B = A
		B.playsound_local(T, pick(sound), volume, freq_vary)
	else
		playsound(T, pick(sound), volume, freq_vary, extra_range)

	if(happens_once)
		qdel(src)

/obj/effect/step_trigger/sound_effect/explosion_far
	sound = list('sound/effects/explosionfar.ogg', 'sound/effects/explosioncreak2.ogg', 'sound/effects/explosioncreak1.ogg', 'sound/effects/explosion_distant.ogg')
	volume = 200
	happens_once = 1
	extra_range = 4
