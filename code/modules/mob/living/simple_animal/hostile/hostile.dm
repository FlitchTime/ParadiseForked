/mob/living/simple_animal/hostile
	faction = list("hostile",)
	stop_automated_movement_when_pulled = 0
	obj_damage = 40
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES //Bitflags. Set to ENVIRONMENT_SMASH_STRUCTURES to break closets,tables,racks, etc; ENVIRONMENT_SMASH_WALLS for walls; ENVIRONMENT_SMASH_RWALLS for rwalls
	AI_delay_max = 1.5 SECONDS
	var/atom/target
	var/ranged = FALSE
	var/ranged_distance = INFINITY
	var/rapid = 0 //How many shots per volley.
	var/rapid_fire_delay = 2 //Time between rapid fire shots

	///Are we dodging?
	var/dodging = TRUE
	///We should dodge now
	var/approaching_target = FALSE
	///We should sidestep now
	var/in_melee = FALSE
	///Probability that we dodge
	var/dodge_prob = 30
	///How many sidesteps per npcpool cycle when in melee
	var/sidestep_per_cycle = 1

	var/projectiletype	//set ONLY it and NULLIFY casingtype var, if we have ONLY projectile
	var/projectilesound
	var/casingtype		//set ONLY it and NULLIFY projectiletype, if we have projectile IN CASING
	var/move_to_delay = 3 //delay for the automated movement.
	var/list/friends = list()
	var/list/emote_taunt = list()
	var/taunt_chance = 0

	var/rapid_melee = 1			 //Number of melee attacks between each npc pool tick. Spread evenly.
	var/melee_queue_distance = 4 //If target is close enough start preparing to hit them if we have rapid_melee enabled

	var/ranged_message = "fires" //Fluff text for ranged mobs
	///Cooldown for firing
	COOLDOWN_DECLARE(ranged_cooldown)
	var/ranged_cooldown_time = 3 SECONDS //How long, in seconds, the cooldown of ranged attacks is
	var/ranged_ignores_vision = FALSE //if it'll fire ranged attacks even if it lacks vision on its target, only works with environment smash
	var/check_friendly_fire = 0 // Should the ranged mob check for friendlies when shooting
	var/retreat_distance = null //If our mob runs from players when they're too close, set in tile distance. By default, mobs do not retreat.
	var/minimum_distance = 1 //Minimum approach distance, so ranged mobs chase targets down, but still keep their distance set in tiles to the target, set higher to make mobs keep distance


//These vars are related to how mobs locate and target
	var/robust_searching = 0 //By default, mobs have a simple searching method, set this to 1 for the more scrutinous searching (stat_attack, stat_exclusive, etc), should be disabled on most mobs
	var/use_pathfinding = FALSE
	var/vision_range = 9 //How big of an area to search for targets in, a vision of 9 attempts to find targets as soon as they walk into screen view
	var/aggro_vision_range = 9 //If a mob is aggro, we search in this radius. Defaults to 9 to keep in line with original simple mob aggro radius
	var/search_objects = 0 //If we want to consider objects when searching around, set this to 1. If you want to search for objects while also ignoring mobs until hurt, set it to 2. To completely ignore mobs, even when attacked, set it to 3
	var/search_objects_timer_id //Timer for regaining our old search_objects value after being attacked
	var/search_objects_regain_time = 30 //the delay between being attacked and gaining our old search_objects value back
	var/list/wanted_objects = list() //A typecache of objects types that will be checked against to attack, should we have search_objects enabled
	var/stat_attack = CONSCIOUS //Mobs with stat_attack to UNCONSCIOUS will attempt to attack things that are unconscious, Mobs with stat_attack set to DEAD will attempt to attack the dead.
	var/stat_exclusive = FALSE //Mobs with this set to TRUE will exclusively attack things defined by stat_attack, stat_attack DEAD means they will only attack corpses
	var/attack_same = 0 //Set us to 1 to allow us to attack our own faction
	var/atom/targets_from = null //all range/attack/etc. calculations should be done from this atom, defaults to the mob itself, useful for Vehicles and such
	var/attack_all_objects = FALSE //if true, equivalent to having a wanted_objects list containing ALL objects.

	var/lose_patience_timer_id //id for a timer to call LoseTarget(), used to stop mobs fixating on a target they can't reach
	var/lose_patience_timeout = 300 //30 seconds by default, so there's no major changes to AI behaviour, beyond actually bailing if stuck forever

	var/list/enemies = list()
	var/retaliate_only = FALSE //if true, will attack only after being attacked

	var/mob_attack_logs = list() //for hostiles and megafauna

	tts_seed = "Vort_e2"

	dirslash_enabled = TRUE

/mob/living/simple_animal/hostile/Initialize(mapload)
	. = ..()

	if(!targets_from)
		targets_from = src
	wanted_objects = typecacheof(wanted_objects)

/mob/living/simple_animal/hostile/Destroy()
	targets_from = null
	GiveTarget(null)
	return ..()

/mob/living/simple_animal/hostile/tamed(whomst)
	if(isliving(whomst))
		var/mob/living/fren = whomst
		friends = fren
		faction = fren.faction.Copy()
		visible_message(span_notice("[src] gently growls and calms down. It seems that it no longer sees you as a threat!"))
	return ..()

/mob/living/simple_animal/hostile/Life(seconds, times_fired)
	. = ..()
	if(!.)	// dead
		SSmove_manager.stop_looping(src)


/mob/living/simple_animal/hostile/handle_automated_action()
	if(AIStatus == AI_OFF || QDELETED(src))
		return FALSE
	var/list/possible_targets = ListTargets() //we look around for potential targets and make it a list for later use.

	if(environment_smash)
		EscapeConfinement()

	if(AICanContinue(possible_targets))
		if(!QDELETED(target) && !targets_from.Adjacent(target))
			DestroyPathToTarget()
		if(!MoveToTarget(possible_targets))     //if we lose our target
			if(AIShouldSleep(possible_targets))	// we try to acquire a new one
				toggle_ai(AI_IDLE)				// otherwise we go idle
	return TRUE


/mob/living/simple_animal/hostile/handle_automated_movement()
	. = ..()
	if(dodging && target && in_melee && isturf(loc) && isturf(target.loc))
		var/datum/cb = CALLBACK(src, PROC_REF(sidestep))
		if(sidestep_per_cycle > 1) //For more than one just spread them equally - this could changed to some sensible distribution later
			var/sidestep_delay = SSnpcpool.wait / sidestep_per_cycle
			for(var/i in 1 to sidestep_per_cycle)
				addtimer(cb, (i - 1) * sidestep_delay)
		else //Otherwise randomize it to make the players guessing.
			addtimer(cb, rand(1, SSnpcpool.wait))


/mob/living/simple_animal/hostile/proc/sidestep()
	if(!target || !isturf(target.loc) || !isturf(loc) || stat == DEAD)
		return
	var/target_dir = get_dir(src, target)

	var/static/list/cardinal_sidestep_directions = list(-90, -45, 0, 45, 90)
	var/static/list/diagonal_sidestep_directions = list(-45, 0, 45)
	var/chosen_dir = NONE
	if(ISDIAGONALDIR(target_dir))
		chosen_dir = pick(diagonal_sidestep_directions)
	else
		chosen_dir = pick(cardinal_sidestep_directions)
	if(chosen_dir)
		chosen_dir = turn(target_dir,chosen_dir)
		Move(get_step(src, chosen_dir))
		face_atom(target) //Looks better if they keep looking at you when dodging


/mob/living/simple_animal/hostile/step_with_glide(atom/newloc, direction, speed_override)
	return ..(newloc, direction, move_to_delay)


/mob/living/simple_animal/hostile/proceed_attack_results(obj/item/I, mob/living/user, params, def_zone)
	. = ..()
	if(ATTACK_CHAIN_SUCCESS_CHECK(.) && I.force && stat == CONSCIOUS && !target && AIStatus != AI_OFF && !client)
		FindTarget(list(user), TRUE)


/mob/living/simple_animal/hostile/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE, jitter_time = 10 SECONDS, stutter_time = 6 SECONDS, stun_duration = 4 SECONDS)
	if(stat == CONSCIOUS && !target && AIStatus != AI_OFF && !client && isatom(source)) // strings are often used in electrocute_act()
		FindTarget(list(source))
	return ..()


/mob/living/simple_animal/hostile/bullet_act(obj/projectile/P)
	if(stat == CONSCIOUS && !target && AIStatus != AI_OFF && !client)
		if(P.firer && get_dist(src, P.firer) <= aggro_vision_range)
			FindTarget(list(P.firer))
		Goto(P.starting, move_to_delay, 3)
	return ..()

//////////////HOSTILE MOB TARGETTING AND AGGRESSION////////////


/mob/living/simple_animal/hostile/proc/ListTargets()//Step 1, find out what we can see
	if(retaliate_only && !enemies.len)
		return list()
	if(!search_objects)
		. = hearers(vision_range, targets_from) - src //Remove self, so we don't suicide

		var/static/possible_targets = typecacheof(list(/obj/machinery/porta_turret, /obj/mecha, /obj/spacepod, /mob/living))
		for(var/HM in typecache_filter_list(range(vision_range, targets_from), possible_targets))
			if(targets_from.can_see(HM, vision_range))
				. += HM
	else
		. = oview(vision_range, targets_from)
	if(retaliate_only)
		return . &= enemies // Remove all entries that aren't in enemies

/mob/living/simple_animal/hostile/can_see(atom/target, length)
	if(!target || target.invisibility > see_invisible)
		return FALSE
	var/turf/current_turf = get_turf(src)
	var/turf/target_turf = get_turf(target)
	if(!current_turf || !target_turf)	// nullspace
		return FALSE
	if(get_dist(current_turf, target_turf) > length)
		return FALSE
	if(current_turf == target_turf)//they are on the same turf, source can see the target
		return TRUE
	if(isliving(target) && (sight & SEE_MOBS))//if a mob sees mobs through walls, it always sees the target mob within line of sight
		return TRUE
	var/steps = 1
	current_turf = get_step_towards(current_turf, target_turf)
	while(current_turf != target_turf)
		if(steps > length)
			return FALSE
		if(IS_OPAQUE_TURF(current_turf))
			return FALSE
		current_turf = get_step_towards(current_turf, target_turf)
		steps++
	return TRUE


/mob/living/simple_animal/hostile/proc/FindTarget(list/possible_targets)//Step 2, filter down possible targets to things we actually care about
	if(QDELETED(src))
		return
	var/list/all_potential_targets = list()
	if(!possible_targets)
		possible_targets = ListTargets()

	for(var/atom/pos_targ as anything in possible_targets)
		if(Found(pos_targ)) //Just in case people want to override targeting
			all_potential_targets = list(pos_targ)
			break

		if(isitem(pos_targ) && ismob(pos_targ.loc)) //If source is from an item, check the holder of it.
			if(CanAttack(pos_targ.loc))
				all_potential_targets += pos_targ.loc
		else
			if(CanAttack(pos_targ))
				all_potential_targets += pos_targ

	var/found_target = PickTarget(all_potential_targets)
	GiveTarget(found_target)
	return found_target //We now have a target


/mob/living/simple_animal/hostile/proc/Retaliate()
	var/list/around = view(src, vision_range)

	for(var/atom/movable/A in around)
		if(A == src)
			continue
		if(isliving(A))
			var/mob/living/M = A
			if(faction_check_mob(M) && attack_same || !faction_check_mob(M))
				enemies |= M
		else if(ismecha(A))
			var/obj/mecha/M = A
			if(M.occupant)
				enemies |= M
				enemies |= M.occupant
		else if(isspacepod(A))
			var/obj/spacepod/S = A
			if(S.pilot)
				enemies |= S
				enemies |= S.pilot

	for(var/mob/living/simple_animal/hostile/H in around)
		if(faction_check_mob(H) && !attack_same && !H.attack_same)
			H.enemies |= enemies
	return 0

/mob/living/simple_animal/hostile/proc/PossibleThreats()
	. = list()
	for(var/pos_targ in ListTargets())
		var/atom/A = pos_targ
		if(Found(A))
			. = list(A)
			break
		if(CanAttack(A))
			. += A
			continue


/mob/living/simple_animal/hostile/proc/Found(atom/A)//This is here as a potential override to pick a specific target if available
	if(QDELETED(A))
		return FALSE
	if(retaliate_only)
		if(isliving(A))
			var/mob/living/L = A
			if(!L.stat)
				return L
			else
				enemies -= L
		else if(ismecha(A))
			var/obj/mecha/M = A
			if(M.occupant)
				return A
		else if(isspacepod(A))
			var/obj/spacepod/S = A
			if(S.pilot)
				return A


/mob/living/simple_animal/hostile/proc/PickTarget(list/Targets)//Step 3, pick amongst the possible, attackable targets
	if(target != null)//If we already have a target, but are told to pick again, calculate the lowest distance between all possible, and pick from the lowest distance targets
		for(var/pos_targ in Targets)
			var/atom/A = pos_targ
			var/target_dist = get_dist(targets_from, target)
			var/possible_target_distance = get_dist(targets_from, A)
			if(target_dist < possible_target_distance)
				Targets -= A

	var/list/mob/high_priority_targets = list()
	for(var/mob/T in Targets)
		if (!(T.UID() in low_priority_targets))
			high_priority_targets.Add(T)

	if (high_priority_targets.len)
		Targets = high_priority_targets

	if(!Targets.len)//We didnt find nothin!
		return

	var/chosen_target = pick(Targets)//Pick the remaining targets (if any) at random
	return chosen_target


// Please do not add one-off mob AIs here, but override this function for your mob
/mob/living/simple_animal/hostile/CanAttack(atom/the_target)//Can we actually attack a possible target?
	if(!isatom(the_target))
		stack_trace("Invalid target in CanAttack(): [the_target]")
		return FALSE

	if(isturf(the_target) || !the_target || the_target.type == /atom/movable/lighting_object) // bail out on invalids
		return FALSE

	if(ismob(the_target)) //Target is in godmode, ignore it.
		var/mob/mob = the_target
		if(HAS_TRAIT(mob, TRAIT_GODMODE))
			return FALSE

	if(see_invisible < the_target.invisibility) //Target's invisible to us, forget it
		return FALSE
	if(search_objects < 2)
		if(isliving(the_target))
			var/mob/living/L = the_target
			var/faction_check = faction_check_mob(L)
			if(robust_searching)
				if(faction_check && !attack_same)
					return FALSE
				if(L.stat > stat_attack)
					return FALSE
				if(L in friends)
					return FALSE
			else
				if((faction_check && !attack_same) || L.stat > stat_attack)
					return FALSE
			return TRUE

		if(ismecha(the_target))
			var/obj/mecha/M = the_target
			if(M.occupant)//Just so we don't attack empty mechs
				if(CanAttack(M.occupant))
					return TRUE

		if(isspacepod(the_target))
			var/obj/spacepod/S = the_target
			if(S.pilot)//Just so we don't attack empty pods
				if(CanAttack(S.pilot))
					return TRUE

		if(istype(the_target, /obj/machinery/porta_turret))
			var/obj/machinery/porta_turret/P = the_target
			if(P.faction in faction)
				return FALSE
			if(!P.raised) //Don't attack invincible turrets
				return FALSE
			if(P.stat & BROKEN) //Or turrets that are already broken
				return FALSE
			return TRUE

	if(isobj(the_target))
		if(attack_all_objects || is_type_in_typecache(the_target, wanted_objects))
			return TRUE

	return FALSE


/mob/living/simple_animal/hostile/proc/GiveTarget(new_target)//Step 4, give us our selected target
	add_target(new_target)
	LosePatience()
	if(!QDELETED(target))
		GainPatience()
		Aggro()
		return TRUE


//What we do after closing in
/mob/living/simple_animal/hostile/proc/MeleeAction(patience = TRUE)
	if(rapid_melee > 1)
		var/datum/callback/cb = CALLBACK(src, PROC_REF(CheckAndAttack))
		var/delay = SSnpcpool.wait / rapid_melee
		for(var/i in 1 to rapid_melee)
			addtimer(cb, (i - 1)*delay)
	else if(target)
		AttackingTarget()
	if(patience)
		GainPatience()


/mob/living/simple_animal/hostile/proc/CheckAndAttack()
	if(target && targets_from && isturf(targets_from.loc) && target.Adjacent(targets_from) && !incapacitated())
		AttackingTarget()


/mob/living/simple_animal/hostile/proc/MoveToTarget(list/possible_targets)//Step 5, handle movement between us and our target
	stop_automated_movement = TRUE
	if(!target || !CanAttack(target))
		lose_target()
		return FALSE

	var/target_distance = get_dist(targets_from,target)
	if(target in possible_targets)
		var/turf/T = get_turf(src)
		if(target.z != T.z)
			lose_target()
			return FALSE
		if(ranged) //We ranged? Shoot at em
			if(COOLDOWN_FINISHED(src, ranged_cooldown) && !target.Adjacent(targets_from)&& target_distance <= ranged_distance) //But make sure they're not in range for a melee attack
				OpenFire(target)
		if(!Process_Spacemove(NONE)) //Drifting
			SSmove_manager.stop_looping(src)
			return TRUE
		if(!isnull(retreat_distance)) //If we have a retreat distance, check if we need to run from our target
			if(target_distance <= retreat_distance) //If target's closer than our retreat distance, run
				var/glide_flag = move_to_delay > END_GLIDE_SPEED ? MOVEMENT_LOOP_IGNORE_GLIDE : NONE
				SSmove_manager.move_away(src, target, retreat_distance, move_to_delay, flags = glide_flag)
			else
				Goto(target,move_to_delay,minimum_distance) //Otherwise, get to our minimum distance so we chase them
		else
			Goto(target,move_to_delay,minimum_distance)
		if(target)
			if(targets_from && isturf(targets_from.loc) && target.Adjacent(targets_from)) //If they're next to us, attack
				MeleeAction()
			else
				if(rapid_melee > 1 && target_distance <= melee_queue_distance)
					MeleeAction(FALSE)
				in_melee = FALSE //If we're just preparing to strike do not enter sidestep mode
			return TRUE
		return FALSE
	if(environment_smash)
		if(target.loc != null && get_dist(targets_from, target.loc) <= vision_range) //We can't see our target, but he's in our vision range still
			if((COOLDOWN_FINISHED(src, ranged_cooldown)) && ranged_ignores_vision && target_distance <= ranged_distance)
				OpenFire(target)
			if((environment_smash & ENVIRONMENT_SMASH_WALLS) || (environment_smash & ENVIRONMENT_SMASH_RWALLS)) //If we're capable of smashing through walls, forget about vision completely after finding our target
				Goto(target,move_to_delay,minimum_distance)
				FindHidden()
				return TRUE
			else
				if(FindHidden())
					return TRUE
	lose_target()
	return FALSE


/mob/living/simple_animal/hostile/proc/Goto(target, delay, minimum_distance, timeout)
	if(target == src.target)
		approaching_target = TRUE
	else
		approaching_target = FALSE
	var/glide_flag = delay > END_GLIDE_SPEED ? MOVEMENT_LOOP_IGNORE_GLIDE : NONE
	if(use_pathfinding)
		return SSmove_manager.move_to_pathfind(src, target, minimum_distance, delay, timeout, flags = glide_flag)
	return SSmove_manager.move_to(src, target, minimum_distance, delay, timeout, flags = glide_flag)


/mob/living/simple_animal/hostile/adjustHealth(
	amount = 0,
	updating_health = TRUE,
	blocked = 0,
	damage_type = BRUTE,
	forced = FALSE,
)
	. = ..()
	if(!.)
		return .
	if(!ckey && !stat && search_objects < 3 && amount > 0)//Not unconscious, and we don't ignore mobs
		if(search_objects)//Turn off item searching and ignore whatever item we were looking at, we're more concerned with fight or flight
			lose_target()
			LoseSearchObjects()
		if(AIStatus != AI_ON && AIStatus != AI_OFF)
			toggle_ai(AI_ON)
			FindTarget()
		else if(target != null && prob(40))//No more pulling a mob forever and having a second player attack it, it can switch targets now if it finds a more suitable one
			FindTarget()
	if(retaliate_only && amount > 0 && stat == CONSCIOUS)
		Retaliate()



/mob/living/simple_animal/hostile/proc/AttackingTarget()
	in_melee = TRUE
	SEND_SIGNAL(src, COMSIG_HOSTILE_ATTACKINGTARGET, target)
	if(!client)
		mob_attack_logs += "[time_stamp()] Attacked [target] at [COORD(src)]"
	var/result = attack_proc()
	SEND_SIGNAL(src, COMSIG_HOSTILE_POST_ATTACKINGTARGET, target, result)
	return result

/mob/living/simple_animal/hostile/proc/attack_proc()
	return target.attack_animal(src)

/mob/living/simple_animal/hostile/proc/Aggro()
	vision_range = aggro_vision_range
	if(target && emote_taunt.len && prob(taunt_chance))
		INVOKE_ASYNC(src, PROC_REF(custom_emote), EMOTE_VISIBLE, "[pick(emote_taunt)] at [target].")
		taunt_chance = max(taunt_chance-7,2)


/mob/living/simple_animal/hostile/proc/LoseAggro()
	stop_automated_movement = FALSE
	vision_range = initial(vision_range)
	taunt_chance = initial(taunt_chance)


/mob/living/simple_animal/hostile/lose_target()
	. = ..()
	GiveTarget(null)
	approaching_target = FALSE
	in_melee = FALSE
	SSmove_manager.stop_looping(src)
	LoseAggro()


//////////////END HOSTILE MOB TARGETTING AND AGGRESSION////////////

/mob/living/simple_animal/hostile/death(gibbed)
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE
	lose_target()

/mob/living/simple_animal/hostile/proc/summon_backup(distance)
	do_alert_animation(src)
	playsound(loc, 'sound/machines/chime.ogg', 50, 1, -1)
	for(var/mob/living/simple_animal/hostile/M in oview(distance, targets_from))
		if(faction_check_mob(M, TRUE))
			if(M.AIStatus == AI_OFF)
				return
			else
				M.Goto(src,M.move_to_delay,M.minimum_distance)

/mob/living/simple_animal/hostile/proc/CheckFriendlyFire(atom/A)
	if(check_friendly_fire)
		for(var/turf/T as anything in get_line(src,A)) // Not 100% reliable but this is faster than simulating actual trajectory
			for(var/mob/living/L in T)
				if(L == src || L == A)
					continue
				if(faction_check_mob(L) && !attack_same)
					return TRUE

/mob/living/simple_animal/hostile/proc/OpenFire(atom/A)
	if(client && (a_intent == INTENT_HELP || intent == INTENT_HELP))
		return
	if(GLOB.pacifism_after_gt || HAS_TRAIT(src, TRAIT_PACIFISM))
		return
	if(CheckFriendlyFire(A))
		return
	visible_message("<span class='danger'><b>[src]</b> [ranged_message] at [A]!</span>")


	if(rapid > 1)
		var/datum/callback/cb = CALLBACK(src, PROC_REF(Shoot), A)
		for(var/i in 1 to rapid)
			addtimer(cb, (i - 1)*rapid_fire_delay)
	else
		Shoot(A)

	COOLDOWN_START(src, ranged_cooldown, ranged_cooldown_time)

/mob/living/simple_animal/hostile/proc/Shoot(atom/targeted_atom)
	if( QDELETED(targeted_atom) || targeted_atom == targets_from.loc || targeted_atom == targets_from )
		return
	var/turf/startloc = get_turf(targets_from)
	if(casingtype)
		var/obj/item/ammo_casing/casing = new casingtype(startloc)
		playsound(src, projectilesound, 100, 1)
		casing.fire(targeted_atom, src, zone_override = ran_zone())
	else if(projectiletype)
		var/obj/projectile/P = new projectiletype(startloc)
		playsound(src, projectilesound, 100, 1)
		P.current = startloc
		P.starting = startloc
		P.firer = src
		P.yo = targeted_atom.y - startloc.y
		P.xo = targeted_atom.x - startloc.x
		if(AIStatus != AI_ON)//Don't want mindless mobs to have their movement screwed up firing in space
			newtonian_move(get_dir(targeted_atom, targets_from))
		P.original = targeted_atom
		P.preparePixelProjectile(targeted_atom, get_turf(targeted_atom), src)
		P.fire()
		return P

/mob/living/simple_animal/hostile/proc/CanSmashTurfs(turf/T)
	return iswallturf(T) || (ismineralturf(T) && !istype(T, /turf/simulated/mineral/ancient/outer))


/mob/living/simple_animal/hostile/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	if(dodging && approaching_target && prob(dodge_prob) && !moving_diagonally && isturf(loc) && isturf(newloc))
		return dodge(newloc, dir)
	else
		return ..()


/mob/living/simple_animal/hostile/proc/dodge(moving_to, move_direction)
	//Assuming we move towards the target we want to swerve toward them to get closer
	var/cdir = turn(move_direction, 45)
	var/ccdir = turn(move_direction, -45)
	var/turf/step = get_step(loc, pick(cdir, ccdir))
	for(var/atom/object in step)
		if(!object.CanPass(src, get_dir(object, src)))
			return Move(moving_to, move_direction)
	dodging = FALSE
	. = Move(step)
	if(!.)//Can't dodge there so we just carry on
		. = Move(moving_to, move_direction)
	face_atom(target)
	dodging = TRUE


/mob/living/simple_animal/hostile/proc/DestroyObjectsInDirection(direction)
	var/turf/T = get_step(targets_from, direction)
	if(QDELETED(T))
		return
	if(T.Adjacent(targets_from))
		if(CanSmashTurfs(T))
			T.attack_animal(src)
			return
	for(var/obj/O in T.contents)
		if(!O.Adjacent(targets_from))
			continue
		if((ismachinery(O) || isstructure(O)) && O.density && environment_smash >= ENVIRONMENT_SMASH_STRUCTURES && !O.IsObscured())
			O.attack_animal(src)
			return


/mob/living/simple_animal/hostile/proc/DestroyPathToTarget()
	if(environment_smash)
		EscapeConfinement()
		var/dir_to_target = get_dir(targets_from, target)
		var/dir_list = list()
		if(ISDIAGONALDIR(dir_to_target)) //it's diagonal, so we need two directions to hit
			for(var/direction in GLOB.cardinal)
				if(direction & dir_to_target)
					dir_list += direction
		else
			dir_list += dir_to_target
		for(var/direction in dir_list) //now we hit all of the directions we got in this fashion, since it's the only directions we should actually need
			DestroyObjectsInDirection(direction)


/mob/living/simple_animal/hostile/proc/DestroySurroundings() // for use with megafauna destroying everything around them
	if(!environment_smash)
		return
	EscapeConfinement()
	for(var/dir in GLOB.cardinal)
		DestroyObjectsInDirection(dir)


/mob/living/simple_animal/hostile/proc/EscapeConfinement()
	if(buckled)
		buckled.attack_animal(src)
	if(!isturf(targets_from.loc) && targets_from.loc != null)//Did someone put us in something?
		var/atom/A = targets_from.loc
		A.attack_animal(src)//Bang on it till we get out


/mob/living/simple_animal/hostile/proc/FindHidden()
	if(isnull(target))
		return FALSE
	var/static/hidden_locs = typecacheof(list(
		/obj/structure/closet,
		/obj/machinery/disposal,
		/obj/machinery/sleeper,
		/obj/machinery/bodyscanner,
		/obj/machinery/recharge_station,
	))
	if(!is_type_in_typecache(target.loc))
		return FALSE
	. = TRUE
	var/atom/hidden_loc = target.loc
	Goto(hidden_loc, move_to_delay, minimum_distance)
	if(hidden_loc.Adjacent(targets_from))
		hidden_loc.attack_animal(src)


/mob/living/simple_animal/hostile/RangedAttack(atom/A, params) //Player firing
	if(GLOB.pacifism_after_gt || HAS_TRAIT(src, TRAIT_PACIFISM))
		return
	if(ranged && COOLDOWN_FINISHED(src, ranged_cooldown))
		target = A
		OpenFire(A)
		return
	return ..()


////// AI Status ///////
/mob/living/simple_animal/hostile/proc/AICanContinue(list/possible_targets)
	if(QDELETED(src))
		return FALSE
	switch(AIStatus)
		if(AI_ON)
			return TRUE
		if(AI_IDLE)
			if(FindTarget(possible_targets))
				toggle_ai(AI_ON) //Wake up for more than one Life() cycle.
				return TRUE
			return FALSE


/mob/living/simple_animal/hostile/proc/AIShouldSleep(list/possible_targets)
	return !FindTarget(possible_targets)


//These two procs handle losing our target if we've failed to attack them for
//more than lose_patience_timeout deciseconds, which probably means we're stuck
/mob/living/simple_animal/hostile/proc/GainPatience()
	if(lose_patience_timeout)
		LosePatience()
		if(!QDELETED(src))
			lose_patience_timer_id = addtimer(CALLBACK(src, PROC_REF(lose_target)), lose_patience_timeout, TIMER_STOPPABLE)


/mob/living/simple_animal/hostile/proc/LosePatience()
	deltimer(lose_patience_timer_id)


//These two procs handle losing and regaining search_objects when attacked by a mob
/mob/living/simple_animal/hostile/proc/LoseSearchObjects()
	search_objects = 0
	deltimer(search_objects_timer_id)
	search_objects_timer_id = addtimer(CALLBACK(src, PROC_REF(RegainSearchObjects)), search_objects_regain_time, TIMER_STOPPABLE)


/mob/living/simple_animal/hostile/proc/RegainSearchObjects(value)
	if(!value)
		value = initial(search_objects)
	search_objects = value


/mob/living/simple_animal/hostile/consider_wakeup()
	..()
	var/turf/out_turf = get_turf(src)
	if(!out_turf)
		return

	if(!length(SSmobs.clients_by_zlevel[out_turf.z]))
		toggle_ai(AI_Z_OFF)
		return

	var/cheap_search = !is_station_level(out_turf.z)
	var/list/targets_list
	if(cheap_search)
		targets_list = ListTargetsLazy(out_turf.z)
	else
		targets_list = ListTargets()

	if(AIStatus == AI_IDLE && FindTarget(targets_list))
		if(cheap_search) //Try again with full effort
			FindTarget()
		toggle_ai(AI_ON)


/mob/living/simple_animal/hostile/proc/ListTargetsLazy(check_z)//Step 1, find out what we can see
	var/static/hostile_machines = typecacheof(list(
		/obj/machinery/porta_turret,
		/obj/mecha,
		/obj/spacepod,
	))
	. = list()
	for(var/mob/mob as anything in SSmobs.clients_by_zlevel[check_z])
		if(get_dist(mob, src) < vision_range)
			if(isturf(mob.loc))
				. += mob
			else if(is_type_in_typecache(mob.loc, hostile_machines))
				. += mob.loc


/mob/living/simple_animal/hostile/proc/handle_target_del(datum/source)
	SIGNAL_HANDLER

	UnregisterSignal(target, COMSIG_QDELETING)
	target = null
	lose_target()


/mob/living/simple_animal/hostile/proc/add_target(new_target)
	SEND_SIGNAL(src, COMSIG_HOSTILE_FOUND_TARGET, new_target)
	if(target)
		UnregisterSignal(target, COMSIG_QDELETING)
	target = new_target
	if(target)
		RegisterSignal(target, COMSIG_QDELETING, PROC_REF(handle_target_del))

