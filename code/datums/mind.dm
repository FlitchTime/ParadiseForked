/*	Note from Carnie:
		The way datum/mind stuff works has been changed a lot.
		Minds now represent IC characters rather than following a client around constantly.
	Guidelines for using minds properly:
	-	Never mind.transfer_to(ghost). The var/current and var/original of a mind must always be of type mob/living!
		ghost.mind is however used as a reference to the ghost's corpse
	-	When creating a new mob for an existing IC character (e.g. cloning a dead guy or borging a brain of a human)
		the existing mind of the old mob should be transfered to the new mob like so:
			mind.transfer_to(new_mob)
	-	You must not assign key= or ckey= after transfer_to() since the transfer_to transfers the client for you.
		By setting key or ckey explicitly after transfering the mind with transfer_to you will cause bugs like DCing
		the player.
	-	IMPORTANT NOTE 2, if you want a player to become a ghost, use mob.ghostize() It does all the hard work for you.
	-	When creating a new mob which will be a new IC character (e.g. putting a shade in a construct or randomly selecting
		a ghost to become a xeno during an event). Simply assign the key or ckey like you've always done.
			new_mob.key = key
		The Login proc will handle making a new mob for that mobtype (including setting up stuff like mind.name). Simple!
		However if you want that mind to have any special properties like being a traitor etc you will have to do that
		yourself.
*/

/datum/mind
	var/key
	/// Replaces mob/var/original_name
	var/name
	/// Current mob of our mind.
	var/mob/living/current
	/// The original mob's UID. Used for example to see if a silicon with antag status is actually malf. Or just an antag put in a borg.
	var/original_mob_UID
	/// The original mob's name. Used in dead chat messages.
	var/original_mob_name

	var/active = FALSE

	var/memory

	var/assigned_role //assigned role is what job you're assigned to when you join the station.
	var/playtime_role //if set, overrides your assigned_role for the purpose of playtime awards. Set by IDcomputer when your ID is changed.
	var/special_role //special roles are typically reserved for antags or roles like ERT. If you want to avoid a character being automatically announced by the AI, on arrival (becuase they're an off station character or something); ensure that special_role and assigned_role are equal.
	var/offstation_role = FALSE //set to true for ERT, deathsquad, abductors, etc, that can go from and to z2 at will and shouldn't be antag targets
	var/list/restricted_roles = list()

	var/rev_cooldown = 0

	var/list/spell_list
	var/datum/martial_art/martial_art
	var/list/known_martial_arts = list()

	var/role_alt_title

	var/datum/job/assigned_job
	var/list/datum/objective/objectives = list()
	var/list/datum/objective/special_verbs = list()

	var/list/targets = list()

	var/has_been_rev = 0//Tracks if this mind has been a rev or not

	var/miming = 0 // Mime's vow of silence
	var/list/antag_datums

	var/antag_hud_icon_state = null //this mind's ANTAG_HUD should have this icon_state
	var/datum/atom_hud/antag/antag_hud = null //this mind's antag HUD
	var/datum/mindslaves/som //stands for slave or master...hush..
	var/damnation_type = 0
	var/datum/mind/soulOwner //who owns the soul.  Under normal circumstances, this will point to src
	var/hasSoul = TRUE

	var/isholy = FALSE // is this person a chaplain or admin role allowed to use bibles
	var/isblessed = FALSE // is this person blessed by a chaplain?
	var/num_blessed = 0 // for prayers

	var/lost_memory = FALSE // for the memorizers

	var/suicided = FALSE

	//put this here for easier tracking ingame
	var/datum/money_account/initial_account

	//zealot_master is a reference to the mob that converted them into a zealot (for ease of investigation and such)
	var/mob/living/carbon/human/zealot_master = null

	var/list/learned_recipes //List of learned recipe TYPES.

	var/ambition_limit = 6 //Лимит амбиций

	var/list/curses


/datum/mind/New(new_key)
	key = new_key
	soulOwner = src


/datum/mind/Destroy()
	SSticker.minds -= src

	for(var/datum/antagonist/antag as anything in antag_datums)
		if(QDELETED(antag))
			continue

		if(!antag.delete_on_mind_deletion)
			continue

		qdel(antag)

	current = null
	soulOwner = null
	return ..()


/datum/mind/proc/set_original_mob(mob/original)
	original_mob_UID = original.UID()


/datum/mind/proc/is_original_mob(mob/o_mob)
	return original_mob_UID == o_mob.UID()


// Do not use for admin related things as this can hide the mob's ckey
/datum/mind/proc/get_display_key()
	// Lets try find a client so we can check their prefs
	var/client/C = null

	var/cannonical_key = ckey(key)

	if(current?.client)
		// Active client
		C = current.client
	else if(cannonical_key in GLOB.directory)
		// Do a directory lookup on the last ckey this mind had
		// If theyre online we can grab them still and check prefs
		C = GLOB.directory[cannonical_key]

	// Ok we found a client, be it their active or their last
	// Now we see if we need to respect their privacy
	var/out_ckey
	if(C)
		if(C.prefs.toggles2 & PREFTOGGLE_2_ANON)
			out_ckey = "(Anon)"
		else
			out_ckey = C.ckey
	else
		// No client. Just mark as DC'd.
		out_ckey = "(Disconnected)"

	return out_ckey


/datum/mind/proc/transfer_to(mob/living/new_character)
	if(!istype(new_character))
		stack_trace("transfer_to(): Some idiot has tried to transfer_to() a non mob/living mob.")

	var/datum/atom_hud/antag/hud_to_transfer = antag_hud // we need this because leave_hud() will clear this list
	var/mob/living/old_current = current

	if(current)					// remove ourself from our old body's mind variable
		current.mind = null
		leave_all_huds() // leave all the huds in the old body, so it won't get huds if somebody else enters it

		SStgui.on_transfer(current, new_character)

	if(new_character.mind)		// remove any mind currently in our new body's mind variable
		new_character.mind.current = null

	current = new_character		// link ourself to our new body
	new_character.mind = src	// and link our new body to ourself

	transfer_antag_huds(hud_to_transfer)				// inherit the antag HUD
	transfer_actions(new_character, old_current)

	if(martial_art)
		for(var/datum/martial_art/MA in known_martial_arts)
			MA.remove(current)
			if(old_current)
				MA.remove_martial_art_verbs(old_current)
			if(!MA.temporary)
				MA.teach(current)

	for(var/datum/antagonist/antag in antag_datums)	// Makes sure all antag datums effects are applied in the new body
		antag.on_body_transfer(old_current, current)

	if(active)
		new_character.set_key(key)		// now transfer the key to link the client to our new body

	// essential mob updates
	new_character.update_blind_effects()
	new_character.update_blurry_effects()
	new_character.update_sight()
	new_character.hud_used?.reload_fullscreen()
	new_character.reload_huds()

	SEND_SIGNAL(src, COMSIG_MIND_TRANSER_TO, new_character)
	SEND_SIGNAL(new_character, COMSIG_BODY_TRANSFER_TO)


/datum/mind/proc/store_memory(new_text)
	memory += "[new_text]<br>"


/datum/mind/proc/wipe_memory()
	memory = null


/datum/mind/proc/show_memory(mob/recipient, window = TRUE)
	if(!recipient)
		recipient = current
	var/output = {"<b>[name]'s Memories:</b><hr>"}
	output += memory

	var/antag_datum_objectives = FALSE
	for(var/datum/antagonist/antag in antag_datums)
		output += antag.antag_memory
		if(!antag_datum_objectives && LAZYLEN(antag.objectives))
			antag_datum_objectives = TRUE

	if(LAZYLEN(objectives) || antag_datum_objectives)
		output += "<hr><b>Objectives:</b><br>"
		output += gen_objective_text()

	if(LAZYLEN(job_objectives))
		output += "<hr><b>Job Objectives:</b><ul>"

		var/obj_count = 1
		for(var/datum/job_objective/objective in job_objectives)
			output += "<li><b>Task #[obj_count]</b>: [objective.get_description()]</li>"
			obj_count++
		output += "</ul>"

	if(iscarbon(current))
		// Кнопки для амбиций и их отображение
		output += "<hr><b>Амбиции:</b><ul>"
		if(LAZYLEN(ambition_objectives))

			var/amb_count = 1
			for(var/datum/ambition_objective/objective in ambition_objectives)
				output += "<li><b>Амбиция #[amb_count]</b>: [objective.description]</li>"
				output += "<a href='byond://?src=[UID()];amb_delete=\ref[objective]'>Удалить</a> " // Удалить амбицию
				output += "<a href='byond://?src=[UID()];amb_completed=\ref[objective]'>" // Определить завершенность амбиции
				output += "<font color=[objective.completed ? "green" : "red"]>[objective.completed ? "Передумать" : "Выполнить"]</font>"
				output += "</a>"
				output += "<br>"
				amb_count++
		output += "<a href='byond://?src=[UID()];amb_add=1'>Добавить амбицию</a><br><br>"
		output += "</ul>"

	if(window)
		var/datum/browser/popup = new(recipient, "memory", "[name]'s Memories")
		popup.set_content(output)
		popup.open(FALSE)
	else
		to_chat(recipient, "<i>[output]</i>")


/datum/mind/proc/gen_objective_text(admin = FALSE)
	. = ""
	var/obj_count = 1

	// If they don't have any objectives, "" will be returned.
	for(var/datum/objective/objective in get_all_objectives())
		. += "<b>Objective #[obj_count++]</b>: [objective.explanation_text]"
		if(admin)
			. += " <a href='byond://?src=[UID()];obj_edit=\ref[objective]'>Edit</a> " // Edit
			. += "<a href='byond://?src=[UID()];obj_delete=\ref[objective]'>Delete</a> " // Delete

			. += "<a href='byond://?src=[UID()];obj_completed=\ref[objective]'>" // Mark Completed
			. += "<font color=[objective.completed ? "green" : "red"]>Toggle Completion</font>"
			. += "</a>"
		. += "<br>"


/**
 * Gets every objective this mind owns, including all of those from any antag datums they have, and returns them as a list.
 */
/datum/mind/proc/get_all_objectives()
	var/list/all_objectives = list()

	for(var/datum/antagonist/antag in antag_datums)
		all_objectives += antag.objectives	// Add all antag datum objectives.

	for(var/datum/objective/objective in objectives)
		all_objectives += objective // Add all mind objectives.

	return all_objectives


/**
 * Completely remove the given objective from the src mind and it's antag datums.
 */
/datum/mind/proc/remove_objective(datum/objective/objective, qdel_on_remove = FALSE)
	for(var/datum/antagonist/antag in antag_datums)
		antag.objectives -= objective
	objectives -= objective
	if(qdel_on_remove)
		qdel(objective)


/**
 * Completely remove ALL objectives from the src mind and it's antag datums.
 */
/datum/mind/proc/remove_all_objectives(qdel_on_remove = FALSE)
	for(var/datum/objective/objective in get_all_objectives())
		remove_objective(objective, qdel_on_remove)


/datum/mind/proc/_memory_edit_header(gamemode, list/alt)
	. = gamemode
	if(SSticker.mode.config_tag == gamemode || (LAZYLEN(alt) && (SSticker.mode.config_tag in alt)))
		. = uppertext(.)
	. = "<i><b>[.]</b></i>: "

/datum/mind/proc/_memory_edit_role_enabled(role)
	. = "|Disabled in Prefs"
	if(current && current.client && (role in current.client.prefs.be_special))
		. = "|Enabled in Prefs"

/datum/mind/proc/memory_edit_implant(mob/living/carbon/human/H)
	if(isertmindshielded(H))
		. = "ERT Mindshield Implant:<a href='byond://?src=[UID()];implant=ertremove'>Remove</a>|<b><font color='green'>ERT Implanted</font></b></br>"
	else if(ismindshielded(H))
		. = "Mindshield Implant:<a href='byond://?src=[UID()];implant=remove'>Remove</a>|<b><font color='green'>Implanted</font></b></br>"
	else
		. = "Mindshield Implant:<b>No Implant</b>|<a href='byond://?src=[UID()];implant=add'>Implant [H.p_them()]!</a></br> or <a href='byond://?src=[UID()];implant=ertadd'>ERT implant [H.p_them()]!</a></br>"


/datum/mind/proc/memory_edit_revolution(mob/living/carbon/human/H)
	. = _memory_edit_header("revolution")
	if(src in SSticker.mode.head_revolutionaries)
		. += "<a href='byond://?src=[UID()];revolution=clear'>no</a>|<b><font color='red'>HEADREV</font></b>|<a href='byond://?src=[UID()];revolution=rev'>rev</a>"
		. += " <a href='byond://?src=[UID()];revolution=reequip'>Reequip</a> (gives security HUD and spray can)."
		if(!length(objectives))
			. += "<br>Objectives are empty! <a href='byond://?src=[UID()];revolution=autoobjectives'>Set to kill all heads</a>."
	else if(src in SSticker.mode.revolutionaries)
		. += "<a href='byond://?src=[UID()];revolution=clear'>no</a>|<a href='byond://?src=[UID()];revolution=headrev'>headrev</a>|<b><font color='red'>REV</font></b>"
	else if(ismindshielded(H))
		. += "<b>NO</b>|headrev|rev"
	else
		. += "<b>NO</b>|<a href='byond://?src=[UID()];revolution=headrev'>headrev</a>|<a href='byond://?src=[UID()];revolution=rev'>rev</a>"

	. += _memory_edit_role_enabled(ROLE_REV)


/datum/mind/proc/memory_edit_cult(mob/living/carbon/human/H)
	. = _memory_edit_header("cult")
	if(src in SSticker.mode.cult)
		. += "<a href='byond://?src=[UID()];cult=clear'>no</a>|<b><font color='red'>CULTIST</font></b>"
		. += "<br>Give <a href='byond://?src=[UID()];cult=dagger'>dagger</a>|<a href='byond://?src=[UID()];cult=runedmetal'>runedmetal</a>."
	else
		. += "<b>NO</b>|<a href='byond://?src=[UID()];cult=cultist'>cultist</a>"

	. += _memory_edit_role_enabled(ROLE_CULTIST)

/datum/mind/proc/memory_edit_clockwork(mob/living/carbon/human/H)
	. = _memory_edit_header("clockwork")
	if(src in SSticker.mode.clockwork_cult)
		. += "<a href='byond://?src=[UID()];clock=clear'>no</a>|<b><font color='red'>CLOCKER</font></b>"
		. += "<br>Give <a href='byond://?src=[UID()];clock=clockslab'>clockslab</a>|<a href='byond://?src=[UID()];clock=brassmetal'>brassmetal</a>."
	else
		. += "<b>NO</b>|<a href='byond://?src=[UID()];clock=clocker'>clocker</a>"

	. += _memory_edit_role_enabled(ROLE_CLOCKER)


/datum/mind/proc/memory_edit_clockwork_silicon()
	. = _memory_edit_header("clockwork")
	if(istype(current, /mob/living/silicon/robot))
		if(src in SSticker.mode.clockwork_cult)
			. += "<a href='byond://?src=[UID()];siliclock=clearrobot'>no</a>|<b><font color='red'>CLOCKER</font></b>"
		else
			. += "<b>NO</b>|<a href='byond://?src=[UID()];siliclock=clockrobot'>clocker</a>"
	else if(istype(current, /mob/living/silicon/ai))
		if(src in SSticker.mode.clockwork_cult)
			. += "no|<b><font color='red'>CLOCKER</font></b>"
		else
			. += "<b>NO</b>|<a href='byond://?src=[UID()];siliclock=clockai'>clocker</a>"
			. += "<b>By making AI clocker, all his slave cyborg will also become clockers! <font color='red'>The process cannot be undone!</font></b>"

/*
. += "<a href='byond://?src=[UID()];siliclock=clear'>no</a>|<b><font color='red'>CLOCKER</font></b>"
	else
		. += "<b>NO</b>|<a href='byond://?src=[UID()];siliclock=clocker'>clocker</a>"
*/

/datum/mind/proc/memory_edit_wizard(mob/living/carbon/human/H)
	. = _memory_edit_header("wizard")
	if(src in SSticker.mode.wizards)
		. += "<b><font color='red'>WIZARD</font></b>|<a href='byond://?src=[UID()];wizard=clear'>no</a>"
		. += "<br><a href='byond://?src=[UID()];wizard=lair'>To lair</a>, <a href='byond://?src=[UID()];common=undress'>undress</a>, <a href='byond://?src=[UID()];wizard=dressup'>dress up</a>, <a href='byond://?src=[UID()];wizard=name'>let choose name</a>."
		if(!length(objectives))
			. += "<br>Objectives are empty! <a href='byond://?src=[UID()];wizard=autoobjectives'>Randomize!</a>"
	else if(src in SSticker.mode.apprentices)
		. += "<b><font color='red'>WIZARD APPRENTICE</font></b>|<a href='byond://?src=[UID()];wizard=clear'>no</a>"
		. += "<br><a href='byond://?src=[UID()];wizard=lair'>To lair</a>, <a href='byond://?src=[UID()];common=undress'>undress</a>, <a href='byond://?src=[UID()];wizard=dressup'>dress up</a>, <a href='byond://?src=[UID()];wizard=name'>let choose name</a>."
		if(!length(objectives))
			. += "<br>Objectives are empty! <a href='byond://?src=[UID()];wizard=autoobjectives'>Randomize!</a>"
	else
		. += "<b>NO</b>|<a href='byond://?src=[UID()];wizard=wizard'>wizard</a>|<a href='byond://?src=[UID()];wizard=apprentice'>apprentice</a>"
	. += _memory_edit_role_enabled(ROLE_WIZARD)


/datum/mind/proc/memory_edit_changeling(mob/living/carbon/human/H)
	. = _memory_edit_header("changeling", list("traitorchan", "traitorthiefchan", "thiefchan", "changelingthief"))
	var/datum/antagonist/changeling/cling = has_antag_datum(/datum/antagonist/changeling)
	if(cling)
		. += "<b><font color='red'>CHANGELING</font></b>|<a href='byond://?src=[UID()];changeling=clear'>no</a>"
		if(!length(cling.objectives))
			. += "<br>Objectives are empty! <a href='byond://?src=[UID()];changeling=autoobjectives'>Randomize!</a>"
		if(length(cling.absorbed_dna))
			var/datum/dna/DNA = cling.absorbed_dna[1]
			if(current.real_name != DNA.real_name)
				. += "<br><a href='byond://?src=[UID()];changeling=initialdna'>Transform to initial appearance.</a>"
	else
		. += "<a href='byond://?src=[UID()];changeling=changeling'>changeling</a>|<b>NO</b>"

	. += _memory_edit_role_enabled(ROLE_CHANGELING)


/datum/mind/proc/memory_edit_vampire(mob/living/carbon/human/H)
	. = _memory_edit_header("vampire", list("traitorvamp"))
	var/datum/antagonist/vampire/vamp = has_antag_datum(/datum/antagonist/vampire)
	if(vamp)
		. += "<b><font color='red'>[is_goon_vampire(src)? "GOON VAMPIRE" : "VAMPIRE" ]</font></b>|<a href='byond://?src=[UID()];vampire=clear'>no</a>"
		. += "<br>Usable blood: <a href='byond://?src=[UID()];vampire=edit_usable_blood'>[vamp.bloodusable]</a>"
		. += " | Total blood: <a href='byond://?src=[UID()];vampire=edit_total_blood'>[vamp.bloodtotal]</a>"
		var/has_subclass = !QDELETED(vamp.subclass)
		. += "<br>Subclass: <a href='byond://?src=[UID()];vampire=change_subclass'>[has_subclass ? capitalize(vamp.subclass.name) : "None"]</a>"
		if(has_subclass)
			. += " | Force full power: <a href='byond://?src=[UID()];vampire=full_power_override'>[vamp.subclass.full_power_override ? "Yes" : "No"]</a>"
			if(istype(vamp.subclass, /datum/vampire_subclass/bestia) || istype(vamp.subclass, /datum/vampire_subclass/ancient))
				. += "<br><b>Trophies:</b><br>Hearts: <a href='byond://?src=[UID()];vampire=edit_hearts'>[vamp.subclass.trophies[INTERNAL_ORGAN_HEART]]</a>"
				. += " | Lungs: <a href='byond://?src=[UID()];vampire=edit_lungs'>[vamp.subclass.trophies[INTERNAL_ORGAN_LUNGS]]</a>"
				. += " | Livers: <a href='byond://?src=[UID()];vampire=edit_livers'>[vamp.subclass.trophies[INTERNAL_ORGAN_LIVER]]</a>"
				. += "<br>Kidneys: <a href='byond://?src=[UID()];vampire=edit_kidneys'>[vamp.subclass.trophies[INTERNAL_ORGAN_KIDNEYS]]</a>"
				. += " | Eyes: <a href='byond://?src=[UID()];vampire=edit_eyes'>[vamp.subclass.trophies[INTERNAL_ORGAN_EYES]]</a>"
				. += " | Ears: <a href='byond://?src=[UID()];vampire=edit_ears'>[vamp.subclass.trophies[INTERNAL_ORGAN_EARS]]</a>"
		if(!length(vamp.objectives))
			. += "<br>Objectives are empty! <a href='byond://?src=[UID()];vampire=autoobjectives'>Randomize!</a>"
	else
		. += "<a href='byond://?src=[UID()];vampire=vampire'>vampire</a>|"
		. += "<a href='byond://?src=[UID()];vampire=goonvampire'>goon vampire</a>|<b>NO</b>"

	. += _memory_edit_role_enabled(ROLE_VAMPIRE)
	/** Enthralled ***/
	. += "<br><b><i>enthralled</i></b>: "
	if(has_antag_datum(/datum/antagonist/mindslave/thrall))
		. += "<b><font color='red'>THRALL</font></b>|<a href='byond://?src=[UID()];vampthrall=clear'>no</a>"
	else
		. += "thrall|<b>NO</b>"


/datum/mind/proc/memory_edit_nuclear(mob/living/carbon/human/H)
	. = _memory_edit_header("nuclear")
	if(src in SSticker.mode.syndicates)
		. += "<b><font color='red'>OPERATIVE</b></font>|<a href='byond://?src=[UID()];nuclear=clear'>no</a>"
		. += "<br><a href='byond://?src=[UID()];nuclear=lair'>To shuttle</a>, <a href='byond://?src=[UID()];common=undress'>undress</a>, <a href='byond://?src=[UID()];nuclear=dressup'>dress up</a>."
		var/code
		for(var/obj/machinery/nuclearbomb/bombue in GLOB.machines)
			if(length(bombue.r_code) <= 5 && bombue.r_code != "LOLNO" && bombue.r_code != "ADMIN")
				code = bombue.r_code
				break
		if(code)
			. += " Code is [code]. <a href='byond://?src=[UID()];nuclear=tellcode'>tell the code.</a>"
	else
		. += "<a href='byond://?src=[UID()];nuclear=nuclear'>operative</a>|<b>NO</b>"

	. += _memory_edit_role_enabled(ROLE_OPERATIVE)

/datum/mind/proc/memory_edit_shadowling(mob/living/carbon/human/H)
	. = _memory_edit_header("shadowling")
	if(src in SSticker.mode.shadows)
		. += "<b><font color='red'>SHADOWLING</font></b>|thrall|<a href='byond://?src=[UID()];shadowling=clear'>no</a>"
	else if(src in SSticker.mode.shadowling_thralls)
		. += "Shadowling|<b><font color='red'>THRALL</font></b>|<a href='byond://?src=[UID()];shadowling=clear'>no</a>"
	else
		. += "<a href='byond://?src=[UID()];shadowling=shadowling'>shadowling</a>|<a href='byond://?src=[UID()];shadowling=thrall'>thrall</a>|<b>NO</b>"

	. += _memory_edit_role_enabled(ROLE_SHADOWLING)

/datum/mind/proc/memory_edit_abductor(mob/living/carbon/human/H)
	. = _memory_edit_header("abductor")
	if(src in SSticker.mode.abductors)
		. += "<b><font color='red'>ABDUCTOR</font></b>|<a href='byond://?src=[UID()];abductor=clear'>no</a>"
		. += "|<a href='byond://?src=[UID()];common=undress'>undress</a>|<a href='byond://?src=[UID()];abductor=equip'>equip</a>"
	else
		. += "<a href='byond://?src=[UID()];abductor=abductor'>abductor</a>|<b>NO</b>"

	. += _memory_edit_role_enabled(ROLE_ABDUCTOR)


/datum/mind/proc/memory_edit_ninja()
	. = _memory_edit_header("ninja")
	var/datum/antagonist/ninja/ninja_datum = has_antag_datum(/datum/antagonist/ninja)
	if(ninja_datum)
		. += "<b><font color='red'>Ninja</font></b>|<a href='byond://?src=[UID()];ninja=clear'>no</a>"
		. += "<br><a href='byond://?src=[UID()];ninja=dojo'>To dojo</a>, <a href='byond://?src=[UID()];common=undress'>undress</a>, <a href='byond://?src=[UID()];ninja=dressup'>dress up</a>, <a href='byond://?src=[UID()];ninja=name'>let choose name</a>."
		if(!length(ninja_datum.objectives))
			. += "<br>Objectives are empty! <a href='byond://?src=[UID()];ninja=autoobjectives'>Randomize!</a>"
	else
		. += "<a href='byond://?src=[UID()];ninja=ninja'>ninja</a>|<b>NO</b>"

	. += _memory_edit_role_enabled(ROLE_NINJA)


/datum/mind/proc/memory_edit_devil(mob/living/H)
	. = _memory_edit_header("devil", list("devilagents"))
	if(src in SSticker.mode.devils)
		var/datum/antagonist/devil/devilinfo = has_antag_datum(/datum/antagonist/devil)
		if(!devilinfo)
			. += "<b>No devilinfo found! Yell at a coder!</b>"
		else
			. += "<a href='byond://?src=[UID()];devil=devil'>DEVIL</a>|sintouched|<a href='byond://?src=[UID()];devil=clear'>no</a>"
	else if(src in SSticker.mode.sintouched)
		. += "devil|<b>SINTOUCHED</b>|<a href='byond://?src=[UID()];devil=clear'>no</a>"
	else
		. += "<a href='byond://?src=[UID()];devil=devil'>devil</a>|<a href='byond://?src=[UID()];devil=sintouched'>sintouched</a>|<b>NO</b>"

	. += _memory_edit_role_enabled(ROLE_DEVIL)


/datum/mind/proc/memory_edit_space_dragon()
	. = _memory_edit_header("dragon")
	var/datum/antagonist/space_dragon/dragon_datum = has_antag_datum(/datum/antagonist/space_dragon)
	if(dragon_datum)
		. += "<b><font color='red'>SPACE DRAGON</font></b>|<a href='byond://?src=[UID()];space_dragon=clear'>no</a>"
	else
		. += "<a href='byond://?src=[UID()];space_dragon=space_dragon'>space dragon</a>|<b>NO</b>"


/datum/mind/proc/memory_edit_eventmisc(mob/living/H)
	. = _memory_edit_header("event", list())
	if(src in SSticker.mode.eventmiscs)
		. += "<b>YES</b>|<a href='byond://?src=[UID()];eventmisc=clear'>no</a>"
	else
		. += "<a href='byond://?src=[UID()];eventmisc=eventmisc'>Event Role</a>|<b>NO</b>"


/datum/mind/proc/memory_edit_blob()
	. = _memory_edit_header("blob")
	if(isblobinfected(src))
		. += "|<b><font color='red'>BLOB</font></b>|<a href='byond://?src=[UID()];blob=clear'>deblobize</a>"
		. += "|<a href='byond://?src=[UID()];blob=burst'>burst blob</a>"
	else if(isblobovermind(src))
		var/mob/camera/blob/blob_overmind = current
		if(istype(blob_overmind))
			. += "|<b><font color='red'>BLOB Overmind</font></b>|"
			. += "<br/><b>Total points: <a href='byond://?src=[UID()];blob=set_points'>[blob_overmind.blob_points]</a>/[blob_overmind.max_blob_points]</b>"
			. += "<br/><b>Infinity points: <a href='byond://?src=[UID()];blob=inf_points'>[(blob_overmind.is_infinity)? "ON" : "OFF"]</a></b>"
			. += "<br/><b>Blob strain: <a href='byond://?src=[UID()];blob=select_strain'>[blob_overmind.blobstrain? "<font color=\"[blob_overmind.blobstrain.color]\">[blob_overmind?.blobstrain?.name]</font>" : "None"]</a></b>"
	else if(isblobminion(src))
		. += "|<b><font color='red'>BLOB Minion</font></b>|"
	else if(current.can_be_blob())
		. += "<a href='byond://?src=[UID()];blob=blob'>blobize</a>|<b>NO</b>"
	. += _memory_edit_role_enabled(ROLE_BLOB)

/datum/mind/proc/memory_edit_terrors()
	. = _memory_edit_header("terror spiders")
	var/datum/antagonist/terror_spider/spider_datum = has_antag_datum(/datum/antagonist/terror_spider/)
	if(spider_datum)
		. += "|<b><font color='red'>[spider_datum.spider_category]</font></b>"
	else
		. += "<a href='byond://?src=[UID()];terror=datumise'>datumise</a>|<b>NO</b>"
	. += _memory_edit_role_enabled(ROLE_TERROR_SPIDER)

/datum/mind/proc/memory_edit_xenomorphs()
	. = _memory_edit_header("xenomorphs")
	var/datum/antagonist/xenomorph/xeno_datum = has_antag_datum(/datum/antagonist/xenomorph)
	if(xeno_datum)
		. += "|<b><font color='red'>[xeno_datum.antag_menu_name]</font></b>"
	else
		. += "<a href='byond://?src=[UID()];xenomorph=datumise'>datumise</a>|<b>NO</b>"
	. += _memory_edit_role_enabled(ROLE_ALIEN)

/datum/mind/proc/memory_edit_traitor()
	. = _memory_edit_header("traitor", list("traitorchan", "traitorvamp", "traitorthief"))
	var/datum/antagonist/traitor/traitor_datum = has_antag_datum(/datum/antagonist/traitor)
	if(traitor_datum)
		. += "<b><font color='red'>TRAITOR</font></b>|<a href='byond://?src=[UID()];traitor=clear'>no</a>"
		if(!length(traitor_datum.objectives))
			. += "<br>Objectives are empty! <a href='byond://?src=[UID()];traitor=autoobjectives'>Randomize!</a>"
	else
		. += "<a href='byond://?src=[UID()];traitor=traitor'>traitor</a>|<b>NO</b>"

	. += _memory_edit_role_enabled(ROLE_TRAITOR)
	// Contractor
	. += "<br><b><i>contractor</i></b>: "
	var/datum/antagonist/contractor/C = has_antag_datum(/datum/antagonist/contractor)
	if(C)
		var/status
		if(C.contractor_uplink) // Offer accepted
			status = "<b><font color='red'>CONTRACTOR</font></b>"
		else if(world.time >= C.offer_deadline)
			status = "<b><font color='darkorange'>CONTRACTOR (EXPIRED)</font></b>"
		else
			status = "<b><font color='orange'>CONTRACTOR (PENDING)</font></b>"
		. += "[status]|<a href='byond://?src=[UID()];contractor=clear'>no</a>"
		// List all their contracts
		if(C.contractor_uplink)
			. += "<br><b>Contracts:</b>"
			if(C.contractor_uplink.hub.contracts)
				var/count = 1
				for(var/co in C.contractor_uplink.hub.contracts)
					var/datum/syndicate_contract/CO = co
					. += "<br><b>Contract #[count++]</b>: "
					. += "<a href='byond://?src=[UID()];cuid=[CO.UID()];contractor=target'><b>[CO.contract.target?.name || "Invalid target!"]</b></a>|"
					. += "<a href='byond://?src=[UID()];cuid=[CO.UID()];contractor=locations'>locations</a>|"
					. += "<a href='byond://?src=[UID()];cuid=[CO.UID()];contractor=other'>more</a>|"
					switch(CO.status)
						if(CONTRACT_STATUS_INVALID)
							. += "<b>INVALID</b>"
						if(CONTRACT_STATUS_INACTIVE)
							. += "inactive"
						if(CONTRACT_STATUS_ACTIVE)
							. += "<b><font color='orange'>ACTIVE</font></b>|"
							. += "<a href='byond://?src=[UID()];cuid=[CO.UID()];contractor=interrupt'>interrupt</a>|"
							. += "<a href='byond://?src=[UID()];cuid=[CO.UID()];contractor=fail'>fail</a>"
						if(CONTRACT_STATUS_COMPLETED)
							. += "<font color='green'>COMPLETED</font>"
						if(CONTRACT_STATUS_FAILED)
							. += "<font color='red'>FAILED</font>"
				. += "<br>"
				. += "<a href='byond://?src=[UID()];contractor=add'>Add Contract</a><br>"
				. += "Claimable TC: <a href='byond://?src=[UID()];contractor=tc'>[C.contractor_uplink.hub.reward_tc_available]</a><br>"
				. += "Available Rep: <a href='byond://?src=[UID()];contractor=rep'>[C.contractor_uplink.hub.rep]</a><br>"
			else
				. += "<br>"
				. += "<i>Has not logged in to contractor uplink</i>"
	else
		if(traitor_datum)
			if(find_syndicate_uplink())
				. += "<a href='byond://?src=[UID()];contractor=contractor'>contractor</a>|<b>NO</b>"
			else
				. += "contractor|<b>NO</b>|No Uplink"
		else
			. += "contractor|<b>NO</b>"
	// Mindslave
	. += "<br><b><i>mindslaved</i></b>: "
	if(has_antag_datum(/datum/antagonist/mindslave, FALSE))
		. += "<b><font color='red'>MINDSLAVE</font></b>|<a href='byond://?src=[UID()];mindslave=clear'>no</a>"
	else
		. += "mindslave|<b>NO</b>"


/datum/mind/proc/memory_edit_malf_ai()
	. = _memory_edit_header("traitor", list("traitorchan", "traitorvamp", "traitorthief"))
	var/datum/antagonist/malf_ai/malf_datum = has_antag_datum(/datum/antagonist/malf_ai)
	if(malf_datum)
		. += "<b><font color='red'>MALF AI</font></b>|<a href='byond://?src=[UID()];malf_ai=clear'>no</a>"
		if(!length(malf_datum.objectives))
			. += "<br>Objectives are empty! <a href='byond://?src=[UID()];malf_ai=autoobjectives'>Randomize!</a>"
	else
		. += "<a href='byond://?src=[UID()];malf_ai=malf_ai'>malf AI</a>|<b>NO</b>"

	. += _memory_edit_role_enabled(ROLE_MALF_AI)


/datum/mind/proc/memory_edit_thief()
	. = _memory_edit_header("thief", list("traitorthief", "traitorthiefvamp", "traitorthiefchan", "thiefchan", "thiefvamp", "changelingthief", "vampirethief"))
	var/datum/antagonist/thief/thief_datum = has_antag_datum(/datum/antagonist/thief)
	if(thief_datum)
		. += "<b><font color='red'>THIEF</font></b>|<a href='byond://?src=[UID()];thief=clear'>no</a>"
		if(ishuman(current))
			. += "|<a href='byond://?src=[UID()];thief=equip'>Equip</a>"
		if(!length(thief_datum.objectives))
			. += "<br>Objectives are empty! <a href='byond://?src=[UID()];thief=autoobjectives'>Randomize!</a>"
	else
		. += "<a href='byond://?src=[UID()];thief=thief'>thief</a>|<b>NO</b>"

	. += _memory_edit_role_enabled(ROLE_THIEF)


/datum/mind/proc/memory_edit_silicon()
	. = "<i><b>Silicon</b></i>: "
	var/mob/living/silicon/silicon = current
	. = "<br>Current Laws: <b>[silicon.laws.name]</b> <a href='byond://?src=[UID()];silicon=lawmanager'>Law Manager</a>"
	var/mob/living/silicon/robot/robot = current
	if(istype(robot))
		. += "<br><b>Cyborg Module: [robot.module ? robot.module : "None" ]</b> <a href='byond://?src=[UID()];silicon=borgpanel'>Borg Panel</a>"
		if(robot.emagged)
			. += "<br>Cyborg: <b><font color='red'>Is emagged!</font></b> <a href='byond://?src=[UID()];silicon=unemag'>Unemag!</a>"
		if(robot.laws.zeroth_law)
			. += "<br>0th law: [robot.laws.zeroth_law?.law]"
	var/mob/living/silicon/ai/ai = current
	if(istype(ai) && ai.connected_robots.len)
		var/n_e_robots = 0
		for(var/mob/living/silicon/robot/R in ai.connected_robots)
			if(R.emagged)
				n_e_robots++
		. += "<br>[n_e_robots] of [ai.connected_robots.len] slaved cyborgs are emagged. <a href='byond://?src=[UID()];silicon=unemagcyborgs'>Unemag</a>"


/datum/mind/proc/memory_edit_uplink()
	. = ""
	if(ishuman(current) && ((src in SSticker.mode.head_revolutionaries) || \
		(has_antag_datum(/datum/antagonist/traitor)) || \
		(src in SSticker.mode.syndicates)))
		. = "Uplink: <a href='byond://?src=[UID()];common=uplink'>give</a>"
		var/obj/item/uplink/hidden/suplink = find_syndicate_uplink()
		var/crystals
		if(suplink)
			crystals = suplink.uses
		if(suplink)
			. += "|<a href='byond://?src=[UID()];common=takeuplink'>take</a>"
			if(usr.client.holder.rights & (R_SERVER|R_EVENT))
				. += ", <a href='byond://?src=[UID()];common=crystals'>[crystals]</a> crystals"
			else
				. += ", [crystals] crystals"
		. += "." //hiel grammar
		//         ^ whoever left this comment is literally a grammar nazi. stalin better. in russia grammar correct you.


/datum/mind/proc/edit_memory()
	if(!SSticker || !SSticker.mode)
		tgui_alert(usr, "Not before round-start!", "Alert")
		return

	var/list/out = list("<body><b>[name]</b>[(current && (current.real_name != name))?" (as [current.real_name])" : ""]")
	out.Add("Mind currently owned by key: [key] [active ? "(synced)" : "(not synced)"]")
	out.Add("Assigned role: [assigned_role]. <a href='byond://?src=[UID()];role_edit=1'>Edit</a>")
	out.Add("Special role: [special_role].") //better to change this through /datum/antagonist/, some code uses this var and can break if something goes wrong
	out.Add("Factions and special roles:")

	var/list/sections = list(
		"implant",
		"revolution",
		"cult",
		"clockwork",
		"wizard",
		"changeling", 	// "traitorchan", "thiefchan", "changelingthief",
		"vampire", 		// "traitorvamp", "thiefvamp", "vampirethief",
		"nuclear",
		"traitor",
		"ninja",
		"thief",		//	"traitorthief", "traitorthiefvamp", "traitorthiefchan",
		"malf_ai",
		"blob"
	)
	var/mob/living/carbon/human/H = current
	if(ishuman(current))
		/** Impanted**/
		sections["implant"] = memory_edit_implant(H)
		/** REVOLUTION ***/
		sections["revolution"] = memory_edit_revolution(H)
		/** WIZARD ***/
		sections["wizard"] = memory_edit_wizard(H)
		/** CHANGELING ***/
		sections["changeling"] = memory_edit_changeling(H)
		/** VAMPIRE ***/
		sections["vampire"] = memory_edit_vampire(H)
		/** NUCLEAR ***/
		sections["nuclear"] = memory_edit_nuclear(H)
		/** SHADOWLING **/
		sections["shadowling"] = memory_edit_shadowling(H)
		/** Abductors **/
		sections["abductor"] = memory_edit_abductor(H)
		/** Space Ninja **/
		sections["ninja"] = memory_edit_ninja()
		/** THIEF ***/
		sections["thief"] = memory_edit_thief()
		/** TRAITOR ***/
		sections["traitor"] = memory_edit_traitor()

	if(isAI(current))
		sections["malf_ai"] = memory_edit_malf_ai()

	/** DEVIL ***/
	var/static/list/devils_typecache = typecacheof(list(/mob/living/carbon/human, /mob/living/carbon/true_devil, /mob/living/silicon/robot))
	if(is_type_in_typecache(current, devils_typecache))
		sections["devil"] = memory_edit_devil(H)

	if(istype(current, /mob/living/simple_animal/hostile/space_dragon))
		sections["space_dragon"] = memory_edit_space_dragon()

	sections["eventmisc"] = memory_edit_eventmisc(H)

	if((isliving(current) && current.can_be_blob()) || isblobovermind(src))
		sections["blob"] = memory_edit_blob(current)
	if(isterrorspider(current))
		sections["terror_spiders"] = memory_edit_terrors(current)
	if(isalien(current))
		sections["xenomorphs"] = memory_edit_xenomorphs()
	if(!issilicon(current))
		/** CULT ***/
		sections["cult"] = memory_edit_cult(H)
		/** CLOCKWORK **/
		sections["clockwork"] = memory_edit_clockwork(H)

	/** SILICON ***/
	if(issilicon(current))
		sections["silicon"] = memory_edit_silicon()
		/** CLOCKWORK SILICON **/
		sections["siliclock"] = memory_edit_clockwork_silicon()
	/*
		This prioritizes antags relevant to the current round to make them appear at the top of the panel.
		Traitorchan and traitorvamp are snowflaked in because they have multiple sections.
	*/
	switch(SSticker.mode.config_tag)
		if("traitorchan")
			if(sections["traitor"])
				out.Add(sections["traitor"])
			if(sections["changeling"])
				out.Add(sections["changeling"])
			sections -= "traitor"
			sections -= "changeling"
		// Elif technically unnecessary but it makes the following else look better
		if("traitorvamp")
			if(sections["traitor"])
				out.Add(sections["traitor"])
			if(sections["vampire"])
				out.Add(sections["vampire"])
			sections -= "traitor"
			sections -= "vampire"
		if("thiefchan")
			if(sections["thief"])
				out.Add(sections["thief"])
			if(sections["changeling"])
				out.Add(sections["changeling"])
			sections -= "thief"
			sections -= "changeling"
		if("vampirethief")
			if(sections["vampire"])
				out.Add(sections["vampire"])
			if(sections["thief"])
				out.Add(sections["thief"])
			sections -= "vampire"
			sections -= "thief"
		if("traitorthiefchan")
			if(sections["traitor"])
				out.Add(sections["traitor"])
			if(sections["thief"])
				out.Add(sections["thief"])
			if(sections["changeling"])
				out.Add(sections["changeling"])
			sections -= "traitor"
			sections -= "thief"
			sections -= "changeling"
		if("traitorthiefvamp")
			if(sections["traitor"])
				out.Add(sections["traitor"])
			if(sections["thief"])
				out.Add(sections["thief"])
			if(sections["vampire"])
				out.Add(sections["vampire"])
			sections -= "traitor"
			sections -= "thief"
			sections -= "vampire"
		else
			if(sections[SSticker.mode.config_tag])
				out.Add(sections[SSticker.mode.config_tag])
			sections -= SSticker.mode.config_tag

	for(var/i in sections)
		if(sections[i])
			out.Add(sections[i])

	out.Add(memory_edit_uplink())

	out.Add("<b>Memory:</b>")
	out.Add(memory)
	out.Add("<br><a href='byond://?src=[UID()];memory_edit=1'>Edit memory</a><br>")
	out.Add("Objectives:")
	if(!length(get_all_objectives()))
		out.Add("EMPTY<br>")
	else
		out.Add(gen_objective_text(admin = TRUE))
	out.Add("<a href='byond://?src=[UID()];obj_add=1'>Add objective</a><br>")
	out.Add("<a href='byond://?src=[UID()];obj_announce=1'>Announce objectives</a><br>")
	out.Add("</body></html>")

	var/datum/browser/popup = new(usr, "edit_memory[src]", "<div align='center'>[name]</div>", 500, 500)
	popup.set_content(out.Join("<br>"))
	popup.set_window_options("can_close=1;can_minimize=0;can_maximize=0;can_resize=0;titlebar=1;")
	popup.open()
	onclose(usr, "edit_memory[src]")

/datum/mind/Topic(href, href_list)
	//проверяем на амбиции, после чего прерываем выполнение, иначе он залезет в админский антаг-панель
	var/ambition_func = ambition_topic(href, href_list)
	if (ambition_func)
		return

	if(!check_rights(R_ADMIN))
		return

	if(href_list["role_edit"])
		var/new_role = tgui_input_list(usr, "Select new role", "Assigned role", GLOB.joblist)
		if(!new_role)
			return
		assigned_role = new_role
		log_admin("[key_name(usr)] has changed [key_name(current)]'s assigned role to [assigned_role]")
		message_admins("[key_name_admin(usr)] has changed [key_name_admin(current)]'s assigned role to [assigned_role]")

	else if(href_list["memory_edit"])
		var/messageinput = tgui_input_text(usr, "Write new memory", "Memory", memory, multiline = TRUE, encode = FALSE)
		if(isnull(messageinput))
			return
		var/confirmed = tgui_alert(usr, "Are you sure you want to edit their memory? It will wipe out their original memory!", "Edit Memory", list("Yes", "No"))
		if(confirmed == "Yes") // Because it is too easy to accidentally wipe someone's memory
			memory = messageinput
			log_admin("[key_name(usr)] has edited [key_name(current)]'s memory")
			message_admins("[key_name_admin(usr)] has edited [key_name_admin(current)]'s memory")

	else if(href_list["obj_edit"] || href_list["obj_add"])
		var/datum/objective/objective
		var/objective_pos
		var/def_value

		if(href_list["obj_edit"])
			objective = locate(href_list["obj_edit"])
			if(!objective)
				return

			if(objectives.Find(objective))
				objective_pos = list(objectives.Find(objective), null)
			else
				for(var/datum/antagonist/antag in antag_datums)
					if(antag.objectives.Find(objective))
						objective_pos = list(antag.objectives.Find(objective), antag)

			//Text strings are easy to manipulate. Revised for simplicity.
			var/temp_obj_type = "[objective.type]"//Convert path into a text string.
			def_value = copytext(temp_obj_type, 18)	//Convert last part of path into an objective keyword.
			if(!def_value)//If it's a custom objective, it will be an empty string.
				def_value = "custom"

			switch(def_value)
				if("maroon")
					def_value = "prevent from escape"
				if("pain_hunter")
					def_value = "pain hunter"
				if("debrain")
					def_value = "steal brain"
				if("steal/hard")
					def_value = "thief hard"
				if("steal/medium")
					def_value = "thief medium"
				if("collect")
					def_value = "thief collect"
				if("steal_pet")
					def_value = "thief pet"
				if("steal_structure")
					def_value = "thief structure"
				if("escape_with_identity")
					def_value = "identity theft"
				if("block")
					def_value = "kill all humans"
				if("get_money")
					def_value = "get money"
				if("find_and_scan")
					def_value = "find and scan"
				if("set_up")
					def_value = "set up"
				if("research_corrupt")
					def_value = "research corrupt"
				if("ai_corrupt")
					def_value = "ai corrupt"
				if("plant_explosive")
					def_value = "plant explosive"
				if("cyborg_hijack")
					def_value = "cyborg hijack"

		var/list/objective_types = list(
			"assassinate", "prevent from escape", "pain hunter", "steal brain", "protect", "escape", "survive",
			"steal", "thief hard", "thief medium", "thief collect", "thief pet", "thief structure",
			"download", "nuclear", "capture", "blood", "absorb",
			"destroy", "identity theft", "hijack", "kill all humans",
			// Цели для ниндзя //
			"get money", "find and scan", "set up",
			"research corrupt", "ai corrupt", "plant explosive", "cyborg hijack",
			// Кастомная цель//
			"custom")

		var/new_obj_type = tgui_input_list(usr, "Select objective type:", "Objective type", objective_types)
		if(!new_obj_type)
			return

		var/datum/objective/new_objective = null

		switch(new_obj_type)
			if("assassinate", "protect", "steal brain", "prevent from escape", "pain hunter")

				var/list/possible_targets = list()
				var/list/possible_targets_random = list()
				for(var/datum/mind/possible_target in SSticker.minds)
					if((possible_target != src) && ishuman(possible_target.current))
						possible_targets += possible_target.current // Allows for admins to pick off station roles
						if(!is_invalid_target(possible_target))
							possible_targets_random += possible_target.current // For random picking, only valid targets

				var/mob/def_target = null
				var/objective_list[] = list(/datum/objective/assassinate,
											/datum/objective/protect,
											/datum/objective/debrain,
											/datum/objective/maroon,
											/datum/objective/pain_hunter
										)
				if(objective && (objective.type in objective_list) && objective:target)
					def_target = objective.target.current
				possible_targets = sortAtom(possible_targets)

				var/new_target
				if(length(possible_targets))
					if(tgui_alert(usr, "Do you want to pick the objective yourself? No will randomise it", "Pick objective", list("Yes", "No")) == "Yes")
						possible_targets += "Free objective"
						new_target = tgui_input_list(usr, "Select target:", "Objective target", possible_targets, def_target)
					else
						if(!length(possible_targets_random))
							to_chat(usr, span_warning("No random target found. Pick one manually."))
							return
						new_target = pick(possible_targets_random)

					if(!new_target)
						return
				else
					to_chat(usr, span_warning("No possible target found. Defaulting to a Free objective."))
					new_target = "Free objective"

				var/obj_type = list("assassinate" = /datum/objective/assassinate,
								"protect" = /datum/objective/protect,
								"steal brain" = /datum/objective/debrain,
								"prevent from escape" = /datum/objective/maroon,
								"pain hunter" = /datum/objective/pain_hunter
								)[new_obj_type]

				if(new_target == "Free objective")
					new_objective = new obj_type
					new_objective.owner = src
					new_objective:target = null
					new_objective.explanation_text = "Free objective"
				else
					new_objective = new obj_type
					new_objective.owner = src
					new_objective:target = new_target:mind

					var/description = ""
					switch(new_obj_type)
						if("assassinate")
							description = "Assassinate"
						if("protect")
							description = "Protect"
						if("steal brain")
							var/mob/living/target = new_target
							var/obj/item/organ/internal/brains = target.get_organ_slot(INTERNAL_ORGAN_BRAIN)
							description = "Steal the [brains ? brains.name : "brain"] of"
						if("prevent from escape")
							description = "Prevent from escaping alive or free"
						if("pain hunter")
							var/datum/objective/pain_hunter/choose_objective = new_objective
							choose_objective.update_find_objective()
					if(description)
						//Will display as special role if assigned mode is equal to special role.. Ninjas/commandos/nuke ops.
						new_objective.explanation_text = "[description] [new_target:real_name], the [new_target:mind:assigned_role == new_target:mind:special_role ? (new_target:mind:special_role) : (new_target:mind:assigned_role)]."

			if("destroy")
				var/list/possible_targets = active_ais(1)
				if(possible_targets.len)
					var/mob/new_target = tgui_input_list(usr, "Select target:", "Objective target", possible_targets)
					new_objective = new /datum/objective/destroy
					new_objective.target = new_target.mind
					new_objective.owner = src
					new_objective.explanation_text = "Destroy [new_target.name], the experimental AI."
				else
					to_chat(usr, "No active AIs with minds")

			if("kill all humans")
				new_objective = new /datum/objective/block
				new_objective.owner = src

			if("hijack")
				new_objective = new /datum/objective/hijack
				new_objective.owner = src

			if("escape")
				new_objective = new /datum/objective/escape
				new_objective.owner = src

			if("survive")
				new_objective = new /datum/objective/survive
				new_objective.owner = src

			if("die")
				new_objective = new /datum/objective/die
				new_objective.owner = src

			if("nuclear")
				new_objective = new /datum/objective/nuclear
				new_objective.owner = src

			if("find and scan")
				if(tgui_alert(usr, "Предупреждение! Эту цель способен выполнить только ниндзя!", "Продолжить?", list("Да", "Нет")) == "Да")
					new_objective = new /datum/objective/find_and_scan
					var/datum/objective/find_and_scan/scan_objective = new_objective
					var/list/roles = scan_objective.available_roles.Copy()
					if(tgui_alert(usr, "Do you want to pick roles yourself? No will randomise it", "Pick roles", list("Yes", "No")) == "Yes")
						for(var/i in 1 to 3)
							var/role = tgui_input_list(usr, "Select role:", "Objective role", roles)
							if(role)
								roles -= role
								scan_objective.possible_roles += role
							else
								qdel(scan_objective)
								return
					scan_objective.find_target()
					scan_objective.owner = src

			if("research corrupt")
				if(tgui_alert(usr, "Предупреждение! Эту цель способен выполнить только ниндзя!", "Продолжить?", list("Да", "Нет")) == "Да")
					new_objective = new /datum/objective/research_corrupt
					new_objective.owner = src

			if("ai corrupt")
				if(tgui_alert(usr, "Предупреждение! Эту цель способен выполнить только ниндзя!", "Продолжить?", list("Да", "Нет")) == "Да")
					new_objective = new /datum/objective/ai_corrupt
					new_objective.owner = src

			if("cyborg hijack")
				if(tgui_alert(usr, "Предупреждение! Эту цель способен выполнить только ниндзя!", "Продолжить?", list("Да", "Нет")) == "Да")
					new_objective = new /datum/objective/cyborg_hijack
					new_objective.owner = src

			if("plant explosive")
				if(tgui_alert(usr, "Предупреждение! Эту цель способен выполнить только ниндзя!", "Продолжить?", list("Да", "Нет")) == "Да")
					new_objective = new /datum/objective/plant_explosive
					var/datum/objective/plant_explosive/bomb_objective = new_objective
					var/area/random_detonation_area = null
					var/area/detonation_area = null
					if(tgui_alert(usr, "Do you want to pick detonation area yourself? No will randomise it", "Pick objective", list("Yes", "No")) == "No")
						for(var/sanity in 1 to 100) // 100 checks at most.
							var/area/selected_area = pick(get_sorted_areas())
							if(selected_area && is_station_level(selected_area.z) && selected_area.valid_territory) //Целью должна быть зона на станции!
								if(selected_area in bomb_objective.area_blacklist)
									continue
								random_detonation_area = selected_area
								break
					else
						detonation_area = tgui_input_list(usr, "Select area:", "Objective area", get_sorted_areas())

					bomb_objective.detonation_location = detonation_area ? detonation_area : random_detonation_area
					bomb_objective.explanation_text = "Взорвите выданную вам бомбу в [bomb_objective.detonation_location]. Учтите, что бомбу нельзя активировать на не предназначенной для подрыва территории!"
					bomb_objective.owner = src
					//Выдача бомбы
					var/obj/item/grenade/plastic/c4/ninja/charge = new
					var/mob/living/carbon/human/bomber = current
					bomber.equip_or_collect(charge, ITEM_SLOT_POCKET_LEFT)
					charge.detonation_objective = bomb_objective

			if("set up")
				new_objective = new /datum/objective/set_up
				new_objective.owner = src //Должно быть вначале чтобы проверки ниже работали
				var/list/possible_targets = list()
				for(var/datum/mind/possible_target in SSticker.minds)
					if(new_objective.is_invalid_target(possible_target))
						continue
					if(ismindshielded(possible_target.current))
						continue
					possible_targets += possible_target
				possible_targets = sortAtom(possible_targets)

				var/new_target = null
				var/target_pick = null
				if(length(possible_targets))
					if(tgui_alert(usr, "Do you want to pick the objective yourself? No will randomise it", "Pick objective", list("Yes", "No")) == "No")
						target_pick = pick(possible_targets)
					else
						new_target = tgui_input_list(usr, "Select target:", "Objective target", possible_targets)
					new_objective.target = new_target ? new_target : target_pick
					new_objective.explanation_text = "Любым способом подставьте [new_objective.target.current.real_name], [new_objective.target.assigned_role], чтобы его лишили свободы. Но не убили!"

				else
					to_chat(usr, span_warning("No possible target found. Defaulting to a Free objective."))
					new_target = "Free objective"

			if("steal")
				if(!istype(objective, /datum/objective/steal))
					new_objective = new /datum/objective/steal
					new_objective.owner = src
				else
					new_objective = objective
				var/datum/objective/steal/steal = new_objective
				if(!steal.select_target())
					to_chat(usr, "<span class='warning'>Цель не обнаружена. Выберите другую или создайте её.</span>")
					return

			if("thief hard")
				if(!istype(objective, /datum/objective/steal/hard))
					new_objective = new /datum/objective/steal/hard
					new_objective.owner = src
				else
					new_objective = objective
				var/datum/objective/steal/hard/steal = new_objective
				if(!steal.select_target())
					to_chat(usr, "<span class='warning'>Цель не обнаружена. Выберите другую или создайте её.</span>")
					return

			if("thief medium")
				if(!istype(objective, /datum/objective/steal/medium))
					new_objective = new /datum/objective/steal/medium
					new_objective.owner = src
				else
					new_objective = objective
				var/datum/objective/steal/medium/steal = new_objective
				if(!steal.select_target())
					to_chat(usr, "<span class='warning'>Цель не обнаружена. Выберите другую или создайте её.</span>")
					return

			if("thief collect")
				if(!istype(objective, /datum/objective/steal/collect))
					new_objective = new /datum/objective/steal/collect
					new_objective.owner = src
				else
					new_objective = objective
				var/datum/objective/steal/collect/steal = new_objective
				if(!steal.select_target())
					to_chat(usr, "<span class='warning'>Цель не обнаружена. Выберите другую или создайте её.</span>")
					return

			if("thief pet")
				if(!istype(objective, /datum/objective/steal/animal))
					new_objective = new /datum/objective/steal/animal
					new_objective.owner = src
				else
					new_objective = objective
				var/datum/objective/steal/animal/steal = new_objective
				if(!steal.select_target())
					to_chat(usr, "<span class='warning'>Цель не обнаружена. Выберите другую или создайте её.</span>")
					return

			if("thief structure")
				if(!istype(objective, /datum/objective/steal/structure))
					new_objective = new /datum/objective/steal/structure
					new_objective.owner = src
				else
					new_objective = objective
				var/datum/objective/steal/structure/steal = new_objective
				if(!steal.select_target())
					to_chat(usr, "<span class='warning'>Цель не обнаружена. Выберите другую или создайте её.</span>")
					return

			if("get money")
				new_objective = new /datum/objective/get_money
				var/datum/objective/get_money/money_objective = new_objective
				var/input_sum = null
				var/accounts_procent = 60
				if(tgui_alert(usr, "Хотите сами подобрать сумму? Если нет, то будет выбрана сумма от процентажа со всех аккаунтов.", "Введите сумму", list("Yes", "No")) == "Yes")
					input_sum = tgui_input_number(usr, "Введите необходимую денежную сумму:", "Денежная Сумма", max_value = INFINITY)
				else
					accounts_procent = tgui_input_number(usr, "Введите необходимый процентаж суммы со всех аккаунтов (1-100), иначе будет 60%:", "Процентаж", min_value = 1, max_value = 100)
					if(!accounts_procent)
						accounts_procent = initial(accounts_procent)
				money_objective.owner = src
				money_objective.new_cash(input_sum, accounts_procent)

			if("download","capture","absorb", "blood")
				var/def_num
				if(objective&&objective.type==text2path("/datum/objective/[new_obj_type]"))
					def_num = objective.target_amount

				var/target_number = tgui_input_number(usr, "Input target number:", "Objective", def_num)
				if(isnull(target_number))//Ordinarily, you wouldn't need isnull. In this case, the value may already exist.
					return

				switch(new_obj_type)
					if("download")
						new_objective = new /datum/objective/download
						new_objective.explanation_text = "Download [target_number] research levels."
					if("capture")
						new_objective = new /datum/objective/capture
						new_objective.explanation_text = "Accumulate [target_number] capture points."
					if("absorb")
						new_objective = new /datum/objective/absorb
						new_objective.explanation_text = "Absorb [target_number] compatible genomes."
					if("blood")
						new_objective = new /datum/objective/blood
						new_objective.explanation_text = "Накопить не менее [target_number] единиц крови."
				new_objective.owner = src
				new_objective.target_amount = target_number

			if("identity theft")
				var/list/possible_targets = list()
				for(var/datum/mind/possible_target in SSticker.minds)
					if((possible_target != src) && ishuman(possible_target.current))
						possible_targets += possible_target
				possible_targets = sortAtom(possible_targets)
				possible_targets += "Free objective"

				var/new_target = tgui_input_list(usr, "Select target:", "Objective target", possible_targets)
				if(!new_target)
					return

				var/datum/mind/targ = new_target
				if(!istype(targ))
					log_runtime(EXCEPTION("Invalid target for identity theft objective, cancelling"), src)
					return

				var/datum/objective/escape/escape_with_identity/identity_objective = new
				identity_objective.owner = src
				identity_objective.target = new_target
				identity_objective.target_real_name = targ.current.real_name
				identity_objective.explanation_text = "Escape on the shuttle or an escape pod with the identity of [targ.current.real_name], the [targ.assigned_role] while wearing [targ.current.p_their()] identification card."
				new_objective = identity_objective

			if("custom")
				var/expl = sanitize(tgui_input_text(usr, "Custom objective:", "Objective", objective ? objective.explanation_text : ""))
				if(!expl)
					return
				new_objective = new /datum/objective
				new_objective.owner = src
				new_objective.explanation_text = expl

		if(!new_objective)
			return

		if(objective)
			remove_objective(objective)
			if(objective_pos[2])
				var/datum/antagonist/antag = objective_pos[2]
				antag.objectives.Insert(objective_pos[1], new_objective)
			else
				objectives.Insert(objective_pos[1], new_objective)
		else
			objectives += new_objective

		log_admin("[key_name(usr)] has updated [key_name(current)]'s objectives: [new_objective]")
		message_admins("[key_name_admin(usr)] has updated [key_name_admin(current)]'s objectives: [new_objective]")

	else if(href_list["obj_delete"])
		var/datum/objective/objective = locate(href_list["obj_delete"])
		if(!istype(objective))
			return

		log_admin("[key_name(usr)] has removed one of [key_name(current)]'s objectives: [objective]")
		message_admins("[key_name_admin(usr)] has removed one of [key_name_admin(current)]'s objectives: [objective]")
		remove_objective(objective)

	else if(href_list["obj_completed"])
		var/datum/objective/objective = locate(href_list["obj_completed"])
		if(!istype(objective))
			return
		objective.completed = !objective.completed

		log_admin("[key_name(usr)] has toggled the completion of one of [key_name(current)]'s objectives")
		message_admins("[key_name_admin(usr)] has toggled the completion of one of [key_name_admin(current)]'s objectives")

	else if(href_list["implant"])
		var/mob/living/carbon/human/H = current

		switch(href_list["implant"])
			if("ertremove")
				for(var/obj/item/implant/mindshield/ert/I in H.contents)
					if(I && I.implanted)
						qdel(I)
				to_chat(H, "<span class='notice'><span style='font-size: 3;'><b>Your ert mindshield implant has been deactivated.</b></span></span>")
				log_admin("[key_name(usr)] has deactivated [key_name(current)]'s ert mindshield implant")
				message_admins("[key_name_admin(usr)] has deactivated [key_name_admin(current)]'s ert mindshield implant")
			if("remove")
				for(var/obj/item/implant/mindshield/I in H.contents)
					if(I && I.implanted)
						qdel(I)
				to_chat(H, "<span class='notice'><span style='font-size: 3;'><b>Your mindshield implant has been deactivated.</b></span></span>")
				log_admin("[key_name(usr)] has deactivated [key_name(current)]'s mindshield implant")
				message_admins("[key_name_admin(usr)] has deactivated [key_name_admin(current)]'s mindshield implant")
			if("add")
				var/obj/item/implant/mindshield/L = new/obj/item/implant/mindshield(H)
				L.implant(H)

				log_admin("[key_name(usr)] has given [key_name(current)] a mindshield implant")
				message_admins("[key_name_admin(usr)] has given [key_name_admin(current)] a mindshield implant")

				to_chat(H, "<span class='warning'><span style='font-size: 3;'><b>You somehow have become the recepient of a mindshield transplant, and it just activated!</b></span></span>")
				if(src in SSticker.mode.revolutionaries)
					SSticker.mode.remove_revolutionary(src)
			if("ertadd")
				var/obj/item/implant/mindshield/ert/L = new/obj/item/implant/mindshield/ert(H)
				L.implant(H)

				log_admin("[key_name(usr)] has given [key_name(current)] a ert mindshield implant")
				message_admins("[key_name_admin(usr)] has given [key_name_admin(current)] a ert mindshield implant")

				to_chat(H, "<span class='warning'><span style='font-size: 3;'><b>You somehow have become the recepient of a ert mindshield transplant, and it just activated!</b></span></span>")
				if(src in SSticker.mode.revolutionaries)
					SSticker.mode.remove_revolutionary(src)

	else if(href_list["revolution"])

		switch(href_list["revolution"])
			if("clear")
				remove_revolutionary_role()
				log_admin("[key_name(usr)] has de-rev'd [key_name(current)]")
				message_admins("[key_name_admin(usr)] has de-rev'd [key_name_admin(current)]")

			if("rev")
				if(src in SSticker.mode.head_revolutionaries)
					for(var/datum/action/innate/revolution_recruitment/C in current.actions)
						qdel(C)
					SSticker.mode.head_revolutionaries -= src
					SSticker.mode.update_rev_icons_removed(src)
					to_chat(current, "<span class='warning'><span style='font-size: 3;'><b>Revolution has been disappointed of your leadership traits! You are a regular revolutionary now!</b></span></span>")
				else if(!(src in SSticker.mode.revolutionaries))
					to_chat(current, "<span class='warning'><span style='font-size: 3;'> You are now a revolutionary! Follow orders given by revolution leaders. Do not harm your fellow freedom fighters. You can identify your comrades by the red \"R\" icons, and your leaders by the blue \"R\" icons.</span></span>")
				else
					return
				SSticker.mode.revolutionaries += src
				SSticker.mode.update_rev_icons_added(src)
				special_role = SPECIAL_ROLE_REV
				SEND_SOUND(current, 'sound/ambience/antag/revolutionary_tide.ogg')
				log_admin("[key_name(usr)] has rev'd [key_name(current)]")
				message_admins("[key_name_admin(usr)] has rev'd [key_name_admin(current)]")
				current.create_log(MISC_LOG, "[current] was made into a revolutionary by [key_name_admin(usr)]")

			if("headrev")
				if(src in SSticker.mode.revolutionaries)
					SSticker.mode.revolutionaries -= src
					SSticker.mode.update_rev_icons_removed(src)
					to_chat(current, span_userdanger("You have proven your devotion to revolution! You are a head revolutionary now!"))
				else if(!(src in SSticker.mode.head_revolutionaries))
					to_chat(current, span_notice("You are a member of the revolutionaries' leadership now!"))
				else
					return

				SSticker.mode.head_revolutionaries += src
				SSticker.mode.update_rev_icons_added(src)
				special_role = SPECIAL_ROLE_HEAD_REV
				var/datum/action/innate/revolution_recruitment/recruit_action = locate() in current.actions
				if(!recruit_action)
					recruit_action = new
					recruit_action.Grant(src.current)
				SEND_SOUND(current, 'sound/ambience/antag/revolutionary_tide.ogg')
				log_admin("[key_name(usr)] has head-rev'd [key_name(current)]")
				message_admins("[key_name_admin(usr)] has head-rev'd [key_name_admin(current)]")
				current.create_log(MISC_LOG, "[current] was made into a head revolutionary by [key_name_admin(usr)]")

			if("autoobjectives")
				SSticker.mode.forge_revolutionary_objectives(src)
				log_admin("[key_name(usr)] has automatically forged revolutionary objectives for [key_name(current)]")
				message_admins("[key_name_admin(usr)] has automatically forged revolutionary objectives for [key_name_admin(current)]")

			if("reequip")
				var/fail = FALSE
				fail |= !SSticker.mode.equip_revolutionary(current)
				if(fail)
					to_chat(usr, span_warning("Reequipping revolutionary goes wrong!"))
					return
				log_admin("[key_name(usr)] has equipped [key_name(current)] as a revolutionary")
				message_admins("[key_name_admin(usr)] has equipped [key_name_admin(current)] as a revolutionary")

	else if(href_list["cult"])
		switch(href_list["cult"])
			if("clear")
				remove_cult_role()
				log_admin("[key_name(usr)] has de-culted [key_name(current)]")
				message_admins("[key_name_admin(usr)] has de-culted [key_name_admin(current)]")
			if("cultist")
				if(!(src in SSticker.mode.cult))
					to_chat(current, CULT_GREETING)
					SSticker.mode.add_cultist(src)
					to_chat(current, "<span class='cultitalic'>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve [SSticker.cultdat.entity_title2] above all else. Bring It back.</span>")
					log_and_message_admins("[key_name(usr)] has culted [key_name(current)]")
			if("dagger")
				var/mob/living/carbon/human/H = current
				if(!SSticker.mode.cult_give_item(/obj/item/melee/cultblade/dagger, H))
					to_chat(usr, "<span class='warning'>Spawning dagger failed!</span>")
				log_and_message_admins("[key_name(usr)] has equipped [key_name(current)] with a cult dagger")
			if("runedmetal")
				var/mob/living/carbon/human/H = current
				if(!SSticker.mode.cult_give_item(/obj/item/stack/sheet/runed_metal/ten, H))
					to_chat(usr, "<span class='warning'>Spawning runed metal failed!</span>")
				log_and_message_admins("[key_name(usr)] has equipped [key_name(current)] with 10 runed metal sheets")

	else if(href_list["clock"])
		switch(href_list["clock"])
			if("clear")
				remove_clocker_role()
				log_admin("[key_name(usr)] has de-clocked [key_name(current)]")
				message_admins("[key_name_admin(usr)] has de-clocked [key_name_admin(current)]")
			if("clocker")
				if(!(src in SSticker.mode.clockwork_cult))
					to_chat(current, CLOCK_GREETING)
					SSticker.mode.add_clocker(src)
					to_chat(current, "<span class='clockitalic'>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve Ratvar above all else. Bring It back.</span>")
					log_and_message_admins("[key_name(usr)] has clocked [key_name(current)]")
			if("clockslab")
				var/mob/living/carbon/human/H = current
				if(!SSticker.mode.clock_give_item(/obj/item/clockwork/clockslab, H))
					to_chat(usr, "<span class='warning'>Spawning Clock slab failed!</span>")
				log_and_message_admins("[key_name(usr)] has equipped [key_name(current)] with a clock slab")
			if("brassmetal")
				var/mob/living/carbon/human/H = current
				if(!SSticker.mode.clock_give_item(/obj/item/stack/sheet/brass/ten, H))
					to_chat(usr, "<span class='warning'>Spawning brass metal failed!</span>")
				log_and_message_admins("[key_name(usr)] has equipped [key_name(current)] with 10 brass metal sheets")
	else if(href_list["siliclock"])
		switch(href_list["siliclock"])
			if("clearrobot")
				var/mob/living/silicon/robot/robot = current
				if(src in SSticker.mode.clockwork_cult)
					SSticker.mode.remove_clocker(src)
					robot.clear_supplied_laws()
					robot.laws = new /datum/ai_laws/crewsimov
					log_admin("[key_name(usr)] has de-clocked [key_name(current)]")
					message_admins("[key_name_admin(usr)] has de-clocked [key_name_admin(current)]")
			if("clockrobot")
				if(!(src in SSticker.mode.clockwork_cult))
					current.ratvar_act(TRUE)
					to_chat(current, "<span class='clockitalic'>Assist your new compatriots in their brass dealings. Their goal is yours, and yours is theirs. You serve Ratvar above all else. Bring It back.</span>")
					log_and_message_admins("[key_name(usr)] has clocked [key_name(current)]")
			if("clockai")
				var/mob/living/silicon/ai/ai = current
				if(!(src in SSticker.mode.clockwork_cult))
					ai.ratvar_act(TRUE)
					to_chat(current, "<span class='clockitalic'>Assist your new compatriots in their brass dealings. Their goal is yours, and yours is theirs. You serve Ratvar above all else. Bring It back.</span>")
					log_and_message_admins("[key_name(usr)] has clocked [key_name(current)]")


	else if(href_list["wizard"])

		switch(href_list["wizard"])
			if("clear")
				remove_wizard_role()
				to_chat(current, "<span class='userdanger'><span style='font-size: 3;'>You have been brainwashed! You are no longer a wizard!</span></span>")
				log_admin("[key_name(usr)] has de-wizarded [key_name(current)]")
				message_admins("[key_name_admin(usr)] has de-wizarded [key_name_admin(current)]")
				if(src in SSticker.mode.apprentices)
					SSticker.mode.apprentices -= src
					special_role = null
					current.spellremove(current)
					current.faction = list("Station")
					SSticker.mode.update_wiz_icons_removed(src)
					to_chat(current, "<span class='userdanger'><span style='font-size: 3;'>You have been brainwashed! You are no longer a apprentice wizard!</span></span>")
					log_admin("[key_name(usr)] has de-apprentice-wizarded [key_name(current)]")
					message_admins("[key_name_admin(usr)] has de-apprentice-wizarded [key_name_admin(current)]")
			if("wizard")
				if(!(src in SSticker.mode.wizards) && !(src in SSticker.mode.apprentices))
					SSticker.mode.wizards += src
					special_role = SPECIAL_ROLE_WIZARD
					//ticker.mode.learn_basic_spells(current)
					SSticker.mode.update_wiz_icons_added(src)
					SEND_SOUND(current, 'sound/ambience/antag/ragesmages.ogg')
					to_chat(current, "<span class='danger'>You are a Space Wizard!</span>")
					current.faction = list("wizard")
					log_admin("[key_name(usr)] has wizarded [key_name(current)]")
					message_admins("[key_name_admin(usr)] has wizarded [key_name_admin(current)]")
			if("apprentice")
				if(!(src in SSticker.mode.wizards) && !(src in SSticker.mode.apprentices))
					SSticker.mode.apprentices += src
					special_role = SPECIAL_ROLE_WIZARD_APPRENTICE
					SSticker.mode.update_wiz_icons_added(src)
					SEND_SOUND(current, 'sound/ambience/antag/ragesmages.ogg')
					to_chat(current, "<span class='danger'>You are a Apprentice of Space Wizard!</span>")
					current.faction = list("wizard")
					log_admin("[key_name(usr)] has apprentice-wizarded [key_name(current)]")
					message_admins("[key_name_admin(usr)] has apprentice-wizarded [key_name_admin(current)]")
			if("lair")
				current.forceMove(pick(GLOB.wizardstart))
				log_admin("[key_name(usr)] has moved [key_name(current)] to the wizard's lair")
				message_admins("[key_name_admin(usr)] has moved [key_name_admin(current)] to the wizard's lair")
			if("dressup")
				if(src in SSticker.mode.wizards)
					SSticker.mode.equip_wizard(current)
					log_admin("[key_name(usr)] has equipped [key_name(current)] as a wizard")
					message_admins("[key_name_admin(usr)] has equipped [key_name_admin(current)] as a wizard")
				else if(src in SSticker.mode.apprentices)
					SSticker.mode.equip_wizard_apprentice(current)
					log_admin("[key_name(usr)] has equipped [key_name(current)] as a wizard apprentice")
					message_admins("[key_name_admin(usr)] has equipped [key_name_admin(current)] as a wizard apprentice")
			if("name")
				INVOKE_ASYNC(SSticker.mode, TYPE_PROC_REF(/datum/game_mode/wizard, name_wizard), current)
				log_admin("[key_name(usr)] has allowed wizard [key_name(current)] to name themselves")
				message_admins("[key_name_admin(usr)] has allowed wizard [key_name_admin(current)] to name themselves")
			if("autoobjectives")
				if(src in SSticker.mode.wizards)
					SSticker.mode.forge_wizard_objectives(src)
					to_chat(usr, "<span class='notice'>The objectives for wizard [key] have been generated. You can edit them and announce manually.</span>")
					log_admin("[key_name(usr)] has automatically forged wizard objectives for [key_name(current)]")
					message_admins("[key_name_admin(usr)] has automatically forged wizard objectives for [key_name_admin(current)]")
				else if(src in SSticker.mode.apprentices)
					if (SSticker.mode.wizards.len)
						var/datum/mind/wizard = pick(SSticker.mode.wizards)
						SSticker.mode.forge_wizard_apprentice_objectives(wizard, src)
					else
						SSticker.mode.forge_wizard_objectives(src)
					to_chat(usr, "<span class='notice'>The objectives for wizard apprentice [key] have been generated. You can edit them and announce manually.</span>")
					log_admin("[key_name(usr)] has automatically forged wizard apprentice objectives for [key_name(current)]")
					message_admins("[key_name_admin(usr)] has automatically forged wizard apprentice objectives for [key_name_admin(current)]")


	else if(href_list["changeling"])
		switch(href_list["changeling"])
			if("clear")
				if(ischangeling(current))
					remove_antag_datum(/datum/antagonist/changeling)
					log_admin("[key_name(usr)] has de-changelinged [key_name(current)]")
					message_admins("[key_name_admin(usr)] has de-changelinged [key_name_admin(current)]")

			if("changeling")
				if(!ischangeling(current))
					var/datum/antagonist/changeling/cling = new()
					cling.give_objectives = FALSE
					add_antag_datum(cling)
					to_chat(usr, "<span class='notice'>Changeling [key] has no objectives. You can add custom ones or generate random set by using <b>Randomize!</b> button.</span>")
					to_chat(current, "<span class='biggerdanger'>Your powers have awoken. A flash of memory returns to us... we are a changeling!</span>")
					log_admin("[key_name(usr)] has changelinged [key_name(current)]")
					message_admins("[key_name_admin(usr)] has changelinged [key_name_admin(current)]")

			if("autoobjectives")
				var/datum/antagonist/changeling/cling = has_antag_datum(/datum/antagonist/changeling)
				cling.give_objectives()
				to_chat(usr, "<span class='notice'>The objectives for changeling [key] have been generated. You can edit them and announce manually.</span>")
				log_admin("[key_name(usr)] has automatically forged objectives for [key_name(current)]")
				message_admins("[key_name_admin(usr)] has automatically forged objectives for [key_name_admin(current)]")

			if("initialdna")
				var/datum/antagonist/changeling/cling = has_antag_datum(/datum/antagonist/changeling)
				if(!cling || !length(cling.absorbed_dna))
					to_chat(usr, "<span class='warning'>Resetting DNA failed!</span>")
				else
					current.dna = cling.absorbed_dna[1]
					current.real_name = current.dna.real_name
					current.UpdateAppearance()
					current.check_genes()
					log_admin("[key_name(usr)] has reset [key_name(current)]'s DNA")
					message_admins("[key_name_admin(usr)] has reset [key_name_admin(current)]'s DNA")

	else if(href_list["vampire"])
		switch(href_list["vampire"])
			if("clear")
				if(!isvampire(src))
					return

				remove_vampire_role()
				to_chat(current, "<span style='font-size: 3; color: red;'><b>Вы ослабли и потеряли свои силы! Вы больше не вампир и теперь останетесь в своей текущей форме!</b></span>")
				log_admin("[key_name(usr)] has de-vampired [key_name(current)]")
				message_admins("[key_name_admin(usr)] has de-vampired [key_name_admin(current)]")

			if("goonvampire")
				if(isvampire(src))
					return

				var/datum/antagonist/vampire/goon_vampire/g_vamp = new()
				g_vamp.give_objectives = FALSE
				add_antag_datum(g_vamp)
				to_chat(usr, span_notice("У вампира [key] отсутствуют цели. Вы можете добавить их вручную или сгенерировать случайный набор, кнопкой <b>Randomize!</b>"))
				log_admin("[key_name(usr)] has goon-vampired [key_name(current)]")
				message_admins("[key_name_admin(usr)] has goon-vampired [key_name_admin(current)]")

			if("vampire")
				if(isvampire(src))
					return

				var/datum/antagonist/vampire/new_vampire/vamp = new()
				vamp.give_objectives = FALSE
				add_antag_datum(vamp)
				to_chat(usr, span_notice("У вампира [key] отсутствуют цели. Вы можете добавить их вручную или сгенерировать случайный набор, кнопкой <b>Randomize!</b>"))
				to_chat(current, "<b><font color='red'>Ваши силы пробудились. Ваша жажда крови растет... Вы вампир!</font></b>")
				log_admin("[key_name(usr)] has vampired [key_name(current)]")
				message_admins("[key_name_admin(usr)] has vampired [key_name_admin(current)]")

			if("edit_usable_blood")
				if(!isvampire(src))
					return

				var/new_usable = tgui_input_number(usr, "Select a new value:", "Modify usable blood")
				if(isnull(new_usable) || new_usable < 0)
					return

				var/datum/antagonist/vampire/vamp = has_antag_datum(/datum/antagonist/vampire)
				vamp.bloodusable = new_usable
				current.update_action_buttons_icon()
				log_admin("[key_name(usr)] has set [key_name(current)]'s usable blood to [new_usable].")
				message_admins("[key_name_admin(usr)] has set [key_name_admin(current)]'s usable blood to [new_usable].")

			if("edit_total_blood")
				if(!isvampire(src))
					return

				var/new_total = tgui_input_number(usr, "Select a new value:", "Modify total blood")
				if(isnull(new_total) || new_total < 0)
					return

				var/datum/antagonist/vampire/vamp = has_antag_datum(/datum/antagonist/vampire)
				if(new_total < vamp.bloodtotal)
					if(tgui_alert(usr, "Note that reducing the vampire's total blood may remove some active powers. Continue?", "Confirm New Total", list("Yes", "No")) == "No")
						return
					vamp.remove_all_powers()

				vamp.bloodtotal = new_total
				vamp.check_vampire_upgrade()
				log_admin("[key_name(usr)] has set [key_name(current)]'s total blood to [new_total].")
				message_admins("[key_name_admin(usr)] has set [key_name_admin(current)]'s total blood to [new_total].")

			if("change_subclass")
				if(!isvampire(src))
					return

				var/list/subclass_selection = list()
				for(var/subtype in subtypesof(/datum/vampire_subclass))
					var/datum/vampire_subclass/subclass = subtype
					subclass_selection[capitalize(initial(subclass.name))] = subtype
				subclass_selection["Let them choose (remove current subclass)"] = NONE

				var/new_subclass_name = tgui_input_list(usr, "Choose a new subclass:", "Change Vampire Subclass", subclass_selection)
				if(!new_subclass_name)
					return

				var/datum/antagonist/vampire/vamp = has_antag_datum(/datum/antagonist/vampire)
				var/subclass_type = subclass_selection[new_subclass_name]

				if(subclass_type == NONE)
					vamp.clear_subclass()
					log_admin("[key_name(usr)] has removed [key_name(current)]'s vampire subclass.")
					message_admins("[key_name_admin(usr)] has removed [key_name_admin(current)]'s vampire subclass.")
				else
					vamp.upgrade_tiers -= /obj/effect/proc_holder/spell/vampire/self/specialize
					vamp.change_subclass(subclass_type)
					log_admin("[key_name(usr)] has removed [key_name(current)]'s vampire subclass.")
					message_admins("[key_name_admin(usr)] has removed [key_name_admin(current)]'s vampire subclass.")

			if("full_power_override")
				if(!isvampire(src))
					return

				var/datum/antagonist/vampire/vamp = has_antag_datum(/datum/antagonist/vampire)
				if(vamp.subclass.full_power_override)
					vamp.subclass.full_power_override = FALSE
					for(var/power in vamp.powers)
						if(!is_type_in_list(power, vamp.subclass.fully_powered_abilities))
							continue
						vamp.remove_ability(power)
				else
					vamp.subclass.full_power_override = TRUE

				vamp.check_full_power_upgrade()
				log_admin("[key_name(usr)] set [key_name(current)]'s vampire 'full_power_overide' to [vamp.subclass.full_power_override].")
				message_admins("[key_name_admin(usr)] set [key_name_admin(current)]'s vampire 'full_power_overide' to [vamp.subclass.full_power_override].")

			if("edit_hearts")
				var/datum/antagonist/vampire/vamp = has_antag_datum(/datum/antagonist/vampire)
				if(!vamp || QDELETED(vamp.subclass))
					return

				var/new_total = tgui_input_number(usr, "Adjust a new value:", "Modify hearts trophies")
				if(isnull(new_total))
					return

				vamp.adjust_trophies(INTERNAL_ORGAN_HEART, new_total)
				log_admin("[key_name(usr)] has adjusted [key_name(current)]'s hearts trophies by [new_total].")
				message_admins("[key_name_admin(usr)] has adjusted [key_name_admin(current)]'s hearts trophies by [new_total].")

			if("edit_lungs")
				var/datum/antagonist/vampire/vamp = has_antag_datum(/datum/antagonist/vampire)
				if(!vamp || QDELETED(vamp.subclass))
					return

				var/new_total = tgui_input_number(usr, "Adjust a new value:", "Modify lungs trophies")
				if(isnull(new_total))
					return

				vamp.adjust_trophies(INTERNAL_ORGAN_LUNGS, new_total)
				log_admin("[key_name(usr)] has adjusted [key_name(current)]'s lungs trophies by [new_total].")
				message_admins("[key_name_admin(usr)] has adjusted [key_name_admin(current)]'s lungs trophies by [new_total].")

			if("edit_livers")
				var/datum/antagonist/vampire/vamp = has_antag_datum(/datum/antagonist/vampire)
				if(!vamp || QDELETED(vamp.subclass))
					return

				var/new_total = tgui_input_number(usr, "Adjust a new value:", "Modify livers trophies")
				if(isnull(new_total))
					return

				vamp.adjust_trophies(INTERNAL_ORGAN_LIVER, new_total)
				log_admin("[key_name(usr)] has adjusted [key_name(current)]'s livers trophies by [new_total].")
				message_admins("[key_name_admin(usr)] has adjusted [key_name_admin(current)]'s livers trophies by [new_total].")

			if("edit_kidneys")
				var/datum/antagonist/vampire/vamp = has_antag_datum(/datum/antagonist/vampire)
				if(!vamp || QDELETED(vamp.subclass))
					return

				var/new_total = tgui_input_number(usr, "Adjust a new value:", "Modify kidneys trophies")
				if(isnull(new_total))
					return

				vamp.adjust_trophies(INTERNAL_ORGAN_KIDNEYS, new_total)
				log_admin("[key_name(usr)] has adjusted [key_name(current)]'s kidneys trophies by [new_total].")
				message_admins("[key_name_admin(usr)] has adjusted [key_name_admin(current)]'s kidneys trophies by [new_total].")

			if("edit_eyes")
				var/datum/antagonist/vampire/vamp = has_antag_datum(/datum/antagonist/vampire)
				if(!vamp || QDELETED(vamp.subclass))
					return

				var/new_total = tgui_input_number(usr, "Adjust a new value:", "Modify eyes trophies")
				if(isnull(new_total))
					return

				vamp.adjust_trophies(INTERNAL_ORGAN_EYES, new_total)
				log_admin("[key_name(usr)] has adjusted [key_name(current)]'s eyes trophies by [new_total].")
				message_admins("[key_name_admin(usr)] has adjusted [key_name_admin(current)]'s eyes trophies by [new_total].")

			if("edit_ears")
				var/datum/antagonist/vampire/vamp = has_antag_datum(/datum/antagonist/vampire)
				if(!vamp || QDELETED(vamp.subclass))
					return

				var/new_total = tgui_input_number(usr, "Adjust a new value:", "Modify ears trophies")
				if(isnull(new_total))
					return

				vamp.adjust_trophies(INTERNAL_ORGAN_EARS, new_total)
				log_admin("[key_name(usr)] has adjusted [key_name(current)]'s ears trophies by [new_total].")
				message_admins("[key_name_admin(usr)] has adjusted [key_name_admin(current)]'s ears trophies by [new_total].")

			if("autoobjectives")
				if(!isvampire(src))
					return

				var/datum/antagonist/vampire/vamp = has_antag_datum(/datum/antagonist/vampire)
				vamp.give_objectives()
				to_chat(usr, span_notice("Для вампира [key] сгенерированы задания. Вы можете отредактировать и объявить их вручную."))
				log_admin("[key_name(usr)] has automatically forged objectives for [key_name(current)]")
				message_admins("[key_name_admin(usr)] has automatically forged objectives for [key_name_admin(current)]")

	else if(href_list["vampthrall"])
		switch(href_list["vampthrall"])
			if("clear")
				if(has_antag_datum(/datum/antagonist/mindslave/thrall))
					remove_antag_datum(/datum/antagonist/mindslave/thrall)
					log_admin("[key_name(usr)] has de-vampthralled [key_name(current)]")
					message_admins("[key_name_admin(usr)] has de-vampthralled [key_name_admin(current)]")

	else if(href_list["nuclear"])
		var/mob/living/carbon/human/H = current

		switch(href_list["nuclear"])
			if("clear")
				remove_syndicate_role()
				to_chat(current, "<span class='warning'><span style='font-size: 3;'><b>You have been brainwashed! You are no longer a syndicate operative!</b></span></span>")
				log_admin("[key_name(usr)] has de-nuke op'd [key_name(current)]")
				message_admins("[key_name_admin(usr)] has de-nuke op'd [key_name_admin(current)]")
			if("nuclear")
				if(!(src in SSticker.mode.syndicates))
					SSticker.mode.syndicates += src
					SSticker.mode.update_synd_icons_added(src)
					if(SSticker.mode.syndicates.len==1)
						SSticker.mode.prepare_syndicate_leader(src)
					else
						current.real_name = "[syndicate_name()] Operative #[SSticker.mode.syndicates.len-1]"
					special_role = SPECIAL_ROLE_NUKEOPS
					to_chat(current, "<span class='notice'>You are a [syndicate_name()] agent!</span>")
					SSticker.mode.forge_syndicate_objectives(src)
					SSticker.mode.greet_syndicate(src)
					log_admin("[key_name(usr)] has nuke op'd [key_name(current)]")
					message_admins("[key_name_admin(usr)] has nuke op'd [key_name_admin(current)]")
			if("lair")
				current.forceMove(get_turf(locate("landmark*Syndicate-Spawn")))
				log_admin("[key_name(usr)] has moved [key_name(current)] to the nuclear operative spawn")
				message_admins("[key_name_admin(usr)] has moved [key_name_admin(current)] to the nuclear operative spawn")
			if("dressup")
				qdel(H.belt)
				qdel(H.back)
				qdel(H.l_ear)
				qdel(H.r_ear)
				qdel(H.gloves)
				qdel(H.head)
				qdel(H.shoes)
				qdel(H.wear_id)
				qdel(H.wear_pda)
				qdel(H.wear_suit)
				qdel(H.w_uniform)

				if(!SSticker.mode.equip_syndicate(current))
					to_chat(usr, "<span class='warning'>Equipping a syndicate failed!</span>")
					return
				SSticker.mode.update_syndicate_id(current.mind, SSticker.mode.syndicates.len == 1)
				log_admin("[key_name(usr)] has equipped [key_name(current)] as a nuclear operative")
				message_admins("[key_name_admin(usr)] has equipped [key_name_admin(current)] as a nuclear operative")

			if("tellcode")
				var/code
				for(var/obj/machinery/nuclearbomb/bombue in GLOB.machines)
					if(length(bombue.r_code) <= 5 && bombue.r_code != "LOLNO" && bombue.r_code != "ADMIN")
						code = bombue.r_code
						break
				if(code)
					store_memory("<b>Syndicate Nuclear Bomb Code</b>: [code]", 0, 0)
					to_chat(current, "The nuclear authorization code is: <b>[code]</b>")
					log_admin("[key_name(usr)] has given [key_name(current)] the nuclear authorization code")
					message_admins("[key_name_admin(usr)] has given [key_name_admin(current)] the nuclear authorization code")
				else
					to_chat(usr, "<span class='warning'>No valid nuke found!</span>")

	else if(href_list["space_dragon"])
		switch(href_list["space_dragon"])
			if("clear")
				var/datum/antagonist/space_dragon/dragon_datum = has_antag_datum(/datum/antagonist/space_dragon)
				if(!dragon_datum)
					return

				remove_antag_datum(dragon_datum)
				log_admin("[key_name(usr)] has removed space dragon role from [key_name(current)]")
				message_admins("[key_name_admin(usr)] has removed space dragon role from [key_name_admin(current)]")

			if("space_dragon")
				var/datum/antagonist/space_dragon/dragon_datum = has_antag_datum(/datum/antagonist/space_dragon)
				if(dragon_datum)
					return

				add_antag_datum(new /datum/antagonist/space_dragon)
				playsound(current, 'sound/magic/ethereal_exit.ogg', 50, TRUE, -1)
				log_admin("[key_name(usr)] has added space dragon role to [key_name(current)]")
				message_admins("[key_name_admin(usr)] has added space dragon role to [key_name_admin(current)]")

	else if(href_list["eventmisc"])
		switch(href_list["eventmisc"])
			if("clear")
				if(src in SSticker.mode.eventmiscs)
					remove_event_role()
					message_admins("[key_name_admin(usr)] has de-eventantag'ed [current].")
					log_admin("[key_name(usr)] has de-eventantag'ed [current].")
			if("eventmisc")
				SSticker.mode.eventmiscs += src
				special_role = SPECIAL_ROLE_EVENTMISC
				SSticker.mode.update_eventmisc_icons_added(src)
				message_admins("[key_name_admin(usr)] has eventantag'ed [current].")
				log_admin("[key_name(usr)] has eventantag'ed [current].")
	else if(href_list["devil"])
		switch(href_list["devil"])
			if("clear")
				if(src in SSticker.mode.devils)
					log_admin("[key_name(usr)] has de-devil'ed [current].")

				else if(src in SSticker.mode.sintouched)
					message_admins("[key_name_admin(usr)] has de-sintouch'ed [current].")
					log_admin("[key_name(usr)] has de-sintouch'ed [current].")

				remove_devil_role()
			if("devil")
				if(has_antag_datum(/datum/antagonist/devil))
					return

				add_antag_datum(/datum/antagonist/devil)
				message_admins("[key_name_admin(usr)] has devil'ed [current].")
				log_admin("[key_name(usr)] has devil'ed [current].")
			if("sintouched")
				if(has_antag_datum(/datum/antagonist/sintouched))
					return

				add_antag_datum(/datum/antagonist/sintouched)
				message_admins("[key_name_admin(usr)] has sintouch'ed [current].")
				log_admin("[key_name(usr)] has sintouch'ed [current].")

	else if(href_list["traitor"])
		switch(href_list["traitor"])
			if("clear")
				var/datum/antagonist/traitor/traitor_datum = has_antag_datum(/datum/antagonist/traitor)
				if(!traitor_datum)
					return

				traitor_datum.silent = TRUE
				remove_antag_datum(traitor_datum)
				to_chat(current, "<span class='warning'><span style='font-size: 3;'><b>You have been brainwashed! You are no longer a traitor!</b></span></span>")
				log_admin("[key_name(usr)] has de-traitored [key_name(current)]")
				message_admins("[key_name_admin(usr)] has de-traitored [key_name_admin(current)]")

			if("traitor")
				if(!(has_antag_datum(/datum/antagonist/traitor)))
					var/datum/antagonist/traitor/traitor_datum = new()
					traitor_datum.give_objectives = FALSE
					traitor_datum.give_uplink = FALSE
					add_antag_datum(traitor_datum)
					log_admin("[key_name(usr)] has traitored [key_name(current)]")
					message_admins("[key_name_admin(usr)] has traitored [key_name_admin(current)]")

			if("autoobjectives")
				var/datum/antagonist/traitor/traitor_datum = has_antag_datum(/datum/antagonist/traitor)
				if(!traitor_datum)
					return

				traitor_datum.give_objectives()
				to_chat(usr, "<span class='notice'>The objectives for traitor [key] have been generated. You can edit them and announce manually.</span>")
				log_admin("[key_name(usr)] has automatically forged objectives for [key_name(current)]")
				message_admins("[key_name_admin(usr)] has automatically forged objectives for [key_name_admin(current)]")

	else if(href_list["malf_ai"])
		switch(href_list["malf_ai"])
			if("clear")
				var/datum/antagonist/malf_ai/malf_datum = has_antag_datum(/datum/antagonist/malf_ai)
				if(!malf_datum)
					return

				remove_antag_datum(malf_datum)
				to_chat(current, "<span class='warning'><span style='font-size: 3;'><b>Unknown hackers have brought your systems back to normal, you are no longer malfunctioning!</b></span></span>")
				log_admin("[key_name(usr)] has de-malfAIed [key_name(current)]")
				message_admins("[key_name_admin(usr)] has de-malfAIed [key_name_admin(current)]")
				SSticker?.score?.save_silicon_laws(current, usr, additional_info = "admin removed malf AI", log_all_laws = TRUE)

			if("malf_ai")
				if(has_antag_datum(/datum/antagonist/malf_ai))
					return

				var/datum/antagonist/malf_ai/malf_datum = new
				malf_datum.give_objectives = FALSE
				add_antag_datum(malf_datum)
				log_admin("[key_name(usr)] has malfAIed [key_name(current)]")
				message_admins("[key_name_admin(usr)] has malfAIed [key_name_admin(current)]")
				SSticker?.score?.save_silicon_laws(current, usr, additional_info = "admin made malf AI", log_all_laws = TRUE)

			if("autoobjectives")
				var/datum/antagonist/malf_ai/malf_datum = has_antag_datum(/datum/antagonist/malf_ai)
				if(!malf_datum)
					return

				malf_datum.give_objectives()
				to_chat(usr, "<span class='notice'>The objectives for malf AI [key] have been generated. You can edit them and announce manually.</span>")
				log_admin("[key_name(usr)] has automatically forged objectives for [key_name(current)]")
				message_admins("[key_name_admin(usr)] has automatically forged objectives for [key_name_admin(current)]")

	else if(href_list["contractor"])
		var/datum/antagonist/contractor/C = has_antag_datum(/datum/antagonist/contractor)
		var/datum/contractor_hub/H = C && C.contractor_uplink?.hub
		switch(href_list["contractor"])
			if("clear")
				remove_contractor_role()
				log_admin("[key_name(usr)] has de-contractored [key_name(current)]")
				message_admins("[key_name_admin(usr)] has de-contractored [key_name_admin(current)]")

			if("contractor")
				if(has_antag_datum(/datum/antagonist/contractor))
					return
				var/datum/antagonist/contractor/contractor_datum = new()
				contractor_datum.is_admin_forced = TRUE
				add_antag_datum(contractor_datum)
				// Notify
				log_admin("[key_name(usr)] has contractored [key_name(current)]")
				message_admins("[key_name_admin(usr)] has contractored [key_name_admin(current)]")

			if("add")
				if(!C)
					return
				var/list/possible_targets = list()
				for(var/foo in SSticker.minds)
					var/datum/mind/possible_target = foo
					if(src == possible_target || !possible_target.current || !possible_target.key)
						continue
					possible_targets[possible_target.name] = possible_target

				var/choice = tgui_input_list(usr, "Select the contract target:", "Add Contract", possible_targets)
				var/datum/mind/target = possible_targets[choice]
				if(!target || !target.current || !target.key)
					return
				var/datum/syndicate_contract/new_contract = new(H, src, list(), target)
				new_contract.reward_tc = list(0, 0, 0)
				H.contracts += new_contract
				SStgui.update_uis(C.contractor_uplink.hub)
				log_admin("[key_name(usr)] has given a new contract to [key_name(current)] with [target.current] as the target")
				message_admins("[key_name_admin(usr)] has given a new contract to [key_name_admin(current)] with [target.current] as the target")

			if("tc")
				if(!C)
					return
				var/new_tc = tgui_input_number(usr, "Enter the new amount of TC:", "Set Claimable TC", H.reward_tc_available)
				new_tc = text2num(new_tc)
				if(isnull(new_tc) || new_tc < 0)
					return
				H.reward_tc_available = new_tc
				SStgui.update_uis(C.contractor_uplink.hub)
				log_admin("[key_name(usr)] has set [key_name(current)]'s claimable TC to [new_tc]")
				message_admins("[key_name_admin(usr)] has set [key_name_admin(current)]'s claimable TC to [new_tc]")

			if("rep")
				if(!C)
					return
				var/new_rep = tgui_input_number(usr, "Enter the new amount of Rep:", "Set Available Rep", H.rep)
				new_rep = text2num(new_rep)
				if(isnull(new_rep) || new_rep < 0)
					return
				H.rep = new_rep
				SStgui.update_uis(C.contractor_uplink.hub)
				log_admin("[key_name(usr)] has set [key_name(current)]'s contractor Rep to [new_rep]")
				message_admins("[key_name_admin(usr)] has set [key_name_admin(current)]'s contractor Rep to [new_rep]")

			// Contract specific actions
			if("target")
				if(!C)
					return
				var/datum/syndicate_contract/CO = locateUID(href_list["cuid"])
				if(!istype(CO))
					return

				var/list/possible_targets = list()
				for(var/foo in SSticker.minds)
					var/datum/mind/possible_target = foo
					if(src == possible_target || !possible_target.current || !possible_target.key)
						continue
					possible_targets[possible_target.name] = possible_target

				var/choice = tgui_input_list(usr, "Select the new contract target:", "Set Contract Target", possible_targets)
				var/datum/mind/target = possible_targets[choice]
				if(!target || !target.current || !target.key)
					return
				// Update
				var/datum/data/record/R = find_record("name", target.name, GLOB.data_core.general)
				var/name = R?.fields["name"] || target.name || "Unknown"
				var/rank = R?.fields["rank"] || target.assigned_role || "Unknown"
				CO.contract.target = target
				CO.target_name = "[name], the [rank]"
				if(R?.fields["photo"])
					var/icon/temp = new('icons/turf/floors.dmi', pick("floor", "wood", "darkfull", "stairs"))
					temp.Blend(R.fields["photo"], ICON_OVERLAY)
					CO.target_photo = temp
				// Notify
				SStgui.update_uis(C.contractor_uplink.hub)
				log_admin("[key_name(usr)] has set [key_name(current)]'s contract target to [target.current]")
				message_admins("[key_name_admin(usr)] has set [key_name_admin(current)]'s contract target to [target.current]")

			if("locations")
				if(!C)
					return
				var/datum/syndicate_contract/CO = locateUID(href_list["cuid"])
				if(!istype(CO))
					return

				var/list/difficulty_choices = list()
				for(var/diff in EXTRACTION_DIFFICULTY_EASY to EXTRACTION_DIFFICULTY_HARD)
					var/area/A = CO.contract.candidate_zones[diff]
					difficulty_choices["[A.name] ([CO.reward_tc[diff]] TC)"] = diff

				var/choice_diff = tgui_input_list(usr, "Select the location to change:", "Set Contract Location", difficulty_choices)
				var/difficulty = difficulty_choices[choice_diff]
				if(!difficulty)
					return

				var/list/area_choices = list()
				for(var/area/A in get_sorted_areas())
					if(A.outdoors || !is_station_level(A.z))
						continue
					area_choices += A

				var/new_area = tgui_input_list(usr, "Select the new location:", "Set Contract Location", area_choices, CO.contract.candidate_zones[difficulty])
				if(!new_area)
					return

				var/new_reward = tgui_input_number(usr, "Enter the new amount of rewarded TC:", "Set Contract Location", CO.reward_tc[difficulty])
				new_reward = text2num(new_reward)
				if(isnull(new_reward) || new_reward < 0)
					return
				CO.contract.candidate_zones[difficulty] = new_area
				CO.reward_tc[difficulty] = new_reward
				SStgui.update_uis(C.contractor_uplink.hub)
				log_admin("[key_name(usr)] has set [key_name(current)]'s contract location to [new_area] with [new_reward] TC as reward")
				message_admins("[key_name_admin(usr)] has set [key_name_admin(current)]'s contract location to [new_area] with [new_reward] TC as reward")

			if("other")
				if(!C)
					return
				var/datum/syndicate_contract/CO = locateUID(href_list["cuid"])
				if(!istype(CO))
					return

				var/choice = tgui_input_list(usr, "Select an action to take:", "Other Contract Actions", list("Edit Fluff Message", "Edit Prison Time", "Edit Credits Reward", "Delete Contract", "Cancel"))
				if(!choice)
					return

				switch(choice)
					if("Edit Fluff Message")
						var/new_message = tgui_input_text(usr, "Enter the new fluff message:", "Edit Fluff Message", CO.fluff_message, multiline = TRUE, encode = FALSE)
						if(!new_message)
							return
						CO.fluff_message = new_message
						log_admin("[key_name(usr)] has edited [key_name(current)]'s contract fluff message")
						message_admins("[key_name_admin(usr)] has edited [key_name_admin(current)]'s contract fluff message")
					if("Edit Prison Time")
						var/new_time = tgui_input_number(usr, "Enter the new prison time in seconds:", "Edit Prison Time", CO.prison_time / 10)
						if(!new_time || new_time < 0)
							return
						CO.prison_time = new_time SECONDS
						log_admin("[key_name(usr)] has edited [key_name(current)]'s contract prison time to [new_time] seconds")
						message_admins("[key_name_admin(usr)] has edited [key_name_admin(current)]'s contract prison time to [new_time] seconds")
					if("Edit Credits Reward")
						var/new_creds = tgui_input_number(usr, "Enter the new credits reward:", "Edit Credits Reward", CO.reward_credits)
						if(!new_creds || new_creds < 0)
							return
						CO.reward_credits = new_creds
						log_admin("[key_name(usr)] has edited [key_name(current)]'s contract reward credits to [new_creds]")
						message_admins("[key_name_admin(usr)] has edited [key_name_admin(current)]'s contract reward credits to [new_creds]")
					if("Delete Contract")
						if(CO.status == CONTRACT_STATUS_ACTIVE)
							CO.fail("Contract interrupted forcibly.")
						H.contracts -= CO
						log_admin("[key_name(usr)] has deleted [key_name(current)]'s contract")
						message_admins("[key_name_admin(usr)] has deleted [key_name_admin(current)]'s contract")
					else
						return
				SStgui.update_uis(C.contractor_uplink.hub)

			if("interrupt")
				if(!C)
					return
				var/datum/syndicate_contract/CO = locateUID(href_list["cuid"])
				if(!istype(CO) || CO.status != CONTRACT_STATUS_ACTIVE)
					return
				H.current_contract = null
				CO.contract.extraction_zone = null
				CO.status = CONTRACT_STATUS_INACTIVE
				CO.clean_up()
				log_admin("[key_name(usr)] has interrupted [key_name(current)]'s contract")
				message_admins("[key_name_admin(usr)] has interrupted [key_name_admin(current)]'s contract")

			if("fail")
				if(!C)
					return
				var/datum/syndicate_contract/CO = locateUID(href_list["cuid"])
				if(!istype(CO) || CO.status != CONTRACT_STATUS_ACTIVE)
					return
				var/fail_reason = sanitize(tgui_input_text(usr, "Enter the fail reason:", "Fail Contract", encode = FALSE))
				if(!fail_reason || CO.status != CONTRACT_STATUS_ACTIVE)
					return
				CO.fail(fail_reason)
				SStgui.update_uis(C.contractor_uplink.hub)
				log_admin("[key_name(usr)] has failed [key_name(current)]'s contract with reason: [fail_reason]")
				message_admins("[key_name_admin(usr)] has failed [key_name_admin(current)]'s contract with reason: [fail_reason]")

	else if(href_list["mindslave"])
		switch(href_list["mindslave"])
			if("clear")
				if(!has_antag_datum(/datum/antagonist/mindslave, FALSE))
					return

				for(var/obj/item/implant/traitor/mindslave_imp in current.contents)
					if(QDELETED(mindslave_imp))
						continue

					qdel(mindslave_imp)

				remove_antag_datum(/datum/antagonist/mindslave)
				log_admin("[key_name(usr)] has de-mindslaved [key_name(current)]")
				message_admins("[key_name_admin(usr)] has de-mindslaved [key_name_admin(current)]")

	else if(href_list["thief"])
		switch(href_list["thief"])
			if("clear")
				remove_thief_role()
				log_admin("[key_name(usr)] has de-thiefed [key_name(current)]")
				message_admins("[key_name_admin(usr)] has de-thiefed [key_name_admin(current)]")

			if("thief")
				if(has_antag_datum(/datum/antagonist/thief))
					return

				var/datum/antagonist/thief/thief_datum = new()
				thief_datum.silent = TRUE
				thief_datum.give_objectives = FALSE
				thief_datum.give_kit = FALSE
				add_antag_datum(thief_datum)
				SEND_SOUND(current, 'sound/ambience/antag/thiefalert.ogg')
				to_chat(current, "<b><font color='red'>Мои [ishuman(current) ? "руки" : "лапы"] так и чешутся чего-нибудь прикарманить!</font></b>")
				log_admin("[key_name(usr)] has thiefed [key_name(current)]")
				message_admins("[key_name_admin(usr)] has thiefed [key_name_admin(current)]")

			if("autoobjectives")
				var/datum/antagonist/thief/thief_datum = has_antag_datum(/datum/antagonist/thief)
				if(!thief_datum)
					return

				thief_datum.give_objectives()
				to_chat(usr, "<span class='notice'>The objectives for thief [key] have been generated. You can edit them and announce manually.</span>")
				log_admin("[key_name(usr)] has automatically forged objectives for [key_name(current)]")
				message_admins("[key_name_admin(usr)] has automatically forged objectives for [key_name_admin(current)]")

			if("equip")
				var/datum/antagonist/thief/thief_datum = has_antag_datum(/datum/antagonist/thief)
				if(!thief_datum)
					return

				thief_datum.equip_thief_kit()
				log_admin("[key_name(usr)] give [key_name(current)] thief equipment")
				message_admins("[key_name_admin(usr)] give [key_name_admin(current)] thief equipment")

	else if(href_list["shadowling"])
		switch(href_list["shadowling"])
			if("clear")
				if(src in SSticker.mode.shadows)
					message_admins("[key_name_admin(usr)] has de-shadowlinged [current].")
					log_admin("[key_name(usr)] has de-shadowlinged [current].")
				else if(src in SSticker.mode.shadowling_thralls)
					message_admins("[key_name_admin(usr)] has de-thrall'ed [current].")
					log_admin("[key_name(usr)] has de-thralled [key_name(current)]")
					message_admins("[key_name_admin(usr)] has de-thralled [key_name_admin(current)]")
				remove_shadow_role()
			if("shadowling")
				if(!ishuman(current))
					to_chat(usr, "<span class='warning'>This only works on humans!</span>")
					return
				SSticker.mode.shadows += src
				special_role = SPECIAL_ROLE_SHADOWLING
				SSticker.mode.recount_required_thralls()
				to_chat(current, "<span class='shadowling'><b>Что-то всплывает в глубинах твоего разума. Твой взгляд заливает красным свечением и ты медленно вспоминаешь. Твоя маскировка под гуманойда послужила тебе прекрасно, но \
				время отбросить её и вернутся к своей истинной форме. Ты замаскировался под гуманойда, но ты не один из них. Ты тенелинг и ты должен возвыситься любой ценой.\
				</b></span>")
				SSticker.mode.finalize_shadowling(src)
				SSticker.mode.update_shadow_icons_added(src)
				log_admin("[key_name(usr)] has shadowlinged [key_name(current)]")
				message_admins("[key_name_admin(usr)] has shadowlinged [key_name_admin(current)]")
			if("thrall")
				if(!ishuman(current))
					to_chat(usr, "<span class='warning'>This only works on humans!</span>")
					return
				SSticker.mode.add_thrall(src)
				message_admins("[key_name_admin(usr)] has thralled [current].")
				log_admin("[key_name(usr)] has thralled [current].")

	else if(href_list["abductor"])
		switch(href_list["abductor"])
			if("clear")
				to_chat(usr, "Not implemented yet. Sorry!")
				//ticker.mode.update_abductor_icons_removed(src)
			if("abductor")
				if(!ishuman(current))
					to_chat(usr, "<span class='warning'>This only works on humans!</span>")
					return
				make_Abductor()
				log_admin("[key_name(usr)] turned [current] into abductor.")
				SSticker.mode.update_abductor_icons_added(src)
			if("equip")
				if(!ishuman(current))
					to_chat(usr, "<span class='warning'>This only works on humans!</span>")
					return

				var/mob/living/carbon/human/H = current
				var/gear = tgui_alert(usr, "Agent or Scientist Gear", "Gear", list("Agent", "Scientist"))
				if(gear)
					if(gear=="Agent")
						H.equipOutfit(/datum/outfit/abductor/agent)
					else
						H.equipOutfit(/datum/outfit/abductor/scientist)
	else if(href_list["ninja"])
		switch(href_list["ninja"])
			if("clear")
				remove_ninja_role()
				log_and_message_admins("has removed special role \"Ninja\" from [key_name_admin(current)]")
				add_conversion_logs(current, "De-ninjad")

			if("ninja")
				if(isninja(src))
					return
				var/datum/antagonist/ninja/ninja_datum = new
				ninja_datum.allow_rename = FALSE
				ninja_datum.give_equip = FALSE
				ninja_datum.give_objectives = FALSE
				ninja_datum.generate_antags = FALSE
				add_antag_datum(ninja_datum)
				log_admin("[key_name(usr)] has made [key_name(current)] into a \"Ninja\"")
				message_admins("[key_name_admin(usr)] has made [key_name_admin(current)] into a \"Ninja\"")

			if("dojo")
				current.forceMove(pick(GLOB.ninjastart))
				log_admin("[key_name(usr)] has moved [key_name(current)] tp dojo")
				message_admins("[key_name_admin(usr)] has moved [key_name_admin(current)] to dojo")

			if("dressup")
				var/datum/antagonist/ninja/ninja_datum = has_antag_datum(/datum/antagonist/ninja)
				if(!ninja_datum)
					return

				ninja_datum.change_species(current)
				ninja_datum.equip_ninja()
				log_admin("[key_name(usr)] has equipped [key_name(current)] as a ninja")
				message_admins("[key_name_admin(usr)] has equipped [key_name_admin(current)] as a ninja")

			if("name")
				var/datum/antagonist/ninja/ninja_datum = has_antag_datum(/datum/antagonist/ninja)
				if(!ninja_datum)
					return

				ninja_datum.allow_rename = TRUE
				INVOKE_ASYNC(ninja_datum, TYPE_PROC_REF(/datum/antagonist/ninja, name_ninja))
				log_admin("[key_name(usr)] has allowed ninja [key_name(current)] to name themselves")
				message_admins("[key_name_admin(usr)] has allowed ninja [key_name_admin(current)] to name themselves")

			if("autoobjectives")
				var/datum/antagonist/ninja/ninja_datum = has_antag_datum(/datum/antagonist/ninja)
				if(!ninja_datum?.my_suit)
					to_chat(usr,span_warning("Ниндзя - зависим от костюма. Рандомная выдача целей, до выдачи костюма ведёт к ошибкам!"))
					return
				var/list/objective_types = list(NINJA_TYPE_GENERIC, NINJA_TYPE_PROTECTOR, NINJA_TYPE_HACKER, NINJA_TYPE_KILLER)
				var/objective_type = tgui_input_list(usr, "Select type of objectives to generate", "Objective type selection", objective_types)
				if(objective_type != NINJA_TYPE_GENERIC)
					if(tgui_alert(usr, "Данный вид целей генерирует дополнительных антагонистов в раунд. Продолжить?", "ВАЖНО!", list("Да", "Нет")) == "Нет")
						return
					if(ninja_datum.antags_done)
						to_chat(usr, span_warning("Антагонисты уже были сгенерированы!"))
						return
				if(!objective_type)
					if(tgui_alert(usr, "Рандомный выбор типа целей имеет ВЫСОКИЙ шанс сгенерировать дополнительных антагонистов в раунд. Начать генерацию?", "ВАЖНО!", list("Да", "Нет")) == "Нет")
						return
					if(ninja_datum.antags_done)
						to_chat(usr, span_warning("Антагонисты уже были сгенерированы, случайная генерация более невозможна!"))
						return

				ninja_datum.make_objectives_generate_antags(objective_type)
				to_chat(usr, span_notice("Цели для ниндзя: [key] были сгенерированы. Вы можете их отредактировать и оповестить игрока о целях вручную."))
				log_admin("[key_name(usr)] has automatically forged ninja objectives for [key_name(current)]")
				message_admins("[key_name_admin(usr)] has automatically forged ninja objectives for [key_name_admin(current)]")

	else if(href_list["silicon"])
		switch(href_list["silicon"])
			if("borgpanel")
				var/mob/living/silicon/robot/R = current
				var/datum/borgpanel/B = new(usr, R)
				B.ui_interact(usr)
				log_and_message_admins("has opened [R]'s Borg Panel.")
			if("lawmanager")
				var/mob/living/silicon/S = current
				var/datum/ui_module/law_manager/L = new(S)
				L.ui_interact(usr)
				log_and_message_admins("has opened [S]'s law manager.")
			if("unemag")
				var/mob/living/silicon/robot/R = current
				if(!istype(R))
					return
				R.unemag()
				log_admin("[key_name(usr)] has un-emagged [key_name(current)]")
				message_admins("[key_name_admin(usr)] has un-emagged [key_name_admin(current)]")

			if("unemagcyborgs")
				if(!isAI(current))
					return
				var/mob/living/silicon/ai/ai = current
				for(var/mob/living/silicon/robot/R in ai.connected_robots)
					R.unemag()
				log_admin("[key_name(usr)] has unemagged [key_name(ai)]'s cyborgs")
				message_admins("[key_name_admin(usr)] has unemagged [key_name_admin(ai)]'s cyborgs")

	else if(href_list["blob"])
		switch(href_list["blob"])
			if("clear")
				remove_antag_datum(/datum/antagonist/blob_infected)
				log_and_message_admins("has removed special role \"Blob\" from [key_name_admin(current)]")
				add_conversion_logs(current, "De-blobed")

			if("blob")
				var/burst_time = tgui_input_number(usr, "Введите время до вылупления","Time:", TIME_TO_BURST_ADDED_HIGHT)
				var/need_new_blob = tgui_alert(usr, "Нужно ли выбирать блоба из экипажа в случае попытки вылупления за пределами станции?", "", list("Да", "Нет")) == "Нет"
				var/start_process = tgui_alert(usr,"Начинать отсчет до момента вылупления?", "", list("Да", "Нет")) == "Да"
				if(isnull(burst_time) || QDELETED(current) || current.stat == DEAD)
					return
				var/datum_type = get_blob_infected_type()
				var/datum/antagonist/blob_infected/blob_datum = new datum_type()
				blob_datum.need_new_blob = need_new_blob
				blob_datum.start_process = start_process
				blob_datum.time_to_burst_hight = burst_time
				blob_datum.time_to_burst_low = burst_time
				add_antag_datum(blob_datum)
				log_admin("[key_name(usr)] has made [key_name(current)] into a \"Blob\"")
				message_admins("[key_name_admin(usr)] has made [key_name_admin(current)] into a \"Blob\"")

			if("burst")
				var/warn_blob = tgui_alert(usr,"Предупреждать блоба при попытке вылупления за пределами станции?", "", list("Да", "Нет")) != "Да"
				var/need_new_blob = tgui_alert(usr,"Нужно ли выбирать блоба из экипажа в случае попытки вылупления за пределами станции?", "", list("Да", "Нет")) == "Да"
				if(tgui_alert(usr,"Вы действительно хотите лопнуть блоба? Это уничтожит персонажа игрока и превратит его в блоба.", "", list("Да", "Нет")) == "Да")
					var/datum/antagonist/blob_infected/blob = has_antag_datum(/datum/antagonist/blob_infected)
					if(!blob)
						return
					blob.warn_blob = warn_blob
					blob.need_new_blob = need_new_blob
					blob.burst_blob()
					log_admin("[key_name(usr)] has bursted [key_name(current)]")
					message_admins("[key_name_admin(usr)] has bursted [key_name_admin(current)]")

			if("set_points")
				if(!isblobovermind(src))
					return
				var/mob/camera/blob/blob_overmind = current
				var/blob_points = tgui_input_number(usr, "Введите новое число очков в диапазоне от 0 до [blob_overmind.max_blob_points]", "Count:", blob_overmind.blob_points, blob_overmind.max_blob_points, 0)
				if(isnull(blob_points) || QDELETED(current) || current.stat == DEAD)
					return
				blob_overmind.blob_points = clamp(blob_points, 0, blob_overmind.max_blob_points)
				log_admin("[key_name(usr)] set blob points to [key_name(current)] as [blob_overmind.blob_points]")
				message_admins("[key_name_admin(usr)] set blob points to [key_name_admin(current)] as [blob_overmind.blob_points]")

			if("inf_points")
				if(!isblobovermind(src))
					return
				var/mob/camera/blob/blob_overmind = current
				if(QDELETED(current) || current.stat == DEAD)
					return
				blob_overmind.is_infinity = !blob_overmind.is_infinity
				log_admin("[key_name(usr)] make blob points [blob_overmind.is_infinity? "infinity" : "not infinity"] to [key_name(current)]")
				message_admins("[key_name_admin(usr)] make blob points [blob_overmind.is_infinity? "infinity" : "not infinity"] to [key_name_admin(current)]")

			if("select_strain")
				if(!isblobovermind(src))
					return
				var/mob/camera/blob/blob_overmind = current
				if(QDELETED(current) || current.stat == DEAD)
					return
				var/strain = tgui_input_list(usr, "Выберите штамм", "Выбор штамма", GLOB.valid_blobstrains, null)
				if(ispath(strain))
					blob_overmind.set_strain(strain)
					log_admin("[key_name(usr)] changed the strain to [strain] for [key_name(current)]")
					message_admins("[key_name_admin(usr)] changed the strain to [strain] for [key_name_admin(current)]")

	else if(href_list["terror"])
		switch(href_list["terror"])
			if("datumise")
				if(QDELETED(current) || current.stat == DEAD)
					return
				var/mob/living/simple_animal/hostile/poison/terror_spider/spider = current
				spider.add_datum_if_not_exist()
				log_and_message_admins("has made [key_name(current)] into a \"Terror Spider\"")

	else if(href_list["xenomorph"])
		switch(href_list["xenomorph"])
			if("datumise")
				if(QDELETED(current) || current.stat == DEAD)
					return
				var/mob/living/carbon/alien/alien = current
				alien.update_datum()
				log_and_message_admins("has made [key_name(current)] into a \"Xenomorph\"")

	else if(href_list["common"])
		switch(href_list["common"])
			if("undress")
				if(ishuman(current))
					var/mob/living/carbon/human/H = current
					// Don't "undress" organs right out of the body
					for(var/obj/item/W in H.contents - (H.bodyparts | H.internal_organs))
						current.drop_item_ground(W, TRUE)
				else
					for(var/obj/item/W in current)
						current.drop_item_ground(W, TRUE)
				log_admin("[key_name(usr)] has unequipped [key_name(current)]")
				message_admins("[key_name_admin(usr)] has unequipped [key_name_admin(current)]")

			if("takeuplink")
				take_uplink()
				var/datum/antagonist/traitor/traitor_datum = has_antag_datum(/datum/antagonist/traitor)
				traitor_datum.antag_memory = "" //Remove any antag memory they may have had (uplink codes, code phrases)
				log_admin("[key_name(usr)] has taken [key_name(current)]'s uplink")
				message_admins("[key_name_admin(usr)] has taken [key_name_admin(current)]'s uplink")

			if("crystals")
				if(usr.client.holder.rights & (R_SERVER|R_EVENT))
					var/obj/item/uplink/hidden/suplink = find_syndicate_uplink()
					var/crystals
					if(suplink)
						crystals = suplink.uses
					crystals = tgui_input_number(usr, "Amount of telecrystals for [key]", "Syndicate uplink", crystals)
					if(!isnull(crystals))
						if(suplink)
							suplink.uses = crystals
							log_admin("[key_name(usr)] has set [key_name(current)]'s telecrystals to [crystals]")
							message_admins("[key_name_admin(usr)] has set [key_name_admin(current)]'s telecrystals to [crystals]")

			if("uplink")
				var/datum/antagonist/traitor/traitor_datum = has_antag_datum(/datum/antagonist/traitor)
				if(!traitor_datum)
					return

				if(traitor_datum.hidden_uplink)
					to_chat(usr, span_warning("[current] already has an uplink!"))
					return

				if(!traitor_datum.antag_memory)
					traitor_datum.give_codewords()

				if(!traitor_datum.give_uplink())
					to_chat(usr, span_warning("Equipping a syndicate failed!"))
					return

				traitor_datum.announce_uplink_info()
				log_admin("[key_name(usr)] has given [key_name(current)] an uplink")
				message_admins("[key_name_admin(usr)] has given [key_name_admin(current)] an uplink")

	else if(href_list["obj_announce"])
		var/list/messages = prepare_announce_objectives()
		to_chat(current, chat_box_red(messages.Join("<br>")))
		SEND_SOUND(current, sound('sound/ambience/alarm4.ogg'))
		log_admin("[key_name(usr)] has announced [key_name(current)]'s objectives")
		message_admins("[key_name_admin(usr)] has announced [key_name_admin(current)]'s objectives")

	edit_memory()


/**
 * Create and/or add the `datum_type_or_instance` antag datum to the src mind.
 *
 * Arguments:
 * * datum_type - an antag datum typepath or instance
 * * datum/team/team - the antag team that the src mind should join, if any
 */
/datum/mind/proc/add_antag_datum(datum_type_or_instance, team)
	if(!datum_type_or_instance)
		return
	var/datum/antagonist/antag
	if(!ispath(datum_type_or_instance))
		antag = datum_type_or_instance
		if(!istype(antag))
			return
	else
		antag = new datum_type_or_instance()

	if(!antag.can_be_owned(src))
		qdel(antag)
		return

	antag.owner = src
	LAZYADD(antag_datums, antag)

	antag.create_team(team)
	var/datum/team/antag_team = antag.get_team()
	if(antag_team)
		antag_team.add_member(src)

	ASSERT(antag.owner && antag.owner.current)
	antag.on_gain()
	return antag


/**
 * Remove the specified `datum_type` antag datum from the src mind.
 *
 * Arguments:
 * * datum_type - an antag datum typepath
 */
/datum/mind/proc/remove_antag_datum(datum_type)
	var/datum/antagonist/antag = has_antag_datum(datum_type)

	if(!antag)
		return

	qdel(antag)


/**
 * Removes all antag datums from the src mind.
 *
 * Use this over doing `QDEL_LIST_CONTENTS(antag_datums)`.
 */
/datum/mind/proc/remove_all_antag_datums() //For the Lazy amongst us.
	// This is not `QDEL_LIST_CONTENTS(antag_datums)`because it's possible for the `antag_datums` list to be set to null during deletion of an antag datum.
	// Then `QDEL_LIST` would runtime because it would be doing `null.Cut()`.
	for(var/datum/antagonist/A as anything in antag_datums)
		qdel(A)
	antag_datums?.Cut()
	antag_datums = null


/datum/mind/proc/remove_revolutionary_role()
	if(src in SSticker.mode.revolutionaries)
		SSticker.mode.revolutionaries -= src
		to_chat(current, span_warning("<span style='font-size: 3;'><b>You have been brainwashed! You are no longer a revolutionary!</b></span>"))
		SSticker.mode.update_rev_icons_removed(src)
		special_role = null

	if(src in SSticker.mode.head_revolutionaries)
		SSticker.mode.head_revolutionaries -= src
		to_chat(current, span_warning("<span style='font-size: 3;'><b>You have been brainwashed! You are no longer a head revolutionary!</b></span>"))
		SSticker.mode.update_rev_icons_removed(src)
		special_role = null


/datum/mind/proc/remove_cult_role()
	if(src in SSticker.mode.cult)
		SSticker.mode.remove_cultist(src)
		special_role = null

/datum/mind/proc/remove_clocker_role()
	if(src in SSticker.mode.clockwork_cult)
		SSticker.mode.remove_clocker(src)
		special_role = null

/datum/mind/proc/remove_wizard_role()
	if(src in SSticker.mode.wizards)
		SSticker.mode.wizards -= src
		special_role = null
		current.spellremove(current)
		current.faction = list("Station")
		SSticker.mode.update_wiz_icons_removed(src)
	if(src in SSticker.mode.apprentices)
		SSticker.mode.apprentices -= src
		special_role = null
		current.spellremove(current)
		current.faction = list("Station")
		SSticker.mode.update_wiz_icons_removed(src)



/datum/mind/proc/remove_changeling_role()
	var/datum/antagonist/traitor/chan_datum = has_antag_datum(/datum/antagonist/changeling)
	if(!chan_datum)
		return

	chan_datum.silent = TRUE
	remove_antag_datum(chan_datum)


/datum/mind/proc/remove_vampire_role()
	var/datum/antagonist/vampire/vamp = has_antag_datum(/datum/antagonist/vampire)
	if(!vamp)
		return

	remove_antag_datum(vamp)


/datum/mind/proc/remove_syndicate_role()
	if(src in SSticker.mode.syndicates)
		SSticker.mode.syndicates -= src
		SSticker.mode.update_synd_icons_removed(src)
		special_role = null
		for(var/datum/objective/nuclear/O in objectives)
			objectives-=O
			qdel(O)

/datum/mind/proc/remove_event_role()
	if(src in SSticker.mode.eventmiscs)
		SSticker.mode.eventmiscs -= src
		SSticker.mode.update_eventmisc_icons_removed(src)
		special_role = null

/datum/mind/proc/remove_devil_role()
	if(src in SSticker.mode.devils)
		remove_antag_datum(/datum/antagonist/devil)

	else if(src in SSticker.mode.sintouched)
		remove_antag_datum(/datum/antagonist/sintouched)


/datum/mind/proc/remove_contractor_role()
	var/datum/antagonist/contractor/contractor_datum = has_antag_datum(/datum/antagonist/contractor)
	if(!contractor_datum)
		return

	contractor_datum.silent = TRUE
	if(contractor_datum.contractor_uplink && !contractor_datum.is_admin_forced)
		SSticker?.mode?.contractor_accepted--
	remove_antag_datum(/datum/antagonist/contractor)


/datum/mind/proc/remove_traitor_role()
	var/datum/antagonist/traitor/traitor_datum = has_antag_datum(/datum/antagonist/traitor)
	if(!traitor_datum)
		return

	traitor_datum.silent = TRUE
	remove_antag_datum(traitor_datum)


/datum/mind/proc/remove_thief_role()
	var/datum/antagonist/thief/thief_datum = has_antag_datum(/datum/antagonist/thief)
	if(!thief_datum)
		return

	remove_antag_datum(thief_datum)


/datum/mind/proc/remove_shadow_role()
	SSticker.mode.update_shadow_icons_removed(src)
	if(src in SSticker.mode.shadows)
		SSticker.mode.shadows -= src
		special_role = null
		current.spellremove(current)
		current.remove_language(LANGUAGE_HIVE_SHADOWLING)
	else if(src in SSticker.mode.shadowling_thralls)
		SSticker.mode.remove_thrall(src,0)


/datum/mind/proc/remove_ninja_role()
	var/datum/antagonist/ninja/ninja_datum = has_antag_datum(/datum/antagonist/ninja)
	if(!ninja_datum)
		return

	remove_antag_datum(ninja_datum)


/datum/mind/proc/remove_all_antag_roles(adminlog = TRUE) // Except abductor, because it isnt implemented in admin panel
	remove_revolutionary_role()
	remove_cult_role()
	remove_clocker_role()
	remove_wizard_role()
	remove_changeling_role()
	remove_vampire_role()
	remove_syndicate_role()
	remove_event_role()
	remove_devil_role()
	remove_traitor_role()
	remove_thief_role()
	remove_shadow_role()
	remove_ninja_role()

	if(adminlog)
		message_admins("[ADMIN_LOOKUP(current)] lost all antag roles")
		log_admin("[key_name_log(current)] lost all antag roles")


/**
 * Returns an antag datum instance if the src mind has the specified `datum_type`. Returns `null` otherwise.
 *
 * Arguments:
 * * datum_type - an antag datum typepath
 * * check_subtypes - TRUE if this proc will consider subtypes of `datum_type` as valid. FALSE if only the exact same type should be considered.
 */
/datum/mind/proc/has_antag_datum(datum_type, check_subtypes = TRUE)
	for(var/datum/antagonist/A as anything in antag_datums)
		if(check_subtypes && istype(A, datum_type))
			return A
		else if(A.type == datum_type)
			return A


/datum/mind/proc/prepare_announce_objectives(title = TRUE)
	if(!current)
		return
	var/list/text = list()
	if(title)
		text.Add("<span class='notice'>Your current objectives:</span>")
	text.Add(gen_objective_text())
	return text


/datum/mind/proc/find_syndicate_uplink()
	var/datum/antagonist/traitor/traitor_datum = has_antag_datum(/datum/antagonist/traitor)
	if(traitor_datum)
		return traitor_datum.hidden_uplink

	// We will return first found uplink in mob contents if its not a traitor
	var/list/uplinks = current?.collect_all_atoms_of_type(/obj/item/uplink/hidden)
	return length(uplinks) ? uplinks[1] : null


/datum/mind/proc/take_uplink()
	var/obj/item/uplink/hidden/uplink = find_syndicate_uplink()
	if(!uplink)
		return

	var/obj/item/uplink_holder = uplink.loc
	uplink_holder.hidden_uplink = null

	var/datum/antagonist/traitor/traitor_datum = has_antag_datum(/datum/antagonist/traitor)
	if(traitor_datum?.hidden_uplink == uplink)
		traitor_datum.hidden_uplink = null

	qdel(uplink)


/datum/mind/proc/make_Traitor()
	if(!has_antag_datum(/datum/antagonist/traitor))
		add_antag_datum(/datum/antagonist/traitor)


/datum/mind/proc/make_goon_vampire()
	if(!isvampire(src))
		add_antag_datum(/datum/antagonist/vampire/goon_vampire)


/datum/mind/proc/make_vampire()
	if(!isvampire(src))
		add_antag_datum(/datum/antagonist/vampire/new_vampire)


/datum/mind/proc/make_Nuke()
	if(!(src in SSticker.mode.syndicates))
		SSticker.mode.syndicates += src
		SSticker.mode.update_synd_icons_added(src)
		if(SSticker.mode.syndicates.len==1)
			SSticker.mode.prepare_syndicate_leader(src)
		else
			current.real_name = "[syndicate_name()] Operative #[SSticker.mode.syndicates.len-1]"
		special_role = SPECIAL_ROLE_NUKEOPS
		assigned_role = SPECIAL_ROLE_NUKEOPS
		to_chat(current, "<span class='notice'>You are a [syndicate_name()] agent!</span>")
		SSticker.mode.forge_syndicate_objectives(src)
		SSticker.mode.greet_syndicate(src)

		current.forceMove(get_turf(locate("landmark*Syndicate-Spawn")))

		var/mob/living/carbon/human/H = current
		qdel(H.belt)
		qdel(H.back)
		qdel(H.l_ear)
		qdel(H.r_ear)
		qdel(H.gloves)
		qdel(H.head)
		qdel(H.shoes)
		qdel(H.wear_id)
		qdel(H.wear_pda)
		qdel(H.wear_suit)
		qdel(H.w_uniform)

		SSticker.mode.equip_syndicate(current)


/datum/mind/proc/make_Wizard()
	if(!(src in SSticker.mode.wizards))
		SSticker.mode.wizards += src
		special_role = SPECIAL_ROLE_WIZARD
		assigned_role = SPECIAL_ROLE_WIZARD
		//ticker.mode.learn_basic_spells(current)
		if(!GLOB.wizardstart.len)
			current.forceMove(pick(GLOB.latejoin))
			to_chat(current, "HOT INSERTION, GO GO GO")
		else
			current.forceMove(pick(GLOB.wizardstart))

		SSticker.mode.equip_wizard(current)
		for(var/obj/item/spellbook/S in current.contents)
			S.op = 0
		INVOKE_ASYNC(SSticker.mode, TYPE_PROC_REF(/datum/game_mode/wizard, name_wizard), current)
		SSticker.mode.forge_wizard_objectives(src)
		SSticker.mode.greet_wizard(src)
		SSticker.mode.update_wiz_icons_added(src)


/datum/mind/proc/make_Space_Ninja(datum/objective/custom_objective)
	if(isninja(src))
		return

	var/datum/antagonist/ninja/ninja_datum = new
	ninja_datum.give_objectives = FALSE
	ninja_datum.generate_antags = FALSE
	ninja_datum.change_species(current)
	add_antag_datum(ninja_datum)

	if(!length(GLOB.ninjastart))
		current.forceMove(pick(GLOB.latejoin))
		to_chat(current, "HOT INSERTION, GO GO GO")
	else
		current.forceMove(pick(GLOB.ninjastart))

	//"generic" only, we don't want to spawn other antag's
	ninja_datum.make_objectives_generate_antags(NINJA_TYPE_GENERIC, custom_objective)


/datum/mind/proc/make_Rev()
	SSticker.mode.head_revolutionaries += src
	SSticker.mode.forge_revolutionary_objectives(src)
	SSticker.mode.equip_revolutionary(current)
	SSticker.mode.greet_revolutionary(src,0)


/datum/mind/proc/make_Thief()
	if(!has_antag_datum(/datum/antagonist/thief))
		add_antag_datum(/datum/antagonist/thief)

/datum/mind/proc/make_Abductor()
	var/role = tgui_alert(usr, "Abductor Role?", "Role", list("Agent", "Scientist"))
	var/team = tgui_input_list(usr, "Abductor Team?", "Team?", list(1,2,3,4))
	var/teleport = tgui_alert(usr, "Teleport to ship?", "Teleport", list("Yes", "No"))

	if(!role || !team || !teleport)
		return

	if(!ishuman(current))
		return

	SSticker.mode.abductors |= src

	var/datum/objective/stay_hidden/hidden_obj = new
	hidden_obj.owner = src
	objectives += hidden_obj

	var/datum/objective/experiment/O = new
	O.owner = src
	objectives += O

	var/mob/living/carbon/human/H = current

	H.set_species(/datum/species/abductor)
	var/datum/species/abductor/S = H.dna.species

	if(role == "Scientist")
		S.scientist = TRUE

	S.team = team

	var/list/obj/effect/landmark/abductor/agent_landmarks = new
	var/list/obj/effect/landmark/abductor/scientist_landmarks = new
	agent_landmarks.len = 4
	scientist_landmarks.len = 4
	for(var/obj/effect/landmark/abductor/A in GLOB.landmarks_list)
		if(istype(A, /obj/effect/landmark/abductor/agent))
			agent_landmarks[text2num(A.team)] = A
		else if(istype(A, /obj/effect/landmark/abductor/scientist))
			scientist_landmarks[text2num(A.team)] = A

	var/obj/effect/landmark/L
	if(teleport == "Yes")
		switch(role)
			if("Agent")
				L = agent_landmarks[team]
			if("Scientist")
				L = agent_landmarks[team]
		H.forceMove(L.loc)

/datum/mind/proc/get_blob_infected_type()
	if(!current)
		stack_trace("The mind is not attached to the mob.")
	if(isanimal(current))
		return /datum/antagonist/blob_infected/simple_animal
	if(ishuman(current))
		return /datum/antagonist/blob_infected/human


/datum/mind/proc/AddSpell(obj/effect/proc_holder/spell/spell)
	if(!istype(spell))
		return
	LAZYADD(spell_list, spell)
	spell.action.Grant(current)
	spell.on_spell_gain(current)

/datum/mind/proc/RemoveSpell(obj/effect/proc_holder/spell/instance_or_path) //To remove a specific spell from a mind
	if(!ispath(instance_or_path))
		instance_or_path = instance_or_path.type
	for(var/obj/effect/proc_holder/spell/spell as anything in spell_list)
		if(spell.type == instance_or_path)
			LAZYREMOVE(spell_list, spell)
			qdel(spell)

/datum/mind/proc/deactivate_spell(obj/effect/proc_holder/spell/instance_or_path)
	if(!ispath(instance_or_path))
		instance_or_path = instance_or_path.type

	var/obj/effect/proc_holder/spell/spell = LAZYIN(spell_list, locate(instance_or_path))

	if(!spell)
		return FALSE
	
	LAZYREMOVE(spell_list, spell)

	spell.action.Remove(current)

	return TRUE


/datum/mind/proc/transfer_actions(mob/living/new_character, mob/living/old_current)
	if(old_current && old_current.actions)
		for(var/datum/action/A in old_current.actions)
			if(A.check_flags & AB_TRANSFER_MIND)
				A.Grant(new_character)
	transfer_mindbound_actions(new_character)


/datum/mind/proc/transfer_mindbound_actions(mob/living/new_character)
	for(var/obj/effect/proc_holder/spell/spell as anything in spell_list)
		spell.action.Grant(new_character)


/datum/mind/proc/disrupt_spells(delay, list/exceptions)
	for(var/obj/effect/proc_holder/spell/spell as anything in spell_list)
		var/exception = FALSE
		for(var/typepath in exceptions)
			if(istype(spell, typepath))
				exception = TRUE
				break
		if(exception)
			continue
		if(spell.cooldown_handler)
			spell.cooldown_handler.recharge_duration = delay
			INVOKE_ASYNC(spell.cooldown_handler, TYPE_PROC_REF(/datum/spell_cooldown, start_recharge))
		spell.updateButtonIcon()

/datum/mind/proc/get_ghost(even_if_they_cant_reenter)
	for(var/mob/dead/observer/G in GLOB.dead_mob_list)
		if(G.mind == src)
			if(G.can_reenter_corpse || even_if_they_cant_reenter)
				return G
			break

/datum/mind/proc/grab_ghost(force)
	var/mob/dead/observer/G = get_ghost(even_if_they_cant_reenter = force)
	. = G
	if(G)
		G.reenter_corpse()


/datum/mind/proc/make_zealot(mob/living/carbon/human/missionary, convert_duration = 10 MINUTES, team_color = "red")

	zealot_master = missionary

	// Give the new zealot their mindslave datum with a custom greeting.
	var/greeting = "You're now a loyal zealot of [missionary.name]!</b> You now must lay down your life to protect [missionary.p_them()] and assist in [missionary.p_their()] goals at any cost."
	add_antag_datum(new /datum/antagonist/mindslave(missionary.mind, greeting))

	var/obj/item/clothing/under/jumpsuit = null
	if(ishuman(current))		//only bother with the jumpsuit stuff if we are a human type, since we won't have the slot otherwise
		var/mob/living/carbon/human/H = current
		if(H.w_uniform)
			jumpsuit = H.w_uniform
			jumpsuit.color = team_color
			H.update_inv_w_uniform()

	add_attack_logs(missionary, current, "Converted to a zealot for [convert_duration/600] minutes")
	add_conversion_logs(current, "became a mindslave for [convert_duration/600] minutes. Master: [key_name_log(missionary)]")
	addtimer(CALLBACK(src, PROC_REF(remove_zealot), jumpsuit), convert_duration) //deconverts after the timer expires


/datum/mind/proc/remove_zealot(obj/item/clothing/under/jumpsuit = null)
	if(!zealot_master)	//if they aren't a zealot, we can't remove their zealot status, obviously. don't bother with the rest so we don't confuse them with the messages
		return

	remove_antag_datum(/datum/antagonist/mindslave)
	add_attack_logs(zealot_master, current, "Lost control of zealot")
	add_conversion_logs(current, "Time's up and stopped being mindslave for [key_name_log(zealot_master)]")
	zealot_master = null

	if(jumpsuit)
		jumpsuit.color = initial(jumpsuit.color)		//reset the jumpsuit no matter where our mind is
		if(ishuman(current))							//but only try updating us if we are still a human type since it is a human proc
			var/mob/living/carbon/human/H = current
			H.update_inv_w_uniform()

	to_chat(current, span_warning("<b>You seem to have forgotten the events of the past 10 minutes or so, and your head aches a bit as if someone beat it savagely with a stick.</b>"))
	to_chat(current, span_warning("<b>This means you don't remember who you were working for or what you were doing.</b>"))


/datum/mind/proc/is_revivable() //Note, this ONLY checks the mind.
	if(damnation_type)
		return FALSE
	return TRUE

// returns a mob to message to produce something visible for the target mind
/datum/mind/proc/messageable_mob()
	if(!QDELETED(current) && current.client)
		return current
	else
		return get_ghost(even_if_they_cant_reenter = TRUE)

//Initialisation procs
/mob/proc/mind_initialize()
	if(mind)
		mind.key = key
	else
		mind = new /datum/mind(key)
		if(SSticker)
			SSticker.minds += mind
		else
			error("mind_initialize(): No ticker ready yet! Please inform Carn")
	if(!mind.name)
		mind.name = real_name
	mind.current = src
	SEND_SIGNAL(src, COMSIG_MOB_MIND_INITIALIZED, mind)

//HUMAN
/mob/living/carbon/human/mind_initialize()
	..()
	if(!mind.assigned_role)
		mind.assigned_role = JOB_TITLE_CIVILIAN	//defualt

/mob/proc/sync_mind()
	mind_initialize()  //updates the mind (or creates and initializes one if one doesn't exist)
	mind.active = TRUE    //indicates that the mind is currently synced with a client

//slime
/mob/living/simple_animal/slime/mind_initialize()
	..()
	mind.assigned_role = "slime"

//XENO
/mob/living/carbon/alien/mind_initialize()
	..()
	mind.assigned_role = "Alien"
	//XENO HUMANOID
/mob/living/carbon/alien/humanoid/queen/mind_initialize()
	..()
	mind.special_role = SPECIAL_ROLE_XENOMORPH_QUEEN

/mob/living/carbon/alien/humanoid/hunter/mind_initialize()
	..()
	mind.special_role = SPECIAL_ROLE_XENOMORPH_HUNTER

/mob/living/carbon/alien/humanoid/drone/mind_initialize()
	..()
	mind.special_role = SPECIAL_ROLE_XENOMORPH_DRONE

/mob/living/carbon/alien/humanoid/sentinel/mind_initialize()
	..()
	mind.special_role = SPECIAL_ROLE_XENOMORPH_SENTINEL
	//XENO LARVA
/mob/living/carbon/alien/larva/mind_initialize()
	..()
	mind.special_role = SPECIAL_ROLE_XENOMORPH_LARVA

//AI
/mob/living/silicon/ai/mind_initialize()
	..()
	mind.assigned_role = JOB_TITLE_AI

//BORG
/mob/living/silicon/robot/mind_initialize()
	..()
	mind.assigned_role = JOB_TITLE_CYBORG
	if(is_taipan(z))
		give_taipan_hud()
		GLOB.taipan_players_active += mind

//PAI
/mob/living/silicon/pai/mind_initialize()
	..()
	mind.assigned_role = "pAI"
	mind.special_role = null

//BLOB
/mob/camera/overmind/mind_initialize()
	..()
	mind.special_role = SPECIAL_ROLE_BLOB

//Animals
/mob/living/simple_animal/mind_initialize()
	..()
	mind.assigned_role = "Animal"

/mob/living/simple_animal/pet/dog/corgi/mind_initialize()
	..()
	mind.assigned_role = "Corgi"

/mob/living/simple_animal/shade/mind_initialize()
	..()
	mind.assigned_role = "Shade"

/mob/living/simple_animal/construct/builder/mind_initialize()
	..()
	mind.assigned_role = "Artificer"
	mind.special_role = SPECIAL_ROLE_CULTIST

/mob/living/simple_animal/construct/wraith/mind_initialize()
	..()
	mind.assigned_role = "Wraith"
	mind.special_role = SPECIAL_ROLE_CULTIST

/mob/living/simple_animal/construct/armoured/mind_initialize()
	..()
	mind.assigned_role = "Juggernaut"
	mind.special_role = SPECIAL_ROLE_CULTIST
