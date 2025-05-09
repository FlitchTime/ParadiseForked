//This is the proc for gibbing a mob. Cannot gib ghosts.
//added different sort of gibs and animations. N
/mob/living/gib()
	if(!death(TRUE) && stat != DEAD)
		return FALSE
	// hide and freeze for the GC
	ADD_TRAIT(src, TRAIT_NO_TRANSFORM, PERMANENT_TRANSFORMATION_TRAIT)
	icon = null
	invisibility = INVISIBILITY_ABSTRACT

	playsound(src.loc, 'sound/goonstation/effects/gib.ogg', 50, 1)
	gibs(loc, dna)
	QDEL_IN(src, 0)
	return TRUE

//This is the proc for turning a mob into ash. Mostly a copy of gib code (above).
//Originally created for wizard disintegrate. I've removed the virus code since it's irrelevant here.
//Dusting robots does not eject the MMI, so it's a bit more powerful than gib() /N
/mob/living/dust()
	dusted = TRUE
	if(!death(TRUE) && stat != DEAD)
		dusted = FALSE
		return FALSE
	// hide and freeze them while they get GC'd
	ADD_TRAIT(src, TRAIT_NO_TRANSFORM, PERMANENT_TRANSFORMATION_TRAIT)
	icon = null
	invisibility = INVISIBILITY_ABSTRACT
	dust_animation()
	QDEL_IN(src, 0)
	return TRUE

/mob/living/melt()
	if(!death(TRUE) && stat != DEAD)
		return FALSE
	// hide and freeze them while they get GC'd
	ADD_TRAIT(src, TRAIT_NO_TRANSFORM, PERMANENT_TRANSFORMATION_TRAIT)
	icon = null
	invisibility = INVISIBILITY_ABSTRACT
	QDEL_IN(src, 0)
	return TRUE

/mob/living/proc/can_die()
	return !(stat == DEAD || HAS_TRAIT(src, TRAIT_GODMODE) || HAS_TRAIT(src, TRAIT_NO_DEATH))

// Returns true if mob transitioned from live to dead
// Do a check with `can_die` beforehand if you need to do any
// handling before `stat` is set
/mob/living/death(gibbed)
	SEND_SIGNAL(src, COMSIG_LIVING_EARLY_DEATH, gibbed)

	if(stat == DEAD || !can_die())
		// Whew! Good thing I'm indestructible! (or already dead)
		return FALSE

	set_stat(DEAD)
	..()
	INVOKE_ASYNC(src, PROC_REF(burst_blob_on_die))
	timeofdeath = world.time
	var/gib_pref = ""
	if(client)
		gib_pref = " Разрешение на гиб без цели в" + (client.prefs.toggles2 & PREFTOGGLE_2_GIB_WITHOUT_OBJECTIVE ? "" : "ы") + "ключено."

	add_attack_logs(src, src, "died[gibbed ? " (Gibbed)": ""]" + gib_pref)

	if(!gibbed && deathgasp_on_death)
		INVOKE_ASYNC(src, PROC_REF(emote), "deathgasp")

	if(HAS_TRAIT(src, TRAIT_SECDEATH))
		playsound(loc, pick('sound/misc/die1.ogg', 'sound/misc/die2.ogg', 'sound/misc/die3.ogg', 'sound/misc/die4.ogg'), 80)

	if(mind && suiciding)
		mind.suicided = TRUE
	reset_perspective(null)
	hud_used?.reload_fullscreen()
	update_sight()
	update_action_buttons_icon()

	update_damage_hud()
	update_health_hud()
	update_stamina_hud()
	med_hud_set_health()
	med_hud_set_status()
	if(!gibbed && !QDELETED(src))
		addtimer(CALLBACK(src, PROC_REF(med_hud_set_status)), DEFIB_TIME_LIMIT + 1)

	for(var/s in ownedSoullinks)
		var/datum/soullink/S = s
		S.ownerDies(gibbed, src)
	for(var/s in sharedSoullinks)
		var/datum/soullink/S = s
		S.sharerDies(gibbed, src)

	if(mind)
		mind.store_memory("Time of death: [station_time_timestamp("hh:mm:ss", timeofdeath)]", 0)
		GLOB.respawnable_list += src
		if(mind.name && !isbrain(src)) // !isbrain() is to stop it from being called twice
			var/turf/T = get_turf(src)
			var/area_name = get_area_name(T)
			for(var/P in GLOB.dead_mob_list)
				var/mob/M = P
				if((M.client?.prefs.toggles2 & PREFTOGGLE_2_DEATHMESSAGE) && (isobserver(M) || M.stat == DEAD))
					to_chat(M, "<span class='deadsay'><b>[mind.name]</b> has died at <b>[area_name]</b>. (<a href='byond://?src=[M.UID()];jump=[gibbed ? "\ref[T]" : "\ref[src]"]'>JMP</a>)</span>")

	if(SSticker && SSticker.mode)
		SSticker.mode.check_win()

	if(xenobiology_spawned)
		SSmobs.xenobiology_mobs--

	clear_alert("succumb")
	SEND_SIGNAL(src, COMSIG_LIVING_DEATH, gibbed)
	// u no we dead
	return TRUE

/mob/living/proc/delayed_gib()
	visible_message("<span class='danger'><b>[src]</b> starts convulsing violently!</span>", "You feel as if your body is tearing itself apart!")
	Weaken(30 SECONDS)
	do_jitter_animation(1000, -1) // jitter until they are gibbed
	addtimer(CALLBACK(src, PROC_REF(gib)), rand(2 SECONDS, 10 SECONDS))
