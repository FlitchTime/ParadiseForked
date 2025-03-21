/obj/item/folder
	name = "folder"
	desc = "A folder."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "folder"
	w_class = WEIGHT_CLASS_SMALL
	pressure_resistance = 2
	resistance_flags = FLAMMABLE

	lefthand_file = 'icons/mob/inhands/folder_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/folder_righthand.dmi'

/obj/item/folder/emp_act(severity)
	..()
	for(var/i in contents)
		var/atom/A = i
		A.emp_act(severity)

/obj/item/folder/blue
	desc = "A blue folder."
	icon_state = "folder_blue"

/obj/item/folder/red
	desc = "A red folder."
	icon_state = "folder_red"

/obj/item/folder/yellow
	desc = "A yellow folder."
	icon_state = "folder_yellow"

/obj/item/folder/white
	desc = "A white folder."
	icon_state = "folder_white"


/obj/item/folder/update_overlays()
	. = ..()
	if(contents.len)
		. += "folder_paper"


/obj/item/folder/attackby(obj/item/I, mob/user, params)
	if(is_pen(I))
		rename_interactive(user, I)
		return ATTACK_CHAIN_BLOCKED

	var/static/list/allowed_to_store = typecacheof(list(
		/obj/item/paper,
		/obj/item/photo,
		/obj/item/paper_bundle,
		/obj/item/documents,
	))
	if(is_type_in_typecache(I, allowed_to_store))
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		add_fingerprint(user)
		to_chat(user, span_notice("You put [I] into [src]."))
		update_icon(UPDATE_OVERLAYS)
		updateUsrDialog()
		return ATTACK_CHAIN_BLOCKED_ALL

	if(user.a_intent != INTENT_HARM)
		to_chat(user, span_warning("You cannot put [I] into [src]!"))
		return ATTACK_CHAIN_PROCEED

	return ..()


/obj/item/folder/attack_self(mob/user as mob)
	var/dat = ""

	for(var/obj/item/paper/P in src)
		dat += "<a href='byond://?src=[UID()];remove=\ref[P]'>Remove</a> - <a href='byond://?src=[UID()];read=\ref[P]'>[P.name]</a><br>"
	for(var/obj/item/photo/Ph in src)
		dat += "<a href='byond://?src=[UID()];remove=\ref[Ph]'>Remove</a> - <a href='byond://?src=[UID()];look=\ref[Ph]'>[Ph.name]</a><br>"
	for(var/obj/item/paper_bundle/Pa in src)
		dat += "<a href='byond://?src=[UID()];remove=\ref[Pa]'>Remove</a> - <a href='byond://?src=[UID()];look=\ref[Pa]'>[Pa.name]</a><br>"
	for(var/obj/item/documents/doc in src)
		dat += "<a href='byond://?src=[UID()];remove=\ref[doc]'>Remove</a> - <a href='byond://?src=[UID()];look=\ref[doc]'>[doc.name]</a><br>"
	var/datum/browser/popup = new(user, "folder", name)
	popup.set_content(dat)
	popup.open(TRUE)
	onclose(user, "folder")
	add_fingerprint(user)
	return

/obj/item/folder/Topic(href, href_list)
	..()
	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return

	if(src.loc == usr)

		if(href_list["remove"])
			var/obj/item/P = locate(href_list["remove"])
			if(P && (P.loc == src) && istype(P))
				P.forceMove_turf()
				usr.put_in_hands(P, ignore_anim = FALSE)

		else if(href_list["read"])
			var/obj/item/paper/P = locate(href_list["read"])
			if(P && (P.loc == src) && istype(P))
				P.show_content(usr)
		else if(href_list["look"])
			var/obj/item/photo/P = locate(href_list["look"])
			if(P && (P.loc == src) && istype(P))
				P.show(usr)
		else if(href_list["browse"])
			var/obj/item/paper_bundle/P = locate(href_list["browse"])
			if(P && (P.loc == src) && istype(P))
				P.attack_self(usr)
				onclose(usr, "[P.name]")

		//Update everything
		attack_self(usr)
		update_icon(UPDATE_OVERLAYS)


/obj/item/folder/documents
	name = "folder- 'TOP SECRET'"
	desc = "A folder stamped \"Top Secret - Property of Nanotrasen Corporation. Unauthorized distribution is punishable by death.\""

/obj/item/folder/documents/New()
	..()
	new /obj/item/documents/nanotrasen(src)
	update_icon(UPDATE_OVERLAYS)

/obj/item/folder/syndicate
	name = "folder- 'TOP SECRET'"
	desc = "A folder stamped \"Top Secret - Property of The Syndicate.\""

/obj/item/folder/syndicate/red
	icon_state = "folder_sred"

/obj/item/folder/syndicate/red/New()
	..()
	new /obj/item/documents/syndicate/red(src)
	update_icon(UPDATE_OVERLAYS)

/obj/item/folder/syndicate/blue
	icon_state = "folder_sblue"

/obj/item/folder/syndicate/blue/New()
	..()
	new /obj/item/documents/syndicate/blue(src)
	update_icon(UPDATE_OVERLAYS)

/obj/item/folder/syndicate/yellow
	icon_state = "folder_syellow"

/obj/item/folder/syndicate/yellow/full/New()
	..()
	new /obj/item/documents/syndicate/yellow(src)
	update_icon(UPDATE_OVERLAYS)

/obj/item/folder/syndicate/mining/New()
	. = ..()
	new /obj/item/documents/syndicate/mining(src)
	update_icon(UPDATE_OVERLAYS)

/obj/item/folder/ussp
	name = "folder"
	desc = "A folder with a hammer and sickle seal."
	icon_state = "folder_ussp"
