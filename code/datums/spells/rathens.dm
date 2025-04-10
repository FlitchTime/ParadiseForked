/obj/effect/proc_holder/spell/rathens
	name = "Rathen's Secret"
	desc = "Summons a powerful shockwave around you that tears the appendix out of enemies, and occasionally removes their limbs."
	base_cooldown = 50 SECONDS
	cooldown_min = 20 SECONDS
	clothes_req = TRUE
	invocation = "APPEN NATH!"
	invocation_type = "shout"
	action_icon_state = "lungpunch"


/obj/effect/proc_holder/spell/rathens/create_new_targeting()
	var/datum/spell_targeting/targeted/T = new()
	T.max_targets = INFINITY
	return T


/obj/effect/proc_holder/spell/rathens/cast(list/targets, mob/user = usr)
	for(var/mob/living/carbon/human/H in targets)
		var/datum/effect_system/fluid_spread/smoke/s = new
		s.set_up(amount = 5, location = H)
		s.start()
		var/obj/item/organ/internal/appendix/A = H.get_int_organ(/obj/item/organ/internal/appendix)
		if(A)
			A.remove(H)
			A.forceMove(get_turf(H))
			spawn()
				A.throw_at(get_edge_target_turf(H, pick(GLOB.alldirs)), rand(1, 10), 5)
			H.visible_message("<span class='danger'>[H]'s [A.name] flies out of their body in a magical explosion!</span>",\
							  "<span class='danger'>Your [A.name] flies out of your body in a magical explosion!</span>")
			H.Weaken(4 SECONDS)
		else
			var/obj/effect/decal/cleanable/blood/gibs/G = new/obj/effect/decal/cleanable/blood/gibs(get_turf(H))
			spawn()
				G.throw_at(get_edge_target_turf(H, pick(GLOB.alldirs)), rand(1, 10), 5)
			H.apply_damage(10, BRUTE, BODY_ZONE_CHEST)
			to_chat(H, "<span class='userdanger'>You have no appendix, but something had to give! Holy shit, what was that?</span>")
			H.Weaken(6 SECONDS)
			for(var/obj/item/organ/external/E as anything in H.bodyparts)
				if(istype(E, /obj/item/organ/external/head))
					continue
				if(istype(E, /obj/item/organ/external/chest))
					continue
				if(istype(E, /obj/item/organ/external/groin))
					continue
				if(prob(7))
					to_chat(H, "<span class='userdanger'>Your [E] was severed by the explosion!</span>")
					E.droplimb(1, DROPLIMB_SHARP, 0, 1)
