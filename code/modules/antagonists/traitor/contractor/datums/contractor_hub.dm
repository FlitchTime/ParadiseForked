/**
  * # Syndicate Hub
  *
  * Describes and manages the contracts and rewards for a single contractor.
  */
/datum/contractor_hub
	// Settings
	/// The number of contracts to generate initially.
	var/num_contracts = 6
	/// How much Contractor Rep to earn per contract completion.
	var/rep_per_completion = 2
	/// Completing every contract at a given difficulty will always result in a sum of TC greater or equal than the difficulty's threshold.
	/// Structure: EXTRACTION_DIFFICULTY_(EASY|MEDIUM|HARD) => number
	var/difficulty_tc_thresholds = list(
		EXTRACTION_DIFFICULTY_EASY = 100,
		EXTRACTION_DIFFICULTY_MEDIUM = 150,
		EXTRACTION_DIFFICULTY_HARD = 200,
	)
	/// Maximum variation a single contract's TC reward can have upon generation.
	/// In other words: final_reward = CEILING((tc_threshold / num_contracts) * (1 + (rand(-100, 100) / 100) * tc_variation), 1)
	var/tc_variation = 0.25
	/// TC reward multiplier if the target was extracted DEAD. Should be a penalty so between 0 and 1.
	/// The final amount is rounded up.
	var/dead_penalty = 0.2
	/// List of purchases that can be done for Rep.
	var/list/datum/rep_purchase/purchases = list(
		/datum/rep_purchase/reroll,
		/datum/rep_purchase/item/pinpointer,
		/datum/rep_purchase/item/baton,
		/datum/rep_purchase/item/baton_cuffup,
		/datum/rep_purchase/item/baton_muteup,
		/datum/rep_purchase/item/baton_focusup,
		/datum/rep_purchase/item/baton_antidropup,
		/datum/rep_purchase/item/fulton,
		/datum/rep_purchase/blackout,
		/datum/rep_purchase/comms_blackout,
		/datum/rep_purchase/item/zippo,
		/datum/rep_purchase/item/balloon,
		/datum/rep_purchase/item/contractor_partner,
		/datum/rep_purchase/item/contractor_hardsuit,
		/datum/rep_purchase/item/spai_kit,
	)
	// Variables
	/// The contractor associated to this hub.
	var/datum/mind/owner = null
	/// The contractor uplink associated to this hub.
	var/obj/item/contractor_uplink/contractor_uplink = null
	/// The current contract in progress.
	var/datum/syndicate_contract/current_contract = null
	/// The contracts offered by the hub.
	var/list/datum/syndicate_contract/contracts = null
	/// List of targets from each contract in [/datum/contractor_hub/var/contracts].
	/// Used to make sure two contracts from the same hub don't have the same target.
	var/list/datum/mind/targets = null
	/// Amount of telecrystals available for redeeming.
	var/reward_tc_available = 0
	/// Total amount of paid out telecrystals since the start.
	var/reward_tc_paid_out = 0
	/// The number of completed contracts.
	var/completed_contracts = 0
	/// Amount of Contractor Rep available for spending.
	var/rep = 0
	/// Current UI page index.
	var/page = HUB_PAGE_CONTRACTS

/datum/contractor_hub/New(datum/mind/O, obj/item/contractor_uplink/U)
	owner = O
	contractor_uplink = U
	// Instantiate purchases
	for(var/i in 1 to length(purchases))
		if(ispath(purchases[i]))
			var/datum/rep_purchase/P = purchases[i]
			purchases[i] = new P
		else
			stack_trace("Expected Hub purchase [purchases[i]] to be a type but it wasn't!")

/datum/contractor_hub/ui_host(mob/user)
	return contractor_uplink

/**
  * Called when the loading animation completes for the first time.
  */
/datum/contractor_hub/proc/first_login(mob/user)
	if(!is_user_authorized(user))
		return
	user.playsound_local(user, 'sound/effects/contractstartup.ogg', 30, FALSE)
	generate_contracts()
	SStgui.update_uis(src)

/**
  * Regenerates a list of contracts for the contractor to take up.
  */
/datum/contractor_hub/proc/generate_contracts()
	contracts = list()
	targets = list()

	var/num_to_generate = min(num_contracts, length(GLOB.data_core.locked))
	if(num_to_generate <= 0) // ?
		return

	// Contract generation
	var/total_earnable_tc = list(0, 0, 0)
	for(var/i in 1 to num_to_generate)
		var/datum/syndicate_contract/C = new(src, owner, targets)
		// Calculate TC reward for each difficulty
		C.reward_tc = list(null, null, null)
		for(var/difficulty in EXTRACTION_DIFFICULTY_EASY to EXTRACTION_DIFFICULTY_HARD)
			var/amount_tc = calculate_tc_reward(num_to_generate, difficulty)
			// Bump up the TC reward a little if it's too close to the lower difficulty's reward
			if(difficulty > EXTRACTION_DIFFICULTY_EASY)
				amount_tc = max(amount_tc, C.reward_tc[difficulty - 1] + (difficulty - 1))
			C.reward_tc[difficulty] = amount_tc
			total_earnable_tc[difficulty] += amount_tc
		// Add to lists
		contracts += C
		targets += C.contract.target

	// Fill the gap if a difficulty doesn't meet the TC threshold
	for(var/difficulty in EXTRACTION_DIFFICULTY_EASY to EXTRACTION_DIFFICULTY_HARD)
		var/total = total_earnable_tc[difficulty]
		var/missing = difficulty_tc_thresholds[difficulty] - total
		if(missing <= 0)
			continue
		// Just add the missing TC to a random contract
		var/datum/syndicate_contract/C = pick(contracts)
		C.reward_tc[difficulty] += missing

/**
  * Generates an amount of TC to be used as a contract reward for the given difficulty.
  *
  * Arguments:
  * * total_contracts - The number of contracts being generated.
  * * difficulty - The difficulty to base the threshold from.
  */
/datum/contractor_hub/proc/calculate_tc_reward(total_contracts, difficulty = EXTRACTION_DIFFICULTY_EASY)
	ASSERT(total_contracts > 0)
	return CEILING((difficulty_tc_thresholds[difficulty] / total_contracts) * (1 + (rand(-100, 100) / 100) * tc_variation), 1)

/**
  * Called when a [/datum/syndicate_contract] has been completed.
  *
  * Arguments:
  * * tc - The final amount of TC to award.
  * * creds - The final amount of credits to award.
  */
/datum/contractor_hub/proc/on_completion(tc, creds)
	completed_contracts++
	reward_tc_available += tc
	rep += rep_per_completion
	owner?.initial_account?.credit(creds, pick(list(
		"ПОЗДРАВЛЯЕМ. Вы стали 10 000-м посетителем сайта SquishySlimes.squish! Прилагаем ваши [creds] кредит[declension_ru(creds, "", "а", "ов")].",
		"Поздравляем вас с выигрышем ставки в последнем матче \"Клоун против Мима\"! На ваш счёт было начислено [creds] кредит[declension_ru(creds, "", "а", "ов")].",
		"Дорогой бенефициар фонда, сообщаем вам, что оплата по просроченному платежу наконец-то завершена, и на ваш счёт зачислено [creds] кредит[declension_ru(creds, "", "а", "ов")].",
		"Привет, брат. Как дела? Ты давно угостил меня пивом, и я хочу отплатить тебе! [creds] кредит[declension_ru(creds, "", "а", "ов")] твои, наслаждайся!",
		"Благодарим вас за инвестицию в размере 500 кредитов! В знак признательности мы зачислили на ваш счёт [creds] кредит[declension_ru(creds, "", "а", "ов")].",
		"Ваш запрос на возврат 100 таблеток \"Доктор Зюзя\" с причиной \"Мне нужно гораздо больше, чем 100 таблеток!\" был принят. Мы зачислили на ваш счёт [creds] кредит[declension_ru(creds, "", "а", "ов")].",
		"Ваш запрос на возврат средств за подписку на WetSkrell.nt был получен. Мы зачислили на ваш счёт [creds] кредит[declension_ru(creds, "", "а", "ов")].",
	)))
	// Clean up
	current_contract = null

/**
  * Gives any unclaimed TC to the given mob.
  *
  * Arguments:
  * * M - The mob to give the TC to.
  */
/datum/contractor_hub/proc/claim_tc(mob/living/M)
	if(reward_tc_available <= 0)
		return

	// Spawn the crystals
	var/obj/item/stack/telecrystal/TC = new(get_turf(M), reward_tc_available)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.put_in_hands(TC))
			to_chat(H, span_notice("Ваш платеж материализуется в ваших руках!"))
		else
			to_chat(M, span_notice("Ваш платеж материализуется на полу."))
	// Update info
	reward_tc_paid_out += reward_tc_available
	reward_tc_available = 0

/**
  * Returns whether the given mob is allowed to connect to the uplink.
  *
  * Arguments:
  * * M - The mob.
  */
/datum/contractor_hub/proc/is_user_authorized(mob/living/carbon/user)
	return user?.mind?.has_antag_datum(/datum/antagonist/contractor)
