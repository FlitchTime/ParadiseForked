/datum/game_mode/vampire/thief
	name = "vampire+thief"
	config_tag = "vampirethief"
	vampire_amount = 2 //hard limit if scaling is turned off
	restricted_jobs = list(JOB_TITLE_AI, JOB_TITLE_CYBORG)
	required_players = 10
	required_enemies = 1	// how many of each type are required
	recommended_enemies = 3
	var/list/datum/mind/pre_thieves = list()


/datum/game_mode/vampire/thief/announce()
	to_chat(world, "<b>The current game mode is - Vampire+Thief!</b>")
	to_chat(world, "<b>На станции зафиксирована деятельность гильдии воров и вампиров. Не дайте вампирам достичь успеха и не допустите кражу дорогостоящего оборудования!</b>")


/datum/game_mode/vampire/thief/pre_setup()
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


/datum/game_mode/vampire/thief/post_setup()
	for(var/datum/mind/thief in pre_thieves)
		thief.add_antag_datum(/datum/antagonist/thief)
	..()

