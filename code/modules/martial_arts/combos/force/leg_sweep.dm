/datum/martial_combo/force/leg_sweep
	name = "Подсечка"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "сбивает с ног жертву и отрубает ей одну из ног."

/datum/martial_combo/force/leg_sweep/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/martial_art)
	if(!ishuman(target))
		return MARTIAL_COMBO_FAIL
	target.Knockdown(1 SECONDS)
	target.Stun(1 SECONDS)

	var/mob/living/carbon/human/H = target
	var/obj/item/organ/external/leg = H.get_organ(pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
	leg?.droplimb(FALSE, DROPLIMB_SHARP)

	target.visible_message(
		span_danger("[user] подсекает [target] и отрубает ногу!"),
		span_userdanger("[user] подсекает вас и отрубает ногу!")
	)
	add_attack_logs(user, target, "Force Arts: leg sweep combo", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE_BASIC_HIT
