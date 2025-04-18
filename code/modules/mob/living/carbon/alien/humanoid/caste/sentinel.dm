/mob/living/carbon/alien/humanoid/sentinel
	name = "alien sentinel"
	caste = "s"
	maxHealth = 250
	health = 250
	attack_damage = 25
	time_to_open_doors = 0.2 SECONDS
	icon_state = "aliens_s"
	role_text = "Вы - Часовой. Ваша основная задача - защита гнезда от непрошенных гостей."
	can_evolve = TRUE


/mob/living/carbon/alien/humanoid/sentinel/New()
	if(name == "alien sentinel")
		name = text("alien sentinel ([rand(1, 1000)])")
	real_name = name
	..()
	AddSpell(new /obj/effect/proc_holder/spell/alien_spell/break_vents)
	AddSpell(new /obj/effect/proc_holder/spell/alien_spell/evolve/praetorian)


/mob/living/carbon/alien/humanoid/sentinel/get_caste_organs()
	. = ..()
	. += list(
		/obj/item/organ/internal/xenos/plasmavessel/sentinel,
		/obj/item/organ/internal/xenos/acidgland/sentinel,
		/obj/item/organ/internal/xenos/neurotoxin/sentinel
	)


/mob/living/carbon/alien/humanoid/praetorian
	name = "alien praetorian"
	icon = 'icons/mob/alienlarge.dmi'
	icon_state = "prat_s"
	pixel_x = -16
	maxHealth = 420
	health = 420
	status_flags = CANPARALYSE
	large = TRUE
	move_resist = MOVE_FORCE_STRONG
	caste_movement_delay = 1
	ventcrawler_trait = null
	attack_damage = 30
	disarm_stamina_damage = 34
	armour_penetration = 30
	obj_damage = 80
	time_to_open_doors = 0.2 SECONDS
	environment_smash = ENVIRONMENT_SMASH_WALLS
	role_text = "Вы - Преторианец. Вы являетесь более сильной и неповоротливой версией Часового. Ваша основная задача - защита гнезда от непрошенных гостей."
	var/datum/action/innate/small_sprite_alien/praetorian/action_sprite


/mob/living/carbon/alien/humanoid/praetorian/New()
	if(name == "alien praetorian")
		name = text("alien praetorian ([rand(1, 1000)])")
	real_name = name
	action_sprite = new
	action_sprite.Grant(src)
	..()
	AddSpell(new /obj/effect/proc_holder/spell/alien_spell/break_vents)
	praetorian_count++


/mob/living/carbon/alien/humanoid/praetorian/Destroy()
	if(action_sprite)
		action_sprite.Remove(src)
		action_sprite = null
	return ..()

/mob/living/carbon/alien/humanoid/praetorian/death(gibbed)
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(.)
		praetorian_count--

/mob/living/carbon/alien/humanoid/praetorian/is_strong()
	return TRUE

/mob/living/carbon/alien/humanoid/praetorian/get_caste_organs()
	. = ..()
	. += list(
		/obj/item/organ/internal/xenos/plasmavessel/praetorian,
		/obj/item/organ/internal/xenos/acidgland/praetorian,
		/obj/item/organ/internal/xenos/neurotoxin
	)


/mob/living/carbon/alien/humanoid/praetorian/update_icons()
	cut_overlays()

	if(stat == DEAD)
		icon_state = "prat_dead"
	else if(stat == UNCONSCIOUS || body_position == LYING_DOWN)
		icon_state = "prat_sleep"
	else
		icon_state = "prat_s"

	update_inv_r_hand()
	update_inv_l_hand()
	update_inv_pockets()
	update_fire()

	if(blocks_emissive)
		add_overlay(get_emissive_block())

