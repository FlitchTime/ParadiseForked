//the essential proc to call when an obj must receive damage of any kind.
/obj/proc/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration = 0)
	if(QDELETED(src))
		stack_trace("[src] taking damage after deletion")
		return
	if(sound_effect)
		play_attack_sound(damage_amount, damage_type, damage_flag)
	if((resistance_flags & INDESTRUCTIBLE) || obj_integrity <= 0)
		return
	damage_amount = run_obj_armor(damage_amount, damage_type, damage_flag, attack_dir, armour_penetration)
	if(damage_amount < DAMAGE_PRECISION)
		return
	. = damage_amount
	obj_integrity = max(obj_integrity - damage_amount, 0)
	//BREAKING FIRST
	if(integrity_failure && obj_integrity <= integrity_failure)
		obj_break(damage_flag)
	//DESTROYING SECOND
	if(obj_integrity <= 0)
		obj_destruction(damage_flag)

///returns the damage value of the attack after processing the obj's various armor protections
/obj/proc/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir, armour_penetration = 0)
	if(damage_flag == "melee" && damage_amount < damage_deflection)
		return 0
	switch(damage_type)
		if(BRUTE)
		if(BURN)
		else
			return 0
	var/armor_protection = 0
	if(damage_flag)
		armor_protection = armor.getRating(damage_flag)
	if(armor_protection)		//Only apply weak-against-armor/hollowpoint effects if there actually IS armor.
		armor_protection = clamp(armor_protection - armour_penetration, min(armor_protection, 0), 100)
	return round(damage_amount * (100 - armor_protection) * 0.01, DAMAGE_PRECISION)


/// Proc for recovering atom_integrity. Returns the amount repaired by
/obj/proc/repair_damage(amount)
	if(amount <= 0) // We only recover here
		return
	var/new_integrity = min(max_integrity, obj_integrity + amount)
	. = new_integrity - obj_integrity

	update_integrity(new_integrity)


/// Handles the integrity of an obj changing. This must be called instead of changing integrity directly.
/obj/proc/update_integrity(new_value)
	SHOULD_NOT_OVERRIDE(TRUE)
	var/old_value = obj_integrity
	new_value = max(0, new_value)
	if(obj_integrity == new_value)
		return
	obj_integrity = new_value
	on_update_integrity(old_value, new_value)
	return new_value

/// Handle updates to your obj's integrity
/obj/proc/on_update_integrity(old_value, new_value)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_OBJ_INTEGRITY_CHANGED, old_value, new_value)

/// This mostly exists to keep obj_integrity private. Might be useful in the future.
/obj/proc/get_integrity()
	SHOULD_BE_PURE(TRUE)
	return obj_integrity

/// Similar to get_integrity, but returns the percentage as [0-1] instead.
/obj/proc/get_integrity_percentage()
	SHOULD_BE_PURE(TRUE)
	return round(obj_integrity / max_integrity, 0.01)

///the sound played when the obj is damaged.
/obj/proc/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/weapons/smash.ogg', 50, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	..()
	take_damage(AM.throwforce, BRUTE, "melee", 1, get_dir(src, AM))

/obj/ex_act(severity)
	if(QDELETED(src))
		return
	if(resistance_flags & INDESTRUCTIBLE)
		return
	switch(severity)
		if(1)
			take_damage(INFINITY, BRUTE, "bomb", 0)
		if(2)
			take_damage(rand(100, 250), BRUTE, "bomb", 0)
		if(3)
			take_damage(rand(10, 90), BRUTE, "bomb", 0)

/obj/bullet_act(obj/projectile/P)
	. = ..()
	playsound(src, P.hitsound, 50, TRUE)
	visible_message(span_danger("[src] is hit by \a [P]!"), projectile_message = TRUE)
	if(!QDELETED(src)) //Bullet on_hit effect might have already destroyed this object
		take_damage(P.damage, P.damage_type, P.flag, 0, turn(P.dir, 180), P.armour_penetration)


/obj/blob_act(obj/structure/blob/B)
	if(!..() || (obj_flags & IGNORE_BLOB_ACT))
		return
	if(isturf(loc))
		var/turf/T = loc
		if((T.intact && level == 1) || T.transparent_floor == TURF_TRANSPARENT) //the blob doesn't destroy thing below the floor
			return
	take_damage(400, BRUTE, MELEE, 0, get_dir(src, B))


/obj/proc/attack_generic(mob/user, damage_amount = 0, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, armor_penetration = 0) //used by attack_alien, attack_animal, and attack_slime
	user.do_attack_animation(src)
	user.changeNext_move(CLICK_CD_MELEE)
	return take_damage(damage_amount, damage_type, damage_flag, sound_effect, get_dir(src, user), armor_penetration)

/obj/attack_alien(mob/living/carbon/alien/humanoid/user)
	if(attack_generic(user, user.obj_damage, BRUTE, "melee", 0, user.armour_penetration))
		playsound(loc, 'sound/weapons/slash.ogg', 100, TRUE)

/obj/attack_basic_mob(mob/living/basic/user)
	if(!user.melee_damage && !user.obj_damage) //No damage
		user.emote("custom", message = "[user.friendly_verb_continuous] [src].")
		return FALSE

	if(GLOB.pacifism_after_gt || HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, span_notice("Немного подумав, Вы решаете не трогать [src]."))
		return FALSE

	else
		if(user.obj_damage)
			. = attack_generic(user, user.obj_damage, user.melee_damage_type, MELEE, TRUE, user.armour_penetration)
		else
			. = attack_generic(user, user.melee_damage, user.melee_damage_type, MELEE, TRUE, user.armour_penetration)
		if(.)
			playsound(src, 'sound/effects/meteorimpact.ogg', 100, TRUE)

/obj/attack_animal(mob/living/simple_animal/M)
	if((M.a_intent == INTENT_HELP && M.ckey) || (!M.melee_damage_upper && !M.obj_damage))
		M.custom_emote(EMOTE_VISIBLE, "[M.friendly] [src].")
		return FALSE

	if(GLOB.pacifism_after_gt || HAS_TRAIT(M, TRAIT_PACIFISM))
		to_chat(M, span_notice("Немного подумав, Вы решаете не трогать [src]."))
		return FALSE

	var/play_soundeffect = !M.environment_smash
	var/turf/source_turf = get_turf(src)  // play from the turf in case the object gets deleted mid attack
	if(M.obj_damage)
		. = attack_generic(M, M.obj_damage, M.melee_damage_type, MELEE, play_soundeffect, M.armour_penetration)
	else
		. = attack_generic(M, rand(M.melee_damage_lower,M.melee_damage_upper), M.melee_damage_type, MELEE, play_soundeffect, M.armour_penetration)
	if(. && !play_soundeffect)
		playsound(QDELETED(src) ? source_turf : src, 'sound/effects/meteorimpact.ogg', 100, TRUE)


/obj/force_pushed(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	return TRUE

/obj/move_crushed(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	collision_damage(pusher, force, direction)
	return TRUE

/obj/proc/collision_damage(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	var/amt = max(0, ((force - (move_resist * MOVE_FORCE_CRUSH_RATIO)) / (move_resist * MOVE_FORCE_CRUSH_RATIO)) * 10)
	take_damage(amt, BRUTE)

/obj/attack_slime(mob/living/simple_animal/slime/user)
	if(user.age_state.age == SLIME_BABY )
		return
	attack_generic(user, rand(5 + user.age_state.damage, 10 + user.age_state.damage), BRUTE, "melee", 1)

/obj/mech_melee_attack(obj/mecha/M)
	M.do_attack_animation(src)
	var/play_soundeffect = 0
	var/mech_damtype = M.damtype
	if(M.selected)
		mech_damtype = M.selected.damtype
		play_soundeffect = 1
	else
		switch(M.damtype)
			if(BRUTE)
				playsound(src, 'sound/weapons/punch4.ogg', 50, TRUE)
			if(BURN)
				playsound(src, 'sound/items/welder.ogg', 50, TRUE)
			if(TOX)
				playsound(src, 'sound/effects/spray2.ogg', 50, TRUE)
				return 0
			else
				return 0
	M.visible_message("<span class='danger'>[M.name] hits [src]!</span>", "<span class='danger'>You hit [src]!</span>")
	return take_damage(M.force*3, mech_damtype, "melee", play_soundeffect, get_dir(src, M)) // multiplied by 3 so we can hit objs hard but not be overpowered against mobs.

/obj/singularity_act()
	ex_act(EXPLODE_DEVASTATE)
	if(src && !QDELETED(src))
		qdel(src)
	return 2

///// ACID

GLOBAL_DATUM_INIT(acid_overlay, /mutable_appearance, mutable_appearance('icons/effects/effects.dmi', "acid"))

///the obj's reaction when touched by acid
/obj/acid_act(acidpwr, acid_volume)
	if(!(resistance_flags & UNACIDABLE) && acid_volume)

		if(!acid_level)
			SSacid.processing[src] = src
			add_overlay(GLOB.acid_overlay)
		var/acid_cap = acidpwr * 300 //so we cannot use huge amounts of weak acids to do as well as strong acids.
		if(acid_level < acid_cap)
			acid_level = min(acid_level + acidpwr * acid_volume, acid_cap)
		return 1

///the proc called by the acid subsystem to process the acid that's on the obj
/obj/proc/acid_processing()
	. = TRUE
	if(!(resistance_flags & ACID_PROOF))
		if(prob(33))
			playsound(loc, 'sound/items/welder.ogg', 150, TRUE)
		take_damage(min(1 + round(sqrt(acid_level) * 0.3), 300), BURN, "acid", 0)

	acid_level = max(acid_level - (5 + 3 * round(sqrt(acid_level))), 0)
	if(!acid_level)
		return FALSE

///called when the obj is destroyed by acid.
/obj/proc/acid_melt()
	SSacid.processing -= src
	deconstruct(FALSE)

//// FIRE

/obj/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	if(isturf(loc))
		var/turf/T = loc
		if((T.intact && level == 1) || T.transparent_floor == TURF_TRANSPARENT) //fire can't damage things hidden below the floor.
			return
	..()
	if(QDELETED(src)) // no taking damage after deletion
		return
	if(exposed_temperature && !(resistance_flags & FIRE_PROOF))
		take_damage(clamp(0.02 * exposed_temperature, 0, 20), BURN, "fire", 0)
	if(!(resistance_flags & ON_FIRE) && (resistance_flags & FLAMMABLE) && !(resistance_flags & FIRE_PROOF))
		resistance_flags |= ON_FIRE
		SSfires.processing[src] = src
		add_overlay(custom_fire_overlay ? custom_fire_overlay : GLOB.fire_overlay)
		return TRUE

///called when the obj is destroyed by fire
/obj/proc/burn()
	if(resistance_flags & ON_FIRE)
		SSfires.processing -= src
	deconstruct(FALSE)

///Called when the obj is no longer on fire.
/obj/proc/extinguish()
	if(resistance_flags & ON_FIRE)
		resistance_flags &= ~ON_FIRE
		cut_overlay(custom_fire_overlay ? custom_fire_overlay : GLOB.fire_overlay, TRUE)
		SSfires.processing -= src

///Called when the obj is hit by a tesla bolt.
/obj/proc/tesla_act(power)
	being_shocked = TRUE
	var/power_bounced = power * 0.5
	tesla_zap(src, 3, power_bounced)
	addtimer(CALLBACK(src, PROC_REF(reset_shocked)), 10)

/obj/proc/reset_shocked()
	being_shocked = FALSE

//the obj is deconstructed into pieces, whether through careful disassembly or when destroyed.
/obj/proc/deconstruct(disassembled = TRUE)
	SEND_SIGNAL(src, COMSIG_OBJ_DECONSTRUCT, disassembled)
	qdel(src)

//what happens when the obj's health is below integrity_failure level.
/obj/proc/obj_break(damage_flag)
	return

///what happens when the obj's integrity reaches zero.
/obj/proc/obj_destruction(damage_flag)
	if(damage_flag == "acid")
		acid_melt()
	else if(damage_flag == "fire")
		burn()
	else
		deconstruct(FALSE)

///changes max_integrity while retaining current health percentage, returns TRUE if the obj got broken.
/obj/proc/modify_max_integrity(new_max, can_break = TRUE, damage_type = BRUTE, new_failure_integrity = null)
	var/current_integrity = obj_integrity
	var/current_max = max_integrity

	if(current_integrity != 0 && current_max != 0)
		var/percentage = current_integrity / current_max
		current_integrity = max(1, round(percentage * new_max))	//don't destroy it as a result
		obj_integrity = current_integrity

	max_integrity = new_max

	if(new_failure_integrity != null)
		integrity_failure = new_failure_integrity

	if(can_break && integrity_failure && current_integrity <= integrity_failure)
		obj_break(damage_type)
		return TRUE
	return FALSE

///Only tesla coils, vehicles, and grounding rods currently call this because mobs are already targeted over all other objects, but this might be useful for more things later.
/obj/proc/zap_buckle_check(strength)
	if(has_buckled_mobs())
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			buckled_mob.electrocute_act((clamp(round(strength * 1.25e-3), 10, 90) + rand(-5, 5)), src, flags = SHOCK_TESLA)

