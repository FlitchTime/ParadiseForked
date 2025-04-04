/datum/game_mode
	var/list/datum/mind/changelings = list()

/datum/game_mode/changeling
	name = "changeling"
	config_tag = "changeling"
	restricted_jobs = list(JOB_TITLE_AI, JOB_TITLE_CYBORG)
	protected_jobs = list(JOB_TITLE_OFFICER, JOB_TITLE_WARDEN, JOB_TITLE_DETECTIVE, JOB_TITLE_HOS, JOB_TITLE_CAPTAIN, JOB_TITLE_BLUESHIELD, JOB_TITLE_REPRESENTATIVE, JOB_TITLE_PILOT, JOB_TITLE_JUDGE, JOB_TITLE_BRIGDOC, JOB_TITLE_LAWYER, JOB_TITLE_CCOFFICER, JOB_TITLE_CCFIELD, JOB_TITLE_CCSPECOPS, JOB_TITLE_CCSUPREME, JOB_TITLE_SYNDICATE)
	protected_species = list(SPECIES_MACNINEPERSON)
	required_players = 15
	required_enemies = 1
	recommended_enemies = 4
	/// The total number of changelings allowed to be picked.
	var/changeling_amount = 4
	/// A list containing references to the minds of soon-to-be changelings. This is seperate to avoid duplicate entries in the `changelings` list.
	var/list/datum/mind/pre_changelings = list()


/datum/game_mode/changeling/Destroy(force)
	pre_changelings.Cut()
	return ..()


/datum/game_mode/changeling/announce()
	to_chat(world, "<b>The current game mode is - Changeling!</b>")
	to_chat(world, "<b>There are alien changelings on the station. Do not let the changelings succeed!</b>")


/datum/game_mode/changeling/pre_setup()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_changelings = get_players_for_role(ROLE_CHANGELING)

	var/changeling_scale = 10
	if(CONFIG_GET(number/traitor_scaling))
		changeling_scale = CONFIG_GET(number/traitor_scaling)
	changeling_amount = 1 + round(num_players() / changeling_scale)
	add_game_logs("Number of changelings chosen: [changeling_amount]")

	for(var/i in 1 to changeling_amount)
		if(!length(possible_changelings))
			break
		var/datum/mind/changeling = pick_n_take(possible_changelings)
		pre_changelings += changeling
		changeling.restricted_roles = restricted_jobs
		changeling.special_role = SPECIAL_ROLE_CHANGELING

	if(!length(pre_changelings))
		return FALSE

	return TRUE


/datum/game_mode/changeling/post_setup()
	for(var/datum/mind/changeling as anything in pre_changelings)
		changeling.add_antag_datum(/datum/antagonist/changeling)
		pre_changelings -= changeling
	..()


/datum/game_mode/proc/auto_declare_completion_changeling()
	if(length(changelings))
		var/text = "<span style='font-size: 3;'><b>The changelings were:</b></span>"
		for(var/datum/mind/changeling in changelings)
			var/changelingwin = TRUE

			text += "<br>[changeling.get_display_key()] was [changeling.name] ("
			if(changeling.current)
				if(changeling.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
				if(changeling.current.real_name != changeling.name)
					text += " as [changeling.current.real_name]"
			else
				text += "body destroyed"
				changelingwin = FALSE
			text += ")"

			//Removed sanity if(changeling) because we -want- a runtime to inform us that the changelings list is incorrect and needs to be fixed.
			var/datum/antagonist/changeling/cling = changeling?.has_antag_datum(/datum/antagonist/changeling)
			text += "<br><b>Changeling ID:</b> [cling.changelingID]."
			text += "<br><b>Genomes Extracted:</b> [cling.absorbed_count]"

			var/list/all_objectives = changeling.get_all_objectives()

			if(length(all_objectives))
				var/count = 1
				for(var/datum/objective/objective in all_objectives)
					if(objective.check_completion())
						text += "<br><b>Objective #[count]</b>: [objective.explanation_text] <font color='green'><b>Success!</b></font>"
						if(istype(objective, /datum/objective/steal))
							var/datum/objective/steal/steal_objective = objective
							SSblackbox.record_feedback("nested tally", "changeling_steal_objective", 1, list("Steal [steal_objective.steal_target]", "SUCCESS"))
						else
							SSblackbox.record_feedback("nested tally", "changeling_objective", 1, list("[objective.type]", "SUCCESS"))
					else
						text += "<br><b>Objective #[count]</b>: [objective.explanation_text] <font color='red'>Fail.</font>"
						if(istype(objective, /datum/objective/steal))
							var/datum/objective/steal/steal_objective = objective
							SSblackbox.record_feedback("nested tally", "changeling_steal_objective", 1, list("Steal [steal_objective.steal_target]", "FAIL"))
						else
							SSblackbox.record_feedback("nested tally", "changeling_objective", 1, list("[objective.type]", "FAIL"))
						changelingwin = FALSE
					count++

			if(changelingwin)
				text += "<br><font color='green'><b>The changeling was successful!</b></font>"
				SSblackbox.record_feedback("tally", "changeling_success", 1, "SUCCESS")
			else
				text += "<br><font color='red'><b>The changeling has failed.</b></font>"
				SSblackbox.record_feedback("tally", "changeling_success", 1, "FAIL")

		to_chat(world, text)

	return TRUE

