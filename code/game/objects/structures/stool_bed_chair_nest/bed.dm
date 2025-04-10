/* Beds... get your mind out of the gutter, they're for sleeping!
 * Contains:
 * 		Beds
 *		Roller beds
 *		Dog Beds
 */

/*
 * Beds
 */

/obj/structure/bed
	name = "bed"
	desc = "This is used to lie in, sleep in or strap on."
	gender = FEMALE
	icon = 'icons/obj/objects.dmi'
	icon_state = "bed"
	can_buckle = TRUE
	anchored = TRUE
	buckle_lying = 90
	resistance_flags = FLAMMABLE
	layer = BELOW_OBJ_LAYER
	max_integrity = 100
	integrity_failure = 30
	var/buildstacktype = /obj/item/stack/sheet/metal
	var/buildstackamount = 2
	var/comfort = 2 // default comfort


/obj/structure/bed/psych
	name = "psych bed"
	desc = "For prime comfort during psychiatric evaluations."
	icon_state = "psychbed"
	buildstackamount = 5

/obj/structure/bed/alien
	name = "resting contraption"
	desc = "This looks similar to contraptions from Earth. Could aliens be stealing our technology?"
	icon_state = "abed"
	comfort = 0.3

/obj/structure/bed/sandstone
	name = "sandstone plate"
	desc = "This is used to lie on, feels farm."
	icon_state = "bed_sand"
	resistance_flags = FIRE_PROOF
	max_integrity = 200
	buildstacktype = /obj/item/stack/sheet/mineral/sandstone
	buildstackamount = 15

/obj/structure/bed/old
	name = "old bed"
	desc = "This is a very old spring bed, it looks extremely UNCOMFORTABLE, you would not lie on it for anything in your life."
	icon_state = "catwalkcouch1"
	comfort = 0

/obj/structure/bed/wicker
	name = "wicker bed"
	desc = "Большая кровать, сотканная из чего-то, напоминающего ткань. Выглядит достаточно удобно."
	ru_names = list(
		NOMINATIVE = "плетёная кровать",
		GENITIVE = "плетёной кровати",
		DATIVE = "плетёной кровати",
		ACCUSATIVE = "плетёную кровать",
		INSTRUMENTAL = "плетёной кроватью",
		PREPOSITIONAL = "плетёной кровати"
	)
	icon_state = "wicker_bed"
	comfort = 1.5
	buildstacktype = /obj/item/stack/sheet/cloth
	buildstackamount = 5

/obj/structure/bed/leather
	name = "leather bed"
	desc = "Куски кожи, грубо сшитые друг с другом и прикреплённые к деревянной раме. Не самое удобное место для лежания."
	ru_names = list(
		NOMINATIVE = "кровать из кожи",
		GENITIVE = "кровати из кожи",
		DATIVE = "кровати из кожи",
		ACCUSATIVE = "кровать из кожи",
		INSTRUMENTAL = "кроватью из кожи",
		PREPOSITIONAL = "кровати из кожи"
	)
	icon_state = "leather_bed"
	comfort = 1.2
	buildstacktype = /obj/item/stack/sheet/leather
	buildstackamount = 2

/obj/structure/bed/wooden
	name = "wooden bed"
	desc = "Кровать, сделанная из качественной древесины. Выглядит очень мило и уютно."
	ru_names = list(
		NOMINATIVE = "деревянная кровать",
		GENITIVE = "деревянной кровати",
		DATIVE = "деревянной кровати",
		ACCUSATIVE = "деревянную кровать",
		INSTRUMENTAL = "деревянной кроватью",
		PREPOSITIONAL = "деревянной кровати"
	)
	icon_state = "wooden_bed"
	comfort = 2.5
	buildstacktype = /obj/item/stack/sheet/wood
	buildstackamount = 5

/obj/structure/bed/proc/handle_rotation()
	return

/obj/structure/bed/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(obj_flags & NODECONSTRUCT)
		to_chat(user, "<span class='warning'>You can't figure out how to deconstruct [src]!</span>")
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	deconstruct(TRUE)

/obj/structure/bed/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		if(buildstacktype)
			new buildstacktype(loc, buildstackamount)
	..()


/*
 * Roller beds
 */

/obj/structure/bed/roller
	name = "roller bed"
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "down"
	resistance_flags = NONE
	anchored = FALSE
	comfort = 1
	pull_push_slowdown = 0	// used for transporting lying mobs
	var/icon_up = "up"
	var/icon_down = "down"
	var/folded = /obj/item/roller


/obj/structure/bed/roller/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/roller_holder))
		var/buckled_mobs = has_buckled_mobs()
		if(buckled_mobs)
			add_fingerprint(user)
			if(buckled_mobs > 1)
				unbuckle_all_mobs()
				user.visible_message(
					span_notice("[user] unbuckles all creatures from [src]."),
					span_notice("You unbuckle all creatures from [src]."),
				)
			else
				user_unbuckle_mob(buckled_mobs[1], user)
			return ATTACK_CHAIN_PROCEED_SUCCESS
		user.visible_message(
			span_notice("[user] collapses [src]."),
			span_notice("You collapse [src]."),
		)
		var/obj/item/folded_item = new folded(drop_location())
		transfer_fingerprints_to(folded_item)
		folded_item.add_fingerprint(user)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/structure/bed/roller/update_icon_state()
	icon_state = has_buckled_mobs() ? icon_up : icon_down


/obj/structure/bed/roller/post_buckle_mob(mob/living/target)
	set_density(TRUE)
	update_icon(UPDATE_ICON_STATE)
	target.pixel_y = target.base_pixel_y + 3


/obj/structure/bed/roller/post_unbuckle_mob(mob/living/target)
	set_density(FALSE)
	update_icon(UPDATE_ICON_STATE)
	target.pixel_y = target.base_pixel_y + target.body_position_pixel_y_offset


/obj/structure/bed/roller/holo
	name = "holo stretcher"
	icon_state = "holo_down"
	icon_up = "holo_up"
	icon_down = "holo_down"
	folded = /obj/item/roller/holo

/obj/item/roller
	name = "roller bed"
	desc = "A collapsed roller bed that can be carried around."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "folded"
	/// Whether it can be picked up by roller holder
	var/collectable = TRUE
	var/extended = /obj/structure/bed/roller
	w_class = WEIGHT_CLASS_BULKY // Can't be put in backpacks.


/obj/item/roller/attack_self(mob/user)
	var/obj/structure/bed/roller/R = new extended(drop_location())
	R.add_fingerprint(user)
	qdel(src)


/obj/item/roller/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/roller_holder))
		var/obj/item/roller_holder/roller = I
		if(roller.held)
			to_chat(user, span_warning("The [roller.name] already contains [roller.held]."))
			return ATTACK_CHAIN_PROCEED
		if(!collectable)
			to_chat(user, span_warning("You cannot collect this type of roller."))
			return ATTACK_CHAIN_PROCEED
		if(loc == user && !user.can_unEquip(src))
			return ..()
		user.visible_message(
			span_notice("[user] collects [src]."),
			span_notice("You collect [src]."),
		)
		if(loc == user)
			user.transfer_item_to_loc(src, roller)
		else
			forceMove(roller)
		roller.held = src
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/structure/bed/roller/MouseDrop(atom/over_object, src_location, over_location, src_control, over_control, params)
	if(!has_buckled_mobs() && over_object == usr && ishuman(usr) && !usr.incapacitated() && !HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED) && usr.Adjacent(src))
		usr.visible_message(
			span_notice("[usr] collapses [src]."),
			span_notice("You collapse [src]."),
		)
		var/obj/item/folded_item = new folded(drop_location())
		folded_item.add_fingerprint(usr)
		qdel(src)
		return FALSE
	return ..()


/obj/item/roller/holo
	name = "holo stretcher"
	desc = "A retracted hardlight stretcher that can be carried around."
	icon_state = "holo_retracted"
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "magnets=3;biotech=4;powerstorage=3"
	extended = /obj/structure/bed/roller/holo
	collectable = FALSE


/obj/item/roller_holder
	name = "roller bed rack"
	desc = "A rack for carrying a collapsed roller bed."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "folded"
	var/obj/item/roller/held = /obj/item/roller


/obj/item/roller_holder/Initialize(mapload)
	. = ..()
	if(ispath(held, /obj/item/roller))
		held = new held(src)


/obj/item/roller_holder/Destroy()
	QDEL_NULL(held)
	return ..()


/obj/item/roller_holder/attack_self(mob/user)
	if(!held)
		to_chat(user, span_warning("The rack is empty."))
		return

	to_chat(user, span_notice("You deploy the roller bed."))
	var/obj/structure/bed/roller/roller = new held.extended(drop_location())
	roller.add_fingerprint(user)
	QDEL_NULL(held)



/*
 * Dog beds
 */

/obj/structure/bed/dogbed
	name = "dog bed"
	icon_state = "dogbed"
	desc = "A comfy-looking dog bed. You can even strap your pet in, just in case the gravity turns off."
	anchored = FALSE
	buildstackamount = 10
	buildstacktype = /obj/item/stack/sheet/wood
	comfort = 0.5

/obj/structure/bed/dogbed/ian
	name = "Ian's bed"
	desc = "Ian's bed! Looks comfy."
	anchored = TRUE

/obj/structure/bed/dogbed/renault
	desc = "Renault's bed! Looks comfy. A foxy person needs a foxy pet."
	name = "Renault's bed"
	anchored = TRUE

/obj/structure/bed/dogbed/runtime
	desc = "A comfy-looking cat bed. You can even strap your pet in, in case the gravity turns off."
	name = "Runtime's bed"
	anchored = TRUE

/obj/structure/bed/dogbed/pet
	name = "Удобная лежанка"
	desc = "Комфортная лежанка для любимейшего питомца отдела."
	anchored = TRUE
