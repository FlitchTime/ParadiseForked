SUBSYSTEM_DEF(medals)
	name = "Medals"
	flags = SS_NO_FIRE
	ss_id = "medals"
	var/hub_enabled = FALSE


/datum/controller/subsystem/medals/Initialize()
	if(CONFIG_GET(string/medal_hub_address) && CONFIG_GET(string/medal_hub_password))
		hub_enabled = TRUE
	return SS_INIT_SUCCESS


/datum/controller/subsystem/medals/proc/UnlockMedal(medal, client/player)
	set waitfor = FALSE
	if(!medal || !hub_enabled)
		return
	if(isnull(world.SetMedal(medal, player, CONFIG_GET(string/medal_hub_address), CONFIG_GET(string/medal_hub_password))))
		hub_enabled = FALSE
		add_game_logs("MEDAL ERROR: Could not contact hub to award medal [medal] to player [player.ckey].", player)
		message_admins("Error! Failed to contact hub to award [medal] medal to [player.ckey]!")
		return
	to_chat(player, "<span class='greenannounce'><b>Achievement unlocked: [medal]!</b></span>")


/datum/controller/subsystem/medals/proc/SetScore(score, client/player, increment, force)
	set waitfor = FALSE
	if(!score || !hub_enabled)
		return

	var/list/oldscore = GetScore(score, player, TRUE)
	if(increment)
		if(!oldscore[score])
			oldscore[score] = 1
		else
			oldscore[score] = (text2num(oldscore[score]) + 1)
	else
		oldscore[score] = force

	var/newscoreparam = list2params(oldscore)

	if(isnull(world.SetScores(player.ckey, newscoreparam, CONFIG_GET(string/medal_hub_address), CONFIG_GET(string/medal_hub_password))))
		hub_enabled = FALSE
		add_game_logs("SCORE ERROR: Could not contact hub to set score. Score [score] for player [player.ckey].", player)
		message_admins("Error! Failed to contact hub to set [score] score for [player.ckey]!")

/datum/controller/subsystem/medals/proc/GetScore(score, client/player, returnlist)
	if(!score || !hub_enabled)
		return

	var/scoreget = world.GetScores(player.ckey, score, CONFIG_GET(string/medal_hub_address), CONFIG_GET(string/medal_hub_password))
	if(isnull(scoreget))
		hub_enabled = FALSE
		add_game_logs("SCORE ERROR: Could not contact hub to get score. Score [score] for player [player.ckey].", player)
		message_admins("Error! Failed to contact hub to get score [score] for [player.ckey]!")
		return
	. = params2list(scoreget)
	if(!returnlist)
		return .[score]

/datum/controller/subsystem/medals/proc/CheckMedal(medal, client/player)
	if(!medal || !hub_enabled)
		return

	if(isnull(world.GetMedal(medal, player, CONFIG_GET(string/medal_hub_address), CONFIG_GET(string/medal_hub_password))))
		hub_enabled = FALSE
		add_game_logs("MEDAL ERROR: Could not contact hub to get medal [medal] for player [player.ckey]", player)
		message_admins("Error! Failed to contact hub to get [medal] medal for [player.ckey]!")
		return
	to_chat(player, "[medal] is unlocked")

/datum/controller/subsystem/medals/proc/LockMedal(medal, client/player)
	if(!player || !medal || !hub_enabled)
		return
	var/result = world.ClearMedal(medal, player, CONFIG_GET(string/medal_hub_address), CONFIG_GET(string/medal_hub_password))
	switch(result)
		if(null)
			hub_enabled = FALSE
			add_game_logs("MEDAL ERROR: Could not contact hub to clear medal [medal] for player [player.ckey].", player)
			message_admins("Error! Failed to contact hub to clear [medal] medal for [player.ckey]!")
		if(TRUE)
			message_admins("Medal: [medal] removed for [player.ckey]")
		if(FALSE)
			message_admins("Medal: [medal] was not found for [player.ckey]. Unable to clear.")


/datum/controller/subsystem/medals/proc/ClearScore(client/player)
	if(isnull(world.SetScores(player.ckey, "", CONFIG_GET(string/medal_hub_address), CONFIG_GET(string/medal_hub_password))))
		add_game_logs("MEDAL ERROR: Could not contact hub to clear scores for [player.ckey].", player)
		message_admins("Error! Failed to contact hub to clear scores for [player.ckey]!")
