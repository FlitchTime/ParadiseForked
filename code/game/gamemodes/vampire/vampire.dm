/datum/game_mode
	var/list/datum/mind/vampires = list()
	var/list/datum/mind/vampire_enthralled = list() //those controlled by a vampire

/datum/game_mode/vampire
	name = "vampire"
	config_tag = "vampire"
	restricted_jobs = list(JOB_TITLE_AI, JOB_TITLE_CYBORG)
	protected_jobs = list(JOB_TITLE_OFFICER, JOB_TITLE_WARDEN, JOB_TITLE_DETECTIVE, JOB_TITLE_HOS, JOB_TITLE_CAPTAIN, JOB_TITLE_BLUESHIELD, JOB_TITLE_REPRESENTATIVE, JOB_TITLE_PILOT, JOB_TITLE_JUDGE, JOB_TITLE_CHAPLAIN, JOB_TITLE_BRIGDOC, JOB_TITLE_LAWYER, JOB_TITLE_CCOFFICER, JOB_TITLE_CCFIELD, JOB_TITLE_CCSPECOPS, JOB_TITLE_CCSUPREME, JOB_TITLE_SYNDICATE)
	protected_species = list(SPECIES_MACNINEPERSON, SPECIES_GOLEM_BASIC)
	required_players = 15
	required_enemies = 1
	recommended_enemies = 4
	var/vampire_amount = 4
	///list of minds of soon to be vampires
	var/list/datum/mind/pre_vampires = list()


/datum/game_mode/vampire/announce()
	to_chat(world, "<b>The current game mode is - Vampires!</b>")
	to_chat(world, "<b>There are Bluespace Vampires infesting your fellow crewmates, keep your blood close and neck safe!</b>")


/datum/game_mode/vampire/pre_setup()

	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_vampires = get_players_for_role(ROLE_VAMPIRE)

	var/vampire_scale = 10
	if(CONFIG_GET(number/traitor_scaling))
		vampire_scale = CONFIG_GET(number/traitor_scaling)
	vampire_amount = 1 + round(num_players() / vampire_scale)
	add_game_logs("Number of vampires chosen: [vampire_amount]")

	if(length(possible_vampires))
		for(var/i in 1 to vampire_amount)
			if(!length(possible_vampires))
				break
			var/datum/mind/vampire = pick_n_take(possible_vampires)
			pre_vampires += vampire
			vampire.special_role = SPECIAL_ROLE_VAMPIRE
			vampire.restricted_roles = restricted_jobs

		..()
		return TRUE
	else
		return FALSE


/datum/game_mode/vampire/post_setup()
	for(var/datum/mind/vampire in pre_vampires)
		vampire.add_antag_datum(/datum/antagonist/vampire/new_vampire)
	..()


/datum/game_mode/proc/auto_declare_completion_vampire()
	if(!length(vampires))
		return

	var/text = "<span style='font-size: 2;'><b>The vampires were:</b></span>"
	for(var/datum/mind/vampire in vampires)
		var/traitorwin = TRUE
		var/datum/antagonist/vampire/vamp = vampire.has_antag_datum(/datum/antagonist/vampire)
		text += "<br>[vampire.get_display_key()] was [vampire.name] ("
		if(vampire.current)
			if(vampire.current.stat == DEAD)
				text += "died"
			else
				text += "survived"
				if(vamp.subclass)
					text += " as a [vamp.subclass.name]"
		else
			text += "body destroyed"
		text += ")"

		var/list/all_objectives = vampire.get_all_objectives()

		if(length(all_objectives))//If the traitor had no objectives, don't need to process this.
			var/count = 1
			for(var/datum/objective/objective in all_objectives)
				if(objective.check_completion())
					text += "<br><b>Objective #[count]</b>: [objective.explanation_text] <font color='green'><b>Success!</b></font>"
					if(istype(objective, /datum/objective/steal))
						var/datum/objective/steal/S = objective
						SSblackbox.record_feedback("nested tally", "vampire_steal_objective", 1, list("Steal [S.steal_target]", "SUCCESS"))
					else
						SSblackbox.record_feedback("nested tally", "vampire_objective", 1, list("[objective.type]", "SUCCESS"))
				else
					text += "<br><b>Objective #[count]</b>: [objective.explanation_text] <font color='red'>Fail.</font>"
					if(istype(objective, /datum/objective/steal))
						var/datum/objective/steal/S = objective
						SSblackbox.record_feedback("nested tally", "vampire_steal_objective", 1, list("Steal [S.steal_target]", "FAIL"))
					else
						SSblackbox.record_feedback("nested tally", "vampire_objective", 1, list("[objective.type]", "FAIL"))
					traitorwin = FALSE
				count++

		var/special_role_text
		if(vampire.special_role)
			special_role_text = lowertext(vampire.special_role)
		else
			special_role_text = "antagonist"

		if(traitorwin)
			text += "<br><font color='green'><b>The [special_role_text] was successful!</b></font>"
			SSblackbox.record_feedback("tally", "vampire_success", 1, "SUCCESS")
		else
			text += "<br><font color='red'><b>The [special_role_text] has failed!</b></font>"
			SSblackbox.record_feedback("tally", "vampire_success", 1, "FAIL")
	to_chat(world, text)
	return TRUE


/datum/game_mode/proc/auto_declare_completion_enthralled()
	if(!length(vampire_enthralled))
		return

	var/text = "<span style='font-size: 2;'><b>The Enthralled were:</b></span>"
	for(var/datum/mind/mind in vampire_enthralled)
		text += "<br>[mind.get_display_key()] was [mind.name] ("
		if(mind.current)
			if(mind.current.stat == DEAD)
				text += "died"
			else
				text += "survived"
			if(mind.current.real_name != mind.name)
				text += " as [mind.current.real_name]"
		else
			text += "body destroyed"
		text += ")"
	to_chat(world, text)
	return TRUE

