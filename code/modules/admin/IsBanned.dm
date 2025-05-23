//Blocks an attempt to connect before even creating our client datum thing.
/world/IsBanned(key, address, computer_id, type, check_ipintel = TRUE)

	if(!key || !address || !computer_id)
		log_adminwarn("Failed Login (invalid data): [key] [address]-[computer_id]")
		return list("reason"="invalid login data", "desc"="Error: Could not check ban status, please try again. Error message: Your computer provided invalid or blank information to the server on connection (BYOND Username, IP, and Computer ID). Provided information for reference: Username: '[key]' IP: '[address]' Computer ID: '[computer_id]'. If you continue to get this error, please restart byond or contact byond support.")

	if(type == "world")
		return ..() //shunt world topic banchecks to purely to byond's internal ban system

	if(text2num(computer_id) == 2147483647) //this cid causes stickybans to go haywire
		log_adminwarn("Failed Login (invalid cid): [key] [address]-[computer_id]")
		return list("reason"="invalid login data", "desc"="Error: Could not check ban status, Please try again. Error message: Your computer provided an invalid Computer ID.")

	var/admin = 0
	var/ckey = ckey(key)

	var/client/C = GLOB.directory[ckey]
	if (C && ckey == C.ckey && computer_id == C.computer_id && address == C.address)
		return //don't recheck connected clients.

	if((ckey in GLOB.admin_datums) || (ckey in GLOB.de_admins))
		var/datum/admins/A = GLOB.admin_datums[ckey]
		if(A && (A.rights & R_ADMIN))
			admin = 1

	//Guest Checking
	if(!GLOB.guests_allowed && IsGuestKey(key))
		log_adminwarn("Failed Login: [key] [computer_id] [address] - Guests not allowed")
		// message_admins("<span class='notice'>Failed Login: [key] - Guests not allowed</span>")
		return list("reason"="guest", "desc"="\nReason: Guests not allowed. Please sign in with a BYOND account.")

	//check if the IP address is a known proxy/vpn, and the user is not whitelisted
	if(check_ipintel && CONFIG_GET(string/ipintel_email) && CONFIG_GET(flag/ipintel_whitelist) && ipintel_is_banned(key, address))
		log_adminwarn("Failed Login: [key] [computer_id] [address] - Proxy/VPN")
		var/mistakemessage = ""
		if(CONFIG_GET(string/banappeals))
			mistakemessage = "\nIf you have to use one, request whitelisting at:  [CONFIG_GET(string/banappeals)]"
		return list("reason"="using proxy or vpn", "desc"="\nReason: Proxies/VPNs are not allowed here. [mistakemessage]")


	if(CONFIG_GET(flag/ban_legacy_system))
		//Ban Checking
		. = CheckBan(ckey(key), computer_id, address)
		if(.)
			if(admin)
				log_admin("The admin [key] has been allowed to bypass a matching ban on [.["key"]]")
				message_admins("<span class='adminnotice'>The admin [key] has been allowed to bypass a matching ban on [.["key"]]</span>")
				addclientmessage(ckey,"<span class='adminnotice'>You have been allowed to bypass a matching ban on [.["key"]].</span>")
			else
				log_adminwarn("Failed Login: [key] [computer_id] [address] - Banned [.["reason"]]")
				return .
	else
		var/ckeytext = ckey(key)

		if(!SSdbcore.IsConnected())
			log_world("Ban database connection failure. Key [ckeytext] not checked")
			return

		var/list/sql_query_params = list(
			"ckeytext" = ckeytext
		)

		var/wl_cid

		var/ipquery = ""
		var/cidquery = ""
		if(address)
			ipquery = " OR ip=:ip "
			sql_query_params["ip"] = address

		if(computer_id)
			cidquery = " OR computerid=:cid "
			sql_query_params["cid"] = computer_id

			var/datum/db_query/ban_wl_query = SSdbcore.NewQuery({"
			SELECT computerid FROM [CONFIG_GET(string/utility_database)].[format_table_name("ban_whitelist")]
			WHERE ckey=:ckeytext [cidquery]"}, sql_query_params)

			if(!ban_wl_query.warn_execute())
				message_admins("Failed to do a DB ban whitelist check for [ckeytext]. You have been warned.")
				qdel(ban_wl_query)
				return

			while(ban_wl_query.NextRow())
				wl_cid = ban_wl_query.item[1]
			qdel(ban_wl_query)

		var/datum/db_query/query = SSdbcore.NewQuery({"
		SELECT ckey, ip, computerid, a_ckey, reason, expiration_time, duration, bantime, bantype FROM [CONFIG_GET(string/utility_database)].[format_table_name("ban")]
		WHERE (ckey=:ckeytext [ipquery] [cidquery]) AND (bantype = 'PERMABAN' OR bantype = 'ADMIN_PERMABAN'
		OR ((bantype = 'TEMPBAN' OR bantype = 'ADMIN_TEMPBAN') AND expiration_time > Now())) AND isnull(unbanned)"}, sql_query_params)

		if(!query.warn_execute())
			message_admins("Failed to do a DB ban check for [ckeytext]. You have been warned.")
			qdel(query)
			return

		while(query.NextRow())
			var/pckey = query.item[1]
			//var/pip = query.item[2]
			//var/pcid = query.item[3]
			var/ackey = query.item[4]
			var/reason = query.item[5]
			var/expiration = query.item[6]
			var/duration = query.item[7]
			var/bantime = query.item[8]
			var/bantype = query.item[9]
			if(wl_cid && computer_id && wl_cid == computer_id && pckey != ckey)
				log_admin("Client [key] has banned CID ([computer_id]) but also exist in a ban whitelist - access allowed")
				continue
			if(bantype == "ADMIN_PERMABAN" || bantype == "ADMIN_TEMPBAN")
				//admin bans MUST match on ckey to prevent cid-spoofing attacks
				//	as well as dynamic ip abuse
				if(pckey != ckey)
					continue
			if(admin)
				if(bantype == "ADMIN_PERMABAN" || bantype == "ADMIN_TEMPBAN")
					log_admin("The admin [key] is admin banned, and has been disallowed access")
					message_admins("<span class='adminnotice'>The admin [key] is admin banned, and has been disallowed access</span>")
				else
					log_admin("The admin [key] has been allowed to bypass a matching ban on [pckey]")
					message_admins("<span class='adminnotice'>The admin [key] has been allowed to bypass a matching ban on [pckey]</span>")
					addclientmessage(ckey,"<span class='adminnotice'>You have been allowed to bypass a matching ban on [pckey].</span>")
					continue
			var/expires = ""
			var/appealmessage = ""
			if(CONFIG_GET(string/banappeals))
				appealmessage = " You may appeal it at <a href='[CONFIG_GET(string/banappeals)]'>[CONFIG_GET(string/banappeals)]</a>."
			if(text2num(duration) > 0)
				expires = " The ban is for [duration] minutes and expires on [expiration] (server time).[appealmessage]"
			else
				expires = " This ban does not expire automatically and must be appealed.[appealmessage]"

			var/desc = "\nReason: You, or another user of this computer or connection ([pckey]) is banned from playing here. The ban reason is:\n[reason]\nThis ban was applied by [ackey] on [bantime].[expires]"

			. = list("reason"="[bantype]", "desc"="[desc]")

			log_adminwarn("Failed Login: [key] [computer_id] [address] - Banned [.["reason"]]")
			qdel(query)
			return .
		qdel(query)

	. = ..()	//default pager ban stuff
	if(.)
		//byond will not trigger isbanned() for "global" host bans,
		//ie, ones where the "apply to this game only" checkbox is not checked (defaults to not checked)
		//So it's safe to let admins walk thru host/sticky bans here
		if(admin)
			log_admin("The admin [key] has been allowed to bypass a matching host/sticky ban")
			message_admins("<span class='adminnotice'>The admin [key] has been allowed to bypass a matching host/sticky ban</span>")
			addclientmessage(ckey,"<span class='adminnotice'>You have been allowed to bypass a matching host/sticky ban.</span>")
			return null
		else
			log_adminwarn("Failed Login: [key] [computer_id] [address] - Banned [.["message"]]")

	return .
