#define MINER_DASH_RANGE 4

/*

BLOOD-DRUNK MINER

Effectively a highly aggressive miner, the blood-drunk miner has very few attacks but compensates by being highly aggressive.

The blood-drunk miner's attacks are as follows
- If not in KA range, it will rapidly dash at its target
- If in KA range, it will fire its kinetic accelerator
- If in melee range, will rapidly attack, akin to an actual player
- After any of these attacks, may transform its cleaving saw:
	Untransformed, it attacks very rapidly for smaller amounts of damage
	Transformed, it attacks at normal speed for higher damage and cleaves enemies hit

When the blood-drunk miner dies, it leaves behind the cleaving saw it was using and its kinetic accelerator.

Difficulty: Medium

*/

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner
	name = "blood-drunk miner"
	desc = "A miner destined to wander forever, engaged in an endless hunt."
	health = 900
	maxHealth = 900
	icon_state = "miner"
	icon_living = "miner"
	icon = 'icons/mob/lavaland/blood_drunk.dmi'
	light_color = "#E4C7C5"
	speak_emote = list("roars")
	tts_seed = "Chen"
	speed = 3
	move_to_delay = 3
	projectiletype = /obj/projectile/kinetic/miner
	projectilesound = 'sound/weapons/kenetic_accel.ogg'
	ranged = TRUE
	ranged_cooldown_time = 16
	pixel_x = -7
	base_pixel_x = -7
	crusher_loot = list(/obj/item/melee/energy/cleaving_saw, /obj/item/gun/energy/kinetic_accelerator, /obj/item/crusher_trophy/miner_eye, /obj/item/gem/phoron)
	loot = list(/obj/item/melee/energy/cleaving_saw, /obj/item/gun/energy/kinetic_accelerator, /obj/item/gem/phoron)
	wander = FALSE
	del_on_death = TRUE
	blood_volume = BLOOD_VOLUME_NORMAL
	internal_type = /obj/item/gps/internal/miner
	medal_type = BOSS_MEDAL_MINER
	var/obj/item/melee/energy/cleaving_saw/miner_saw
	var/time_until_next_transform = 0
	var/dashing = FALSE
	var/dash_cooldown = 0
	var/dash_cooldown_to_use = 1.5 SECONDS
	var/guidance = FALSE
	var/transform_stop_attack = FALSE // stops the blood drunk miner from attacking after transforming his weapon until the next attack chain
	deathmessage = "falls to the ground, decaying into glowing particles."
	death_sound = "bodyfall"
	footstep_type = FOOTSTEP_MOB_HEAVY
	enraged_loot = /obj/item/disk/fauna_research/blood_drunk_miner
	enraged_unique_loot = /obj/item/clothing/suit/hooded/explorer/blood
	attack_action_types = list(/datum/action/innate/megafauna_attack/dash,
							   /datum/action/innate/megafauna_attack/kinetic_accelerator,
							   /datum/action/innate/megafauna_attack/transform_weapon)

/obj/item/gps/internal/miner
	icon_state = null
	gpstag = "Mysterious Signal"
	desc = "The sweet blood, oh, it sings to me."
	invisibility = INVISIBILITY_ABSTRACT

/* New costume */

/obj/item/clothing/suit/hooded/explorer/blood
	name = "empowered explorer suit"
	desc = "An armoured hood for exploring harsh environments. The sweet blood, oh, it sings to you."
	armor = list("melee" = 55, "bullet" = 35, "laser" = 25, "energy" = 25, "bomb" = 75, "bio" = 100, "rad" = 50, "fire" = 100, "acid" = 100)
	hoodtype = /obj/item/clothing/head/hooded/explorer/blood
	var/obj/effect/proc_holder/spell/blood_suit/blood_spell

/obj/item/clothing/head/hooded/explorer/blood
	name = "empowered explorer hood"
	desc = "An armoured hood for exploring harsh environments. The sweet blood, oh, it sings to you."
	armor = list("melee" = 55, "bullet" = 35, "laser" = 25, "energy" = 25, "bomb" = 75, "bio" = 100, "rad" = 50, "fire" = 100, "acid" = 100)

/obj/item/clothing/suit/hooded/explorer/blood/Initialize(mapload)
	.=..()
	blood_spell = new

/obj/item/clothing/suit/hooded/explorer/blood/Destroy()
	QDEL_NULL(blood_spell)
	return ..()

/obj/effect/proc_holder/spell/blood_suit
	name = "Bloodlust"
	desc = "The sweet blood. My swetty blood I love you!"
	base_cooldown = 20 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	phase_allowed = TRUE
	should_recharge_after_cast = TRUE
	stat_allowed = UNCONSCIOUS
	sound = 'sound/misc/enter_blood.ogg'
	action_icon_state = "bloodcrawl"

/obj/effect/proc_holder/spell/blood_suit/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/blood_suit/cast(list/targets, mob/living/user = usr)
	if(is_mining_level(user.z) || istype(get_area(user), /area/ruin/space/bubblegum_arena))
		if(user.body_position == LYING_DOWN)
			to_chat(user, span_colossus("Fight right now my bloody warrior!"))
		else
			to_chat(user, span_colossus("The blood sings to me. How pretty!"))
		user.say("Oh sweet blood. I hear you singing!")
		user.SetWeakened(0)
		user.SetStunned(0)
		user.SetParalysis(0)
		user.SetSleeping(0)
		user.SetConfused(0)
		user.SetImmobilized(0)
		user.SetKnockdown(0)
		user.adjustStaminaLoss(-100)
		user.set_resting(FALSE, instant = TRUE)
		user.get_up(instant = TRUE)
	else
		to_chat(user, span_colossus("COME BACK TO ME, BLOODY WARRIOR."))
		user.say("I don't hear a blood's sing!")
		user.Stun(5 SECONDS)
		user.Confused(20 SECONDS)
		user.Slowed(20 SECONDS)
		user.Dizzy(20 SECONDS)


/obj/item/clothing/suit/hooded/explorer/blood/equipped(mob/living/carbon/human/user, slot, initial = FALSE)
	. = ..()
	if(!ishuman(user) || slot != ITEM_SLOT_CLOTH_OUTER)
		return .
	LAZYADD(user.mob_spell_list, blood_spell)
	blood_spell.action.Grant(user)


/obj/item/clothing/suit/hooded/explorer/blood/dropped(mob/living/carbon/human/user, slot, silent = FALSE)
	. = ..()
	if(!ishuman(user) || slot != ITEM_SLOT_CLOTH_OUTER)
		return .
	LAZYREMOVE(user.mob_spell_list, blood_spell)
	blood_spell.action.Remove(user)


/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/Initialize(mapload)
	. = ..()
	miner_saw = new /obj/item/melee/energy/cleaving_saw/miner(src)

/datum/action/innate/megafauna_attack/dash
	name = "Dash To Target"
	icon_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "sniper_zoom"
	chosen_message = "<span class='colossus'>You are now dashing to your target.</span>"
	chosen_attack_num = 1

/datum/action/innate/megafauna_attack/kinetic_accelerator
	name = "Fire Kinetic Accelerator"
	icon_icon = 'icons/obj/weapons/energy.dmi'
	button_icon_state = "kineticgun"
	chosen_message = "<span class='colossus'>You are now shooting your kinetic accelerator.</span>"
	chosen_attack_num = 2

/datum/action/innate/megafauna_attack/transform_weapon
	name = "Transform Weapon"
	icon_icon = 'icons/obj/lavaland/artefacts.dmi'
	button_icon_state = "cleaving_saw"
	chosen_message = "<span class='colossus'>You are now transforming your weapon.</span>"
	chosen_attack_num = 3

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/OpenFire()
	if(client)
		switch(chosen_attack)
			if(1)
				dash(target)
			if(2)
				shoot_ka()
			if(3)
				transform_weapon()
		return

	Goto(target, move_to_delay, minimum_distance)
	if(get_dist(src, target) > MINER_DASH_RANGE && dash_cooldown <= world.time)
		dash_attack()
	else
		shoot_ka()
	transform_weapon()

/obj/item/melee/energy/cleaving_saw/miner //nerfed saw because it is very murdery
	force = 6
	force_on = 10


/obj/item/melee/energy/cleaving_saw/miner/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	target.add_status_effect_absorption(
		source = "miner",
		effect_type = list(WEAKEN, STUN, KNOCKDOWN),
		duration = 1 SECONDS,
		priority = INFINITY,
	)
	return ..()


/obj/projectile/kinetic/miner
	damage = 20
	speed = 0.9
	icon_state = "ka_tracer"
	range = MINER_DASH_RANGE

/obj/projectile/kinetic/miner/enraged
	damage = 35


/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/adjustHealth(
	amount = 0,
	updating_health = TRUE,
	blocked = 0,
	damage_type = BRUTE,
	forced = FALSE,
)
	if(!enraged && amount > 0)
		var/adjustment_amount = amount * 0.1
		if(world.time + adjustment_amount > next_move)
			changeNext_move(adjustment_amount) //attacking it interrupts it attacking, but only briefly
	return ..()


/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/death(gibbed)
	if(health > 0)
		return
	new /obj/effect/temp_visual/dir_setting/miner_death(loc, dir)
	return ..()

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	if(dashing || (newloc && newloc.z == z && (islava(newloc) || ischasm(newloc)))) //we're not stupid!
		return FALSE
	. = ..()

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/ex_act(severity)
	if(dash())
		return
	return ..()

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/MeleeAction(patience = TRUE)
	transform_stop_attack = FALSE
	return ..()

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/AttackingTarget()
	if(client)
		transform_stop_attack = FALSE
	if(QDELETED(target) || transform_stop_attack)
		return
	face_atom(target)
	if(isliving(target))
		var/mob/living/L = target
		if(L.stat == DEAD)
			visible_message("<span class='danger'>[src] butchers [L]!</span>",
			"<span class='userdanger'>You butcher [L], restoring your health!</span>")
			if(!is_station_level(z) || client) //NPC monsters won't heal while on station
				if(guidance)
					adjustHealth(-L.maxHealth)
				else
					adjustHealth(-(L.maxHealth * 0.5))
			L.gib()
			return TRUE
	changeNext_move(CLICK_CD_MELEE)
	miner_saw.melee_attack_chain(src, target)
	if(guidance)
		adjustHealth(enraged ? -6 : -2)
	if(prob(50))
		transform_weapon() //Still follows the normal rules for cooldown between swaps.
	return TRUE

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!used_item && !isturf(A))
		used_item = miner_saw
	..()

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/GiveTarget(new_target)
	var/targets_the_same = (new_target == target)
	. = ..()
	if(. && target && !targets_the_same)
		wander = TRUE

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/enrage()
	. = ..()
	if(!.)
		return

	miner_saw = new /obj/item/melee/energy/cleaving_saw(src) //Real saw for real men.
	dash_cooldown_to_use = 0.5 SECONDS //Becomes a teleporting shit.
	ranged_cooldown_time = 5 //They got some cooldown mods.
	projectiletype = /obj/projectile/kinetic/miner/enraged
	maxHealth = 1800
	health = 1800 //Bit more of a challenge.

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/unrage()
	. = ..()
	miner_saw = new /obj/item/melee/energy/cleaving_saw/miner(src)
	dash_cooldown_to_use = initial(dash_cooldown_to_use)
	ranged_cooldown_time = initial(ranged_cooldown_time)
	projectiletype = initial(projectiletype)
	maxHealth = initial(maxHealth)
	health = initial(health)

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/proc/dash_attack()
	INVOKE_ASYNC(src, PROC_REF(dash), target)
	shoot_ka()

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/proc/shoot_ka()
	if(ranged_cooldown <= world.time && get_dist(src, target) <= MINER_DASH_RANGE && !Adjacent(target))
		ranged_cooldown = world.time + ranged_cooldown_time
		visible_message("<span class='danger'>[src] fires the proto-kinetic accelerator!</span>")
		face_atom(target)
		new /obj/effect/temp_visual/dir_setting/firing_effect(loc, dir)
		Shoot(target)
		changeNext_move(CLICK_CD_RANGE)

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/proc/dash(atom/dash_target)
	if(world.time < dash_cooldown)
		return
	var/list/accessable_turfs = list()
	var/self_dist_to_target = 0
	var/turf/own_turf = get_turf(src)
	if(!QDELETED(dash_target))
		self_dist_to_target += get_dist(dash_target, own_turf)
	for(var/turf/O in RANGE_TURFS(MINER_DASH_RANGE, own_turf))
		if(O.density)
			continue
		var/turf_dist_to_target = 0
		if(!QDELETED(dash_target))
			turf_dist_to_target += get_dist(dash_target, O)
		if(get_dist(src, O) >= MINER_DASH_RANGE && turf_dist_to_target <= self_dist_to_target && !islava(O) && !ischasm(O))
			var/valid = TRUE
			for(var/turf/T as anything in get_line(own_turf, O))
				if(T.is_blocked_turf(exclude_mobs = TRUE))
					valid = FALSE
					continue
			if(valid)
				accessable_turfs[O] = turf_dist_to_target
	var/turf/target_turf
	if(!QDELETED(dash_target))
		var/closest_dist = MINER_DASH_RANGE
		for(var/t in accessable_turfs)
			if(accessable_turfs[t] < closest_dist)
				closest_dist = accessable_turfs[t]
		for(var/t in accessable_turfs)
			if(accessable_turfs[t] != closest_dist)
				accessable_turfs -= t
	if(!LAZYLEN(accessable_turfs))
		return
	dash_cooldown = world.time + dash_cooldown_to_use
	target_turf = pick(accessable_turfs)
	var/turf/step_back_turf = get_step(target_turf, get_cardinal_dir(target_turf, own_turf))
	var/turf/step_forward_turf = get_step(own_turf, get_cardinal_dir(own_turf, target_turf))
	new /obj/effect/temp_visual/small_smoke/halfsecond(step_back_turf)
	new /obj/effect/temp_visual/small_smoke/halfsecond(step_forward_turf)
	var/obj/effect/temp_visual/decoy/fading/halfsecond/D = new (own_turf, src)
	forceMove(step_back_turf)
	playsound(own_turf, 'sound/weapons/punchmiss.ogg', 40, 1, -1)
	dashing = TRUE
	alpha = 0
	animate(src, alpha = 255, time = 5)
	SLEEP_CHECK_DEATH(src, 2)
	D.forceMove(step_forward_turf)
	forceMove(target_turf)
	playsound(target_turf, 'sound/weapons/punchmiss.ogg', 40, 1, -1)
	SLEEP_CHECK_DEATH(src, 1)
	dashing = FALSE
	return TRUE

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/proc/transform_weapon()
	if(time_until_next_transform <= world.time)
		miner_saw.transform_cooldown = 0
		miner_saw.transform_weapon(src, TRUE)
		if(!miner_saw.active)
			rapid_melee = 5 // 4 deci cooldown before changes, npcpool subsystem wait is 20, 20/4 = 5
		else
			rapid_melee = 3 // same thing but halved (slightly rounded up)
		transform_stop_attack = TRUE
		icon_state = "miner[miner_saw.active ? "_transformed":""]"
		icon_living = "miner[miner_saw.active ? "_transformed":""]"
		time_until_next_transform = world.time + rand(50, 100)

/obj/effect/temp_visual/dir_setting/miner_death
	icon_state = "miner_death"
	duration = 15

/obj/effect/temp_visual/dir_setting/miner_death/Initialize(mapload, set_dir)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(fade_out))

/obj/effect/temp_visual/dir_setting/miner_death/proc/fade_out()
	var/matrix/M = new
	M.Turn(pick(90, 270))
	var/final_dir = dir
	if(dir & (EAST|WEST)) //Facing east or west
		final_dir = pick(NORTH, SOUTH) //So you fall on your side rather than your face or ass

	animate(src, transform = M, pixel_y = -6, dir = final_dir, time = 2, easing = EASE_IN|EASE_OUT)
	sleep(5)
	animate(src, color = list("#A7A19E", "#A7A19E", "#A7A19E", list(0, 0, 0)), time = 10, easing = EASE_IN, flags = ANIMATION_PARALLEL)
	sleep(4)
	animate(src, alpha = 0, time = 6, easing = EASE_OUT, flags = ANIMATION_PARALLEL)

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/guidance
	guidance = TRUE

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/hunter/AttackingTarget()
	. = ..()
	if(. && prob(enraged ? 40 : 12))
		INVOKE_ASYNC(src, PROC_REF(dash))

#undef MINER_DASH_RANGE
