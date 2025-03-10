
/mob/living/simple_animal/bot/ed209/syndicate
	name = "Syndicate Sentry Bot"
	desc = "Охранный робот Синдиката."
	ru_names = list(
		NOMINATIVE = "робот-часовой Синдиката",
		GENITIVE = "робота-часового Синдиката",
		DATIVE = "роботу-часовому Синдиката",
		ACCUSATIVE = "робота-часового Синдиката",
		INSTRUMENTAL = "роботом-часовым Синдиката",
		PREPOSITIONAL = "роботе-часовом Синдиката",
	)
	model = "Guardian"
	icon = 'icons/obj/mecha/mecha.dmi'
	icon_state = "darkgygax"
	radio_channel = "Syndicate"
	health = 300
	maxHealth = 300
	declare_arrests = FALSE
	idcheck = TRUE
	arrest_type = TRUE
	auto_patrol = TRUE
	emagged = 2
	faction = list("syndicate")
	shoot_sound = 'sound/weapons/wave.ogg'
	anchored = TRUE
	window_id = "syndiebot"
	window_name = "Интерфейс Часового Робота Синдиката"
	var/turf/saved_turf
	var/stepsound = 'sound/mecha/mechstep.ogg'
	var/area/syndicate_depot/core/depotarea
	var/raised_alert = FALSE
	var/pathing_failed = FALSE
	var/turf/spawn_turf


/mob/living/simple_animal/bot/ed209/syndicate/Initialize(mapload)
	. = ..()
	set_weapon()
	update_icon()
	spawn_turf = get_turf(src)


/mob/living/simple_animal/bot/ed209/syndicate/setup_access()
	if(access_card)
		access_card.access = list(ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER)
		prev_access = access_card.access


/mob/living/simple_animal/bot/ed209/syndicate/update_icon_state()
	icon_state = initial(icon_state)


/mob/living/simple_animal/bot/ed209/syndicate/turn_on()
	. = ..()
	update_icon()


/mob/living/simple_animal/bot/ed209/syndicate/turn_off()
	..()
	update_icon()


/mob/living/simple_animal/bot/ed209/syndicate/ui_interact(mob/user, datum/tgui/ui = null)
	balloon_alert(user, "панель управления отсутствует!")
	return


/mob/living/simple_animal/bot/ed209/syndicate/ui_data(mob/user)
	return


/mob/living/simple_animal/bot/ed209/syndicate/ui_act(action, params)
	return


/mob/living/simple_animal/bot/ed209/syndicate/Topic(href, href_list)
	return


/mob/living/simple_animal/bot/ed209/syndicate/retaliate(mob/living/carbon/human/H)
	if(!H)
		return
	target = H
	mode = BOT_HUNT


/mob/living/simple_animal/bot/ed209/syndicate/emag_act(mob/user)
	if(user)
		balloon_alert(user, "сканер ID-карт отсутствует!")


/mob/living/simple_animal/bot/ed209/syndicate/ed209_ai()
	var/turf/current_turf = get_turf(src)
	if(saved_turf && current_turf != saved_turf)
		playsound(loc, stepsound, 40, TRUE)
	if(spawn_turf && !are_zs_connected(src, spawn_turf))
		raise_alert("[capitalize(declent_ru(NOMINATIVE))] потерялся в пространстве.")
		raised_alert = FALSE
		raise_alert("[capitalize(declent_ru(NOMINATIVE))] активировал протокол само-уничтожения.")
		explode()
	saved_turf = current_turf
	switch(mode)
		if(BOT_IDLE)
			SSmove_manager.stop_looping(src)
			set_path(null)
			look_for_perp()
			if(!mode && auto_patrol)
				mode = BOT_START_PATROL
		if(BOT_HUNT)
			if(frustration >= 8)
				SSmove_manager.stop_looping(src)
				set_path(null)
				back_to_idle()
			if(target)
				if(isliving(target))
					if(target.stat == DEAD)
						back_to_idle()
						return
				shootAt(target)
				var/turf/olddist = get_dist(src, target)
				SSmove_manager.move_to(src, target, 1, BOT_STEP_DELAY)
				if((get_dist(src, target)) >= (olddist))
					frustration++
				else
					frustration = 0
			else
				back_to_idle()
		if(BOT_START_PATROL)
			look_for_perp()
			start_patrol()
		if(BOT_PATROL)
			look_for_perp()
			bot_patrol()
		else
			back_to_idle()


/mob/living/simple_animal/bot/ed209/syndicate/look_for_perp()
	if(disabled)
		return

	for(var/mob/M in view(7, src))
		if(M.invisibility > see_invisible)
			continue
		if("syndicate" in M.faction)
			continue
		if(M.stat == DEAD)
			continue
		if((M.name == oldtarget_name) && (world.time < last_found + 100))
			continue
		target = M
		oldtarget_name = M.name
		mode = BOT_HUNT
		INVOKE_ASYNC(src, PROC_REF(handle_automated_action))
		break

	for(var/obj/spacepod/P in view(7, src))
		if((P.name == oldtarget_name) && (world.time < last_found + 100))
			continue
		if(!P.pilot)
			continue
		if("syndicate" in P.pilot.faction)
			continue
		if(P.pilot.stat == DEAD)
			continue
		target = P
		oldtarget_name = P.name
		mode = BOT_HUNT
		INVOKE_ASYNC(src, PROC_REF(handle_automated_action))
		break


/mob/living/simple_animal/bot/ed209/syndicate/shootAt(atom/target)
	if(lastfired && world.time - lastfired < shot_delay)
		return
	lastfired = world.time
	var/obj/projectile/P = new projectile(loc)
	playsound(loc, shoot_sound, 100, 1)
	P.current = loc
	P.starting = loc
	P.firer = src
	P.yo = target.y - loc.y
	P.xo = target.x - loc.x
	P.original = target
	P.fire()


/mob/living/simple_animal/bot/ed209/syndicate/explode()
	if(!QDELETED(src))
		if(depotarea)
			depotarea.list_remove(src, depotarea.guard_list)
		SSmove_manager.stop_looping(src)
		visible_message(span_userdanger("[capitalize(declent_ru(NOMINATIVE))] разлетается на части!"))
		do_sparks(3, 1, src)
		new /obj/effect/decal/cleanable/blood/oil(loc)
		var/obj/structure/mecha_wreckage/gygax/dark/wreck = new /obj/structure/mecha_wreckage/gygax/dark(loc)
		wreck.name = "sentry bot wreckage"

		raise_alert("[capitalize(declent_ru(NOMINATIVE))] уничтожен.")
		qdel(src)


/mob/living/simple_animal/bot/ed209/syndicate/set_weapon()
	projectile = /obj/projectile/bullet/a40mm


/mob/living/simple_animal/bot/ed209/syndicate/emp_act(severity)
	return


/mob/living/simple_animal/bot/ed209/syndicate/OnUnarmedAttack(atom/A)
	return shootAt(A)


/mob/living/simple_animal/bot/ed209/syndicate/start_cuffing(mob/living/carbon/C)
	shootAt(C)


/mob/living/simple_animal/bot/ed209/syndicate/stun_attack(mob/living/carbon/C)
	shootAt(C)


/mob/living/simple_animal/bot/ed209/syndicate/speak()
	return


/mob/living/simple_animal/bot/ed209/syndicate/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	return TRUE


/mob/living/simple_animal/bot/ed209/syndicate/start_patrol()
	if(tries >= BOT_STEP_MAX_RETRIES)
		if(!pathing_failed)
			pathing_failed = TRUE
			var/failmsg = "Depot: [src] at [loc.x],[loc.y],[loc.z] lacks patrol target."
			if(istype(patrol_target))
				failmsg = "Depot: [src] at [loc.x],[loc.y],[loc.z] cannot reach [patrol_target.x],[patrol_target.y]"
			log_debug(failmsg)
	return ..()


/mob/living/simple_animal/bot/ed209/syndicate/proc/raise_alert(reason)
	if(raised_alert)
		return
	raised_alert = TRUE
	if(depotarea)
		depotarea.increase_alert(reason)
