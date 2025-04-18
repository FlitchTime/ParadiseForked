/mob/living/carbon/alien/humanoid/empress
	name = "alien empress"
	caste = "q"
	maxHealth = 900
	health = 900
	icon_state = "alienq_s"
	status_flags = CANPARALYSE
	mob_size = MOB_SIZE_LARGE
	bubble_icon = "alienroyal"
	large = TRUE
	move_resist = MOVE_FORCE_STRONG
	obj_damage = 100
	time_to_open_doors = 0.2 SECONDS
	attack_damage = 50
	disarm_stamina_damage = 60
	armour_penetration = 60
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	ventcrawler_trait = null
	pressure_resistance = 200 //Because big, stompy xenos should not be blown around like paper.
	antag_datum_type = /datum/antagonist/xenomorph/queen

/mob/living/carbon/alien/humanoid/empress/large
	name = "alien empress"
	caste = "e"
	icon = 'icons/mob/alienhuge.dmi'
	icon_state = "empress_s"
	pixel_x = -32

/mob/living/carbon/alien/humanoid/empress/large/update_icons()
	cut_overlays()

	if(stat == DEAD)
		icon_state = "empress_dead"
	else if(stat == UNCONSCIOUS || body_position == LYING_DOWN)
		icon_state = "empress_sleep"
	else
		icon_state = "empress_s"

	for(var/image/I in overlays_standing)
		add_overlay(I)

	if(blocks_emissive)
		add_overlay(get_emissive_block())

/mob/living/carbon/alien/humanoid/empress/New()
	//there should only be one queen
	for(var/mob/living/carbon/alien/humanoid/empress/E in GLOB.alive_mob_list)
		if(E == src)
			continue
		if(E.stat == DEAD)
			continue
		if(E.client)
			name = "alien grand princess ([rand(1, 999)])"	//if this is too cutesy feel free to change it/remove it.
			break

	real_name = name
	..()


/mob/living/carbon/alien/humanoid/empress/get_caste_organs()
	. = ..()
	. += list(
		/obj/item/organ/internal/xenos/plasmavessel/queen,
		/obj/item/organ/internal/xenos/acidgland/queen,
		/obj/item/organ/internal/xenos/eggsac,
		/obj/item/organ/internal/xenos/resinspinner,
		/obj/item/organ/internal/xenos/neurotoxin
	)


/mob/living/carbon/alien/humanoid/empress/is_strong()
	return TRUE

