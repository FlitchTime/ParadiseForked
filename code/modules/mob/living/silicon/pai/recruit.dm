// Recruiting observers to play as pAIs

GLOBAL_DATUM_INIT(paiController, /datum/paiController, new) // Global handler for pAI candidates

/datum/paiCandidate
	var/name
	var/key
	var/description
	var/role
	var/comments
	var/ready = 0

/datum/paiController
	var/list/pai_candidates = list()
	var/list/asked = list()
	var/list/paicards
	var/summon_cooldown = 0

	var/askDelay = 10 * 60 * 1	// One minute [ms * sec * min]

/datum/paiController/Topic(href, href_list[])

	var/datum/paiCandidate/candidate = locateUID(href_list["candidate"])

	if(candidate)
		if(!istype(candidate))
			message_admins("Warning: possible href exploit by [ADMIN_LOOKUPFLW(usr)] (paiController/Topic, candidate is not a pAI)")
			log_debug("Warning: possible href exploit by [key_name_log(usr)] (paiController/Topic, candidate is not a pAI)")
			return

	if(href_list["download"])
		var/obj/item/paicard/card = locate(href_list["device"])
		if(card.pai)
			return
		if(usr.incapacitated() || isobserver(usr) || !card.Adjacent(usr))
			return
		if(istype(card, /obj/item/paicard) && istype(candidate, /datum/paiCandidate))
			var/mob/living/silicon/pai/pai = new(card)
			if(!candidate.name)
				pai.name = pick(GLOB.ninja_names)
			else
				pai.name = candidate.name
			pai.real_name = pai.name
			pai.key = candidate.key
			card.setPersonality(pai)
			card.looking_for_personality = 0

			pai_candidates -= candidate
			close_window(usr, "findPai")
			close_window(usr, "paicard")
		return

	if("signup" in href_list)
		var/mob/dead/observer/O = locate(href_list["signup"])
		if(!O)
			O = usr
			if(!istype(O))
				return

		if(!(O in GLOB.respawnable_list))
			to_chat(O, span_notice("Вы отказались от возможности возрождения!"))
			return
		if(!check_recruit(O))
			return
		recruitWindow(O)
		return

	if(candidate)
		if(candidate.key && usr.key && candidate.key != usr.key)
			message_admins("Warning: possible href exploit by [ADMIN_LOOKUPFLW(usr)] (paiController/Topic, candidate and usr have different keys)")
			log_debug("Warning: possible href exploit by [key_name_log(usr)] (paiController/Topic, candidate and usr have different keys)")
			return

	if(href_list["new"])
		var/option = href_list["option"]
		var/t = ""

		switch(option)
			if("name")
				t = tgui_input_text(usr, "Enter a name for your pAI", "pAI Name", candidate.name, MAX_NAME_LEN)
				if(isnull(t))
					return
				candidate.name = t
			if("desc")
				t = tgui_input_text(usr, "Enter a description for your pAI", "pAI Description", candidate.description, multiline = TRUE)
				if(isnull(t))
					return
				candidate.description = t
			if("role")
				t = tgui_input_text(usr, "Enter a role for your pAI", "pAI Role", candidate.role)
				if(isnull(t))
					return
				candidate.role = t
			if("ooc")
				t = tgui_input_text(usr, "Enter any OOC comments", "pAI OOC Comments", candidate.comments, multiline = TRUE)
				if(isnull(t))
					return
				candidate.comments = t
			if("save")
				candidate.savefile_save(usr)
			if("load")
				candidate.savefile_load(usr)
				//In case people have saved unsanitized stuff.
				if(candidate.name)
					candidate.name = sanitize(copytext_char(candidate.name,1,MAX_NAME_LEN))
				if(candidate.description)
					candidate.description = sanitize(copytext_char(candidate.description,1,MAX_MESSAGE_LEN))
				if(candidate.role)
					candidate.role = sanitize(copytext_char(candidate.role,1,MAX_MESSAGE_LEN))
				if(candidate.comments)
					candidate.comments = sanitize(copytext_char(candidate.comments,1,MAX_MESSAGE_LEN))

			if("submit")
				if(candidate)
					candidate.ready = !candidate.ready
					if(candidate.ready)
						to_chat(usr, span_notice("Вы отправили заявку на становление пИИ."))
						for(var/obj/item/paicard/p in paicards)
							if(p.looking_for_personality)
								p.alertUpdate()
					else
						to_chat(usr, span_notice("Вы отменили заявку на становление пИИ."))

				close_window(usr, "paiRecruit")
				return
		recruitWindow(usr)


/datum/paiController/proc/recruitWindow(var/mob/M as mob)
	var/datum/paiCandidate/candidate
	for(var/datum/paiCandidate/c in pai_candidates)
		if(!istype(c) || !istype(M))
			break
		if(c.key == M.key)
			candidate = c
	if(!candidate)
		candidate = new /datum/paiCandidate()
		candidate.key = M.key
		pai_candidates.Add(candidate)


	var/dat = ""

	dat += {"
		<b><font size="3px">pAI Personality Configuration</font></b>
		<p class="top">Please configure your pAI personality's options. Remember, what you enter here could determine whether or not the user requesting a personality chooses you!</p>

		<table>
			<tr class="d0">
				<th rowspan="2"><a href='byond://?src=[UID()];option=name;new=1;candidate=[candidate.UID()]'>Name</a>:</th>
				<td class="desc">[candidate.name]&nbsp;</td>
			</tr>
			<tr class="d1">
				<td>What you plan to call yourself. Suggestions: Any character name you would choose for a station character OR an AI.</td>
			</tr>
			<tr class="d0">
				<th rowspan="2"><a href='byond://?src=[UID()];option=desc;new=1;candidate=[candidate.UID()]'>Description</a>:</th>
				<td class="desc">[candidate.description]&nbsp;</td>
			</tr>
			<tr class="d1">
				<td>What sort of pAI you typically play; your mannerisms, your quirks, etc. This can be as sparse or as detailed as you like.</td>
			</tr>
			<tr class="d0">
				<th rowspan="2"><a href='byond://?src=[UID()];option=role;new=1;candidate=[candidate.UID()]'>Preferred Role</a>:</th>
				<td class="desc">[candidate.role]&nbsp;</td>
			</tr>
			<tr class="d1">
				<td>Do you like to partner with sneaky social ninjas? Like to help security hunt down thugs? Enjoy watching an engineer's back while he saves the station yet again? This doesn't have to be limited to just station jobs. Pretty much any general descriptor for what you'd like to be doing works here.</td>
			</tr>
			<tr class="d0">
				<th rowspan="2"><a href='byond://?src=[UID()];option=ooc;new=1;candidate=[candidate.UID()]'>OOC Comments</a>:</th>
				<td class="desc">[candidate.comments]&nbsp;</td>
			</tr>
			<tr class="d1">
				<td>Anything you'd like to address specifically to the player reading this in an OOC manner. \"I prefer more serious RP.\", \"I'm still learning the interface!\", etc. Feel free to leave this blank if you want.</td>
			</tr>
		</table>
		<br>
		<table>
			<tr>
				<td class="button">
					<a href='byond://?src=[UID()];option=save;new=1;candidate=[candidate.UID()]' class="button">Save Personality</a>
				</td>
			</tr>
			<tr>
				<td class="button">
					<a href='byond://?src=[UID()];option=load;new=1;candidate=[candidate.UID()]' class="button">Load Personality</a>
				</td>
			</tr>
		</table><br>
		<table>
			<td class="button"><a href='byond://?src=[UID()];option=submit;new=1;candidate=[candidate.UID()]' class="button"><b><font size="4px">[candidate.ready ? "Reset personality" : "Submit personality"]</font></b></a></td>
		</table><br>
	"}

	var/datum/browser/popup = new(M, "paiRecruit", "PAI Recruit", 580, 580)
	popup.set_content(dat)
	popup.add_stylesheet("pai_recruit", 'html/css/pai_recruit.css')
	popup.open(FALSE)

/datum/paiController/proc/findPAI(var/obj/item/paicard/p, var/mob/user)
	requestRecruits(p, user)
	var/list/available = list()
	for(var/datum/paiCandidate/c in GLOB.paiController.pai_candidates)
		if(c.ready)
			var/found = 0
			for(var/mob/o in GLOB.respawnable_list)
				if(o.key == c.key)
					found = 1
			if(found)
				available.Add(c)
	var/dat = ""

	dat += {"
				<b><font size='3px'>pAI Availability List</font></b><br><br>
	"}
	dat += "<p>Displaying available AI personalities from central database... If there are no entries, or if a suitable entry is not listed, check again later as more personalities may be added.</p>"

	for(var/datum/paiCandidate/c in available)
		dat += {"
				<table class="desc">
					<tr class="d0">
						<th>Name:</th>
						<td>[c.name]</td>
					</tr>
					<tr class="d1">
						<th>Description:</th>
						<td>[c.description]</td>
					</tr>
					<tr class="d0">
						<th>Preferred Role:</th>
						<td>[c.role]</td>
					</tr>
					<tr class="d1">
						<th>OOC Comments:</th>
						<td>[c.comments]</td>
					</tr>
				</table>
				<table class="download">
					<td class="download"><a href='byond://?src=[UID()];download=1;candidate=[c.UID()];device=\ref[p]' class="button"><b>Download [c.name]</b></a>
					</td>
				</table>
				<br>
		"}
	var/datum/browser/popup = new(user, "findPai", "Find PAI")
	popup.set_content(dat)
	popup.add_stylesheet("find_pai", 'html/css/find_pai.css')
	popup.open(FALSE)

/datum/paiController/proc/requestRecruits(obj/item/paicard/P, mob/user)
	for(var/mob/dead/observer/O in GLOB.player_list)
		if(O.client && (ROLE_PAI in O.client.prefs.be_special))
			if(player_old_enough_antag(O.client,ROLE_PAI))
				if(check_recruit(O))
					to_chat(O, "<span class='boldnotice'>A [(P.is_syndicate_type) ? "Syndicate" : ""]  pAI card activated by [user.real_name] is looking for personalities. (<a href='byond://?src=[O.UID()];jump=\ref[P]'>Teleport</a> | <a href='byond://?src=[UID()];signup=\ref[O]'>Sign Up</a>)</span>")
	if(P.is_syndicate_type)
		if(summon_cooldown > world.time)
			return
		var/image/alert_overlay = image('icons/obj/aicards.dmi', "ghostalert")
		notify_ghosts("[user] activated [user.p_their()] Syndicate pAI card, calling for your help!", enter_link="<a href='byond://?src=[UID()];signup=1'>(Click to Sign Up)</a>", source = P, alert_overlay = alert_overlay, action = NOTIFY_ATTACK)
		summon_cooldown = world.time + 60 SECONDS

/datum/paiController/proc/check_recruit(var/mob/dead/observer/O)
	if(jobban_isbanned(O, ROLE_PAI) || jobban_isbanned(O,"nonhumandept"))
		return 0
	if(!player_old_enough_antag(O.client,ROLE_PAI))
		return 0
	if(cannotPossess(O))
		return 0
	if(O.client)
		return 1
	return 0

/datum/paiController/proc/question(var/client/C)
	spawn(0)
		if(!C)	return
		asked.Add(C.key)
		asked[C.key] = world.time
		var/response = tgui_alert(C, "Someone is requesting a pAI personality. Would you like to play as a personal AI?", "pAI Request", list("Yes", "No", "Never for this round"))
		if(!C)	return		//handle logouts that happen whilst the alert is waiting for a response.
		if(response == "Yes")
			recruitWindow(C.mob)
		else if(response == "Never for this round")
			var/warning = tgui_alert(C, "Someone is requesting a pAI personality. Would you like to play as a personal AI?", "pAI Request", list("Yes", "No", "Never for this round"))
			if(warning == "Yes")
				asked[C.key] = INFINITY
			else
				question(C)
