/obj/machinery/door/window
	name = "interior door"
	desc = "A strong door."
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "left"
	layer = ABOVE_WINDOW_LAYER
	closingLayer = ABOVE_WINDOW_LAYER
	resistance_flags = ACID_PROOF
	visible = 0
	flags = ON_BORDER
	obj_flags = BLOCKS_CONSTRUCTION_DIR
	pass_flags_self = PASSGLASS
	opacity = FALSE
	dir = EAST
	set_dir_on_move = FALSE
	max_integrity = 150 //If you change this, consider changing ../door/window/brigdoor/ max_integrity at the bottom of this .dm file
	integrity_failure = 0
	armor = list("melee" = 20, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 70, "acid" = 100)
	var/obj/item/access_control/electronics
	var/base_state = "left"
	var/reinf = 0
	var/cancolor = TRUE
	var/shards = 2
	var/rods = 2
	var/cable = 1
	var/list/debris = list()


/obj/machinery/door/window/Initialize(mapload, set_dir)
	. = ..()
	if(set_dir)
		setDir(set_dir)
	if(length(req_access))
		icon_state = "[icon_state]"
		base_state = icon_state
	if(!color && cancolor)
		color = color_windows(src)
	for(var/i in 1 to shards)
		debris += new /obj/item/shard(src)
	if(rods)
		debris += new /obj/item/stack/rods(src, rods)
	if(cable)
		debris += new /obj/item/stack/cable_coil(src, cable)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_exit),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/obj/machinery/door/window/Destroy()
	set_density(FALSE)
	QDEL_LIST(debris)
	if(obj_integrity == 0)
		playsound(src, "shatter", 70, 1)
	QDEL_NULL(electronics)
	return ..()


/obj/machinery/door/window/examine(mob/user)
	. = ..()
	if(emagged)
		. += span_warning("Its access panel is smoking slightly.")
	if(HAS_TRAIT(src, TRAIT_CMAGGED))
		. += span_warning("The access panel is coated in yellow ooze...")

/obj/machinery/door/window/emp_act(severity)
	. = ..()
	if(prob(20 / severity))
		INVOKE_ASYNC(src, PROC_REF(open))

/obj/machinery/door/window/proc/open_and_close()
	set waitfor = FALSE
	open()
	if(check_access(null))
		sleep(50)
	else //secure doors close faster
		sleep(20)
	close()

/obj/machinery/door/window/Bumped(atom/movable/moving_atom, skip_effects = TRUE)
	. = ..()
	if(operating || !density)
		return .
	if(!ismob(moving_atom))
		if(ismecha(moving_atom))
			var/obj/mecha/mecha = moving_atom
			if(mecha.occupant && allowed(mecha.occupant))
				if(HAS_TRAIT(src, TRAIT_CMAGGED))
					cmag_switch(FALSE)
					return
				open_and_close()
			else
				if(HAS_TRAIT(src, TRAIT_CMAGGED))
					cmag_switch(TRUE)
					return
				INVOKE_ASYNC(src, PROC_REF(do_animate), "deny")
		return
	if(!SSticker)
		return
	var/mob/living/M = moving_atom
	if(!HAS_TRAIT(M, TRAIT_HANDS_BLOCKED) && M.mob_size > MOB_SIZE_TINY && (!(isrobot(M) && M.stat)))
		bumpopen(M)


/obj/machinery/door/window/bumpopen(mob/user)
	if(operating || !density)
		return
	add_fingerprint(user)
	if(!requiresID() || allowed(user))
		if(HAS_TRAIT(src, TRAIT_CMAGGED))
			cmag_switch(FALSE, user)
			return
		open_and_close()
	else
		if(HAS_TRAIT(src, TRAIT_CMAGGED))
			cmag_switch(TRUE, user)
			return
		INVOKE_ASYNC(src, PROC_REF(do_animate), "deny")


/obj/machinery/door/window/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(.)
		return TRUE

	if(border_dir == dir)
		return FALSE

	if(isobj(mover))
		var/obj/object = mover
		if(object.obj_flags & BLOCKS_CONSTRUCTION_DIR)
			var/obj/structure/window/window = object
			var/fulltile = istype(window) ? window.fulltile : FALSE
			if(!valid_build_direction(loc, object.dir, is_fulltile = fulltile))
				return FALSE

	return TRUE


/obj/machinery/door/window/CanAtmosPass(turf/T, vertical)
	if(get_dir(loc, T) == dir)
		return !density
	else
		return 1


/obj/machinery/door/window/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	return !density || (dir != to_dir) || (check_access_list(pass_info.access) && hasPower() && !pass_info.no_id)


/obj/machinery/door/window/proc/on_exit(datum/source, atom/movable/leaving, atom/newLoc)
	SIGNAL_HANDLER

	if(leaving.movement_type & PHASING)
		return

	if(leaving == src)
		return // Let's not block ourselves.

	if(leaving.pass_flags == PASSEVERYTHING || (pass_flags_self & leaving.pass_flags) || ((pass_flags_self & LETPASSTHROW) && leaving.throwing))
		return

	if(density && dir == get_dir(leaving, newLoc))
		leaving.Bump(src)
		return COMPONENT_ATOM_BLOCK_EXIT


/obj/machinery/door/window/update_icon_state()
	switch(operating)
		if(DOOR_OPENING)
			icon_state = "[base_state]open"
		if(DOOR_CLOSING)
			icon_state = base_state
		else
			icon_state = "[base_state][density ? "" : "open"]"

	SSdemo.mark_dirty(src)

/obj/machinery/door/window/open(forced=0)

	if(operating) //doors can still open when emag-disabled
		return FALSE
	if(!forced && !hasPower())
		return FALSE
	if(forced < 2 && emagged)
		return FALSE
	if(!operating) //in case of emag
		operating = DOOR_OPENING
	INVOKE_ASYNC(src, PROC_REF(do_animate), "opening")
	set_opacity(FALSE)
	playsound(loc, 'sound/machines/windowdoor.ogg', 100, 1)
	update_icon()
	sleep(1 SECONDS)

	set_density(FALSE)

	air_update_turf(TRUE)
	update_freelook_sight()

	if(operating) //emag again
		operating = NONE
	return TRUE


/obj/machinery/door/window/close(forced = 0)
	if(operating)
		return FALSE
	if(!forced && !hasPower())
		return FALSE
	if(forced < 2 && emagged)
		return FALSE
	operating = DOOR_CLOSING
	INVOKE_ASYNC(src, PROC_REF(do_animate), "closing")
	playsound(loc, 'sound/machines/windowdoor.ogg', 100, TRUE)

	set_density(TRUE)
	update_icon()
	air_update_turf(TRUE)
	update_freelook_sight()
	sleep(1 SECONDS)

	operating = NONE
	return TRUE


/obj/machinery/door/window/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src, 'sound/effects/glasshit.ogg', 90, TRUE)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 100, TRUE)

/obj/machinery/door/window/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT) && !disassembled)
		for(var/obj/fragment in debris)
			fragment.forceMove(get_turf(src))
			transfer_fingerprints_to(fragment)
			debris -= fragment

		if(!electronics)
			electronics = new(loc)
			electronics.selected_accesses = length(req_access) ? req_access : list()
			electronics.one_access = check_one_access
		else
			electronics.forceMove(loc)
		if(emagged)
			electronics.emag_act()
		electronics = null

	qdel(src)

/obj/machinery/door/window/narsie_act()
	color = NARSIE_WINDOW_COLOUR

/obj/machinery/door/window/ratvar_act()
	var/obj/machinery/door/window/clockwork/C = new(loc, dir)
	C.name = name
	qdel(src)

/obj/machinery/door/window/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > T0C + (reinf ? 1600 : 800))
		take_damage(round(exposed_volume / 200), BURN, 0, 0)

/obj/machinery/door/window/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/door/window/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)

/obj/machinery/door/window/attack_hand(mob/living/carbon/human/user)
	if(user.a_intent == INTENT_HARM && ishuman(user) && (user.dna.species.obj_damage + user.physiology.punch_obj_damage > 0))
		add_fingerprint(user)
		user.changeNext_move(CLICK_CD_MELEE)
		attack_generic(user, user.dna.species.obj_damage + user.physiology.punch_obj_damage)
		return
	return try_to_activate_door(user)

/obj/machinery/door/window/emag_act(mob/user)
	if(!operating && density && !emagged)
		add_attack_logs(user, src, "emagged")
		emagged = TRUE
		operating = TRUE
		flick("[base_state]spark", src)
		playsound(src, "sparks", 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		sleep(6)
		operating = FALSE
		open(2)
		return 1

/obj/machinery/door/window/cmag_act(mob/user)
	if(operating || !density || HAS_TRAIT(src, TRAIT_CMAGGED) || emagged)
		return
	ADD_TRAIT(src, TRAIT_CMAGGED, CMAGGED)
	operating = TRUE
	flick("[base_state]spark", src)
	playsound(src, "sparks", 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	sleep(6)
	operating = FALSE
	return TRUE


/obj/machinery/door/window/attackby(obj/item/I, mob/living/user, params)
	//If it's in the process of opening/closing, ignore the click
	if(operating)
		add_fingerprint(user)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/machinery/door/window/screwdriver_act(mob/user, obj/item/I)
	if(obj_flags & NODECONSTRUCT)
		return
	. = TRUE
	if(density || operating)
		to_chat(user, span_warning("You need to open the door to access the maintenance panel!"))
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	panel_open = !panel_open
	to_chat(user, span_notice("You [panel_open ? "open":"close"] the maintenance panel of the [src.name]."))


/obj/machinery/door/window/crowbar_act(mob/user, obj/item/I)
	if(operating)
		return
	if(obj_flags & NODECONSTRUCT)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(panel_open && !density && !operating)
		user.visible_message(span_warning("[user] removes the electronics from the [name]."), \
							 "You start to remove electronics from the [name]...")
		if(I.use_tool(src, user, 40, volume = I.tool_volume))
			if(panel_open && !density && !operating && loc)
				var/obj/structure/windoor_assembly/WA = new /obj/structure/windoor_assembly(loc)
				switch(base_state)
					if("left")
						WA.facing = "l"
					if("right")
						WA.facing = "r"
					if("leftsecure")
						WA.facing = "l"
						WA.secure = TRUE
					if("rightsecure")
						WA.facing = "r"
						WA.secure = TRUE
				WA.set_anchored(TRUE)
				WA.state= "02"
				WA.setDir(dir)
				WA.ini_dir = dir
				WA.update_icon()
				WA.created_name = name

				to_chat(user, span_notice("You remove the airlock electronics."))

				if(!electronics)
					electronics = new(loc)
					electronics.selected_accesses = length(req_access) ? req_access : list()
					electronics.one_access = check_one_access
				else
					electronics.forceMove(loc)
				if(emagged)
					electronics.emag_act()
				electronics = null

				qdel(src)
	else
		try_to_crowbar(user, I)

/obj/machinery/door/window/try_to_crowbar(mob/user, obj/item/I)
	if(!hasPower())
		if(density)
			open(2)
		else
			close(2)
	else
		to_chat(user, span_warning("The door's motors resist your efforts to force it!"))

/obj/machinery/door/window/do_animate(animation)
	switch(animation)
		if("opening")
			flick("[base_state]opening", src)
		if("closing")
			flick("[base_state]closing", src)
		if("deny")
			flick("[base_state]deny", src)

/obj/machinery/door/window/brigdoor
	name = "secure door"
	icon_state = "leftsecure"
	base_state = "leftsecure"
	max_integrity = 300 //Stronger doors for prison (regular window door health is 200)
	reinf = 1
	explosion_block = 1
	var/id = null

/obj/machinery/door/window/brigdoor/security/cell
	name = "cell door"
	desc = "For keeping in criminal scum."
	req_access = list(ACCESS_BRIG)

/obj/machinery/door/window/clockwork
	name = "brass windoor"
	desc = "A thin door with translucent brass paneling."
	icon_state = "clockwork"
	base_state = "clockwork"
	shards = 0
	rods = 0
	resistance_flags = ACID_PROOF | FIRE_PROOF
	cancolor = FALSE
	var/made_glow = FALSE


/obj/machinery/door/window/clockwork_fake
	name = "brass windoor"
	desc = "A completely not magical thin door with translucent brass paneling."
	icon_state = "clockwork"
	base_state = "clockwork"
	shards = 0
	rods = 0
	resistance_flags = ACID_PROOF | FIRE_PROOF
	cancolor = FALSE


/obj/machinery/door/window/clockwork/Initialize(mapload, set_dir)
	. = ..()
	debris += new/obj/item/stack/sheet/brass(src, 2)


/obj/machinery/door/window/clockwork_fake/Initialize(mapload, set_dir)
	. = ..()
	debris += new/obj/item/stack/sheet/brass_fake(src, 2)


/obj/machinery/door/window/clockwork/setDir(newdir)
	if(!made_glow)
		var/obj/effect/E = new /obj/effect/temp_visual/ratvar/door/window(get_turf(src))
		E.setDir(newdir)
		made_glow = TRUE
	return ..()


/obj/machinery/door/window/clockwork/emp_act(severity)
	if(prob(80/severity))
		open()

/obj/machinery/door/window/clockwork/ratvar_act()
	obj_integrity = max_integrity

/obj/machinery/door/window/clockwork/hasPower()
	return TRUE //yup that's power all right

/obj/machinery/door/window/clockwork/narsie_act()
	take_damage(rand(30, 60), BRUTE)
	if(src)
		var/previouscolor = color
		color = COLOR_CULT_RED
		animate(src, color = previouscolor, time = 8)

/obj/machinery/door/window/northleft
	dir = NORTH

/obj/machinery/door/window/eastleft
	dir = EAST

/obj/machinery/door/window/westleft
	dir = WEST

/obj/machinery/door/window/southleft
	dir = SOUTH

/obj/machinery/door/window/northright
	dir = NORTH
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/eastright
	dir = EAST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/westright
	dir = WEST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/southright
	dir = SOUTH
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/brigdoor/northleft
	dir = NORTH

/obj/machinery/door/window/brigdoor/eastleft
	dir = EAST

/obj/machinery/door/window/brigdoor/westleft
	dir = WEST

/obj/machinery/door/window/brigdoor/southleft
	dir = SOUTH

/obj/machinery/door/window/brigdoor/northright
	dir = NORTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/eastright
	dir = EAST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/westright
	dir = WEST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/southright
	dir = SOUTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/security/cell/northleft
	dir = NORTH

/obj/machinery/door/window/brigdoor/security/cell/eastleft
	dir = EAST

/obj/machinery/door/window/brigdoor/security/cell/westleft
	dir = WEST

/obj/machinery/door/window/brigdoor/security/cell/southleft
	dir = SOUTH

/obj/machinery/door/window/brigdoor/security/cell/northright
	dir = NORTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/security/cell/eastright
	dir = EAST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/security/cell/westright
	dir = WEST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/security/cell/southright
	dir = SOUTH
	icon_state = "rightsecure"
	base_state = "rightsecure"
