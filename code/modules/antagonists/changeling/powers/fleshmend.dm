/datum/action/changeling/fleshmend
	name = "Регенерация плоти"
	desc = "Наша плоть начинает быстро регенерировать. Требует 40 химикатов."
	helptext = "Помогает с порезами, ожогами, удушьем, кровопотерей, но не отращивает конечности. Можно использовать будучи бессознания. Можно использовать в низшей форме."
	button_icon_state = "fleshmend"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 2
	chemical_cost = 40
	req_stat = UNCONSCIOUS

/**
 * Starts healing you every second for 10 seconds. Can be used whilst unconscious.
 */
/datum/action/changeling/fleshmend/sting_action(mob/living/user)
	if(user.has_status_effect(STATUS_EFFECT_FLESHMEND))
		user.balloon_alert(user, "эффективность регенерации снижена")
	else
		user.balloon_alert(user, "быстрая регенерация плоти")

	user.apply_status_effect(STATUS_EFFECT_FLESHMEND)
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))

	return TRUE

