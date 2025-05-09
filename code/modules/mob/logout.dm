/mob/Logout()
	SEND_SIGNAL(src, COMSIG_MOB_LOGOUT)
	set_typing_indicator(FALSE)
	SStgui.on_logout(src) // Cleanup any TGUIs the user has open
	unset_machine()
	remove_from_player_list()
	log_access_out(src)
	add_game_logs("OWNERSHIP: [key_name(src)] is no longer owning mob [src]([src.type])")
	// `holder` is nil'd out by now, so we check the `admin_datums` array directly
	//Only report this stuff if we are currently playing.
	if(GLOB.admin_datums[ckey] && SSticker && SSticker.current_state == GAME_STATE_PLAYING)
		var/datum/admins/temp_admin = GLOB.admin_datums[ckey]
		// Triggers on people with banhammer power only - no mentors tripping the alarm
		if(temp_admin.rights & R_BAN)
			message_admins("Admin logout: [key_name_admin(src)]")
			var/list/admincounter = staff_countup(R_BAN)
			if(admincounter[1] == 0) // No active admins
				SSdiscord.send2discord_simple(DISCORD_WEBHOOK_ADMIN, "[key_name(src)] logged out - No active admins, [admincounter[2]] non-admin staff, [admincounter[3]] inactive staff.")

	..()

	become_uncliented()
	update_morgue()

	return TRUE
