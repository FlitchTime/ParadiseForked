// Set a client's focus to an object and override these procs on that object to let it handle keypresses

/datum/proc/key_down(key, client/user, full_key) // Called when a key is pressed down initially
	SHOULD_CALL_PARENT(TRUE)
	return


/datum/proc/key_up(key, client/user) // Called when a key is released
	return


/datum/proc/keyLoop(client/user) // Called once every frame
	set waitfor = FALSE
	return


/client/proc/set_macros()
	set waitfor = FALSE

	//Reset the buffer
	client_reset_held_keys()

	erase_all_macros()

	var/list/macro_sets = SSinput.macro_set
	for(var/i in 1 to length(macro_sets))
		var/setname = macro_sets[i]
		if(setname != "default")
			winclone(src, "default", setname)
		var/list/macro_set = macro_sets[setname]
		for(var/k in 1 to length(macro_set))
			var/key = macro_set[k]
			var/command = macro_set[key]
			winset(src, "[setname]-[key]", "parent=[setname];name=[key];command=[command]")

	winset(src, null, "input.border=line") //screw you, we start in hotkey mode now

	calculate_move_dir()


// removes all the existing macros
/client/proc/erase_all_macros()
	var/erase_output = ""
	var/list/macro_set = params2list(winget(src, "default.*", "command")) // The third arg doesnt matter here as we're just removing them all
	for(var/k in 1 to length(macro_set))
		var/list/split_name = splittext(macro_set[k], ".")
		var/macro_name = "[split_name[1]].[split_name[2]]" // [3] is "command"
		erase_output = "[erase_output];[macro_name].parent=null"
	winset(src, null, erase_output)


/// Manually clears any held keys, in case due to lag or other undefined behavior a key gets stuck.
/client/proc/client_reset_held_keys()
	for(var/key in keys_held)
		KeyUp(key)

	//In case one got stuck and the previous loop didn't clean it, somehow.
	for(var/key in key_combos_held)
		KeyUp(key_combos_held[key])


/client/proc/update_active_keybindings()
	active_keybindings = list()
	movement_keys = list()

	for(var/key in prefs?.keybindings)
		for(var/datum/keybinding/keybinding as anything in prefs.keybindings[key])
			if(!keybinding.can_use(src, mob))
				continue
			if(istype(keybinding, /datum/keybinding/movement))
				var/datum/keybinding/movement/move_keybinding = keybinding
				movement_keys[key] = move_keybinding.move_dir
			else
				active_keybindings[key] += list(keybinding)
	calculate_move_dir()
	if(!mob) // Clients can join before world/new is setup, so we gotta mob check em
		return active_keybindings
	for(var/datum/action/action as anything in mob.actions)
		if(action.button?.linked_keybind?.binded_to)
			var/datum/keybinding/mob/trigger_action_button/linked_bind = action.button.linked_keybind
			active_keybindings[linked_bind.binded_to] += list(linked_bind)

	return active_keybindings

