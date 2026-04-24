/datum/martial_combo/force/hilt_feint
	name = "Финт рукоятью"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_GRAB)
	explaination_text = "Обманывает противника рукоятью меча, захватывая его за шею."

/datum/martial_combo/force/hilt_feint/New()
	combo_text_override = "[span_red("Harm мечом")], [span_blue("Disarm рукоятью меча")], [span_yellow("Grab рукой")]"

/datum/martial_combo/force/hilt_feint/check_combo(step, mob/living/target, mob/living/carbon/human/user, datum/martial_art/force/MA)
	if(!..())
		return FALSE

	if(step == MARTIAL_COMBO_STEP_DISARM)
		if(MA.get_sword_status(user) != SWORD_INACTIVE)
			return FALSE
	return TRUE

/datum/martial_combo/force/hilt_feint/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/martial_art)
	if(!target || !user || !ishuman(target))
		return MARTIAL_COMBO_FAIL

	var/mob/living/carbon/human/human_target = target

	var/grab_success = human_target.grabbedby(user, supress_message = TRUE)
	
	if(!grab_success)
		return MARTIAL_COMBO_FAIL

	human_target.grippedby(user, grab_state_override = GRAB_NECK)
	human_target.visible_message(
		span_danger("[user] обманывает [human_target] движением рукояти и мгновенно перехватывает его за шею!"),
		span_userdanger("[user] финтит рукоятью и хватает вас за горло!")
		)


	var/datum/martial_art/force/force_art = martial_art
	if(istype(force_art) && force_art.force_grab_target == human_target)
		force_art.clear_force_grab(user)

	add_attack_logs(user, human_target, "Force Arts: hilt feint (neck grab)", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
