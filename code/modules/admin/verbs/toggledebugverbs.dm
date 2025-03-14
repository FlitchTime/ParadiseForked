GLOBAL_LIST_INIT(admin_verbs_show_debug_verbs, list(
	/client/proc/camera_view,
	/client/proc/sec_camera_report,
	/client/proc/intercom_view,
	/client/proc/Cell, //More air things
	/client/proc/atmosscan, //check plumbing
	/client/proc/powerdebug, //check power
	/client/proc/count_objects_on_z_level,
	/client/proc/count_objects_all,
	/client/proc/cmd_assume_direct_control,
	/client/proc/startSinglo,
	/client/proc/ticklag,
	/client/proc/cmd_admin_grantfullaccess,
	/client/proc/cmd_admin_areatest,
	/client/proc/cmd_admin_rejuvenate,
	/datum/admins/proc/show_traitor_panel,
	/client/proc/print_jobban_old,
	/client/proc/print_jobban_old_filter,
	/client/proc/admin_redo_space_transitions,
	/client/proc/make_turf_space_map,
	/client/proc/vv_by_ref
))

// Would be nice to make this a permanent admin pref so we don't need to click it each time
/client/proc/enable_debug_verbs()
	set category = "Debug"
	set name = "Debug verbs - Enable"

	if(!check_rights(R_DEBUG))
		return

	remove_verb(src, /client/proc/enable_debug_verbs)
	add_verb(src, GLOB.admin_verbs_show_debug_verbs + /client/proc/disable_debug_verbs)
	
/client/proc/disable_debug_verbs()
	set category = "Debug"
	set name = "Debug verbs - Disable"

	remove_verb(src, GLOB.admin_verbs_show_debug_verbs + /client/proc/disable_debug_verbs)
	add_verb(src, /client/proc/enable_debug_verbs)
