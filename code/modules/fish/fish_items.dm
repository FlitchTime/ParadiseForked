
//////////////////////////////////////////////
//			Aquarium Supplies				//
//////////////////////////////////////////////

/obj/item/egg_scoop
	name = "fish egg scoop"
	desc = "A small scoop to collect fish eggs with."
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "egg_scoop"
	slot_flags = ITEM_SLOT_BELT
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 7

/obj/item/fish_net
	name = "fish net"
	desc = "A tiny net to capture fish with. It's a death sentence!"
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "net"
	slot_flags = ITEM_SLOT_BELT
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 7

/obj/item/fish_net/suicide_act(mob/user)			//"A tiny net is a death sentence: it's a net and it's tiny!" https://www.youtube.com/watch?v=FCI9Y4VGCVw
	to_chat(viewers(user), "<span class='warning'>[user] places the [src.name] on top of [user.p_their()] head, [user.p_their()] fingers tangled in the netting! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	return OXYLOSS

/obj/item/fishfood
	name = "fish food can"
	desc = "A small can of Carp's Choice brand fish flakes. The label shows a smiling Space Carp."
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "fish_food"
	throwforce = 1
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 7

/obj/item/tank_brush
	name = "aquarium brush"
	desc = "A brush for cleaning the inside of aquariums. Contains a built-in odor neutralizer."
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "brush"
	slot_flags = ITEM_SLOT_BELT
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 7
	attack_verb = list("отдраил", "шлифанул", "поцарапал")

/obj/item/tank_brush/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='warning'>[user] is vigorously scrubbing [user.p_them()]self raw with the [name]! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	return BRUTELOSS|FIRELOSS

/obj/item/storage/bag/fish
	name = "fish bag"
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "bag"
	storage_slots = 100
	max_combined_w_class = 100
	max_w_class = WEIGHT_CLASS_NORMAL
	w_class = WEIGHT_CLASS_TINY
	can_hold = list(
		/obj/item/fish,
		/obj/item/fish_eggs,
		/obj/item/reagent_containers/food/snacks/shrimp,
		/obj/item/reagent_containers/food/snacks/crayfish_raw,
		/obj/item/reagent_containers/food/snacks/crayfish_raw_small,
	)
	resistance_flags = FLAMMABLE

//////////////////////////////////////////////
//				Fish Items					//
//////////////////////////////////////////////

/obj/item/reagent_containers/food/snacks/shrimp
	name = "shrimp"
	desc = "A single raw shrimp."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "shrimp_raw"
	filling_color = "#FF1C1C"
	list_reagents = list("protein" = 1)
	bitesize = 1

/obj/item/reagent_containers/food/snacks/shrimp/New()
	..()
	desc = pick("Anyway, like I was sayin', shrimp is the fruit of the sea.", "You can barbecue it, boil it, broil it, bake it, saute it.")

/obj/item/reagent_containers/food/snacks/feederfish
	name = "feeder fish"
	desc = "A tiny feeder fish. Sure doesn't look very filling..."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "feederfish"
	filling_color = "#FF1C1C"
	list_reagents = list("protein" = 1)
	bitesize = 1

/obj/item/fish
	name = "fish"
	desc = "A generic fish"
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "fish"
	throwforce = 1
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 7
	force = 1
	attack_verb = list("шлёпнул", "унизил", "ударил")
	hitsound = 'sound/effects/snap.ogg'

/obj/item/fish/glofish
	name = "glofish"
	desc = "A small bio-luminescent fish. Not very bright, but at least it's pretty!"
	icon_state = "glofish"
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = 1
	light_color = "#99FF66"

/obj/item/fish/electric_eel
	name = "electric eel"
	desc = "An eel capable of producing a mild electric shock. Luckily it's rather weak out of water."
	icon_state = "electric_eel"

/obj/item/fish/shark
	name = "shark"
	desc = "Warning: Keep away from tornadoes."
	icon_state = "shark"
	hitsound = 'sound/weapons/bite.ogg'
	force = 3


/obj/item/fish/shark/wirecutter_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume))
		return .
	to_chat(user, span_notice("You rip out the teeth of [src]!"))
	var/atom/drop_loc = drop_location()
	var/obj/item/fish/toothless_shark/shark = new(drop_loc)
	var/obj/item/shard/shark_teeth/teeth = new(drop_loc)
	transfer_fingerprints_to(shark)
	shark.add_fingerprint(user)
	teeth.add_fingerprint(user)
	qdel(src)


/obj/item/fish/toothless_shark
	name = "toothless shark"
	desc = "Looks like someone ripped it's teeth out!"
	icon_state = "shark"
	hitsound = 'sound/effects/snap.ogg'

/obj/item/shard/shark_teeth
	name = "shark teeth"
	desc = "A number of teeth, supposedly from a shark."
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "teeth"
	force = 2.0
	throwforce = 5.0
	materials = list()

/obj/item/shard/shark_teeth/New()
	..()
	src.pixel_x = rand(-5,5)
	src.pixel_y = rand(-5,5)

/obj/item/fish/catfish
	name = "catfish"
	desc = "Apparently, catfish don't purr like you might have expected them to. Such a confusing name!"
	icon_state = "catfish"


/obj/item/fish/catfish/attackby(obj/item/I, mob/user, params)
	if(is_sharp(I))
		to_chat(user, "You carefully clean and gut [src].")
		var/obj/item/reagent_containers/food/snacks/catfishmeat/meat = new(drop_location(), 2)
		meat.add_fingerprint(user)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/fish/goldfish
	name = "goldfish"
	desc = "A goldfish, just like the one you never won at the county fair."
	icon_state = "goldfish"

/obj/item/fish/salmon
	name = "salmon"
	desc = "The second-favorite food of Space Bears, right behind crew members."
	icon_state = "salmon"


/obj/item/fish/salmon/attackby(obj/item/I, mob/user, params)
	if(is_sharp(I))
		to_chat(user, "You carefully clean and gut [src].")
		var/obj/item/reagent_containers/food/snacks/salmonmeat/meat = new(drop_location(), 2)
		meat.add_fingerprint(user)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/fish/babycarp
	name = "baby space carp"
	desc = "Substantially smaller than the space carp lurking outside the hull, but still unsettling."
	icon_state = "babycarp"
	hitsound = 'sound/weapons/bite.ogg'
	force = 3


/obj/item/fish/babycarp/attackby(obj/item/I, mob/user, params)
	if(is_sharp(I))
		to_chat(user, "You carefully clean and gut [src].")
		var/obj/item/reagent_containers/food/snacks/carpmeat/meat = new(drop_location())	//just one fillet; this is a baby, afterall.
		meat.add_fingerprint(user)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/grown/bananapeel/clownfish
	name = "clown fish"
	desc = "Even underwater, you cannot escape HONKing."
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "clownfish"
	throwforce = 1
	force = 1
	attack_verb = list("шлёпнул", "унизил", "ударил", "хонкнул")
