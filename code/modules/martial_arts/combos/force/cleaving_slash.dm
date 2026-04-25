/datum/martial_combo/force

/datum/martial_combo/force/cleaving_slash
	name = "Рассекающий удар"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "40% шанс отрубить выбранную конечность (кроме головы)."

/datum/martial_combo/force/cleaving_slash/New()
	combo_text_override = "[span_red("Harm мечом")], [span_red("Harm мечом")]"

/datum/martial_combo/force/cleaving_slash/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/martial_art)
	if(!ishuman(target))
		return MARTIAL_COMBO_DONE_BASIC_HIT

	var/zone = user.zone_selected
	if(zone in list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH))
		return MARTIAL_COMBO_DONE_BASIC_HIT

	var/mob/living/carbon/human/human_target = target
	var/obj/item/organ/external/limb = human_target.get_organ(zone)
	if(!limb || limb.cannot_amputate)
		return MARTIAL_COMBO_DONE_BASIC_HIT

	if(prob(40))
		if(limb.droplimb(FALSE, DROPLIMB_SHARP))
			human_target.visible_message(
				span_danger("[user] рассекающим ударом отрубает [human_target] [limb.declent_ru(ACCUSATIVE)]!"),
				span_userdanger("[user] отрубает вам [limb.declent_ru(ACCUSATIVE)]!")
			)
			add_attack_logs(user, target, "Force Arts: cleaving slash dismembered [zone]", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE_BASIC_HIT
