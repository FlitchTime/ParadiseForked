
//objects in /obj/effect should never be things that are attackable, use obj/structure instead.
//Effects are mostly temporary visual effects like sparks, smoke, as well as decals, etc...

/obj/effect
	icon = 'icons/effects/effects.dmi'
	obj_flags = IGNORE_HITS
	resistance_flags = INDESTRUCTIBLE|LAVA_PROOF|FIRE_PROOF|UNACIDABLE|ACID_PROOF|FREEZE_PROOF
	move_resist = INFINITY
	anchored = TRUE


/obj/effect/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	return

/obj/effect/singularity_act()
	qdel(src)
	return FALSE

/obj/effect/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	return

/obj/effect/acid_act()
	return

/obj/effect/proc/is_cleanable() //Called when you want to clean something, and usualy delete it after
	return FALSE

/obj/effect/mech_melee_attack(obj/mecha/M)
	return 0

/obj/effect/blob_act(obj/structure/blob/B)
	return

/obj/effect/experience_pressure_difference()
	return

/obj/effect/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if(prob(60))
				qdel(src)
		if(3)
			if(prob(25))
				qdel(src)


/obj/effect/hit_by_thrown_carbon(mob/living/carbon/human/C, datum/thrownthing/throwingdatum, damage, mob_hurt, self_hurt)
	return


/**
 * # The abstract object
 *
 * This is an object that is intended to able to be placed, but that is completely invisible.
 * The object should be immune to all forms of damage, or things that can delete it, such as the singularity, or explosions.
 */
/obj/effect/abstract
	name = "Abstract object"
	invisibility = INVISIBILITY_ABSTRACT
	layer = TURF_LAYER
	density = FALSE
	icon = null
	icon_state = null
	armor = list(MELEE = 100, BULLET = 100, LASER = 100, ENERGY = 100, BOMB = 100, BIO = 100, RAD = 100, FIRE = 100, ACID = 100)

// Most of these overrides procs below are overkill, but better safe than sorry.
/obj/effect/abstract/swarmer_act()
	return

/obj/effect/abstract/bullet_act(obj/projectile/P)
	return

/obj/effect/abstract/decompile_act(obj/item/matter_decompiler/C, mob/user)
	return

/obj/effect/abstract/tesla_act(power)
	return

/obj/effect/abstract/singularity_act()
	return

/obj/effect/abstract/has_gravity()
	return

/obj/effect/abstract/narsie_act()
	return

/obj/effect/abstract/ratvar_act()
	return

/obj/effect/abstract/ex_act(severity)
	return

/obj/effect/abstract/blob_act()
	return

/obj/effect/abstract/acid_act()
	return

/obj/effect/abstract/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	return

/obj/effect/abstract/has_gravity(turf/gravity_turf)
	return FALSE

/obj/effect/decal
	plane = FLOOR_PLANE
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/no_scoop = FALSE   //if it has this, don't let it be scooped up
	var/no_clear = FALSE    //if it has this, don't delete it when its' scooped up
	var/list/scoop_reagents = null

/obj/effect/decal/Initialize(mapload)
	. = ..()
	create_reagents(100)
	if(scoop_reagents)
		reagents.add_reagent_list(scoop_reagents)


/obj/effect/decal/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers/glass) || istype(I, /obj/item/reagent_containers/food/drinks))
		add_fingerprint(user)
		scoop(I, user)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ATTACK_CHAIN_PROCEED


/obj/effect/decal/proc/scoop(obj/item/I, mob/user)
	if(reagents && I.reagents && !no_scoop)
		if(!reagents.total_volume)
			to_chat(user, "<span class='notice'>There isn't enough [src] to scoop up!</span>")
			return
		if(I.reagents.total_volume >= I.reagents.maximum_volume)
			to_chat(user, "<span class='notice'>[I] is full!</span>")
			return
		to_chat(user, "<span class='notice'>You scoop [src] into [I]!</span>")
		reagents.trans_to(I, reagents.total_volume)
		if(!reagents.total_volume && !no_clear) //scooped up all of it
			qdel(src)

/obj/effect/decal/ex_act()
	if(reagents)
		for(var/datum/reagent/R in reagents.reagent_list)
			R.on_ex_act()
	qdel(src)

/obj/effect/decal/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	if(reagents)
		reagents.temperature_reagents(exposed_temperature)
	if(!(resistance_flags & FIRE_PROOF)) //non fire proof decal or being burned by lava
		qdel(src)

/obj/effect/decal/blob_act(obj/structure/blob/B)
	if(B && B.loc == loc && !QDELETED(src))
		qdel(src)
