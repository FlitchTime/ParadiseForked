/datum/martial_combo/force/hilt_feint
	name = "Финт рукоятью"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_GRAB)
	explaination_text = "Обманывает противника, позволяя взять его в захват."
	var/used_inactive_hilt = FALSE

/datum/martial_combo/force/hilt_feint/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/martial_art)
	if(!target || !user || !ishuman(target))
		return MARTIAL_COMBO_FAIL

	if(!used_inactive_hilt)
		return MARTIAL_COMBO_FAIL

	var/mob/living/carbon/human/H = target

	var/grab_success = H.grabbedby(user, supress_message = TRUE)
	
	if(!grab_success)
		return MARTIAL_COMBO_FAIL

	H.grippedby(user, grab_state_override = GRAB_NECK)
	H.visible_message(
		span_danger("[user] обманывает [H] движением рукояти и мгновенно перехватывает его за шею!"),
		span_userdanger("[user] финтит рукоятью и хватает вас за горло!")
		)


	var/datum/martial_art/force/force_art = martial_art
	if(istype(force_art) && force_art.force_grab_target == H)
		force_art.clear_force_grab(user)

	add_attack_logs(user, H, "Force Arts: hilt feint (neck grab)", ATKLOG_ALL)

	used_inactive_hilt = FALSE 
	return MARTIAL_COMBO_DONE
