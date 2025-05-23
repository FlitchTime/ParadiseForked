/obj/item/ammo_casing/energy
	name = "energy weapon lens"
	desc = "The part of the gun that makes the laser go pew"
	caliber = "energy"
	projectile_type = /obj/projectile/energy
	fire_sound = 'sound/weapons/gunshots/1laser10.ogg'
	muzzle_flash_effect = /obj/effect/temp_visual/target_angled/muzzle_flash/energy
	leaves_residue = FALSE
	/// The amount of energy a cell needs to expend to create this shot.
	var/e_cost = 100
	/// Identifier for the firemode, mostly used in icon updates.
	var/select_name = "energy"
	/// Fluff fire mode name showed to the user.
	var/fluff_select_name

/obj/item/ammo_casing/energy/laser
	projectile_type = /obj/projectile/beam/laser
	muzzle_flash_color = LIGHT_COLOR_DARKRED
	select_name = "kill"

/obj/item/ammo_casing/energy/laser/light
	projectile_type = /obj/projectile/beam/laser/light
	delay = 0.9

/obj/item/ammo_casing/energy/laser/cyborg //to balance cyborg energy cost seperately
	e_cost = 250

/obj/item/ammo_casing/energy/lasergun
	projectile_type = /obj/projectile/beam/laser
	muzzle_flash_color = LIGHT_COLOR_DARKRED
	e_cost = 65
	select_name = "kill"

/obj/item/ammo_casing/energy/laser/hos //allows balancing of HoS and blueshit guns seperately from other energy weapons
	e_cost = 75

/obj/item/ammo_casing/energy/laser/blueshield
	e_cost = 83

/obj/item/ammo_casing/energy/laser/practice
	projectile_type = /obj/projectile/beam/practice
	select_name = "practice"
	harmful = FALSE
	fire_sound = 'sound/weapons/gunshots/1retrolaser.ogg'

/obj/item/ammo_casing/energy/laser/scatter
	projectile_type = /obj/projectile/beam/scatter
	pellets = 5
	variance = 25
	select_name = "scatter"

/obj/item/ammo_casing/energy/laser/heavy
	projectile_type = /obj/projectile/beam/laser/heavylaser
	select_name = "anti-vehicle"
	fire_sound = 'sound/weapons/gunshots/1pulse2.ogg'

/obj/item/ammo_casing/energy/laser/pulse
	projectile_type = /obj/projectile/beam/pulse
	muzzle_flash_color = LIGHT_COLOR_DARKBLUE
	e_cost = 200
	select_name = "DESTROY"
	fire_sound = 'sound/weapons/gunshots/1pulse2.ogg'

/obj/item/ammo_casing/energy/laser/scatter/pulse
	projectile_type = /obj/projectile/beam/pulse
	e_cost = 200
	select_name = "ANNIHILATE"
	fire_sound = 'sound/weapons/gunshots/1pulse2.ogg'

/obj/item/ammo_casing/energy/laser/bluetag
	projectile_type = /obj/projectile/beam/lasertag/bluetag
	muzzle_flash_color = LIGHT_COLOR_BLUE
	select_name = "bluetag"
	harmful = FALSE
	fire_sound = 'sound/weapons/gunshots/1retrolaser.ogg'

/obj/item/ammo_casing/energy/laser/redtag
	projectile_type = /obj/projectile/beam/lasertag/redtag
	select_name = "redtag"
	harmful = FALSE
	fire_sound = 'sound/weapons/gunshots/1retrolaser.ogg'

/obj/item/ammo_casing/energy/xray
	projectile_type = /obj/projectile/beam/xray
	muzzle_flash_color = LIGHT_COLOR_GREEN
	delay = 11
	e_cost = 100
	fire_sound = 'sound/weapons/gunshots/1xray.ogg'

/obj/item/ammo_casing/energy/immolator
	projectile_type = /obj/projectile/beam/immolator
	fire_sound = 'sound/weapons/gunshots/1xray.ogg'
	e_cost = 125

/obj/item/ammo_casing/energy/immolator/strong
	projectile_type = /obj/projectile/beam/immolator/strong
	e_cost = 50
	select_name = "precise"

/obj/item/ammo_casing/energy/immolator/strong/cyborg
	// Used by gamma ERT borgs
	e_cost = 250 // 5x that of the standard laser, for 2.25x the damage (if 1/1 shots hit) plus ignite. Not energy-efficient, but can be used for sniping.

/obj/item/ammo_casing/energy/immolator/scatter
	projectile_type = /obj/projectile/beam/immolator/weak
	e_cost = 50
	pellets = 6
	variance = 25
	select_name = "scatter"

/obj/item/ammo_casing/energy/immolator/scatter/cyborg
	// Used by gamma ERT borgs
	e_cost = 250 // 5x that of the standard laser, for 7.5x the damage (if 6/6 shots hit) plus ignite. Efficient only if you hit with at least 4/6 of the shots.

/obj/item/ammo_casing/energy/electrode
	projectile_type = /obj/projectile/energy/electrode
	muzzle_flash_color = "#FFFF00"
	select_name = "stun"
	fire_sound = 'sound/weapons/gunshots/1taser.ogg'
	e_cost = 100
	delay = 15
	harmful = FALSE

/obj/item/ammo_casing/energy/electrode/advanced //admin-bus only, k? dont give this thing to 100 year old Charlie crew or other ghost role
	projectile_type = /obj/projectile/energy/electrode/advanced

/obj/item/ammo_casing/energy/electrode/gun
	fire_sound = 'sound/weapons/gunshots/gunshot.ogg'
	e_cost = 100

/obj/item/ammo_casing/energy/electrode/hos //allows balancing of HoS and blueshit guns seperately from other energy weapons
	e_cost = 100

/obj/item/ammo_casing/energy/electrode/blueshield
	e_cost = 150

/obj/item/ammo_casing/energy/ion
	projectile_type = /obj/projectile/ion
	muzzle_flash_color = LIGHT_COLOR_LIGHTBLUE
	delay = 0.4 SECONDS
	select_name = "ion"
	fire_sound = 'sound/weapons/ionrifle.ogg'

/obj/item/ammo_casing/energy/declone
	projectile_type = /obj/projectile/energy/declone
	muzzle_flash_color = LIGHT_COLOR_GREEN
	select_name = "declone"
	fire_sound = 'sound/weapons/gunshots/1declone.ogg'

/obj/item/ammo_casing/energy/mindflayer
	projectile_type = /obj/projectile/beam/mindflayer
	select_name = "MINDFUCK"
	fire_sound = 'sound/weapons/laser.ogg'

/obj/item/ammo_casing/energy/flora
	fire_sound = 'sound/effects/stealthoff.ogg'
	muzzle_flash_color = LIGHT_COLOR_GREEN
	harmful = FALSE

/obj/item/ammo_casing/energy/flora/alpha
	name = "alpha"
	select_name = "floraalpha"
	fire_sound = 'sound/weapons/gunshots/1declone.ogg'
	projectile_type = /obj/projectile/energy/floraalpha
	harmful = TRUE
	click_cooldown_override = 2
	e_cost = 150

/obj/item/ammo_casing/energy/flora/alpha/emag
	projectile_type = /obj/projectile/energy/floraalpha/emag
	e_cost = 225

/obj/item/ammo_casing/energy/flora/beta
	name = "beta"
	select_name = "florabeta"
	projectile_type = /obj/projectile/energy/florabeta
	click_cooldown_override = 1
	e_cost = 75

/obj/item/ammo_casing/energy/flora/gamma
	name = "gamma"
	select_name = "floragamma"
	projectile_type = /obj/projectile/energy/floragamma
	delay = 10
	e_cost = 675

/obj/item/ammo_casing/energy/flora/gamma/fire(atom/target, mob/living/user, params, distro, quiet, zone_override, spread, atom/firer_source_atom)
	playsound(src.loc, 'sound/weapons/floragun_gamma.ogg', 75, TRUE)
	if(!do_after(user, 0.5 SECONDS, user, DA_IGNORE_USER_LOC_CHANGE, progress = FALSE))
		return FALSE
	. = ..()

/obj/item/ammo_casing/energy/temp
	projectile_type = /obj/projectile/temp
	fire_sound = 'sound/weapons/gunshots/1laser7.ogg'
	var/temp = 300

/obj/item/ammo_casing/energy/temp/Initialize(mapload)
	. = ..()
	BB = null

/obj/item/ammo_casing/energy/temp/newshot()
	..(temp)

/obj/item/ammo_casing/energy/meteor
	projectile_type = /obj/projectile/meteor
	muzzle_flash_effect = /obj/effect/temp_visual/target_angled/muzzle_flash
	muzzle_flash_color = null
	select_name = "goddamn meteor"

/obj/item/ammo_casing/energy/disabler
	projectile_type = /obj/projectile/beam/disabler
	muzzle_flash_color = LIGHT_COLOR_LIGHTBLUE
	select_name  = "disable"
	e_cost = 50
	fire_sound = 'sound/weapons/plasma_cutter.ogg'
	harmful = FALSE
/obj/item/ammo_casing/energy/disabler/hos
	e_cost = 40

/obj/item/ammo_casing/energy/disabler/cyborg //seperate balancing for cyborg, again
	e_cost = 175

/obj/item/ammo_casing/energy/disabler/blueshield
	e_cost = 40

/obj/item/ammo_casing/energy/plasma
	projectile_type = /obj/projectile/plasma
	muzzle_flash_color = LIGHT_COLOR_PURPLE
	select_name = "plasma burst"
	fire_sound = 'sound/weapons/pulse.ogg'
	delay = 15
	e_cost = 50 //30 shots

/obj/item/ammo_casing/energy/plasma/adv
	projectile_type = /obj/projectile/plasma/adv
	delay = 10
	e_cost = 25 //60 shots

/obj/item/ammo_casing/energy/plasma/adv/mega
	e_cost = 20 //75 shots
	projectile_type = /obj/projectile/plasma/adv/mega

/obj/item/ammo_casing/energy/plasma/shotgun
	projectile_type = /obj/projectile/plasma/shotgun
	delay = 15
	e_cost = 75 //20 shots
	pellets = 5
	variance = 35

/obj/item/ammo_casing/energy/plasma/shotgun/mega
	e_cost = 50 //30 shots
	projectile_type = /obj/projectile/plasma/adv/mega/shotgun

/obj/item/ammo_casing/energy/wormhole
	projectile_type = /obj/projectile/beam/wormhole
	muzzle_flash_color = "#33CCFF"
	delay = 10
	e_cost = 100
	fire_sound = 'sound/weapons/pulse3.ogg'
	select_name = "blue"
	harmful = FALSE

/obj/item/ammo_casing/energy/wormhole/orange
	projectile_type = /obj/projectile/beam/wormhole/orange
	muzzle_flash_color = "#FF6600"
	select_name = "orange"

/obj/item/ammo_casing/energy/bolt
	projectile_type = /obj/projectile/energy/bolt
	muzzle_flash_color = null
	muzzle_flash_effect = /obj/effect/temp_visual/target_angled/muzzle_flash
	select_name = "bolt"
	e_cost = 500
	fire_sound = 'sound/weapons/gunshots/1heavysuppres.ogg'

/obj/item/ammo_casing/energy/bolt/bolttoy
	projectile_type = /obj/projectile/energy/bolttoy
	select_name = "bolttoy"

/obj/item/ammo_casing/energy/bolt/large
	projectile_type = /obj/projectile/energy/bolt/large
	select_name = "heavy bolt"

/obj/projectile/energy/bsg
	name = "Сфера чистой БС энергии"
	icon_state = "bluespace"
	impact_effect_type = /obj/effect/temp_visual/bsg_kaboom
	damage = 60
	damage_type = BURN
	range = 9
	weaken  = 8 SECONDS //This is going to knock you off your feet
	eyeblur = 20 SECONDS
	speed   = 2

/obj/item/ammo_casing/energy/bsg/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	..()
	var/obj/projectile/energy/bsg/P = BB
	addtimer(CALLBACK(P, TYPE_PROC_REF(/obj/projectile/energy/bsg, make_chain), P, user), 1)

/obj/projectile/energy/bsg/proc/make_chain(obj/projectile/P, mob/user)
	P.chain = P.Beam(user, icon_state = "sm_arc_supercharged", icon = 'icons/effects/beam.dmi', time = 10 SECONDS, maxdistance = 30)

/obj/projectile/energy/bsg/on_hit(atom/target)
	. = ..()
	kaboom()
	qdel(src)

/obj/projectile/energy/bsg/on_range()
	kaboom()
	new /obj/effect/temp_visual/bsg_kaboom(loc)
	..()

/obj/projectile/energy/bsg/proc/kaboom()
	playsound(src, 'sound/weapons/bsg_explode.ogg', 75, TRUE)
	for(var/mob/living/M in hearers(7, src)) //No stuning people with thermals through a wall.
		var/floored = FALSE
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/gun/energy/bsg/N = locate() in H
			if(N)
				to_chat(H, "<span class='notice'>[N] deploys an energy shield to project you from [src]'s explosion.</span>")
				continue
		var/distance = (1 + get_dist(M, src))
		if(prob(min(400 / distance, 100))) //100% chance to hit with the blast up to 3 tiles, after that chance to hit is 80% at 4 tiles, 66.6% at 5, 57% at 6, and 50% at 7
			if(prob(min(150 / distance, 100)))//100% chance to upgraded to a stun as well at a direct hit, 75% at 1 tile, 50% at 2, 37.5% at 3, 30% at 4, 25% at 5, 21% at 6, and finaly 19% at 7. This is calculated after the first hit however.
				floored = TRUE
			M.apply_damage((rand(15, 30) * (1.1 - distance / 10)), BURN) //reduced by 10% per tile
			add_attack_logs(src, M, "Hit heavily by [src]")
			if(floored)
				to_chat(M, "<span class='userdanger'>You see a flash of briliant blue light as [src] explodes, knocking you to the ground and burning you!</span>")
				M.Weaken(8 SECONDS)
			else
				to_chat(M, "<span class='userdanger'>You see a flash of briliant blue light as [src] explodes, burning you!</span>")
		else
			to_chat(M, "<span class='userdanger'>You feel the heat of the explosion of [src], but the blast mostly misses you.</span>")
			add_attack_logs(src, M, "Hit lightly by [src]")
			M.apply_damage(rand(1, 5), BURN)

/obj/item/ammo_casing/energy/dart
	projectile_type = /obj/projectile/energy/dart
	fire_sound = 'sound/weapons/genhit.ogg'
	e_cost = 500
	select_name = "toxic dart"

/obj/item/ammo_casing/energy/instakill
	projectile_type = /obj/projectile/beam/instakill
	muzzle_flash_color = LIGHT_COLOR_PURPLE
	e_cost = 0
	select_name = "DESTROY"
	fire_sound = 'sound/weapons/marauder.ogg'

/obj/item/ammo_casing/energy/instakill/blue
	projectile_type = /obj/projectile/beam/instakill/blue
	muzzle_flash_color = LIGHT_COLOR_DARKBLUE

/obj/item/ammo_casing/energy/instakill/red
	projectile_type = /obj/projectile/beam/instakill/red
	muzzle_flash_color = LIGHT_COLOR_DARKRED

/obj/item/ammo_casing/energy/shock_revolver
	fire_sound = 'sound/magic/lightningbolt.ogg'
	e_cost = 200
	select_name = "lightning beam"
	muzzle_flash_color = LIGHT_COLOR_FADEDPURPLE
	projectile_type = /obj/projectile/energy/shock_revolver

/obj/item/ammo_casing/energy/toxplasma
	projectile_type = /obj/projectile/energy/toxplasma
	muzzle_flash_color = LIGHT_COLOR_FADEDPURPLE
	fire_sound = 'sound/weapons/gunshots/1plasma.ogg'
	select_name = "plasma dart"

/obj/item/ammo_casing/energy/weak_plasma
	projectile_type = /obj/projectile/energy/weak_plasma
	e_cost = 60 // With no charging, 500 damage from 25 shots.
	muzzle_flash_color = LIGHT_COLOR_FADEDPURPLE
	fire_sound = 'sound/weapons/gunshots/1plasma.ogg'
	select_name = null //If the select name is null, it does not send a message of switching modes to the user, important on the pistol.

/obj/item/ammo_casing/energy/charged_plasma
	projectile_type = /obj/projectile/energy/charged_plasma
	e_cost = 0 //Charge is used when you charge the gun. Prevents issues.
	muzzle_flash_color = LIGHT_COLOR_FADEDPURPLE
	fire_sound = 'sound/weapons/marauder.ogg' //Should be different enough to get attention
	select_name = null

/obj/item/ammo_casing/energy/clown
	projectile_type = /obj/projectile/clown
	muzzle_flash_effect = null
	fire_sound = 'sound/weapons/gunshots/gunshot_smg.ogg'
	select_name = "clown"

/obj/item/ammo_casing/energy/bsg
	projectile_type = /obj/projectile/energy/bsg
	muzzle_flash_color = LIGHT_COLOR_DARKBLUE
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	fire_sound = 'sound/weapons/wave.ogg'
	e_cost = 10000
	select_name = null //No one is sticking this into another gun / so I don't have to rename 20 icon states
	delay = 4 SECONDS //Looooooong cooldown // Used to be 10 seconds, has been rebalanced to be normal firing rate now

/obj/item/ammo_casing/energy/sniper
	projectile_type = /obj/projectile/beam/sniper
	muzzle_flash_color = LIGHT_COLOR_PINK
	fire_sound = 'sound/weapons/marauder.ogg'
	delay = 50
	select_name = "snipe"

/obj/item/ammo_casing/energy/podsniper/disabler
	projectile_type = /obj/projectile/beam/podsniper/disabler
	muzzle_flash_color = LIGHT_COLOR_LIGHTBLUE
	fire_sound = 'sound/weapons/LSR-39_disabler.ogg'
	delay = 3 SECONDS
	e_cost = 100
	select_name = "disable"

/obj/item/ammo_casing/energy/podsniper/laser
	projectile_type = /obj/projectile/beam/podsniper/laser
	muzzle_flash_color = LIGHT_COLOR_DARKRED
	fire_sound = 'sound/weapons/LSR-39_kill.ogg'
	delay = 3 SECONDS
	e_cost = 150
	select_name = "kill"

/obj/item/ammo_casing/energy/teleport
	projectile_type = /obj/projectile/energy/teleport
	muzzle_flash_color = LIGHT_COLOR_LIGHTBLUE
	fire_sound = 'sound/weapons/wave.ogg'
	e_cost = 250
	select_name = "teleport beam"
	var/teleport_target

/obj/item/ammo_casing/energy/teleport/New()
	..()
	BB = null

/obj/item/ammo_casing/energy/teleport/newshot()
	..(teleport_target)

/obj/item/ammo_casing/energy/mimic
	projectile_type = /obj/projectile/mimic
	muzzle_flash_effect = null
	fire_sound = 'sound/weapons/bite.ogg'
	select_name = "gun mimic"
	var/mimic_type

/obj/item/ammo_casing/energy/mimic/New()
	..()
	BB = null

/obj/item/ammo_casing/energy/mimic/newshot()
	..(mimic_type)

/obj/item/ammo_casing/energy/dominator/stun
	projectile_type = /obj/projectile/energy/electrode/dominator
	muzzle_flash_color = LIGHT_COLOR_LIGHTBLUE
	select_name = "taser"
	fluff_select_name = "stun"
	fire_sound = 'sound/weapons/gunshots/1taser.ogg'
	e_cost = 250
	delay = 15
	harmful = FALSE

/obj/item/ammo_casing/energy/dominator/paralyzer
	projectile_type = /obj/projectile/beam/dominator/paralyzer
	muzzle_flash_color = LIGHT_COLOR_LIGHTBLUE
	select_name = "disable"
	fluff_select_name  = "non-lethal paralyzer"
	fire_sound = 'sound/weapons/plasma_cutter.ogg'
	e_cost = 100
	harmful = FALSE

/obj/item/ammo_casing/energy/dominator/eliminator
	projectile_type = /obj/projectile/beam/dominator/eliminator
	muzzle_flash_color = LIGHT_COLOR_DARKBLUE
	select_name = "lethal"
	fluff_select_name = "lethal-eliminator"
	fire_sound = 'sound/weapons/gunshots/1laser10.ogg'
	e_cost = 200

/obj/item/ammo_casing/energy/dominator/slaughter
	projectile_type = /obj/projectile/beam/dominator/slaughter
	muzzle_flash_color = LIGHT_COLOR_DARKBLUE
	select_name = "destroy"
	fluff_select_name  = "execution-slaughter"
	fire_sound = 'sound/weapons/marauder.ogg'
	e_cost = 250
	delay = 30

/obj/item/ammo_casing/energy/emittergun
	projectile_type = /obj/projectile/beam/emitter
	e_cost = 200
	fire_sound = 'sound/weapons/emitter.ogg'
	delay = 25
	muzzle_flash_color = LIGHT_COLOR_GREEN
	select_name  = "emitter"

/obj/item/ammo_casing/energy/emittergunborg
	projectile_type = /obj/projectile/beam/emitter
	fire_sound = 'sound/weapons/emitter.ogg'
	delay = 30
	muzzle_flash_color = LIGHT_COLOR_GREEN
	select_name  = "emitter"
	e_cost = 750
