#define BODY_SHIELD_COOLDOWN_TIME enraged ? 3 SECONDS : 5 SECONDS
#define EXTRA_PLAYER_ANGER_NORMAL_CAP 6
#define EXTRA_PLAYER_ANGER_STATION_CAP 3
#define BLUESPACE 1
#define GRAV 2
#define PYRO 3
#define FLUX 4
#define VORTEX 5
#define TOP_RIGHT 1
#define TOP_LEFT 2
#define BOTTOM_RIGHT 3
#define BOTTOM_LEFT 4


/*

Vetus Speculator

An old 4 legged self learning robot made from a long gone civilization. Likes to scan and learn from things... Including crewmembers.

Hybrid ranged / melee combatant, similar to bubblegum.

It has several attacks at it's disposal. It can melee with it's body and legs, however a person will not be hit by both at once unless poorly positioned. Legs also have a weak turret on each leg, that can be broken via damage.

Every 5 seconds it creates a shield around itself, that blocks 1 hit, or multiple non damaging hits. Crusher users will need blast tube to break the shield, OR melee the robot with shield up to de-activate it.

The main feature that makes it unique, is that it has 5 modes, based on each anomaly core, that can augment it's remaning attacks.

It can charge like bubblegum. If it has a pyro core, it makes a trail of fire and temporary lava. If it is bluespace, it charges with more delay between charges, but instead teleports between charges, to make it less predictable. Grav throws people if they bump into them during charge.

It can spawn 3 anomalies around it for 15 seconds with a low chance. They do not explode / mass teleport / spawn slimes.

Finaly, for each mode, it has a special attack.
	- Bluespace causes it's current target to have half attack speed for 10 seconds.
	- Grav picks up rocks from the terrain, and throws them at the target.
	- Pyro turns 3x3 areas around the target (but not too close) into lava.
	- Flux shoots weakened tesla revolver shots at all humans nearby.
	- Vortex causes a small earthquake, leading to rocks falling from the sky.

Upon reaching critical HP (normally death), it preps a 10 second self destruct, before exploding. Large tell, hard to miss.
Loot: Anomaly core that matches the mode that was picked of the robot. A pinpointer that can point to tendrils, which should be fine, as by the time this is killed, the round should be an hour or more over. As well as a variety of raw ores.
Crusher Loot: Adaptive inteligence core, a trophy that temporarly increases the force of a crusher against a target it has hit within the last 30 seconds by 2 per hit, up to 20 extra force.

Difficulty: Very Hard

*/

/mob/living/simple_animal/hostile/megafauna/ancient_robot
	name = "\improper Vetus Speculator"
	desc = "An ancient robot from a long forgotten civilization. Adapts to the enviroment, and what it finds, to be the ideal combatant."
	health = 2500
	maxHealth = 2500
	attacktext = "shocks"
	attack_sound = 'sound/machines/defib_zap.ogg'
	icon = 'icons/mob/lavaland/64x64megafauna.dmi'
	icon_state = "ancient_robot"
	icon_living = "ancient_robot"
	friendly = "stares down"
	speak_emote = list("BUZZES")
	universal_speak = TRUE
	universal_understand = TRUE
	armour_penetration = 40
	melee_damage_lower = 20
	melee_damage_upper = 20
	melee_damage_type = BURN //Legs do the stomping, this is just a shock
	speed = 5
	move_to_delay = 5
	ranged = TRUE
	pixel_x = -16
	pixel_y = -16
	del_on_death = TRUE
	loot = list(/obj/structure/closet/crate/necropolis/ancient)
	crusher_loot = list(/obj/structure/closet/crate/necropolis/ancient/crusher)
	internal_type = /obj/item/gps/internal/ancient
	medal_type = BOSS_MEDAL_ROBOT
	score_type = ROBOT_SCORE
	deathmessage = "explodes into a shower of alloys"
	footstep_type = FOOTSTEP_MOB_HEAVY //make stomp like bubble
	attack_action_types = list()

	var/charging = FALSE
	var/revving_charge = FALSE
	var/player_cooldown = 0
	var/body_shield_enabled = FALSE
	var/extra_player_anger = 0
	var/mode = 0 //This variable controls the special attacks of the robot, one for each anomaly core.
	var/exploding = FALSE

/// Legs and the connector for the legs

	var/mob/living/simple_animal/hostile/ancient_robot_leg/TR = null
	var/mob/living/simple_animal/hostile/ancient_robot_leg/TL = null
	var/mob/living/simple_animal/hostile/ancient_robot_leg/BR = null
	var/mob/living/simple_animal/hostile/ancient_robot_leg/BL = null
	var/obj/effect/abstract/beam = null

/mob/living/simple_animal/hostile/megafauna/ancient_robot/Initialize(mapload, mob/living/ancient) //We spawn and move them to clear out area for the legs, rather than risk the legs getting put in a wall
	. = ..()
	TR = new /mob/living/simple_animal/hostile/ancient_robot_leg(loc, src, TOP_RIGHT)
	TL = new /mob/living/simple_animal/hostile/ancient_robot_leg(loc, src, TOP_LEFT)
	BR = new /mob/living/simple_animal/hostile/ancient_robot_leg(loc, src, BOTTOM_RIGHT)
	BL = new /mob/living/simple_animal/hostile/ancient_robot_leg(loc, src, BOTTOM_LEFT)
	beam = new /obj/effect/abstract(loc)
	mode = pick(BLUESPACE, GRAV, PYRO, FLUX, VORTEX) //picks one of the 5 cores.
	if(mode == FLUX) // Main attack is shock, so flux makes it stronger
		melee_damage_lower = 25
		melee_damage_upper = 25
	body_shield()
	add_overlay("[mode]")
	add_overlay("eyes")
	return INITIALIZE_HINT_LATELOAD

/mob/living/simple_animal/hostile/megafauna/ancient_robot/LateInitialize()
	fix_specific_leg(TOP_RIGHT)
	fix_specific_leg(TOP_LEFT)
	fix_specific_leg(BOTTOM_RIGHT)
	fix_specific_leg(BOTTOM_LEFT)


/mob/living/simple_animal/hostile/megafauna/ancient_robot/Destroy()
	QDEL_NULL(TR)
	QDEL_NULL(TL)
	QDEL_NULL(BR)
	QDEL_NULL(BL)
	QDEL_NULL(beam)
	return ..()

/obj/item/gps/internal/ancient
	icon_state = null
	gpstag = "Mysterious Signal"
	desc = "ERROR_NULL_ENTRY"
	invisibility = 100

/mob/living/simple_animal/hostile/megafauna/ancient_robot/death(gibbed, allowed = FALSE)
	if(allowed)
		return ..()
	else if(exploding) //but it refused
		return
	adjustBruteLoss(-1)
	self_destruct()
	exploding = TRUE


/mob/living/simple_animal/hostile/megafauna/ancient_robot/Life(seconds, times_fired)
	..()
	if(!exploding)
		return
	playsound(src, 'sound/items/timer.ogg', 70, 0)

/mob/living/simple_animal/hostile/megafauna/ancient_robot/drop_loot()
	var/core_type = null
	switch(mode)
		if(BLUESPACE)
			core_type = /obj/item/assembly/signaler/anomaly/bluespace
		if(GRAV)
			core_type = /obj/item/assembly/signaler/anomaly/grav
		if(PYRO)
			core_type = /obj/item/assembly/signaler/anomaly/pyro
		if(FLUX)
			core_type = /obj/item/assembly/signaler/anomaly/flux
		if(VORTEX)
			core_type = /obj/item/assembly/signaler/anomaly/vortex

	var/crate_type = pick(loot)
	var/obj/structure/closet/crate/C = new crate_type(loc)
	new core_type(C)
	if(!enraged)
		return
	for(var/mob/living/M in urange(40, src)) //Bigger range, ran once per shift, as people run away from vetus as it blows up.
		if(M.client)
			new /obj/item/disk/fauna_research/vetus(C)

/mob/living/simple_animal/hostile/megafauna/ancient_robot/enrage()
	. = ..()
	if(!.)
		return

	armour_penetration = 66
	TL.armour_penetration = 66
	TR.armour_penetration = 66
	BL.armour_penetration = 66
	BR.armour_penetration = 66


/mob/living/simple_animal/hostile/megafauna/ancient_robot/unrage()
	. = ..()
	armour_penetration = 50
	TL.armour_penetration = 50
	TR.armour_penetration = 50
	BL.armour_penetration = 50
	BR.armour_penetration = 50

/mob/living/simple_animal/hostile/megafauna/ancient_robot/OpenFire()
	if(charging)
		return

	if(exploding)
		return

	anger_modifier = clamp(((maxHealth - health) / 50), 0, 20)
	ranged_cooldown = world.time + (ranged_cooldown_time * ((10 - extra_player_anger) / 10))
	if(enraged && prob(20)) //This attack is free, and can be combined with other attacks, so chance is low.
		single_laser()

	if(prob(30 + (anger_modifier / 2))) //Less scaling as the weaker attack / first calculated.
		triple_charge()

	else if(prob(15 + anger_modifier))
		spawn_anomalies()

	else if(prob(60 + anger_modifier))
		do_special_move()

	calculate_extra_player_anger()

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/single_laser()
	say(pick("KTMGMK JOYIU OTLKXTU", "ROQK G OTZKXTGR JOYQ", "HO-JOXKIZOUTGR RGYKXY KTMGMKJ"))
	new /obj/effect/vetus_laser(get_turf(src))

/obj/effect/vetus_laser
	icon = 'icons/obj/engines_and_power/tesla/energy_ball.dmi'
	icon_state = "energy_ball"
	pixel_x = -32
	pixel_y = -32

/obj/effect/vetus_laser/Initialize(mapload)
	. = ..()
	var/newcolor = rgb(241, 137, 172)
	add_atom_colour(newcolor, TEMPORARY_COLOUR_PRIORITY)
	beam_it_up()

/obj/effect/vetus_laser/ex_act(severity)
	return

/obj/effect/vetus_laser/proc/beam_it_up()
	var/turf/beam_me_up_scotty = get_turf(src)
	for(var/turf/T in spiral_range_turfs(9, src, 9))
		T.Beam(beam_me_up_scotty, icon_state = "sm_arc_dbz_referance", time = 0.1, beam_type = /obj/effect/ebeam/vetus)
		SLEEP_CHECK_QDEL(1)
	qdel(src)

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/triple_charge()
	if(mode == BLUESPACE)
		charge(delay = 24) //An extra charge, to make up for the longer time between teleports
		charge(delay = 18)
		charge(delay = 12)
		charge(delay = 6)
	else
		charge(delay = 9)
		charge(delay = 6)
		charge(delay = 3)
	SetRecoveryTime(15)

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/charge(atom/chargeat = target, delay = 5, chargepast = 2)
	if(!chargeat)
		return
	if(mode == BLUESPACE || (enraged && prob(13)))
		new /obj/effect/temp_visual/bsg_kaboom(get_turf(src))
		src.visible_message("<span class='danger'>[src] teleports somewhere nearby!</span>")
		do_teleport(src, target, 7, asoundin = 'sound/effects/phasein.ogg') //Teleport within 7 tiles of the target
		new /obj/effect/temp_visual/bsg_kaboom(get_turf(src))

		TR.health_and_snap_check(FALSE)// We want the legs to instantly teleport with it, without regening
		TL.health_and_snap_check(FALSE)
		BR.health_and_snap_check(FALSE)
		BL.health_and_snap_check(FALSE)

	var/chargeturf = get_turf(chargeat)
	if(!chargeturf)
		return
	var/dir = get_dir(src, chargeturf)
	var/turf/T = get_ranged_target_turf(chargeturf, dir, chargepast)
	if(!T)
		return
	new /obj/effect/temp_visual/dragon_swoop/bubblegum/ancient_robot(T, beam)
	charging = TRUE
	revving_charge = TRUE
	DestroySurroundings()
	SSmove_manager.stop_looping(src)
	setDir(dir)
	SLEEP_CHECK_DEATH(src, delay)
	revving_charge = FALSE
	var/movespeed = 0.8
	SSmove_manager.move_towards_legacy(src, T, movespeed, flags = MOVEMENT_LOOP_START_FAST, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	SLEEP_CHECK_DEATH(src, get_dist(src, T) * movespeed)
	SSmove_manager.stop_looping(src)
	charging = FALSE

/mob/living/simple_animal/hostile/megafauna/ancient_robot/MeleeAction(patience = TRUE)
	if(charging)
		return
	return ..()


/mob/living/simple_animal/hostile/megafauna/ancient_robot/Bump(mob/living/bumped_living)
	. = ..()
	if(!charging || istype(bumped_living, /mob/living/simple_animal/hostile/ancient_robot_leg) || !isliving(bumped_living))
		return .
	var/turf/living_turf = get_turf(bumped_living)
	bumped_living.visible_message("<span class='danger'>[src] slams into [bumped_living]!</span>", "<span class='userdanger'>[src] tramples you into the ground!</span>")
	forceMove(living_turf)
	var/limb_to_hit = bumped_living.get_organ(pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))
	bumped_living.apply_damage(25, BRUTE, limb_to_hit, bumped_living.run_armor_check(limb_to_hit, "melee", null, null, armour_penetration))
	playsound(living_turf, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	shake_camera(bumped_living, 4, 3)
	shake_camera(src, 2, 3)
	if(mode == GRAV || enraged)
		var/atom/throw_target = get_edge_target_turf(bumped_living, get_dir(src, get_step_away(bumped_living, src)))
		bumped_living.throw_at(throw_target, 3, 2)


/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/body_shield()
	body_shield_enabled = TRUE
	visible_message("<span class='danger'>[src] creates some sort of energy shield!</span>")
	add_overlay("shield")

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/disable_shield()
	visible_message("<span class='danger'>[src]'s shield fails!</span>")
	cut_overlay("shield")
	body_shield_enabled = FALSE
	addtimer(CALLBACK(src, PROC_REF(body_shield)), BODY_SHIELD_COOLDOWN_TIME)


/mob/living/simple_animal/hostile/megafauna/ancient_robot/bullet_act(obj/projectile/P)
	if(!body_shield_enabled)
		return ..()
	do_sparks(2, 1, src)
	visible_message(span_danger("[src]'s shield deflects [P] in a shower of sparks!"), span_userdanger("You deflect the projectile!"), projectile_message = TRUE)
	if(P.damage)
		disable_shield()


/mob/living/simple_animal/hostile/megafauna/ancient_robot/proceed_attack_results(obj/item/I, mob/living/user, params, def_zone)
	if(!body_shield_enabled)
		return ..()

	. = ATTACK_CHAIN_BLOCKED
	do_sparks(2, 1, src)
	visible_message(
		span_danger("[src]'s shield deflects [I] in a shower of sparks!"),
		span_warning("Your shield deflects the attack!"),
		ignored_mobs = user,
	)
	to_chat(user, span_danger("[src]'s shield deflects your attack!"))
	if(I.force)
		disable_shield()


/mob/living/simple_animal/hostile/megafauna/ancient_robot/devour(mob/living/L)
	say(pick("JKYZXAIZOBK GTGREYKX GIZOBK", "OTZKMXGZOTM YAHPKIZ YZXKTMZNY", "JKIUSVOROTM GTJ RKGXTOTM", "LOTJOTM IXOZOIGR CKGQTKYYKY")) //what can I say, I like the trope of something talking in cypher
	visible_message("<span class='userdanger'>[src] disintigrates [L]!</span>","<span class='userdanger'>You analyse [L], restoring your health!</span>")
	if(client || !is_station_level(z))
		adjustHealth(-maxHealth * 0.1)
	L.dust()

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/do_special_move()
	say(pick("JKVRUEOTM LUIAYKJ VUCKX", "JKVRUEOTM KDVKXOSKTZGR GZZGIQ", "LUIAYOTM VUCKX OTZU GTUSGRUAY UHPKIZ", "VUCKX UL ZNK YAT OT ZNK NKGXZ UL SE IUXK"))
	switch(mode)
		if(BLUESPACE)
			if(ishuman(target))
				var/mob/living/carbon/human/H = target
				to_chat(H, "<span class='danger'>[src] starts to slow time around you!</span>")
				H.apply_status_effect(STATUS_EFFECT_BLUESPACESLOWDOWN)
		if(GRAV)
			visible_message("<span class='danger'>Debris from the battlefield begin to get compressed into rocks!</span>")
			var/list/turfs = list()
			var/rocks = 0
			for(var/turf/T in view(4, target))
				if(T.density)
					continue
				if(T in range (2, target))
					continue
				turfs += T
			var/amount = enraged ? 5 : 3
			while(rocks < amount && length(turfs))
				var/turf/spot = pick_n_take(turfs)
				if(!spot)
					return
				new /obj/effect/temp_visual/rock(spot)
				addtimer(CALLBACK(src, PROC_REF(throw_rock), spot, target), 2 SECONDS)
				rocks++
		if(PYRO)
			visible_message("<span class='danger'>The ground begins to heat up around you!</span>")
			var/list/turfs = list()
			var/volcanos = 0
			for(var/turf/T in view(4, target))
				if(T.density)
					continue
				if(T in range(1, target))
					continue
				turfs += T
			var/amount = enraged ? 5 : 3
			while(volcanos < amount && length(turfs))
				var/turf/spot = pick_n_take(turfs)
				if(!spot)
					return
				for(var/turf/around in range(1, spot))
					new /obj/effect/temp_visual/lava_warning(around, enraged ? 18 SECONDS : 6 SECONDS)
				volcanos++
		if(FLUX)
			for(var/mob/living/carbon/human/H in view(7, src))
				var/turf/T = get_turf(H)
				var/turf/S = get_turf(src)
				if(!S || !T)
					return
				var/obj/projectile/energy/shock_revolver/ancient/O = new /obj/projectile/energy/shock_revolver/ancient(S)
				O.current = S
				O.firer = src
				O.yo = T.y - S.y
				O.xo = T.x - S.x
				O.fire()
		if(VORTEX)
			visible_message("<span class='danger'>[src] begins vibrate rapidly. It's causing an earthquake!</span>")
			for(var/turf/turf in range(9,get_turf(target)))
				if(prob(enraged ? 40 : 15))
					new /obj/effect/temp_visual/target/ancient(turf)

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/spawn_anomalies()
	say(pick("JKVRUEOTM XGC VUCKX", "KXXUX OT GTUSGRE IUTZGOTSKTZ", "YZGHOROZE OT OTYZGHOROZE OT YZGHOROZE OT OTYZGH-"))
	var/list/turfs = list()
	var/anomalies = 0
	for(var/turf/T in view(5, src))
		if(T.density)
			continue
		turfs += T
	var/amount = enraged ? 5 : 3
	while(anomalies < amount && length(turfs))
		var/turf/spot = pick(turfs)
		turfs -= spot
		var/time_to_use = enraged ? 25 SECONDS : 15 SECONDS
		switch(mode)
			if(BLUESPACE)
				var/obj/effect/anomaly/bluespace/A = new(spot, time_to_use, FALSE)
				A.mass_teleporting = FALSE
			if(GRAV)
				var/obj/effect/anomaly/grav/A = new(spot, time_to_use, FALSE, FALSE)
				A.knockdown = TRUE
			if(PYRO)
				var/obj/effect/anomaly/pyro/A = new(spot, time_to_use, FALSE)
				A.produces_slime = FALSE
			if(FLUX)
				var/obj/effect/anomaly/flux/A = new(spot, time_to_use, FALSE)
				A.explosive = FALSE
			if(VORTEX)
				new /obj/effect/anomaly/bhole(spot, time_to_use, FALSE)
		anomalies++
	return

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/throw_rock(turf/spot, mob/target)
	var/turf/T = get_turf(target)
	if(!spot || !T)
		return
	var/obj/projectile/bullet/rock/O = new /obj/projectile/bullet/rock(spot)
	O.current = spot
	O.firer = src
	O.yo = T.y - spot.y
	O.xo = T.x - spot.x
	O.fire()

// To make this fight harder, it scales it's attacks based on number of players, or as injured. Capped lower on station.
/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/calculate_extra_player_anger()
	var/anger = 0
	var/cap = 0
	for(var/mob/living/carbon/human/H in range(10, src))
		if(H.stat == DEAD)
			continue
		anger++
	if(health <= health / 2)
		anger += 2
	if(enraged)
		anger += 2
	cap = (is_station_level(loc.z) ? EXTRA_PLAYER_ANGER_STATION_CAP : EXTRA_PLAYER_ANGER_NORMAL_CAP) + enraged
	extra_player_anger = clamp(anger,1,cap) - 1

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/self_destruct()
	say(pick("OTZKMXOZE LGORAXK, YKRL JKYZXAIZ GIZOBK", "RUYY IKXZGOT, KTMGMKOTM XKIUBKXE JKTOGR", "VUCKX IUXKY 8-12 HXKGINKJ, UBKXRUGJOTM XKSGOTOTM IUXKY", "KXXUX KXXUX KXXUX KXXUX KXX-", "-ROQK ZKGXY OT XGOT- - -ZOSK ZU JOK"))
	visible_message("<span class='biggerdanger'>[src] begins to overload it's core. It is going to explode!</span>")
	SSmove_manager.stop_looping(src)
	playsound(src,'sound/machines/alarm.ogg',100,0,5)
	addtimer(CALLBACK(src, PROC_REF(kaboom)), 10 SECONDS)

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/kaboom()
	explosion(get_turf(src), -1, 7, 15, 20)
	health = 0
	death(allowed = TRUE)

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/disable_legs()
	TR.ranged = FALSE

	TL.ranged = FALSE

	BR.ranged = FALSE

	BL.ranged = FALSE

/mob/living/simple_animal/hostile/megafauna/ancient_robot/face_atom(atom/A) //This is used to make the legs get near the core when a user is meleeing the core
	. = ..()
	switch(dir)
		if(NORTH)
			leg_control_system(TOP_RIGHT, 1, 2)
			leg_control_system(TOP_LEFT, -1, 2)
		if(SOUTH)
			leg_control_system(BOTTOM_RIGHT, 1, -2)
			leg_control_system(BOTTOM_LEFT, -1, -2)
		if(EAST)
			leg_control_system(TOP_RIGHT, 2, 1)
			leg_control_system(BOTTOM_RIGHT, 2, -1)
		if(WEST)
			leg_control_system(TOP_LEFT, -2, 1)
			leg_control_system(BOTTOM_LEFT, -2,- 1)

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/fix_specific_leg(input) //Used to reset legs to specific locations
	switch(input)
		if(TOP_RIGHT)
			leg_control_system(input, 2, 2)
		if(TOP_LEFT)
			leg_control_system(input, -2, 2)
		if(BOTTOM_RIGHT)
			leg_control_system(input, 2, -2)
		if(BOTTOM_LEFT)
			leg_control_system(input, -2, -2)

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/leg_walking_controler(dir) //This controls the legs. Here be pain.
	switch(dir)
		if(NORTH)
			leg_walking_orderer(TOP_RIGHT, TOP_LEFT, BOTTOM_RIGHT, BOTTOM_LEFT)
		if(SOUTH)
			leg_walking_orderer(BOTTOM_LEFT, BOTTOM_RIGHT, TOP_LEFT, TOP_RIGHT)
		if(EAST)
			leg_walking_orderer(TOP_RIGHT, TOP_LEFT, BOTTOM_RIGHT, BOTTOM_LEFT)
		if(WEST)
			leg_walking_orderer(BOTTOM_LEFT, BOTTOM_RIGHT, TOP_LEFT, TOP_RIGHT)
		if(NORTHEAST)
			leg_walking_orderer(TOP_RIGHT, TOP_LEFT, BOTTOM_RIGHT, BOTTOM_LEFT)
		if(SOUTHEAST)
			leg_walking_orderer(BOTTOM_RIGHT, TOP_LEFT, BOTTOM_LEFT, TOP_RIGHT)
		if(NORTHWEST)
			leg_walking_orderer(TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT)
		if(SOUTHEAST)
			leg_walking_orderer(BOTTOM_LEFT, TOP_LEFT, BOTTOM_RIGHT, TOP_RIGHT)


/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/leg_walking_orderer(A, B, C, D)
	addtimer(CALLBACK(src, PROC_REF(fix_specific_leg), A), 1)
	addtimer(CALLBACK(src, PROC_REF(fix_specific_leg), B), 2)
	addtimer(CALLBACK(src, PROC_REF(fix_specific_leg), C), 3)
	addtimer(CALLBACK(src, PROC_REF(fix_specific_leg), D), 4)

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/leg_control_system(input, horizontal, vertical)
	var/turf/target = locate(x + horizontal, y + vertical, z)
	switch(input)
		if(TOP_RIGHT)
			TR.leg_movement(target, 0.6)
		if(TOP_LEFT)
			TL.leg_movement(target, 0.6)
		if(BOTTOM_RIGHT)
			BR.leg_movement(target, 0.6)
		if(BOTTOM_LEFT)
			BL.leg_movement(target, 0.6)

/mob/living/simple_animal/hostile/megafauna/ancient_robot/ex_act(severity, target)
	switch(severity)
		if(1)
			adjustBruteLoss(25)

		if(2)
			adjustBruteLoss(10)

		if(3)
			return

/mob/living/simple_animal/hostile/megafauna/ancient_robot/Goto()
	if(!exploding)
		return ..()
	return

/mob/living/simple_animal/hostile/megafauna/ancient_robot/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	if(!movement_dir)
		return ..()

	leg_walking_controler(movement_dir)
	if(!charging)
		return ..()

	switch(mode)
		if(PYRO)
			var/turf/C = get_turf(src)
			new /obj/effect/temp_visual/lava_warning(C, enraged ? 18 SECONDS : 6 SECONDS)
			for(var/turf/T in range (1,src))
				new /obj/effect/hotspot(T)
				T.hotspot_expose(700,50,1)
		if(VORTEX)
			var/turf/T = get_turf(src)
			for(var/atom/A in T)
				A.ex_act(3) //Body is immune to explosions of this strength.
			T.ex_act(3)

	if(beam && !QDELETED(beam))
		beam.forceMove(get_turf(src))

	return ..()


/mob/living/simple_animal/hostile/megafauna/ancient_robot/mob_negates_gravity() //No more being thrown around like a spastic child by grav anomalies
	return TRUE

/mob/living/simple_animal/hostile/megafauna/ancient_robot/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE, jitter_time = 10 SECONDS, stutter_time = 6 SECONDS, stun_duration = 4 SECONDS)
	return FALSE

/mob/living/simple_animal/hostile/ancient_robot_leg
	name = "leg"
	desc = "Legs with a mounted turret, for shooting and crushing small miners like you."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "leg"
	maxHealth = INFINITY //it's fine trust me
	health = INFINITY
	faction = list("mining", "boss") // No attacking your leg
	weather_immunities = list(TRAIT_LAVA_IMMUNE, TRAIT_ASHSTORM_IMMUNE)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	check_friendly_fire = 1
	ranged = TRUE
	projectilesound = 'sound/weapons/gunshots/1autorifle.ogg'
	projectiletype = /obj/projectile/bullet/ancient_robot_bullet
	attacktext = "stomps on"
	armour_penetration = 20
	melee_damage_lower = 15
	melee_damage_upper = 15
	obj_damage = 400
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	sentience_type = SENTIENCE_BOSS
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	stop_automated_movement = 1
	wander = 0
	robust_searching = TRUE
	ranged_ignores_vision = TRUE
	stat_attack = UNCONSCIOUS
	var/range = 3
	var/mob/living/simple_animal/hostile/megafauna/ancient_robot/core = null
	var/fake_max_hp = 300
	var/fake_hp = 300
	var/fake_hp_regen = 2
	var/transfer_rate = 0.75
	var/who_am_i = null

/mob/living/simple_animal/hostile/ancient_robot_leg/Initialize(mapload, mob/living/ancient, who)
	. = ..()
	if(!ancient)
		qdel(src) //no
		return
	AddElement(/datum/element/simple_flying)
	core = ancient
	who_am_i = who
	ranged_cooldown_time = rand(30, 60) // keeps them not running on the same time
	addtimer(CALLBACK(src, PROC_REF(beam_setup)), 1 SECONDS)

/mob/living/simple_animal/hostile/ancient_robot_leg/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		minbodytemp = 0, \
	)

/mob/living/simple_animal/hostile/ancient_robot_leg/death(gibbed)
	return //It shouldn't get gibbed by shuttle.

/mob/living/simple_animal/hostile/ancient_robot_leg/Life(seconds, times_fired)
	..()
	health_and_snap_check(TRUE)

/mob/living/simple_animal/hostile/ancient_robot_leg/bullet_act(obj/projectile/P)
	if(core.stat == CONSCIOUS && !core.target && core.AIStatus != AI_OFF && !core.client)
		if(P.firer && get_dist(core, P.firer) <= core.aggro_vision_range)
			core.FindTarget(list(P.firer))
		core.Goto(P.starting, core.move_to_delay, 3)
	..()

/mob/living/simple_animal/hostile/ancient_robot_leg/Goto()
	return // stops the legs from trying to move on their own

/mob/living/simple_animal/hostile/ancient_robot_leg/proc/beam_setup()
	Beam(core, "leg_connection", 'icons/effects/effects.dmi', time = INFINITY, maxdistance = INFINITY, beam_type = /obj/effect/ebeam/vetus_leg)

/mob/living/simple_animal/hostile/ancient_robot_leg/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents = TRUE)
	..()
	addtimer(CALLBACK(src, PROC_REF(beam_setup)), 1 SECONDS)


/mob/living/simple_animal/hostile/ancient_robot_leg/adjustHealth(
	amount = 0,
	updating_health = TRUE,
	blocked = 0,
	damage_type = BRUTE,
	forced = FALSE,
)
	. = STATUS_UPDATE_NONE
	amount *= transfer_rate
	core.adjustBruteLoss(amount)
	fake_hp = clamp(fake_hp - amount, 0, fake_max_hp)
	if(amount && ranged && fake_hp <= 200)
		ranged = FALSE
		visible_message("<span class='danger'>[src]'s turret breaks and pulls back into the leg!</span>")
	if(amount && transfer_rate <= 0.25) //warn that you are not doing much damage
		visible_message("<span class='danger'>[src] looks too damaged to hurt it much more!</span>")
	health_and_snap_check(FALSE)


/mob/living/simple_animal/hostile/ancient_robot_leg/proc/health_and_snap_check(regen = FALSE)
	if(regen)
		fake_hp = min(fake_hp + fake_hp_regen, fake_max_hp)
	transfer_rate = 0.75 * (fake_hp/fake_max_hp)
	if(fake_hp >= 250 && !ranged)
		ranged = TRUE
		visible_message("<span class='danger'>[src]'s turret pops out of it!</span>")
	if(get_dist(get_turf(core),get_turf(src)) <= range)
		return
	else
		forceMove(core.loc)
		core.fix_specific_leg(who_am_i)

/mob/living/simple_animal/hostile/ancient_robot_leg/proc/leg_movement(turf/T, movespeed)
	SSmove_manager.move_towards_legacy(src, T, movespeed, flags = MOVEMENT_LOOP_START_FAST, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)


/mob/living/simple_animal/hostile/ancient_robot_leg/Bump(mob/living/bumped_living)
	. = ..()
	if(!core.charging || istype(bumped_living, /mob/living/simple_animal/hostile/megafauna/ancient_robot) || !isliving(bumped_living))
		return .
	var/turf/living_turf = get_turf(bumped_living)
	bumped_living.visible_message("<span class='danger'>[src] slams into [bumped_living]!</span>", "<span class='userdanger'>[src] tramples you into the ground!</span>")
	forceMove(living_turf)
	var/limb_to_hit = bumped_living.get_organ(pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))
	bumped_living.apply_damage(12.5, BRUTE, limb_to_hit, bumped_living.run_armor_check(limb_to_hit, "melee", null, null, armour_penetration))
	playsound(living_turf, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	shake_camera(bumped_living, 4, 3)
	shake_camera(src, 2, 3)


/mob/living/simple_animal/hostile/ancient_robot_leg/ex_act(severity, target)
	switch(severity)
		if(1)
			adjustBruteLoss(25)

		if(2)
			adjustBruteLoss(10)

		if(3)
			return

/mob/living/simple_animal/hostile/ancient_robot_leg/MeleeAction(patience = TRUE)
	if(core.charging || core.exploding)
		return
	return ..()

/mob/living/simple_animal/hostile/ancient_robot_leg/OpenFire() // This is (idealy) to keep the turrets on the legs from shooting people that are close to the robot. The guns will only shoot if they won't hit the robot, or if the user is between a leg and another leg / robot
	if(core.exploding)
		return
	if(get_dist(target, core) < 3)
		return
	if(prob(33))
		return
	ranged_cooldown_time = (rand(30, 60)) // keeps them not running on the same time
	..()

/mob/living/simple_animal/hostile/ancient_robot_leg/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	SHOULD_CALL_PARENT(FALSE)	// I'm sorry
	playsound(src, 'sound/effects/meteorimpact.ogg', 60, TRUE, 2, TRUE) //turned way down from bubblegum levels due to 4 legs

/mob/living/simple_animal/hostile/ancient_robot_leg/mob_negates_gravity()
	return TRUE

/mob/living/simple_animal/hostile/ancient_robot_leg/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE, jitter_time = 10 SECONDS, stutter_time = 6 SECONDS, stun_duration = 4 SECONDS)
	return FALSE

/obj/projectile/bullet/ancient_robot_bullet
	damage = 8
	damage_type = BRUTE

/obj/projectile/bullet/rock
	name = "thrown rock"
	damage = 25
	damage_type = BRUTE
	icon = 'icons/obj/meteor.dmi'
	icon_state = "small1"

/obj/effect/temp_visual/rock
	name = "floating rock"
	desc = "Might want to focus on dodging, rather than looking at it."
	icon = 'icons/obj/meteor.dmi'
	icon_state = "small1"
	duration = 20

/obj/projectile/energy/shock_revolver/ancient
	damage = 5


/obj/projectile/energy/shock_revolver/ancient/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(istype(mover, /mob/living/simple_animal/hostile/ancient_robot_leg))
		return TRUE


/obj/effect/temp_visual/dragon_swoop/bubblegum/ancient_robot //this is the worst path I have ever made
	icon_state = "target"

/obj/effect/temp_visual/dragon_swoop/bubblegum/ancient_robot/Initialize(mapload, target)
	. = ..()
	new /obj/effect/temp_visual/beam_target(get_turf(src), target) // Yup, we have to make *another* effect since beam doesn't work right with 64x64
	set_light(4, l_color = "#ee2e27", l_on = TRUE)

/obj/effect/temp_visual/beam_target
	duration = 1.6 SECONDS
	var/datum/beam/charge

/obj/effect/temp_visual/beam_target/Initialize(mapload, target)
	. = ..()
	charge = Beam(target, "target_beam", 'icons/effects/effects.dmi', time=1.5 SECONDS, maxdistance=INFINITY, beam_type=/obj/effect/ebeam)


/obj/effect/temp_visual/beam_target/Destroy()
	QDEL_NULL(charge)
	return ..()

/obj/effect/temp_visual/target/ancient

/obj/effect/temp_visual/target/ancient/fall(list/flame_hit)
	var/turf/T = get_turf(src)
	playsound(T,'sound/magic/fleshtostone.ogg', 80, TRUE)
	new /obj/effect/temp_visual/fireball/rock(T)
	SLEEP_CHECK_QDEL(duration)
	if(ismineralturf(T))
		var/turf/simulated/mineral/M = T
		M.attempt_drill()
	playsound(T, 'sound/effects/meteorimpact.ogg', 80, TRUE)
	for(var/mob/living/L in T.contents)
		if(istype(L, /mob/living/simple_animal/hostile/megafauna/ancient_robot))
			continue
		L.adjustBruteLoss(35)
		to_chat(L, "<span class='userdanger'>You're hit by the falling rock!</span>")

/obj/effect/temp_visual/fireball/rock
	icon = 'icons/obj/meteor.dmi'
	icon_state = "small1"


#undef BODY_SHIELD_COOLDOWN_TIME
#undef EXTRA_PLAYER_ANGER_NORMAL_CAP
#undef EXTRA_PLAYER_ANGER_STATION_CAP
#undef BLUESPACE
#undef GRAV
#undef PYRO
#undef FLUX
#undef VORTEX
#undef TOP_RIGHT
#undef TOP_LEFT
#undef BOTTOM_RIGHT
#undef BOTTOM_LEFT
