/datum/component/spawner
	var/mob_types = list(/mob/living/simple_animal/hostile/carp)
	var/spawn_time = 300 //30 seconds default
	var/list/spawned_mobs = list()
	var/spawn_delay = 0
	var/max_mobs = 5
	var/spawn_text = "emerges from"
	var/list/faction = list("mining")



/datum/component/spawner/Initialize(_mob_types, _spawn_time, _faction, _spawn_text, _max_mobs)
	if(_spawn_time)
		spawn_time=_spawn_time
	if(_mob_types)
		mob_types=_mob_types
	if(_faction)
		faction=_faction
	if(_spawn_text)
		spawn_text=_spawn_text
	if(_max_mobs)
		max_mobs=_max_mobs

	RegisterSignal(parent, list(COMSIG_QDELETING), PROC_REF(stop_spawning))
	START_PROCESSING(SSprocessing, src)

/datum/component/spawner/process()
	try_spawn_mob()


/datum/component/spawner/proc/stop_spawning(force)
	STOP_PROCESSING(SSprocessing, src)
	for(var/mob/living/simple_animal/L in spawned_mobs)
		if(L.nest == src)
			L.nest = null
	spawned_mobs = null

/datum/component/spawner/proc/try_spawn_mob()
	var/atom/P = parent
	var/turf/T = get_turf(P)
	if(GLOB.mob_suspension && T && !length(SSmobs?.clients_by_zlevel[T.z]))
		return FALSE
	if(spawned_mobs.len >= max_mobs)
		return FALSE
	if(spawn_delay > world.time)
		return FALSE
	spawn_delay = world.time + spawn_time
	var/chosen_mob_type = pickweight(mob_types)
	var/mob/living/simple_animal/L = new chosen_mob_type(P.loc)
	if(P.flags & ADMIN_SPAWNED)
		L.flags |= ADMIN_SPAWNED
	spawned_mobs += L
	L.nest = src
	L.faction = src.faction
	P.visible_message("<span class='danger'>[L] [spawn_text] [P].</span>")
