/obj/item/teleportation_scroll
	name = "scroll of teleportation"
	desc = "A scroll for moving around."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll"
	var/uses = 4.0
	w_class = WEIGHT_CLASS_SMALL
	item_state = "paper"
	throw_speed = 4
	throw_range = 20
	origin_tech = "bluespace=6"
	resistance_flags = FLAMMABLE

/obj/item/teleportation_scroll/apprentice
	name = "lesser scroll of teleportation"
	uses = 1
	origin_tech = "bluespace=5"

/obj/item/teleportation_scroll/attack_self(mob/user as mob)
	user.set_machine(src)
	var/dat = {"<b>Teleportation Scroll:</b></br>"}
	dat += "Number of uses: [src.uses]</br>"
	dat += "<hr>"
	dat += "<b>Four uses use them wisely:</b></br>"
	dat += "<a href='byond://?src=[UID()];spell_teleport=1'>Teleport</A></br>"
	dat += "Kind regards,<br>Wizards Federation<br><br>P.S. Don't forget to bring your gear, you'll need it to cast most spells.<hr>"
	var/datum/browser/popup = new(user, "scroll", "Teleportation Scroll")
	popup.set_content(dat)
	popup.open(TRUE)
	onclose(user, "scroll")
	return

/obj/item/teleportation_scroll/Topic(href, href_list)
	..()
	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED) || src.loc != usr)
		return
	var/mob/living/carbon/human/H = usr
	if(!( ishuman(H)))
		return 1
	if((usr == src.loc || (in_range(src, usr) && istype(src.loc, /turf))))
		usr.set_machine(src)
		if(href_list["spell_teleport"])
			if(src.uses >= 1)
				teleportscroll(H)
	attack_self(H)
	return

/obj/item/teleportation_scroll/proc/teleportscroll(var/mob/user)

	var/A

	A = tgui_input_list(user, "Area to jump to", "BOOYEA", GLOB.teleportlocs)

	if(!A)
		return

	var/area/thearea = GLOB.teleportlocs[A]

	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	if(!((user == loc || (in_range(src, user) && istype(src.loc, /turf)))))
		return

	if(thearea.tele_proof && !istype(thearea, /area/wizard_station))
		to_chat(user, "<span class='warning'>A mysterious force disrupts your arcane spell matrix, and you remain where you are.</span>")
		return

	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(amount = 5, location = user.loc)
	smoke.attach(user)
	smoke.start()
	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		if(!T.density)
			var/clear = 1
			for(var/obj/O in T)
				if(O.density)
					clear = 0
					break
			if(clear)
				L+=T

	if(!L.len)
		to_chat(user, "<span class='warning'>The spell matrix was unable to locate a suitable teleport destination for an unknown reason. Sorry.</span>")
		return

	if(user && user.buckled)
		user.buckled.unbuckle_mob(user, force = TRUE)

	if(user && user.has_buckled_mobs())
		user.unbuckle_all_mobs(force = TRUE)

	var/list/tempL = L
	var/attempt = null
	var/success = FALSE
	while(tempL.len)
		attempt = pick(tempL)
		user.forceMove(attempt)
		if(get_turf(user) == attempt)
			success = TRUE
			break
		tempL.Remove(attempt)

	if(!success)
		user.forceMove(pick(L))

	smoke.start()
	src.uses -= 1
	user.update_action_buttons_icon()  //Update action buttons as some spells might now be castable
