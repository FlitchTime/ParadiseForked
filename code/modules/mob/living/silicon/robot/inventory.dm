//These procs handle putting s tuff in your hand. It's probably best to use these rather than setting stuff manually
//as they handle all relevant stuff like adding it to the player's screen and such

//Returns the thing in our active hand (whatever is in our active module-slot, in this case)
/mob/living/silicon/robot/get_active_hand()
	if(istype(module_active, /obj/item/gripper))
		var/obj/item/gripper/gripper = module_active
		return gripper.gripped_item == null ? module_active : gripper.gripped_item
	return module_active

/mob/living/silicon/robot/get_all_slots()
	return list(module_state_1, module_state_2, module_state_3)


/mob/living/silicon/robot/get_equipped_items(include_pockets = FALSE, include_hands = FALSE)
	. = list()
	if(module_state_1)
		. += module_state_1
	if(module_state_2)
		. += module_state_2
	if(module_state_3)
		. += module_state_3


/*-------TODOOOOOOOOOO--------*/
/mob/living/silicon/robot/proc/uneq_module(obj/item/O)
	if(!O)
		return 0

	O.mouse_opacity = MOUSE_OPACITY_OPAQUE

	if(client)
		client.screen -= O
		observer_screen_update(O, FALSE)
	contents -= O
	if(module)
		O.loc = module	//Return item to module so it appears in its contents, so it can be taken out again.
		for(var/X in O.actions) // Remove assocated actions
			var/datum/action/A = X
			A.Remove(src)

	if(module_active == O)
		if(istype(module_active, /obj/item/borg/destroyer/mobility))
			remove_movespeed_modifier(/datum/movespeed_modifier/destroyer_mobility)
		module_active = null
	if(module_state_1 == O)
		inv1.icon_state = "inv1"
		module_state_1 = null
	else if(module_state_2 == O)
		inv2.icon_state = "inv2"
		module_state_2 = null
	else if(module_state_3 == O)
		module_state_3 = null
		inv3.icon_state = "inv3"
	if(hud_used)
		hud_used.update_robot_modules_display()
	update_icons()
	return TRUE

/mob/living/silicon/robot/proc/activate_module(var/obj/item/O)
	if(!(locate(O) in src.module.modules) && O != src.module.emag)
		return
	if(activated(O))
		to_chat(src, "Already activated")
		return
	if(is_component_functioning("power cell") && cell)
		if(istype(O, /obj/item/borg))
			var/obj/item/borg/B = O
			if(B.powerneeded)
				if((cell.charge * 100 / cell.maxcharge) < B.powerneeded)
					to_chat(src, "Not enough power to activate [B.name]!")
					return
	if(!module_state_1)
		O.mouse_opacity = initial(O.mouse_opacity)
		module_state_1 = O
		O.layer = ABOVE_HUD_LAYER
		SET_PLANE_EXPLICIT(O, ABOVE_HUD_PLANE, src)
		O.screen_loc = inv1.screen_loc
		observer_screen_update(O, TRUE)
		contents += O
		set_actions(O)
	else if(!module_state_2)
		O.mouse_opacity = initial(O.mouse_opacity)
		module_state_2 = O
		O.layer = ABOVE_HUD_LAYER
		SET_PLANE_EXPLICIT(O, ABOVE_HUD_PLANE, src)
		O.screen_loc = inv2.screen_loc
		observer_screen_update(O, TRUE)
		contents += O
		set_actions(O)
	else if(!module_state_3)
		O.mouse_opacity = initial(O.mouse_opacity)
		module_state_3 = O
		O.layer = ABOVE_HUD_LAYER
		SET_PLANE_EXPLICIT(O, ABOVE_HUD_PLANE, src)
		O.screen_loc = inv3.screen_loc
		observer_screen_update(O, TRUE)
		contents += O
		set_actions(O)
	else
		to_chat(src, "You need to disable a module first!")
	check_module_damage(FALSE)


/mob/living/silicon/robot/proc/observer_screen_update(obj/item/item_to_update, add = TRUE)
	for(var/mob/dead/observer/observe in orbiters)
		if(!istype(observe) || !observe.orbit_menu?.auto_observe)
			continue
		if(!(observe.client && observe.client.eye == src))
			LAZYREMOVE(orbiters, observe)
			continue

		if(add)
			observe.client.screen += item_to_update
		else
			observe.client.screen -= item_to_update



/mob/living/silicon/robot/proc/set_actions(obj/item/I)
	for(var/X in I.actions)
		var/datum/action/A = X
		A.Grant(src)

/mob/living/silicon/robot/proc/uneq_active()
	uneq_module(module_active)

/mob/living/silicon/robot/proc/uneq_all()
	uneq_module(module_state_1)
	uneq_module(module_state_2)
	uneq_module(module_state_3)

/mob/living/silicon/robot/proc/uneq_numbered(var/module)
	if(module < 1 || module > 3) return

	switch(module)
		if(1)
			uneq_module(module_state_1)
		if(2)
			uneq_module(module_state_2)
		if(3)
			uneq_module(module_state_3)

/mob/living/silicon/robot/proc/activated(obj/item/O)
	if(module_state_1 == O)
		return 1
	else if(module_state_2 == O)
		return 1
	else if(module_state_3 == O)
		return 1
	else
		return 0

/mob/living/silicon/robot/drop_from_active_hand(force = FALSE)
	var/obj/item/gripper/G = module_active
	if(istype(G))
		G.drop_gripped_item(silent = TRUE)
		return TRUE // The gripper is special because it has a normal item inside that we can drop.
	return FALSE // All robot inventory items have NODROP trait, so they should return FALSE.

//Helper procs for cyborg modules on the UI.
//These are hackish but they help clean up code elsewhere.

//module_selected(module) - Checks whether the module slot specified by "module" is currently selected.
/mob/living/silicon/robot/proc/module_selected(var/module) //Module is 1-3
	return module == get_selected_module()

//module_active(module) - Checks whether there is a module active in the slot specified by "module".
/mob/living/silicon/robot/proc/module_active(var/module) //Module is 1-3
	if(module < 1 || module > 3) return 0

	switch(module)
		if(1)
			if(module_state_1)
				return 1
		if(2)
			if(module_state_2)
				return 1
		if(3)
			if(module_state_3)
				return 1
	return 0

//get_selected_module() - Returns the slot number of the currently selected module.  Returns 0 if no modules are selected.
/mob/living/silicon/robot/proc/get_selected_module()
	if(module_state_1 && module_active == module_state_1)
		return 1
	else if(module_state_2 && module_active == module_state_2)
		return 2
	else if(module_state_3 && module_active == module_state_3)
		return 3

	return 0

//select_module(module) - Selects the module slot specified by "module"
/mob/living/silicon/robot/proc/select_module(var/module) //Module is 1-3
	if(module < 1 || module > 3)
		return

	if(!module_active(module))
		return

	deselect_module(get_selected_module())
	switch(module)
		if(1)
			if(module_active != module_state_1)
				inv1.icon_state = "inv1 +a"
				inv2.icon_state = "inv2"
				inv3.icon_state = "inv3"
				module_active = module_state_1

		if(2)
			if(module_active != module_state_2)
				inv1.icon_state = "inv1"
				inv2.icon_state = "inv2 +a"
				inv3.icon_state = "inv3"
				module_active = module_state_2

		if(3)
			if(module_active != module_state_3)
				inv1.icon_state = "inv1"
				inv2.icon_state = "inv2"
				inv3.icon_state = "inv3 +a"
				module_active = module_state_3

	if(istype(module_active, /obj/item/borg/destroyer/mobility))
		add_movespeed_modifier(/datum/movespeed_modifier/destroyer_mobility)
	update_icons()


//deselect_module(module) - Deselects the module slot specified by "module"
/mob/living/silicon/robot/proc/deselect_module(var/module) //Module is 1-3
	if(module < 1 || module > 3)
		return

	if(istype(module_active, /obj/item/borg/destroyer/mobility))
		remove_movespeed_modifier(/datum/movespeed_modifier/destroyer_mobility)

	switch(module)
		if(1)
			if(module_active == module_state_1)
				inv1.icon_state = "inv1"
				module_active = null
		if(2)
			if(module_active == module_state_2)
				inv2.icon_state = "inv2"
				module_active = null
		if(3)
			if(module_active == module_state_3)
				inv3.icon_state = "inv3"
				module_active = null

	update_icons()


//toggle_module(module) - Toggles the selection of the module slot specified by "module".
/mob/living/silicon/robot/proc/toggle_module(var/module) //Module is 1-3
	if(module < 1 || module > 3) return

	if(module_selected(module))
		deselect_module(module)
	else
		if(module_active(module))
			select_module(module)
		else
			deselect_module(get_selected_module()) //If we can't do select anything, at least deselect the current module.
	return

//cycle_modules() - Cycles through the list of selected modules.
/mob/living/silicon/robot/proc/cycle_modules()
	var/slot_start = get_selected_module()
	if(slot_start) deselect_module(slot_start) //Only deselect if we have a selected slot.

	var/slot_num
	if(slot_start == 0)
		slot_num = 0
		slot_start = 3
	else
		slot_num = slot_start

	do
		slot_num++
		if(slot_num > 3) slot_num = 1 //Wrap around.
		if(module_active(slot_num))
			select_module(slot_num)
			return
	while(slot_start != slot_num) //If we wrap around without finding any free slots, just give up.

	return


/mob/living/silicon/robot/do_unEquip(obj/item/I, force = FALSE, atom/newloc, no_move = FALSE, invdrop = TRUE, silent = FALSE)
	if(I == module_active)
		uneq_active(I)
	return ..()


/mob/living/silicon/robot/proc/update_module_icon()
	if (!hands)
		return

	if(!module)
		hands.icon_state = "nomod"
	else
		hands.icon_state = lowertext(module.module_type)
