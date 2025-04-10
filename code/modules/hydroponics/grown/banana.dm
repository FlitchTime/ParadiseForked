// Banana
/obj/item/seeds/banana
	name = "pack of banana seeds"
	desc = "They're seeds that grow into banana trees. When grown, keep away from clown."
	icon_state = "seed-banana"
	species = "banana"
	plantname = "Banana Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/banana
	lifespan = 50
	endurance = 30
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_dead = "banana-dead"
	genes = list(/datum/plant_gene/trait/slip, /datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/banana/mime, /obj/item/seeds/banana/bluespace)
	reagents_add = list("banana" = 0.1, "potassium" = 0.1, "vitamin" = 0.04, "plantmatter" = 0.02)

/obj/item/reagent_containers/food/snacks/grown/banana
	seed = /obj/item/seeds/banana
	name = "banana"
	desc = "It's an excellent prop for a clown."
	icon_state = "banana"
	trash = /obj/item/grown/bananapeel
	filling_color = "#FFFF00"
	bitesize = 5
	distill_reagent = "bananahonk"
	tastes = list("banana" = 1)


/obj/item/reagent_containers/food/snacks/grown/banana/throw_impact(mob/living/simple_animal/hostile/gorilla/hit_gorilla, datum/thrownthing/throwingdatum)
	if(istype(hit_gorilla))
		if(!hit_gorilla.can_befriend || hit_gorilla.is_on_cooldown())
			return ..()
		var/mob/thrower = locateUID(thrownby)
		hit_gorilla.start_action_cooldown()
		if(hit_gorilla.master && hit_gorilla.master != thrower)
			if(hit_gorilla.master in view(hit_gorilla))
				hit_gorilla.face_atom(hit_gorilla.master)
				hit_gorilla.custom_emote(EMOTE_VISIBLE, "кос%(ит,ят)%ся на банан, а затем моляще смотр%(ит,ят)% на [hit_gorilla.master].", intentional = TRUE)
			else
				hit_gorilla.custom_emote(EMOTE_VISIBLE, "броса%(ет,ют)% беглый взгляд на банан, а затем оглядыва%(ет,ют)%ся в поисках [hit_gorilla.master].", intentional = TRUE)
			return ..()
		hit_gorilla.eat_banana(src, thrower, throw_impact = TRUE)
	else
		return ..()


/obj/item/reagent_containers/food/snacks/grown/banana/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is aiming the [name] at [user.p_them()]self! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	playsound(loc, 'sound/items/bikehorn.ogg', 50, 1, -1)
	sleep(25)
	if(!user)
		return OXYLOSS
	user.say("BANG!")
	sleep(25)
	if(!user)
		return OXYLOSS
	user.visible_message("<b>[user]</b> laughs so hard [user.p_they()] begin[user.p_s()] to suffocate!")
	return OXYLOSS

/obj/item/grown/bananapeel
	seed = /obj/item/seeds/banana
	name = "banana peel"
	desc = "A peel from a banana."
	icon_state = "banana_peel"
	item_state = "banana_peel"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_speed = 3
	throw_range = 7

/obj/item/grown/bananapeel/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is deliberately slipping on the [src.name]! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	playsound(loc, 'sound/misc/slip.ogg', 50, 1, -1)
	return BRUTELOSS


// Mimana - invisible sprites are totally a feature!
/obj/item/seeds/banana/mime
	name = "pack of mimana seeds"
	desc = "They're seeds that grow into mimana trees. When grown, keep away from mime."
	icon_state = "seed-mimana"
	species = "mimana"
	plantname = "Mimana Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/banana/mime
	growthstages = 4
	mutatelist = list()
	reagents_add = list("nothing" = 0.1, "capulettium_plus" = 0.1, "nutriment" = 0.02)
	rarity = 15

/obj/item/reagent_containers/food/snacks/grown/banana/mime
	seed = /obj/item/seeds/banana/mime
	name = "mimana"
	desc = "It's an excellent prop for a mime."
	icon_state = "mimana"
	trash = /obj/item/grown/bananapeel/mimanapeel
	filling_color = "#FFFFEE"
	distill_reagent = "silencer"

/obj/item/grown/bananapeel/mimanapeel
	seed = /obj/item/seeds/banana/mime
	name = "mimana peel"
	desc = "A mimana peel."
	icon_state = "mimana_peel"

// Bluespace Banana
/obj/item/seeds/banana/bluespace
	name = "pack of bluespace banana seeds"
	desc = "They're seeds that grow into bluespace banana trees. When grown, keep away from bluespace clown."
	icon_state = "seed-banana-blue"
	species = "bluespacebanana"
	icon_grow = "banana-grow"
	plantname = "Bluespace Banana Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/banana/bluespace
	mutatelist = list()
	genes = list(/datum/plant_gene/trait/slip, /datum/plant_gene/trait/teleport, /datum/plant_gene/trait/repeated_harvest)
	reagents_add = list("singulo" = 0.2, "banana" = 0.1, "vitamin" = 0.04, "plantmatter" = 0.02)
	rarity = 30

/obj/item/reagent_containers/food/snacks/grown/banana/bluespace
	seed = /obj/item/seeds/banana/bluespace
	name = "bluespace banana"
	icon_state = "banana_blue"
	trash = /obj/item/grown/bananapeel/bluespace
	filling_color = "#0000FF"
	origin_tech = "biotech=3;bluespace=5"
	wine_power = 0.6
	wine_flavor = "slippery hypercubes"

/obj/item/grown/bananapeel/bluespace
	seed = /obj/item/seeds/banana/bluespace
	name = "bluespace banana peel"
	desc = "A peel from a bluespace banana."
	icon_state = "banana_peel_blue"

// Other
/obj/item/grown/bananapeel/specialpeel     //used by /obj/item/clothing/shoes/clown_shoes/banana_shoes
	name = "synthesized banana peel"
	desc = "A synthetic banana peel."

/obj/item/grown/bananapeel/specialpeel/New()
	. = ..()
	// The reason this AddComponent is here and not in ComponentInitialize() is because if it's put there, it will be ran before the parent New proc for /grown types.
	// And then be overriden by the generic component placed onto it by the `/datum/plant_gene/trait/slip`
	AddComponent(/datum/component/slippery, 4 SECONDS, 0, NONE, CALLBACK(src, PROC_REF(after_slip)))

/obj/item/grown/bananapeel/specialpeel/proc/after_slip()
	qdel(src)
