/**********************Lazarus Injector**********************/
/obj/item/lazarus_injector
	name = "lazarus injector"
	desc = "An injector with a cocktail of nanomachines and chemicals, this device can seemingly raise animals from the dead, making them become friendly to the user. Unfortunately, the process is useless on higher forms of life and incredibly costly, so these were hidden in storage until an executive thought they'd be great motivation for some of their employees."
	icon = 'icons/obj/hypo.dmi'
	icon_state = "lazarus_hypo"
	item_state = "hypo"
	origin_tech = "biotech=4;magnets=6"
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	var/loaded = TRUE
	var/malfunctioning = 0
	var/revive_type = SENTIENCE_ORGANIC //So you can't revive boss monsters or robots with it


/obj/item/lazarus_injector/update_icon_state()
	icon_state = "lazarus_[loaded ? "hypo" : "empty"]"


/obj/item/lazarus_injector/afterattack(atom/target, mob/user, proximity_flag, params)
	if(!loaded)
		return
	if(isliving(target) && proximity_flag)
		if(isanimal(target))
			var/mob/living/simple_animal/M = target
			if(M.sentience_type != revive_type)
				balloon_alert(user, "неподходящее животное!")
				return
			if(M.stat == DEAD)
				M.faction = list("neutral")
				M.revive()
				M.can_collar = 1
				if(istype(target, /mob/living/simple_animal/hostile))
					var/mob/living/simple_animal/hostile/H = M
					if(malfunctioning)
						H.faction |= list("lazarus", "\ref[user]")
						H.robust_searching = 1
						H.friends += user
						H.attack_same = 1
						add_game_logs("[user] has revived hostile mob [target] with a malfunctioning lazarus injector", user)
					else
						H.attack_same = 0
				loaded = FALSE
				user.visible_message("<span class='notice'>[user] injects [M] with [src], reviving it.</span>")
				playsound(src,'sound/effects/refill.ogg',50,1)
				update_icon(UPDATE_ICON_STATE)
				return
			else
				balloon_alert(user, "нельзя использовать на мёртвых!")
				return
		else
			balloon_alert(user, "оно слишком разумно!")
			return

/obj/item/lazarus_injector/emag_act(mob/user)
	if(!malfunctioning)
		add_attack_logs(user, src, "emagged")
		malfunctioning = 1
		if(user)
			balloon_alert(user, "протоколы защиты сняты!")

/obj/item/lazarus_injector/emp_act()
	if(!malfunctioning)
		malfunctioning = 1

/obj/item/lazarus_injector/examine(mob/user)
	. = ..()
	if(!loaded)
		. += "<span class='notice'>[src] is empty.</span>"
	if(malfunctioning)
		. += "<span class='notice'>The display on [src] seems to be flickering.</span>"

/*********************Mob Capsule*************************/

/obj/item/mobcapsule
	name = "lazarus capsule"
	desc = "It allows you to store and deploy lazarus-injected creatures easier."
	icon = 'icons/obj/mobcap.dmi'
	icon_state = "mobcap0"
	w_class = WEIGHT_CLASS_TINY
	throw_range = 7
	var/mob/living/simple_animal/captured = null
	var/colorindex = 0
	var/capture_type = SENTIENCE_ORGANIC //So you can't capture boss monsters or robots with it

/obj/item/mobcapsule/Destroy()
	if(captured)
		captured.ghostize()
		QDEL_NULL(captured)
	return ..()


/obj/item/mobcapsule/attack(mob/living/simple_animal/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(istype(target) && target.sentience_type == capture_type && capture(target, user))
		return ATTACK_CHAIN_PROCEED_SUCCESS
	return ..()


/obj/item/mobcapsule/proc/capture(mob/living/simple_animal/S, mob/living/M)
	if(captured)
		to_chat(M, "<span class='notice'>Capture failed!</span>: The capsule already has a mob registered to it!")
	else
		if("neutral" in S.faction)
			S.forceMove(src)
			S.name = "[M.name]'s [initial(S.name)]"
			S.cancel_camera()
			name = "Lazarus Capsule: [initial(S.name)]"
			to_chat(M, "<span class='notice'>You placed a [S.name] inside the Lazarus Capsule!</span>")
			captured = S
		else
			to_chat(M, "You can't capture that mob!")

/obj/item/mobcapsule/throw_impact(atom/A, datum/thrownthing/throwingdatum)
	..()
	if(captured)
		dump_contents()

/obj/item/mobcapsule/proc/dump_contents()
	if(captured)
		captured.forceMove(get_turf(src))
		captured = null


/obj/item/mobcapsule/update_icon_state()
	icon_state = "mobcap[colorindex]"


/obj/item/mobcapsule/attack_self(mob/user)
	colorindex += 1
	if(colorindex >= 6)
		colorindex = 0
	update_icon(UPDATE_ICON_STATE)

