/mob/living/silicon/ai/examine(mob/user)
	. = ..()
	var/msg = "<span class='notice'>"
	if(src.stat == DEAD)
		msg += "<span class='deadsay'>It appears to be powered-down.</span>\n"
	else
		msg += "<span class='warning'>"
		if(src.getBruteLoss())
			if(src.getBruteLoss() < 30)
				msg += "It looks slightly dented.\n"
			else
				msg += "<b>It looks severely dented!</b>\n"
		if(src.getFireLoss())
			if(src.getFireLoss() < 30)
				msg += "It looks slightly charred.\n"
			else
				msg += "<b>Its casing is melted and heat-warped!</b>\n"
		if(src.stat == UNCONSCIOUS)
			msg += "It is non-responsive and displaying the text: \"RUNTIME: Sensory Overload, stack 26/3\".\n"
		if(!shunted && !client)
			msg += "[src]Core.exe has stopped responding! NTOS is searching for a solution to the problem...\n"
		msg += "</span>"
	msg += "</span>"

	. += msg
	user.showLaws(src)


/mob/proc/showLaws(var/mob/living/silicon/S)
	return

/mob/dead/observer/showLaws(var/mob/living/silicon/S)
	if(antagHUD || check_rights(R_ADMIN, 0, src))
		S.laws.show_laws(src)
