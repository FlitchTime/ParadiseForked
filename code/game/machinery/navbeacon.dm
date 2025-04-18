// Navigation beacon for AI robots
// No longer exists on the radio controller, it is managed by a global list.

/obj/machinery/navbeacon

	icon = 'icons/obj/objects.dmi'
	icon_state = "navbeacon0-f"
	name = "navigation beacon"
	desc = "A radio beacon used for bot navigation."
	level = 1		// underfloor
	layer = WIRE_LAYER
	plane = FLOOR_PLANE
	anchored = TRUE
	max_integrity = 500
	armor = list(melee = 70, bullet = 70, laser = 70, energy = 70, bomb = 0, bio = 0, rad = 0, fire = 80, acid = 80)
	var/open = 0		// true if cover is open
	var/locked = 1		// true if controls are locked
	var/location = ""	// location response text
	var/list/codes		// assoc. list of transponder codes
	var/codes_txt = ""	// codes as set on map: "tag1;tag2" or "tag1=value;tag2=value"

	req_access = list(ACCESS_ENGINE, ACCESS_ROBOTICS)

/obj/machinery/navbeacon/New()
	..()

	set_codes()

	var/turf/T = loc
	if(!T.transparent_floor)
		hide(T.intact)
	if(!codes || !codes.len)
		log_runtime(EXCEPTION("Empty codes datum at ([x],[y],[z])"), src, list("codes_txt: '[codes_txt]'"))
	if("patrol" in codes)
		if(!GLOB.navbeacons["[z]"])
			GLOB.navbeacons["[z]"] = list()
		GLOB.navbeacons["[z]"] += src //Register with the patrol list!
	if("delivery" in codes)
		GLOB.deliverybeacons += src
		GLOB.deliverybeacontags += location

/obj/machinery/navbeacon/Destroy()
	GLOB.navbeacons["[z]"] -= src //Remove from beacon list, if in one.
	GLOB.deliverybeacons -= src
	return ..()

/obj/machinery/navbeacon/serialize()
	var/list/data = ..()
	data["codes"] = codes
	return data

/obj/machinery/navbeacon/deserialize(list/data)
	codes = data["codes"]
	..()

// set the transponder codes assoc list from codes_txt
/obj/machinery/navbeacon/proc/set_codes()
	if(!codes_txt)
		return

	codes = new()

	var/list/entries = splittext(codes_txt, ";")	// entries are separated by semicolons

	for(var/e in entries)
		var/index = findtext(e, "=")		// format is "key=value"
		if(index)
			var/key = copytext(e, 1, index)
			var/val = copytext(e, index+1)
			codes[key] = val
		else
			codes[e] = "1"


// called when turf state changes
// hide the object if turf is intact
/obj/machinery/navbeacon/hide(intact)
	invisibility = intact ? INVISIBILITY_MAXIMUM : 0
	update_icon(UPDATE_ICON_STATE)


// update the icon_state
/obj/machinery/navbeacon/update_icon_state()
	// if invisible, set icon to faded version
	// in case revealed by T-scanner
	icon_state = "navbeacon[open][invisibility ? "-f" : ""]"


/obj/machinery/navbeacon/attackby(obj/item/I, mob/user, params)
	var/turf/our_turf = loc
	if(!isturf(our_turf) || our_turf.intact || our_turf.transparent_floor == TURF_TRANSPARENT)	// prevent intraction when T-scanner revealed
		return ATTACK_CHAIN_BLOCKED_ALL

	if(user.a_intent == INTENT_HARM)
		return ..()

	if(I.GetID() || is_pda(I))
		add_fingerprint(user)
		if(!open)
			to_chat(user, span_warning("You must open the cover first!"))
			return ATTACK_CHAIN_PROCEED
		if(!allowed(user))
			to_chat(user, span_danger("Access denied."))
			return ATTACK_CHAIN_PROCEED
		locked = !locked
		to_chat(user, span_notice("Controls are now [locked ? "locked" : "unlocked"]."))
		updateDialog()
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/machinery/navbeacon/screwdriver_act(mob/living/user, obj/item/I)
	var/turf/T = get_turf(src)
	if(T.intact)
		return FALSE
	open = !open
	user.visible_message(
		"[user] [open ? "opens" : "closes"] the beacon's cover.",
		span_notice("You [open ? "open" : "close"] the beacon's cover."),
	)
	update_icon(UPDATE_ICON_STATE)
	return TRUE


/obj/machinery/navbeacon/attack_ai(mob/user)
	interact(user, 1)

/obj/machinery/navbeacon/attack_hand(mob/user)
	add_fingerprint(user)
	interact(user, 0)

/obj/machinery/navbeacon/interact(mob/user, ai = 0)
	var/turf/T = get_turf(src)
	if(T.intact)
		return		// prevent intraction when T-scanner revealed

	if(!open && !ai)	// can't alter controls if not open, unless you're an AI
		to_chat(user, span_warning("The beacon's control cover is closed!"))
		return


	var/t

	if(locked && !ai)
		t = {"<tt><b>Navigation Beacon</b><hr><br>
<i>(swipe card to unlock controls)</i><br>
Location: [location ? location : "(none)"]</a><br>
Transponder Codes:<ul>"}

		for(var/key in codes)
			t += "<li>[key] ... [codes[key]]"
		t+= "<ul></tt>"

	else

		t = {"<tt><b>Navigation Beacon</b><hr><br>
<i>(swipe card to lock controls)</i><br>

<hr>
Location: <a href='byond://?src=[UID()];locedit=1'>[location ? location : "None"]</a><br>
Transponder Codes:<ul>"}

		for(var/key in codes)
			t += "<li>[key] ... [codes[key]]"
			t += "	<a href='byond://?src=[UID()];edit=1;code=[key]'>Edit</a>"
			t += "	<a href='byond://?src=[UID()];delete=1;code=[key]'>Delete</a><br>"
		t += "	<a href='byond://?src=[UID()];add=1;'>Add New</a><br>"
		t+= "<ul></tt>"

	var/datum/browser/popup = new(user, "navbeacon", "Navigation Beacon", 300, 400)
	popup.set_content(t)
	popup.open()
	return

/obj/machinery/navbeacon/Topic(href, href_list)
	if(..())
		return
	if(open && !locked)
		usr.set_machine(src)

		if(href_list["locedit"])
			var/newloc = tgui_input_text(usr, "Enter New Location", "Navigation Beacon", location)
			if(!newloc)
				return
			location = newloc
			updateDialog()

		else if(href_list["edit"])
			var/codekey = href_list["code"]

			var/newkey = tgui_input_text(usr, "Enter Transponder Code Key", "Navigation Beacon", codekey)
			if(!newkey)
				return

			var/codeval = codes[codekey]
			var/newval = tgui_input_text(usr, "Enter Transponder Code Value", "Navigation Beacon", codeval)
			if(!newval)
				newval = codekey
				return

			codes.Remove(codekey)
			codes[newkey] = newval

			updateDialog()

		else if(href_list["delete"])
			var/codekey = href_list["code"]
			codes.Remove(codekey)
			updateDialog()

		else if(href_list["add"])

			var/newkey = tgui_input_text(usr, "Enter New Transponder Code Key", "Navigation Beacon")
			if(!newkey)
				return

			var/newval = tgui_input_text(usr, "Enter New Transponder Code Value", "Navigation Beacon")
			if(!newval)
				newval = "1"
				return

			if(!codes)
				codes = new()

			codes[newkey] = newval

			updateDialog()


/obj/machinery/navbeacon/invisible
	invisibility = INVISIBILITY_ABSTRACT

/obj/machinery/navbeacon/invisible/hide(intact)
	invisibility = INVISIBILITY_ABSTRACT
	update_icon(UPDATE_ICON_STATE)
