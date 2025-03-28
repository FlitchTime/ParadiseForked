/*Contains:
	Rapid Pipe Dispenser
*/

#define RPD_COOLDOWN_TIME		4 //How long should we have to wait between dispensing pipes?
#define RPD_WALLBUILD_TIME		40 //How long should drilling into a wall take?
#define RPD_MENU_ROTATE "Rotate pipes" //Stuff for radial menu
#define RPD_MENU_FLIP "Flip pipes" //Stuff for radial menu
#define RPD_MENU_DELETE "Delete pipes" //Stuff for radial menu
#define RPD_MENU_WRENCH "Toggle auto-wrenching"

/obj/item/rpd
	name = "rapid pipe dispenser"
	desc = "This device can rapidly dispense atmospherics and disposals piping, manipulate loose piping, and recycle any detached pipes it is applied to."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rpd"
	righthand_file = 'icons/mob/inhands/tools_righthand.dmi'
	lefthand_file = 'icons/mob/inhands/tools_lefthand.dmi'
	flags = CONDUCT
	force = 10
	throwforce = 10
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL = 75000, MAT_GLASS = 37500)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 50)
	resistance_flags = FIRE_PROOF
	origin_tech = "engineering=4;materials=2"
	var/datum/effect_system/spark_spread/spark_system
	var/lastused
	var/iconrotation = 0 //Used to orient icons and pipes
	var/mode = RPD_ATMOS_MODE //Disposals, atmospherics, etc.
	var/pipe_category = RPD_ATMOS_PIPING //For TGUI menus, this is a subtype of pipes e.g. scrubbers pipes, devices
	var/whatpipe = PIPE_SIMPLE_STRAIGHT //What kind of atmos pipe is it?
	var/whatdpipe = PIPE_DISPOSALS_STRAIGHT //What kind of disposals pipe is it?
	var/spawndelay = RPD_COOLDOWN_TIME
	var/walldelay = RPD_WALLBUILD_TIME
	var/ranged = FALSE
	var/primary_sound = 'sound/machines/click.ogg'
	var/alt_sound = null
	var/obj/item/wrench/integrated_wrench = new
	var/auto_wrench = FALSE

	//Lists of things
	var/list/mainmenu = list(
		list("category" = "Atmospherics", "mode" = RPD_ATMOS_MODE, "icon" = "wrench"),
		list("category" = "Disposals", "mode" = RPD_DISPOSALS_MODE, "icon" = "recycle"),
		list("category" = "Rotate", "mode" = RPD_ROTATE_MODE, "icon" = "sync-alt"),
		list("category" = "Flip", "mode" = RPD_FLIP_MODE, "icon" = "arrows-alt-h"),
		list("category" = "Recycle", "mode" = RPD_DELETE_MODE, "icon" = "trash"))
	var/list/pipemenu = list(
		list("category" = "Normal", "pipemode" = RPD_ATMOS_PIPING),
		list("category" = "Supply", "pipemode" = RPD_SUPPLY_PIPING),
		list("category" = "Scrubber", "pipemode" = RPD_SCRUBBERS_PIPING),
		list("category" = "Devices", "pipemode" = RPD_DEVICES),
		list("category" = "Heat exchange", "pipemode" = RPD_HEAT_PIPING))


/obj/item/rpd/Initialize(mapload)
	. = ..()
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(1, 0, src)
	spark_system.attach(src)

/obj/item/rpd/Destroy()
	QDEL_NULL(spark_system)
	return ..()

/obj/item/rpd/bluespace
	name = "bluespace rapid pipe dispenser"
	desc = "This device can rapidly dispense atmospherics and disposals piping, manipulate loose piping, and recycle any detached pipes it is applied to, at any range."
	icon_state = "brpd"
	materials = list(MAT_METAL = 75000, MAT_GLASS = 37500, MAT_SILVER = 3000)
	origin_tech = "engineering=4;materials=2;bluespace=3"
	ranged = TRUE
	primary_sound = 'sound/items/PSHOOM.ogg'
	alt_sound = 'sound/items/PSHOOM_2.ogg'

//Procs

/obj/item/rpd/proc/activate_rpd(delay) //Maybe makes sparks and activates cooldown if there is a delay
	if(alt_sound && prob(3))
		playsound(src, alt_sound, 50, 1)
	else
		playsound(src, primary_sound, 50, 1)
	if(prob(15) && !ranged)
		spark_system.start()
	if(delay)
		lastused = world.time

/obj/item/rpd/proc/can_dispense_pipe(var/pipe_id, var/pipe_type) //Returns TRUE if this is a legit pipe we can dispense, otherwise returns FALSE
	for(var/list/L in GLOB.rpd_pipe_list)
		if(pipe_type != L["pipe_type"]) //Sometimes pipes in different categories have the same pipe_id, so we need to skip anything not in the category we want
			continue
		if(pipe_id == L["pipe_id"]) //Found the pipe, we can dispense it
			return TRUE

/obj/item/rpd/proc/create_atmos_pipe(mob/user, turf/T) //Make an atmos pipe, meter, or gas sensor
	if(!can_dispense_pipe(whatpipe, RPD_ATMOS_MODE))
		log_runtime(EXCEPTION("Failed to spawn [get_pipe_name(whatpipe, PIPETYPE_ATMOS)] - possible tampering detected")) //Damn dirty apes -- I mean hackers
		return
	var/obj/item/pipe/P
	if(whatpipe == PIPE_GAS_SENSOR)
		P = new /obj/item/pipe_gsensor(T)
	else if(whatpipe == PIPE_METER)
		P = new /obj/item/pipe_meter(T)
	else
		P = new(T, whatpipe, iconrotation) //Make the pipe, BUT WAIT! There's more!
		if(!iconrotation && P.is_bent_pipe()) //Automatically rotates dispensed pipes if the user selected auto-rotation
			P.dir = turn(user.dir, 135)
		else if(!iconrotation && (P.pipe_type in list(PIPE_CONNECTOR, PIPE_UVENT, PIPE_SCRUBBER, PIPE_HEAT_EXCHANGE, PIPE_CAP, PIPE_SUPPLY_CAP, PIPE_SCRUBBERS_CAP, PIPE_INJECTOR, PIPE_PASV_VENT))) //Some pipes dispense oppositely to what you'd expect, but we don't want to do anything if they selected a direction
			P.dir = turn(user.dir, -180)
		else if(iconrotation && P.is_bent_pipe()) //If user selected a rotation and the pipe is bent
			P.dir = turn(iconrotation, -45)
		else if(!iconrotation) //If user selected a rotation
			P.dir = user.dir
	to_chat(user, "<span class='notice'>[src] rapidly dispenses [P]!</span>")
	activate_rpd(TRUE)
	if(auto_wrench)
		P.wrench_act(user, integrated_wrench)

/obj/item/rpd/proc/create_disposals_pipe(mob/user, turf/T) //Make a disposals pipe / construct
	if(!can_dispense_pipe(whatdpipe, RPD_DISPOSALS_MODE))
		log_runtime(EXCEPTION("Failed to spawn [get_pipe_name(whatdpipe, PIPETYPE_DISPOSAL)] - possible tampering detected"))
		return
	var/rotate_dir = iconrotation ? iconrotation : user.dir
	var/obj/structure/disposalconstruct/construct = new(T, whatdpipe, rotate_dir)
	to_chat(user, span_notice("[src] rapidly dispenses the [construct.pipename]!"))
	activate_rpd(TRUE)
	if(auto_wrench)
		construct.wrench_act(user, integrated_wrench)

/obj/item/rpd/proc/rotate_all_pipes(mob/user, turf/T) //Rotate all pipes on a turf
	for(var/obj/item/pipe/P in T)
		P.rotate()
	for(var/obj/structure/disposalconstruct/D in T)
		D.rotate()

/obj/item/rpd/proc/flip_all_pipes(mob/user, turf/T) //Flip all pipes on a turf
	for(var/obj/item/pipe/P in T)
		P.flip()
	for(var/obj/structure/disposalconstruct/D in T)
		D.flip()

/obj/item/rpd/proc/delete_all_pipes(mob/user, turf/T) //Delete all pipes on a turf
	var/eaten
	for(var/obj/item/pipe/P in T)
		QDEL_NULL(P)
		eaten = TRUE
	for(var/obj/item/pipe_gsensor/G in T)
		QDEL_NULL(G)
		eaten = TRUE
	for(var/obj/item/pipe_meter/M in T)
		QDEL_NULL(M)
		eaten = TRUE
	for(var/obj/structure/disposalconstruct/D in T)
		if(!D.anchored)
			QDEL_NULL(D)
			eaten = TRUE
	if(eaten)
		to_chat(user, "<span class='notice'>[src] sucks up the loose pipes on [T].")
		activate_rpd()
	else
		to_chat(user, "<span class='notice'>There were no loose pipes on [T].</span>")

/obj/item/rpd/proc/delete_single_pipe(mob/user, obj/P) //Delete a single pipe
	to_chat(user, "<span class='notice'>[src] sucks up [P].</span>")
	QDEL_NULL(P)
	activate_rpd()

// TGUI stuff

/obj/item/rpd/attack_self(mob/user)
	ui_interact(user)

/obj/item/rpd/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/rpd/ui_interact(mob/user, datum/tgui/ui = null)
	user.set_machine(src)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RPD", name)
		ui.open()

/obj/item/rpd/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/rpd)
	)

/obj/item/rpd/click_alt(mob/living/user)
	radial_menu(user)
	return CLICK_ACTION_SUCCESS

/obj/item/rpd/ui_data(mob/user)
	var/list/data = list()
	data["iconrotation"] = iconrotation
	data["mainmenu"] = mainmenu
	data["mode"] = mode
	data["pipelist"] = GLOB.rpd_pipe_list
	data["pipemenu"] = pipemenu
	data["pipe_category"] = pipe_category
	data["whatdpipe"] = whatdpipe
	data["whatpipe"] = whatpipe
	data["auto_wrench"] = auto_wrench
	return data

/obj/item/rpd/ui_act(action, list/params)
	if(..())
		return

	. = TRUE

	switch(action)
		if("iconrotation")
			if(isnum(params["iconrotation"]))
				iconrotation = params["iconrotation"]
		if("whatpipe")
			if(isnum(params["whatpipe"]))
				whatpipe = params["whatpipe"]
		if("whatdpipe")
			if(isnum(params["whatdpipe"]))
				whatdpipe = params["whatdpipe"]
		if("pipe_category")
			if(isnum(params["pipe_category"]))
				pipe_category = params["pipe_category"]
		if("mode")
			if(isnum(params["mode"]))
				mode = params["mode"]
		if("auto_wrench")
			auto_wrench = !auto_wrench

//RPD radial menu
/obj/item/rpd/proc/check_menu(mob/living/user)
	if(!istype(user))
		return
	if(user.incapacitated())
		return
	if(loc != user)
		return
	return TRUE

/obj/item/rpd/proc/radial_menu(mob/user)
	if(!check_menu(user))
		to_chat(user, "<span class='notice'>You can't do that right now!</span>")
		return
	var/list/choices = list(
		RPD_MENU_ROTATE = image(icon = 'icons/obj/interface.dmi', icon_state = "rpd_rotate"),
		RPD_MENU_FLIP = image(icon = 'icons/obj/interface.dmi', icon_state = "rpd_flip"),
		RPD_MENU_DELETE = image(icon = 'icons/obj/interface.dmi', icon_state = "rpd_delete"),
		RPD_MENU_WRENCH = image(icon = 'icons/obj/tools.dmi', icon_state = "wrench"),
		"UI" = image(icon = 'icons/obj/interface.dmi', icon_state = "ui_interact")
	)
	var/selected_mode = show_radial_menu(user, src, choices, custom_check = CALLBACK(src, PROC_REF(check_menu), user))
	if(!check_menu(user))
		return
	if(selected_mode == "UI")
		ui_interact(user)
	else
		switch(selected_mode)
			if(RPD_MENU_ROTATE)
				mode = RPD_ROTATE_MODE
			if(RPD_MENU_FLIP)
				mode = RPD_FLIP_MODE
			if(RPD_MENU_DELETE)
				mode = RPD_DELETE_MODE
			if(RPD_MENU_WRENCH)
				auto_wrench = !auto_wrench
				to_chat(user, "<span class='notice'>You [auto_wrench ? "enable" : "disable"] auto-wrenching new-placed pipes.</span>")
				return
			else
				return //Either nothing was selected, or an invalid mode was selected
		to_chat(user, "<span class='notice'>You set [src]'s mode.</span>")

/obj/item/rpd/afterattack(atom/target, mob/user, proximity, params)
	..()
	if(loc != user)
		return
	if(!proximity && !ranged)
		return
	if(world.time < lastused + spawndelay)
		return
	if(ranged && !(target in view(user)))
		return

	var/turf/T = get_turf(target)
	if(target != T)
		// We only check the rpd_act of the target if it isn't the turf, because otherwise
		// (A) blocked turfs can be acted on, and (B) unblocked turfs get acted on twice.
		if(target.rpd_act(user, src) == TRUE)
			// If the object we are clicking on has a valid RPD interaction for just that specific object, do that and nothing else.
			// Example: clicking on a pipe with a RPD in rotate mode should rotate that pipe and ignore everything else on the tile.
			if(ranged)
				user.Beam(T, icon_state="rped_upgrade", icon='icons/effects/effects.dmi', time=5)
			return

	// If we get this far, we have to check every object in the tile, to make sure that none of them block RPD usage on this tile.
	// This is done by calling rpd_blocksusage on every /obj in the tile. If any block usage, fail at this point.

	for(var/obj/O in T)
		if(O.rpd_blocksusage() == TRUE)
			to_chat(user, "<span class='warning'>[O] blocks the [src]!</span>")
			return

	// If we get here, then we're effectively acting on the turf, probably placing a pipe.
	if(ranged) //woosh beam if bluespaced at a distance
		if(get_dist(src, T) <= (user.client.maxview() + 2))\
			user.Beam(T,icon_state="rped_upgrade", icon='icons/effects/effects.dmi', time=5)
	T.rpd_act(user, src)

#undef RPD_COOLDOWN_TIME
#undef RPD_WALLBUILD_TIME
#undef RPD_MENU_ROTATE
#undef RPD_MENU_FLIP
#undef RPD_MENU_DELETE
#undef RPD_MENU_WRENCH
