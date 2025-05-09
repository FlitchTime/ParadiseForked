/datum/game_mode
	var/list/datum/mind/thieves = list()


/datum/game_mode/thief
	name = "thief"
	config_tag = "thief"
	restricted_jobs = list(JOB_TITLE_AI, JOB_TITLE_CYBORG)
	protected_jobs = list(JOB_TITLE_OFFICER, JOB_TITLE_WARDEN, JOB_TITLE_DETECTIVE, JOB_TITLE_HOS, JOB_TITLE_CAPTAIN, JOB_TITLE_BLUESHIELD, JOB_TITLE_REPRESENTATIVE, JOB_TITLE_PILOT, JOB_TITLE_JUDGE, JOB_TITLE_BRIGDOC, JOB_TITLE_LAWYER, JOB_TITLE_CCOFFICER, JOB_TITLE_CCFIELD, JOB_TITLE_CCSPECOPS, JOB_TITLE_CCSUPREME, JOB_TITLE_SYNDICATE)
	required_players = 0
	required_enemies = 1
	recommended_enemies = 3
	/// List of minds of soon to be thieves
	var/list/datum/mind/pre_thieves = list()


/datum/game_mode/thief/announce()
	to_chat(world, "<b>The current game mode is - thief!</b>")
	to_chat(world, "<b>На станции зафиксирована деятельность гильдии воров. Не допустите кражу дорогостоящего оборудования!</b>")


/datum/game_mode/thief/pre_setup()

	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_thieves = get_players_for_role(ROLE_THIEF, list(SPECIES_VOX = 4))

	var/thieves_scale = 15
	if(CONFIG_GET(number/traitor_scaling))
		thieves_scale = CONFIG_GET(number/traitor_scaling)
	var/thieves_amount = 1 + round(num_players() / thieves_scale)
	add_game_logs("Number of  thieves chosen: [thieves_amount]")

	if(length(possible_thieves))
		for(var/i in 1 to thieves_amount)
			if(!length(possible_thieves))
				break
			var/datum/mind/thief = pick(possible_thieves)
			listclearduplicates(thief, possible_thieves)
			pre_thieves += thief
			thief.special_role = SPECIAL_ROLE_THIEF
			thief.restricted_roles = restricted_jobs
		..()
		return TRUE
	else
		return FALSE


/datum/game_mode/thief/post_setup()
	for(var/datum/mind/thief in pre_thieves)
		thief.add_antag_datum(/datum/antagonist/thief)
	..()


/datum/game_mode/proc/auto_declare_completion_thief()
	if(!length(thieves))
		return

	var/text = "<span style='font-size: 2;'><b>Воры в розыске:</b></span><br>"
	for(var/datum/mind/thief in thieves)

		text += printplayer(thief) + "<br>"

		var/list/all_objectives = thief.get_all_objectives()
		if(!length(all_objectives))
			continue

		var/count = 1
		var/thiefwin = TRUE
		for(var/datum/objective/objective in all_objectives)
			if(objective.check_completion())
				text += "<br><b>Цель #[count]</b>: [objective.explanation_text] <font color='green'><b>Выполнена!</b></font>"
				SSblackbox.record_feedback("nested tally", "thief_objective", 1, list("[objective.type]", "SUCCESS"))
			else
				text += "<br><b>Цель #[count]</b>: [objective.explanation_text] <font color='red'>Провалена.</font>"
				SSblackbox.record_feedback("nested tally", "thief_objective", 1, list("[objective.type]", "FAIL"))
				thiefwin = FALSE
			count++

		if(thiefwin)
			text += "<br><font color='green'><b>Вор преуспел!</b></font><br>"
			SSblackbox.record_feedback("tally", "thief_success", 1, "SUCCESS")
		else
			text += "<br><font color='red'><b>Вор провалился.</b></font><br>"
			SSblackbox.record_feedback("tally", "thief_success", 1, "FAIL")

	to_chat(world, text)
	return TRUE

