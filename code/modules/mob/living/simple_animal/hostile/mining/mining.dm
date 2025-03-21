//the base mining mob
/mob/living/simple_animal/hostile/asteroid
	vision_range = 2
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	faction = list("mining")
	weather_immunities = list(TRAIT_LAVA_IMMUNE, TRAIT_ASHSTORM_IMMUNE)
	obj_damage = 30
	environment_smash = ENVIRONMENT_SMASH_WALLS
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "strikes"
	status_flags = 0
	a_intent = INTENT_HARM
	AI_delay_max = 0.5 SECONDS
	var/jewelry_loot
	var/crusher_loot
	var/throw_message = "bounces off of"
	var/fromtendril = FALSE
	nightvision = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	mob_size = MOB_SIZE_LARGE
	var/icon_aggro = null
	var/crusher_drop_mod = 25
	var/has_laser_resist = TRUE //If we want the mob to have 66% resist from burn damage projectiles

/mob/living/simple_animal/hostile/asteroid/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		maxbodytemp = INFINITY, \
		minbodytemp = 0, \
		heat_damage = 20, \
	)

/mob/living/simple_animal/hostile/asteroid/Aggro()
	..()
	if(vision_range != aggro_vision_range)
		icon_state = icon_aggro

/mob/living/simple_animal/hostile/asteroid/LoseAggro()
	..()
	if(stat == DEAD)
		return
	icon_state = icon_living

/mob/living/simple_animal/hostile/asteroid/bullet_act(obj/projectile/P)//Reduces damage from most projectiles to curb off-screen kills
	if(!stat)
		Aggro()
	if(P.damage < 30 && P.damage_type != BRUTE && has_laser_resist)
		P.damage = (P.damage / 3)
		visible_message(span_danger("[P] has a reduced effect on [src]!"), projectile_message = TRUE)
	..()

/mob/living/simple_animal/hostile/asteroid/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum) //No floor tiling them to death, wiseguy
	if(isitem(AM))
		var/obj/item/T = AM
		if(!stat)
			Aggro()
		if(T.throwforce <= 20)
			visible_message("<span class='notice'>The [T.name] [throw_message] [src.name]!</span>")
			return
	..()

/mob/living/simple_animal/hostile/asteroid/death(gibbed)
	var/datum/status_effect/crusher_damage/C = has_status_effect(STATUS_EFFECT_CRUSHERDAMAGETRACKING)
	if(C && crusher_loot && prob((C.total_damage/maxHealth) * crusher_drop_mod)) //on average, you'll need to kill 4 creatures before getting the item
		spawn_crusher_loot()
	if(!fromtendril && jewelry_loot)
		if(prob(melee_damage_lower | melee_damage_upper ? 30 : 40)) // Poaching logic - a better reward gained from hunting harmless animals.
			var/obj/gem = new jewelry_loot(loc)
			if(!deathmessage)
				deathmessage = "spits out a [gem.name] as it dies!"
		jewelry_loot = null
		. = ..(gibbed)
		deathmessage = initial(deathmessage)
	else
		..(gibbed)

/mob/living/simple_animal/hostile/asteroid/proc/spawn_crusher_loot()
	butcher_results[crusher_loot] = 1
