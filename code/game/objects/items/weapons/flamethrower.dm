/obj/item/flamethrower
	name = "flamethrower"
	desc = "You are a firestarter!"
	icon = 'icons/obj/weapons/flamethrower.dmi'
	icon_state = "flamethrowerbase"
	item_state = "flamethrower_0"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	flags = CONDUCT
	force = 3
	throwforce = 10
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL=500)
	resistance_flags = FIRE_PROOF
	origin_tech = "combat=1;plasmatech=2;engineering=2"
	var/status = FALSE
	var/lit = FALSE	//on or off
	var/operating = FALSE//cooldown
	var/obj/item/weldingtool/weldtool = null
	var/obj/item/assembly/igniter/igniter = null
	var/obj/item/tank/internals/plasma/ptank = null
	var/warned_admins = FALSE //for the message_admins() when lit
	//variables for prebuilt flamethrowers
	var/create_full = FALSE
	var/create_with_tank = FALSE
	var/igniter_type = /obj/item/assembly/igniter


/obj/item/flamethrower/Destroy()
	QDEL_NULL(weldtool)
	QDEL_NULL(igniter)
	QDEL_NULL(ptank)
	return ..()


/obj/item/flamethrower/process()
	if(!lit || !igniter)
		STOP_PROCESSING(SSobj, src)
		return null
	var/turf/location = loc
	if(istype(location, /mob/))
		var/mob/M = location
		if(M.l_hand == src || M.r_hand == src)
			location = M.loc
	if(isturf(location)) //start a fire if possible
		igniter.flamethrower_process(location)


/obj/item/flamethrower/update_icon(updates = ALL)
	. = ..()
	update_equipped_item(update_speedmods = FALSE)



/obj/item/flamethrower/update_icon_state()
	item_state = "flamethrower_[lit]"


/obj/item/flamethrower/update_overlays()
	. = ..()
	if(igniter)
		. += "+igniter[status]"
	if(ptank)
		. += "+ptank"
	if(lit)
		. += "+lit"


/obj/item/flamethrower/can_enter_storage(obj/item/storage/S, mob/user)
	if(lit)
		to_chat(user, "<span class='warning'>[S] can't hold [src] while it's lit!</span>")
		return FALSE
	else
		return TRUE

/obj/item/flamethrower/afterattack(atom/target, mob/user, flag, params)
	. = ..()
	if(flag)
		return // too close
	if(user && user.get_active_hand() == src) // Make sure our user is still holding us
		var/turf/target_turf = get_turf(target)
		if(target_turf)
			var/turflist = get_line(user, target_turf)
			add_attack_logs(user, target, "Flamethrowered at [target.x],[target.y],[target.z]")
			flame_turf(turflist)
			playsound(src, 'sound/weapons/gunshots/1flamethr.ogg', 50, 1)


/obj/item/flamethrower/attackby(obj/item/I, mob/user, params)
	if(isigniter(I))
		add_fingerprint(user)
		var/obj/item/assembly/igniter/new_igniter = I
		if(igniter)
			to_chat(user, span_warning("There is [igniter] already installed!"))
			return ATTACK_CHAIN_PROCEED
		if(new_igniter.secured)
			to_chat(user, span_warning("The [new_igniter.name] should not be secured!"))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(new_igniter, src))
			return ..()
		igniter = new_igniter
		update_icon()
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/tank/internals/plasma))
		add_fingerprint(user)
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		if(ptank)
			ptank.forceMove_turf()
			to_chat(user, span_notice("You swap the plasma tank in [src]."))
		else
			to_chat(user, span_notice("You have installed new plasma tank in [src]."))
		ptank = I
		update_icon()
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/flamethrower/wrench_act(mob/user, obj/item/I)
	if(status)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	var/turf/T = get_turf(src)
	if(weldtool)
		weldtool.forceMove(T)
		weldtool = null
	if(igniter)
		igniter.forceMove(T)
		igniter = null
	if(ptank)
		ptank.forceMove(T)
		ptank = null
	new /obj/item/stack/rods(T)
	qdel(src)

/obj/item/flamethrower/screwdriver_act(mob/user, obj/item/I)
	if(!igniter || lit)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	status = !status
	to_chat(user, "<span class='notice'>[igniter] is now [status ? "secured" : "unsecured"]!</span>")
	update_icon()

/obj/item/flamethrower/return_analyzable_air()
	if(ptank)
		return ptank.return_analyzable_air()
	return null

/obj/item/flamethrower/attack_self(mob/user)
	toggle_igniter(user)

/obj/item/flamethrower/click_alt(mob/living/user)
	if(!ptank)
		return NONE
	ptank.forceMove_turf()
	user.put_in_hands(ptank, ignore_anim = FALSE)
	ptank = null
	to_chat(user, span_notice("You remove the plasma tank from [src]!"))
	update_icon()
	return CLICK_ACTION_SUCCESS

/obj/item/flamethrower/examine(mob/user)
	. = ..()
	if(ptank)
		. += "<span class='notice'>[src] has \a [ptank] attached. Alt-click to remove it.</span>"

/obj/item/flamethrower/proc/toggle_igniter(mob/user)
	if(!ptank)
		to_chat(user, "<span class='notice'>Attach a plasma tank first!</span>")
		return
	if(!status)
		to_chat(user, "<span class='notice'>Secure the igniter first!</span>")
		return
	to_chat(user, "<span class='notice'>You [lit ? "extinguish" : "ignite"] [src]!</span>")
	lit = !lit
	if(lit)
		START_PROCESSING(SSobj, src)
		if(!warned_admins)
			message_admins("[ADMIN_LOOKUPFLW(user)] has lit a flamethrower.")
			warned_admins = TRUE
	else
		STOP_PROCESSING(SSobj,src)
	update_icon()

/obj/item/flamethrower/CheckParts(list/parts_list)
	..()
	weldtool = locate(/obj/item/weldingtool) in contents
	igniter = locate(/obj/item/assembly/igniter) in contents
	igniter.secured = FALSE
	status = TRUE
	update_icon()

//Called from turf.dm turf/dblclick
/obj/item/flamethrower/proc/flame_turf(turflist)
	if(!lit || operating)
		return
	operating = TRUE
	var/turf/previousturf = get_turf(src)
	for(var/turf/simulated/T in turflist)
		if(!T.air)
			break
		if(T == previousturf)
			continue	//so we don't burn the tile we be standin on
		if(!ptank || !T.CanAtmosPass(previousturf, vertical = FALSE))
			break
		if(igniter)
			igniter.ignite_turf(src, T)
		else
			default_ignite(T)
		sleep(1)
		previousturf = T
	operating = FALSE
	for(var/mob/M in viewers(1, loc))
		if((M.client && M.machine == src))
			attack_self(M)


/obj/item/flamethrower/proc/default_ignite(turf/target, release_amount = 0.05)
	if(!ptank)
		return
	//TODO: DEFERRED Consider checking to make sure tank pressure is high enough before doing this...
	//Transfer 5% of current tank air contents to turf
	var/datum/gas_mixture/air_transfer = ptank.air_contents.remove_ratio(release_amount)
	if(air_transfer.toxins)
		air_transfer.toxins = air_transfer.toxins * 5
	target.assume_air(air_transfer)
	//Burn it based on transfered gas
	target.hotspot_expose((ptank.air_contents.temperature*2) + 380, 500)
	//location.hotspot_expose(1000,500,1)
	SSair.add_to_active(target, 0)


/obj/item/flamethrower/Initialize(mapload)
	. = ..()
	if(create_full)
		if(!weldtool)
			weldtool = new /obj/item/weldingtool(src)
		if(!igniter)
			igniter = new igniter_type(src)
		igniter.secured = FALSE
		status = TRUE
		if(create_with_tank)
			ptank = new /obj/item/tank/internals/plasma/full(src)
		update_icon()

/obj/item/flamethrower/full
	create_full = TRUE

/obj/item/flamethrower/full/tank
	create_with_tank = TRUE


/obj/item/flamethrower/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = ITEM_ATTACK)
	var/obj/projectile/P = hitby
	if(ptank && damage && attack_type == PROJECTILE_ATTACK && P.damage_type != STAMINA && prob(15))
		owner.visible_message("<span class='danger'>[attack_text] hits the fueltank on [owner]'s [src], rupturing it! What a shot!</span>")
		var/turf/target_turf = get_turf(owner)
		add_game_logs("A projectile ([hitby]) detonated a flamethrower tank held by [key_name(owner)] at [COORD(target_turf)]", owner)
		igniter.ignite_turf(src,target_turf, release_amount = 100)
		QDEL_NULL(ptank)
		return 1 //It hit the flamethrower, not them


/obj/item/assembly/igniter/proc/flamethrower_process(turf/simulated/location)
	location.hotspot_expose(700, 2)

/obj/item/assembly/igniter/proc/ignite_turf(obj/item/flamethrower/F, turf/simulated/location, release_amount = 0.05)
	F.default_ignite(location, release_amount)
