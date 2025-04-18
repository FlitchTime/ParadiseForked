/datum/game_mode/thief/vampire
	name = "thief+vampire(less)"
	config_tag = "thiefvamp"
	protected_jobs = list(JOB_TITLE_OFFICER, JOB_TITLE_WARDEN, JOB_TITLE_DETECTIVE, JOB_TITLE_HOS, JOB_TITLE_CAPTAIN, JOB_TITLE_BLUESHIELD, JOB_TITLE_REPRESENTATIVE, JOB_TITLE_PILOT, JOB_TITLE_JUDGE, JOB_TITLE_CHAPLAIN, JOB_TITLE_BRIGDOC, JOB_TITLE_LAWYER, JOB_TITLE_CCOFFICER, JOB_TITLE_CCFIELD, JOB_TITLE_CCSPECOPS, JOB_TITLE_CCSUPREME)
	restricted_jobs = list(JOB_TITLE_AI, JOB_TITLE_CYBORG)
	required_players = 15
	required_enemies = 1	// how many of each type are required
	recommended_enemies = 3
	var/protected_species_vampire = list(SPECIES_MACNINEPERSON)
	var/list/datum/mind/pre_vampires = list()

/datum/game_mode/thief/vampire/announce()
	to_chat(world, "<b>The current game mode is - Thief+Vampire!</b>")
	to_chat(world, "<b>На станции зафиксирована деятельность гильдии воров и вампиров. Не дайте вампирам достичь успеха и не допустите кражу дорогостоящего оборудования!</b>")


/datum/game_mode/thief/vampire/pre_setup()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_vampires = get_players_for_role(ROLE_VAMPIRE)

	for(var/mob/new_player/player in GLOB.player_list)
		if((player.mind in possible_vampires) && (player.client.prefs.species in protected_species_vampire))
			possible_vampires -= player.mind

	if(length(possible_vampires))
		var/datum/mind/vampire = pick(possible_vampires)
		pre_vampires += vampire
		vampire.restricted_roles = restricted_jobs
		vampire.special_role = SPECIAL_ROLE_VAMPIRE
		..()
		return TRUE
	else
		return FALSE

/datum/game_mode/thief/vampire/post_setup()
	for(var/datum/mind/vampire in pre_vampires)
		vampire.add_antag_datum(/datum/antagonist/vampire/new_vampire)
	..()
