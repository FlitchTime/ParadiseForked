/obj/item/seeds/nettle
	name = "pack of nettle seeds"
	desc = "These seeds grow into nettles."
	icon_state = "seed-nettle"
	species = "nettle"
	plantname = "Nettles"
	product = /obj/item/grown/nettle/basic
	lifespan = 30
	endurance = 40 // tuff like a toiger
	yield = 4
	growthstages = 5
	genes = list(/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/plant_type/weed_hardy)
	mutatelist = list(/obj/item/seeds/nettle/death)
	reagents_add = list("sacid" = 0.5)

/obj/item/seeds/nettle/death
	name = "pack of death-nettle seeds"
	desc = "These seeds grow into death-nettles."
	icon_state = "seed-deathnettle"
	species = "deathnettle"
	plantname = "Death Nettles"
	product = /obj/item/grown/nettle/death
	endurance = 25
	maturation = 8
	yield = 2
	genes = list(/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/plant_type/weed_hardy, /datum/plant_gene/trait/stinging)
	mutatelist = list()
	reagents_add = list("facid" = 0.5, "sacid" = 0.5)
	rarity = 20

/obj/item/grown/nettle //abstract type
	name = "nettle"
	desc = "It's probably <b>not</b> wise to touch it with bare hands..."
	icon = 'icons/obj/items.dmi'
	icon_state = "nettle"
	damtype = "fire"
	force = 15
	hitsound = 'sound/weapons/bladeslice.ogg'
	throwforce = 5
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 1
	throw_range = 3
	origin_tech = "combat=3"
	attack_verb = list("ужалил")

/obj/item/grown/nettle/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is eating some of the [src.name]! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	return BRUTELOSS|TOXLOSS

/obj/item/grown/nettle/pickup(mob/living/user)
	. = ..()
	if(!ishuman(user))
		return TRUE
	var/mob/living/carbon/human/H = user
	var/obj/item/clothing/gloves = H.gloves
	if(isclothing(gloves) && gloves.clothing_flags & FINGERS_COVERED)
		return TRUE
	if(HAS_TRAIT(H, TRAIT_PIERCEIMMUNE))
		return TRUE
	H.apply_damage(force, BURN, def_zone = H.hand ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
	to_chat(H, "<span class='userdanger'>The nettle burns your bare hand!</span>")
	return TRUE

/obj/item/grown/nettle/afterattack(atom/A, mob/user, proximity, params)
	if(!proximity)
		return
	if(force > 0)
		force -= rand(1, (force / 3) + 1) // When you whack someone with it, leaves fall off
	else
		to_chat(usr, "All the leaves have fallen off the nettle from violent whacking.")
		usr.temporarily_remove_item_from_inventory(src)
		qdel(src)

/obj/item/grown/nettle/basic
	seed = /obj/item/seeds/nettle

/obj/item/grown/nettle/basic/add_juice()
	..()
	force = round((5 + seed.potency / 5), 1)

/obj/item/grown/nettle/death
	seed = /obj/item/seeds/nettle/death
	name = "deathnettle"
	desc = "The <span class='danger'>glowing</span> nettle incites <span class='boldannounceic'>rage</span> in you just from looking at it!"
	icon_state = "deathnettle"
	force = 30
	throwforce = 15
	origin_tech = "combat=5"

/obj/item/grown/nettle/death/add_juice()
	..()
	force = round((5 + seed.potency / 2.5), 1)

/obj/item/grown/nettle/death/pickup(mob/living/carbon/user)
	if(ishuman(user)) // If the pickup succeeded and is humanoid
		var/mob/living/carbon/human/H = user
		if(HAS_TRAIT(H, TRAIT_PIERCEIMMUNE))
			return ..()
		var/obj/item/clothing/gloves = H.gloves
		if((!isclothing(gloves) || !(gloves.clothing_flags & FINGERS_COVERED)) && prob(50))
			user.Paralyse(4 SECONDS)
			to_chat(user, span_userdanger("You are stunned by the Deathnettle when you try picking it up!"))
			return FALSE
	return ..()


/obj/item/grown/nettle/death/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.))
		return .

	to_chat(target, span_danger("You are stunned by the powerful acid of the Deathnettle!"))
	add_attack_logs(user, target, "Hit with [src]")
	target.AdjustEyeBlurry((force / 7) STATUS_EFFECT_CONSTANT)
	target.drop_from_active_hand()
	if(prob(20))
		target.Paralyse(2 SECONDS)

