GLOBAL_LIST_EMPTY(ai_list)
GLOBAL_LIST_INIT(ai_verbs_default, list(
	/mob/living/silicon/ai/proc/announcement,
	/mob/living/silicon/ai/proc/ai_announcement_text,
	/mob/living/silicon/ai/proc/ai_call_shuttle,
	/mob/living/silicon/ai/proc/ai_camera_track,
	/mob/living/silicon/ai/proc/ai_camera_list,
	/mob/living/silicon/ai/proc/ai_goto_location,
	/mob/living/silicon/ai/proc/ai_remove_location,
	/mob/living/silicon/ai/proc/ai_hologram_change,
	/mob/living/silicon/ai/proc/ai_network_change,
	/mob/living/silicon/ai/proc/ai_roster,
	/mob/living/silicon/ai/proc/ai_statuschange,
	/mob/living/silicon/ai/proc/ai_store_location,
	/mob/living/silicon/ai/proc/control_integrated_radio,
	/mob/living/silicon/ai/proc/core,
	/mob/living/silicon/ai/proc/pick_icon,
	/mob/living/silicon/ai/proc/sensor_mode,
	/mob/living/silicon/ai/proc/show_laws_verb,
	/mob/living/silicon/ai/proc/toggle_acceleration,
	/mob/living/silicon/ai/proc/toggle_camera_light,
	/mob/living/silicon/ai/proc/botcall,
	/mob/living/silicon/ai/proc/change_arrival_message,
	/mob/living/silicon/ai/proc/arrivals_announcement,
	/mob/living/silicon/ai/proc/ai_change_voice,
))

//Not sure why this is necessary...
/proc/AutoUpdateAI(obj/subject)
	var/is_in_use = 0
	if(subject!=null)
		for(var/A in GLOB.ai_list)
			var/mob/living/silicon/ai/M = A
			if((M.client && M.machine == subject))
				is_in_use = 1
				subject.attack_ai(M)
	return is_in_use

/mob/living/silicon/ai
	name = "AI"
	icon = 'icons/mob/ai.dmi'//
	icon_state = "ai"
	move_resist = MOVE_FORCE_NORMAL
	density = TRUE
	status_flags = CANSTUN|CANPARALYSE|CANPUSH
	mob_size = MOB_SIZE_LARGE
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS
	nightvision = 8
	can_buckle_to = FALSE
	hud_type = /datum/hud/ai
	var/list/network = list("SS13","Telecomms","Research Outpost","Mining Outpost")
	var/obj/machinery/camera/current = null
	var/list/connected_robots = list()
	var/aiRestorePowerRoutine = 0
	//var/list/laws = list()
	alarms_listend_for = list("Motion", "Fire", "Atmosphere", "Power", "Camera", "Burglar")
	var/viewalerts = 0
	var/icon/holo_icon//Default is assigned when AI is created.
	var/obj/mecha/controlled_mech //For controlled_mech a mech, to determine whether to relaymove or use the AI eye.
	var/obj/item/pda/silicon/ai/aiPDA = null
	var/obj/item/multitool/aiMulti = null
	var/custom_sprite = 0 //For our custom sprites
	var/custom_hologram = 0 //For our custom holograms
	var/on_the_card = FALSE //If our ai is on the Intelicard, or not

	var/obj/item/radio/headset/heads/ai_integrated/aiRadio = null

	//MALFUNCTION
	var/datum/module_picker/malf_picker
	var/datum/action/innate/ai/choose_modules/modules_action
	var/list/datum/AI_Module/current_modules = list()
	var/can_dominate_mechs = 0
	var/shunted = 0 //1 if the AI is currently shunted. Used to differentiate between shunted and ghosted/braindead

	var/control_disabled = FALSE // Set to TRUE to stop AI from interacting via Click() -- TLE
	var/malfhacking = 0 // More or less a copy of the above var, so that malf AIs can hack and still get new cyborgs -- NeoFite
	var/malf_cooldown = 0 //Cooldown var for malf modules, stores a worldtime + cooldown

	var/obj/machinery/power/apc/malfhack = null
	var/explosive = 0 //does the AI explode when it dies?

	var/mob/living/silicon/ai/parent = null
	var/camera_light_on = 0
	var/list/obj/machinery/camera/lit_cameras = list()

	var/datum/trackable/track = new()

	var/last_paper_seen = null
	var/last_paper_seen_title = null
	var/can_shunt = TRUE
	var/last_announcement = ""
	var/datum/announcement/priority/announcement
	var/mob/living/simple_animal/bot/Bot
	var/turf/waypoint //Holds the turf of the currently selected waypoint.
	var/waypoint_mode = 0 //Waypoint mode is for selecting a turf via clicking.
	var/apc_override = FALSE	//hack for letting the AI use its APC even when visionless
	var/nuking = 0
	var/obj/machinery/doomsday_device/doomsday_device

	var/obj/machinery/hologram/holopad/holo = null
	var/mob/camera/aiEye/eyeobj
	var/sprint = 10
	var/cooldown = 0
	var/acceleration = 1
	var/tracking = 0 //this is 1 if the AI is currently tracking somebody, but the track has not yet been completed.

	var/obj/machinery/camera/portable/builtInCamera

	var/obj/structure/AIcore/deactivated/linked_core //For exosuit control

	/// If our AI doesn't want to be the arrivals announcer, this gets set to FALSE.
	var/announce_arrivals = TRUE
	var/arrivalmsg = "$name, $rank, прибыл на станцию."

	var/list/all_eyes = list()

/mob/living/silicon/ai/proc/add_ai_verbs()
	add_verb(src, GLOB.ai_verbs_default)
	add_verb(src, silicon_subsystems)

/mob/living/silicon/ai/can_strip()
	return FALSE

/mob/living/silicon/ai/proc/remove_ai_verbs()
	remove_verb(src, GLOB.ai_verbs_default)
	remove_verb(src, silicon_subsystems)

/mob/living/silicon/ai/New(loc, var/datum/ai_laws/L, var/obj/item/mmi/B, var/safety = 0)
	announcement = new()
	announcement.title = "Оповещение ИИ"
	announcement.announcement_type = "Оповещение ИИ"
	announcement.announcer = name
	announcement.newscast = FALSE

	var/list/possibleNames = GLOB.ai_names

	var/pickedName = null
	while(!pickedName)
		pickedName = pick(GLOB.ai_names)
		for(var/mob/living/silicon/ai/A in GLOB.mob_list)
			if(A.real_name == pickedName && possibleNames.len > 1) //fixing the theoretically possible infinite loop
				possibleNames -= pickedName
				pickedName = null

	aiPDA = new/obj/item/pda/silicon/ai(src)
	rename_character(null, pickedName)
	set_anchored(TRUE)
	set_density(TRUE)
	loc = loc

	holo_icon = getHologramIcon(icon('icons/mob/ai.dmi',"holo1"))

	if(B?.clock)
		ratvar_act()
	else if(L)
		if(istype(L, /datum/ai_laws))
			laws = L
	else
		make_laws()

	add_verb(src, /mob/living/silicon/ai/proc/show_laws_verb)

	aiMulti = new(src)
	aiRadio = new(src)
	common_radio = aiRadio
	aiRadio.myAi = src
	additional_law_channels["Binary"] = get_language_prefix(LANGUAGE_BINARY)
	additional_law_channels["Holopad"] = ":h"

	aiCamera = new/obj/item/camera/siliconcam/ai_camera(src)

	if(isturf(loc))
		add_ai_verbs(src)

	//Languages
	add_language(LANGUAGE_BINARY, 1)
	add_language(LANGUAGE_GALACTIC_COMMON, 1)
	add_language(LANGUAGE_SOL_COMMON, 1)
	add_language(LANGUAGE_TRADER, 1)
	add_language(LANGUAGE_NEO_RUSSIAN, 1)
	add_language(LANGUAGE_GUTTER, 1)
	add_language(LANGUAGE_UNATHI, 1)
	add_language(LANGUAGE_TAJARAN, 1)
	add_language(LANGUAGE_VULPKANIN, 1)
	add_language(LANGUAGE_SKRELL, 1)
	add_language(LANGUAGE_VOX, 1)
	add_language(LANGUAGE_DRASK, 1)
	add_language(LANGUAGE_DIONA, 1)
	add_language(LANGUAGE_TRINARY, 1)
	add_language(LANGUAGE_KIDAN, 1)
	add_language(LANGUAGE_SLIME, 1)
	add_language(LANGUAGE_CLOWN, 1)
	add_language(LANGUAGE_MOTH, 1)

	if(!safety)//Only used by AIize() to successfully spawn an AI.
		if(!B)//If there is no player/brain inside.
			new/obj/structure/AIcore/deactivated(loc)//New empty terminal.
			qdel(src)//Delete AI.
			return
		else
			if(B.brainmob.mind)
				B.brainmob.mind.transfer_to(src)

			on_mob_init()

	spawn(5)
		new /obj/machinery/ai_powersupply(src)

	create_eye()

	builtInCamera = new(src, list("SS13"), name)

	GLOB.ai_list += src
	GLOB.shuttle_caller_list += src
	..()


/mob/living/silicon/ai/Initialize(mapload)
	. = ..()
	add_traits(list(TRAIT_PULL_BLOCKED, TRAIT_HANDS_BLOCKED), ROUNDSTART_TRAIT)
	AddElement(/datum/element/high_value_item)


/mob/living/silicon/ai/proc/on_mob_init()
	to_chat(src, "<b>You are playing the station's AI. The AI cannot move, but can interact with many objects while viewing them (through cameras).</b>")
	to_chat(src, "<b>To look at other parts of the station, click on yourself to get a camera menu.</b>")
	to_chat(src, "<b>While observing through a camera, you can use most (networked) devices which you can see, such as computers, APCs, intercoms, doors, etc.</b>")
	to_chat(src, "To use something, simply click on it.")
	to_chat(src, "Use say '[get_language_prefix(LANGUAGE_BINARY)]' to speak to your cyborgs through binary. Use say ':h ' to speak from an active holopad.")
	to_chat(src, "For department channels, use the following say commands:")

	var/radio_text = ""
	for(var/i = 1 to common_radio.channels.len)
		var/channel = common_radio.channels[i]
		var/key = get_radio_key_from_channel(channel)
		radio_text += "[key] - [channel]"
		if(i != common_radio.channels.len)
			radio_text += ", "

	to_chat(src, radio_text)

	show_laws()
	to_chat(src, "<b>These laws may be changed by other players, or by you being the traitor.</b>")

	job = JOB_TITLE_AI

/mob/living/silicon/ai/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	if(stat)
		status_tab_data[++status_tab_data.len] = list("System status:", "Nonfunctional")
		return
	status_tab_data = show_borg_info(status_tab_data)

/mob/living/silicon/ai/proc/ai_alerts()
	var/list/dat = list()
	dat += "<a href='byond://?src=[UID()];mach_close=aialerts'>Close</a><br><br>"
	var/list/list/temp_alarm_list = SSalarm.alarms.Copy()
	for(var/cat in temp_alarm_list)
		if(!(cat in alarms_listend_for))
			continue
		dat += "<b>[cat]</b><br>"
		var/list/list/L = temp_alarm_list[cat].Copy()
		for(var/alarm in L)
			var/list/list/alm = L[alarm].Copy()
			var/area_name = alm[1]
			var/C = alm[2]
			var/list/list/sources = alm[3].Copy()
			for(var/thing in sources)
				var/atom/A = locateUID(thing)
				if(A && A.z != z)
					L -= alarm
					continue
				dat += "<nobr>"
				if(C && islist(C))
					var/dat2 = ""
					for(var/cam in C)
						var/obj/machinery/camera/I = locateUID(cam)
						if(!QDELETED(I))
							dat2 += "[(dat2 == "") ? "" : " | "]<a href='byond://?src=[UID()];switchcamera=[cam]'>[I.c_tag]</a>"
					dat += "-- [area_name] ([(dat2 != "") ? dat2 : "No Camera"])"
				else
					dat += "-- [area_name] (No Camera)"
				if(sources.len > 1)
					dat += "- [sources.len] sources"
				dat += "</nobr><br>\n"
		if(!L.len)
			dat += "-- All Systems Nominal<br>\n"
		dat += "<br>\n"

	viewalerts = TRUE
	var/dat_text = dat.Join("")
	var/datum/browser/popup = new(src, "aialerts", "Current Station Alerts")
	popup.set_content(dat_text)
	popup.set_window_options("can_close=0;")
	popup.open(FALSE)

/mob/living/silicon/ai/proc/show_borg_info(list/status_tab_data)
	status_tab_data[++status_tab_data.len] = list("Connected cyborg count:", "[length(connected_robots)]")
	for(var/mob/living/silicon/robot/R in connected_robots)
		var/robot_status = "Nominal"
		if(R.stat || !R.client)
			robot_status = "OFFLINE"
		else if(!R.cell || R.cell.charge <= 0)
			robot_status = "DEPOWERED"
		// Name, Health, Battery, Module, Area, and Status! Everything an AI wants to know about its borgies!
		var/area/A = get_area(R)
		var/area_name = A ? sanitize(A.name) : "Unknown"
		status_tab_data[++status_tab_data.len] = list("[R.name]:", "S.Integrity: [R.health]% | Cell: [R.cell ? "[R.cell.charge] / [R.cell.maxcharge]" : "Empty"] | \
		Module: [R.designation] | Loc: [area_name] | Status: [robot_status]")
	return status_tab_data

/mob/living/silicon/ai/rename_character(oldname, newname)
	if(!..(oldname, newname))
		return FALSE

	if(oldname != real_name)
		announcement.announcer = name

		if(eyeobj)
			eyeobj.name = "[newname] (AI Eye)"

		// Set ai pda name
		if(aiPDA)
			aiPDA.set_name_and_job(newname, JOB_TITLE_AI)

	return TRUE

/mob/living/silicon/ai/Destroy()
	GLOB.ai_list -= src
	GLOB.shuttle_caller_list -= src
	SSshuttle.autoEvac()
	QDEL_NULL(eyeobj) // No AI, no Eye
	if(malfhacking)
		deltimer(malfhacking)
		malfhacking = null
	malfhack = null
	return ..()


/*
	The AI Power supply is a dummy object used for powering the AI since only machinery should be using power.
	The alternative was to rewrite a bunch of AI code instead here we are.
*/
/obj/machinery/ai_powersupply
	name="\improper AI power supply"
	active_power_usage=1000
	use_power = ACTIVE_POWER_USE
	power_channel = EQUIP
	var/mob/living/silicon/ai/powered_ai = null
	invisibility = INVISIBILITY_ABSTRACT

/obj/machinery/ai_powersupply/New(mob/living/silicon/ai/ai=null)
	powered_ai = ai
	if(isnull(powered_ai))
		qdel(src)
		return

	loc = powered_ai.loc
	use_power(1) // Just incase we need to wake up the power system.

	..()

/obj/machinery/ai_powersupply/process()
	if(!powered_ai || powered_ai.stat & DEAD)
		qdel(src)
		return
	if(!powered_ai.anchored)
		loc = powered_ai.loc
		use_power = NO_POWER_USE
	if(powered_ai.anchored)
		use_power = ACTIVE_POWER_USE

/mob/living/silicon/ai/proc/pick_icon()
	set category = "AI Commands"
	set name = "Set AI Core Display"
	if(stat || aiRestorePowerRoutine)
		return
	if(!custom_sprite) //Check to see if custom sprite time, checking the appopriate file to change a var
		var/file = file2text("config/custom_sprites.txt")
		var/lines = splittext(file, "\n")

		for(var/line in lines)
		// split & clean up
			var/list/Entry = splittext(line, ":")
			for(var/i = 1 to Entry.len)
				Entry[i] = trim(Entry[i])

			if(Entry.len < 2 || Entry[1] != "ai")			//ignore incorrectly formatted entries or entries that aren't marked for AI
				continue

			if(Entry[2] == ckey)	//They're in the list? Custom sprite time, var and icon change required
				custom_sprite = 1

	var/display_choices = list(
		"Monochrome",
		"Blue",
		"Clown",
		"Inverted",
		"Text",
		"Smiley",
		"Angry",
		"Dorf",
		"Matrix",
		"Bliss",
		"Firewall",
		"Green",
		"Red",
		"Static",
		"Triumvirate",
		"Triumvirate Static",
		"Red October",
		"Sparkles",
		"ANIMA",
		"President",
		"NT",
		"NT2",
		"Rainbow",
		"Angel",
		"Heartline",
		"Hades",
		"Helios",
		"Syndicat Meow",
		"Too Deep",
		"Goon",
		"Murica",
		"Fuzzy",
		"Glitchman",
		"House",
		"Database",
		"Alien",
		"Cheese",
		"Voiddonut",
		"Bee",
		"Fox",
		"Tiger",
		"Vox",
		"Liz",
		"Darkmatter",
		"Nadburn",
		"Rainbowslime",
		"Borb",
		"Catamari",
		"Anonymous",
		"Hippy",
		"AMAI",
		"HAL",
		)
	if(custom_sprite)
		display_choices += "Custom"

		//if(icon_state == initial(icon_state))
	var/icontype = ""
	icontype = input("Select an icon!", "AI", null, null) in display_choices
	icon = 'icons/mob/ai.dmi'	//reset this in case we were on a custom sprite and want to change to a standard one
	switch(icontype)
		if("Custom")
			icon = 'icons/mob/custom_synthetic/custom-synthetic.dmi'	//set this here so we can use the custom_sprite
			icon_state = "[ckey]-ai"
		if("Clown")
			icon_state = "ai-clown"
		if("Monochrome")
			icon_state = "ai-mono"
		if("Inverted")
			icon_state = "ai-u"
		if("Firewall")
			icon_state = "ai-magma"
		if("Green")
			icon_state = "ai-weird"
		if("Red")
			icon_state = "ai-red"
		if("Static")
			icon_state = "ai-static"
		if("Text")
			icon_state = "ai-text"
		if("Smiley")
			icon_state = "ai-smiley"
		if("Matrix")
			icon_state = "ai-matrix"
		if("Angry")
			icon_state = "ai-angryface"
		if("Dorf")
			icon_state = "ai-dorf"
		if("Bliss")
			icon_state = "ai-bliss"
		if("Triumvirate")
			icon_state = "ai-triumvirate"
		if("Triumvirate Static")
			icon_state = "ai-triumvirate-malf"
		if("Red October")
			icon_state = "ai-redoctober"
		if("Sparkles")
			icon_state = "ai-sparkles"
		if("ANIMA")
			icon_state = "ai-anima"
		if("President")
			icon_state = "ai-president"
		if("NT")
			icon_state = "ai-nt"
		if("NT2")
			icon_state = "ai-nanotrasen"
		if("Rainbow")
			icon_state = "ai-rainbow"
		if("Angel")
			icon_state = "ai-angel"
		if("Heartline")
			icon_state = "ai-heartline"
		if("Hades")
			icon_state = "ai-hades"
		if("Helios")
			icon_state = "ai-helios"
		if("Syndicat Meow")
			icon_state = "ai-syndicatmeow"
		if("Too Deep")
			icon_state = "ai-toodeep"
		if("Goon")
			icon_state = "ai-goon"
		if("Murica")
			icon_state = "ai-murica"
		if("Fuzzy")
			icon_state = "ai-fuzz"
		if("Glitchman")
			icon_state = "ai-glitchman"
		if("House")
			icon_state = "ai-house"
		if("Database")
			icon_state = "ai-database"
		if("Alien")
			icon_state = "ai-alien"
		if("Cheese")
			icon_state = "ai-cheese"
		if("Voiddonut")
			icon_state = "ai-voiddonut"
		if("Bee")
			icon_state = "ai-bee"
		if("Fox")
			icon_state = "ai-fox"
		if("Tiger")
			icon_state = "ai-tiger"
		if("Vox")
			icon_state = "ai-vox"
		if("Liz")
			icon_state = "ai-liz"
		if("Darkmatter")
			icon_state = "ai-darkmatter"
		if("Nadburn")
			icon_state = "ai-nadburn"
		if("Rainbowslime")
			icon_state = "ai-rainbowslime"
		if("Borb")
			icon_state = "ai-borb"
		if("Catamari")
			icon_state = "ai-catamari"
		if("Hippy")
			icon_state = "ai-hippy"
		if("Anonymous")
			icon_state = "ai-anon"
		if("AMAI")
			icon_state = "ai-am"
		if("HAL")
			icon_state = "ai-hal"
		else
			icon_state = "ai"
	//else
//			to_chat(usr, "You can only change your display once!")
			//return

// this verb lets the ai see the stations manifest
/mob/living/silicon/ai/proc/ai_roster()
	set name = "Show Crew Manifest"
	set category = "AI Commands"
	show_station_manifest()

/mob/living/silicon/ai/var/message_cooldown = 0
/mob/living/silicon/ai/proc/ai_announcement_text()
	set category = "AI Commands"
	set name = "Make Station Announcement"

	if(check_unable(AI_CHECK_WIRELESS | AI_CHECK_RADIO))
		return

	if(message_cooldown)
		to_chat(src, "<span class='warning'>Please allow one minute to pass between announcements.</span>")
		return

	var/input = tgui_input_text(usr, "Please write a message to announce to the station crew.", "A.I. Announcement", multiline = TRUE, encode = FALSE)
	if(!input)
		return

	if(check_unable(AI_CHECK_WIRELESS | AI_CHECK_RADIO))
		return

	announcement.Announce(input)
	message_cooldown = 1
	spawn(600)//One minute cooldown
		message_cooldown = 0

/mob/living/silicon/ai/proc/ai_call_shuttle()
	set name = "Call Emergency Shuttle"
	set category = "AI Commands"

	if(check_unable(AI_CHECK_WIRELESS))
		return

	var/input = tgui_input_text(src, "Please enter the reason for calling the shuttle.", "Shuttle Call Reason", multiline = TRUE, encode = FALSE)
	if(!input || stat)
		return

	if(check_unable(AI_CHECK_WIRELESS))
		return

	call_shuttle_proc(src, input)

	return

/mob/living/silicon/ai/proc/ai_cancel_call()
	set name = "Recall Emergency Shuttle"
	set category = "AI Commands"

	if(check_unable(AI_CHECK_WIRELESS))
		return

	var/confirm = tgui_alert(src, "Are you sure you want to recall the shuttle?", "Confirm Shuttle Recall", list("Yes", "No"))

	if(check_unable(AI_CHECK_WIRELESS))
		return

	if(confirm == "Yes")
		cancel_call_proc(src)

/mob/living/silicon/ai/cancel_camera()
	view_core()

/mob/living/silicon/ai/verb/toggle_anchor()
	set category = "AI Commands"
	set name = "Toggle Floor Bolts"

	if(!isturf(loc)) // if their location isn't a turf
		return // stop

	if(anchored)
		set_anchored(FALSE)
	else
		set_anchored(TRUE)

	to_chat(src, "[anchored ? "<b>You are now anchored.</b>" : "<b>You are now unanchored.</b>"]")


/mob/living/silicon/ai/proc/announcement()
	set name = "Announcement"
	set desc = "Create a vocal announcement by typing in the available words to create a sentence."
	set category = "AI Commands"

	if(check_unable(AI_CHECK_WIRELESS | AI_CHECK_RADIO))
		return

	ai_announcement()

/mob/living/silicon/ai/check_eye(mob/user)
	if(!current)
		return null
	user.reset_perspective(current)
	return TRUE

/mob/living/silicon/ai/blob_act(obj/structure/blob/B)
	if(stat != DEAD)
		adjustBruteLoss(60)
		return TRUE
	return TRUE

/mob/living/silicon/ai/emp_act(severity)
	..()
	if(prob(30))
		switch(pick(1,2))
			if(1)
				view_core()
			if(2)
				ai_call_shuttle()

/mob/living/silicon/ai/ex_act(severity)
	..()

	switch(severity)
		if(1.0)
			gib()
		if(2.0)
			if(stat != 2)
				apply_damages(60, 60)
		if(3.0)
			if(stat != 2)
				apply_damage(30)


/mob/living/silicon/ai/ratvar_act()
	if(isclocker(src))
		return
	SSticker.mode.add_clocker(mind)
	laws = new /datum/ai_laws/ratvar
	add_overlay("clockwork_frame")
	for(var/mob/living/silicon/robot/R in connected_robots)
		to_chat(R, "<span class='danger'>ERROR: Master AI has be&# &#@)!-")
		to_chat(R, "<span class='clocklarge'>\"Your master is under my control, so do you\"")
		R.ratvar_act(TRUE)
		SSticker?.score?.save_silicon_laws(R, additional_info = "Ratvar act via master AI conversion", log_all_laws = TRUE)

/mob/living/silicon/ai/Topic(href, href_list)
	if(usr != src)
		return
	..()
	if(href_list["mach_close"])
		if(href_list["mach_close"] == "aialerts")
			viewalerts = 0
		var/t1 = "window=[href_list["mach_close"]]"
		unset_machine()
		close_window(src, t1)
	if(href_list["switchcamera"])
		switchCamera(locate(href_list["switchcamera"]) in GLOB.cameranet.cameras)
	if(href_list["showalerts"])
		ai_alerts()
	if(href_list["show_paper"])
		if(last_paper_seen)
			var/datum/browser/popup = new(src, "show_paper", last_paper_seen_title)
			popup.include_default_stylesheet = FALSE
			popup.set_content(last_paper_seen)
			popup.open(FALSE)
	//Carn: holopad requests
	if(href_list["jumptoholopad"])
		var/obj/machinery/hologram/holopad/H = locate(href_list["jumptoholopad"])
		if(stat == CONSCIOUS)
			if(H)
				H.attack_ai(src) //may as well recycle
			else
				to_chat(src, "<span class='notice'>Unable to locate the holopad.</span>")

	if(href_list["say_word"])
		play_vox_word(href_list["say_word"], null, src)
		return

	if(href_list["track"])
		var/mob/living/target = locate(href_list["track"]) in GLOB.mob_list
		if(istype(target) && target.can_track())
			ai_actual_track(target)
		else
			to_chat(src, "<span class='warning'>Target is not on or near any active cameras on the station.</span>")
		return

	if(href_list["trackbot"])
		var/mob/living/simple_animal/bot/target = locate(href_list["trackbot"]) in GLOB.bots_list
		if(target)
			ai_actual_track(target)
		else
			to_chat(src, "<span class='warning'>Target is not on or near any active cameras on the station.</span>")
		return

	if(href_list["callbot"]) //Command a bot to move to a selected location.
		Bot = locate(href_list["callbot"]) in GLOB.bots_list
		if(!Bot || Bot.remote_disabled || control_disabled)
			return //True if there is no bot found, the bot is manually emagged, or the AI is carded with wireless off.
		waypoint_mode = 1
		to_chat(src, "<span class='notice'>Set your waypoint by clicking on a valid location free of obstructions.</span>")
		return

	if(href_list["interface"]) //Remotely connect to a bot!
		Bot = locate(href_list["interface"]) in GLOB.bots_list
		if(!Bot || Bot.remote_disabled || control_disabled)
			return
		Bot.attack_ai(src)

	if(href_list["botrefresh"]) //Refreshes the bot control panel.
		botcall()
		return

	if(href_list["ai_take_control"]) //Mech domination

		var/obj/mecha/M = locate(href_list["ai_take_control"])

		if(!M)
			return

		var/mech_has_controlbeacon = FALSE
		for(var/obj/item/mecha_parts/mecha_tracking/ai_control/A in M.trackers)
			mech_has_controlbeacon = TRUE
			break
		if(!can_dominate_mechs && !mech_has_controlbeacon)
			message_admins("Warning: possible href exploit by [ADMIN_LOOKUPFLW(usr)] - attempted control of a mecha without can_dominate_mechs or a control beacon in the mech.")
			log_debug("Warning: possible href exploit by [key_name_log(usr)] - attempted control of a mecha without can_dominate_mechs or a control beacon in the mech.")
			return

		if(controlled_mech)
			to_chat(src, "<span class='warning'>You are already loaded into an onboard computer!</span>")
			return
		if(!GLOB.cameranet.checkCameraVis(M))
			to_chat(src, "<span class='warning'>Exosuit is no longer near active cameras.</span>")
			return
		if(lacks_power())
			to_chat(src, "<span class='warning'>You're depowered!</span>")
			return
		if(!isturf(loc))
			to_chat(src, "<span class='warning'>You aren't in your core!</span>")
			return
		if(M)
			M.transfer_ai(AI_MECH_HACK, src, usr) //Called om the mech itself.

	else if(href_list["faketrack"])
		var/mob/target = locate(href_list["track"]) in GLOB.mob_list
		var/mob/living/silicon/ai/A = locate(href_list["track2"]) in GLOB.mob_list
		if(A && target)

			A.cameraFollow = target
			to_chat(A, "Now tracking [target.name] on camera.")
			if(usr.machine == null)
				usr.machine = usr

			while(cameraFollow == target)
				to_chat(usr, "Target is not on or near any active cameras on the station. We'll check again in 5 seconds (unless you use the cancel-camera verb).")
				sleep(40)
				continue

	else if(href_list["open"])
		var/mob/target = locate(href_list["open"]) in GLOB.mob_list
		if(target)
			open_nearest_door(target)

/mob/living/silicon/ai/bullet_act(var/obj/projectile/Proj)
	..(Proj)
	return 2

/mob/living/silicon/ai/reset_perspective(atom/new_eye)
	SHOULD_CALL_PARENT(FALSE) // I hate you all
	if(camera_light_on)
		light_cameras()
	if(istype(new_eye, /obj/machinery/camera))
		current = new_eye
	if(!client)
		return

	if(ismovable(new_eye))
		client.perspective = EYE_PERSPECTIVE
		client.set_eye(new_eye)
	else
		if(isturf(loc))
			if(eyeobj)
				client.set_eye(eyeobj)
				client.perspective = EYE_PERSPECTIVE
			else
				client.set_eye(client.mob)
				client.perspective = MOB_PERSPECTIVE
		else
			client.perspective = EYE_PERSPECTIVE
			client.set_eye(loc)
	update_sight()
	update_fullscreen()

	// I am so sorry
	SEND_SIGNAL(src, COMSIG_MOB_RESET_PERSPECTIVE)

/mob/living/silicon/ai/proc/botcall()
	set category = "AI Commands"
	set name = "Access Robot Control"
	set desc = "Wirelessly control various automatic robots."
	if(stat == 2)
		to_chat(src, "<span class='danger'>Critical error. System offline.</span>")
		return

	if(check_unable(AI_CHECK_WIRELESS | AI_CHECK_RADIO))
		return

	var/d
	var/area/bot_area
	d += "<a href='byond://?src=[UID()];botrefresh=\ref[Bot]'>Query network status</a><br>"
	d += "<table width='100%'><tr><td width='40%'><h3>Name</h3></td><td width='20%'><h3>Status</h3></td><td width='30%'><h3>Location</h3></td><td width='10%'><h3>Control</h3></td></tr>"

	for(var/mob/living/simple_animal/bot/Bot in GLOB.bots_list)
		if(is_ai_allowed(Bot.z) && !Bot.remote_disabled) //Only non-emagged bots on the allowed Z-level are detected!
			bot_area = get_area(Bot)
			d += "<tr><td width='30%'>[Bot.hacked ? "<span class='bad'>(!) </span>[Bot.name]" : Bot.name] ([Bot.model])</td>"
			//If the bot is on, it will display the bot's current mode status. If the bot is not mode, it will just report "Idle". "Inactive if it is not on at all.
			d += "<td width='20%'>[Bot.on ? "[Bot.mode ? "<span class='average'>[ Bot.mode_name[Bot.mode] ]</span>": "<span class='good'>Idle</span>"]" : "<span class='bad'>Inactive</span>"]</td>"
			d += "<td width='30%'>[bot_area.name]</td>"
			d += "<td width='10%'><a href='byond://?src=[UID()];interface=\ref[Bot]'>Interface</a></td>"
			d += "<td width='10%'><a href='byond://?src=[UID()];callbot=\ref[Bot]'>Call</a></td>"
			d += "</tr>"
			d = format_text(d)

	var/datum/browser/popup = new(src, "botcall", "Remote Robot Control", 700, 400)
	popup.set_content(d)
	popup.open()

/mob/living/silicon/ai/proc/set_waypoint(atom/A)
	var/turf/turf_check = get_turf(A)
		//The target must be in view of a camera or near the core.
	if(turf_check in range(get_turf(src)))
		call_bot(turf_check)
	else if(GLOB.cameranet && GLOB.cameranet.checkTurfVis(turf_check))
		call_bot(turf_check)
	else
		to_chat(src, "<span class='danger'>Selected location is not visible.</span>")

/mob/living/silicon/ai/proc/call_bot(turf/waypoint)

	if(!Bot)
		return

	if(Bot.calling_ai && Bot.calling_ai != src) //Prevents an override if another AI is controlling this bot.
		to_chat(src, "<span class='danger'>Interface error. Unit is already in use.</span>")
		return

	Bot.call_bot(src, waypoint)

/mob/living/silicon/ai/alarm_triggered(src, class, area/A, list/O, obj/alarmsource)
	if(!(class in alarms_listend_for))
		return
	if(alarmsource.z != z)
		return
	if(stat == DEAD)
		return TRUE
	if(O)
		var/obj/machinery/camera/C = locateUID(O[1])
		if(O.len == 1 && !QDELETED(C) && C.can_use())
			queueAlarm("--- [class] alarm detected in [A.name]! (<a href='byond://?src=[UID()];switchcamera=[O[1]]'>[C.c_tag]</a>)", class)
		else if(O && O.len)
			var/foo = 0
			var/dat2 = ""
			for(var/thing in O)
				var/obj/machinery/camera/I = locateUID(thing)
				if(!QDELETED(I))
					dat2 += "[(!foo) ? "" : " | "]<a href='byond://?src=[UID()];switchcamera=[thing]'>[I.c_tag]</a>"
					foo = 1
			queueAlarm("--- [class] alarm detected in [A.name]! ([dat2])", class)
		else
			queueAlarm("--- [class] alarm detected in [A.name]! (No Camera)", class)
	else
		queueAlarm("--- [class] alarm detected in [A.name]! (No Camera)", class)
	if(viewalerts)
		ai_alerts()

/mob/living/silicon/ai/alarm_cancelled(src, class, area/A, obj/origin, cleared)
	if(cleared)
		if(!(class in alarms_listend_for))
			return
		if(origin.z != z)
			return
		queueAlarm("--- [class] alarm in [A.name] has been cleared.", class, 0)
		if(viewalerts)
			ai_alerts()

/mob/living/silicon/ai/proc/switchCamera(obj/machinery/camera/C)

	if(!tracking)
		cameraFollow = null

	if(QDELETED(C) || stat == DEAD) //C.can_use())
		return FALSE

	if(!eyeobj)
		view_core()
		return
	// ok, we're alive, camera is good and in our network...
	eyeobj.setLoc(get_turf(C))
	//machine = src

	return TRUE

//Replaces /mob/living/silicon/ai/verb/change_network() in ai.dm & camera.dm
//Adds in /mob/living/silicon/ai/proc/ai_network_change() instead
//Addition by Mord_Sith to define AI's network change ability
/mob/living/silicon/ai/proc/ai_network_change()
	set category = "AI Commands"
	set name = "Jump To Network"
	unset_machine()
	var/cameralist[0]

	if(check_unable())
		return

	if(usr.stat == 2)
		to_chat(usr, "You can't change your camera network because you are dead!")
		return

	var/mob/living/silicon/ai/U = usr

	for(var/obj/machinery/camera/C in GLOB.cameranet.cameras)
		if(!C.can_use())
			continue

		var/list/tempnetwork = difflist(C.network,GLOB.restricted_camera_networks,1)
		if(tempnetwork.len)
			for(var/i in tempnetwork)
				cameralist[i] = i
	var/old_network = network
	network = tgui_input_list(U, "Which network would you like to view?", "Jump To Network", cameralist)

	if(check_unable())
		return

	if(!U.eyeobj)
		U.view_core()
		return

	if(isnull(network))
		network = old_network // If nothing is selected
	else
		for(var/obj/machinery/camera/C in GLOB.cameranet.cameras)
			if(!C.can_use())
				continue
			if(network in C.network)
				U.eyeobj.setLoc(get_turf(C))
				break
	to_chat(src, "<span class='notice'>Switched to [network] camera network.</span>")
//End of code by Mord_Sith

/mob/living/silicon/ai/proc/ai_statuschange()
	set category = "AI Commands"
	set name = "AI Status"

	if(usr.stat == 2)
		to_chat(usr, "You cannot change your emotional status because you are dead!")
		return

	if(check_unable())
		return

	var/list/ai_emotions = list("Very Happy", "Happy", "Neutral", "Unsure", "Confused", "Sad", "Surprised", "BSOD", "Blank", "Problems?", "Awesome", "Dorfy", "Facepalm", "Friend Computer", "Beer", "Dwarf", "Fish Tank", "Plump", "Tribunal")
	var/emote = input("Please, select a status!", "AI Status", null, null) in ai_emotions

	if(check_unable())
		return

	for(var/obj/machinery/ai_status_display/display as anything in GLOB.ai_displays) //change status
		display.emotion = emote
		display.update_icon(UPDATE_OVERLAYS)

	for(var/obj/machinery/machine in GLOB.machines) //change status
		if(istype(machine, /obj/machinery/ai_status_display))
			var/obj/machinery/ai_status_display/display = machine
			display.emotion = emote
			display.update_icon()

		//if Friend Computer, change ALL displays
		else if(istype(machine, /obj/machinery/status_display))

			var/obj/machinery/status_display/display = machine
			if(emote=="Friend Computer")
				display.friendc = TRUE
			else
				display.friendc = FALSE


//I am the icon meister. Bow fefore me.	//>fefore
/mob/living/silicon/ai/proc/ai_hologram_change()
	set name = "Change Hologram"
	set desc = "Change the default hologram available to AI to something else."
	set category = "AI Commands"

	if(check_unable())
		return
	if(!custom_hologram) //Check to see if custom sprite time, checking the appopriate file to change a var
		var/file = file2text("config/custom_sprites.txt")
		var/lines = splittext(file, "\n")

		for(var/line in lines)
		// split & clean up
			var/list/Entry = splittext(line, ":")
			for(var/i = 1 to Entry.len)
				Entry[i] = trim(Entry[i])

			if(Entry.len < 2 || Entry[1] != "hologram")
				continue

			if (Entry[2] == ckey) //Custom holograms
				custom_hologram = 1  // option is given in hologram menu

	var/input
	switch(tgui_alert(usr, "Would you like to select a hologram based on a crew member, an animal, or switch to a unique avatar?", "Change Hologram", list("Crew Member", "Unique", "Animal")))
		if("Crew Member")
			var/personnel_list[] = list()

			for(var/datum/data/record/t in GLOB.data_core.general)//Look in data core general.
				personnel_list["[t.fields["name"]]: [t.fields["rank"]]"] = t.fields["photo"]//Pull names, rank, and id photo.

			if(personnel_list.len)
				input = tgui_input_list(usr, "Select a crew member", "Change Hologram", personnel_list)
				var/icon/character_icon = personnel_list[input]
				if(character_icon)
					qdel(holo_icon)//Clear old icon so we're not storing it in memory.
					holo_icon = getHologramIcon(icon(character_icon))
			else
				alert("No suitable records found. Aborting.")

		if("Animal")
			var/icon_list[] = list(
			"Bear",
			"Carp",
			"Chicken",
			"Corgi",
			"Cow",
			"Crab",
			"Deer",
			"Fox",
			"Goat",
			"Goose",
			"Kitten",
			"Kitten2",
			"Pig",
			"Poly",
			"Pug",
			"Seal",
			"Spider",
			"Turkey"
			)

			input = tgui_input_list(usr, "Please select a hologram", "Change Hologram", icon_list)
			if(input)
				qdel(holo_icon)
				switch(input)
					if("Bear")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi',"bear"))
					if("Carp")
						holo_icon = getHologramIcon(icon('icons/mob/carp.dmi',"carp"))
					if("Chicken")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi',"chicken_brown"))
					if("Corgi")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi',"corgi"))
					if("Cow")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi',"cow"))
					if("Crab")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi',"crab"))
					if("Deer")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi',"deer"))
					if("Fox")
						holo_icon = getHologramIcon(icon('icons/mob/pets.dmi',"fox"))
					if("Goat")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi',"goat"))
					if("Goose")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi',"goose"))
					if("Kitten")
						holo_icon = getHologramIcon(icon('icons/mob/pets.dmi',"cat"))
					if("Kitten2")
						holo_icon = getHologramIcon(icon('icons/mob/pets.dmi',"cat2"))
					if("Pig")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi',"pig"))
					if("Poly")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi',"parrot_fly"))
					if("Pug")
						holo_icon = getHologramIcon(icon('icons/mob/pets.dmi',"pug"))
					if("Seal")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi',"seal"))
					if("Spider")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi',"guard"))
					if("Turkey")
						holo_icon = getHologramIcon(icon('icons/mob/animal.dmi',"turkey"))

		else
			var/icon_list[] = list(
			"default",
			"floating face",
			"xeno queen",
			"eldritch",
			"ancient machine",
			"AUTO",
			"beach ball",
			"pair of bees"
			)
			if(custom_hologram) //insert custom hologram
				icon_list.Add("custom")

			input = tgui_input_list(usr, "Please select a hologram", "Change Hologram", icon_list)
			if(input)
				qdel(holo_icon)
				switch(input)
					if("default")
						holo_icon = getHologramIcon(icon('icons/mob/ai.dmi',"holo1"))
					if("floating face")
						holo_icon = getHologramIcon(icon('icons/mob/ai.dmi',"holo2"))
					if("xeno queen")
						holo_icon = getHologramIcon(icon('icons/mob/ai.dmi',"holo3"))
					if("eldritch")
						holo_icon = getHologramIcon(icon('icons/mob/ai.dmi',"holo4"))
					if("AUTO")
						holo_icon = getHologramIcon(icon('icons/mob/ai.dmi',"holo5"))
					if("beach ball")
						holo_icon = getHologramIcon(icon('icons/mob/ai.dmi',"holo6"))
					if("pair of bees")
						holo_icon = getHologramIcon(icon('icons/mob/ai.dmi',"holo7"))
					if("ancient machine")
						holo_icon = getHologramIcon(icon('icons/mob/ancient_machine.dmi', "ancient_machine"))
					if("custom")
						if("[ckey]-ai-holo" in icon_states('icons/mob/custom_synthetic/custom-synthetic.dmi'))
							holo_icon = getHologramIcon(icon('icons/mob/custom_synthetic/custom-synthetic.dmi', "[ckey]-ai-holo"))
						else if("[ckey]-ai-holo" in icon_states('icons/mob/custom_synthetic/custom-synthetic64.dmi'))
							holo_icon = getHologramIcon(icon('icons/mob/custom_synthetic/custom-synthetic64.dmi', "[ckey]-ai-holo"))
						else
							holo_icon = getHologramIcon(icon('icons/mob/ai.dmi',"holo1"))

	return


//Toggles the luminosity and applies it by re-entereing the camera.
/mob/living/silicon/ai/proc/toggle_camera_light()
	set name = "Toggle Camera Lights"
	set desc = "Toggles the lights on the cameras throughout the station."
	set category = "AI Commands"

	if(stat != CONSCIOUS)
		return

	camera_light_on = !camera_light_on

	if(!camera_light_on)
		to_chat(src, "Camera lights deactivated.")

		for(var/obj/machinery/camera/C in lit_cameras)
			C.set_light(l_on = FALSE)
			lit_cameras = list()

		return

	light_cameras()

	to_chat(src, "Camera lights activated.")

/mob/living/silicon/ai/proc/set_syndie_radio()
	if(aiRadio)
		aiRadio.make_syndie()

/mob/living/silicon/ai/proc/sensor_mode()
	set name = "Set Sensor Augmentation"
	set desc = "Augment visual feed with internal sensor overlays."
	set category = "AI Commands"
	toggle_sensor_mode()

/mob/living/silicon/ai/proc/ai_change_voice()
	set name = "Change Voice"
	set desc = "Express yourself!"
	set category = "AI Commands"
	change_voice()

/mob/living/silicon/ai/proc/arrivals_announcement()
	set name = "Toggle Arrivals Announcer"
	set desc = "Change whether or not you wish to announce arrivals."
	set category = "AI Commands"
	announce_arrivals = !announce_arrivals
	to_chat(usr, "Arrivals announcement system [announce_arrivals ? "enabled" : "disabled"]")

/mob/living/silicon/ai/proc/change_arrival_message()
	set name = "Set Arrival Message"
	set desc = "Change the message that's transmitted when a new crew member arrives on station."
	set category = "AI Commands"

	var/newmsg = tgui_input_text(usr, "What would you like the arrival message to be? List of options: $name, $rank, $species, $gender, $age", "Change Arrival Message", arrivalmsg, encode = FALSE)
	if(isnull(newmsg) || newmsg == arrivalmsg)
		to_chat(usr, "Arrival message changing aborted.")
	else if(newmsg != arrivalmsg)
		arrivalmsg = newmsg
		to_chat(usr, "The arrival message has been successfully changed.")

// Handled camera lighting, when toggled.
// It will get the nearest camera from the eyeobj, lighting it.

/mob/living/silicon/ai/proc/light_cameras()
	var/list/obj/machinery/camera/add = list()
	var/list/obj/machinery/camera/remove = list()
	var/list/obj/machinery/camera/visible = list()
	for (var/datum/camerachunk/chunk as anything in eyeobj.visibleCameraChunks)
		for (var/z_key in chunk.cameras)
			for(var/obj/machinery/camera/camera as anything in chunk.cameras[z_key])
				if (!camera.can_use() || get_dist(camera, eyeobj) > 7)
					continue
				visible |= camera

	add = visible - lit_cameras
	remove = lit_cameras - visible

	for(var/obj/machinery/camera/C in remove)
		lit_cameras -= C //Removed from list before turning off the light so that it doesn't check the AI looking away.
		C.Togglelight(FALSE)
	for(var/obj/machinery/camera/C in add)
		C.Togglelight(TRUE)
		lit_cameras |= C


/mob/living/silicon/ai/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	var/prev_state = anchored
	user.visible_message(
		span_notice("[user] starts to [prev_state ? "unbolt" : "bolt"] [src]."),
		span_notice("You start to [prev_state ? "unbolt" : "bolt"] [src]..."),
	)
	if(!I.use_tool(src, user, 4 SECONDS, volume = I.tool_volume) || anchored != prev_state)
		return .
	set_anchored(!anchored)
	user.visible_message(
		span_notice("[user] has finished to [prev_state ? "unbolt" : "bolt"] [src]."),
		span_notice("You have finished to [prev_state ? "unbolt" : "bolt"] [src]."),
	)


/mob/living/silicon/ai/welder_act()
	return

/mob/living/silicon/ai/proc/control_integrated_radio()
	set name = "Radio Settings"
	set desc = "Allows you to change settings of your radio."
	set category = "AI Commands"

	if(check_unable(AI_CHECK_RADIO))
		return

	to_chat(src, "Accessing Subspace Transceiver control...")
	if(aiRadio)
		aiRadio.interact(src)


/mob/living/silicon/ai/proc/check_unable(flags = 0)
	if(stat == DEAD)
		to_chat(src, "<span class='warning'>You are dead!</span>")
		return TRUE

	if(lacks_power())
		to_chat(src, "<span class='warning'>Power systems failure!</span>")
		return TRUE

	if((flags & AI_CHECK_WIRELESS) && control_disabled)
		to_chat(src, "<span class='warning'>Wireless control is disabled!</span>")
		return TRUE
	if((flags & AI_CHECK_RADIO) && aiRadio.disabledAi)
		to_chat(src, "<span class='warning'>System Error - Transceiver Disabled!</span>")
		return TRUE
	return FALSE

/mob/living/silicon/ai/proc/is_in_chassis()
	return isturf(loc)

/mob/living/silicon/ai/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	if(!..())
		return
	if(interaction == AI_TRANS_TO_CARD)//The only possible interaction. Upload AI mob to a card.
		if(!mind)
			to_chat(user, "<span class='warning'>No intelligence patterns detected.</span>")//No more magical carding of empty cores, AI RETURN TO BODY!!!11
			return
		drop_hat()
		new /obj/structure/AIcore/deactivated(loc)//Spawns a deactivated terminal at AI location.
		on_the_card = TRUE
		aiRestorePowerRoutine = 0//So the AI initially has power.
		update_blind_effects()
		update_sight()
		control_disabled = TRUE//Can't control things remotely if you're stuck in a card!
		aiRadio.disabledAi = TRUE 	//No talking on the built-in radio for you either!
		forceMove(card) //Throw AI into the card.
		to_chat(src, "You have been downloaded to a mobile storage device. Remote device connection severed.")
		to_chat(user, "<span class='boldnotice'>Transfer successful</span>: [name] ([rand(1000,9999)].exe) removed from host terminal and stored within local memory.")

/mob/living/silicon/ai/can_perform_action(atom/target, action_bitflags)
	if(control_disabled)
		to_chat(src, span_warning("You can't do that right now!"))
		return FALSE
	action_bitflags &= ~NEED_HANDS
	return can_see(target) && ..() //stop AIs from leaving windows open and using then after they lose vision

/mob/living/silicon/ai/switch_to_camera(obj/machinery/camera/C)
	if(!C.can_use() || !is_in_chassis())
		return FALSE

	eyeobj.setLoc(get_turf(C))
	client.set_eye(eyeobj)
	return TRUE


/mob/living/silicon/ai/can_see(atom/A, length)
	if(isturf(loc)) //AI in core, check if on cameras
		//get_turf_pixel() is because APCs in maint aren't actually in view of the inner camera
		//apc_override is needed here because AIs use their own APC when depowered
		var/turf/T = isturf(A) ? A : get_turf_pixel(A)
		return (GLOB.cameranet && GLOB.cameranet.checkTurfVis(T)) || apc_override
	//AI is carded/shunted
	//view(src) returns nothing for carded/shunted AIs and they have x-ray vision so just use get_dist
	var/list/viewscale = getviewsize(client.view)
	return get_dist(src, A) <= max(viewscale[1]*0.5,viewscale[2]*0.5)

/mob/living/silicon/ai/proc/relay_speech(mob/living/M, list/message_pieces, verb)
	var/message_clean = combine_message(message_pieces, M)
	message_clean = replace_characters(message_clean, list("+"))

	var/message = verb_message(message_pieces, message_clean, verb)

	var/name_used = M.GetVoice()
	//This communication is imperfect because the holopad "filters" voices and is only designed to connect to the master only.
	var/rendered = "<i><span class='game say'>Relayed Speech: <span class='name'>[name_used]</span> [message]</span></i>"
	if(client?.prefs.toggles2 & PREFTOGGLE_2_RUNECHAT)
		create_chat_message(M, message_clean, list("radio"))
	show_message(rendered, 2)

/mob/living/silicon/ai/proc/malfhacked(obj/machinery/power/apc/apc)
	malfhack = null
	malfhacking = 0
	clear_alert("hackingapc")

	if(!istype(apc) || QDELETED(apc) || apc.stat & BROKEN)
		to_chat(src, "<span class='danger'>Hack aborted. The designated APC no longer exists on the power network.</span>")
		playsound(get_turf(src), 'sound/machines/buzz-two.ogg', 50, 1)
	else if(apc.aidisabled)
		to_chat(src, "<span class='danger'>Hack aborted. [apc] is no longer responding to our systems.</span>")
		playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, 1)
	else
		malf_picker.processing_time += 10

		apc.malfai = parent || src
		apc.malfhack = TRUE
		apc.locked = TRUE

		playsound(get_turf(src), 'sound/machines/ding.ogg', 50, 1)
		to_chat(src, "Hack complete. [apc] is now under your exclusive control.")
		apc.update_icon()

/mob/living/silicon/ai/proc/add_malf_picker()
	to_chat(src, "In the top right corner of the screen you will find the Malfunctions tab, where you can purchase various abilities, from upgraded surveillance to station ending doomsday devices.")
	to_chat(src, "You are also capable of hacking APCs, which grants you more points to spend on your Malfunction powers. The drawback is that a hacked APC will give you away if spotted by the crew. Hacking an APC takes 60 seconds.")
	view_core() //A BYOND bug requires you to be viewing your core before your verbs update
	malf_picker = new /datum/module_picker
	modules_action = new(malf_picker)
	modules_action.Grant(src)

///Removes all malfunction-related /datum/action's from the target AI.
/mob/living/silicon/ai/proc/remove_malf_abilities()
	QDEL_NULL(modules_action)
	for(var/datum/AI_Module/AM in current_modules)
		for(var/datum/action/A in actions)
			if(istype(A, initial(AM.power_type)))
				qdel(A)

/mob/living/silicon/ai/proc/open_nearest_door(mob/living/target)
	if(!istype(target))
		return

	if(target && target.can_track())
		var/obj/machinery/door/airlock/A = null

		var/dist = -1
		for(var/obj/machinery/door/airlock/D in range(3, target))
			if(!D.density)
				continue

			var/curr_dist = get_dist(D, target)

			if(dist < 0)
				dist = curr_dist
				A = D
			else if(dist > curr_dist)
				dist = curr_dist
				A = D

		if(istype(A))
			switch(tgui_alert(src, "Do you want to open \the [A] for [target]?", "Doorknob_v2a.exe", list("Yes", "No")))
				if("Yes")
					if(!A.density)
						to_chat(src, "<span class='notice'>[A] was already opened.</span>")
					else if(A.open_close(src))
						to_chat(src, "<span class='notice'>You open \the [A] for [target].</span>")
				else
					to_chat(src, "<span class='warning'>You deny the request.</span>")
		else
			to_chat(src, "<span class='warning'>Unable to locate an airlock near [target].</span>")

	else
		to_chat(src, "<span class='warning'>Target is not on or near any active cameras on the station.</span>")

/mob/living/silicon/ai/proc/camera_visibility(mob/camera/aiEye/moved_eye)
	GLOB.cameranet.visibility(moved_eye, client, all_eyes)

/mob/living/silicon/ai/var/current_camera = 0

/mob/living/silicon/ai/proc/set_camera_by_index(client/user, var/camnum)
	var/camnum_length = length(stored_locations)
	if(camnum > camnum_length || (camnum == 0 && camnum_length < 10))
		to_chat(user, "<span class='warning'>You have no stored camera on [camnum] position</span>")
		return FALSE
	if(camnum == 0)
		camnum = 10
	current_camera = camnum
	return TRUE

/mob/living/silicon/ai/proc/check_for_binded_cameras(client/user)
	if(!length(stored_locations))
		to_chat(user, "<span class='warning'>You have no stored camera positions</span>")
		return FALSE
	return TRUE

/mob/living/silicon/ai/proc/update_binded_camera(client/user)
	var/camname
	camname = stored_locations[current_camera]
	ai_goto_location(camname)
	to_chat(user, "<span class='notice'>Now you on camera position: [camname]</span>")

/mob/living/silicon/ai/proc/current_camera_next(client/user)
	if(current_camera >= length(stored_locations))
		current_camera = 1
	else
		current_camera += 1

/mob/living/silicon/ai/proc/current_camera_back(client/user)
	if(current_camera <= 1)
		current_camera = length(stored_locations)
	else
		current_camera -= 1

/mob/living/silicon/ai/handle_fire()
	return

/mob/living/silicon/ai/update_fire()
	return

/mob/living/silicon/ai/IgniteMob()
	return FALSE

/mob/living/silicon/ai/ExtinguishMob()
	return


/mob/living/silicon/ai/update_sight()
	if(!client)
		return

	if(stat == DEAD)
		grant_death_vision()
		return

	set_invis_see(initial(see_invisible))
	nightvision = initial(nightvision)
	set_sight(initial(sight))
	lighting_alpha = initial(lighting_alpha)

	if(aiRestorePowerRoutine)
		clear_sight(SEE_TURFS|SEE_MOBS|SEE_OBJS)
		nightvision = 0

	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_SIGHT)
	sync_lighting_plane_alpha()


/mob/living/silicon/ai/ghostize(can_reenter_corpse)
	var/old_turf = get_turf(eyeobj)
	. = ..()
	if(isobserver(.))
		var/mob/dead/observer/ghost = .
		ghost.forceMove(old_turf)
