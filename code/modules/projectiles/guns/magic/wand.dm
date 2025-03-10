/obj/item/gun/magic/wand
	name = "wand of nothing"
	belt_icon = "wand of nothing"
	desc = "It's not just a stick, it's a MAGIC stick!"
	ammo_type = /obj/item/ammo_casing/magic
	icon_state = "nothingwand"
	item_state = "wand"
	w_class = WEIGHT_CLASS_SMALL
	can_charge = 0
	max_charges = 100 //100, 50, 50, 34 (max charge distribution by 25%ths)
	var/variable_charges = 1

/obj/item/gun/magic/wand/Initialize()
	if(prob(75) && variable_charges) //25% chance of listed max charges, 50% chance of 1/2 max charges, 25% chance of 1/3 max charges
		if(prob(33))
			max_charges = CEILING(max_charges / 3, 1)
		else
			max_charges = CEILING(max_charges / 2, 1)
	. = ..()


/obj/item/gun/magic/wand/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Has [charges] charge\s remaining.</span>"


/obj/item/gun/magic/wand/update_icon_state()
	icon_state = "[initial(icon_state)][charges ? "" : "-drained"]"


/obj/item/gun/magic/wand/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(target == user)
		return ATTACK_CHAIN_PROCEED
	return ..()


/obj/item/gun/magic/wand/magic_charge_act(mob/user)
	. = ..()
	update_appearance(UPDATE_ICON_STATE)


/obj/item/gun/magic/wand/afterattack(atom/target, mob/living/user, proximity, params)
	if(!charges)
		shoot_with_empty_chamber(user)
		return
	if(target == user)
		if(no_den_usage)
			var/area/A = get_area(user)
			if(istype(A, /area/wizard_station))
				to_chat(user, "<span class='warning'>You know better than to violate the security of The Den, best wait until you leave to use [src].</span>")
				return
			else
				no_den_usage = FALSE
		zap_self(user)
	else
		..()
	update_icon()

/obj/item/gun/magic/wand/proc/zap_self(mob/living/user)
	user.visible_message("<span class='danger'>[user] zaps [user.p_them()]self with [src].</span>")
	playsound(user, fire_sound, 50, 1)
	add_attack_logs(null, user, "zapped [user.p_them()]self with a [src]", ATKLOG_ALL)

/////////////////////////////////////
//WAND OF DEATH
/////////////////////////////////////

/obj/item/gun/magic/wand/death
	name = "wand of death"
	belt_icon = "wand of death"
	desc = "This deadly wand overwhelms the victim's body with pure energy, slaying them without fail."
	fire_sound = 'sound/magic/wandodeath.ogg'
	ammo_type = /obj/item/ammo_casing/magic/death
	icon_state = "deathwand"
	max_charges = 3 //3, 2, 2, 1

/obj/item/gun/magic/wand/death/zap_self(mob/living/user)
	var/message ="<span class='warning'>You irradiate yourself with pure energy! "
	message += pick("Do not pass go. Do not collect 200 zorkmids.</span>","You feel more confident in your spell casting skills.</span>","You Die...</span>","Do you want your possessions identified?</span>")
	to_chat(user, message)
	user.adjustFireLoss(3000)
	charges--
	..()

/////////////////////////////////////
//WAND OF HEALING
/////////////////////////////////////

/obj/item/gun/magic/wand/resurrection
	name = "wand of resurrection"
	belt_icon = "wand of resurrection"
	desc = "This wand uses healing magics to heal and revive. They are rarely utilized within the Wizard Federation for some reason."
	ammo_type = /obj/item/ammo_casing/magic/heal
	fire_sound = 'sound/magic/staff_healing.ogg'
	icon_state = "revivewand"
	max_charges = 3 //3, 2, 2, 1

/obj/item/gun/magic/wand/resurrection/zap_self(mob/living/user)
	user.revive()
	to_chat(user, "<span class='notice'>You feel great!</span>")
	charges--
	..()

/////////////////////////////////////
//WAND OF POLYMORPH
/////////////////////////////////////

/obj/item/gun/magic/wand/polymorph
	name = "wand of polymorph"
	belt_icon = "wand of polymorph"
	desc = "This wand is attuned to chaos and will radically alter the victim's form."
	ammo_type = /obj/item/ammo_casing/magic/change
	fire_sound = 'sound/magic/staff_change.ogg'
	icon_state = "polywand"
	max_charges = 10 //10, 5, 5, 4

/obj/item/gun/magic/wand/polymorph/zap_self(mob/living/user)
	..() //because the user mob ceases to exists by the time wabbajack fully resolves
	wabbajack(user)
	charges--

/////////////////////////////////////
//WAND OF TELEPORTATION
/////////////////////////////////////

/obj/item/gun/magic/wand/teleport
	name = "wand of teleportation"
	belt_icon = "wand of teleportation"
	desc = "This wand will wrench targets through space and time to move them somewhere else."
	ammo_type = /obj/item/ammo_casing/magic/teleport
	icon_state = "telewand"
	max_charges = 10 //10, 5, 5, 4
	no_den_usage = TRUE
	fire_sound = 'sound/magic/wand_teleport.ogg'

/obj/item/gun/magic/wand/teleport/zap_self(mob/living/user)
	do_teleport(user, user, 10)
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(amount = 10, location = user.loc)
	smoke.start()
	charges--
	..()

/////////////////////////////////////
//WAND OF DOOR CREATION
/////////////////////////////////////

/obj/item/gun/magic/wand/door
	name = "wand of door creation"
	belt_icon = "wand of door creation"
	desc = "This particular wand can create doors in any wall for the unscrupulous wizard who shuns teleportation magics."
	ammo_type = /obj/item/ammo_casing/magic/door
	fire_sound = 'sound/magic/staff_door.ogg'
	icon_state = "doorwand"
	max_charges = 20 //20, 10, 10, 7
	no_den_usage = TRUE

/obj/item/gun/magic/wand/door/zap_self(mob/living/user)
	to_chat(user, "<span class='notice'>You feel vaguely more open with your feelings.</span>")
	charges--
	..()

/////////////////////////////////////
//WAND OF FIREBALL
/////////////////////////////////////

/obj/item/gun/magic/wand/fireball
	name = "wand of fireball"
	belt_icon = "wand of fireball"
	desc = "This wand shoots scorching balls of fire that explode into destructive flames."
	fire_sound = 'sound/magic/fireball.ogg'
	ammo_type = /obj/item/ammo_casing/magic/fireball
	icon_state = "firewand"
	max_charges = 8 //8, 4, 4, 3

/obj/item/gun/magic/wand/fireball/zap_self(mob/living/user)
	explosion(user.loc, -1, 0, 2, 3, 0, flame_range = 2, cause = src)
	charges--
	..()

/////////////////////////////////////
//WAND OF SLIPPING
/////////////////////////////////////

/obj/item/gun/magic/wand/slipping
	name = "wand of slipping"
	desc = "This wand shoots... banana peels?"
	fire_sound = 'sound/items/bikehorn.ogg'
	ammo_type = /obj/item/ammo_casing/magic/slipping
	icon_state = "wandofslipping"
	item_state = "staffofslipping"
	variable_charges = 0
	max_charges = 5
	var/charging = FALSE

/obj/item/gun/magic/wand/slipping/zap_self(mob/living/user)
	to_chat(user, "<span class='notice'>You feel rather silly!</span>")
	charges--
	..()

/obj/item/gun/magic/wand/slipping/afterattack(atom/target, mob/living/user, proximity, params)
	. = ..()
	if(!charges && !charging)
		to_chat(usr, "<span class='notice'>[src] has started to regain its charge.</span>")
		charging = TRUE
		addtimer(CALLBACK(src, PROC_REF(recharge)), 30 SECONDS, TIMER_UNIQUE)

/obj/item/gun/magic/wand/slipping/shoot_with_empty_chamber(mob/living/user as mob|obj)
	to_chat(user, "<span class='warning'>[src] is still regaining its charge!</span>")
	return

/obj/item/gun/magic/wand/slipping/proc/recharge()
	charges++
	playsound(src, 'sound/items/bikehorn.ogg', 50, TRUE)
	to_chat(usr, "<span class='notice'>[src] has regained its charge!</span>")
	charging = FALSE
	update_icon()
