/datum/martial_combo/force
	var/requires_active_sword = TRUE
	var/requires_inactive_hilt = FALSE

/datum/martial_combo/force/cleaving_slash
	name = "Рассекающий удар"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "40% шанс отрубить выбранную конечность (кроме головы/груди/паха)."

/datum/martial_combo/force/cleaving_slash/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/martial_art)
	if(!ishuman(target))
		return MARTIAL_COMBO_DONE_BASIC_HIT

	var/zone = user.zone_selected
	if(zone == BODY_ZONE_HEAD || zone == BODY_ZONE_CHEST || zone == BODY_ZONE_PRECISE_GROIN)
		return MARTIAL_COMBO_DONE_BASIC_HIT

	var/mob/living/carbon/human/H = target
	var/obj/item/organ/external/limb = H.get_organ(zone)
	if(!limb || limb.cannot_amputate)
		return MARTIAL_COMBO_DONE_BASIC_HIT

	if(prob(40))
		if(limb.droplimb(FALSE, DROPLIMB_SHARP))
			H.visible_message(
				span_danger("[user] рассекающим ударом отрубает [H] [limb.name]!"),
				span_userdanger("[user] отрубает вам [limb.name]!")
			)
			add_attack_logs(user, target, "Force Arts: cleaving slash dismembered [zone]", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE_BASIC_HIT
