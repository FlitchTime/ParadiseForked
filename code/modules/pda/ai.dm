// Special AI/pAI PDAs that cannot explode.
/obj/item/pda/silicon
	icon_state = "NONE"
	detonate = 0
	ttone = "data"


/obj/item/pda/silicon/proc/set_name_and_job(newname as text, newjob as text, newrank as null|text)
	owner = newname
	ownjob = newjob
	if(newrank)
		ownrank = newrank
	else
		ownrank = ownjob

	custom_name = newname
	update_appearance(UPDATE_NAME)


/obj/item/pda/silicon/verb/cmd_send_pdamesg()
	set category = "AI IM"
	set name = "Send PDA Message"
	set src in usr

	if(!can_use(usr))
		return
	var/datum/data/pda/app/messenger/M = find_program(/datum/data/pda/app/messenger)
	if(!M)
		to_chat(usr, span_warning("Cannot use messenger!"))
	var/list/plist = M.available_pdas()
	if(plist)
		var/c = tgui_input_list(usr, "Please select a PDA", "Send message", sortList(plist))
		if(!c) // if the user hasn't selected a PDA file we can't send a message
			return
		var/selected = plist[c]
		M.create_message(usr, selected)

/obj/item/pda/silicon/verb/cmd_show_message_log()
	set category = "AI IM"
	set name = "Show Message Log"
	set src in usr

	if(!can_use(usr))
		return
	var/datum/data/pda/app/messenger/M = find_program(/datum/data/pda/app/messenger)
	if(!M)
		to_chat(usr, span_warning("Cannot use messenger!"))
	var/HTML = ""
	for(var/index in M.tnote)
		var/obj/item/pda/target_pda = locateUID(index["target"])
		HTML += "<i><b>[index["sent"] ? "&rarr; To" : "&larr; From"] <a href='byond://?src=[M.UID()];choice=Message;target=[index["target"]]'>[QDELETED(target_pda) ? "Error#1133: Unable to find UserName." : "[target_pda.owner] ([target_pda.ownjob])"]</a>:</b></i><br>[index["message"]]<br>"
	var/datum/browser/popup = new(usr, "log", "AI PDA Message Log", 400, 444)
	popup.set_window_options("border=1;can_resize=1;can_close=1;can_minimize=0")
	popup.set_content(HTML)
	popup.open(FALSE)

/obj/item/pda/silicon/verb/cmd_toggle_pda_receiver()
	set category = "AI IM"
	set name = "Toggle Sender/Receiver"
	set src in usr

	if(!can_use(usr))
		return
	var/datum/data/pda/app/messenger/M = find_program(/datum/data/pda/app/messenger)
	M.toff = !M.toff
	to_chat(usr, "<span class='notice'>PDA sender/receiver toggled [(M.toff ? "Off" : "On")]!</span>")


/obj/item/pda/silicon/verb/cmd_toggle_pda_silent()
	set category = "AI IM"
	set name = "Toggle Ringer"
	set src in usr

	if(!can_use(usr))
		return
	var/datum/data/pda/app/messenger/M = find_program(/datum/data/pda/app/messenger)
	M.notify_silent = !M.notify_silent
	to_chat(usr, "<span class='notice'>PDA ringer toggled [(M.notify_silent ? "Off" : "On")]!</span>")

/obj/item/pda/silicon/attack_self(mob/user as mob)
	if((honkamt > 0) && (prob(60)))//For clown virus.
		honkamt--
		playsound(loc, 'sound/items/bikehorn.ogg', 30, 1)
	return

/obj/item/pda/silicon/ai/can_use()
	var/mob/living/silicon/ai/AI = usr
	if(!istype(AI))
		return 0
	return ..() && !AI.check_unable(AI_CHECK_WIRELESS)

/obj/item/pda/silicon/robot/can_use()
	var/mob/living/silicon/robot/R = usr
	if(!istype(R))
		return 0
	return ..() && R.cell.charge > 0

/obj/item/pda/silicon/pai
	ttone = "assist"

/obj/item/pda/silicon/pai/can_use()
	var/mob/living/silicon/pai/pAI = usr
	if(!istype(pAI))
		return FALSE
	if(!pAI.installed_software["messenger"])
		to_chat(usr, "<span class='warning'>You have not purchased the digital messenger!</span>")
		return FALSE
	return ..() && !pAI.silence_time
