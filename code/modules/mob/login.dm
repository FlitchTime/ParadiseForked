//handles setting lastKnownIP and computer_id for use by the ban systems as well as checking for multikeying
/mob/proc/update_Login_details()
	//Multikey checks and logging
	lastKnownIP	= client.address
	computer_id	= client.computer_id
	log_access_in(client)
	add_game_logs("OWNERSHIP: Client [key_name(src)] has taken ownership of mob [src]([src.type])")
	if(CONFIG_GET(flag/log_access))
		for(var/mob/M in GLOB.player_list)
			if(M == src)	continue
			if( M.key && (M.key != key) )
				var/matches
				if( (M.lastKnownIP == client.address) )
					matches += "IP ([client.address])"
				if( (M.computer_id == client.computer_id) )
					if(matches)	matches += " and "
					matches += "ID ([client.computer_id])"
					if(!CONFIG_GET(flag/disable_cid_warn_popup))
						spawn() alert("You have logged in already with another key this round, please log out of this one NOW or risk being banned!")
				if(matches)
					if(M.client)
						message_admins("<span style='color: red'><b>Notice: </b><span style='color: #EB4E00'><a href='byond://?src=[usr.UID()];priv_msg=[src.client.ckey]'>[key_name_admin(src)]</a> has the same [matches] as <a href='byond://?src=[usr.UID()];priv_msg=[M.client.ckey]'>[key_name_admin(M)]</a>.</span>")
						log_adminwarn("Notice: [key_name(src)] has the same [matches] as [key_name(M)].")
					else
						message_admins("span style='color: red'><b>Notice: </b><span style='color: #EB4E00'><a href='byond://?src=[usr.UID()];priv_msg=[src.client.ckey]'>[key_name_admin(src)]</a> has the same [matches] as [key_name_admin(M)] (no longer logged in). </span>")
						log_adminwarn("Notice: [key_name(src)] has the same [matches] as [key_name(M)] (no longer logged in).")

/mob/Login()
	if(!client)
		return FALSE

	canon_client = client
	
	add_to_player_list()
	GLOB.left_player_list -= src

	last_known_ckey = ckey
	update_Login_details()
	world.update_status()

	client.images = list()				//remove the images such as AIs being unable to see runes
	client.screen = list()				//remove hud items just in case
	if(client.click_intercept)
		client.click_intercept.quit() // Let's not keep any old click_intercepts

	if(!hud_used)
		create_mob_hud()	 // creating a hud will add it to the client's screen, which can process a disconnect
		if(!client)
			return FALSE

	if(hud_used)
		hud_used.show_hud(hud_used.hud_version)	// see above, this can process a disconnect
		if(!client)
			return FALSE

	next_move = 1

	SSdemo.write_event_line("setmob [client.ckey] \ref[src]")

	add_sight(SEE_SELF)

	// DO NOT CALL PARENT HERE
	// BYOND's internal implementation of login does two things
	// 1: Set statobj to the mob being logged into (We got this covered)
	// 2: And I quote "If the mob has no location, place it near (1,1,1) if possible"
	// See, near is doing an agressive amount of legwork there
	// What it actually does is takes the area that (1,1,1) is in, and loops through all those turfs
	// If you successfully move into one, it stops
	// Because we want Move() to mean standard movements rather then just what byond treats it as (ALL moves)
	// We don't allow moves from nullspace -> somewhere. This means the loop has to iterate all the turfs in (1,1,1)'s area
	// For us, (1,1,1) is a space tile. This means roughly 200,000! calls to Move()
	// You do not want this

	reset_perspective(loc)


	if((ckey in GLOB.de_admins) || (ckey in GLOB.de_mentors))
		add_verb(src, /client/proc/readmin)

	//Clear ability list and update from mob.
	remove_verb(client, GLOB.ability_verbs)

	client.update_active_keybindings()

	//HUD updates (antag hud, etc)
	//readd this mob's HUDs (antag, med, etc)
	reload_huds()

	add_click_catcher()

	if(viewing_alternate_appearances && viewing_alternate_appearances.len)
		for(var/datum/alternate_appearance/AA in viewing_alternate_appearances)
			AA.display_to(list(src))

	update_client_colour(0)
	update_morgue()
	client.init_verbs()

	SEND_SIGNAL(src, COMSIG_MOB_CLIENT_LOGIN, client)
	SEND_SIGNAL(src, COMSIG_MOB_LOGIN)
	return TRUE

