/datum/game_mode/traitor/thief
	name = "traitor+thief"
	config_tag = "traitorthief"
	traitors_possible = 2 //hard limit on traitors if scaling is turned off
	restricted_jobs = list(JOB_TITLE_AI, JOB_TITLE_CYBORG)
	required_players = 10
	required_enemies = 1	// how many of each type are required
	recommended_enemies = 3
	var/list/datum/mind/pre_thieves = list()


/datum/game_mode/traitor/thief/announce()
	to_chat(world, "<b>The current game mode is - Traitor+Thief!</b>")
	to_chat(world, "<b>На станции зафиксирована деятельность гильдии воров и агентов Синдиката. Не дайте агентам Синдиката достичь успеха и не допустите кражу дорогостоящего оборудования!</b>")


/datum/game_mode/traitor/thief/pre_setup()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_thieves = get_players_for_role(ROLE_THIEF, list(SPECIES_VOX = 4))

	if(length(possible_thieves))
		var/datum/mind/thief = pick(possible_thieves)
		pre_thieves += thief
		thief.restricted_roles = restricted_jobs
		thief.special_role = SPECIAL_ROLE_THIEF
		return ..()
	else
		return FALSE


/datum/game_mode/traitor/thief/post_setup()
	for(var/datum/mind/thief in pre_thieves)
		thief.add_antag_datum(/datum/antagonist/thief)
	..()

