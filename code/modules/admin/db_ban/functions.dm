#define MAX_ADMIN_BANS_PER_ADMIN 1

/datum/admins/proc/DB_ban_record(bantype, mob/banned_mob, duration = -1, reason, job = "", rounds = 0, banckey = null, banip = null, bancid = null)

	if(!check_rights(R_BAN))	return

	if(!SSdbcore.IsConnected())
		to_chat(usr, span_boldannounceooc("Database connection failure when attempting to make DB ban. Please freeze them and write their ckey in notepad, so they can be banned when the DB returns."), confidential=TRUE)
		return

	var/serverip = "[world.internet_address]:[world.port]"
	var/bantype_pass = 0
	var/bantype_str
	var/maxadminbancheck	//Used to limit the number of active bans of a certein type that each admin can give. Used to protect against abuse or mutiny.
	var/announce_in_discord = FALSE		//When set, it announces the ban in irc. Intended to be a way to raise an alarm, so to speak.
	var/blockselfban		//Used to prevent the banning of yourself.
	var/kickbannedckey		//Defines whether this proc should kick the banned person, if they are connected (if banned_mob is defined).
							//some ban types kick players after this proc passes (tempban, permaban), but some are specific to db_ban, so
							//they should kick within this proc.
	var/isjobban // For job bans, which need to be inserted into the job ban lists
	switch(bantype)
		if(BANTYPE_PERMA)
			bantype_str = "PERMABAN"
			duration = -1
			bantype_pass = 1
			blockselfban = 1
		if(BANTYPE_TEMP)
			bantype_str = "TEMPBAN"
			bantype_pass = 1
			blockselfban = 1
		if(BANTYPE_JOB_PERMA)
			bantype_str = "JOB_PERMABAN"
			duration = -1
			bantype_pass = 1
			isjobban = 1
		if(BANTYPE_JOB_TEMP)
			bantype_str = "JOB_TEMPBAN"
			bantype_pass = 1
			isjobban = 1
		if(BANTYPE_APPEARANCE)
			bantype_str = "APPEARANCE_BAN"
			duration = -1
			bantype_pass = 1
		if(BANTYPE_ADMIN_PERMA)
			bantype_str = "ADMIN_PERMABAN"
			duration = -1
			bantype_pass = 1
			maxadminbancheck = 1
			announce_in_discord = TRUE
			blockselfban = 1
			kickbannedckey = 1
		if(BANTYPE_ADMIN_TEMP)
			bantype_str = "ADMIN_TEMPBAN"
			bantype_pass = 1
			maxadminbancheck = 1
			announce_in_discord = TRUE
			blockselfban = 1
			kickbannedckey = 1

	if( !bantype_pass ) return
	if( !istext(reason) ) return
	if( !isnum(duration) ) return

	var/ckey
	var/computerid
	var/ip

	if(ismob(banned_mob) && banned_mob.ckey)
		ckey = banned_mob.ckey
		if(banned_mob.client)
			computerid = banned_mob.client.computer_id
			ip = banned_mob.client.address
		else
			if(banned_mob.lastKnownIP)
				ip = banned_mob.lastKnownIP
			if(banned_mob.computer_id)
				computerid = banned_mob.computer_id
	else if(banckey)
		ckey = ckey(banckey)
		computerid = bancid
		ip = banip
	else if(ismob(banned_mob))
		message_admins("<font color='red'>[key_name_admin(usr)] attempted to add a ban based on a ckey-less mob, with no ckey provided. Report this bug.")
		return
	else
		message_admins("<font color='red'>[key_name_admin(usr)] attempted to add a ban based on a non-existent mob, with no ckey provided. Report this bug.")
		return

	var/datum/db_query/query = SSdbcore.NewQuery("SELECT id FROM [format_table_name("player")] WHERE ckey=:ckey", list(
		"ckey" = ckey
	))
	if(!query.warn_execute())
		qdel(query)
		return
	var/validckey = FALSE
	if(query.NextRow())
		validckey = TRUE
	if(!validckey)
		if(!banned_mob || (banned_mob && !IsGuestKey(banned_mob.key)))
			message_admins("<font color='red'>[key_name_admin(usr)] attempted to ban [ckey], but [ckey] does not exist in the player database. Please only ban actual players.</font>")
			qdel(query)
			return

	qdel(query)
	var/a_ckey
	var/a_computerid
	var/a_ip

	if(src.owner && isclient(src.owner))
		a_ckey = src.owner:ckey
		a_computerid = src.owner:computer_id
		a_ip = src.owner:address

	if(blockselfban)
		if(a_ckey == ckey)
			to_chat(usr, span_danger("You cannot apply this ban type on yourself."), confidential=TRUE)
			return

	var/who
	for(var/client/C in GLOB.clients)
		if(!who)
			who = "[C]"
		else
			who += ", [C]"

	var/adminwho
	for(var/client/C in GLOB.admins)
		if(!adminwho)
			adminwho = "[C]"
		else
			adminwho += ", [C]"

	if(maxadminbancheck)
		var/datum/db_query/adm_query = SSdbcore.NewQuery("SELECT count(id) AS num FROM [CONFIG_GET(string/utility_database)].[format_table_name("ban")] WHERE (a_ckey=:a_ckey) AND (bantype = 'ADMIN_PERMABAN'  OR (bantype = 'ADMIN_TEMPBAN' AND expiration_time > Now())) AND isnull(unbanned)", list(
			"a_ckey" = a_ckey
		))
		if(!adm_query.warn_execute())
			qdel(adm_query)
			return
		if(adm_query.NextRow())
			var/adm_bans = text2num(adm_query.item[1])
			if(adm_bans >= MAX_ADMIN_BANS_PER_ADMIN)
				to_chat(usr, span_danger("You already logged [MAX_ADMIN_BANS_PER_ADMIN] admin ban(s) or more. Do not abuse this function!"), confidential=TRUE)
				qdel(adm_query)
				return
		qdel(adm_query)

	var/datum/db_query/query_insert = SSdbcore.NewQuery({"
		INSERT INTO [CONFIG_GET(string/utility_database)].[format_table_name("ban")] (`id`,`bantime`,`serverip`,`bantype`,`reason`,`job`,`duration`,`rounds`,`expiration_time`,`ckey`,`computerid`,`ip`,`a_ckey`,`a_computerid`,`a_ip`,`who`,`adminwho`,`edits`,`unbanned`,`unbanned_datetime`,`unbanned_ckey`,`unbanned_computerid`,`unbanned_ip`)
		VALUES (null, Now(), :serverip, :bantype_str, :reason, :job, :duration, :rounds, Now() + INTERVAL :duration MINUTE, :ckey, :computerid, :ip, :a_ckey, :a_computerid, :a_ip, :who, :adminwho, '', null, null, null, null, null)
	"}, list(
		// Get ready for parameters
		"serverip" = serverip,
		"bantype_str" = bantype_str,
		"reason" = reason,
		"job" = job,
		"duration" = (duration ? "[duration]" : "0"), // Strings are important here
		"rounds" = (rounds ? "[rounds]" : "0"), // And here
		"ckey" = ckey,
		"computerid" = computerid,
		"ip" = ip,
		"a_ckey" = a_ckey,
		"a_computerid" = a_computerid,
		"a_ip" = a_ip,
		"who" = who,
		"adminwho" = adminwho
	))
	if(!query_insert.warn_execute())
		qdel(query_insert)
		return

	qdel(query_insert)
	to_chat(usr, span_notice("Ban saved to database."), confidential=TRUE)
	message_admins("[key_name_admin(usr)] has added a [bantype_str] for [ckey] [(job)?"([job])":""] [(duration > 0)?"([duration] minutes)":""] with the reason: \"[reason]\" to the ban database.")

	if(announce_in_discord)
		SSdiscord.send2discord_simple(DISCORD_WEBHOOK_ADMIN, "**\[Ban]** [a_ckey] applied a [bantype_str] on [ckey]")

	if(kickbannedckey)
		if(banned_mob && banned_mob.client && banned_mob.client.ckey == banckey)
			qdel(banned_mob.client)

	if(isjobban)
		jobban_client_fullban(ckey, job)
	else
		flag_account_for_forum_sync(ckey)

/datum/admins/proc/DB_ban_unban(ckey, bantype, job = "")

	if(!check_rights(R_BAN))	return

	if(!SSdbcore.IsConnected())
		to_chat(usr, span_boldannounceooc("Database connection failure when attempting to remove DB ban. Please remember to unban them at a later date!."), confidential=TRUE)
		return

	var/bantype_str
	var/isjobban // For job bans, which need to be removed from the job ban lists
	if(bantype)
		var/bantype_pass = 0
		switch(bantype)
			if(BANTYPE_PERMA)
				bantype_str = "PERMABAN"
				bantype_pass = 1
			if(BANTYPE_TEMP)
				bantype_str = "TEMPBAN"
				bantype_pass = 1
			if(BANTYPE_JOB_PERMA)
				bantype_str = "JOB_PERMABAN"
				bantype_pass = 1
				isjobban = 1
			if(BANTYPE_JOB_TEMP)
				bantype_str = "JOB_TEMPBAN"
				bantype_pass = 1
				isjobban = 1
			if(BANTYPE_APPEARANCE)
				bantype_str = "APPEARANCE_BAN"
				bantype_pass = 1
			if(BANTYPE_ADMIN_PERMA)
				bantype_str = "ADMIN_PERMABAN"
				bantype_pass = 1
			if(BANTYPE_ADMIN_TEMP)
				bantype_str = "ADMIN_TEMPBAN"
				bantype_pass = 1
			if(BANTYPE_ANY_FULLBAN)
				bantype_str = "ANY"
				bantype_pass = 1
		if( !bantype_pass ) return

	var/bantype_sql
	if(bantype_str == "ANY")
		bantype_sql = "(bantype = 'PERMABAN' OR (bantype = 'TEMPBAN' AND expiration_time > Now() ) )"
	else
		bantype_sql = "bantype = '[bantype_str]'"

	var/sql = "SELECT id FROM [CONFIG_GET(string/utility_database)].[format_table_name("ban")] WHERE ckey=:ckey AND [bantype_sql] AND (unbanned is null OR unbanned = false)"
	var/list/sql_params = list(
		"ckey" = ckey
	)
	if(job)
		sql += " AND job=:job"
		sql_params["job"] = job

	var/ban_id
	var/ban_number = 0 //failsafe

	var/datum/db_query/query = SSdbcore.NewQuery(sql, sql_params)
	if(!query.warn_execute())
		qdel(query)
		return

	while(query.NextRow())
		ban_id = query.item[1]
		ban_number++

	qdel(query)

	if(ban_number == 0)
		to_chat(usr, span_warning("Database update failed due to no bans fitting the search criteria. If this is not a legacy ban you should contact the database admin."), confidential=TRUE)
		return

	if(ban_number > 1)
		to_chat(usr, span_warning("Database update failed due to multiple bans fitting the search criteria. Note down the ckey, job and current time and contact the database admin."), confidential=TRUE)
		return

	if(istext(ban_id))
		ban_id = text2num(ban_id)
	if(!isnum(ban_id))
		to_chat(usr, span_warning("Database update failed due to a ban ID mismatch. Contact the database admin."), confidential=TRUE)
		return

	DB_ban_unban_by_id(ban_id)
	if(isjobban)
		jobban_unban_client(ckey, job)
	else
		flag_account_for_forum_sync(ckey)

/datum/admins/proc/DB_ban_edit(banid = null, param = null)

	if(!check_rights(R_BAN))	return

	if(!isnum(banid) || !istext(param))
		to_chat(usr, "Cancelled", confidential=TRUE)
		return

	var/datum/db_query/query = SSdbcore.NewQuery("SELECT ckey, duration, reason, job FROM [CONFIG_GET(string/utility_database)].[format_table_name("ban")] WHERE id=:banid", list(
		"banid" = banid
	))
	if(!query.warn_execute())
		qdel(query)
		return

	var/eckey = usr.ckey	//Editing admin ckey
	var/pckey				//(banned) Player ckey
	var/duration			//Old duration
	var/reason				//Old reason
	var/job						//Old job

	if(query.NextRow())
		pckey = query.item[1]
		duration = query.item[2]
		reason = query.item[3]
		job = query.item[4]
	else
		to_chat(usr, "Invalid ban id. Contact the database admin", confidential=TRUE)
		qdel(query)
		return

	qdel(query)
	var/value

	switch(param)
		if("reason")
			if(!value)
				value = tgui_input_text(usr, "Insert the new reason for [pckey]'s ban", "New Reason", "[reason]", multiline = TRUE, encode = FALSE)
				if(!value)
					to_chat(usr, "Cancelled", confidential=TRUE)
					return

			var/edit_reason = "- [eckey] changed ban reason from <cite><b>\\\"[reason]\\\"</b></cite> to <cite><b>\\\"[value]\\\"</b></cite><br>"
			var/datum/db_query/update_query = SSdbcore.NewQuery("UPDATE [CONFIG_GET(string/utility_database)].[format_table_name("ban")] SET reason=:value, edits = CONCAT(IFNULL(edits,''), :edittext) WHERE id=:banid", list(
				"edittext" = edit_reason,
				"banid" = banid,
				"value" = value
			))

			if(!update_query.warn_execute())
				qdel(update_query)
				return
			qdel(update_query)
			message_admins("[key_name_admin(usr)] has edited a ban for [pckey]'s reason from [reason] to [value]")
		if("duration")
			if(!value)
				var/days = floor(duration/(1 BAN_DAYS))
				var/hours = floor((duration - days BAN_DAYS)/(1 BAN_HOURS))
				var/minutes = duration - days BAN_DAYS - hours BAN_HOURS
				var/raw_values = tgui_input_text(usr, "Введите новую длительность бана в формате Д:Ч:M", "Новая длительность", "[days]:[hours]:[minutes]")
				if(!raw_values)
					to_chat(usr, "Cancelled", confidential=TRUE)
					return
				var/list/values = text2numlist(raw_values, ":")
				if(!values?.len || values.len != 3)
					to_chat(usr, "Cancelled", confidential=TRUE)
					return
				value = values[1] BAN_DAYS + values[2] BAN_HOURS + values[3]
				if(!isnum(value) || !value)
					to_chat(usr, "Cancelled", confidential=TRUE)
					return

			var/edittext = "- [eckey] changed ban duration from [duration] to [value]<br>"
			var/datum/db_query/update_query = SSdbcore.NewQuery("UPDATE [CONFIG_GET(string/utility_database)].[format_table_name("ban")] SET duration=:value, edits = CONCAT(IFNULL(edits, ''), :edittext), expiration_time = DATE_ADD(bantime, INTERVAL :value MINUTE) WHERE id=:banid", list(
				"edittext" = edittext,
				"banid" = banid,
				"value" = value
			))
			if(!update_query.warn_execute())
				qdel(update_query)
				return

			qdel(update_query)
			message_admins("[key_name_admin(usr)] has edited a ban for [pckey]'s duration from [duration] to [value]")
		if("unban")
			if(tgui_alert(usr, "Unban [pckey]?", "Unban?", list("Yes", "No")) == "Yes")
				DB_ban_unban_by_id(banid)
				if(job && length(job))
					jobban_unban_client(pckey, job)
				return
			else
				to_chat(usr, "Cancelled", confidential=TRUE)
				return
		else
			to_chat(usr, "Cancelled", confidential=TRUE)
			return

/datum/admins/proc/DB_ban_unban_by_id(var/id)

	if(!check_rights(R_BAN))
		return

	if(!SSdbcore.IsConnected())
		to_chat(usr, span_boldannounceooc("Database connection failure when attempting to remove DB ban. Please remember to unban them at a later date!"), confidential=TRUE)
		return

	var/ban_number = 0 //failsafe

	var/pckey
	var/datum/db_query/query = SSdbcore.NewQuery("SELECT ckey FROM [CONFIG_GET(string/utility_database)].[format_table_name("ban")] WHERE id=:banid", list(
		"banid" = id
	))
	if(!query.warn_execute())
		qdel(query)
		return
	while(query.NextRow())
		pckey = query.item[1]
		ban_number++

	qdel(query)

	if(ban_number == 0)
		to_chat(usr, span_warning("Database update failed due to a ban id not being present in the database."), confidential=TRUE)
		return

	if(ban_number > 1)
		to_chat(usr, span_warning("Database update failed due to multiple bans having the same ID. Contact the database admin."), confidential=TRUE)
		return

	if(!src.owner || !isclient(src.owner))
		return

	var/unban_ckey = src.owner:ckey
	var/unban_computerid = src.owner:computer_id
	var/unban_ip = src.owner:address

	var/datum/db_query/query_update = SSdbcore.NewQuery("UPDATE [CONFIG_GET(string/utility_database)].[format_table_name("ban")] SET unbanned = 1, unbanned_datetime = Now(), unbanned_ckey=:unban_ckey, unbanned_computerid=:unban_computerid, unbanned_ip=:unban_ip WHERE id=:id", list(
		"unban_ckey" = unban_ckey,
		"unban_computerid" = unban_computerid,
		"unban_ip" = unban_ip,
		"id" = id
	))
	if(!query_update.warn_execute())
		qdel(query_update)
		return

	qdel(query_update)

	message_admins("[key_name_admin(usr)] has lifted [pckey]'s ban.")
	flag_account_for_forum_sync(pckey)


/client/proc/DB_ban_panel()
	set category = "Admin.Ban"
	set name = "Banning Panel"
	set desc = "DB Ban Panel"

	if(!check_rights(R_BAN))
		return

	holder.DB_ban_panel()


/datum/admins/proc/DB_ban_panel(playerckey = null, adminckey = null, playerip = null, playercid = null, dbbantype = null, match = null)

	if(!usr.client)
		return

	if(!check_rights(R_BAN))
		return

	if(!SSdbcore.IsConnected())
		to_chat(usr, span_warning("Не удалось установить соединение с базой данных"), confidential=TRUE)
		return

	var/cached_UID = UID()
	var/list/output = list()

	output += "<div align='center'><table width='100%'><tr>"
	output += "<td align='center'>"
	output += "<form method='GET' action='?src=[cached_UID]'><b>Add custom ban:</b> (ONLY use this if you can't ban through any other method)</b>"
	output += "<input type='hidden' name='src' value='[cached_UID]'>"
	output += "<table width='100%'><tr>"
	output += "<td width='50%' align='center'><b>Ban Type:</b><br><select name='dbbanaddtype'>"
	output += "<option value=''>--</option>"
	output += "<option value='[BANTYPE_PERMA]'>PERMABAN</option>"
	output += "<option value='[BANTYPE_TEMP]'>TEMPBAN</option>"
	output += "<option value='[BANTYPE_JOB_PERMA]'>JOB PERMABAN</option>"
	output += "<option value='[BANTYPE_JOB_TEMP]'>JOB TEMPBAN</option>"
	output += "<option value='[BANTYPE_APPEARANCE]'>APPEARANCE BAN</option>"
	output += "<option value='[BANTYPE_ADMIN_PERMA]'>ADMIN PERMABAN</option>"
	output += "<option value='[BANTYPE_ADMIN_TEMP]'>ADMIN TEMPBAN</option>"
	output += "</select></td>"
	output += "<td width='50%' align='center'><b>Ckey:</b><br><input type='text' name='dbbanaddckey'></td></tr>"
	output += "<tr><td width='50%' align='center'><b>IP:</b><br><input type='text' name='dbbanaddip'></td>"
	output += "<td width='50%' align='center'><b>CID:</b><br><input type='text' name='dbbanaddcid'></td></tr>"
	output += "<tr>\
	<td width='50%' align='center'>\
		<table style='width: auto; margin: 0 auto;'>\
		<tr>\
		<td style='padding-right: 8px; text-align: right;'><b>Days:</b></td>\
			<td><input type='text' pattern='\\d*' style='width: 40px; padding: 2px; font-size: 12px;' name='dbbadddurationdays'\
				oninvalid='this.setCustomValidity(\"Только числа допустимы\")'\
				oninput='this.setCustomValidity(\"\")'></td>\
		</tr>\
		<tr>\
		<td style='padding-right: 8px; text-align: right;'><b>Hours:</b></td>\
			<td><input type='text' pattern='\\d*' style='width: 40px; padding: 2px; font-size: 12px;' name='dbbadddurationhours'\
				oninvalid='this.setCustomValidity(\"Только числа допустимы\")'\
				oninput='this.setCustomValidity(\"\")'></td>\
		</tr>\
		<tr>\
		<td style='padding-right: 8px; text-align: right;'><b>Minutes:</b></td>\
			<td><input type='text' pattern='\\d*' style='width: 40px; padding: 2px; font-size: 12px;' name='dbbadddurationminutes'\
			oninvalid='this.setCustomValidity(\"Только числа допустимы\")'\
			oninput='this.setCustomValidity(\"\")'></td>\
		</tr>\
		</table>\
	</td>"
	output += "<td width='50%' align='center'><b>Job:</b><br><select name='dbbanaddjob'>"
	output += "<option value=''>--</option>"
	for(var/j in get_all_jobs())
		output += "<option value='[j]'>[j]</option>"
	for(var/j in GLOB.nonhuman_positions)
		output += "<option value='[j]'>[j]</option>"
	for(var/j in GLOB.other_roles)
		output += "<option value='[j]'>[j]</option>"
	for(var/j in list("commanddept","securitydept","engineeringdept","medicaldept","sciencedept","supportdept","nonhumandept","whitelistdept"))
		output += "<option value='[j]'>[j]</option>"
	for(var/j in list("Syndicate") + GLOB.antag_roles)
		output += "<option value='[j]'>[j]</option>"
	output += "</select></td></tr>"
	output += "<tr><td width='50%' align='right'><input type='checkbox' value='round' name='dbbanaddround'> Add current ID and server name</td></tr></table>"
	output += "<b>Reason:<br></b><textarea name='dbbanreason' cols='55' rows='10'></textarea><br><br>"
	output += "<input type='submit' value='Add ban'>"
	output += "</form>"

	output += "</td>"
	output += "</tr>"
	output += "</table>"

	output += "<br><br><hr><br><br>"

	output += "<form method='GET' action='?src=[cached_UID]'><table width='100%'><tr><td colspan='2' align='center'><b>Search:</b>"
	output += "<input type='hidden' name='src' value='[cached_UID]'></td></tr>"
	output += "<tr><td width='50%' align='center'><b>Ckey:</b><br><input type='text' name='dbsearchckey' value='[playerckey]'></td>"
	output += "<td width='50%' align='center'><b>Admin ckey:</b><br><input type='text' name='dbsearchadmin' value='[adminckey]'></td></tr>"
	output += "<tr><td width='50%' align='center'><b>IP:</b><br><input type='text' name='dbsearchip' value='[playerip]'></td>"
	output += "<td width='50%' align='center'><b>CID:</b><br><input type='text' name='dbsearchcid' value='[playercid]'></td></tr>"
	output += "<tr><td width='50%' align='center' colspan='2'><b>Ban type:</b><br><select name='dbsearchbantype'>"
	output += "<option value=''>--</option>"
	output += "<option value='[BANTYPE_PERMA]'>PERMABAN</option>"
	output += "<option value='[BANTYPE_TEMP]'>TEMPBAN</option>"
	output += "<option value='[BANTYPE_JOB_PERMA]'>JOB PERMABAN</option>"
	output += "<option value='[BANTYPE_JOB_TEMP]'>JOB TEMPBAN</option>"
	output += "<option value='[BANTYPE_APPEARANCE]'>APPEARANCE BAN</option>"
	output += "<option value='[BANTYPE_ADMIN_PERMA]'>ADMIN PERMABAN</option>"
	output += "<option value='[BANTYPE_ADMIN_TEMP]'>ADMIN TEMPBAN</option>"
	output += "</select></td></tr></table>"
	output += "<br><br><input type='submit' value='Search'><br>"
	output += "<input type='checkbox' value='[match]' name='dbmatch' [match? "checked=\"1\"" : null]> Match(min. 3 characters to search by key or ip, and 7 to search by cid)<br>"
	output += "</form>"
	output += "This search shows only last 100 bans."

	if(adminckey || playerckey || playerip || playercid || dbbantype)

		adminckey = ckey(adminckey)
		playerckey = ckey(playerckey)

		if(adminckey || playerckey || playerip || playercid || dbbantype)

			var/blcolor = "#fc5f5f" //banned light
			var/bdcolor = "#c72626" //banned dark
			var/ulcolor = "#73b873" //unbanned light
			var/udcolor = "#3faa3f" //unbanned dark

			output += "<table width='100%' bgcolor='#151515' cellpadding='5' cellspacing='0' align='center'>"
			output += "<tr>"
			output += "<th width='25%'><b>TYPE</b></th>"
			output += "<th width='20%'><b>CKEY</b></th>"
			output += "<th width='20%'><b>TIME APPLIED</b></th>"
			output += "<th width='20%'><b>ADMIN</b></th>"
			output += "<th width='15%'><b>OPTIONS</b></th>"
			output += "</tr>"

			var/adminsearch = ""
			var/playersearch = ""
			var/ipsearch = ""
			var/cidsearch = ""
			var/bantypesearch = ""

			var/list/sql_params = list()

			if(!match)
				if(adminckey)
					adminsearch = "AND a_ckey=:adminckey "
					sql_params["adminckey"] = adminckey
				if(playerckey)
					playersearch = "AND ckey=:playerckey "
					sql_params["playerckey"] = playerckey
				if(playerip)
					ipsearch  = "AND ip=:playerip "
					sql_params["playerip"] = playerip
				if(playercid)
					cidsearch  = "AND computerid=:playercid "
					sql_params["playercid"] = playercid
			else
				if(adminckey && length(adminckey) >= 3)
					adminsearch = "AND a_ckey LIKE :adminckey "
					sql_params["adminckey"] = "[adminckey]%"
				if(playerckey && length(playerckey) >= 3)
					playersearch = "AND ckey LIKE :playerckey "
					sql_params["playerckey"] = "[playerckey]%"
				if(playerip && length(playerip) >= 3)
					ipsearch  = "AND ip LIKE :playerip "
					sql_params["playerip"] = "[playerip]%"
				if(playercid && length(playercid) >= 7)
					cidsearch  = "AND computerid LIKE :playercid "
					sql_params["playercid"] = "[playercid]%"

			if(dbbantype)
				bantypesearch = "AND bantype = "

				switch(dbbantype)
					if(BANTYPE_TEMP)
						bantypesearch += "'TEMPBAN' "
					if(BANTYPE_JOB_PERMA)
						bantypesearch += "'JOB_PERMABAN' "
					if(BANTYPE_JOB_TEMP)
						bantypesearch += "'JOB_TEMPBAN' "
					if(BANTYPE_APPEARANCE)
						bantypesearch += "'APPEARANCE_BAN' "
					if(BANTYPE_ADMIN_PERMA)
						bantypesearch = "'ADMIN_PERMABAN' "
					if(BANTYPE_ADMIN_TEMP)
						bantypesearch = "'ADMIN_TEMPBAN' "
					else
						bantypesearch += "'PERMABAN' "


			var/datum/db_query/select_query = SSdbcore.NewQuery({"
				SELECT id, bantime, bantype, reason, job, duration, expiration_time, ckey, a_ckey, unbanned, unbanned_ckey, unbanned_datetime, edits, ip, computerid
				FROM [CONFIG_GET(string/utility_database)].[format_table_name("ban")] WHERE 1 [playersearch] [adminsearch] [ipsearch] [cidsearch] [bantypesearch] ORDER BY bantime DESC LIMIT 100"}, sql_params)

			if(!select_query.warn_execute())
				qdel(select_query)
				return

			while(select_query.NextRow())
				var/banid = select_query.item[1]
				var/bantime = select_query.item[2]
				var/bantype  = select_query.item[3]
				var/reason = select_query.item[4]
				var/job = select_query.item[5]
				var/duration = select_query.item[6]
				var/expiration = select_query.item[7]
				var/ckey = select_query.item[8]
				var/ackey = select_query.item[9]
				var/unbanned = select_query.item[10]
				var/unbanckey = select_query.item[11]
				var/unbantime = select_query.item[12]
				var/edits = select_query.item[13]
				var/ip = select_query.item[14]
				var/cid = select_query.item[15]

				var/lcolor = blcolor
				var/dcolor = bdcolor
				if(unbanned)
					lcolor = ulcolor
					dcolor = udcolor

				var/typedesc =""
				switch(bantype)
					if("PERMABAN")
						typedesc = "<b>PERMABAN</b>"
					if("TEMPBAN")
						typedesc = "<b>TEMPBAN</b><br><font size='2'>([duration] minutes [(unbanned) ? "" : "(<a href=\"byond://?src=[UID()];dbbanedit=duration;dbbanid=[banid]\">Edit</a>))"]<br>Expires [expiration]</font>"
					if("JOB_PERMABAN")
						typedesc = "<b>JOBBAN</b><br><font size='2'>([job])"
					if("JOB_TEMPBAN")
						typedesc = "<b>TEMP JOBBAN</b><br><font size='2'>([job])<br>([duration] minutes<br>Expires [expiration]"
					if("APPEARANCE_BAN")
						typedesc = "<b>APPEARANCE/NAME BAN</b>"
					if("ADMIN_PERMABAN")
						typedesc = "<b>ADMIN PERMABAN</b>"
					if("ADMIN_TEMPBAN")
						typedesc = "<b>ADMIN TEMPBAN</b><br><font size='2'>([duration] minutes [(unbanned) ? "" : "(<a href=\"byond://?src=[cached_UID];dbbanedit=duration;dbbanid=[banid]\">Edit</a>))"]<br>Expires<br>[expiration]</font>"

				output += "<tr bgcolor='[dcolor]'>"
				output += "<td align='center'>[typedesc]</td>"
				output += "<td align='center'><b>[ckey]</b></td>"
				output += "<td align='center'>[bantime]</td>"
				output += "<td align='center'><b>[ackey]</b></td>"
				output += "<td align='center'>[(unbanned) ? "" : "<b><a href=\"byond://?src=[cached_UID];dbbanedit=unban;dbbanid=[banid]\">Unban</a></b>"]</td>"
				output += "</tr>"
				output += "<tr bgcolor='[dcolor]'>"
				output += "<td align='center' colspan='2' bgcolor=''><b>IP:</b> [ip]</td>"
				output += "<td align='center' colspan='3' bgcolor=''><b>CID:</b> [cid]</td>"
				output += "</tr>"
				output += "<tr bgcolor='[lcolor]'>"
				output += "<td align='center' colspan='5'><b>Reason: [(unbanned) ? "" : "(<a href=\"byond://?src=[cached_UID];dbbanedit=reason;dbbanid=[banid]\">Edit</a>)"]</b> <cite>\"[reason]\"</cite></td>"
				output += "</tr>"
				if(edits)
					output += "<tr bgcolor='[dcolor]'>"
					output += "<td align='center' colspan='5'><b>EDITS</b></td>"
					output += "</tr>"
					output += "<tr bgcolor='[lcolor]'>"
					output += "<td align='center' colspan='5'><font size='2'>[edits]</font></td>"
					output += "</tr>"
				if(unbanned)
					output += "<tr bgcolor='[dcolor]'>"
					output += "<td align='center' colspan='5' bgcolor=''><b>UNBANNED by admin [unbanckey] on [unbantime]</b></td>"
					output += "</tr>"
				output += "<tr>"
				output += "<td colspan='5' bgcolor='#151515'>&nbsp</td>"
				output += "</tr>"

			output += "</table></div>"

			qdel(select_query)

	var/datum/browser/popup = new(usr, "ban_panel", "<div align='center'>Manual Ban Panel</div>", 900, 700)
	popup.set_content(output.Join(""))
	popup.set_window_options("can_close=1;can_minimize=0;can_maximize=0;can_resize=0;titlebar=1;")
	popup.add_stylesheet("dark_inputs", "html/dark_inputs.css")
	popup.open()
	onclose(usr, "ban_panel")

/proc/flag_account_for_forum_sync(ckey)
	if(!SSdbcore.IsConnected())
		return
	var/datum/db_query/adm_query = SSdbcore.NewQuery("UPDATE [format_table_name("player")] SET fupdate = 1 WHERE ckey=:ckey", list(
		"ckey" = ckey
	))
	// We do nothing with output here so we dont need to wrap the warn_execute() inside an if statement
	adm_query.warn_execute()
	qdel(adm_query)

