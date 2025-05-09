#define GHOST_CAN_REENTER 1
#define GHOST_IS_OBSERVER 2

GLOBAL_LIST_EMPTY(ghost_images)

GLOBAL_VAR_INIT(observer_default_invisibility, INVISIBILITY_OBSERVER)

/mob/dead/observer
	name = "ghost"
	desc = "It's a g-g-g-g-ghooooost!" //jinkies!
	icon = 'icons/mob/mob.dmi'
	icon_state = "ghost"
	layer = GHOST_LAYER
	plane = GHOST_PLANE
	stat = DEAD
	movement_type = GROUND|FLYING
	density = FALSE
	blocks_emissive = FALSE // Ghosts are transparent, duh
	alpha = 127
	move_resist = INFINITY	//  don't get pushed around
	light_system = NO_LIGHT_SUPPORT
	invisibility = INVISIBILITY_OBSERVER
	pass_flags = PASSEVERYTHING
	hud_type = /datum/hud/ghost
	var/can_reenter_corpse
	var/bootime = FALSE
	var/started_as_observer //This variable is set to 1 when you enter the game as an observer.
							//If you died in the game and are a ghsot - this will remain as null.
							//Note that this is not a reliable way to determine if admins started as observers, since they change mobs a lot.
	universal_speak = TRUE
	var/image/ghostimage = null //this mobs ghost image, for deleting and stuff
	var/ghostvision = TRUE //is the ghost able to see things humans can't?
	var/seedarkness = TRUE
	var/sightchanged = FALSE
	/// Defines from __DEFINES/hud.dm go here based on which huds the ghost has activated.
	var/list/data_hud_seen = list()
	var/ghost_orbit = GHOST_ORBIT_CIRCLE
	///does the ghost have health scanner mode on? by default it should be off
	var/health_scan = FALSE
	///does the ghost have gas scanner mode on? by default it should be off
	var/gas_scan = FALSE
	///does the ghost have plant scanner mode on? by default it should be off
	var/plant_analyzer = FALSE
	var/datum/orbit_menu/orbit_menu

/mob/dead/observer/New(mob/body=null, flags=1)
	set_invisibility(GLOB.observer_default_invisibility)

	add_sight(SEE_TURFS|SEE_MOBS|SEE_OBJS|SEE_SELF)
	set_invis_see(SEE_INVISIBLE_OBSERVER_AI_EYE)
	add_verb(src, list(
		/mob/dead/observer/proc/dead_tele,
		/mob/dead/observer/proc/open_spawners_menu,
		/mob/dead/observer/proc/emote_spin_ghost,
		/mob/dead/observer/proc/emote_flip_ghost,
		/mob/dead/observer/proc/open_minigames_menu,
	))

	// Our new boo spell.
	AddSpell(new /obj/effect/proc_holder/spell/boo(null))

	can_reenter_corpse = flags & GHOST_CAN_REENTER
	started_as_observer = flags & GHOST_IS_OBSERVER

	set_stat(DEAD)

	var/turf/T
	if(ismob(body))
		T = get_turf(body)				//Where is the body located?

		var/mutable_appearance/MA = copy_appearance(body)
		if(body.mind && body.mind.name)
			MA.name = body.mind.name
		else if(body.real_name)
			MA.name = body.real_name
		else
			if(gender == MALE)
				MA.name = capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names))
			else
				MA.name = capitalize(pick(GLOB.first_names_female)) + " " + capitalize(pick(GLOB.last_names_female))

		mind = body.mind	//we don't transfer the mind but we keep a reference to it.
		appearance = MA

	ghostimage = image(icon = icon, loc = src, icon_state = icon_state)
	ghostimage.overlays = overlays
	ghostimage.dir = dir
	ghostimage.appearance_flags |= KEEP_TOGETHER
	ghostimage.alpha = alpha
	underlays.Cut() //Save no underlay lighting on mob
	appearance_flags |= KEEP_TOGETHER
	GLOB.ghost_images |= ghostimage
	updateallghostimages()
	if(!T)
		T = pick(GLOB.latejoin)			//Safety in case we cannot find the body's position

	if(!name)							//To prevent nameless ghosts
		name = capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names))
	real_name = name

	//starts ghosts off with all HUDs.
	show_me_the_hud(THOUGHTS_HUD)
	toggle_all_huds_on(body)
	RegisterSignal(src, COMSIG_MOB_HUD_CREATED, PROC_REF(set_ghost_darkness_level)) //something something don't call this until we have a HUD
	..()
	abstract_move(T) //let ghost initialize properly, then off to spawn point


/mob/dead/observer/Destroy()
	toggle_all_huds_off()
	UnregisterSignal(src, COMSIG_MOB_HUD_CREATED)
	if(ghostimage)
		GLOB.ghost_images -= ghostimage
		QDEL_NULL(ghostimage)
		updateallghostimages()
	if(orbit_menu)
		SStgui.close_uis(orbit_menu)
		QDEL_NULL(orbit_menu)
	return ..()

/mob/dead/observer/examine(mob/user)
	. = ..()
	if(!invisibility)
		. += "<span class='notice'>It seems extremely obvious.</span>"

/mob/dead/observer/proc/set_ghost_darkness_level()
	if(!client)
		return
	UnregisterSignal(src, COMSIG_MOB_HUD_CREATED)
	lighting_alpha = client.prefs.ghost_darkness_level //Remembers ghost lighting pref
	update_sight()

/mob/dead/observer/proc/cleanup_observe()
	client?.perspective = initial(client.perspective)
	set_sight(SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF)

// This seems stupid, but it's the easiest way to avoid absolutely ridiculous shit from happening
// Copying an appearance directly from a mob includes it's verb list, it's invisibility, it's alpha, and it's density
// You might recognize these things as "fucking ridiculous to put in an appearance"
// You'd be right, but that's fucking BYOND for you.
/mob/dead/observer/proc/copy_appearance(mutable_appearance/COPY)
	var/mutable_appearance/MA = new(src)

	MA.appearance_flags = COPY.appearance_flags
	MA.blend_mode = COPY.blend_mode
	MA.color = COPY.color
	MA.dir = COPY.dir
	MA.icon = COPY.icon
	MA.icon_state = COPY.icon_state
	MA.layer = COPY.layer
	MA.maptext = COPY.maptext
	MA.maptext_width = COPY.maptext_width
	MA.maptext_height = COPY.maptext_height
	MA.maptext_x = COPY.maptext_x
	MA.maptext_y = COPY.maptext_y
	MA.mouse_opacity = COPY.mouse_opacity
	MA.overlays = COPY.overlays
	if(!isicon(MA.icon) && !LAZYLEN(MA.overlays)) // Gibbing/dusting/melting removes the icon before ghostize()ing the mob, so we need to account for that
		MA.icon = initial(icon)
		MA.icon_state = initial(icon_state)
	MA.underlays = COPY.underlays
	MA.layer = GHOST_LAYER
	MA.plane = GAME_PLANE
	. = MA

/*
Transfer_mind is there to check if mob is being deleted/not going to have a body.
Works together with spawning an observer, noted above.
*/
/mob/dead/proc/assess_targets(list/target_list, mob/dead/observer/U)
	var/client/C = U.client
	for(var/mob/living/carbon/human/target in target_list)
		C.images += target.hud_list[SPECIALROLE_HUD]
	for(var/mob/living/silicon/target in target_list)
		C.images += target.hud_list[SPECIALROLE_HUD]
	return 1

/mob/proc/ghostize(flags = GHOST_CAN_REENTER)
	if(key)
		if(GLOB.non_respawnable_keys[ckey])
			flags &= ~GHOST_CAN_REENTER

		var/mob/dead/observer/ghost = new(src, flags)	//Transfer safety to observer spawning proc.
		if(client)
			client.mouse_pointer_icon = initial(client.mouse_pointer_icon) //Возвращает курсор в изначальное положение (после меха, нинзи, спелла и т.п)

		ghost.timeofdeath = src.timeofdeath //BS12 EDIT
		GLOB.respawnable_list -= src

		if(ghost.can_reenter_corpse)
			GLOB.respawnable_list += ghost
		else
			GLOB.non_respawnable_keys[ckey] = 1

		ghost.key = key
		ghost.client?.init_verbs()
		SEND_SIGNAL(src, COMSIG_MOB_GHOSTIZE, ghost)
		return ghost

/mob/proc/ManualFollow(atom/movable/target)
	if(!target)
		return FALSE

	if(!isobserver(src)) // parent calls
		var/mob/dead/observer/observer = ghostize()

		if(!observer)
			return FALSE

		observer.ManualFollow(target)

	return TRUE

/*
This is the proc mobs get to turn into a ghost. Forked from ghostize due to compatibility issues.
*/
/mob/living/verb/ghost()
	set category = "OOC"
	set name = "Ghost"
	set desc = "Relinquish your life and enter the land of the dead."

	var/warningmsg = null
	var/obj/machinery/cryopod/P = istype(loc, /obj/machinery/cryopod) && loc

	if(frozen)
		to_chat(src, span_warning("Вы не можете сделать этого, пока находитесь под действием админфриза."))
		message_admins("[key_name_admin(src)] tried to ghost while admin frozen")
		return

	if(P)
		if(TOO_EARLY_TO_GHOST)
			warningmsg = "It's too early in the shift to enter cryo"
	else if(suiciding && TOO_EARLY_TO_GHOST)
		warningmsg = "You have committed suicide too early in the round"
	else if(stat != DEAD)
		warningmsg = "You are alive"
		if(isAI(src))
			warningmsg = "You are a living AI! You should probably use OOC -> Wipe Core instead."
	else if(GLOB.non_respawnable_keys[ckey])
		warningmsg = "You have lost your right to respawn"

	if(warningmsg)
		var/response
		var/alertmsg = "Are you -sure- you want to ghost?\n([warningmsg]. If you ghost now, you probably won't be able to rejoin the round! You can't change your mind, so choose wisely!)"
		response = tgui_alert(src, alertmsg, "Ghost", list("Stay in body", "Ghost"))
		if(response != "Ghost")
			return

	if(stat == CONSCIOUS)
		if(!is_admin_level(z))
			player_ghosted = 1
		if(mind && mind.special_role)
			message_admins("[key_name_admin(src)] has ghosted while alive, with special_role: [mind.special_role]")

	if(warningmsg)
		// Not respawnable
		var/mob/dead/observer/ghost = ghostize(0)	// 0 parameter stops them re-entering their body
		ghost?.timeofdeath = world.time	// Because the living mob won't have a time of death and we want the respawn timer to work properly.
	else
		// Respawnable
		ghostize(1)

	// If mob in cryopod, despawn mob
	if(P)
		if(!P.control_computer)
			P.find_control_computer(urgent=1)
		if(P.control_computer)
			P.despawn_occupant()
	return

// Ghosts have no momentum, being massless ectoplasm
/mob/dead/observer/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	return TRUE


/mob/dead/observer/Move(atom/newloc, direct = NONE, glide_size_override = DEFAULT_GLIDE_SIZE, update_dir = TRUE)
	// only update dir if we actually need it, so overlays won't spin on base sprites that don't have directions of their own
	if(update_dir)
		setDir(direct)
		ghostimage.setDir(dir)

	if(glide_size_override && glide_size_override != glide_size)
		set_glide_size(glide_size_override)

	if(newloc)
		abstract_move(newloc)
	else
		var/turf/destination = get_turf(src)

		if((direct & NORTH) && y < world.maxy)
			destination = get_step(destination, NORTH)

		else if((direct & SOUTH) && y > 1)
			destination = get_step(destination, SOUTH)

		if((direct & EAST) && x < world.maxx)
			destination = get_step(destination, EAST)

		else if((direct & WEST) && x > 1)
			destination = get_step(destination, WEST)

		abstract_move(destination)//Get out of closets and such as a ghost


/mob/dead/observer/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	status_tab_data[++status_tab_data.len] = list("Respawnability:", "[(src in GLOB.respawnable_list) ? "Yes" : "No"]")

/mob/dead/observer/verb/reenter_corpse()
	set category = "Ghost"
	set name = "Re-enter Corpse"
	if(!client)
		return FALSE
	if(!mind || QDELETED(mind.current))
		to_chat(src, "<span class='warning'>You have no body.</span>")
		return FALSE
	if(!can_reenter_corpse)
		to_chat(src, "<span class='warning'>You cannot re-enter your body.</span>")
		return FALSE
	if(mind.current.key && copytext(mind.current.key,1,2)!="@")	//makes sure we don't accidentally kick any clients
		to_chat(usr, "<span class='warning'>Another consciousness is in your body...It is resisting you.</span>")
		return FALSE

	mind.current.key = key

	SEND_SIGNAL(mind.current, COMSIG_LIVING_REENTERED_BODY)

	return TRUE


/mob/dead/observer/proc/notify_cloning(var/message, var/sound, var/atom/source)
	if(message)
		to_chat(src, "<span class='ghostalert'>[message]</span>")
		if(source)
			var/atom/movable/screen/alert/A = throw_alert("\ref[source]_notify_cloning", /atom/movable/screen/alert/notify_cloning)
			if(A)
				if(client && client.prefs && client.prefs.UI_style)
					A.icon = ui_style2icon(client.prefs.UI_style)
				A.desc = message
				var/old_layer = source.layer
				var/old_plane = source.plane
				source.layer = FLOAT_LAYER
				source.plane = FLOAT_PLANE
				A.add_overlay(source)
				source.layer = old_layer
				source.plane = old_plane
	to_chat(src, "<span class='ghostalert'><a href=?src=[UID()];reenter=1>(Click to re-enter)</a></span>")
	if(sound)
		src << sound(sound)

/mob/dead/observer/proc/show_me_the_hud(hud_index)
	var/datum/atom_hud/H = GLOB.huds[hud_index]
	H.add_hud_to(src)
	data_hud_seen |= hud_index

/mob/dead/observer/proc/remove_the_hud(hud_index) //remove old huds
	var/datum/atom_hud/H = GLOB.huds[hud_index]
	data_hud_seen -= hud_index
	H.remove_hud_from(src)

/mob/dead/observer/verb/open_hud_panel()
	set category = "Ghost"
	set name = "Ghost HUD Panel"
	if(!client)
		return
	GLOB.ghost_hud_panel.ui_interact(src)

/mob/dead/observer/proc/toggle_all_huds_on(mob/user)
	show_me_the_hud(DATA_HUD_DIAGNOSTIC)
	show_me_the_hud(DATA_HUD_SECURITY_ADVANCED)
	show_me_the_hud(DATA_HUD_MEDICAL_ADVANCED)
	if(!check_rights((R_ADMIN | R_MOD), FALSE, user))
		return
	antagHUD = TRUE
	for(var/datum/atom_hud/antag/H in GLOB.huds)
		H.add_hud_to(src)

/**
 * Toggles off all HUDs for the ghost player.
 */
/mob/dead/observer/proc/toggle_all_huds_off()
	remove_the_hud(DATA_HUD_DIAGNOSTIC_ADVANCED)
	remove_the_hud(DATA_HUD_SECURITY_ADVANCED)
	remove_the_hud(DATA_HUD_MEDICAL_ADVANCED)
	antagHUD = FALSE
	for(var/datum/atom_hud/antag/H in GLOB.huds)
		H.remove_hud_from(src)

/mob/dead/observer/verb/set_dnr()
	set name = "Set DNR"
	set category = "Ghost"
	set desc = "Предотвращает возрождение вашего персонажа."

	if(!isobserver(src)) // Somehow
		return

	if(!can_reenter_corpse)
		to_chat(src, span_warning("У вас уже стоит DNR!"))
		return

	if(!mind || QDELETED(mind.current))
		to_chat(src, span_warning("У вас нету тела."))
		return

	if(mind.current.stat != DEAD)
		to_chat(src, span_warning("Твое тело все ещё живо!"))
		return

	if(tgui_alert(src, "Если вы включите это, ваше тело не смогут больше возродить до конца раунда.", "Вы уверены?", list("Да", "Нет")) != "Да")
		return

	apply_dnr()
	to_chat(src, span_boldnotice("Do Not Revive статус включён."))

/mob/dead/observer/proc/apply_dnr()
	can_reenter_corpse = FALSE

	if(!QDELETED(mind.current)) // Could change while they're choosing
		mind.current.med_hud_set_status()

	SEND_SIGNAL(mind.current, COMSIG_LIVING_SET_DNR)

/mob/dead/observer/proc/dead_tele()
	set category = "Ghost"
	set name = "Teleport"
	set desc= "Teleport to a location"

	if(!isobserver(usr))
		to_chat(usr, "Not when you're not dead!")
		return
	var/target = tgui_input_list(usr, "Area to teleport to", "Teleport to a location", GLOB.ghostteleportlocs)
	if(!target)
		return
	var/area/A = GLOB.ghostteleportlocs[target]
	teleport(A)

/mob/dead/observer/proc/teleport(area/A)
	if(!A || !isobserver(usr))
		return

	var/list/turfs = list()
	for(var/turf/T in get_area_turfs(A.type))
		turfs += T

	if(!length(turfs))
		to_chat(src, "<span class='warning'>Nowhere to jump to!</span>")
		return
	forceMove(pick(turfs))
	update_parallax_contents()

/mob/dead/observer/verb/follow()
	set category = "Ghost"
	set name = "Orbit" // "Haunt"
	set desc = "Follow and orbit a mob."

	if(!orbit_menu)
		orbit_menu = new(src)

	orbit_menu.ui_interact(src)

// TODO: Remove this verb when "True-Observing" be merged.
/mob/dead/observer/verb/toggle_sight_view()
	set category = "Ghost"
	set name = "Toggle Sight"
	set desc = "Переключает вашу возможность видеть сквозь стены."

	sightchanged = !sightchanged

	if(sightchanged)
		if(orbiting && ismob(orbiting))
			var/mob/living/new_sight = orbiting
			set_sight(new_sight.client? new_sight.sight : set_sight(NONE))
		else
			set_sight(null)
	else
		set_sight(SEE_TURFS|SEE_MOBS|SEE_OBJS|SEE_SELF)

// This is the ghost's follow verb with an argument
/mob/dead/observer/ManualFollow(atom/movable/target)
	. = ..()

	if(!.)
		return

	if(!get_turf(target))
		return

	if(target != src)
		if(orbiting && orbiting == target)
			return

		var/icon/I = icon(target.icon,target.icon_state,target.dir)

		var/orbitsize = (I.Width()+I.Height())*0.5

		if(orbitsize == 0)
			orbitsize = 40

		orbitsize -= (orbitsize/world.icon_size)*(world.icon_size*0.25)

		var/rot_seg

		switch(ghost_orbit)
			if(GHOST_ORBIT_TRIANGLE)
				rot_seg = 3
			if(GHOST_ORBIT_SQUARE)
				rot_seg = 4
			if(GHOST_ORBIT_PENTAGON)
				rot_seg = 5
			if(GHOST_ORBIT_HEXAGON)
				rot_seg = 6
			else //Circular
				rot_seg = 36 //360/10 bby, smooth enough aproximation of a circle

		to_chat(src, span_notice("Now following [target]"))
		orbit(target, orbitsize, FALSE, 20, rot_seg, forceMove = TRUE)

/mob/dead/observer/orbit(atom/A, radius, clockwise, rotation_speed, rotation_segments, pre_rotation, lockinorbit, forceMove)
	setDir(2)//reset dir so the right directional sprites show up
	return ..()

/mob/dead/observer/verb/jumptomob() //Moves the ghost instead of just changing the ghosts's eye -Nodrak
	set category = "Ghost"
	set name = "Jump to Mob"
	set desc = "Teleport to a mob"

	if(isobserver(usr)) //Make sure they're an observer!
		var/jumping = tgui_input_list(src, "Mob to jump to", "Jump to Mob", GLOB.mob_list)
		if(jumping)
			return jump_to_mob(jumping)

/mob/dead/observer/proc/jump_to_mob(mob/M)
	if(!M || !isobserver(usr))
		return
	var/mob/A = src			 //Source mob
	var/turf/T = get_turf(M) //Turf of the destination mob

	if(T && isturf(T))	//Make sure the turf exists, then move the source to that destination.
		A.forceMove(T)
		M.update_parallax_contents()
		return
	to_chat(A, "This mob is not located in the game world.")


/mob/dead/observer/memory()
	set hidden = 1
	to_chat(src, "<span class='warning'>You are dead! You have no mind to store memory!</span>")

/mob/dead/observer/add_memory()
	set hidden = 1
	to_chat(src, "<span class='warning'>You are dead! You have no mind to store memory!</span>")


/mob/dead/observer/verb/toggle_health_scan()
	set name = "Toggle Health Scan"
	set desc = "Toggles whether you health-scan living beings on click"
	set category = "Ghost"

	if(health_scan) //remove old huds
		to_chat(src, "<span class='notice'>Health scan disabled.</span>")
		health_scan = FALSE
	else
		to_chat(src, "<span class='notice'>Health scan enabled.</span>")
		health_scan = TRUE

/mob/dead/observer/verb/toggle_gas_scan()
	set name = "Toggle Gas Scan"
	set desc = "Toggles whether you analyze gas contents on click"
	set category = "Ghost"

	if(gas_scan)
		to_chat(src, span_notice("Gas scan disabled."))
		gas_scan = FALSE
	else
		to_chat(src, span_notice("Gas scan enabled."))
		gas_scan = TRUE

/mob/dead/observer/verb/toggle_plant_anaylzer()
	set name = "Toggle Plant Analyzer"
	set desc = "Toggles wether you can anaylze plants and seeds on click"
	set category = "Ghost"

	if(plant_analyzer)
		to_chat(src, "<span class='notice'>Plant Analyzer disabled.</span>")
		plant_analyzer = FALSE
	else
		to_chat(src, "<span class='notice'>Plant Analyzer enabled. Click on a plant or seed to analyze.</span>")
		plant_analyzer = TRUE

/mob/dead/observer/verb/view_manifest()
	set name = "View Crew Manifest"
	set category = "Ghost"
	GLOB.generic_crew_manifest.ui_interact(usr)


//this is called when a ghost is drag clicked to something.
/mob/dead/observer/MouseDrop(atom/over_object, src_location, over_location, src_control, over_control, params)
	if(!usr || !over_object)
		return FALSE

	if(isobserver(usr) && usr.client?.holder?.cmd_ghost_drag(src, over_object))
		return FALSE

	return ..()


/proc/ghost_follow_link(var/atom/target, var/atom/ghost)
	if((!target) || (!ghost)) return
	if(isAI(target)) // AI core/eye follow links
		var/mob/living/silicon/ai/A = target
		. = "<a href='byond://?src=[ghost.UID()];follow=[A.UID()]'>core</a>"
		if(A.client && A.eyeobj) // No point following clientless AI eyes
			. += "|<a href='byond://?src=[ghost.UID()];follow=[A.eyeobj.UID()]'>eye</a>"
		return
	else if(istype(target, /mob/dead/observer))
		var/mob/dead/observer/O = target
		. = "<a href='byond://?src=[ghost.UID()];follow=[target.UID()]'>follow</a>"
		if(O.mind && O.mind.current)
			. += "|<a href='byond://?src=[ghost.UID()];follow=[O.mind.current.UID()]'>body</a>"
		return
	else
		return "<a href='byond://?src=[ghost.UID()];follow=[target.UID()]'>follow</a>"

//BEGIN TELEPORT HREF CODE
/mob/dead/observer/Topic(href, href_list)
	if(usr != src)
		return

	if(href_list["track"])
		var/atom/target = locate(href_list["track"])
		if(target)
			ManualFollow(target)

	if(href_list["follow"])
		var/atom/target = locate(href_list["follow"])
		if(target)
			ManualFollow(target)

	if(href_list["jump"])
		var/mob/target = locate(href_list["jump"])
		var/mob/A = usr
		to_chat(A, "Teleporting to [target]...")
		//var/mob/living/silicon/ai/A = locate(href_list["track2"]) in GLOB.mob_list
		if(target && target != usr)
			spawn(0)
				var/turf/pos = get_turf(A)
				var/turf/T=get_turf(target)
				if(T != pos)
					if(!T)
						return
					if(!client)
						return
					forceMove(T)

	if(href_list["reenter"])
		reenter_corpse()

	..()
//END TELEPORT HREF CODE

/mob/dead/observer/proc/do_observe(mob/mob_eye)
	if(isnewplayer(mob_eye))
		stack_trace("/mob/dead/new_player: \[[mob_eye]\] is being observed by [key_name(src)]. This should never happen and has been blocked.")
		message_admins("[ADMIN_LOOKUPFLW(src)] attempted to observe someone in the lobby: [ADMIN_LOOKUPFLW(mob_eye)]. This should not be possible and has been blocked.")
		return

	//Istype so we filter out points of interest that are not mobs
	if(!client || !mob_eye || !istype(mob_eye) || isobserver(mob_eye))
		cleanup_observe()
		return

	if(is_admin_level(mob_eye.z) && !client?.holder)
		set_sight(NONE) //we dont want ghosts to see through walls in secret areas

	if(!mob_eye.hud_used)
		return

	RegisterSignal(src, COMSIG_ORBITER_ORBIT_STOP,PROC_REF(handle_when_autoobserve_move), TRUE)
	RegisterSignal(mob_eye, COMSIG_MOB_UPDATE_SIGHT, PROC_REF(handle_when_autoobserve_sight_updated), TRUE)

	client.set_eye(mob_eye)
	set_sight(mob_eye.sight)

	client.clear_screen()
	LAZYOR(mob_eye.orbiters, src)
	mob_eye.hud_used.show_hud(mob_eye.hud_used.hud_version, src)

	for(var/datum/action/act in mob_eye.actions)
		if( istype(act.button, /atom/movable/screen/movable/action_button/hide_toggle) || \
			(act in src.actions))
			continue
		client.screen += act.button

	//An ingenious way to block access to the button. Yes, it's on the screen, but you can't press it.
//	for(var/atom/movable/screen/movable/action_button/button in client.screen)
//		button.mosue_opacity = 0

/mob/dead/observer/proc/handle_when_autoobserve_move()
	SIGNAL_HANDLER  // COMSIG_ORBITER_ORBIT_STOP

	reset_perspective(null)
	cleanup_observe()
	lighting_alpha = client?.prefs.ghost_darkness_level //Remembers ghost lighting pref
	update_sight()
	LAZYREMOVE(orbiting?.orbiters, src)

	clear_fullscreens()

	if(src) // If player discconnected
		UnregisterSignal(src, COMSIG_ORBITER_ORBIT_STOP)
	if(orbiting != null)
		UnregisterSignal(orbiting, COMSIG_MOB_UPDATE_SIGHT)

/mob/dead/observer/proc/handle_when_autoobserve_sight_updated()
	SIGNAL_HANDLER  // COMSIG_MOB_UPDATE_SIGHT

	var/mob/mob_eye = orbiting
	sight = mob_eye?.sight
	lighting_alpha = mob_eye?.lighting_alpha
	update_sight()

/mob/dead/observer/verb/toggle_ghostsee()
	set name = "Toggle Ghost Vision"
	set desc = "Toggles your ability to see things only ghosts can see, like other ghosts"
	set category = "Ghost"
	ghostvision = !(ghostvision)
	update_sight()
	to_chat(usr, "You [(ghostvision?"now":"no longer")] have ghost vision.")

/mob/dead/observer/verb/pick_darkness()
	set name = "Pick Darkness"
	set desc = "Choose how much darkness you want to see."
	set category = "Ghost"
	var/list/ghost_darkness_levels = list("Strong Darkness" = LIGHTING_PLANE_ALPHA_VISIBLE,
											"Darkness" = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE,
											"Light Darkness" = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE,
											"No Darkness" = LIGHTING_PLANE_ALPHA_INVISIBLE)
	var/desired_dark = tgui_input_list(usr, "Choose how much darkness you want to see", "Pick darkness", ghost_darkness_levels)
	if(isnull(desired_dark))
		return
	if(!client)
		return
	client.prefs.ghost_darkness_level = ghost_darkness_levels[desired_dark]
	client.prefs.save_preferences(src)
	lighting_alpha = client.prefs.ghost_darkness_level
	update_sight()

/mob/dead/observer/update_sight()
	if (!ghostvision)
		set_invis_see(SEE_INVISIBLE_LIVING)
	else
		set_invis_see(SEE_INVISIBLE_OBSERVER)

	updateghostimages()
	. = ..()

/mob/dead/observer/proc/updateghostsight()
	if(!seedarkness)
		set_invis_see(SEE_INVISIBLE_OBSERVER_NOLIGHTING)
	else
		set_invis_see(SEE_INVISIBLE_OBSERVER)
		if(!ghostvision)
			set_invis_see(SEE_INVISIBLE_LIVING)

	updateghostimages()

/proc/updateallghostimages()
	for(var/mob/dead/observer/O in GLOB.player_list)
		O.updateghostimages()

/mob/dead/observer/proc/updateghostimages()
	if(!client)
		return
	if(seedarkness || !ghostvision)
		client.images -= GLOB.ghost_images
	else
		//add images for the 60inv things ghosts can normally see when darkness is enabled so they can see them now
		client.images |= GLOB.ghost_images
		if(ghostimage)
			client.images -= ghostimage //remove ourself

/mob/proc/can_admin_interact()
	return FALSE

/mob/proc/can_advanced_admin_interact()
	return FALSE

/mob/dead/observer/can_admin_interact()
	return check_rights(R_ADMIN, 0, src)

/mob/dead/observer/can_advanced_admin_interact()
	if(!can_admin_interact())
		return FALSE

	if(client && client.advanced_admin_interaction)
		return TRUE

	return FALSE

/mob/dead/observer/incapacitated(ignore_flags)
	return TRUE


/**
 * This is a mob verb instead of atom for performance reasons.
 * See /mob/verb/examinate() in mob.dm for more info.
 * Overriden here and in /mob/living for different point span classes and sanity checks.
 */
/mob/dead/observer/run_pointed(atom/target)
	if(!..())
		return FALSE
	var/follow_link
	if(invisibility) // Only show the button if the ghost is not visible to the living
		follow_link = " ([ghost_follow_link(target, src)])"
	usr.visible_message(span_deadsay("<b>[src]</b> points to [target][follow_link]."))
	add_deadchat_logs(src, "point to [key_name(target)] [COORD(target)]")
	return TRUE


/mob/dead/observer/proc/incarnate_ghost(use_old_mind=FALSE)
	if(!client)
		return

	var/mob/living/carbon/human/new_char = new(get_turf(src))
	client.prefs.copy_to(new_char)
	if(mind && use_old_mind)
		mind.active = TRUE
		mind.transfer_to(new_char)
	else
		new_char.key = key

	return new_char

/mob/dead/observer/can_perform_action(atom/movable/target, action_bitflags)
	return can_advanced_admin_interact()

/mob/dead/observer/is_literate()
	return TRUE

/mob/dead/observer/proc/set_invisibility(value)
	invisibility = value
	if(!value)
		set_light_range(1)
		set_light_power(2)
	else
		set_light_on(FALSE)


/mob/dead/observer/vv_edit_var(var_name, var_value)
	switch(var_name)
		if(NAMEOF(src, invisibility))
			set_invisibility(var_value)	// updates light
			. = TRUE

	if(!isnull(.))
		datum_flags |= DF_VAR_EDITED
		return .

	return ..()


/proc/set_observer_default_invisibility(amount, message=null)
	for(var/mob/dead/observer/G in GLOB.player_list)
		G.set_invisibility(amount)
		if(message)
			to_chat(G, message)
	GLOB.observer_default_invisibility = amount

/mob/dead/observer/proc/open_spawners_menu()
	set name = "Mob spawners menu"
	set desc = "See all currently available ghost spawners"
	set category = "Ghost"

	var/datum/spawners_menu/menu = new /datum/spawners_menu(src)
	menu.ui_interact(src)

/mob/dead/observer/proc/open_minigames_menu()
	set name = "Mini games menu"
	set desc = "See all currently available mini games"
	set category = "Ghost"

	var/datum/minigames_explorer = new /datum/minigames_explorer(src)
	minigames_explorer.ui_interact(src)

