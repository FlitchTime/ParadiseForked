GLOBAL_LIST_EMPTY(allfaxes)
GLOBAL_LIST_INIT(admin_departments, list("Central Command"))
GLOBAL_LIST_INIT(hidden_admin_departments, list("Syndicate"))
GLOBAL_LIST_INIT(hidden_ussp, list("USSP Central Committee"))
GLOBAL_LIST_EMPTY(alldepartments)
GLOBAL_LIST_EMPTY(hidden_departments)
GLOBAL_LIST_EMPTY(fax_blacklist)

/obj/machinery/photocopier/faxmachine
	name = "fax machine"
	icon = 'icons/obj/library.dmi'
	icon_state = "fax"
	insert_anim = "faxsend"
	pass_flags = PASSTABLE
	var/fax_network = "Local Fax Network"
	/// If true, prevents fax machine from sending messages to NT machines
	var/syndie_restricted = FALSE
	var/ussp_restricted = FALSE
	/// Can we send messages off-station?
	var/long_range_enabled = FALSE
	req_access = list(ACCESS_LAWYER, ACCESS_HEADS, ACCESS_ARMORY)

	use_power = IDLE_POWER_USE
	idle_power_usage = 30
	active_power_usage = 200

	/// ID card inserted into the machine, used to log in with
	var/obj/item/card/id/scan = null

	/// Whether the machine is "logged in" or not
	var/authenticated = FALSE
	/// Next world.time at which this fax machine can send a message to CC/syndicate
	var/sendcooldown = 0
	/// After sending a message to CC/syndicate, cannot send another to them for this many deciseconds
	var/cooldown_time = 1800
	/// After sending a message to local faxes, cannot send another to them for this many deciseconds
	var/cooldown_time_local = 50

	/// Our department, determines whether this machine gets faxes sent to a department
	var/department = "Unknown"

	/// Target department to send outgoing faxes to
	var/destination

/obj/machinery/photocopier/faxmachine/New()
	..()
	GLOB.allfaxes += src
	update_network()

/obj/machinery/photocopier/faxmachine/proc/update_network()
	if(department != "Unknown")
		if(!(("[department]" in GLOB.alldepartments) || ("[department]" in GLOB.hidden_departments) || ("[department]" in GLOB.admin_departments) || ("[department]" in GLOB.hidden_admin_departments) || ("[department]" in GLOB.hidden_ussp)))
			GLOB.alldepartments |= department

/obj/machinery/photocopier/faxmachine/longrange
	name = "long range fax machine"
	fax_network = "Central Command Quantum Entanglement Network"
	long_range_enabled = TRUE

/obj/machinery/photocopier/faxmachine/longrange/syndie
	name = "syndicate long range fax machine"
	emagged = TRUE
	syndie_restricted = TRUE
	req_access = list(ACCESS_SYNDICATE)
	//No point setting fax network, being emagged overrides that anyway.

/obj/machinery/photocopier/faxmachine/longrange/syndie/update_network()
	if(department != "Unknown")
		GLOB.hidden_departments |= department

/obj/machinery/photocopier/faxmachine/longrange/ussp
	name = "USSP long range fax machine"
	fax_network = "USSP Quantum Entanglement Network"
	ussp_restricted = TRUE
	req_access = list(ACCESS_USSP_MARINE_CAPTAIN)
	idle_power_usage = 60
	active_power_usage = 300

/obj/machinery/photocopier/faxmachine/longrange/ussp/update_network()
	if(department != "Unknown")
		GLOB.hidden_ussp |= department

/obj/machinery/photocopier/faxmachine/attack_hand(mob/user)
	if(..())
		return TRUE

	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/photocopier/faxmachine/attack_ghost(mob/user)
	ui_interact(user)


/obj/machinery/photocopier/faxmachine/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/card/id))
		add_fingerprint(user)
		if(scan)
			to_chat(user, span_warning("The [name] is already holding another ID-card."))
			return ATTACK_CHAIN_PROCEED
		if(!scan(I))
			return ..()
		to_chat(user, span_notice("You have inserted [I] into [src]."))
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/paper) || istype(I, /obj/item/photo) || istype(I, /obj/item/paper_bundle))
		. = ..()
		SStgui.update_uis(src)
		return .

	return ..()


/obj/machinery/photocopier/faxmachine/emag_act(mob/user)
	if(!emagged)
		add_attack_logs(user, src, "emagged")
		emagged = 1
		req_access = list()
		if(user)
			to_chat(user, "<span class='notice'>The transmitters realign to an unknown source!</span>")
	else if(user)
		to_chat(user, "<span class='warning'>You swipe the card through [src], but nothing happens.</span>")

/obj/machinery/photocopier/faxmachine/proc/is_authenticated(mob/user)
	if(authenticated)
		return TRUE
	else if(user.can_admin_interact())
		return TRUE
	return FALSE

/obj/machinery/photocopier/faxmachine/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FaxMachine", name)
		ui.open()

/obj/machinery/photocopier/faxmachine/ui_data(mob/user)
	var/list/data = list()
	data["authenticated"] = is_authenticated(user)
	data["scan_name"] = scan ? scan.name : FALSE
	if(!data["authenticated"])
		data["network"] = "Disconnected"
	else if(!emagged)
		data["network"] = fax_network
	else
		data["network"] = "ERR*?*%!*"
	data["paper"] = copyitem ? copyitem.name : FALSE
	data["paperinserted"] = copyitem ? TRUE : FALSE
	data["destination"] = destination ? destination : FALSE
	data["sendError"] = FALSE
	if(stat & (BROKEN|NOPOWER))
		data["sendError"] = "No Power"
	else if(!data["authenticated"])
		data["sendError"] = "Not Logged In"
	else if(!data["paper"])
		data["sendError"] = "Nothing Inserted"
	else if(!data["destination"])
		data["sendError"] = "Destination Not Set"
	else
		var/cooldown_seconds = cooldown_seconds()
		if(cooldown_seconds)
			data["sendError"] = "Re-aligning in [cooldown_seconds] seconds..."
	return data


/obj/machinery/photocopier/faxmachine/ui_act(action, params)
	if(..())
		return

	// Do not let click buttons if you're ghost unless you're an admin.
	if (isobserver(usr) && !is_admin(usr))
		return FALSE

	var/is_authenticated = is_authenticated(usr)
	. = TRUE
	switch(action)
		if("scan") // insert/remove your ID card
			scan()
		if("auth") // log in/out
			if(!is_authenticated && scan)
				if(scan.registered_name in GLOB.fax_blacklist)
					to_chat(usr, "<span class='warning'>Login rejected: individual is blacklisted from fax network.</span>")
					playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
					. = FALSE
				else if(check_access(scan))
					authenticated = TRUE
				else // ID doesn't have access to this machine
					to_chat(usr, "<span class='warning'>Login rejected: ID card does not have required access.</span>")
					playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
					. = FALSE
			else if(is_authenticated)
				authenticated = FALSE
		if("paper") // insert/eject paper/paperbundle/photo
			if(copyitem)
				copyitem.forceMove(get_turf(src))
				if(ishuman(usr))
					if(Adjacent(usr))
						usr.put_in_hands(copyitem, ignore_anim = FALSE)
				to_chat(usr, "<span class='notice'>You eject [copyitem] from [src].</span>")
				copyitem = null
			else
				var/obj/item/I = usr.get_active_hand()
				if(istype(I, /obj/item/paper) || istype(I, /obj/item/photo) || istype(I, /obj/item/paper_bundle))
					usr.drop_transfer_item_to_loc(I, src)
					copyitem = I
					to_chat(usr, "<span class='notice'>You insert [I] into [src].</span>")
					flick(insert_anim, src)
				else
					to_chat(usr, "<span class='warning'>[src] only accepts paper, paper bundles, and photos.</span>")
					. = FALSE
		if("rename") // rename the item that is currently in the fax machine
			if(copyitem)
				var/n_name = tgui_input_text(usr, "What would you like to label the fax?", "Fax Labelling", copyitem.name)
				if(!n_name)
					return
				if((copyitem && copyitem.loc == src && usr.stat == 0))
					if(istype(copyitem, /obj/item/paper))
						copyitem.name = "[(n_name ? text("[n_name]") : initial(copyitem.name))]"
						copyitem.desc = "This is a paper titled '" + copyitem.name + "'."
					else if(istype(copyitem, /obj/item/photo))
						copyitem.name = "[(n_name ? text("[n_name]") : "photo")]"
					else if(istype(copyitem, /obj/item/paper_bundle))
						copyitem.name = "[(n_name ? text("[n_name]") : "paper")]"
					else
						. = FALSE
				else
					. = FALSE
			else
				. = FALSE
		if("dept") // choose which department receives the fax
			if(is_authenticated)
				var/lastdestination = destination
				var/list/combineddepartments = GLOB.alldepartments.Copy()
				if(long_range_enabled)
					combineddepartments += GLOB.admin_departments.Copy()
					if(z == level_name_to_num(CENTCOMM))
						for(var/obj/machinery/photocopier/faxmachine/F in GLOB.allfaxes)
							if(F.ussp_restricted)
								combineddepartments |= F.department
				if(emagged)
					combineddepartments += GLOB.hidden_admin_departments.Copy()
					combineddepartments += GLOB.hidden_departments.Copy()
				if(syndie_restricted)
					combineddepartments = GLOB.hidden_admin_departments.Copy()
					combineddepartments += GLOB.hidden_departments.Copy()
					for(var/obj/machinery/photocopier/faxmachine/F in GLOB.allfaxes)
						if(F.emagged)//we can contact emagged faxes on the station
							combineddepartments |= F.department
				if(ussp_restricted)
					combineddepartments = GLOB.hidden_ussp.Copy()
					for(var/obj/machinery/photocopier/faxmachine/F in GLOB.allfaxes)
						if(F.ussp_restricted)
							combineddepartments |= F.department
				destination = tgui_input_list(usr, "To which department?", "Choose a department", combineddepartments)
				if(!destination)
					destination = lastdestination
		if("send") // actually send the fax
			if(!copyitem || !is_authenticated || !destination)
				return
			if(stat & (BROKEN|NOPOWER))
				return

			var/cooldown_seconds = cooldown_seconds()
			if(cooldown_seconds > 0)
				playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
				to_chat(usr, "<span class='warning'>[src] is not ready for another [cooldown_seconds] seconds.</span>")
				return

			if((destination in GLOB.admin_departments) || (destination in GLOB.hidden_admin_departments) || (destination in GLOB.hidden_ussp))
				sendcooldown = world.time + cooldown_time
				SStgui.update_uis(src)
				send_admin_fax(usr, destination)
			else
				sendcooldown = world.time + cooldown_time_local
				SStgui.update_uis(src)
				sendfax(destination, usr)
	if(.)
		add_fingerprint(usr)


/obj/machinery/photocopier/faxmachine/proc/scan(obj/item/card/id/card)
	if(scan) // Card is in machine
		if(ishuman(usr))
			scan.forceMove(drop_location())
			if(Adjacent(usr))
				usr.put_in_hands(scan, ignore_anim = FALSE)
			scan = null
			SStgui.update_uis(src)
			return TRUE
		scan.forceMove(drop_location())
		scan = null
		SStgui.update_uis(src)
		return TRUE
	if(!usr || !Adjacent(usr))
		return FALSE
	if(!card)
		var/obj/item/I = usr.get_active_hand()
		if(!istype(I, /obj/item/card/id))
			return FALSE
		if(!usr.drop_transfer_item_to_loc(I, src))
			return FALSE
		scan = I
		SStgui.update_uis(src)
		return TRUE
	if(!istype(card))
		return FALSE
	if(!usr.drop_transfer_item_to_loc(card, src))
		return FALSE
	scan = card
	SStgui.update_uis(src)
	return TRUE


/obj/machinery/photocopier/faxmachine/verb/eject_id()
	set name = "Eject ID Card"
	set src in oview(1)

	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return

	if(scan)
		to_chat(usr, "You remove [scan] from [src].")
		scan.forceMove(get_turf(src))
		if(Adjacent(usr))
			usr.put_in_hands(scan, ignore_anim = FALSE)
		scan = null
	else
		to_chat(usr, "There is nothing to remove from [src].")

/obj/machinery/photocopier/faxmachine/proc/sendfax(var/destination,var/mob/sender)
	use_power(active_power_usage)
	var/success = 0
	for(var/obj/machinery/photocopier/faxmachine/F in GLOB.allfaxes)
		if(F.department == destination)
			success = F.receivefax(copyitem)
	if(success)
		var/datum/fax/F = new /datum/fax()
		F.name = copyitem.name
		F.from_department = department
		F.to_department = destination
		F.origin = src
		F.message = copyitem
		F.sent_by = sender
		F.sent_at = world.time

		visible_message("[src] beeps, \"Message transmitted successfully.\"")
	else
		visible_message("[src] beeps, \"Error transmitting message.\"")

/obj/machinery/photocopier/faxmachine/proc/receivefax(var/obj/item/incoming)
	if(stat & (BROKEN|NOPOWER))
		return FALSE

	if(department == "Unknown")
		return FALSE //You can't send faxes to "Unknown"

	flick("faxreceive", src)

	playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, 1)

	// give the sprite some time to flick
	sleep(20)

	if(istype(incoming, /obj/item/paper))
		papercopy(incoming)
	else if(istype(incoming, /obj/item/photo))
		photocopy(incoming)
	else if(istype(incoming, /obj/item/paper_bundle))
		bundlecopy(incoming)
	else
		return FALSE

	use_power(active_power_usage)
	return TRUE

/obj/machinery/photocopier/faxmachine/proc/send_admin_fax(var/mob/sender, var/destination)
	use_power(active_power_usage)

	if(!(istype(copyitem, /obj/item/paper) || istype(copyitem, /obj/item/paper_bundle) || istype(copyitem, /obj/item/photo)))
		visible_message("[src] beeps, \"Error transmitting message.\"")
		return

	var/datum/fax/admin/A = new /datum/fax/admin()
	A.name = copyitem.name
	A.from_department = department
	A.to_department = destination
	A.origin = src
	A.message = copyitem
	A.sent_by = sender
	A.sent_at = world.time

	//message badmins that a fax has arrived
	switch(destination)
		if("Central Command")
			message_admins(sender, "CENTCOM FAX", destination, copyitem, "#006100")
		if("Syndicate")
			message_admins(sender, "SYNDICATE FAX", destination, copyitem, "#DC143C")
		if("USSP Central Committee")
			message_admins(sender, "USSP FAX", destination, copyitem, "#b60226")
	for(var/obj/machinery/photocopier/faxmachine/F in GLOB.allfaxes)
		if(F.department == destination)
			F.receivefax(copyitem)
	visible_message("[src] beeps, \"Message transmitted successfully.\"")

/obj/machinery/photocopier/faxmachine/proc/cooldown_seconds()
	if(sendcooldown < world.time)
		return 0
	return round((sendcooldown - world.time) / 10)

/obj/machinery/photocopier/faxmachine/proc/message_admins(var/mob/sender, var/faxname, var/faxtype, var/obj/item/sent, font_colour="#9A04D1")
	var/msg = "<span class='boldnotice'><span style='color: [font_colour];>[faxname]: </span> [key_name_admin(sender)] | REPLY: (<a href='byond://?_src_=holder;[faxname == "SYNDICATE FAX" ? "SyndicateReply" : ""]=[sender.UID()][faxname == "USSP FAX" ? "USSPReply" : ""]=[sender.UID()][faxname == "CENTCOM FAX" ? "CentcommReply" : ""]=[sender.UID()]'>RADIO</a>) (<a href='byond://?_src_=holder;AdminFaxCreate=\ref[sender];originfax=\ref[src];faxtype=[faxtype];replyto=\ref[sent]'>FAX</a>) ([ADMIN_SM(sender,"SM")]) | REJECT: (<a href='byond://?_src_=holder;FaxReplyTemplate=[sender.UID()];originfax=\ref[src]'>TEMPLATE</a>) ([ADMIN_BSA(sender,"BSA")]) (<a href='byond://?_src_=holder;EvilFax=[sender.UID()];originfax=\ref[src]'>EVILFAX</a>) </span>: Receiving '[sent.name]' via secure connection... <a href='byond://?_src_=holder;AdminFaxView=\ref[sent]'>view message</a>"
	for(var/client/C in GLOB.admins)
		if(check_rights(R_EVENT, 0, C.mob))
			to_chat(C, msg)
			if(C.prefs.sound & SOUND_ADMINHELP)
				C << 'sound/effects/adminhelp.ogg'

	var/datum/discord_webhook_payload/payload = new()
	if(istype(sent, /obj/item/paper))
		var/obj/item/paper/P = sent
		var/data = sanitize_paper(P)
		var/datum/discord_embed/embed = new()
		embed.embed_title = P.name
		embed.embed_content = data
		embed.embed_colour = replacetext(font_colour, "#", "")
		payload.embeds += embed
		payload.webhook_content = "**\[FAX\]** [sender.client.ckey]/([sender.name]) sent a Paper Fax at [get_area(src)]"
		SSdiscord.send2discord_complex(DISCORD_WEBHOOK_REQUESTS, payload)
	else if(istype(sent, /obj/item/paper_bundle))
		var/obj/item/paper_bundle/bundle = sent
		for(var/obj/item/paper/P in bundle)
			var/datum/discord_embed/embed = new()
			embed.embed_title = P.name
			embed.embed_colour = replacetext(font_colour, "#", "")
			embed.embed_content = sanitize_paper(P)
			payload.embeds += embed
		for(var/obj/item/photo/P in bundle)
			var/datum/discord_embed/embed = new()
			embed.embed_title = P.name
			embed.embed_colour = replacetext(font_colour, "#", "")
			embed.embed_content = P.log_text
			payload.embeds += embed
		payload.webhook_content = "**\[FAX\]** [sender.client.ckey]/([sender.name]) sent a Bundle Fax at [get_area(src)]"
		SSdiscord.send2discord_complex(DISCORD_WEBHOOK_REQUESTS, payload)
	else if(istype(sent, /obj/item/photo))
		var/obj/item/photo/P = sent
		var/datum/discord_embed/embed = new()
		embed.embed_title = P.name
		embed.embed_colour = font_colour
		embed.embed_content = P.log_text
		payload.embeds += embed
		payload.webhook_content = "**\[FAX\]** [sender.client.ckey]/([sender.name]) sent a Photo at [get_area(src)]"
		SSdiscord.send2discord_complex(DISCORD_WEBHOOK_REQUESTS, payload)

/obj/machinery/photocopier/faxmachine/proc/sanitize_paper(obj/item/paper/paper) // html to discord markdown-101
	var/text = "[paper.header][paper.info][paper.footer]"
	text = replacetext(text, "<br>", "\n")
	text = replacetext(text, "</u>", "__")
	text = replacetext(text, "<b>", "**")
	text = replacetext(text, "</b>", "**")
	text = replacetext(text, "<i>", "*")
	text = replacetext(text, "</i>", "*")
	text = replacetext(text, "<u>", "__")
	text = replacetext(text, "</u>", "__")
	text = replacetext(text, "<span class=\"paper_field\"></span>", "`_FIELD_`")

	text = replacetext(text, "<h1>", "# ")
	text = replacetext(text, "<H2>", "## ")
	text = replacetext(text, "<H3>", "### ")

	text = replacetext(text, "<li>", "- ")
	text = replacetext(text, "<hr>", "\n`----- Horizontal Rule -----`\n")
	text = replacetext(text, "<table border=1 cellspacing=0 cellpadding=3 style='border: 1px solid black;'>", "`_TABLE START_`\n")
	text = replacetext(text, "<table>", "`_GRID START_`\n")
	text = replacetext(text, "<tr>", "\n") // starts table, \ns it when splits every cell with |
	text = replacetext(text, "<td>", " | ")
	text = replacetext(text, "<table>", "`_TABLE END_`\n")
	text = replacetext(text, "<img src = ntlogo.png>", "` NT LOGO `\n")
	text = replacetext(text, "<img src = syndielogo.png>", "` SYNDIE LOGO `\n")
	text = replacetextEx(text, "<img src = syndielogo.png>", "` SYNDIE LOGO `\n")
	var/textstamps = paper.stamps
	for(var/obj/item/stamp/stamp_path as anything in paper.stamped)
		if(ispath(stamp_path, /obj/item/stamp/chameleon))
			var/text_stamp = replacetext(textstamps, regex(".*?<img src=large_stamp-(.*?).png>.*"), "$1") // pops from textstamps.
			textstamps = replacetext(textstamps, regex("<img src=large_stamp-.*?.png>"), "")
			text += "` [text_stamp] (CHAMELEON) stamp `"
		else
			text += "` [replacetext(replacetext(initial(stamp_path.name), "rubber", ""), "'s", "")] `"

	return strip_html_properly(text, MAX_PAPER_MESSAGE_LEN, TRUE) //So satisfying that max paper length equals max description disorcd

/obj/machinery/photocopier/faxmachine/proc/become_mimic()
	if(scan)
		scan.forceMove(get_turf(src))
	var/mob/living/simple_animal/hostile/mimic/copy/M = new(loc, src, null, 1) // it will delete src on creation and override any machine checks
	M.name = "angry fax machine"
