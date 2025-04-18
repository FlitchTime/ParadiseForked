/mob/living/carbon/alien/larva
	name = "alien larva"
	real_name = "alien larva"
	icon_state = "larva0"
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	attack_damage = 3
	obj_damage = 10
	maxHealth = 25
	health = 25
	density = FALSE
	ventcrawler_trait = TRAIT_VENTCRAWLER_ALWAYS
	rotate_on_lying = FALSE

	tts_seed = "Templar"

	can_evolve = TRUE
	death_message = "с тошнотворным шипением выдыха%(ет,ют)% воздух и пада%(ет,ют)% на пол..."
	death_sound = null

	hud_type = /datum/hud/larva

	role_text = "Как Грудолом, вы ещё очень слабы для того, чтобы оказывать помощь гнезду. Ваша задача: прятаться, есть и набираться сил."

	var/datum/action/innate/hide/alien_larva/hide_action


//This is fine right now, if we're adding organ specific damage this needs to be updated
/mob/living/carbon/alien/larva/New()
	if(name == "alien larva")
		name = "alien larva ([rand(1, 1000)])"
	real_name = name
	regenerate_icons()
	add_language(LANGUAGE_XENOS)
	add_language(LANGUAGE_HIVE_XENOS)
	hide_action = new
	hide_action.Grant(src)
	..()
	AddSpell(new /obj/effect/proc_holder/spell/alien_spell/evolve/larva)


/mob/living/carbon/alien/larva/Destroy()
	if(hide_action)
		hide_action.Remove(src)
		hide_action = null
	return ..()


/mob/living/carbon/alien/larva/get_caste_organs()
	. = ..()
	. += /obj/item/organ/internal/xenos/plasmavessel/larva


/mob/living/carbon/alien/larva/ex_act(severity)
	..()

	var/b_loss = null
	var/f_loss = null
	switch(severity)
		if(1.0)
			gib()
			return

		if(2.0)

			b_loss += 60

			f_loss += 60

			AdjustDeaf(120 SECONDS)

		if(3.0)
			b_loss += 30
			if(prob(50))
				Paralyse(2 SECONDS)
			AdjustDeaf(60 SECONDS)

	take_overall_damage(b_loss, f_loss)


//can't equip anything
/mob/living/carbon/alien/larva/attack_ui(slot_id)
	return


/mob/living/carbon/alien/larva/var/temperature_resistance = T0C+75

// new damage icon system
// now constructs damage icon for each organ from mask * damage field


/mob/living/carbon/alien/larva/start_pulling(atom/movable/pulled_atom, state, force = pull_force, supress_message = FALSE)
	return FALSE


/mob/living/carbon/alien/larva/can_unarmed_attack() //We bite stuff, and our head is always free.
	return TRUE


/mob/living/carbon/alien/larva/update_layer()
	..()
	if(pulledby && loc == pulledby.loc)
		return
	hide_action?.update_layer()

