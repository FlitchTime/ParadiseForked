/mob/living/simple_animal/hostile/syndicate
	name = "Syndicate Operative"
	desc = "Death to Nanotrasen."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "syndicate"
	icon_living = "syndicate"
	icon_dead = "syndicate_dead" // Does not actually exist. del_on_death.
	icon_gib = "syndicate_gib" // Does not actually exist. del_on_death.
	speak_chance = 0
	turns_per_move = 5
	response_help = "pokes the"
	response_disarm = "shoves the"
	response_harm = "hits the"
	speed = 0
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "бьёт"
	attack_sound = 'sound/weapons/punch1.ogg'
	a_intent = INTENT_HARM
	unsuitable_atmos_damage = 15
	faction = list("syndicate")
	check_friendly_fire = 1
	status_flags = CANPUSH
	loot = list(/obj/effect/mob_spawn/human/corpse/syndicatesoldier)
	del_on_death = 1
	sentience_type = SENTIENCE_OTHER
	footstep_type = FOOTSTEP_MOB_SHOE
	AI_delay_max = 0 SECONDS

///////////////Sword and shield////////////

/mob/living/simple_animal/hostile/syndicate/melee
	melee_damage_lower = 20
	melee_damage_upper = 25
	icon_state = "syndicate_sword"
	icon_living = "syndicate_sword"
	attacktext = "рубит"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	armour_penetration = 28
	status_flags = 0
	loot = list(/obj/effect/mob_spawn/human/corpse/syndicatesoldier, /obj/item/melee/energy/sword/saber/red, /obj/item/shield/energy/syndie)
	var/melee_block_chance = 20
	var/ranged_block_chance = 35


/mob/living/simple_animal/hostile/syndicate/melee/attackby(obj/item/I, mob/user, params)
	if(I.force && prob(melee_block_chance))
		user.do_attack_animation(src)
		visible_message(span_danger("[src] blocks [I] with its shield!"))
		playsound(loc, 'sound/weapons/blade1.ogg', 50, TRUE, -1)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/mob/living/simple_animal/hostile/syndicate/melee/bullet_act(obj/projectile/Proj)
	if(!Proj)
		return
	if(prob(ranged_block_chance))
		visible_message(span_danger("[src] blocks [Proj] with its shield!"), projectile_message = TRUE)
		return FALSE
	return ..()


/mob/living/simple_animal/hostile/syndicate/melee/autogib
	loot = list()//no loot, its gonna delete and gib.

/mob/living/simple_animal/hostile/syndicate/melee/autogib/depot
	name = "Syndicate Operative"
	force_threshold = 6 // Prevents people using punches to bypass eshield
	robust_searching = 1 // Together with stat_attack, ensures dionae/etc that regen are killed properly
	stat_attack = UNCONSCIOUS
	universal_speak = 1
	icon_state = "syndicate_swordonly"
	icon_living = "syndicate_swordonly"
	melee_block_chance = 0
	ranged_block_chance = 0
	del_on_death = 1
	var/area/syndicate_depot/core/depotarea
	var/raised_alert = FALSE
	var/alert_on_death = FALSE
	var/alert_on_timeout = TRUE
	var/alert_on_spacing = TRUE
	var/alert_on_shield_breach = FALSE
	var/seen_enemy = FALSE
	var/seen_enemy_name = null
	var/seen_revived_enemy = FALSE
	var/aggro_cycles = 0
	var/scan_cycles = 0
	var/shield_key = FALSE
	var/turf/spawn_turf

/mob/living/simple_animal/hostile/syndicate/melee/autogib/depot/Initialize(mapload)
	. = ..()
	name = "[name] [pick(GLOB.last_names)]"
	depotarea = get_area(src)
	spawn_turf = get_turf(src)


/mob/living/simple_animal/hostile/syndicate/melee/autogib/depot/ListTargetsLazy()
	// The normal ListTargetsLazy ignores walls, which is very bad in the case of depot mobs. So we override it.
	return ListTargets()

/mob/living/simple_animal/hostile/syndicate/melee/autogib/depot/Aggro()
	. = ..()
	if(!istype(depotarea))
		return
	if(target)
		if(!seen_enemy)
			seen_enemy = TRUE
			if(!ranged)
				playsound(loc, 'sound/weapons/saberon.ogg', 35, 1)
			if(alert_on_shield_breach)
				if(depotarea.shield_list.len)
					raise_alert("[name] reports that [target] is trying to breach the armory shield!")
					alert_on_shield_breach = FALSE
					raised_alert = FALSE
					alert_on_death = TRUE
			if(isliving(target))
				var/mob/living/M = target
				depotarea.list_add(M, depotarea.hostile_list)
				if(M.mind && M.mind.special_role == SPECIAL_ROLE_TRAITOR)
					depotarea.saw_double_agent(M)
			depotarea.declare_started()
		seen_enemy_name = target.name
		if(ismecha(target))
			depotarea.saw_mech(target)
		if(isspacepod(target))
			depotarea.saw_pod(target)
		if(depotarea.list_includes(target, depotarea.dead_list))
			seen_revived_enemy = TRUE
			raise_alert("[name] reports intruder [target] has returned from death!")
			depotarea.list_remove(target, depotarea.dead_list)
		if(!are_zs_connected(src, target) && prob(20))
			// This prevents someone from aggroing a depot mob, then hiding in a locker, perfectly safe, while the mob stands there getting killed by their friends.
			lose_target()

/mob/living/simple_animal/hostile/syndicate/melee/autogib/depot/handle_automated_action()
	. = ..()
	if(!.)
		return
	if(!istype(depotarea))
		return
	if(seen_enemy)
		aggro_cycles++
		if(alert_on_timeout && !raised_alert && aggro_cycles >= 60)
			raise_alert("[name] has reported contact with hostile entity: [seen_enemy_name]")
	if(scan_cycles >= 15)
		scan_cycles = 0
		if(!are_zs_connected(src, spawn_turf))
			if(istype(loc, /obj/structure/closet))
				var/obj/structure/closet/O = loc
				forceMove(get_turf(src))
				visible_message("<span class='boldwarning'>[src] smashes their way out of [O]!</span>")
				qdel(O)
				raise_alert("[src] reported being trapped in a locker.")
				raised_alert = FALSE
				return
			if(alert_on_spacing)
				raise_alert("[src] lost in space.")
			death()
			return
		for(var/mob/living/body in hearers(vision_range, targets_from))
			if(body.stat != DEAD)
				continue
			if(depotarea.list_includes(body, depotarea.dead_list))
				continue
			if(faction_check_mob(body))
				continue
			say("Target [body]... terminated.")
			depotarea.list_add(body, depotarea.dead_list)
			pointed(body)
	else
		scan_cycles++

/mob/living/simple_animal/hostile/syndicate/melee/autogib/depot/AIShouldSleep(list/possible_targets)
	FindTarget(possible_targets)
	return FALSE

/mob/living/simple_animal/hostile/syndicate/melee/autogib/depot/proc/raise_alert(reason)
	if(istype(depotarea) && (!raised_alert || seen_revived_enemy) && !depotarea.used_self_destruct)
		raised_alert = TRUE
		say("Intruder!")
		depotarea.increase_alert(reason)

/mob/living/simple_animal/hostile/syndicate/melee/autogib/depot/death(gibbed)
	if(!istype(depotarea))
		return ..()
	if(alert_on_death)
		if(seen_enemy_name)
			raise_alert("[name] has died in combat with [seen_enemy_name].")
		else
			raise_alert("[name] has died.")
	if(shield_key && depotarea)
		depotarea.shields_key_check()
	if(depotarea)
		depotarea.list_remove(src, depotarea.guard_list)
	new /obj/effect/gibspawner/human(get_turf(src))
	return ..()


/mob/living/simple_animal/hostile/syndicate/melee/autogib/depot/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(.)
		return TRUE
	if(isliving(mover))
		return faction_check_mob(mover)


/mob/living/simple_animal/hostile/syndicate/melee/autogib/depot/officer
	name = "Syndicate Officer"
	icon_state = "syndicate_sword"
	icon_living = "syndicate_sword"
	melee_block_chance = 20
	ranged_block_chance = 35
	alert_on_death = TRUE

/mob/living/simple_animal/hostile/syndicate/melee/autogib/depot/officer/Initialize(mapload)
	. = ..()
	if(prob(50))
		// 50% chance of switching to ranged variant.
		// Designed to counter players taking cover behind reinforced plasmasglass.
		// Does almost no danage in melee, but decent damage at range, and its shots go through glass.
		melee_damage_lower = 10
		melee_damage_upper = 10
		attacktext = "бьёт"
		attack_sound = 'sound/weapons/punch1.ogg'
		ranged = 1
		rapid = 3
		retreat_distance = 3
		minimum_distance = 3
		melee_block_chance = 0
		ranged_block_chance = 0
		icon_state = "syndicate_pistol"
		icon_living = "syndicate_pistol"
		projectiletype = /obj/projectile/beam/laser
		projectilesound = 'sound/weapons/laser.ogg'

/mob/living/simple_animal/hostile/syndicate/melee/autogib/depot/armory
	name = "Syndicate Quartermaster"
	icon_state = "syndicate_stormtrooper_sword"
	icon_living = "syndicate_stormtrooper_sword"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	maxHealth = 200
	health = 200
	melee_block_chance = 40
	alert_on_shield_breach = TRUE

/mob/living/simple_animal/hostile/syndicate/melee/autogib/depot/armory/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		minbodytemp = 0, \
	)

/mob/living/simple_animal/hostile/syndicate/melee/autogib/depot/armory/Initialize(mapload)
	. = ..()
	if(prob(50))
		// 50% chance of switching to extremely dangerous ranged variant
		melee_damage_lower = 10
		melee_damage_upper = 10
		attacktext = "бьёт"
		attack_sound = 'sound/weapons/punch1.ogg'
		ranged = 1
		retreat_distance = 3
		minimum_distance = 3
		melee_block_chance = 0
		ranged_block_chance = 0
		icon_state = "syndicate_stormtrooper_shotgun"
		icon_living = "syndicate_stormtrooper_shotgun"
		projectiletype = /obj/projectile/bullet/sniper/penetrator // Ignores cover.
		projectilesound = 'sound/weapons/gunshots/gunshot_sniper.ogg'
	return INITIALIZE_HINT_LATELOAD

/mob/living/simple_animal/hostile/syndicate/melee/autogib/depot/armory/LateInitialize()
	if(istype(depotarea))
		var/list/key_candidates = list()
		for(var/mob/living/simple_animal/hostile/syndicate/melee/autogib/depot/officer/O in GLOB.alive_mob_list)
			key_candidates += O
		if(key_candidates.len)
			var/mob/living/simple_animal/hostile/syndicate/melee/autogib/depot/officer/O = pick(key_candidates)
			O.shield_key = TRUE
			depotarea.shields_up()


/mob/living/simple_animal/hostile/syndicate/melee/autogib/depot/space
	name = "Syndicate Backup"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	icon_state = "syndicate_space_sword"
	icon_living = "syndicate_space_sword"
	speed = 1
	wander = 0
	alert_on_spacing = FALSE

/mob/living/simple_animal/hostile/syndicate/melee/autogib/depot/space/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		minbodytemp = 0, \
	)

/mob/living/simple_animal/hostile/syndicate/melee/autogib/depot/space/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	return TRUE


/mob/living/simple_animal/hostile/syndicate/melee/space
	name = "Syndicate Commando"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	icon_state = "syndicate_space_sword"
	icon_living = "syndicate_space_sword"
	speed = 1
	loot = list(/obj/effect/mob_spawn/human/corpse/syndicatecommando, /obj/item/melee/energy/sword/saber/red, /obj/item/shield/energy/syndie)

/mob/living/simple_animal/hostile/syndicate/melee/space/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		minbodytemp = 0, \
	)

/mob/living/simple_animal/hostile/syndicate/melee/space/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	return TRUE

/mob/living/simple_animal/hostile/syndicate/ranged
	ranged = 1
	rapid = 2
	retreat_distance = 5
	minimum_distance = 5
	icon_state = "syndicate_smg"
	icon_living = "syndicate_smg"
	projectilesound = 'sound/weapons/gunshots/gunshot.ogg'
	casingtype = /obj/item/ammo_casing/c45
	loot = list(/obj/effect/mob_spawn/human/corpse/syndicatesoldier, /obj/item/gun/projectile/automatic/c20r)

/mob/living/simple_animal/hostile/syndicate/ranged/space
	icon_state = "syndicate_space_smg"
	icon_living = "syndicate_space_smg"
	name = "Syndicate Commando"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	speed = 1
	loot = list(/obj/effect/mob_spawn/human/corpse/syndicatecommando, /obj/item/gun/projectile/automatic/c20r)

/mob/living/simple_animal/hostile/syndicate/ranged/space/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		minbodytemp = 0, \
	)

/mob/living/simple_animal/hostile/syndicate/ranged/space/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	return TRUE

/mob/living/simple_animal/hostile/syndicate/ranged/space/autogib
	loot = list()//gonna gibe, no loot.

/mob/living/simple_animal/hostile/viscerator
	name = "viscerator"
	desc = "A small, twin-bladed machine capable of inflicting very deadly lacerations."
	icon = 'icons/mob/critter.dmi'
	icon_state = "viscerator_attack"
	icon_living = "viscerator_attack"
	pass_flags = PASSTABLE | PASSMOB
	a_intent = INTENT_HARM
	health = 15
	maxHealth = 15
	obj_damage = 0
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "терзает"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	faction = list("syndicate")
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	mob_size = MOB_SIZE_TINY
	bubble_icon = "syndibot"
	gold_core_spawnable = HOSTILE_SPAWN
	del_on_death = 1
	deathmessage = "is smashed into pieces!"
	AI_delay_max = 0 SECONDS

/mob/living/simple_animal/hostile/viscerator/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/swarming)
	AddElement(/datum/element/simple_flying)

/mob/living/simple_animal/hostile/viscerator/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		minbodytemp = 0, \
	)
