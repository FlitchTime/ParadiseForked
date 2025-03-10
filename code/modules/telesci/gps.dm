GLOBAL_LIST_EMPTY(GPS_list)

#define EMP_DISABLE_TIME 30 SECONDS

/**
  * # GPS
  *
  * A small item that reports its current location. Has a tag to help distinguish between them.
  */
/obj/item/gps
	name = "default gps"
	desc = "Helping lost spacemen find their way through the planets since 2016."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "gps-c"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	origin_tech = "materials=2;magnets=1;bluespace=2"
	interaction_flags_click = NEED_HANDS | ALLOW_RESTING | NEED_DEXTERITY
	/// Whether the GPS is on.
	var/tracking = TRUE
	/// The tag that is visible to other GPSes.
	var/gpstag = "COM0"
	/// Whether to only list signals that are on the same Z-level.
	var/same_z = FALSE
	/// Whether the GPS should only show up to GPSes on the same Z-level.
	var/local = FALSE
	/// Whether the GPS is EMPed, disabling it temporarily.
	var/emped = FALSE
	/// Turf reference. If set, it will appear in the UI. Used by [/obj/machinery/computer/telescience].
	var/turf/locked_location
	var/upgraded = 0
	/// For GPS in pAI
	var/atom/movable/parent

/obj/item/gps/Initialize(mapload)
	. = ..()
	GLOB.GPS_list.Add(src)
	GLOB.poi_list.Add(src)
	if(name == initial(name))
		name = "global positioning system ([gpstag])"
	update_icon(UPDATE_OVERLAYS)

/obj/item/gps/Destroy()
	GLOB.GPS_list.Remove(src)
	GLOB.poi_list.Remove(src)
	return ..()

/obj/item/gps/update_overlays()
	. = ..()
	if(emped)
		. += "emp"
	else if(tracking)
		. += "working"

/obj/item/gps/emp_act(severity)
	emped = TRUE
	update_icon(UPDATE_OVERLAYS)
	addtimer(CALLBACK(src, PROC_REF(reboot)), EMP_DISABLE_TIME)

/obj/item/gps/click_alt(mob/living/user)
	toggle_gps(user)
	return CLICK_ACTION_SUCCESS

/obj/item/gps/proc/toggle_gps(mob/living/user)
	if(emped)
		to_chat(user, "<span class='warning'>It's busted!</span>")
		return

	tracking = !tracking
	update_icon(UPDATE_OVERLAYS)
	if(tracking)
		to_chat(user, "[src] is now tracking, and visible to other GPS devices.")
	else
		to_chat(user, "[src] is no longer tracking, or visible to other GPS devices.")
	SStgui.update_uis(src)

/obj/item/gps/ui_data(mob/user)
	var/list/data = list()
	if(emped)
		data["emped"] = TRUE
		return data

	// General
	data["active"] = tracking
	data["tag"] = gpstag
	data["same_z"] = same_z
	data["upgraded"] = upgraded
	if(!tracking)
		return data
	var/turf/T = get_turf(src)
	data["area"] = get_area_name(src, TRUE)
	data["position"] = ATOM_COORDS(T)

	// Saved location
	if(locked_location)
		data["saved"] = ATOM_COORDS(locked_location)
	else
		data["saved"] = null

	// GPS signals
	var/signals = list()
	for(var/g in GLOB.GPS_list)
		var/obj/item/gps/G = g
		var/turf/GT = get_turf(G)
		if(isnull(GT) || !G.tracking || G == src)
			continue
		if((G.local || same_z) && (GT.z != T.z))
			continue

		var/list/signal = list("tag" = G.gpstag, "area" = null, "position" = null)
		if(!G.emped)
			signal["area"] = (GT.z == T.z) ? get_area_name(G, TRUE) : "???"
			signal["position"] = ATOM_COORDS(GT)
		signals += list(signal)
	data["signals"] = signals

	return data

/obj/item/gps/attack_self(mob/user)
	ui_interact(user)


/obj/item/gps/MouseDrop(atom/over_object, src_location, over_location, src_control, over_control, params)
	. = ..()

	var/mob/user = usr
	if(!ishuman(user) || !Adjacent(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return FALSE

	attack_self(user)
	return TRUE

/obj/item/gps/ui_host()
	return parent ? parent : src

/obj/item/gps/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/gps/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GPS", "GPS")
		ui.open()

/obj/item/gps/ui_act(action, list/params)
	if(..())
		return

	. = TRUE
	switch(action)
		if("tag")
			var/newtag = params["newtag"] || ""
			newtag = uppertext(paranoid_sanitize(copytext(newtag, 1, 5)))
			if(!length(newtag) || gpstag == newtag)
				return
			gpstag = newtag
			name = "global positioning system ([gpstag])"
		if("toggle")
			toggle_gps(usr)
			return FALSE
		if("same_z")
			same_z = !same_z
		else
			return FALSE

/**
  * Turns off the GPS's EMPed state. Called automatically after an EMP.
  */
/obj/item/gps/proc/reboot()
	emped = FALSE
	update_icon(UPDATE_OVERLAYS)

/obj/item/gps/science
	icon_state = "gps-s"
	gpstag = "SCI0"

/obj/item/gps/engineering
	icon_state = "gps-e"
	gpstag = "ENG0"

/obj/item/gps/mining
	icon_state = "gps-m"
	gpstag = "MINE0"
	desc = "A positioning system helpful for rescuing trapped or injured miners, keeping one on you at all times while mining might just save your life."
	tracking = FALSE

/obj/item/gps/security
	icon_state = "gps-r"
	gpstag = "SEC0"
	desc = "A positioning system helpful for monitoring prisoners that are implanted with a tracking implant."
	local = TRUE

/obj/item/gps/cyborg
	icon_state = "gps-b"
	gpstag = "BORG0"
	desc = "A mining cyborg internal positioning system. Used as a recovery beacon for damaged cyborg assets, or a collaboration tool for mining teams."


/obj/item/gps/cyborg/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CYBORG_ITEM_TRAIT)

/obj/item/gps/cyborg/New(gpstag = "gps-b", upgraded = FALSE, tracking = TRUE)
	. = ..()
	src.gpstag = gpstag
	src.upgraded = upgraded
	src.tracking = tracking


/obj/item/gps/cyborg/upgraded
	upgraded = 1

/obj/item/gps/syndiecyborg
	icon_state = "gps-b"
	local = TRUE
	gpstag = "SBORG0"
	desc = "A syndicate version of cyborg GPS that only shows it's location on current Z-level"


/obj/item/gps/syndiecyborg/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CYBORG_ITEM_TRAIT)


/obj/item/gps/internal
	icon_state = null
	item_flags = ABSTRACT
	local = TRUE
	gpstag = "Eerie Signal"
	desc = "Report to a coder immediately."
	invisibility = INVISIBILITY_ABSTRACT

/obj/item/gps/internal/mining
	icon_state = "gps-m"
	gpstag = "MINER"
	desc = "A positioning system helpful for rescuing trapped or injured miners, keeping one on you at all times while mining might just save your life."

/obj/item/gps/internal/base
	gpstag = "NT_AUX"
	desc = "A homing signal from Nanotrasen's mining base."

/obj/item/gps/visible_debug
	name = "visible GPS"
	gpstag = "ADMIN"
	desc = "This admin-spawn GPS unit leaves the coordinates visible \
		on any turf that it passes over, for debugging. Especially useful \
		for marking the area around the transition edges."
	var/list/turf/tagged

/obj/item/gps/visible_debug/Initialize(mapload)
	. = ..()
	tagged = list()
	START_PROCESSING(SSfastprocess, src)

/obj/item/gps/visible_debug/process()
	var/turf/T = get_turf(src)
	if(T)
		// I assume it's faster to color,tag and OR the turf in, rather
		// then checking if its there
		T.color = RANDOM_COLOUR
		T.maptext = "[T.x],[T.y],[T.z]"
		tagged |= T

/obj/item/gps/visible_debug/proc/clear()
	while(tagged.len)
		var/turf/T = pop(tagged)
		T.color = initial(T.color)
		T.maptext = initial(T.maptext)

/obj/item/gps/visible_debug/Destroy()
	if(tagged)
		clear()
	tagged = null
	STOP_PROCESSING(SSfastprocess, src)
	. = ..()

/obj/item/gpsupgrade
	name = "GPS upgrade"
	desc = "A data cartridge for portable microcomputers."
	icon = 'icons/obj/pda.dmi'
	icon_state = "cart-mine"
	w_class = WEIGHT_CLASS_TINY


/obj/item/gps/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/gpsupgrade))
		add_fingerprint(user)
		if(upgraded)
			to_chat(user, span_warning("The [name] is already upgraded."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		to_chat(user, span_notice("You have upgraded [src]."))
		upgraded = TRUE
		SStgui.update_uis(src)
		qdel(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


#undef EMP_DISABLE_TIME
