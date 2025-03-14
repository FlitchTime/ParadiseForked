//update_state
#define UPSTATE_CELL_IN 1
#define UPSTATE_OPENED1 2
#define UPSTATE_OPENED2 4
#define UPSTATE_MAINT 8
#define UPSTATE_BROKE 16
#define UPSTATE_BLUESCREEN 32
#define UPSTATE_WIREEXP 64
#define UPSTATE_ALLGOOD 128

//update_overlay
#define APC_UPOVERLAY_CHARGEING0 1
#define APC_UPOVERLAY_CHARGEING1 2
#define APC_UPOVERLAY_CHARGEING2 4
#define APC_UPOVERLAY_EQUIPMENT0 8
#define APC_UPOVERLAY_EQUIPMENT1 16
#define APC_UPOVERLAY_EQUIPMENT2 32
#define APC_UPOVERLAY_LIGHTING0 64
#define APC_UPOVERLAY_LIGHTING1 128
#define APC_UPOVERLAY_LIGHTING2 256
#define APC_UPOVERLAY_ENVIRON0 512
#define APC_UPOVERLAY_ENVIRON1 1024
#define APC_UPOVERLAY_ENVIRON2 2048
#define APC_UPOVERLAY_LOCKED 4096

#define APC_UPDATE_ICON_COOLDOWN (20 SECONDS)

// main_status var
#define APC_EXTERNAL_POWER_NOTCONNECTED 0
#define APC_EXTERNAL_POWER_NOENERGY 1
#define APC_EXTERNAL_POWER_GOOD 2

// APC malf status
#define APC_MALF_NOT_HACKED 1
/// APC hacked by user, and user is in its core.
#define APC_MALF_HACKED 2
/// User is shunted in this APC.
#define APC_MALF_SHUNTED_HERE 3
/// User is shunted in another APC
#define APC_MALF_SHUNTED_OTHER 4

/// Power channel is off, anything connected to it is not powered, cannot be set manually by players.
#define CHANNEL_SETTING_OFF 0
/// APC power channel Setting Off, if set while apc is "on" set apc to "off" otherwise set to "auto-off".
#define CHANNEL_SETTING_AUTO_OFF 1
/// APC power channel setting on.
#define CHANNEL_SETTING_ON 2   //on
/// APC user setting.
#define CHANNEL_SETTING_AUTO_ON  3 //auto

//open states
#define APC_CLOSED 0
#define APC_OPENED 1
#define APC_COVER_OFF 2

//autoflags
#define APC_AUTOFLAG_ALL_OFF 0
#define APC_AUTOFLAG_ENVIRO_ONLY 1
#define APC_AUTOFLAG_EQUIPMENT_OFF 2
#define APC_AUTOFLAG_ALL_ON 3

//electronics state
#define APC_ELECTRONICS_NONE 0
#define APC_ELECTRONICS_INSTALLED 1
#define APC_ELECTRONICS_SECURED 2


// the Area Power Controller (APC), formerly Power Distribution Unit (PDU)
// one per area, needs wire conection to power network through a terminal

// controls power to devices in that area
// may be opened to change power cell
// three different channels (lighting/equipment/environ) - may each be set to on, off, or auto


//NOTE: STUFF STOLEN FROM AIRLOCK.DM thx


/obj/machinery/power/apc
	name = "area power controller"
	desc = "A control terminal for the area electrical systems."
	icon_state = "apc0"
	use_power = NO_POWER_USE
	max_integrity = 200
	integrity_failure = 50
	resistance_flags = FIRE_PROOF
	req_access = list(ACCESS_ENGINE_EQUIP)
	siemens_strength = 1
	damage_deflection = 10
	powernet = 0	// set so that APCs aren't found as powernet nodes //Hackish, Horrible, was like this before I changed it :( (elly1989)

	/*** APC Area/Powernet vars ***/
	/// The area that this APC is in
	var/area/area
	/// The set string name of the area, used in naming the APC
	var/areastring
	/// The power terminal connected to this APC
	var/obj/machinery/power/terminal/terminal
	/// The status of the terminals powernet that this APC is connected to: not connected, no power, or recieving power
	var/main_status = APC_EXTERNAL_POWER_NOTCONNECTED

	/// Amount of power used in the last cycle for lighting channel
	var/last_used_lighting = 0
	/// Amount of power used in the last cycle for equipment channel
	var/last_used_equipment = 0
	/// Amount of power used in the last cycle for environment channel
	var/last_used_environment = 0
	/// Amount of power used in the last cycle in total
	var/last_used_total = 0

	/// Is there a cog siphoning power?
	var/obj/machinery/integration_cog/cog

	/*** APC Cell Vars ***/
	/// The cell type stored in this APC
	var/obj/item/stock_parts/cell/cell
	/// The percentage charge the internal battery will start with
	var/start_charge = 90
	///Base cell has 2500 capacity. Enter the path of a different cell you want to use. cell determines charge rates, max capacity, ect. These can also be changed with other APC vars, but isn't recommended to minimize the risk of accidental usage of dirty editted APCs
	var/cell_type = 2500

	/*** APC Status Vars ***/
	/// The wire panel associated with this APC
	var/datum/wires/apc/wires
	/// Can the APC recieve/transmit power? Determined by the condition of the 2 Main Power Wires
	var/shorted = FALSE
	/// Is the APC on and transmitting power.
	var/operating = TRUE
	/// The current charging mode of the APC: not charging, charging, fully charged
	var/charging = APC_NOT_CHARGING
	/// A counter var used to help determine if the APC has not been charging long enough to justify not performing certain auto setting such as turning all channels back on
	var/longtermpower = 10
	/// State of the APC Cover - Closed, Open, or Off
	var/opened = APC_CLOSED
	/// Can silicons access this APC?
	var/aidisabled = FALSE
	/// Electonics cicuit status.
	var/electronics_state = APC_ELECTRONICS_NONE

	/*** APC Settings Vars ***/
	/// The current setting for the lighting channel
	var/lighting_channel = CHANNEL_SETTING_AUTO_ON
	/// The current setting for the equipment channel
	var/equipment_channel = CHANNEL_SETTING_AUTO_ON
	/// The current setting for the environment channel
	var/environment_channel = CHANNEL_SETTING_AUTO_ON
	/// Is the APC cover locked? i.e cannot be opened?
	var/coverlocked = TRUE
	/// Is the APC User Interface locked (prevents interaction)? Will not prevent silicons or admin observers from interacting
	var/locked = TRUE
	/// If TRUE, the APC will automatically draw power from connect terminal, if FALSE it will not charge.
	var/chargemode = TRUE
	/// Counter var, ticks up when the APC recieves power from terminal and resets to 0 when not charging, used for the `var/charging` var
	var/chargecount = 0
	/// Whether this APC will generate alert reports based on current status.
	var/report_power_alarm = TRUE

	/// If set to TRUE, this APC will not arc bolts of electricity if it's overloaded.
	var/shock_proof = FALSE

	// Nightshift
	var/nightshift_lights = FALSE
	var/last_nightshift_switch = 0

	// Used to determine if emergency lights should be on or off
	var/emergency_power = TRUE
	var/emergency_power_timer
	var/emergency_lights = FALSE

	/// Settings variable for having the APC auto use certain power channel settings
	var/autoflag = APC_AUTOFLAG_ALL_OFF

	/// Being hijacked by a pulse demon?
	var/being_hijacked = FALSE

	/*** APC Malf AI Vars ****/
	var/malfhack = FALSE
	var/mob/living/silicon/ai/malfai
	var/mob/living/silicon/ai/occupier
	/// Used for the Blackout malf module
	var/overload = 1

	/// Used to debug APC processing.
	var/debug = FALSE

	/*** APC Overlay Vars ***/
	var/update_state = -1
	var/update_overlay = -1
	var/global/status_overlays = FALSE
	var/updating_icon = FALSE
	var/global/list/status_overlays_lock
	var/global/list/status_overlays_charging
	var/global/list/status_overlays_equipment
	var/global/list/status_overlays_lighting
	var/global/list/status_overlays_environ
	var/keep_preset_name = FALSE


/obj/machinery/power/apc/worn_out
	name = "\improper Worn out APC"
	keep_preset_name = TRUE
	locked = FALSE
	lighting_channel = CHANNEL_SETTING_OFF
	equipment_channel = CHANNEL_SETTING_OFF
	environment_channel = CHANNEL_SETTING_OFF
	operating = FALSE
	emergency_power = FALSE

/obj/machinery/power/apc/noalarm
	report_power_alarm = FALSE

/obj/machinery/power/apc/syndicate //general syndicate access
	req_access = list(ACCESS_SYNDICATE)
	report_power_alarm = FALSE

/obj/item/apc_electronics
	name = "power control module"
	desc = "Heavy-duty switching circuits for power control."
	icon = 'icons/obj/module.dmi'
	icon_state = "power_mod"
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "engineering=2;programming=1"
	item_state = "electronic"
	flags = CONDUCT
	usesound = 'sound/items/deconstruct.ogg'
	toolspeed = 1

/obj/machinery/power/apc/get_cell()
	return cell

/obj/machinery/power/apc/connect_to_network()
	//Override because the APC does not directly connect to the network; it goes through a terminal.
	//The terminal is what the power computer looks for anyway.
	if(terminal)
		terminal.connect_to_network()

/obj/machinery/power/apc/New(turf/loc, direction, building = 0)
	if(!armor)
		armor = list("melee" = 20, "bullet" = 20, "laser" = 10, "energy" = 100, "bomb" = 30, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 50)
	..()
	GLOB.apcs += src
	GLOB.apcs = sortAtom(GLOB.apcs)

	wires = new(src)

	if(is_taipan(z)) // Синдидоступ при сборке на тайпане
		req_access = list(ACCESS_SYNDICATE)

	if(building)
		// Offset 24 pixels in direction of dir. This allows the APC to be embedded in a wall, yet still inside an area
		setDir(direction) // This is only used for pixel offsets, and later terminal placement. APC dir doesn't affect its sprite since it only has one orientation.
		set_pixel_offsets_from_dir(24, -24, 24, -24)

		area = get_area(src)
		area.apc |= src
		opened = APC_OPENED
		operating = FALSE
		name = "[area.name] APC"
		stat |= MAINT
		update_icon()
		addtimer(CALLBACK(src, PROC_REF(update)), 5)

/obj/machinery/power/apc/Destroy()
	SStgui.close_uis(wires)
	GLOB.apcs -= src
	if(malfai && operating)
		malfai.malf_picker.processing_time = clamp(malfai.malf_picker.processing_time - 10,0,1000)
	area.power_light = 0
	area.power_equip = 0
	area.power_environ = 0
	area.power_change()
	if(occupier)
		malfvacate(1)
	QDEL_NULL(wires)
	QDEL_NULL(cell)
	QDEL_NULL(cog)
	if(terminal)
		disconnect_terminal()
	area.apc -= src
	return ..()

/obj/machinery/power/apc/proc/make_terminal()
	// create a terminal object at the same position as original turf loc
	// wires will attach to this
	terminal = new/obj/machinery/power/terminal(get_turf(src))
	terminal.setDir(dir)
	terminal.master = src

/obj/machinery/power/apc/Initialize(mapload)
	. = ..()
	if(!mapload)
		return
	electronics_state = APC_ELECTRONICS_SECURED
	// is starting with a power cell installed, create it and set its charge level
	if(cell_type)
		cell = new/obj/item/stock_parts/cell/upgraded(src)
		cell.maxcharge = cell_type	// cell_type is maximum charge (old default was 1000 or 2500 (values one and two respectively)
		cell.charge = start_charge * cell.maxcharge / 100 		// (convert percentage to actual value)

	cog = null // Or you can't put it in
	var/area/A = get_area(src)


	//if area isn't specified use current
	if(keep_preset_name)
		if(isarea(A))
			area = A
		// no-op, keep the name
	else if(isarea(A) && !areastring)
		area = A
		name = "\improper [area.name] APC"
	else
		name = "\improper [get_area_name(area, TRUE)] APC"
	area.apc |= src

	update_icon()

	make_terminal()

	addtimer(CALLBACK(src, PROC_REF(update)), 5)

/obj/machinery/power/apc/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		if(stat & BROKEN)
			. += "<span class='warning'>Looks broken</span>"
		else if(opened)
			if(has_electronics() && terminal)
				. += "<span class='notice'>The cover is [opened == APC_COVER_OFF ?"removed":"open"] and the power cell is [ cell ? "installed" : "missing"].</span>"
			else if(!has_electronics() && terminal)
				. += "<span class='notice'>There are some wires but no electronics.</span>"
			else if(has_electronics() && !terminal)
				. += "<span class='notice'>Electronics installed but not wired.</span>"
			else /* if(!has_electronics && !terminal) */
				. += "<span class='notice'>There are no electronics nor connected wires.</span>"
			if(user.Adjacent(src) && cog)
				. += "<span class='warning'>[src]'s innards have been replaced by strange brass machinery!</span>"
		else
			if(stat & MAINT)
				. += "<span class='notice'>The cover is closed. Something wrong with it: it doesn't work.</span>"
			else if(malfhack)
				. += "<span class='warning'>The cover is broken. It may be hard to force it open.</span>"
			else
				. += "<span class='notice'>The cover is closed.</span>"
	if(cog && isclocker(user))
		. += "<span class='clock'>There is an integration cog installed!</span>"


// update the APC icon to show the three base states
// also add overlays for indicator lights
/obj/machinery/power/apc/update_icon(force_update = FALSE)

	if(!status_overlays || force_update)
		status_overlays = TRUE
		status_overlays_lock = new
		status_overlays_charging = new
		status_overlays_equipment = new
		status_overlays_lighting = new
		status_overlays_environ = new

		status_overlays_lock.len = 2
		status_overlays_charging.len = 3
		status_overlays_equipment.len = 4
		status_overlays_lighting.len = 4
		status_overlays_environ.len = 4

		status_overlays_lock[1] = image(icon, "apcox-0")    // 0=blue 1=red
		status_overlays_lock[2] = image(icon, "apcox-1")

		status_overlays_charging[1] = image(icon, "apco3-0")
		status_overlays_charging[2] = image(icon, "apco3-1")
		status_overlays_charging[3] = image(icon, "apco3-2")

		status_overlays_equipment[1] = image(icon, "apco0-0") // 0=red, 1=green, 2=blue
		status_overlays_equipment[2] = image(icon, "apco0-1")
		status_overlays_equipment[3] = image(icon, "apco0-2")
		status_overlays_equipment[4] = image(icon, "apco0-3")

		status_overlays_lighting[1] = image(icon, "apco1-0")
		status_overlays_lighting[2] = image(icon, "apco1-1")
		status_overlays_lighting[3] = image(icon, "apco1-2")
		status_overlays_lighting[4] = image(icon, "apco1-3")

		status_overlays_environ[1] = image(icon, "apco2-0")
		status_overlays_environ[2] = image(icon, "apco2-1")
		status_overlays_environ[3] = image(icon, "apco2-2")
		status_overlays_environ[4] = image(icon, "apco2-3")

	var/update = check_updates() 		//returns 0 if no need to update icons.
						// 1 if we need to update the icon_state
						// 2 if we need to update the overlays
	if(!update && !force_update)
		return

	if(force_update || (update & 3))
		if(update_state & (UPSTATE_OPENED1|UPSTATE_OPENED2|UPSTATE_BROKE))
			set_light_on(FALSE)
		else if(update_state & UPSTATE_BLUESCREEN)
			set_light(2, 1, COLOR_CYAN_BLUE, l_on = TRUE)
		else if(!(stat & (UPSTATE_MAINT|UPSTATE_BROKE)) && (update_state & UPSTATE_ALLGOOD))
			var/color
			switch(charging)
				if(APC_NOT_CHARGING)
					color = COLOR_APC_RED
				if(APC_IS_CHARGING)
					color = COLOR_APC_BLUE
				if(APC_FULLY_CHARGED)
					color = COLOR_APC_GREEN
			set_light(2, 0.5, color, l_on = TRUE)
		else
			set_light_on(FALSE)

	if(force_update || (update & 1)) // Updating the icon state
		..(UPDATE_ICON_STATE)

	if(!(update_state & UPSTATE_ALLGOOD))
		if(managed_overlays)
			..(UPDATE_OVERLAYS)
		return

	if(force_update || (update & 2))
		..(UPDATE_OVERLAYS)


/obj/machinery/power/apc/update_icon_state()
	if(update_state & UPSTATE_ALLGOOD)
		icon_state = "apc0"
	else if(update_state & (UPSTATE_OPENED1|UPSTATE_OPENED2))
		var/basestate = "apc[ cell ? "2" : "1" ]"
		if(update_state & UPSTATE_OPENED1)
			if(update_state & (UPSTATE_MAINT|UPSTATE_BROKE))
				icon_state = "apcmaint" //disabled APC cannot hold cell
			else
				icon_state = basestate
		else if(update_state & UPSTATE_OPENED2)
			icon_state = "[basestate]-nocover"
	else if(update_state & UPSTATE_BROKE)
		icon_state = "apc-b"
	else if(update_state & UPSTATE_BLUESCREEN)
		icon_state = "apcemag"
	else if(update_state & UPSTATE_WIREEXP)
		icon_state = "apcewires"


/obj/machinery/power/apc/update_overlays()
	. = ..()
	underlays.Cut()

	if(update_state & UPSTATE_BLUESCREEN)
		underlays += emissive_appearance(icon, "emit_apcemag", src)
		return

	if((stat & (BROKEN|MAINT)) || !(update_state & UPSTATE_ALLGOOD))
		return

	var/image/statover_lock = status_overlays_lock[locked + 1]
	var/image/statover_charg = status_overlays_charging[charging + 1]
	. += statover_lock
	. += statover_charg
	underlays += emissive_appearance(icon, statover_lock.icon_state, src)
	underlays += emissive_appearance(icon, statover_charg.icon_state, src)

	if(!operating)
		return

	var/image/statover_equip = status_overlays_equipment[equipment_channel + 1]
	var/image/statover_light = status_overlays_lighting[lighting_channel + 1]
	var/image/statover_envir = status_overlays_environ[environment_channel + 1]
	. += statover_equip
	. += statover_light
	. += statover_envir
	underlays += emissive_appearance(icon, statover_equip.icon_state, src)
	underlays += emissive_appearance(icon, statover_light.icon_state, src)
	underlays += emissive_appearance(icon, statover_envir.icon_state, src)


/obj/machinery/power/apc/proc/check_updates()

	var/last_update_state = update_state
	var/last_update_overlay = update_overlay
	update_state = NONE
	update_overlay = NONE

	if(cell)
		update_state |= UPSTATE_CELL_IN
	if(stat & BROKEN)
		update_state |= UPSTATE_BROKE
	if(stat & MAINT)
		update_state |= UPSTATE_MAINT
	if(opened)
		if(opened == APC_OPENED)
			update_state |= UPSTATE_OPENED1
		if(opened == APC_COVER_OFF)
			update_state |= UPSTATE_OPENED2
	else if(emagged || malfai || being_hijacked)
		update_state |= UPSTATE_BLUESCREEN
	else if(panel_open)
		update_state |= UPSTATE_WIREEXP
	if(update_state <= 1)
		update_state |= UPSTATE_ALLGOOD

	if(update_state & UPSTATE_ALLGOOD)
		if(locked)
			update_overlay |= APC_UPOVERLAY_LOCKED

		if(charging == APC_NOT_CHARGING)
			update_overlay |= APC_UPOVERLAY_CHARGEING0
		else if(charging == APC_IS_CHARGING)
			update_overlay |= APC_UPOVERLAY_CHARGEING1
		else if(charging == APC_FULLY_CHARGED)
			update_overlay |= APC_UPOVERLAY_CHARGEING2

		if(!equipment_channel)
			update_overlay |= APC_UPOVERLAY_EQUIPMENT0
		else if(equipment_channel == CHANNEL_SETTING_AUTO_OFF)
			update_overlay |= APC_UPOVERLAY_EQUIPMENT1
		else if(equipment_channel == CHANNEL_SETTING_ON)
			update_overlay |= APC_UPOVERLAY_EQUIPMENT2

		if(!lighting_channel)
			update_overlay |= APC_UPOVERLAY_LIGHTING0
		else if(lighting_channel == CHANNEL_SETTING_AUTO_OFF)
			update_overlay |= APC_UPOVERLAY_LIGHTING1
		else if(lighting_channel == CHANNEL_SETTING_ON)
			update_overlay |= APC_UPOVERLAY_LIGHTING2

		if(!environment_channel)
			update_overlay |= APC_UPOVERLAY_ENVIRON0
		else if(environment_channel == CHANNEL_SETTING_AUTO_OFF)
			update_overlay |= APC_UPOVERLAY_ENVIRON1
		else if(environment_channel == CHANNEL_SETTING_ON)
			update_overlay |= APC_UPOVERLAY_ENVIRON2

	var/results = 0
	if(last_update_state == update_state && last_update_overlay == update_overlay)
		return 0
	if(last_update_state != update_state)
		results += 1
	if(last_update_overlay != update_overlay)
		results += 2
	return results


// Used in process so it doesn't update the icon too much
/obj/machinery/power/apc/proc/queue_icon_update()

	if(!updating_icon)
		updating_icon = TRUE
		// Start the update
		addtimer(CALLBACK(src, PROC_REF(queue_icon_callback)), APC_UPDATE_ICON_COOLDOWN)


/obj/machinery/power/apc/proc/queue_icon_callback()
	update_icon()
	updating_icon = FALSE


/obj/machinery/power/apc/flicker(second_pass = FALSE)
	if(opened || panel_open)
		return FALSE
	if(stat & (NOPOWER | BROKEN))
		return FALSE
	if(!second_pass) //The first time, we just cut overlays
		addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/machinery/power/apc, flicker), TRUE), 1)
		cut_overlays()
		managed_overlays = null
		// APC power distruptions have a chance to propogate to other machines on its network
		for(var/obj/machinery/machine as anything in (area.machinery_cache - src))
			if(prob(10))
				INVOKE_ASYNC(machine, TYPE_PROC_REF(/obj/machinery, flicker))
			CHECK_TICK
	else
		flick("apcemag", src) //Second time we cause the APC to update its icon, then add a timer to update icon later
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon), TRUE), 1 SECONDS)

	return TRUE


/obj/machinery/power/apc/attackby(obj/item/I, mob/living/user, params)
	if(issilicon(user) && get_dist(src, user) > 1)
		attack_hand(user)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/stock_parts/cell))	// trying to put a cell inside
		add_fingerprint(user)
		if(opened == APC_CLOSED)
			to_chat(user, span_warning("You should open the APC cover to insert a power cell."))
			return ATTACK_CHAIN_PROCEED
		if(cell)
			to_chat(user, span_warning("There is already a power cell installed."))
			return ATTACK_CHAIN_PROCEED
		if(stat & MAINT)
			to_chat(user, span_warning("There is no connector for the power cell."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		cell = I
		for(var/mob/living/simple_animal/demon/pulse_demon/demon in cell)
			demon.forceMove(src)
			demon.current_power = src
			if(!being_hijacked) // first come first serve
				demon.try_hijack_apc(src)
		if(being_hijacked)
			cell.rigged = FALSE // don't blow the demon up
		user.visible_message(
			span_notice("[user.name] has inserted the power cell to [src]!"),
			span_notice("You have inserted the power cell."),
		)
		chargecount = 0
		update_icon()
		return ATTACK_CHAIN_BLOCKED_ALL

	if(I.GetID() || is_pda(I))	// trying to unlock the interface with an ID card
		add_fingerprint(user)
		if(togglelock(user))
			return ATTACK_CHAIN_PROCEED_SUCCESS
		return ATTACK_CHAIN_PROCEED

	if(iscoil(I))	// cable terminal
		add_fingerprint(user)
		var/obj/item/stack/cable_coil/coil = I
		if(opened == APC_CLOSED)
			to_chat(user, span_warning("You should open the APC cover to attach the cables."))
			return ATTACK_CHAIN_PROCEED
		if(terminal) // it already have terminal
			to_chat(user, span_warning("This APC is already wired."))
			return ATTACK_CHAIN_PROCEED
		var/turf/host_turf = get_turf(src)
		if(!host_turf)
			throw EXCEPTION("attackby on APC when it's not on a turf")
			return ATTACK_CHAIN_PROCEED
		if(!host_turf.can_have_cabling() || host_turf.intact)
			to_chat(user, span_warning("You should remove the floor plating in front of the APC first."))
			return ATTACK_CHAIN_PROCEED
		if(!has_electronics())
			to_chat(user, span_warning("There is nothing to wire. You should install the electronics first."))
			return ATTACK_CHAIN_PROCEED
		if(coil.get_amount() < 10)
			to_chat(user, span_warning("You need at least ten lengths of cable to wire the APC."))
			return ATTACK_CHAIN_PROCEED
		user.visible_message(
			span_notice("[user.name] starts to construct the cable terminal beneath the APC frame."),
			span_notice("You start to construct the cable terminal beneath the APC frame..."),
		)
		coil.play_tool_sound(src)
		if(!do_after(user, 2 SECONDS * coil.toolspeed, src, category = DA_CAT_TOOL) || opened == APC_CLOSED || terminal || !host_turf.can_have_cabling() || host_turf.intact || !has_electronics() || QDELETED(coil))
			return ATTACK_CHAIN_PROCEED
		var/obj/structure/cable/node = host_turf.get_cable_node()
		if(prob(50) && electrocute_mob(user, node, node, 1, TRUE))
			do_sparks(5, TRUE, src)
			return ATTACK_CHAIN_BLOCKED_ALL
		if(!coil.use(10))
			to_chat(user, span_warning("At some point during construction you lost some cable. Make sure you have ten lengths before trying again."))
			return ATTACK_CHAIN_PROCEED
		user.visible_message(
			span_notice("[user.name] has finished the construction of the cable terminal beneath the APC."),
			span_notice("You have finished the construction of the cable terminal beneath the APC."),
		)
		make_terminal()
		terminal.connect_to_network()
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/apc_electronics))
		add_fingerprint(user)
		if(opened == APC_CLOSED)
			to_chat(user, span_warning("You should open the APC cover to insert the electronics."))
			return ATTACK_CHAIN_PROCEED
		if(has_electronics()) // there are already electronicks inside
			to_chat(user, span_warning("The APC already has an electronics installed."))
			return ATTACK_CHAIN_PROCEED
		if(stat & BROKEN)
			to_chat(user, span_warning("The APC cannot hold an electronics, its too damaged."))
			return ATTACK_CHAIN_PROCEED
		user.visible_message(
			span_notice("[user.name] starts to insert the power control board into the APC."),
			span_notice("You start to insert the power control board into the APC..."),
		)
		playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
		if(!do_after(user, 1 SECONDS * I.toolspeed, src, category = DA_CAT_TOOL) || opened == APC_CLOSED || has_electronics() || (stat & BROKEN))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ATTACK_CHAIN_PROCEED
		user.visible_message(
			span_notice("[user.name] has inserted the power control board into the APC."),
			span_notice("You have inserted the power control board into the APC."),
		)
		electronics_state = APC_ELECTRONICS_INSTALLED
		locked = FALSE
		qdel(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/mounted/frame/apc_frame))	// frame repair
		add_fingerprint(user)
		if(opened == APC_CLOSED)
			to_chat(user, span_warning("You should open the APC cover to repair it."))
			return ATTACK_CHAIN_PROCEED
		if(!(stat & BROKEN || opened == APC_COVER_OFF || obj_integrity < max_integrity)) // There is nothing to repair
			to_chat(user, span_warning("The APC looks completely intact."))
			return ATTACK_CHAIN_PROCEED
		if(!(stat & BROKEN) && opened == APC_COVER_OFF) // Cover is the only thing broken, we do not need to remove elctronicks to replace cover
			user.visible_message(
				span_notice("[user.name] starts to replace the missing APC's cover."),
				span_notice("You start to to replace the missing APC's cover..."),
			)
			playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
			// replacing cover is quicker than replacing whole frame
			if(!do_after(user, 2 SECONDS * I.toolspeed, src, category = DA_CAT_TOOL) || (stat & BROKEN) || opened != APC_COVER_OFF)
				return ATTACK_CHAIN_PROCEED
			if(!user.drop_transfer_item_to_loc(I, src))
				return ATTACK_CHAIN_PROCEED
			user.visible_message(
				span_notice("[user.name] has replaced the missing APC's cover."),
				span_notice("You have replaced the missing APC's cover."),
			)
			opened = APC_OPENED
			update_icon()
			qdel(I)
			return ATTACK_CHAIN_BLOCKED_ALL
		if(has_electronics())
			to_chat(user, span_warning("You cannot repair this APC until you remove the electronics."))
			return ATTACK_CHAIN_PROCEED
		playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
		user.visible_message(
			span_notice("[user.name] starts to replace the damaged APC frame with a new one."),
			span_notice("You start to to replace damaged APC frame with a new one..."),
		)
		if(!do_after(user, 5 SECONDS * I.toolspeed, src, category = DA_CAT_TOOL) || !(stat & BROKEN || opened == APC_COVER_OFF || obj_integrity < max_integrity) || has_electronics())
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ATTACK_CHAIN_PROCEED
		playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
		user.visible_message(
			span_notice("[user.name] has replaced the damaged APC frame with a new one."),
			span_notice("You have replaced the damaged APC frame with a new one."),
		)
		stat &= ~BROKEN
		obj_integrity = max_integrity
		if(opened == APC_COVER_OFF)
			opened = APC_OPENED
		update_icon()
		qdel(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/clockwork/integration_cog))
		add_fingerprint(user)
		if(!isclocker(user))
			to_chat(user, span_warning("You fiddle around with the APC, to no avail."))
			return ATTACK_CHAIN_PROCEED
		if(cog)
			to_chat(user, span_warning("This APC already has a cog."))
			return ATTACK_CHAIN_PROCEED
		if(opened == APC_CLOSED)
			playsound(loc, 'sound/items/crowbar.ogg', 50, TRUE)
			user.visible_message(
				span_warning("[user.name] starts slicing the APC's cover lock."),
				span_clock("You start slicing the APC's cover lock..."),
			)
			if(!do_after(user, 4 SECONDS * I.toolspeed, src, category = DA_CAT_TOOL) || !isclocker(user) || cog || opened != APC_CLOSED)
				return ATTACK_CHAIN_PROCEED
			user.visible_message(
				span_warning("[user.name] has sliced the APC's cover lock, and it swings wide open."),
				span_clock("You have sliced the APC's cover lock apart, and it swings wide open."),
			)
			opened = APC_OPENED
			update_icon()
			return ATTACK_CHAIN_PROCEED_SUCCESS
		playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
		user.visible_message(
			span_warning("[user.name] starts pressing [I] into the APC's internals."),
			span_clock("You hold [I] in place within the APC, and it starts to slowly warm up..."),
		)
		if(!do_after(user, 7 SECONDS * I.toolspeed, src, category = DA_CAT_TOOL) || !isclocker(user) || cog)
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ATTACK_CHAIN_PROCEED
		playsound(user, 'sound/machines/clockcult/integration_cog_install.ogg', 50, TRUE)
		user.visible_message(
			span_warning("[user.name] has installed [I] into the APC's internals."),
			"[span_clock("Replicant alloy rapidly covers the APC's innards, replacing the machinery.<br>")][span_clockitalic("This APC will now passively provide power to the cult.")]",
		)
		cog = new(src)
		opened = APC_CLOSED
		locked = FALSE
		update_icon()
		qdel(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/machinery/power/apc/examine(mob/user)
	. = ..()
	if(in_range(src, user))
		. += span_info("<b>Alt-click</b> to toggle locker.<br/><b>Ctrl-click</b> to toggle power.")

/obj/machinery/power/apc/click_alt(mob/living/carbon/human/H)
	if(!istype(H))
		return NONE
	var/obj/item/card/id/card = H.get_id_card()
	if(!istype(card))
		return NONE

	add_fingerprint(H)
	togglelock(H)
	return CLICK_ACTION_SUCCESS


/obj/machinery/power/apc/CtrlClick(mob/user)
	SEND_SIGNAL(src, COMSIG_CLICK_CTRL, user)
	if(!can_use(user) || is_locked(user))
		return
	toggle_breaker(user)


/obj/machinery/power/apc/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.tool_start_check(src, user, 0))
		return
	if(opened) // a) on open apc
		if(electronics_state == APC_ELECTRONICS_INSTALLED)
			if(terminal)
				to_chat(user, "<span class='warning'>Disconnect the wires first!</span>")
				return
			to_chat(user, "<span class='notice'>You are trying to remove the power control board...</span>" )
			if(I.use_tool(src, user, 50, volume = I.tool_volume))
				if(has_electronics())
					electronics_state = APC_ELECTRONICS_NONE
					if(stat & BROKEN)
						user.visible_message(\
							"[user.name] has broken the power control board inside [name]!",
							"<span class='notice'>You break the charred power control board and remove the remains.</span>",
							"<span class='italics'>You hear a crack.</span>")
						return
						//SSticker.mode:apcs-- //XSI said no and I agreed. -rastaf0
					else if(emagged) // We emag board, not APC's frame
						emagged = FALSE
						user.visible_message(
							"[user.name] has discarded the shorted power control board from [name]!",
							"<span class='notice'>You discarded the shorted board.</span>")
						return
					else if(malfhack) // AI hacks board, not APC's frame
						user.visible_message(\
							"[user.name] has discarded strangely the programmed power control board from [name]!",
							"<span class='notice'>You discarded the strangely programmed board.</span>")
						malfai = null
						malfhack = 0
						return
					else
						user.visible_message(\
							"[user.name] has removed the power control board from [name]!",
							"<span class='notice'>You remove the power control board.</span>")
						new /obj/item/apc_electronics(loc)
						return
		else if(cog)
			user.visible_message("[user] starts prying [cog] from [src].", \
			"<span class='notice'>You painstakingly start tearing [cog] out of [src]'s guts...</span>")
			if(I.use_tool(src, user, 8 SECONDS, volume = I.tool_volume))
				user.visible_message("[user] destroys [cog] in [src]!", \
				"<span class='notice'>[cog] comes free with a clank and snaps in two as the machinery returns to normal!</span>")
				playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
				QDEL_NULL(cog)
			return
		else if(opened != APC_COVER_OFF) //cover isn't removed
			opened = APC_CLOSED
			coverlocked = TRUE //closing cover relocks it
			update_icon()
			return
	else if(!(stat & BROKEN)) // b) on closed and not broken APC
		if(coverlocked && !(stat & MAINT)) // locked...
			to_chat(user, "<span class='warning'>The cover is locked and cannot be opened!</span>")
			return
		else if(panel_open) // wires are exposed
			to_chat(user, "<span class='warning'>Exposed wires prevents you from opening it!</span>")
			return
		else
			opened = APC_OPENED
			update_icon()
	else if(stat & BROKEN)
		if(!opened)
			if(do_after(user, 3 SECONDS * I.toolspeed, src, DEFAULT_DOAFTER_IGNORE|DA_IGNORE_HELD_ITEM, category = DA_CAT_TOOL))
				to_chat(user, span_notice("You pry out broken frame."))
				opened = APC_COVER_OFF
				update_icon()

/obj/machinery/power/apc/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	else if(opened)
		if(cell && !(stat & MAINT))
			to_chat(user, "<span class='warning'>Close the APC first!</span>") //Less hints more mystery!
			return
		else
			if(electronics_state == APC_ELECTRONICS_INSTALLED)
				electronics_state = APC_ELECTRONICS_SECURED
				stat &= ~MAINT
				to_chat(user, "<span class='notice'>You screw the circuit electronics into place.</span>")
			else if(electronics_state == APC_ELECTRONICS_SECURED)
				electronics_state = APC_ELECTRONICS_INSTALLED
				stat |= MAINT
				to_chat(user, "<span class='notice'>You unfasten the electronics.</span>")
			else
				to_chat(user, "<span class='warning'>There is nothing to secure!</span>")
				return
			update_icon()
	else if(emagged)
		to_chat(user, "<span class='warning'>The interface is broken!</span>")
	else
		panel_open = !panel_open
		to_chat(user, "The wires have been [panel_open ? "exposed" : "unexposed"]")
		update_icon()


/obj/machinery/power/apc/wirecutter_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(panel_open && !opened)
		wires.Interact(user)
	else if(terminal && opened)
		terminal.dismantle(user, I)

/obj/machinery/power/apc/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(panel_open && !opened)
		wires.Interact(user)


/obj/machinery/power/apc/proc/togglelock(mob/living/user)
	if(emagged)
		to_chat(user, span_warning("The interface is broken!"))
		return FALSE
	if(opened)
		to_chat(user, span_warning("You must close the cover to swipe an ID card!"))
		return FALSE
	if(panel_open)
		to_chat(user, span_warning("You must close the panel!"))
		return FALSE
	if(stat & (BROKEN|MAINT))
		to_chat(user, span_warning("Nothing happens!"))
		return FALSE
	if(!allowed(user) || wires.is_cut(WIRE_IDSCAN) || malfhack)
		to_chat(user, span_warning("Access denied."))
		return FALSE
	locked = !locked
	to_chat(user, span_notice("You have [ locked ? "locked" : "unlocked"] the APC interface."))
	update_icon()
	return TRUE


/obj/machinery/power/apc/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(stat & BROKEN)
		return damage_amount
	. = ..()

/obj/machinery/power/apc/obj_break(damage_flag)
	if(!(obj_flags & NODECONSTRUCT))
		set_broken()


/obj/machinery/power/apc/proc/has_electronics()
	return electronics_state != APC_ELECTRONICS_NONE


/obj/machinery/power/apc/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		if(!(stat & BROKEN))
			set_broken()
		if(opened != APC_COVER_OFF)
			opened = APC_COVER_OFF
			coverlocked = FALSE
			visible_message("<span class='warning'>The APC cover is knocked down!</span>")
			update_icon()

/obj/machinery/power/apc/welder_act(mob/user, obj/item/I)
	if(!opened || has_electronics() || terminal)
		return
	. = TRUE
	if(!I.tool_use_check(user, 3))
		return
	WELDER_ATTEMPT_SLICING_MESSAGE
	if(I.use_tool(src, user, 50, amount = 3, volume = I.tool_volume))
		if((stat & BROKEN) || opened == APC_COVER_OFF)
			new /obj/item/stack/sheet/metal(loc)
			user.visible_message(\
				"[user.name] has cut [src] apart with [I].",\
				"<span class='notice'>You disassembled the broken APC frame.</span>")
		else
			new /obj/item/mounted/frame/apc_frame(loc)
			user.visible_message(\
				"[user.name] has cut [src] from the wall with [I].",\
				"<span class='notice'>You cut the APC frame from the wall.</span>")
		qdel(src)

/obj/machinery/power/apc/emag_act(mob/user)
	if(!(emagged || malfhack))		// trying to unlock with an emag card
		if(opened)
			if(user)
				to_chat(user, "You must close the cover to swipe an ID card.")
		else if(panel_open)
			if(user)
				to_chat(user, "You must close the panel first.")
		else if(stat & (BROKEN|MAINT))
			if(user)
				to_chat(user, "Nothing happens.")
		else
			add_attack_logs(user, src, "emagged")
			flick("apc-spark", src)
			emagged = 1
			locked = FALSE
			if(user)
				to_chat(user, "You emag the APC interface.")
			update_icon()

// attack with hand - remove cell (if cover open) or interact with the APC
/obj/machinery/power/apc/attack_hand(mob/user)
	if(!user)
		return

	add_fingerprint(user)

	if(usr == user && opened && (!issilicon(user) || istype(user.get_active_hand(), /obj/item/gripper)))
		if(cell)
			user.visible_message("<span class='warning'>[user.name] removes [cell] from [src]!", "You remove the [cell].</span>")
			cell.forceMove_turf()
			user.put_in_hands(cell, ignore_anim = FALSE)
			cell.add_fingerprint(user)
			cell.update_icon()
			cell = null
			charging = APC_NOT_CHARGING
			update_icon()
		return
	if(stat & (BROKEN|MAINT))
		return

	if(..())
		return TRUE

	interact(user)

/obj/machinery/power/apc/attack_ghost(mob/user)
	if(panel_open)
		wires.Interact(user)
	return ui_interact(user)

/obj/machinery/power/apc/interact(mob/user)
	if(!user)
		return

	if(panel_open)
		wires.Interact(user)

	return ui_interact(user)


/obj/machinery/power/apc/proc/get_malf_status(mob/living/silicon/ai/malf)
	if(!istype(malf))
		return FALSE

	// Only if they're a traitor OR they have the malf picker from the combat module
	if(!malf.mind?.has_antag_datum(/datum/antagonist/traitor) && !malf.malf_picker)
		return FALSE

	if(malfai == (malf.parent || malf))
		if(occupier == malf)
			return APC_MALF_SHUNTED_HERE
		else if(isapc(malf.loc))
			return APC_MALF_SHUNTED_OTHER
		else
			return APC_MALF_HACKED
	else
		return APC_MALF_NOT_HACKED

/obj/machinery/power/apc/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "APC", name)
		ui.open()

/obj/machinery/power/apc/ui_data(mob/user)
	var/list/data = list()
	data["locked"] = is_locked(user)
	data["normallyLocked"] = cog ? !isclocker(user) : locked
	data["isOperating"] = operating
	data["externalPower"] = main_status
	data["powerCellStatus"] = cell ? cell.percent() : null
	data["chargeMode"] = chargemode
	data["chargingStatus"] = charging
	data["totalLoad"] = round(last_used_equipment + last_used_lighting + last_used_environment)
	data["coverLocked"] = coverlocked
	data["siliconUser"] = istype(user, /mob/living/silicon)
	data["siliconLock"] = locked
	data["malfStatus"] = get_malf_status(user)
	data["nightshiftLights"] = nightshift_lights
	data["emergencyLights"] = !emergency_lights

	var/powerChannels[0]
	powerChannels[++powerChannels.len] = list(
		"title" = "Equipment",
		"powerLoad" = round(last_used_equipment),
		"status" = equipment_channel,
		"topicParams" = list(
			"auto" = list("eqp" = 3),
			"on"   = list("eqp" = 2),
			"off"  = list("eqp" = 1)
		)
	)
	powerChannels[++powerChannels.len] = list(
		"title" = "Lighting",
		"powerLoad" = round(last_used_lighting),
		"status" = lighting_channel,
		"topicParams" = list(
			"auto" = list("lgt" = 3),
			"on"   = list("lgt" = 2),
			"off"  = list("lgt" = 1)
		)
	)
	powerChannels[++powerChannels.len] = list(
		"title" = "Environment",
		"powerLoad" = round(last_used_environment),
		"status" = environment_channel,
		"topicParams" = list(
			"auto" = list("env" = 3),
			"on"   = list("env" = 2),
			"off"  = list("env" = 1)
		)
	)

	data["powerChannels"] = powerChannels

	return data

/obj/machinery/power/apc/ui_status(mob/user, datum/ui_state/state)
	if(aidisabled && (isAI(user) || isrobot(user)))
		to_chat(user, "<span class='warning'>AI control for \the [src] interface has been disabled.</span>")
		return UI_CLOSE
	. = ..()

/obj/machinery/power/apc/proc/report()
	return "[area.name] : [equipment_channel]/[lighting_channel]/[environment_channel] ([last_used_equipment+last_used_lighting+last_used_environment]) : [cell? cell.percent() : "N/C"] ([charging])"


/obj/machinery/power/apc/proc/update()
	if(operating && !shorted)
		area.power_light = (lighting_channel > CHANNEL_SETTING_AUTO_OFF)
		area.power_equip = (equipment_channel > CHANNEL_SETTING_AUTO_OFF)
		area.power_environ = (environment_channel > CHANNEL_SETTING_AUTO_OFF)
		if(lighting_channel)
			emergency_power = TRUE
			if(emergency_power_timer)
				deltimer(emergency_power_timer)
				emergency_power_timer = null
		else
			emergency_power_timer = addtimer(CALLBACK(src, PROC_REF(turn_emergency_power_off)), 10 MINUTES, TIMER_UNIQUE|TIMER_STOPPABLE)
	else
		area.power_light = FALSE
		area.power_equip = FALSE
		area.power_environ = FALSE
		emergency_power_timer = addtimer(CALLBACK(src, PROC_REF(turn_emergency_power_off)), 10 MINUTES, TIMER_UNIQUE|TIMER_STOPPABLE)
	area.power_change()


/obj/machinery/power/apc/proc/turn_emergency_power_off()
	emergency_power = FALSE
	for(var/obj/machinery/light as anything in area.lights_cache)
		INVOKE_ASYNC(light, TYPE_PROC_REF(/obj/machinery/light, update), FALSE)


/obj/machinery/power/apc/proc/can_use(mob/user) //used by attack_hand() and Topic()
	if(stat & BROKEN)
		return FALSE
	if(user.can_admin_interact())
		return TRUE

	autoflag = 5

	if(issilicon(user))
		if(ispAI(user))
			var/mob/living/silicon/pai/pAI = user
			if(!pAI.syndipai || !pAI.ai_capability || pAI.capa_is_cooldown)
				return FALSE
		if(aidisabled)
			return FALSE
		if(malfhack && istype(malfai))					// Malfhacked APC can be used...
			if(isAI(user))
				var/mob/living/silicon/ai/AI = user		// Only by its hacker...
				if(malfai != AI && malfai != AI.parent)
					return FALSE
			else if(!(user in malfai.connected_robots))	// Or by Malf's borg. No exception for other silicons.
				return FALSE

	else if(!in_range(src, user) || !isturf(loc))
		return FALSE

	var/mob/living/carbon/human/h_user = user
	if(ishuman(h_user))
		if(h_user.incapacitated() || HAS_TRAIT(h_user, TRAIT_HANDS_BLOCKED))
			return FALSE
		if(h_user.getBrainLoss() >= 60)
			h_user.visible_message(span_danger("[h_user] stares cluelessly at [src] and drools."))
			return FALSE
		else if(prob(h_user.getBrainLoss()))
			to_chat(user, span_danger("You momentarily forget how to use [src]."))
			return FALSE
	return TRUE

/obj/machinery/power/apc/proc/is_authenticated(mob/user)
	if(user.can_admin_interact())
		return TRUE
	if(isAI(user) || (isrobot(user) || user.has_unlimited_silicon_privilege) && !iscogscarab(user))
		return TRUE
	else
		return !locked

/obj/machinery/power/apc/proc/is_locked(mob/user)
	if(user.can_admin_interact())
		return FALSE
	if(isAI(user) || (isrobot(user) || user.has_unlimited_silicon_privilege) && !iscogscarab(user))
		return FALSE
	else
		return locked

/obj/machinery/power/apc/ui_act(action, params)
	if(..() || !can_use(usr) || (is_locked(usr) && (action != "toggle_nightshift")))
		return
	. = TRUE
	switch(action)
		if("lock")
			if(usr.has_unlimited_silicon_privilege)
				if(emagged || stat & BROKEN)
					to_chat(usr, "<span class='warning'>The APC does not respond to the command!</span>")
					return FALSE
				else
					locked = !locked
					update_icon()
			else
				to_chat(usr, "<span class='warning'>Access Denied!</span>")
				return FALSE
		if("cover")
			coverlocked = !coverlocked
		if("breaker")
			toggle_breaker(usr)
		if("toggle_nightshift")
			if(last_nightshift_switch > world.time + 100) // don't spam...
				to_chat(usr, "<span class='warning'>[src]'s night lighting circuit breaker is still cycling!</span>")
				return FALSE
			last_nightshift_switch = world.time
			set_nightshift(!nightshift_lights)
		if("charge")
			chargemode = !chargemode
		if("channel")
			if(params["eqp"])
				equipment_channel = setsubsystem(text2num(params["eqp"]))
				update_icon()
				update()
			else if(params["lgt"])
				lighting_channel = setsubsystem(text2num(params["lgt"]))
				update_icon()
				update()
			else if(params["env"])
				environment_channel = setsubsystem(text2num(params["env"]))
				update_icon()
				update()
		if("overload")
			if(usr.has_unlimited_silicon_privilege)
				INVOKE_ASYNC(src, TYPE_PROC_REF(/obj/machinery/power/apc, overload_lighting))
		if("hack")
			if(get_malf_status(usr))
				malfhack(usr)
		if("occupy")
			if(get_malf_status(usr))
				malfoccupy(usr)
		if("deoccupy")
			if(get_malf_status(usr))
				malfvacate()
		if("emergency_lighting")
			emergency_lights = !emergency_lights
			for(var/obj/machinery/light/light as anything in area.lights_cache)
				INVOKE_ASYNC(light, TYPE_PROC_REF(/obj/machinery/light, update), FALSE)
				CHECK_TICK


/obj/machinery/power/apc/proc/toggle_breaker(mob/user)
	operating = !operating
	update()
	update_icon()

/obj/machinery/power/apc/proc/malfhack(mob/living/silicon/ai/malf)
	if(!istype(malf))
		return
	if(get_malf_status(malf) != APC_MALF_NOT_HACKED)
		return
	if(malf.malfhacking)
		to_chat(malf, "You are already hacking an APC.")
		return
	to_chat(malf, "Beginning override of APC systems. This takes some time, and you cannot perform other actions during the process.")
	malf.malfhack = src
	malf.malfhacking = addtimer(CALLBACK(malf, TYPE_PROC_REF(/mob/living/silicon/ai, malfhacked), src), 600, TIMER_STOPPABLE)
	var/atom/movable/screen/alert/hackingapc/A
	A = malf.throw_alert("hackingapc", /atom/movable/screen/alert/hackingapc)
	A.target = src

/obj/machinery/power/apc/proc/malfoccupy(mob/living/silicon/ai/malf)
	if(!istype(malf))
		return
	if(isapc(malf.loc)) // Already in an APC
		to_chat(malf, "<span class='warning'>You must evacuate your current APC first!</span>")
		return
	if(!malf.can_shunt)
		to_chat(malf, "<span class='warning'>You cannot shunt!</span>")
		return
	if(!is_station_level(z))
		return
	occupier = new /mob/living/silicon/ai(src,malf.laws,null,1)
	occupier.adjustOxyLoss(malf.getOxyLoss())
	if(!findtext(occupier.name, "APC Copy"))
		occupier.name = "[malf.name] APC Copy"
	if(malf.parent)
		occupier.parent = malf.parent
	else
		occupier.parent = malf
	malf.shunted = 1
	malf.mind.transfer_to(occupier)
	occupier.eyeobj.name = "[occupier.name] (AI Eye)"
	if(malf.parent)
		qdel(malf)
	var/datum/action/innate/ai/return_to_core/R = new
	R.Grant(occupier)
	occupier.cancel_camera()
	if((seclevel2num(get_security_level()) == SEC_LEVEL_DELTA) && malf.nuking)
		for(var/obj/item/pinpointer/point in GLOB.pinpointer_list)
			point.the_disk = src //the pinpointer will detect the shunted AI

/obj/machinery/power/apc/proc/malfvacate(forced = FALSE)
	if(!occupier)
		return
	if(occupier.parent && occupier.parent.stat != DEAD)
		occupier.mind.transfer_to(occupier.parent)
		occupier.parent.shunted = 0
		occupier.parent.adjustOxyLoss(occupier.getOxyLoss())
		occupier.parent.cancel_camera()
		qdel(occupier)
		if(seclevel2num(get_security_level()) == SEC_LEVEL_DELTA)
			for(var/obj/item/pinpointer/point in GLOB.pinpointer_list)
				for(var/mob/living/silicon/ai/A in GLOB.ai_list)
					if((A.stat != DEAD) && A.nuking)
						point.the_disk = A //The pinpointer tracks the AI back into its core.
	else
		to_chat(occupier, "<span class='danger'>Primary core damaged, unable to return core processes.</span>")
		if(forced)
			occupier.loc = loc
			occupier.death()
			occupier.gib()
			for(var/obj/item/pinpointer/point in GLOB.pinpointer_list)
				point.the_disk = null //Pinpointers go back to tracking the nuke disk

/obj/machinery/power/apc/proc/ion_act()
	//intended to be exactly the same as an AI malf attack
	if(!malfhack && is_station_level(z))
		if(prob(3))
			locked = TRUE
			if(cell.charge > 0)
				cell.charge = 0
				cell.corrupt()
				malfhack = TRUE
				update_icon()
				var/datum/effect_system/fluid_spread/smoke/smoke = new
				smoke.set_up(amount = 3, location = loc)
				smoke.attach(src)
				smoke.start()
				do_sparks(3, 1, src)
				for(var/mob/M in viewers(src))
					M.show_message("<span class='danger'>The [name] suddenly lets out a blast of smoke and some sparks!", 3, "<span class='danger'>You hear sizzling electronics.</span>", 2)


/obj/machinery/power/apc/surplus()
	if(terminal)
		return terminal.surplus()
	else
		return 0

/obj/machinery/power/apc/add_load(amount)
	if(terminal && terminal.powernet)
		terminal.add_load(amount)

/obj/machinery/power/apc/avail()
	if(terminal)
		return terminal.avail()
	else
		return 0

/obj/machinery/power/apc/process()
	if(stat & (BROKEN|MAINT))
		return
	if(!area.requires_power)
		return

	last_used_lighting = area.usage(CHANNEL_STATIC_LIGHT)
	last_used_lighting += area.usage(LIGHT)
	last_used_equipment = area.usage(EQUIP)
	last_used_equipment += area.usage(CHANNEL_STATIC_EQUIP)
	last_used_environment = area.usage(ENVIRON)
	last_used_environment += area.usage(CHANNEL_STATIC_ENVIRON)
	area.clear_usage()

	last_used_total = last_used_lighting + last_used_equipment + last_used_environment

	//store states to update icon if any change
	var/last_lt = lighting_channel
	var/last_eq = equipment_channel
	var/last_en = environment_channel
	var/last_ch = charging

	var/excess = surplus()

	if(!avail())
		main_status = APC_EXTERNAL_POWER_NOTCONNECTED
	else if(excess < 0)
		main_status = APC_EXTERNAL_POWER_NOENERGY
	else
		main_status = APC_EXTERNAL_POWER_GOOD

	if(debug)
		log_debug("Status: [main_status] - Excess: [excess] - Last Equip: [last_used_equipment] - Last Light: [last_used_lighting] - Longterm: [longtermpower]")

	if(cell && !shorted)
		// draw power from cell as before to power the area
		var/cellused = min(cell.charge, GLOB.CELLRATE * last_used_total)	// clamp deduction to a max, amount left in cell
		cell.use(cellused)

		if(excess > last_used_total)		// if power excess recharge the cell
										// by the same amount just used
			cell.give(cellused)
			add_load(cellused/GLOB.CELLRATE)		// add the load used to recharge the cell


		else		// no excess, and not enough per-apc
			if((cell.charge/GLOB.CELLRATE + excess) >= last_used_total)		// can we draw enough from cell+grid to cover last usage?
				cell.charge = min(cell.maxcharge, cell.charge + GLOB.CELLRATE * excess)	//recharge with what we can
				add_load(excess)		// so draw what we can from the grid
				charging = APC_NOT_CHARGING

			else	// not enough power available to run the last tick!
				charging = APC_NOT_CHARGING
				chargecount = 0
				// This turns everything off in the case that there is still a charge left on the battery, just not enough to run the room.
				equipment_channel = autoset(equipment_channel, CHANNEL_SETTING_OFF)
				lighting_channel = autoset(lighting_channel, CHANNEL_SETTING_OFF)
				environment_channel = autoset(environment_channel, CHANNEL_SETTING_OFF)
				autoflag = APC_AUTOFLAG_ALL_OFF

		// Set channels depending on how much charge we have left

		// Allow the APC to operate as normal if the cell can charge
		if(charging != APC_NOT_CHARGING && longtermpower < 10)
			longtermpower += 1
		else if(longtermpower > -10)
			longtermpower -= 2

		handle_autoflag()

		// now trickle-charge the cell
		if(chargemode && charging == APC_IS_CHARGING && operating)
			if(excess > 0)		// check to make sure we have enough to charge
				// Max charge is capped to % per second constant
				var/ch = min(excess*GLOB.CELLRATE, cell.maxcharge*GLOB.CHARGELEVEL)
				add_load(ch/GLOB.CELLRATE) // Removes the power we're taking from the grid
				cell.give(ch) // actually recharge the cell

			else
				charging = APC_NOT_CHARGING		// stop charging
				chargecount = 0

		// show cell as fully charged if so
		if(cell.charge >= cell.maxcharge)
			cell.charge = cell.maxcharge
			charging = APC_FULLY_CHARGED

		if(chargemode)
			if(charging == APC_NOT_CHARGING)
				if(excess > cell.maxcharge*GLOB.CHARGELEVEL)
					chargecount++
				else
					chargecount = 0

				if(chargecount == 10)

					chargecount = 0
					charging = APC_IS_CHARGING

		else // chargemode off
			charging = APC_NOT_CHARGING
			chargecount = 0

		if(!shock_proof)
			handle_shock_chance(excess)

	else // no cell, switch everything off

		charging = APC_NOT_CHARGING
		chargecount = 0
		equipment_channel = autoset(equipment_channel, CHANNEL_SETTING_OFF)
		lighting_channel = autoset(lighting_channel, CHANNEL_SETTING_OFF)
		environment_channel = autoset(environment_channel, CHANNEL_SETTING_OFF)
		if(report_power_alarm)
			area.poweralert(FALSE, src)
		autoflag = APC_AUTOFLAG_ALL_OFF

	// update icon & area power if anything changed

	if(last_lt != lighting_channel || last_eq != equipment_channel || last_en != environment_channel)
		queue_icon_update()
		update()
	else if(last_ch != charging)
		queue_icon_update()

	handle_flicker()


/obj/machinery/power/apc/proc/handle_autoflag()
	if(cell.charge >= 1250 || longtermpower > 0)	// Put most likely at the top so we don't check it last, efficiency 101
		if(autoflag != APC_AUTOFLAG_ALL_ON)
			equipment_channel = autoset(equipment_channel, CHANNEL_SETTING_AUTO_OFF)
			lighting_channel = autoset(lighting_channel, CHANNEL_SETTING_AUTO_OFF)
			environment_channel = autoset(environment_channel, CHANNEL_SETTING_AUTO_OFF)
			autoflag = APC_AUTOFLAG_ALL_ON
			if(report_power_alarm)
				area.poweralert(TRUE, src)
		return

	if(cell.charge < 1250 && cell.charge > 750 && longtermpower < 0)	// <30%, turn off equipment
		if(autoflag != APC_AUTOFLAG_EQUIPMENT_OFF)
			equipment_channel = autoset(equipment_channel, CHANNEL_SETTING_ON)
			lighting_channel = autoset(lighting_channel, CHANNEL_SETTING_AUTO_OFF)
			environment_channel = autoset(environment_channel, CHANNEL_SETTING_AUTO_OFF)
			if(report_power_alarm)
				area.poweralert(FALSE, src)
			autoflag = APC_AUTOFLAG_EQUIPMENT_OFF

	else if(cell.charge < 750 && cell.charge > 10)	// <15%, turn off lighting & equipment
		if(autoflag > APC_AUTOFLAG_ENVIRO_ONLY)
			equipment_channel = autoset(equipment_channel, CHANNEL_SETTING_ON)
			lighting_channel = autoset(lighting_channel, CHANNEL_SETTING_OFF)
			environment_channel = autoset(environment_channel, CHANNEL_SETTING_AUTO_OFF)
			if(report_power_alarm)
				area.poweralert(FALSE, src)
			autoflag = APC_AUTOFLAG_ENVIRO_ONLY

	else if(cell.charge <= 0)	// zero charge, turn all off
		if(autoflag != APC_AUTOFLAG_ALL_OFF)
			equipment_channel = autoset(equipment_channel, CHANNEL_SETTING_OFF)
			lighting_channel = autoset(lighting_channel, CHANNEL_SETTING_OFF)
			environment_channel = autoset(environment_channel, CHANNEL_SETTING_OFF)
			if(report_power_alarm)
				area.poweralert(FALSE, src)
			autoflag = APC_AUTOFLAG_ALL_OFF


/// Handles APC arc'ing every APC process interval
/obj/machinery/power/apc/proc/handle_shock_chance(excess = 0)
	if(excess < 2500000)
		return

	var/shock_chance = excess >= 5000000 ? excess >= 7500000 ? 15 : 10 : 5

	if(prob(shock_chance))
		var/obj/machinery/light/picked_light = safepick(area.lights_cache)
		picked_light?.flicker()
		var/list/shock_mobs = list()
		for(var/mob/living/victim in view(get_turf(src), 5))
			shock_mobs += victim
		var/mob/living/victim = safepick(shock_mobs)	//We only want to shock a single random mob in range, not every one.
		if(victim)
			victim.electrocute_act(rand(5, 25), "электрической дуги")
			playsound(get_turf(victim), 'sound/effects/eleczap.ogg', 75, TRUE)
			Beam(victim, icon_state = "lightning[rand(1, 12)]", icon = 'icons/effects/effects.dmi', time = 5)


/obj/machinery/power/apc/proc/handle_flicker()
	if(prob(MACHINE_FLICKER_CHANCE))
		flicker()

	// lights don't have their own processing loop, so APCs will be the father they never had. 3x as likely to cause a light flicker in a particular area, pick a light to flicker at random
	if(prob(MACHINE_FLICKER_CHANCE) * 3)
		var/obj/machinery/light/picked_light = safepick(area.lights_cache)
		picked_light?.flicker()


/obj/machinery/power/apc/proc/autoset(current_setting, new_setting)
	switch(new_setting)
		if(CHANNEL_SETTING_OFF)
			if(current_setting == CHANNEL_SETTING_ON)	// if on, return off
				return CHANNEL_SETTING_OFF
			if(current_setting == CHANNEL_SETTING_AUTO_ON)	// if auto-on, return auto-off
				return CHANNEL_SETTING_AUTO_OFF

		if(CHANNEL_SETTING_AUTO_OFF)
			if(current_setting == CHANNEL_SETTING_AUTO_OFF)	// if auto-off, return auto-on
				return CHANNEL_SETTING_AUTO_ON

		if(CHANNEL_SETTING_ON)
			if(current_setting == CHANNEL_SETTING_AUTO_ON)	// if auto-on, return auto-off
				return CHANNEL_SETTING_AUTO_OFF

	return current_setting	//if setting is not changed, just keep current setting


// damage and destruction acts

/obj/machinery/power/apc/emp_act(severity)
	if(cell)
		cell.emp_act(severity)
	if(occupier)
		occupier.emp_act(severity)
	lighting_channel = CHANNEL_SETTING_OFF
	equipment_channel = CHANNEL_SETTING_OFF
	environment_channel = CHANNEL_SETTING_OFF
	update_icon()
	update()
	addtimer(CALLBACK(src, PROC_REF(emp_callback)), 60 SECONDS)
	..()


/obj/machinery/power/apc/proc/emp_callback()
	equipment_channel = CHANNEL_SETTING_AUTO_ON
	environment_channel = CHANNEL_SETTING_AUTO_ON
	update_icon()
	update()


/obj/machinery/power/apc/blob_act(obj/structure/blob/B)
	set_broken()

/obj/machinery/power/apc/disconnect_terminal()
	if(terminal)
		terminal.master = null
		terminal = null

/obj/machinery/power/apc/proc/set_broken()
	if(malfai && operating)
		malfai.malf_picker.processing_time = clamp(malfai.malf_picker.processing_time - 10,0,1000)
	stat |= BROKEN
	operating = FALSE
	if(occupier)
		malfvacate(forced = TRUE)
	update_icon()
	update()

// overload all the lights in this APC area

/obj/machinery/power/apc/proc/overload_lighting(chance = 100)
	if(!operating || shorted)
		return
	if(cell && cell.charge >= 20)
		cell.use(20)
		for(var/L in area.lights_cache)
			var/obj/machinery/light/light = L
			if(prob(chance))
				light.break_light_tube(0, 1)
				CHECK_TICK

/obj/machinery/power/apc/proc/null_charge()
	for(var/L in area.lights_cache)
		var/obj/machinery/light/light = L
		light.break_light_tube(0, 1)
		CHECK_TICK

/obj/machinery/power/apc/proc/setsubsystem(val)
	if(cell && cell.charge > 0)
		return (val==1) ? 0 : val
	else if(val == 3)
		return 1
	else
		return 0

/obj/machinery/power/apc/proc/set_nightshift(on)
	set waitfor = FALSE
	nightshift_lights = on
	for(var/L in area.lights_cache)
		var/obj/machinery/light/light = L
		if(light.nightshift_allowed)
			light.nightshift_enabled = nightshift_lights
			light.update(FALSE)
		CHECK_TICK

/obj/machinery/power/apc/proc/relock_callback()
	locked = TRUE
	updateDialog()

/obj/machinery/power/apc/proc/check_main_power_callback()
	if(!wires.is_cut(WIRE_MAIN_POWER1) && !wires.is_cut(WIRE_MAIN_POWER2))
		shorted = FALSE
		updateDialog()

/obj/machinery/power/apc/proc/check_ai_control_callback()
	if(!wires.is_cut(WIRE_AI_CONTROL))
		aidisabled = FALSE
		updateDialog()


#undef UPSTATE_CELL_IN
#undef UPSTATE_OPENED1
#undef UPSTATE_OPENED2
#undef UPSTATE_MAINT
#undef UPSTATE_BROKE
#undef UPSTATE_BLUESCREEN
#undef UPSTATE_WIREEXP
#undef UPSTATE_ALLGOOD

#undef APC_UPOVERLAY_CHARGEING0
#undef APC_UPOVERLAY_CHARGEING1
#undef APC_UPOVERLAY_CHARGEING2
#undef APC_UPOVERLAY_EQUIPMENT0
#undef APC_UPOVERLAY_EQUIPMENT1
#undef APC_UPOVERLAY_EQUIPMENT2
#undef APC_UPOVERLAY_LIGHTING0
#undef APC_UPOVERLAY_LIGHTING1
#undef APC_UPOVERLAY_LIGHTING2
#undef APC_UPOVERLAY_ENVIRON0
#undef APC_UPOVERLAY_ENVIRON1
#undef APC_UPOVERLAY_ENVIRON2
#undef APC_UPOVERLAY_LOCKED

#undef APC_UPDATE_ICON_COOLDOWN

#undef APC_EXTERNAL_POWER_NOTCONNECTED
#undef APC_EXTERNAL_POWER_NOENERGY
#undef APC_EXTERNAL_POWER_GOOD

#undef APC_MALF_NOT_HACKED
#undef APC_MALF_HACKED
#undef APC_MALF_SHUNTED_HERE
#undef APC_MALF_SHUNTED_OTHER

#undef CHANNEL_SETTING_OFF
#undef CHANNEL_SETTING_AUTO_OFF
#undef CHANNEL_SETTING_ON
#undef CHANNEL_SETTING_AUTO_ON

#undef APC_CLOSED
#undef APC_OPENED
#undef APC_COVER_OFF

#undef APC_AUTOFLAG_ALL_OFF
#undef APC_AUTOFLAG_ENVIRO_ONLY
#undef APC_AUTOFLAG_EQUIPMENT_OFF
#undef APC_AUTOFLAG_ALL_ON

#undef APC_ELECTRONICS_NONE
#undef APC_ELECTRONICS_INSTALLED
#undef APC_ELECTRONICS_SECURED

