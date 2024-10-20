/// Ratvar summoned and capture nuke with gear
/datum/cinematic/clockwork_win // Gear in nuke term ¯\_(ツ)_/¯


/datum/cinematic/clockwork_win/play_cinematic()
	screen.icon_state = null
	flick("intro_cult_clockwork", screen)
	stoplag(2.5 SECONDS)
	play_cinematic_sound(sound('sound\magic\clockwork\reconstruct.ogg'))
	stoplag(2.8 SECONDS)
	play_cinematic_sound(sound('sound/machines/terminal_off.ogg'))
	stoplag(2 SECONDS)
	flick("station_corrupted", screen)
	play_cinematic_sound(sound('sound/effects/ghost.ogg'))
	stoplag(7 SECONDS)
	special_callback?.Invoke()


/datum/cinematic/clockwork_fail /// Why are u here? Just for BLOW UP ON NUKE?


/datum/cinematic/clockwork_fail/play_cinematic()
	screen.icon_state = "station_intact"
	stoplag(2 SECONDS)
	play_cinematic_sound(sound('sound\magic\clockwork\clockcult_gateway_disrupted.ogg'))
	stoplag(6 SECONDS)
	play_cinematic_sound(sound('sound/effects/explosion_distant.ogg'))
	stoplag(1 SECONDS)
	play_cinematic_sound(sound('sound/misc/demon_dies.ogg'))
	stoplag(3 SECONDS)
	special_callback?.Invoke()
