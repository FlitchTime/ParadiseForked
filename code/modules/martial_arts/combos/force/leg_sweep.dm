/datum/martial_combo/force/leg_sweep
	name = "Подсечка"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Cбивает с ног жертву и отрубает ей одну из ног."

/datum/martial_combo/force/leg_sweep/New()
	combo_text_override = "[span_red("Harm мечом")], [span_blue("Disarm мечом")], [span_red("Harm мечом")]"

/datum/martial_combo/force/leg_sweep/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/martial_art)
	if(!ishuman(target))
		return MARTIAL_COMBO_FAIL
	target.Knockdown(4 SECONDS)
	target.Stun(1 SECONDS)

	var/mob/living/carbon/human/human_target = target
	var/obj/item/organ/external/leg = human_target.get_organ(pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
	if(leg?.droplimb(FALSE, DROPLIMB_SHARP))
		target.visible_message(
			span_danger("[user] подсекает [target] и отрубает ногу!"),
			span_userdanger("[user] подсекает вас и отрубает ногу!")
		)
		add_attack_logs(user, target, "Force Arts: leg sweep combo", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE_BASIC_HIT

/datum/martial_combo/force/leg_sweep/check_combo(step, mob/living/target, mob/living/carbon/human/user, datum/martial_art/force/MA)
	if(!..())
		return FALSE

	if(step == MARTIAL_COMBO_STEP_DISARM)
		if(MA.get_sword_status(user) != SWORD_ACTIVE)
			return FALSE
	return TRUE
