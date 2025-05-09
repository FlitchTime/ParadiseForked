//This is a list of words which are ignored by the parser when comparing message contents for names. MUST BE IN LOWER CASE!
GLOBAL_LIST_INIT(adminhelp_ignored_words, list("unknown", "the", "a", "an", "of", "monkey", "alien", "as"))

/client/verb/adminhelp()
	set category = "Admin.Admin Tickets"
	set name = "Adminhelp"

	//handle muting and automuting
	if(check_mute(ckey, MUTE_ADMINHELP))
		to_chat(src, "<font color='red'>Error: Admin-PM: You cannot send adminhelps (Muted).</font>", MESSAGE_TYPE_ADMINPM, confidential = TRUE)
		return

	adminhelped = TRUE //Determines if they get the message to reply by clicking the name.

	var/msg
	var/list/type = list("Mentorhelp", "Adminhelp")
	var/selected_type = tgui_input_list(src, "Pick a category.", "Admin Help", type)
	if(selected_type)
		msg = tgui_input_text(src, "Please enter your message.", selected_type, multiline = TRUE, encode = FALSE)

	if(!msg)
		return

	if(handle_spam_prevention(msg, MUTE_ADMINHELP, OOC_COOLDOWN))
		return

	msg = sanitize_simple(copytext_char(msg, 1, MAX_MESSAGE_LEN))
	msg = sanitize_censored_patterns(msg)
	if(!msg) // No message after sanitisation
		return

	if(selected_type == "Mentorhelp")
		SSmentor_tickets.newHelpRequest(src, msg) // Mhelp
	else
		SStickets.newHelpRequest(src, msg) // Ahelp

	//show it to the person adminhelping too
	to_chat(src, span_boldnotice("[selected_type]</b>: [msg]"), MESSAGE_TYPE_ADMINPM, confidential = TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Adminhelp") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

	switch(selected_type)
		if("Adminhelp")
			//See how many staff are on
			var/list/admincount = staff_countup(R_BAN)
			var/active_admins = admincount[1]

			log_admin("[selected_type]: [key_name(src)]: [msg] - heard by [active_admins] non-AFK admins.")
			SSdiscord.send2discord_simple_noadmins("**\[Adminhelp]** [key_name(src)]: [msg]", check_send_always = TRUE)

		if("Mentorhelp")
			var/alerttext
			var/list/mentorcount = staff_countup(R_MENTOR)
			var/active_mentors = mentorcount[1]
			var/inactive_mentors = mentorcount[3]

			if(active_mentors <= 0)
				if(inactive_mentors)
					alerttext = " | **ALL MENTORS AFK**"
				else
					alerttext = " | **NO MENTORS ONLINE**"

			log_admin("[selected_type]: [key_name(src)]: [msg] - heard by [active_mentors] non-AFK mentors.")
			SSdiscord.send2discord_simple(DISCORD_WEBHOOK_MENTOR, "[key_name(src)]: [msg][alerttext]")
