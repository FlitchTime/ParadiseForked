GLOBAL_VAR_INIT(BSACooldown, 0)
GLOBAL_VAR_INIT(nologevent, 0)

////////////////////////////////
/proc/message_admins(var/msg)
	msg = "<span class=\"admin\"><span class=\"prefix\">ADMIN LOG:</span> <span class=\"message\">[msg]</span></span>"
	for(var/client/C in GLOB.admins)
		if(R_ADMIN & C.holder.rights)
			if(C.prefs && !(C.prefs.toggles & PREFTOGGLE_CHAT_NO_ADMINLOGS))
				to_chat(C, msg, MESSAGE_TYPE_ADMINLOG, confidential = TRUE)

/proc/msg_admin_attack(var/text, var/loglevel)
	if(!GLOB.nologevent)
		var/rendered = "<span class=\"admin\"><span class=\"prefix\">ATTACK:</span> <span class=\"message\">[text]</span></span>"
		for(var/client/C in GLOB.admins)
			if((C.holder.rights & R_ADMIN) && (C.prefs?.atklog <= loglevel))
				to_chat(C, rendered, MESSAGE_TYPE_ATTACKLOG, confidential = TRUE)

/**
 * Sends a message to the staff able to see admin tickets
 * Arguments:
 * msg - The message being send
 * important - If the message is important. If TRUE it will ignore the CHAT_NO_TICKETLOGS preferences,
               send a sound and flash the window. Defaults to FALSE
 */
/proc/message_adminTicket(msg, important = FALSE)
	for(var/client/C in GLOB.admins)
		if((R_ADMIN|R_MOD) & C.holder.rights)
			if(important || (C.prefs && !(C.prefs.toggles & PREFTOGGLE_CHAT_NO_TICKETLOGS)))
				to_chat(C, msg, MESSAGE_TYPE_ADMINPM, confidential = TRUE)
			if(important)
				if(C.prefs?.sound & SOUND_ADMINHELP)
					SEND_SOUND(C, 'sound/effects/adminhelp.ogg')
				window_flash(C)

/**
 * Sends a message to the staff able to see mentor tickets
 * Arguments:
 * msg - The message being send
 * important - If the message is important. If TRUE it will ignore the CHAT_NO_TICKETLOGS preferences,
               send a sound and flash the window. Defaults to FALSE
 */
/proc/message_mentorTicket(msg, important = FALSE)
	for(var/client/C in GLOB.admins)
		if(check_rights(R_ADMIN | R_MENTOR | R_MOD, 0, C.mob))
			if(important || (C.prefs && !(C.prefs.toggles & PREFTOGGLE_CHAT_NO_TICKETLOGS)))
				to_chat(C, msg, MESSAGE_TYPE_MENTORCHAT, confidential = TRUE)
			if(important)
				if(C.prefs?.sound & SOUND_MENTORHELP)
					SEND_SOUND(C, 'sound/effects/adminhelp.ogg')
				window_flash(C)

/proc/admin_ban_mobsearch(var/mob/M, var/ckey_to_find, var/mob/admin_to_notify)
	if(!M || !M.ckey)
		if(ckey_to_find)
			for(var/mob/O in GLOB.mob_list)
				if(O.ckey && O.ckey == ckey_to_find)
					if(admin_to_notify)
						to_chat(admin_to_notify, span_warning("admin_ban_mobsearch: Player [ckey_to_find] is now in mob [O]. Pulling data from new mob."), MESSAGE_TYPE_ADMINLOG, confidential = TRUE)
						return O
			if(admin_to_notify)
				to_chat(admin_to_notify, span_warning("admin_ban_mobsearch: Player [ckey_to_find] does not seem to have any mob, anywhere. This is probably an error."), MESSAGE_TYPE_ADMINLOG, confidential = TRUE)
		else if(admin_to_notify)
			to_chat(admin_to_notify, span_warning("admin_ban_mobsearch: No mob or ckey detected."), MESSAGE_TYPE_ADMINLOG, confidential = TRUE)
	return M

///////////////////////////////////////////////////////////////////////////////////////////////Panels

/datum/admins/proc/show_player_panel(mob/M in GLOB.mob_list)
	set name = "\[Admin\] Show Player Panel"
	set desc="Edit player (respawn, ban, heal, etc)"

	if(!M)
		to_chat(usr, "You seem to be selecting a mob that doesn't exist anymore.", confidential=TRUE)
		return

	if(!check_rights(R_ADMIN|R_MOD))
		return

	if(!check_rights(NONE))
		return

	usr.client.holder.vuap_open_context(M)

/datum/admins/proc/show_old_player_panel(mob/M)

	if(!M)
		to_chat(usr, "You seem to be selecting a mob that doesn't exist anymore.", confidential=TRUE)
		return

	if(!check_rights(R_ADMIN|R_MOD))
		return

	var/body = "<body>Options panel for <b>[M]</b>"
	if(M.client)
		body += " played by <b>[M.client]</b> "
		if(check_rights(R_PERMISSIONS, 0))
			body += "\[<a href='byond://?_src_=holder;editrights=rank;ckey=[M.ckey]'>[M.client.holder ? M.client.holder.rank : "Player"]</a>\] "
		else
			body += "\[[M.client.holder ? M.client.holder.rank : "Player"]\] "
		body += "\[<a href='byond://?_src_=holder;getplaytimewindow=[M.UID()]'>" + M.client.get_exp_type(EXP_TYPE_CREW) + " as [EXP_TYPE_CREW]</a>\]"
		body += "<br>BYOND account registration date: [M.client.byondacc_date || "ERROR"] [M.client.byondacc_age <= CONFIG_GET(number/byond_account_age_threshold) ? "<b>" : ""]([M.client.byondacc_age] days old)[M.client.byondacc_age <= CONFIG_GET(number/byond_account_age_threshold) ? "</b>" : ""]"
		body += "<br>Global Ban DB Lookup: [CONFIG_GET(string/centcom_ban_db_url) ? "<a href='byond://?_src_=holder;open_ccDB=[M.client.ckey]'>Lookup</a>" : "<i>Disabled</i>"]"

		body += "<br>"

	if(isnewplayer(M))
		body += " <b>Hasn't Entered Game</b> "
	else
		body += " \[<a href='byond://?_src_=holder;revive=[M.UID()]'>Heal</a>\] "


	body += "<br><br>\[ "
	body += "<a href='byond://?_src_=holder;open_logging_view=[M.UID()];'>LOGS</a> - "
	body += "<a href='byond://?_src_=vars;Vars=[M.UID()]'>VV</a> - "
	body += "[ADMIN_TP(M,"TP")] - "
	if(M.client)
		body += "<a href='byond://?src=[usr.UID()];priv_msg=[M.client.ckey]'>PM</a> - "
		body += "[ADMIN_SM(M,"SM")] - "
	if(ishuman(M) && M.mind)
		body += "<a href='byond://?_src_=holder;HeadsetMessage=[M.UID()]'>HM</a> - "
	body += "[admin_jump_link(M)] - "
	body += "<a href='byond://?_src_=holder;adminalert=[M.UID()]'>SEND ALERT</a>\]</b><br>"
	body += "<b>Mob type:</b> [M.type]<br>"
	if(M.client)
		if(M.client.prefs.discord_id)
			if(length(M.client.prefs.discord_id) < 32)
				body += "<b>Discord:</b>  <@[M.client.prefs.discord_id]>  <b>[M.client.prefs.discord_name]</b><br>"
			else
				body += "<b>Discord: Привязка не завершена!</b><br>"
		if(M.client.related_accounts_cid.len)
			body += "<b>Related accounts by CID:</b> [jointext(M.client.related_accounts_cid, " - ")]<br>"
		if(M.client.related_accounts_ip.len)
			body += "<b>Related accounts by IP:</b> [jointext(M.client.related_accounts_ip, " - ")]<br><br>"

	if(M.ckey)
		body += "<a href='byond://?_src_=holder;boot2=[M.UID()]'>Kick</a> | "
		body += "<a href='byond://?_src_=holder;newban=[M.UID()];dbbanaddckey=[M.ckey]'>Ban</a> | "
		body += "<a href='byond://?_src_=holder;jobban2=[M.UID()];dbbanaddckey=[M.ckey]'>Jobban</a> | "
		body += "<a href='byond://?_src_=holder;appearanceban=[M.UID()];dbbanaddckey=[M.ckey]'>Appearance Ban</a> | "
		body += "<a href='byond://?_src_=holder;shownoteckey=[M.ckey]'>Notes</a> | "
		body += "<a href='byond://?_src_=holder;geoip=[M.UID()]'>GeoIP</a> | "
		if(CONFIG_GET(string/forum_playerinfo_url))
			body += "<a href='byond://?_src_=holder;webtools=[M.ckey]'>WebInfo</a> | "
	if(M.client)
		if(check_watchlist(M.client.ckey))
			body += "<a href='byond://?_src_=holder;watchremove=[M.ckey]'>Remove from Watchlist</a> | "
			body += "<a href='byond://?_src_=holder;watchedit=[M.ckey]'>Edit Watchlist Reason</a> "
		else
			body += "<a href='byond://?_src_=holder;watchadd=[M.ckey]'>Add to Watchlist</a> "

		body += "| <a href='byond://?_src_=holder;sendtoprison=[M.UID()]'>Prison</a> | "
		body += "\ <a href='byond://?_src_=holder;sendbacktolobby=[M.UID()]'>Send back to Lobby</a> | "
		body += {"<br><b>Mute: </b>
			\[<a href='byond://?_src_=holder;mute=[M.UID()];mute_type=[MUTE_IC]'><span style='color: [check_mute(M.client.ckey, MUTE_IC) ? "#ffaa00" : "#aabbff"];'>IC</span></a> |
			<a href='byond://?_src_=holder;mute=[M.UID()];mute_type=[MUTE_OOC]'><span style='color: [check_mute(M.client.ckey, MUTE_OOC) ? "#ffaa00" : "#aabbff"];'>OOC</span></a> |
			<a href='byond://?_src_=holder;mute=[M.UID()];mute_type=[MUTE_PRAY]'><span style='color: [check_mute(M.client.ckey, MUTE_PRAY) ? "#ffaa00" : "#aabbff"];'>PRAY</span></a> |
			<a href='byond://?_src_=holder;mute=[M.UID()];mute_type=[MUTE_ADMINHELP]'><span style='color: [check_mute(M.client.ckey, MUTE_ADMINHELP) ? "#ffaa00" : "#aabbff"];'>ADMINHELP</span></a> |
			<a href='byond://?_src_=holder;mute=[M.UID()];mute_type=[MUTE_DEADCHAT]'><span style='color: [check_mute(M.client.ckey, MUTE_DEADCHAT) ?"#ffaa00" : "#aabbff"];'>DEADCHAT</span></a> |
			<a href='byond://?_src_=holder;mute=[M.UID()];mute_type=[MUTE_TTS]'><span style='color: [check_mute(M.client.ckey, MUTE_TTS)?"#ffaa00":"#aabbff"];'>TTS</span></a> |
			<a href='byond://?_src_=holder;mute=[M.UID()];mute_type=[MUTE_EMOTE]'><span style='color: [check_mute(M.client.ckey, MUTE_EMOTE) ? "#ffaa00" : "#aabbff"];'>EMOTE</span></a>\]
			(<a href='byond://?_src_=holder;mute=[M.UID()];mute_type=[MUTE_ALL]'><span style='color: [check_mute(M.client.ckey, MUTE_ALL) ? "#ffaa00" : "#aabbff"];'>toggle all</span></a>)
		"}
		body += {"<br><b>Mob Manipulation:</b>
			<a href='byond://?_src_=holder;randomizename=[M.UID()]'>Randomize Name</a> |
			<a href='byond://?_src_=holder;userandomname=[M.UID()]'>User Randomize Name</a> |
			<a href='byond://?_src_=holder;eraseflavortext=[M.UID()]'>Erase Flavor Text</a> |
			"}
		if(ishuman(M))
			body += {"
			<a href='byond://?_src_=holder;cma_admin=[M.UID()]'>Mirror UI to Admin</a> |
			<a href='byond://?_src_=holder;cma_self=[M.UID()]'>Mirror UI to Player</a> |
			<a href='byond://?_src_=holder;select_equip=[M.UID()]'>Select Equipment</a> |
			<a href='byond://?_src_=holder;update_mob_sprite=[M.UID()]'>Update Mob Sprite</a> |
			<a href='byond://?_src_=holder;change_voice=[M.UID()]'>Change Voice</a> |
			"}
		if(isliving(M))
			body += {"<a href='byond://?_src_=holder;check_contents=[M.UID()]'>Check Contents</a> |"}
		body += {"
		<a href='byond://?_src_=holder;man_up=[M.UID()]'>Man Up</a> |
		"}


	var/jumptoeye = ""
	if(isAI(M))
		var/mob/living/silicon/ai/A = M
		if(A.client && A.eyeobj) // No point following clientless AI eyes
			jumptoeye = " <b>(<a href='byond://?_src_=holder;jumpto=[A.eyeobj.UID()]'>Eye</a>)</b>"
	body += {"<br><br>
		<a href='byond://?_src_=holder;jumpto=[M.UID()]'><b>Jump to</b></a>[jumptoeye] |
		<a href='byond://?_src_=holder;getmob=[M.UID()]'>Get</a> |
		<a href='byond://?_src_=holder;sendmob=[M.UID()]'>Send To</a>
		<br><br>
		[check_rights(R_ADMIN,0) ? "[ADMIN_TP(M,"Traitor panel")] | " : "" ]
		<a href='byond://?_src_=holder;narrateto=[M.UID()]'>Narrate to</a> |
		[ADMIN_SM(M,"Subtle message")]
	"}

	if(check_rights(R_EVENT, 0))
		body += {" | <a href='byond://?_src_=holder;Bless=[M.UID()]'>Bless</a> | <a href='byond://?_src_=holder;Smite=[M.UID()]'>Smite</a>"}

	if(isLivingSSD(M))
		if(istype(M.loc, /obj/machinery/cryopod))
			body += {" | <a href='byond://?_src_=holder;cryossd=[M.UID()]'>De-Spawn</a> "}
		else
			body += {" | <a href='byond://?_src_=holder;cryossd=[M.UID()]'>Cryo</a> "}

	if(M.client)
		if(!isnewplayer(M))
			body += "<br><br>"
			body += "<b>Transformation:</b>"
			body += "<br>"

			//Monkey
			if(is_monkeybasic(M))
				body += "<b>Monkeyized</b> | "
			else
				body += "<a href='byond://?_src_=holder;monkeyone=[M.UID()]'>Monkeyize</a> | "

			// Gorillas! OOGAS!
			if(istype(M, /mob/living/simple_animal/hostile/gorilla))
				body += "<a href='byond://?_src_=holder;makegorilla=[M.UID()]'>Re-Gorillize</a> | "
			else
				body += "<a href='byond://?_src_=holder;makegorilla=[M.UID()]'>Gorillize</a> | "

			//AI / Cyborg
			if(isAI(M))
				body += "<b>Is an AI</b> "
			else if(ishuman(M))
				body += {"<a href='byond://?_src_=holder;makeai=[M.UID()]'>AI</a> |
					<a href='byond://?_src_=holder;makerobot=[M.UID()]'>Robot</a> |
					<a href='byond://?_src_=holder;makesuper=[M.UID()]'>Superhero</a> |
				"}

			//Simple Animals
			if(isanimal(M))
				body += "<a href='byond://?_src_=holder;makeanimal=[M.UID()]'>Re-Animalize</a> | "
			else
				body += "<a href='byond://?_src_=holder;makeanimal=[M.UID()]'>Animalize</a> | "

			if(istype(M, /mob/dead/observer))
				body += "<a href='byond://?_src_=holder;incarn_ghost=[M.UID()]'>Re-incarnate</a> | "
				body += {"<a href='byond://?_src_=holder;togglerespawnability=[M.UID()]'>Toggle Respawnability</a> | "}

			if(ispAI(M))
				body += "<b>Is a pAI</b> "
			else
				body += "<a href='byond://?_src_=holder;makePAI=[M.UID()]'>Make pAI</a> | "

			// DNA2 - Admin Hax
			if(M.dna && iscarbon(M))
				body += "<br><br>"
				body += "<b>DNA Blocks:</b><br><table border='0'><tr><th>&nbsp;</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th>"
				for(var/block in 1 to DNA_SE_LENGTH)
					if(!((block - 1) % 5))
						body += "</tr><tr><th>[block - 1]</th>"

					body += "<td>"
					var/gene_name = GLOB.assigned_blocks[block]
					if(gene_name)
						var/text_color = "[M.dna.GetSEState(block) ? "#00cc66" : "#ffaa00"]"
						body += "<a href='byond://?_src_=holder;togmutate=[M.UID()];block=[block];version=old;' style='color:[text_color];'>[gene_name]</a><sub>[block]</sub>"
					else
						body += "[block]"
					body += "</td>"
				body += "</tr></table>"

			body += {"<br><br>
				<b>Rudimentary transformation:</b><span style='font-size: 2;'><br>These transformations only create a new mob type and copy stuff over. They do not take into account MMIs and similar mob-specific things. The buttons in 'Transformations' are preferred, when possible.</span><br>
				<a href='byond://?_src_=holder;simplemake=observer;mob=[M.UID()]'>Observer</a> |
				\[ Alien: <a href='byond://?_src_=holder;simplemake=drone;mob=[M.UID()]'>Drone</a>,
				<a href='byond://?_src_=holder;simplemake=hunter;mob=[M.UID()]'>Hunter</a>,
				<a href='byond://?_src_=holder;simplemake=queen;mob=[M.UID()]'>Queen</a>,
				<a href='byond://?_src_=holder;simplemake=sentinel;mob=[M.UID()]'>Sentinel</a>,
				<a href='byond://?_src_=holder;simplemake=larva;mob=[M.UID()]'>Larva</a> \]
				<a href='byond://?_src_=holder;simplemake=human;mob=[M.UID()]'>Human</a>
				\[ slime: <a href='byond://?_src_=holder;simplemake=slime;mob=[M.UID()]'>Baby</a>,
				<a href='byond://?_src_=holder;simplemake=adultslime;mob=[M.UID()]'>Adult</a> \]
				<a href='byond://?_src_=holder;simplemake=monkey;mob=[M.UID()]'>Monkey</a> |
				<a href='byond://?_src_=holder;simplemake=robot;mob=[M.UID()]'>Cyborg</a> |
				<a href='byond://?_src_=holder;simplemake=cat;mob=[M.UID()]'>Cat</a> |
				<a href='byond://?_src_=holder;simplemake=runtime;mob=[M.UID()]'>Runtime</a> |
				<a href='byond://?_src_=holder;simplemake=corgi;mob=[M.UID()]'>Corgi</a> |
				<a href='byond://?_src_=holder;simplemake=ian;mob=[M.UID()]'>Ian</a> |
				<a href='byond://?_src_=holder;simplemake=crab;mob=[M.UID()]'>Crab</a> |
				<a href='byond://?_src_=holder;simplemake=coffee;mob=[M.UID()]'>Coffee</a> |
				\[ Construct: <a href='byond://?_src_=holder;simplemake=constructarmoured;mob=[M.UID()]'>Armoured</a> ,
				<a href='byond://?_src_=holder;simplemake=constructbuilder;mob=[M.UID()]'>Builder</a> ,
				<a href='byond://?_src_=holder;simplemake=constructwraith;mob=[M.UID()]'>Wraith</a> \]
				<a href='byond://?_src_=holder;simplemake=shade;mob=[M.UID()]'>Shade</a>
			"}

	if(M.client)
		body += {"<br><br>
			<b>Other actions:</b>
			<br>
			<a href='byond://?_src_=holder;forcespeech=[M.UID()]'>Forcesay</a> |
			<a href='byond://?_src_=holder;aroomwarp=[M.UID()]'>Admin Room</a> |
			<a href='byond://?_src_=holder;tdome1=[M.UID()]'>Thunderdome 1</a> |
			<a href='byond://?_src_=holder;tdome2=[M.UID()]'>Thunderdome 2</a> |
			<a href='byond://?_src_=holder;tdomeadmin=[M.UID()]'>Thunderdome Admin</a> |
			<a href='byond://?_src_=holder;tdomeobserve=[M.UID()]'>Thunderdome Observer</a> |
			<a href='byond://?_src_=holder;contractor_stop=[M.UID()]'>Stop Syndicate Jail Timer</a> |
			<a href='byond://?_src_=holder;contractor_start=[M.UID()]'>Start Syndicate Jail Timer</a> |
			<a href='byond://?_src_=holder;contractor_release=[M.UID()]'>Release now from Syndicate Jail</a> |
		"}

	body += {"<br></body>
	"}

	var/datum/browser/popup = new(usr, "adminplayeropts", "<div align='center'>Options for [M.key]</div>", 600, 615)
	popup.set_content(body)
	popup.set_window_options("can_close=1;can_minimize=0;can_maximize=0;can_resize=0;titlebar=1;")
	popup.open(TRUE)
	onclose(usr, "adminplayeropts")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Show Player Panel") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!


/datum/player_info/var/author // admin who authored the information
/datum/player_info/var/rank //rank of admin who made the notes
/datum/player_info/var/content // text content of the information
/datum/player_info/var/timestamp // Because this is bloody annoying

#define PLAYER_NOTES_ENTRIES_PER_PAGE 50
/datum/admins/proc/PlayerNotes()
	set category = "Admin.Ban"
	set name = "Player Notes"

	if(!check_rights(R_ADMIN|R_MOD))
		return

	show_note()

/datum/admins/proc/show_player_notes(var/key as text)
	set category = "Admin.Ban"
	set name = "Show Player Notes"

	if(!check_rights(R_ADMIN|R_MOD))
		return

	show_note(key)

/datum/admins/proc/vpn_whitelist()
	set category = "Admin.Ban"
	set name = "VPN Ckey Whitelist"
	if(!check_rights(R_BAN))
		return
	var/key = tgui_input_text(usr, "Enter ckey to add/remove, or leave blank to cancel:", "VPN Whitelist add/remove", max_length = 32)
	if(key)
		vpn_whitelist_panel(key)

/datum/admins/proc/Jobbans()
	if(!check_rights(R_BAN))
		return

	var/dat = {"<b>Job Bans!</b><hr><table>"}
	for(var/t in GLOB.jobban_keylist)
		var/r = t
		if( findtext(r,"##") )
			r = copytext( r, 1, findtext(r,"##") )//removes the description
		dat += text("<tr><td>[t] (<a href='byond://?src=[UID()];removejobban=[r]'>unban</a>)</td></tr>")
	dat += "</table>"
	var/datum/browser/popup = new(usr, "jobban", "Jobban", 400, 400)
	popup.set_content(dat)
	popup.open(FALSE)


/datum/admins/proc/Game()
	if(!check_rights(R_ADMIN))
		return

	var/list/dat = list()
	var/cached_UID = UID()
	dat += "<center>"
	dat += "<p><a href='byond://?src=[cached_UID];c_mode=1'>Change Game Mode</a><br></p>"
	if(GLOB.master_mode == "secret")
		dat += "<p><a href='byond://?src=[cached_UID];f_secret=1'>(Force Secret Mode)</a><br></p>"
	if(GLOB.master_mode == "antag-paradise" || GLOB.secret_force_mode == "antag-paradise")
		dat += "<p><a href='byond://?src=[cached_UID];change_weights=1'>Change Antag Weights</a><br></p>"

	dat += "<hr><br>"
	dat += "<p><a href='byond://?src=[cached_UID];create_object=1'>Create Object</a><br></p>"
	dat += "<p><a href='byond://?src=[cached_UID];quick_create_object=1'>Quick Create Object</a><br></p>"
	dat += "<p><a href='byond://?src=[cached_UID];create_turf=1'>Create Turf</a><br></p>"
	dat += "<p><a href='byond://?src=[cached_UID];create_mob=1'>Create Mob</a></p>"
	if(marked_datum && istype(marked_datum, /atom))
		dat += "<a href='byond://?src=[cached_UID];dupe_marked_datum=1'>Duplicate Marked Datum</a><br>"

	var/datum/browser/popup = new(usr, "game_panel", "<div align='center'>Game Panel</div>", 220, 300)
	popup.set_content(dat.Join(""))
	popup.set_window_options("can_close=1;can_minimize=0;can_maximize=0;can_resize=0;titlebar=1;")
	popup.open()
	return

/////////////////////////////////////////////////////////////////////////////////////////////////admins2.dm merge
//i.e. buttons/verbs


/datum/admins/proc/restart()
	set category = "Server"
	set name = "Restart"
	set desc = "Restarts the world."

	if(!check_rights(R_SERVER))
		return

	// Give an extra popup if they are rebooting a live server
	var/is_live_server = TRUE
	if(usr.client.is_connecting_from_localhost())
		is_live_server = FALSE

	var/list/options = list("Regular Restart", "Hard Restart")
	if(world.TgsAvailable()) // TGS lets you kill the process entirely
		options += "Terminate Process (Kill and restart DD)"

	var/result = input(usr, "Select reboot method", "World Reboot", options[1]) as null|anything in options

	if(is_live_server)
		if(alert(usr, "WARNING: THIS IS A LIVE SERVER, NOT A LOCAL TEST SERVER. DO YOU STILL WANT TO RESTART", "This server is live", "Restart", "Cancel") != "Restart")
			return FALSE

	if(result)
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Reboot World") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!
		var/init_by = "Initiated by [usr.client.holder.fakekey ? "Admin" : usr.key]."
		switch(result)

			if("Regular Restart")
				var/delay = tgui_input_number(usr, "What delay should the restart have (in seconds)?", "Restart Delay", 5)
				if(!delay)
					return FALSE


				// These are pasted each time so that they dont false send if reboot is cancelled
				log_and_message_admins("has initiated a server restart of type [result]")
				SSticker.delay_end = FALSE // We arent delayed anymore
				SSticker.reboot_helper(init_by, "admin reboot - by [usr.key] [usr.client.holder.fakekey ? "(stealth)" : ""]", delay * 10)

			if("Hard Restart")
				log_and_message_admins("has initiated a server restart of type [result]")
				world.Reboot(fast_track = TRUE)

			if("Terminate Process (Kill and restart DD)")
				log_and_message_admins("has initiated a server restart of type [result]")
				world.TgsEndProcess() // Just nuke the entire process if we are royally fucked


/datum/admins/proc/end_round()
	set category = "Server"
	set name = "End Round"
	set desc = "Instantly ends the round and brings up the scoreboard, like shadowlings or wizards dying."

	if(!check_rights(R_SERVER) || SSticker.force_ending)
		return

	var/response = tgui_alert(usr, "Are you sure you want to end the round?", "End Round", list("Yes", "No"))
	if(response != "Yes" || SSticker.force_ending)
		return

	var/announcement = sanitize(tgui_input_text(usr, "What text should players see announcing the round end? You can skip this entirely.", "Specify Announcement Text", "Shift Has Ended!", encode = FALSE))
	if(SSticker.force_ending)
		return

	log_and_message_admins("has admin ended the round[announcement ? " with message: '[announcement]'" : ""]")
	if(announcement)
		to_chat(world, "<span class='warning'><big><b>[announcement]</b></big></span>")
	SSticker.force_ending = TRUE
	SSblackbox.record_feedback("tally", "admin_verb", 1, "End Round") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!
	SSticker.mode_result = "admin ended"


/datum/admins/proc/announce()
	set category = "Admin.Event"
	set name = "Announce"
	set desc = "Announce your desires to the world"

	if(!check_rights(R_ADMIN))
		return

	var/message = tgui_input_text(usr, "Global message to send:", "Admin Announce", null, multiline = TRUE, encode = FALSE)
	if(message)
		if(!check_rights(R_SERVER,0))
			message = adminscrub(message,500)
		message = handleDiscordEmojis(message)
		message = replacetext(message, "\n", "<br>") // required since we're putting it in a <p> tag
		to_chat(world, chat_box_notice("<span class='notice'><b>[usr.client.holder.fakekey ? "Administrator" : usr.key] Announces:</b><br><br><p>[message]</p></span>"))
		log_admin("Announce: [key_name(usr)] : [message]")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Announce") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/datum/admins/proc/toggleooc()
	set category = "Admin.Toggles"
	set desc="Globally Toggles OOC"
	set name="Toggle OOC"

	if(!check_rights(R_ADMIN))
		return

	toggle_ooc()
	log_and_message_admins("toggled OOC.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle OOC") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/datum/admins/proc/togglelooc()
	set category = "Admin.Toggles"
	set desc="Globally Toggles LOOC"
	set name="Toggle LOOC"

	if(!check_rights(R_ADMIN))
		return

	CONFIG_SET(flag/looc_allowed, !CONFIG_GET(flag/looc_allowed))

	if(CONFIG_GET(flag/looc_allowed))
		to_chat(world, "<b>The LOOC channel has been globally enabled!</b>")
	else
		to_chat(world, "<b>The LOOC channel has been globally disabled!</b>")
	log_and_message_admins("toggled LOOC.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle LOOC") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/datum/admins/proc/toggledsay()
	set category = "Admin.Toggles"
	set desc="Globally Toggles DSAY"
	set name="Toggle DSAY"

	if(!check_rights(R_ADMIN))
		return

	CONFIG_SET(flag/dsay_allowed, !CONFIG_GET(flag/dsay_allowed))

	if(CONFIG_GET(flag/dsay_allowed))
		to_chat(world, "<b>Deadchat has been globally enabled!</b>")
	else
		to_chat(world, "<b>Deadchat has been globally disabled!</b>")
	log_and_message_admins("toggled deadchat.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Deadchat") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc

/datum/admins/proc/toggleoocdead()
	set category = "Admin.Toggles"
	set desc="Toggle Dead OOC."
	set name="Toggle Dead OOC"

	if(!check_rights(R_ADMIN))
		return

	CONFIG_SET(flag/dooc_allowed, !(CONFIG_GET(flag/dooc_allowed)))
	if(CONFIG_GET(flag/dooc_allowed))
		to_chat(world, "<b>Dead OOC has been globally enabled!</b>")
	else
		to_chat(world, "<b>Dead OOC has been globally disabled!</b>")
	log_and_message_admins("toggled Dead OOC.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Dead OOC") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/datum/admins/proc/toggleemoji()
	set category = "Admin.Toggles"
	set desc = "Toggle OOC Emoji"
	set name = "Toggle OOC Emoji"

	if(!check_rights(R_ADMIN))
		return
	CONFIG_SET(flag/disable_ooc_emoji, !CONFIG_GET(flag/disable_ooc_emoji))

	log_and_message_admins("toggled OOC Emoji.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle OOC Emoji")

/datum/admins/proc/startnow()
	set category = "Server"
	set desc="Start the round RIGHT NOW"
	set name="Start Now"

	if(!check_rights(R_SERVER))
		return

	if(!SSticker)
		tgui_alert(usr, "Unable to start the game as it is not set up.")
		return

	if(CONFIG_GET(flag/start_now_confirmation))
		if(tgui_alert(usr, "This is a live server. Are you sure you want to start now?", "Start game", list("Yes", "No")) != "Yes")
			return

	if(SSticker.current_state == GAME_STATE_PREGAME || SSticker.current_state == GAME_STATE_STARTUP)
		SSticker.force_start = TRUE
		log_admin("[usr.key] has started the game.")
		var/msg = ""
		if(SSticker.current_state == GAME_STATE_STARTUP)
			msg = " (The server is still setting up, but the round will be started as soon as possible.)"
		message_admins("<span class='darkmblue'>[usr.key] has started the game.[msg]</span>")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Start Game") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!
		return 1
	else
		to_chat(usr, "<span style='color: red;'>Error: Start Now: Game has already started.</span>", confidential=TRUE)
		return

/datum/admins/proc/toggleenter()
	set category = "Server"
	set desc="People can't enter"
	set name="Toggle Entering"

	if(!check_rights(R_SERVER))
		return

	GLOB.enter_allowed = !( GLOB.enter_allowed )
	if(!( GLOB.enter_allowed ))
		to_chat(world, "<b>New players may no longer enter the game.</b>")
	else
		to_chat(world, "<b>New players may now enter the game.</b>")
	log_and_message_admins("toggled new player game entering.")
	world.update_status()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Entering") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/datum/admins/proc/toggleAI()
	set category = "Admin.Toggles"
	set desc="People can't be AI"
	set name="Toggle AI"

	if(!check_rights(R_EVENT))
		return

	CONFIG_SET(flag/allow_ai, !CONFIG_GET(flag/allow_ai))
	if(!CONFIG_GET(flag/allow_ai))
		to_chat(world, "<b>The AI job is no longer chooseable.</b>")
	else
		to_chat(world, "<b>The AI job is chooseable now.</b>")
	log_and_message_admins("toggled AI allowed.")
	world.update_status()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle AI") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/datum/admins/proc/toggleaban()
	set category = "Admin.Toggles"
	set desc="Toggle the ability for players to respawn."
	set name="Toggle Respawn"

	if(!check_rights(R_SERVER))
		return

	GLOB.abandon_allowed = !( GLOB.abandon_allowed )
	if(GLOB.abandon_allowed)
		to_chat(world, "<b>You may now respawn.</b>")
	else
		to_chat(world, "<b>You may no longer respawn :(</b>")
	log_and_message_admins("toggled respawn to [GLOB.abandon_allowed ? "On" : "Off"].")
	world.update_status()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Respawn") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/datum/admins/proc/delay()
	set category = "Server"
	set desc="Delay the game start/end"
	set name="Delay"

	if(!check_rights(R_SERVER))
		return

	if(!SSticker || SSticker.current_state != GAME_STATE_PREGAME)
		SSticker.delay_end = !SSticker.delay_end
		log_and_message_admins("[SSticker.delay_end ? "delayed the round end" : "has made the round end normally"].")
		if(SSticker.delay_end)
			SSticker.real_reboot_time = 0 // Immediately show the "Admin delayed round end" message
		return //alert("Round end delayed", null, null, null, null, null)
	if(SSticker.ticker_going)
		SSticker.ticker_going = FALSE
		SSticker.delay_end = TRUE
		to_chat(world, "<b>The game start has been delayed.</b>")
		log_admin("[key_name(usr)] delayed the game.")
	else
		SSticker.ticker_going = TRUE
		to_chat(world, "<b>The game will start soon.</b>")
		log_admin("[key_name(usr)] removed the delay.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Delay") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

////////////////////////////////////////////////////////////////////////////////////////////////ADMIN HELPER PROCS

/*/proc/is_special_character(mob/M as mob) // returns 1 for specail characters and 2 for heroes of gamemode
	if(!SSticker || !SSticker.mode)
		return 0
	if(!istype(M))
		return 0
	if(isrobot(M))
		var/mob/living/silicon/robot/R = M
		if(R.emagged)
			return 1
	if((M.mind in SSticker.mode.head_revolutionaries) || (M.mind in SSticker.mode.revolutionaries))
		if(SSticker.mode.config_tag == "revolution")
			return 2
		return 1
	if(M.mind in SSticker.mode.cult)
		if(SSticker.mode.config_tag == "cult")
			return 2
		return 1
	if(M.mind in SSticker.mode.syndicates)
		if(SSticker.mode.config_tag == "nuclear")
			return 2
		return 1
	if(M.mind in SSticker.mode.wizards)
		if(SSticker.mode.config_tag == "wizard")
			return 2
		return 1
	if(M.mind in SSticker.mode.changelings)
		if(SSticker.mode.config_tag == "changeling")
			return 2
		return 1
	if(M.mind in SSticker.mode.abductors)
		if(SSticker.mode.config_tag == "abduction")
			return 2
		return 1
	if(M.mind&&M.mind.special_role)//If they have a mind and special role, they are some type of traitor or antagonist.
		return 1

	return 0*/


/**
  * A proc that return whether the mob is a "Special Character" aka Antagonist
  *
  * Arguments:
  * * M - the mob you're checking
  */
/proc/is_special_character(mob/M)
	if(!SSticker.mode)
		return FALSE
	if(!istype(M))
		return FALSE
	if(isrobot(M))
		var/mob/living/silicon/robot/R = M
		if(R.emagged)
			return TRUE
	if(M.mind?.special_role)//If they have a mind and special role, they are some type of traitor or antagonist.
		return TRUE
	return FALSE


/**
  * A proc that return an array of capitalized strings containing name of the antag types they are
  *
  * Arguments:
  * * M - the mob you're checking
  */
/proc/get_antag_type_strings_list(mob/M) // return an array of all the antag types they are with name
	var/list/antag_list = list()

	if(!SSticker.mode || !istype(M) || !M.mind)
		return FALSE

	if(M.mind in SSticker.mode.head_revolutionaries)
		antag_list += "Head Rev"
	if(M.mind in SSticker.mode.revolutionaries)
		antag_list += "Revolutionary"
	if(M.mind in SSticker.mode.cult)
		antag_list += "Cultist"
	if(M.mind in SSticker.mode.syndicates)
		antag_list += "Nuclear Operative"
	if(M.mind in SSticker.mode.wizards)
		antag_list += "Wizard"
	if(M.mind in SSticker.mode.changelings)
		antag_list += "Changeling"
	if(M.mind in SSticker.mode.abductors)
		antag_list += "Abductor"
	if(M.mind.has_antag_datum(/datum/antagonist/vampire))
		antag_list += "Vampire"
	if(M.mind.has_antag_datum(/datum/antagonist/mindslave/thrall))
		antag_list += "Vampire Thrall"
	if(M.mind.has_antag_datum(/datum/antagonist/traitor))
		antag_list += "Traitor"
	if(M.mind.has_antag_datum(/datum/antagonist/mindslave, FALSE))
		antag_list += "Mindslave"
	if(isrobot(M))
		var/mob/living/silicon/robot/R = M
		if(R.emagged)
			antag_list += "Emagged Borg"
	if(!length(antag_list) && M.mind.special_role) // Snowflake check. If none of the above but still special, then other antag. Technically not accurate.
		antag_list += "Other Antag(s)"
	return antag_list


/**
  * A proc that return a string containing all the singled out antags . Empty string if not antag
  *
  * Usually, you'd return a FALSE, but since this is consumed by javascript you're in
  * for a world of hurt if you pass a byond FALSE which get converted into a fucking string anyway and pass for TRUE in check. Fuck.
  * It always append "(May be other antag)"
  * Arguments:
  * * M - the mob you're checking
  * *
  */
/proc/get_antag_type_truncated_plaintext_string(mob/M as mob)
	var/list/antag_list = get_antag_type_strings_list(M)

	if(length(antag_list))
		return antag_list.Join(" &amp; ") + " " + "(May be other antag)"

	return ""


/datum/admins/proc/spawn_atom(object as text)
	set category = "Admin.Event"
	set desc = "(путь атома) Создать атом. Добавьте точку к тексту, чтобы исключить подтипы пути, соответствующего входным данным."
	set name = "Spawn"

	return usr.client.spawn_atom_impl(object, FALSE)

/datum/admins/proc/spawn_atom_adv(object as text)
	set category = "Admin.Event"
	set desc = "(путь атома) Создать атом c aргументами в New(). Добавьте точку к тексту, чтобы исключить подтипы пути, соответствующего входным данным."
	set name = "Advanced Spawn"

	return usr.client.spawn_atom_impl(object, TRUE)

/client/proc/spawn_atom_impl(object, params)
	if(!check_rights(R_SPAWN))
		return

	var/list/types = typesof(/atom)
	var/list/matches = new()

	var/include_subtypes = TRUE

	if(copytext(object, -1) == ".")
		include_subtypes = FALSE
		object = copytext(object, 1, -1)

	if(include_subtypes)
		for(var/path in types)
			if(findtext("[path]", object))
				matches += path
	else
		var/needle_length = length(object)
		for(var/path in types)
			if(copytext("[path]", -needle_length) == object)
				matches += path

	if(matches.len==0)
		return

	var/chosen
	if(matches.len==1)
		chosen = matches[1]
	else
		chosen = tgui_input_list(usr, "Выберите тип атома", "Спавн атома", matches, matches[1])
		if(isnull(chosen))
			return

	var/list/arguments
	if(ispath(chosen,/turf))
		var/turf/T = get_turf(usr.loc)
		T.ChangeTurf(chosen)
	else
		if(params)
			arguments = usr.client.get_callproc_args(TRUE)

		if(!usr)
			return

		arguments = list(usr.loc) + arguments

		var/atom/A = new chosen(arglist(arguments))
		A.flags |= ADMIN_SPAWNED

	log_and_message_admins("spawned [chosen] at [COORD(usr)][LAZYLEN(arguments) > 1 ? " with parameters [print_single_line(arguments)]": ""]")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Spawn Atom") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!


/datum/admins/proc/show_traitor_panel(var/mob/M in GLOB.mob_list)
	set category = "Admin.Admin"
	set desc = "Edit mobs's memory and role"
	set name = "\[Admin\] Show Traitor Panel"

	if(!check_rights(R_ADMIN|R_MOD))
		return

	if(!istype(M))
		to_chat(usr, "This can only be used on instances of type /mob", confidential=TRUE)
		return
	if(!M.mind)
		to_chat(usr, "This mob has no mind!", confidential=TRUE)
		return

	M.mind.edit_memory()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Show Traitor Panel") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/datum/admins/proc/toggleguests()
	set category = "Admin.Toggles"
	set desc="Guests can't enter"
	set name="Toggle Guests"

	if(!check_rights(R_SERVER))
		return

	GLOB.guests_allowed = !( GLOB.guests_allowed )
	if(!( GLOB.guests_allowed ))
		to_chat(world, "<b>Guests may no longer enter the game.</b>")
	else
		to_chat(world, "<b>Guests may now enter the game.</b>")
	log_and_message_admins("toggled guests game entering [GLOB.guests_allowed ? "" : "dis"]allowed.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Guests") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/datum/admins/proc/output_ai_laws()
	var/ai_number = 0
	for(var/mob/living/silicon/S in GLOB.mob_list)
		ai_number++
		if(isAI(S))
			to_chat(usr, "<b>AI [key_name(S, TRUE)]'s laws:</b>", confidential=TRUE)
		else if(isrobot(S))
			var/mob/living/silicon/robot/R = S
			to_chat(usr, "<b>CYBORG [key_name(S, TRUE)]'s [R.connected_ai?"(Slaved to: [R.connected_ai])":"(Independent)"] laws:</b>", confidential=TRUE)
		else if(ispAI(S))
			var/mob/living/silicon/pai/P = S
			to_chat(usr, "<b>pAI [key_name(S, TRUE)]'s laws:</b>", confidential=TRUE)
			to_chat(usr, "[P.pai_law0]", confidential=TRUE)
			if(P.pai_laws)
				to_chat(usr, "[P.pai_laws]")
			continue // Skip showing normal silicon laws for pAIs - they don't have any
		else
			to_chat(usr, "<b>SILICON [key_name(S, TRUE)]'s laws:</b>", confidential=TRUE)

		if(S.laws == null)
			to_chat(usr, "[key_name(S, TRUE)]'s laws are null. Contact a coder.", confidential=TRUE)
		else
			S.laws.show_laws(usr)
	if(!ai_number)
		to_chat(usr, "<b>No AI's located.</b>", confidential=TRUE)//Just so you know the thing is actually working and not just ignoring you.


	log_and_message_admins("checked the AI laws")

/client/proc/update_mob_sprite(mob/living/carbon/human/H as mob)

	if(!check_rights(R_ADMIN))
		return

	if(istype(H))
		H.regenerate_icons()

//
//
//ALL DONE
//*********************************************************************************************************

/proc/formatJumpTo(var/location,var/where="")
	var/turf/loc
	if(istype(location,/turf/))
		loc = location
	else
		loc = get_turf(location)
	if(where=="")
		where=formatLocation(loc)
	return "<a href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[loc.x];Y=[loc.y];Z=[loc.z]'>[where]</a>"

/proc/formatLocation(var/location)
	var/turf/loc
	if(istype(location,/turf/))
		loc = location
	else
		loc = get_turf(location)
	var/area/A = get_area(location)
	return "[A.name] - [loc.x],[loc.y],[loc.z]"

/proc/formatPlayerPanel(var/mob/U,var/text="PP")
	return "[ADMIN_PP(U,"[text]")]"

//Kicks all the clients currently in the lobby. The second parameter (kick_only_afk) determins if an is_afk() check is ran, or if all clients are kicked
//defaults to kicking everyone (afk + non afk clients in the lobby)
//returns a list of ckeys of the kicked clients
/proc/kick_clients_in_lobby(message, kick_only_afk = 0)
	var/list/kicked_client_names = list()
	for(var/client/C in GLOB.clients)
		if(isnewplayer(C.mob))
			if(kick_only_afk && !C.is_afk())	//Ignore clients who are not afk
				continue
			if(message)
				to_chat(C, message, confidential=TRUE)
			kicked_client_names.Add("[C.ckey]")
			qdel(C)
	return kicked_client_names

//returns 1 to let the dragdrop code know we are trapping this event
//returns 0 if we don't plan to trap the event
/datum/admins/proc/cmd_ghost_drag(mob/dead/observer/frommob, atom/tothing)
	if(!istype(frommob))
		return //extra sanity check to make sure only observers are shoved into things

	//same as assume-direct-control perm requirements.
	if(!check_rights(R_VAREDIT,0)) //no varedit, check if they have r_admin and r_debug
		if(!check_rights(R_ADMIN|R_DEBUG,0)) //if they don't have r_admin and r_debug, return
			return FALSE //otherwise, if they have no varedit, but do have r_admin and r_debug, execute the rest of the code

	if(!frommob.ckey)
		return FALSE

	if(isitem(tothing))
		var/mob/living/toitem = tothing

		var/ask = tgui_alert(usr, "Вы уверены, что хотите разрешить [frommob]([frommob.key]) управлять [toitem.declent_ru(INSTRUMENTAL)]?", "Поместить призрака управлять предметом?", list("Да", "Нет"))
		if(ask != "Да")
			return TRUE

		if(!frommob || !toitem) //make sure the mobs don't go away while we waited for a response
			return TRUE

		var/mob/living/simple_animal/possessed_object/tomob = new(toitem)

		log_and_message_admins("has put [frommob.ckey] in control of [tomob.name].")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Ghost Drag")

		tomob.ckey = frommob.ckey
		qdel(frommob)


	if(isliving(tothing))
		var/mob/living/tomob = tothing

		var/question = ""
		if(tomob.ckey)
			question = "У этого существа уже есть пользователь ([tomob.key]), который управляет им! "
		question += "Вы уверены, что хотите разрешить [frommob.name]([frommob.key]) управлять [tomob]?"

		var/ask = tgui_alert(usr, question, "Поместить призрака управлять существом?", list("Да", "Нет"))
		if(ask != "Да")
			return TRUE

		if(!frommob || !tomob) //make sure the mobs don't go away while we waited for a response
			return TRUE

		if(tomob.client) //no need to ghostize if there is no client
			tomob.ghostize(0)

		log_and_message_admins("has put [frommob.ckey] in control of [tomob.name].")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Ghost Drag")

		tomob.ckey = frommob.ckey
		qdel(frommob)

		return TRUE

	if(istype(tothing, /obj/structure/AIcore/deactivated))

		var/question = "Вы уверены, что хотите разрешить [frommob.name]([frommob.key]) управлять пустым ядром ИИ?"

		var/ask = tgui_alert(usr, question, "Поместить призрака управлять пустым ядром ИИ?", list("Да", "Нет"))
		if(ask != "Да")
			return TRUE

		if(QDELETED(frommob) || QDELETED(tothing)) //make sure the mobs don't go away while we waited for a response
			return TRUE

		log_and_message_admins("has put [frommob.ckey] in control of an empty AI core.")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Ghost Drag")

		var/transfer_key = frommob.key // frommob is qdel'd in frommob.AIize()
		var/mob/living/silicon/ai/ai_character = frommob.AIize()
		ai_character.key = transfer_key // this wont occur in mind transferring if the mind is not active, which causes some weird stuff. This fixes it.
		GLOB.empty_playable_ai_cores -= tothing

		ai_character.forceMove(get_turf(tothing))
		ai_character.view_core()

		qdel(tothing)

		return TRUE

// Returns a list of the number of admins in various categories
// result[1] is the number of staff that match the rank mask and are active
// result[2] is the number of staff that do not match the rank mask
// result[3] is the number of staff that match the rank mask and are inactive
/proc/staff_countup(rank_mask = R_BAN)
	var/list/result = list(0, 0, 0)
	for(var/client/X in GLOB.admins)
		if(rank_mask && !check_rights_for(X, rank_mask))
			result[2]++
			continue
		if(X.holder.fakekey)
			result[2]++
			continue
		if(X.is_afk())
			result[3]++
			continue
		result[1]++
	return result


/**
 * Enables an admin to upload a new titlescreen image.
 */
/client/proc/admin_change_title_screen()
	set category = "Admin.Fun"
	set name = "Title Screen: Change"

	if(!check_rights(R_EVENT))
		return

	log_admin("[key_name(usr)] is changing the title screen.")
	message_admins("[key_name_admin(usr)] is changing the title screen.")

	switch(tgui_alert(usr, "Изменить изображение в лобби?", "Лобби", list("Сменить", "Сбросить", "Отмена")))
		if("Сменить")
			var/file = input(usr) as icon|null
			if(!file)
				return

			SStitle.set_title_image(file)
		if("Сбросить")
			SStitle.set_title_image()
		if("Отмена")
			return

/**
 * Sets a titlescreen notice, a big red text on the main screen.
 */
/client/proc/change_title_screen_notice()
	set category = "Admin.Fun"
	set name = "Title Screen: Set Notice"

	if(!check_rights(R_EVENT))
		return

	log_admin("[key_name(usr)] is setting the title screen notice.")
	message_admins("[key_name_admin(usr)] is setting the title screen notice.")

	var/new_notice = tgui_input_text(usr, "Введите новое сообщение для лобби:", "Уведомление в лобби")
	if(isnull(new_notice))
		return

	SStitle.set_notice(new_notice)

	for(var/mob/new_player/new_player in GLOB.player_list)
		SEND_SOUND(new_player,  sound('sound/items/bikehorn.ogg'))

/**
 * An admin debug command that enables you to change the HTML on the go.
 */
/client/proc/change_title_screen_html()
	set category = "Admin.Fun"
	set name = "Title Screen: Set HTML"

	if(!check_rights(R_DEBUG))
		return

	log_admin("[key_name(usr)] is setting the title screen HTML.")
	message_admins("[key_name_admin(usr)] is setting the title screen HTML.")

	var/new_html = tgui_input_text(usr, "Введите нужный HTML (ВНИМАНИЕ: ВЫ СКОРЕЕ ВСЕГО ЧТО-ТО СЛОМАЕТЕ!!!)", "РИСКОВАННО: ИЗМЕНЕНИЕ HTML ЛОББИ", max_length = 99999, multiline = TRUE, encode = FALSE)
	if(isnull(new_html))
		return

	if(tgui_alert(usr, "Всё ли верно? Нигде не ошиблись? Возврата нет!", "Одумайся...", list("Рискнём", "Пожалуй нет...")) != "Рискнём")
		return

	SStitle.set_title_html(new_html)

	message_admins("[key_name_admin(usr)] has changed the title screen HTML.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Change Title Screen")
