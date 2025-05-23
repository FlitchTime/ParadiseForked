#define BUBBLEGUM_SMASH (health <= maxHealth * 0.5 || second_life) // angery
#define BUBBLEGUM_CAN_ENRAGE (enrage_till + (enrage_time * 2) <= world.time)
#define BUBBLEGUM_IS_ENRAGED (enrage_till > world.time)


/*

BUBBLEGUM

Bubblegum spawns randomly wherever a lavaland creature is able to spawn. It is the most powerful slaughter demon in existence.
Bubblegum's footsteps are heralded by shaking booms, proving its tremendous size.

It acts as a melee creature, chasing down and attacking its target while also using different attacks to augment its power

It leaves blood trails behind wherever it goes, its clones do as well.
It tries to strike at its target through any bloodpools under them; if it fails to do that.
If it does warp it will enter an enraged state, becoming immune to all projectiles, becoming much faster, and dealing damage and knockback to anything that gets in the cloud around it.
It may summon clones charging from all sides, one of these charges being bubblegum himself.
It can charge at its target, and also heavily damaging anything directly hit in the charge.
If at half health it will start to charge from all sides with clones.

When Bubblegum dies, it leaves behind a chest that contains:
 1. A H.E.C.K. mining suit
 2. A spellblade that can slice off limbs at range

Difficulty: Hard

*/

/mob/living/simple_animal/hostile/megafauna/bubblegum
	name = "bubblegum"
	desc = "In what passes for a heirarchy among slaughter demons, this one is king."
	health = 2500
	maxHealth = 2500
	attacktext = "кромсает"
	attack_sound = 'sound/misc/demon_attack1.ogg'
	icon_state = "bubblegum"
	icon_living = "bubblegum"
	icon_dead = ""
	friendly = "stares down"
	icon = 'icons/mob/lavaland/96x96megafauna.dmi'
	speak_emote = list("gurgles")
	tts_seed = "Mannoroth"
	armour_penetration = 40
	melee_damage_lower = 40
	melee_damage_upper = 40
	speed = 5
	move_to_delay = 5
	retreat_distance = 5
	minimum_distance = 5
	rapid_melee = 8 // every 1/4 second
	melee_queue_distance = 20 // as far as possible really, need this because of blood warp
	ranged = TRUE
	pixel_x = -32
	base_pixel_x = -32
	del_on_death = TRUE
	crusher_loot = list(/obj/structure/closet/crate/necropolis/bubblegum/crusher)
	loot = list(/obj/structure/closet/crate/necropolis/bubblegum)
	blood_volume = BLOOD_VOLUME_MAXIMUM //BLEED FOR ME
	var/actively_moving = FALSE
	var/turf/charging
	var/enrage_till = 0
	var/enrage_time = 70
	/// Is it on its enraged exclusive second life?
	var/second_life = FALSE
	/// Does it have a portal to the funny second life arena created?
	var/obj/effect/portal/redspace/second_life_portal
	/// Max healing bubblegum can get from being enraged
	var/maximum_enraged_healing = 500
	/// Enraged healing recived
	var/enraged_healing = 0
	internal_type = /obj/item/gps/internal/bubblegum
	medal_type = BOSS_MEDAL_BUBBLEGUM
	score_type = BUBBLEGUM_SCORE
	deathmessage = "sinks into a pool of blood, fleeing the battle. You've won, for now... "
	death_sound = 'sound/misc/enter_blood.ogg'
	attack_action_types = list(/datum/action/innate/megafauna_attack/triple_charge,
							   /datum/action/innate/megafauna_attack/hallucination_charge,
							   /datum/action/innate/megafauna_attack/hallucination_surround,
							   /datum/action/innate/megafauna_attack/blood_warp)

/obj/item/gps/internal/bubblegum
	icon_state = null
	gpstag = "Mysterious Signal"
	desc = "You're not quite sure how a signal can be bloody."
	invisibility = INVISIBILITY_ABSTRACT

/mob/living/simple_animal/hostile/megafauna/bubblegum/Initialize(mapload)
	. = ..()
	if(true_spawn)
		for(var/mob/living/simple_animal/hostile/megafauna/bubblegum/B in GLOB.alive_mob_list)
			if(B != src)
				qdel(src) //There can be only one
				return
	ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, INNATE_TRAIT)
	AddElement(/datum/element/simple_flying)

/datum/action/innate/megafauna_attack/triple_charge
	name = "Triple Charge"
	icon_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "sniper_zoom"
	chosen_message = "<span class='colossus'>You are now triple charging at the target you click on.</span>"
	chosen_attack_num = 1

/datum/action/innate/megafauna_attack/hallucination_charge
	name = "Hallucination Charge"
	icon_icon = 'icons/effects/bubblegum.dmi'
	button_icon_state = "smack ya one"
	chosen_message = "<span class='colossus'>You are now charging with hallucinations at the target you click on.</span>"
	chosen_attack_num = 2

/datum/action/innate/megafauna_attack/hallucination_surround
	name = "Surround Target"
	icon_icon = 'icons/turf/walls/wall.dmi'
	button_icon_state = "wall"
	chosen_message = "<span class='colossus'>You are now surrounding the target you click on with hallucinations.</span>"
	chosen_attack_num = 3

/datum/action/innate/megafauna_attack/blood_warp
	name = "Blood Warp"
	icon_icon = 'icons/effects/blood.dmi'
	button_icon_state = "floor1"
	chosen_message = "<span class='colossus'>You are now warping to blood around your clicked position.</span>"
	chosen_attack_num = 4

/mob/living/simple_animal/hostile/megafauna/bubblegum/enrage()
	. = ..()
	if(!.)
		return

	maxHealth = 2000 //Less health, as a phase 2
	health = 2000
	rapid_melee = 12 //Don't stand still
	vision_range = 18
	loot = list(/obj/effect/decal/cleanable/blood/gibs/bubblegum) //You'll get it in phase 2.
	crusher_loot = list(/obj/effect/decal/cleanable/blood/gibs/bubblegum)
	RegisterSignal(src, COMSIG_HOSTILE_FOUND_TARGET, PROC_REF(i_see_you))
	for(var/mob/living/carbon/human/H in range(18)) //suprise motherfucker bubblegum wakes up fast
		to_chat(H, "<span class='colossus'><b>You DARE to insult my body with these constructs? I curse you as you curse ME!</b></span>")
		FindTarget(list(H)) //From down town with the pile driver

/mob/living/simple_animal/hostile/megafauna/bubblegum/unrage()
	return //They are pissed. Also whoever enraged them is stuck fighting them so, kinda a M.A.D situation.

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/i_see_you(source, target)
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/H = target
	H.apply_status_effect(STATUS_EFFECT_BUBBLEGUM_CURSE, src)
	if(second_life)
		H.clear_fullscreen("bubblegum")
		H.overlay_fullscreen("bubblegum", /atom/movable/screen/fullscreen/fog, 2)

/mob/living/simple_animal/hostile/megafauna/bubblegum/death(gibbed)
	qdel(second_life_portal)
	if(enraged && !second_life)
		var/obj/structure/closet/crate/necropolis/bubblegum/bait/jebait = new /obj/structure/closet/crate/necropolis/bubblegum/bait(get_turf(src))
		var/obj/effect/bubblegum_trigger/great_chest_ahead = new /obj/effect/bubblegum_trigger(jebait, ListTargets())
		new /obj/effect/landmark/spawner/bubblegum_exit(get_turf(src))
		great_chest_ahead.forceMove(jebait)
	if(second_life)
		var/area/A = get_area(src)
		for(var/mob/M in A)
			to_chat(M, "<span class='colossus'><b>YOU FUCK... I... I'll... get you later. Enjoy the last few days of your life...</b></span>")
		new /obj/effect/bubblegum_exit(get_turf(src))
	return ..()

/mob/living/simple_animal/hostile/megafauna/bubblegum/OpenFire(atom/A)
	if(second_life)
		Shoot(A)

	if(charging)
		return

	anger_modifier = clamp(((maxHealth - health)/60),0,20)
	enrage_time = initial(enrage_time) * clamp(anger_modifier / 20, 0.5, 1)
	ranged_cooldown = world.time + 50

	if(client)
		switch(chosen_attack)
			if(1)
				triple_charge()
			if(2)
				hallucination_charge()
			if(3)
				surround_with_hallucinations()
			if(4)
				blood_warp()
		return

	if(!try_bloodattack() || prob(25 + anger_modifier))
		blood_warp()

	if(!BUBBLEGUM_SMASH)
		triple_charge()
	else
		if(prob(25) && enraged)
			hit_up_narsi()
			return
		if(prob(50 + anger_modifier))
			hallucination_charge()
		else
			surround_with_hallucinations()

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/triple_charge()
	charge(delay = 9)
	UNTIL_DEATH_CHECK(src, !charging)
	charge(delay = 6)
	UNTIL_DEATH_CHECK(src, !charging)
	charge(delay = 3)
	SetRecoveryTime(15)


/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/hallucination_charge()
	if(!BUBBLEGUM_SMASH || prob(33))
		hallucination_charge_around(times = 6, delay = 12)
		SetRecoveryTime(10)
	else
		hallucination_charge_around(times = 4, delay = 14)
		UNTIL_DEATH_CHECK(src, !charging)
		hallucination_charge_around(times = 4, delay = 12)
		UNTIL_DEATH_CHECK(src, !charging)
		hallucination_charge_around(times = 4, delay = 11)
		UNTIL_DEATH_CHECK(src, !charging)
		triple_charge()
		SetRecoveryTime(20)


/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/surround_with_hallucinations()
	for(var/i = 1 to 5)
		INVOKE_ASYNC(src, PROC_REF(hallucination_charge_around), 2, 8, 2, FALSE, 4)
		if(ismob(target))
			charge(delay = 9)
			UNTIL_DEATH_CHECK(src, !charging)
		else
			SLEEP_CHECK_DEATH(src, 2 SECONDS)
	SetRecoveryTime(20)


#define BUBLEGUM_CHARGE_SPEED 0.4

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/charge(atom/chargeat = target, delay = 5, chargepast = 2)
	if(!chargeat)
		return
	var/turf/chargeturf = get_turf(chargeat)
	if(!chargeturf || chargeturf.z != z)
		return
	var/dir = get_dir(src, chargeturf)
	var/turf/target_turf = get_ranged_target_turf(chargeturf, dir, chargepast)
	if(!target_turf)
		return
	SSmove_manager.stop_looping(src)
	new /obj/effect/temp_visual/dragon_swoop/bubblegum(target_turf)
	charging = target_turf
	actively_moving = FALSE
	INVOKE_ASYNC(src, PROC_REF(DestroySurroundings))
	setDir(dir)
	var/obj/effect/temp_visual/decoy/decoy = new(loc, src)
	animate(decoy, alpha = 0, color = "#FF0000", transform = matrix() * 2, time = 0.3 SECONDS)
	RegisterSignal(src, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_move), override = TRUE)
	SLEEP_CHECK_DEATH(src, delay)
	var/datum/move_loop/new_loop = SSmove_manager.home_onto(src, target_turf, delay = BUBLEGUM_CHARGE_SPEED, timeout = 3 SECONDS, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	if(!new_loop)
		charging = null
		return
	RegisterSignal(new_loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(pre_move), override = TRUE)
	RegisterSignal(new_loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(post_move), override = TRUE)
	RegisterSignal(new_loop, COMSIG_QDELETING, PROC_REF(charge_end), override = TRUE)
	return TRUE

#undef BUBLEGUM_CHARGE_SPEED


/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/on_move(atom/source, atom/new_loc)
	SIGNAL_HANDLER
	if(!actively_moving)
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE
	new /obj/effect/temp_visual/decoy/fading(loc, src)
	INVOKE_ASYNC(src, PROC_REF(DestroySurroundings))


/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/pre_move(datum/source)
	SIGNAL_HANDLER
	actively_moving = TRUE


/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/post_move(datum/source)
	SIGNAL_HANDLER
	actively_moving = FALSE
	if(get_turf(src) == charging)
		qdel(source)


/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/charge_end(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(src, COMSIG_MOVABLE_PRE_MOVE)
	try_bloodattack()
	actively_moving = FALSE
	charging = null


/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/get_mobs_on_blood()
	var/list/targets = ListTargets()
	. = list()
	for(var/mob/living/L in targets)
		var/list/bloodpool = get_pools(get_turf(L), 0)
		if(bloodpool.len && (!faction_check_mob(L) || L.stat == DEAD))
			. += L

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/try_bloodattack()
	var/list/targets = get_mobs_on_blood()
	if(targets.len)
		INVOKE_ASYNC(src, PROC_REF(bloodattack), targets, prob(enraged ? 75 : 50))
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/bloodattack(list/targets, handedness)
	var/mob/living/target_one = pick_n_take(targets)
	var/turf/target_one_turf = get_turf(target_one)
	var/mob/living/target_two
	if(targets.len)
		target_two = pick_n_take(targets)
		var/turf/target_two_turf = get_turf(target_two)
		if(target_two.stat != CONSCIOUS || prob(10))
			bloodgrab(target_two_turf, handedness)
		else
			bloodsmack(target_two_turf, handedness)

	if(target_one)
		var/list/pools = get_pools(get_turf(target_one), 0)
		if(pools.len)
			target_one_turf = get_turf(target_one)
			if(target_one_turf)
				if(target_one.stat != CONSCIOUS || prob(10))
					bloodgrab(target_one_turf, !handedness)
				else
					bloodsmack(target_one_turf, !handedness)

	if(!target_two && target_one)
		var/list/poolstwo = get_pools(get_turf(target_one), 0)
		if(poolstwo.len)
			target_one_turf = get_turf(target_one)
			if(target_one_turf)
				if(target_one.stat != CONSCIOUS || prob(10))
					bloodgrab(target_one_turf, handedness)
				else
					bloodsmack(target_one_turf, handedness)

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/bloodsmack(turf/T, handedness)
	if(handedness)
		new /obj/effect/temp_visual/bubblegum_hands/rightsmack(T)
	else
		new /obj/effect/temp_visual/bubblegum_hands/leftsmack(T)
	SLEEP_CHECK_DEATH(src, 4)
	for(var/mob/living/L in T)
		if(!faction_check_mob(L))
			to_chat(L, "<span class='userdanger'>[src] rends you!</span>")
			playsound(T, attack_sound, 100, TRUE, -1)
			var/limb_to_hit = L.get_organ(pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG, BODY_ZONE_TAIL, BODY_ZONE_WING))
			L.apply_damage(second_life ? 20 : 10, BRUTE, limb_to_hit, L.run_armor_check(limb_to_hit, "melee", null, null, armour_penetration))
	SLEEP_CHECK_DEATH(src, 3)

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/bloodgrab(turf/T, handedness)
	if(handedness)
		new /obj/effect/temp_visual/bubblegum_hands/rightpaw(T)
		new /obj/effect/temp_visual/bubblegum_hands/rightthumb(T)
	else
		new /obj/effect/temp_visual/bubblegum_hands/leftpaw(T)
		new /obj/effect/temp_visual/bubblegum_hands/leftthumb(T)
	SLEEP_CHECK_DEATH(src, 6)
	for(var/mob/living/L in T)
		if(!faction_check_mob(L))
			if(L.stat != CONSCIOUS)
				to_chat(L, "<span class='userdanger'>[src] drags you through the blood!</span>")
				playsound(T, 'sound/misc/enter_blood.ogg', 100, TRUE, -1)
				var/turf/targetturf = get_step(src, dir)
				L.forceMove(targetturf)
				playsound(targetturf, 'sound/misc/exit_blood.ogg', 100, TRUE, -1)
				addtimer(CALLBACK(src, PROC_REF(devour), L), 2)
	SLEEP_CHECK_DEATH(src, 1)

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/hit_up_narsi()
	SetRecoveryTime(20)
	visible_message("<span class='colossus'><b>[pick("[SSticker.cultdat.entity_name], I call on YOU for one of MY favours you owe me!", "[SSticker.cultdat.entity_title1], I call on you for some support...", "Let us see how you like the minions of [SSticker.cultdat.entity_title2]!", "Oh, [SSticker.cultdat.entity_title3] join me in RENDING THIS WHELP APART!")]</b></span>")
	var/list/turfs = list()
	var/constructs = 0
	for(var/turf/T in view(6, target))
		if(T.density)
			continue
		if(T in range(2, target))
			continue
		turfs += T
		var/amount = second_life ? 4 : 3
		while(constructs < amount && length(turfs))
			var/turf/spot = pick_n_take(turfs)
			if(!spot)
				return
			var/mob/living/simple_animal/hostile/construct/wraith/hostile/bubblegum/summon = new /mob/living/simple_animal/hostile/construct/wraith/hostile/bubblegum(spot)
			summon.faction = faction.Copy()
			constructs++

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/blood_warp()
	if(Adjacent(target))
		return FALSE
	var/list/can_jaunt = get_pools(get_turf(src), 1)
	if(!can_jaunt.len)
		return FALSE

	var/list/pools = get_pools(get_turf(target), 5)
	var/list/pools_to_remove = get_pools(get_turf(target), 4)
	pools -= pools_to_remove
	if(!pools.len)
		return FALSE

	var/obj/effect/temp_visual/decoy/DA = new /obj/effect/temp_visual/decoy(loc,src)
	DA.color = "#FF0000"
	var/oldtransform = DA.transform
	DA.transform = matrix()*2
	animate(DA, alpha = 255, color = initial(DA.color), transform = oldtransform, time = 3)
	SLEEP_CHECK_DEATH(src, 3)
	qdel(DA)

	var/obj/effect/decal/cleanable/blood/found_bloodpool
	pools = get_pools(get_turf(target), 5)
	pools_to_remove = get_pools(get_turf(target), 4)
	pools -= pools_to_remove
	if(pools.len)
		shuffle_inplace(pools)
		found_bloodpool = pick(pools)
	if(found_bloodpool)
		visible_message("<span class='danger'>[src] sinks into the blood...</span>")
		playsound(get_turf(src), 'sound/misc/enter_blood.ogg', 100, TRUE, -1)
		forceMove(get_turf(found_bloodpool))
		playsound(get_turf(src), 'sound/misc/exit_blood.ogg', 100, TRUE, -1)
		visible_message("<span class='danger'>And springs back out!</span>")
		blood_enrage()
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/be_aggressive()
	if(BUBBLEGUM_IS_ENRAGED)
		return TRUE
	if(isliving(target))
		var/mob/living/livingtarget = target
		return (livingtarget.stat != CONSCIOUS || livingtarget.body_position == LYING_DOWN)
	return FALSE

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/get_retreat_distance()
	return (be_aggressive() ? null : initial(retreat_distance))

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/get_minimum_distance()
	return (be_aggressive() ? 1 : initial(minimum_distance))

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/update_approach()
	retreat_distance = get_retreat_distance()
	minimum_distance = get_minimum_distance()

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/blood_enrage()
	if(!BUBBLEGUM_CAN_ENRAGE)
		return FALSE
	enrage_till = world.time + enrage_time
	if(enraged && enraged_healing < maximum_enraged_healing && !second_life)
		adjustHealth(-75)
	update_approach()
	change_move_delay(enraged ? 3 : 4) //3 if enraged, 4 otherwise
	var/newcolor = rgb(149, 10, 10)
	add_atom_colour(newcolor, TEMPORARY_COLOUR_PRIORITY)
	var/datum/callback/cb = CALLBACK(src, PROC_REF(blood_enrage_end))
	addtimer(cb, enrage_time)

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/blood_enrage_end(newcolor = rgb(149, 10, 10))
	update_approach()
	change_move_delay()
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, newcolor)

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/change_move_delay(newmove = initial(move_to_delay))
	move_to_delay = newmove
	set_varspeed(move_to_delay)
	handle_automated_action() // need to recheck movement otherwise move_to_delay won't update until the next checking aka will be wrong speed for a bit

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/get_pools(turf/T, range)
	. = list()
	for(var/obj/effect/decal/cleanable/nearby in view(T, range))
		if(nearby.can_bloodcrawl_in())
			. += nearby

/obj/effect/decal/cleanable/blood/bubblegum
	bloodiness = 0

/obj/effect/decal/cleanable/blood/bubblegum/can_bloodcrawl_in()
	return TRUE

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/hallucination_charge_around(times = 4, delay = 9, chargepast = 0, useoriginal = TRUE, radius)
	var/startingangle = rand(1, 360)
	if(!target)
		return
	if(target.z != z)
		return
	var/turf/chargeat = get_turf(target)
	if(!chargeat)
		return
	var/srcplaced = FALSE
	if(!radius)
		radius = times
	for(var/i = 1 to times)
		var/ang = (startingangle + 360/times * i)
		var/turf/place = locate(chargeat.x + cos(ang) * radius, chargeat.y + sin(ang) * radius, chargeat.z)
		if(!place)
			continue
		if(!nest || nest && nest.parent && get_dist(nest.parent, place) <= nest_range)
			if(!srcplaced && useoriginal)
				forceMove(place)
				srcplaced = TRUE
				continue
		var/mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination/hallucination = new(place)
		INVOKE_ASYNC(hallucination, PROC_REF(charge), chargeat, delay, chargepast)

	if(useoriginal)
		INVOKE_ASYNC(src, PROC_REF(charge), chargeat, delay, chargepast)


/mob/living/simple_animal/hostile/megafauna/bubblegum/adjustBruteLoss(
	amount = 0,
	updating_health = TRUE,
	def_zone = null,
	blocked = 0,
	forced = FALSE,
	used_weapon = null,
	sharp = FALSE,
	silent = FALSE,
	affect_robotic = TRUE,
)
	. = ..()
	if(. && prob(25))
		var/obj/effect/decal/cleanable/blood/gibs/bubblegum/B = new /obj/effect/decal/cleanable/blood/gibs/bubblegum(loc)
		if(prob(40))
			step(B, pick(GLOB.cardinal))
		else
			B.setDir(pick(GLOB.cardinal))


/obj/effect/decal/cleanable/blood/gibs/bubblegum
	name = "thick blood"
	desc = "Thick, splattered blood."
	random_icon_states = list("gib3", "gib5", "gib6")
	bloodiness = 20

/obj/effect/decal/cleanable/blood/gibs/bubblegum/can_bloodcrawl_in()
	return TRUE

/mob/living/simple_animal/hostile/megafauna/bubblegum/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!charging)
		..()

/mob/living/simple_animal/hostile/megafauna/bubblegum/AttackingTarget()
	if(!charging)
		. = ..()
		if(.)
			recovery_time = world.time + 20 // can only attack melee once every 2 seconds but rapid_melee gives higher priority

/mob/living/simple_animal/hostile/megafauna/bubblegum/bullet_act(obj/projectile/P)
	if(BUBBLEGUM_IS_ENRAGED)
		visible_message(span_danger("[src] deflects the projectile; [p_they()] can't be hit with ranged weapons while enraged!"), span_userdanger("You deflect the projectile!"), projectile_message = TRUE)
		playsound(src, pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), 300, TRUE)
		return
	..()

/mob/living/simple_animal/hostile/megafauna/bubblegum/ex_act(severity, target)
	if(severity >= EXPLODE_LIGHT)
		return
	severity = EXPLODE_LIGHT // puny mortals
	return ..()


/mob/living/simple_animal/hostile/megafauna/bubblegum/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(istype(mover, /mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination))
		return TRUE


/mob/living/simple_animal/hostile/megafauna/bubblegum/Goto(target, delay, minimum_distance)
	if(!charging)
		return ..()


/mob/living/simple_animal/hostile/megafauna/bubblegum/MoveToTarget(list/possible_targets)
	if(!charging)
		return ..()


/mob/living/simple_animal/hostile/megafauna/bubblegum/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	update_approach()
	if(movement_dir)
		new /obj/effect/decal/cleanable/blood/bubblegum(loc)
	playsound(src, 'sound/effects/meteorimpact.ogg', 200, TRUE, 2, TRUE)
	return ..()


/mob/living/simple_animal/hostile/megafauna/bubblegum/Bump(atom/bumped_atom)
	. = ..()
	if(!charging)
		return .
	if(isturf(bumped_atom) || (isobj(bumped_atom) && bumped_atom.density))
		bumped_atom.ex_act(EXPLODE_HEAVY)
		return .
	if(!isliving(bumped_atom))
		return .
	var/mob/living/bumped_living = bumped_atom
	var/turf/living_turf = get_turf(bumped_living)
	bumped_living.visible_message("<span class='danger'>[src] slams into [bumped_living]!</span>", "<span class='userdanger'>[src] tramples you into the ground!</span>")
	forceMove(living_turf)
	bumped_living.apply_damage(istype(src, /mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination) ? 15 : 30, BRUTE)
	playsound(living_turf, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	shake_camera(bumped_living, 4, 3)
	shake_camera(src, 2, 3)


/mob/living/simple_animal/hostile/megafauna/bubblegum/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(istype(mover, /mob/living/simple_animal/hostile/megafauna/bubblegum)) // hallucinations should not be stopping bubblegum or eachother
		return TRUE


/obj/effect/temp_visual/dragon_swoop/bubblegum
	duration = 15

/obj/effect/temp_visual/bubblegum_hands
	icon = 'icons/effects/bubblegum.dmi'
	duration = 9

/obj/effect/temp_visual/bubblegum_hands/rightthumb
	icon_state = "rightthumbgrab"

/obj/effect/temp_visual/bubblegum_hands/leftthumb
	icon_state = "leftthumbgrab"

/obj/effect/temp_visual/bubblegum_hands/rightpaw
	icon_state = "rightpawgrab"
	layer = BELOW_MOB_LAYER

/obj/effect/temp_visual/bubblegum_hands/leftpaw
	icon_state = "leftpawgrab"
	layer = BELOW_MOB_LAYER

/obj/effect/temp_visual/bubblegum_hands/rightsmack
	icon_state = "rightsmack"

/obj/effect/temp_visual/bubblegum_hands/leftsmack
	icon_state = "leftsmack"

/mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination
	name = "bubblegum's hallucination"
	desc = "Is that really just a hallucination?"
	health = 1
	maxHealth = 1
	alpha = 127.5
	crusher_loot = null
	medal_type = null
	score_type = null
	deathmessage = "Explodes into a pool of blood!"
	death_sound = 'sound/effects/splat.ogg'
	true_spawn = FALSE
	loot = list(/obj/effect/decal/cleanable/blood/gibs/bubblegum)


/mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination/Initialize(mapload)
	. = ..()
	toggle_ai(AI_OFF)


/mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination/charge_end(datum/source)
	. = ..()
	if(!QDELETED(src))
		qdel(src)


/mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination/Destroy()
	new /obj/effect/decal/cleanable/blood(get_turf(src))
	. = ..()


/mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination/Life()
	return


/mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination/adjustBruteLoss(
	amount = 0,
	updating_health = TRUE,
	def_zone = null,
	blocked = 0,
	forced = FALSE,
	used_weapon = null,
	sharp = FALSE,
	silent = FALSE,
	affect_robotic = TRUE,
)
	return STATUS_UPDATE_NONE


/mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination/OpenFire()
	return

/mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination/AttackingTarget()
	return

/mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination/try_bloodattack()
	return

/mob/living/simple_animal/hostile/megafauna/bubblegum/round_2
	desc = "Oh they are PISSED. And quite injured too..."
	health = 750
	maxHealth = 750
	armour_penetration = 75
	second_life = TRUE
	enraged = TRUE
	rapid_melee = 12
	projectiletype = /obj/projectile/magic/arcane_barrage/blood
	projectilesound = 'sound/effects/splat.ogg'
	deathmessage = null
	death_sound = 'sound/hallucinations/veryfar_noise.ogg'
	ranged = TRUE
	ranged_cooldown_time = 10
	enraged_loot = /obj/item/disk/fauna_research/bubblegum

/mob/living/simple_animal/hostile/megafauna/bubblegum/round_2/Initialize(mapload)
	. = ..()
	for(var/obj/effect/landmark/spawner/bubblegum_exit/E in GLOB.landmarks_list)
		second_life_portal = new /obj/effect/portal/redspace(get_turf(E), get_turf(src), null, 2 HOURS, src, FALSE)
		break
	RegisterSignal(src, COMSIG_HOSTILE_FOUND_TARGET, PROC_REF(i_see_you))
	for(var/mob/living/carbon/human/H in range(20))
		to_chat(H, "<span class='colossus'><b>MY HANDS WILL RELISH ENDING YOU... HERE AND NOW!</b></span>")
		FindTarget(list(H))
