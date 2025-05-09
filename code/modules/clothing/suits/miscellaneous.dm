/*
 * Contains:
 *		Lasertag
 *		Costume
 *		Winter Coats
 *		Misc
 */

/*
 * Lasertag
 */
/obj/item/clothing/suit/bluetag
	name = "blue laser tag armour"
	desc = "Blue Pride, Station Wide."
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "bluetag"
	item_state = "bluetag"
	blood_overlay_type = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	allowed = list (/obj/item/gun/energy/laser/tag/blue)
	resistance_flags = NONE

	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

/obj/item/clothing/suit/redtag
	name = "red laser tag armour"
	desc = "Pew pew pew."
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "redtag"
	item_state = "redtag"
	blood_overlay_type = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	allowed = list (/obj/item/gun/energy/laser/tag/red)
	resistance_flags = NONE

	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

/*
 * Costume
 */
/obj/item/clothing/suit/pirate_brown
	name = "brown pirate coat"
	desc = "Yarr."
	icon_state = "pirate_old"
	item_state = "pirate_old"

	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

/obj/item/clothing/suit/pirate_black
	name = "black pirate coat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"

	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

/obj/item/clothing/suit/hgpirate
	name = "pirate captain coat"
	desc = "Yarr."
	icon_state = "hgpirate"
	item_state = "hgpirate"
	flags_inv = HIDEJUMPSUIT
	flags_inv_transparent = HIDEJUMPSUIT


/obj/item/clothing/suit/cyborg_suit
	name = "cyborg suit"
	desc = "Suit for a cyborg costume."
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "death"
	item_state = "death"
	flags = CONDUCT
	fire_resist = T0C+5200
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	undyeable = TRUE


/obj/item/clothing/suit/greatcoat
	name = "great coat"
	desc = "A Nazi great coat."
	icon_state = "nazi"
	item_state = "nazi"


/obj/item/clothing/suit/johnny_coat
	name = "johnny~~ coat"
	desc = "Johnny~~"
	icon_state = "johnny"
	item_state = "johnny"


/obj/item/clothing/suit/justice
	name = "justice suit"
	desc = "this pretty much looks ridiculous"
	icon_state = "justice"
	item_state = "justice"
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT


/obj/item/clothing/suit/judgerobe
	name = "judge's robe"
	desc = "This robe commands authority."
	icon_state = "judge"
	item_state = "judge"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/storage/fancy/cigarettes,/obj/item/stack/spacecash)
	flags_inv = HIDEJUMPSUIT


/obj/item/clothing/suit/wcoat
	name = "waistcoat"
	desc = "For some classy, murderous fun."
	icon_state = "vest"
	item_state = "wcoat"
	blood_overlay_type = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

/obj/item/clothing/suit/apron/overalls
	name = "coveralls"
	desc = "A set of denim overalls."
	icon_state = "overalls"
	item_state = "overalls"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS


/obj/item/clothing/suit/syndicatefake
	name = "black and red space suit replica"
	icon_state = "syndicate-black-red"
	item_state = "syndicate-black-red"
	desc = "A plastic replica of the syndicate space suit, you'll look just like a real murderous syndicate agent in this! This is a toy, it is not made for use in space!"
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/flashlight,/obj/item/tank/internals/emergency_oxygen,/obj/item/toy)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	resistance_flags = NONE
	undyeable = TRUE


/obj/item/clothing/suit/hastur
	name = "Hastur's robes"
	desc = "Robes not meant to be worn by man."
	icon_state = "hastur"
	item_state = "hastur"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_inv = HIDESHOES|HIDEJUMPSUIT


/obj/item/clothing/suit/imperium_monk
	name = "imperium monk"
	desc = "Have YOU killed a xeno today?"
	icon_state = "imperium_monk"
	item_state = "imperium_monk"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_inv = HIDESHOES|HIDEJUMPSUIT
	allowed = list(/obj/item/storage/bible, /obj/item/nullrod, /obj/item/reagent_containers/food/drinks/bottle/holywater, /obj/item/storage/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen)

/obj/item/clothing/suit/chickensuit
	name = "chicken suit"
	desc = "A suit made long ago by the ancient empire KFC."
	icon_state = "chickensuit"
	item_state = "chickensuit"
	body_parts_covered = UPPER_TORSO|ARMS|LOWER_TORSO|LEGS|FEET
	flags_inv = HIDESHOES|HIDEJUMPSUIT
	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/suit.dmi'
		)

/obj/item/clothing/suit/corgisuit
	name = "corgi suit"
	desc = "A suit made long ago by the ancient empire KFC."
	icon_state = "corgisuit"
	item_state = "chickensuit"
	body_parts_covered = UPPER_TORSO|ARMS|LOWER_TORSO|LEGS|FEET
	flags_inv = HIDEJUMPSUIT
	dog_fashion = /datum/dog_fashion/back

/obj/item/clothing/suit/corgisuit/super_hero
	name = "super-hero corgi suit"
	desc = "A suit made long ago by the ancient empire KFC. This one pulses with a strange power."


/obj/item/clothing/suit/corgisuit/super_hero/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)


/obj/item/clothing/suit/corgisuit/super_hero/en
	name = "\improper super-hero E-N suit"
	icon_state = "ensuit"

/obj/item/clothing/suit/corgisuit/super_hero/en/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/clothing/suit/corgisuit/super_hero/en/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/suit/corgisuit/super_hero/en/process()
	if(prob(2))
		for(var/obj/object in orange(2, src))
			if(!object.anchored && (object.flags & CONDUCT))
				step_towards(object, src)
		for(var/mob/living/silicon/robot in orange(2,src))
			if(isAI(robot))
				continue
			step_towards(robot, src)
		for(var/mob/living/carbon/human/machine/IPC in orange(2,src))
			step_towards(IPC, src)

/obj/item/clothing/suit/monkeysuit
	name = "monkey suit"
	desc = "A suit that looks like a primate"
	icon_state = "monkeysuit"
	item_state = "monkeysuit"
	body_parts_covered = UPPER_TORSO|ARMS|LOWER_TORSO|LEGS|FEET|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT|HIDETAIL


/obj/item/clothing/suit/holidaypriest
	name = "holiday priest"
	desc = "This is a nice holiday my son."
	icon_state = "holidaypriest"
	item_state = "holidaypriest"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_inv = HIDEJUMPSUIT
	allowed = list(/obj/item/storage/bible, /obj/item/nullrod, /obj/item/reagent_containers/food/drinks/bottle/holywater, /obj/item/storage/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen)

/obj/item/clothing/suit/cardborg
	name = "cardborg suit"
	desc = "An ordinary cardboard box with holes cut in the sides."
	icon_state = "cardborg"
	item_state = "cardborg"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	flags_inv = HIDEJUMPSUIT
	species_disguise = "High-tech robot"
	dog_fashion = /datum/dog_fashion/back


/obj/item/clothing/suit/cardborg/equipped(mob/living/user, slot, initial = FALSE)
	. = ..()
	if(slot == ITEM_SLOT_CLOTH_OUTER)
		disguise(user)


/obj/item/clothing/suit/cardborg/dropped(mob/living/user, slot, silent = FALSE)
	. = ..()
	if(slot == ITEM_SLOT_CLOTH_OUTER)
		user.remove_alt_appearance("standard_borg_disguise")


/obj/item/clothing/suit/cardborg/proc/disguise(mob/living/carbon/human/H, obj/item/clothing/head/cardborg/borghead)
	if(istype(H))
		if(!borghead)
			borghead = H.head
		if(istype(borghead, /obj/item/clothing/head/cardborg)) //why is this done this way? because equipped() is called BEFORE THE ITEM IS IN THE SLOT WHYYYY
			var/image/I = image(icon = 'icons/mob/robots.dmi' , icon_state = "robot", loc = H)
			I.override = 1
			I.overlays += image(icon = 'icons/mob/robots.dmi' , icon_state = "eyes-robot") //gotta look realistic
			H.add_alt_appearance("standard_borg_disguise", I, GLOB.silicon_mob_list+H) //you look like a robot to robots! (including yourself because you're totally a robot)

/obj/item/clothing/suit/snowman
	name = "snowman outfit"
	desc = "Two white spheres covered in white glitter. 'Tis the season."
	icon_state = "snowman"
	item_state = "snowman"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/hooded/carp_costume
	name = "carp costume"
	desc = "A costume made from 'synthetic' carp scales, it smells."
	icon_state = "carp_casual"
	item_state = "labcoat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT	//Space carp like space, so you should too
	allowed = list(/obj/item/tank/internals/emergency_oxygen)
	hoodtype = /obj/item/clothing/head/hooded/carp_hood
	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/suit.dmi'
		)

/obj/item/clothing/head/hooded/carp_hood
	name = "carp hood"
	desc = "A hood attached to a carp costume."
	icon_state = "carp_casual"
	body_parts_covered = HEAD
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	flags_inv = HIDEHEADSETS|HIDEHAIR

/obj/item/clothing/suit/hooded/salmon_costume
	name = "salmon suit"
	desc = "A costume made from authentic salmon scales, it reeks!"
	icon_state = "salmon"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	allowed = list(/obj/item/fish/salmon, /obj/item/fish_eggs/salmon)
	hoodtype = /obj/item/clothing/head/hooded/salmon_hood

/obj/item/clothing/head/hooded/salmon_hood
	name = "salmon hood"
	desc = "A hood attached to a salmon suit."
	icon_state = "salmon"
	body_parts_covered = HEAD
	flags_inv = HIDEHEADSETS|HIDEHAIR

/obj/item/clothing/suit/hooded/bee_costume // It's Hip!
	name = "bee costume"
	desc = "Bee the true Queen!"
	icon_state = "bee"
	item_state = "labcoat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	clothing_flags = THICKMATERIAL
	hoodtype = /obj/item/clothing/head/hooded/bee_hood

/obj/item/clothing/head/hooded/bee_hood
	name = "bee hood"
	desc = "A hood attached to a bee costume."
	icon_state = "bee"
	body_parts_covered = HEAD
	clothing_flags = THICKMATERIAL
	flags_inv = HIDEHEADSETS|HIDEHAIR

/obj/item/clothing/suit/bloated_human	//OH MY GOD WHAT HAVE YOU DONE!?!?!?
	name = "bloated human suit"
	desc = "A horribly bloated suit made from human skins."
	icon_state = "lingspacesuit"
	item_state = "lingspacesuit"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/suit.dmi'
		)

/obj/item/clothing/suit/draculacoat // Bleh!
	name = "transylvanian coat"
	desc = "<i>What is a spessman? A miserable little pile of secrets.</i>"
	icon_state = "draculacoat"
	item_state = "draculacoat"

/*
 * Winter Coats
 */

/obj/item/clothing/suit/hooded/wintercoat
	name = "winter coat"
	desc = "A heavy jacket made from 'synthetic' animal furs."
	icon_state = "wintercoat"
	item_state = "coatwinter"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 0)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter)

	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

/obj/item/clothing/head/hooded/winterhood
	name = "winter hood"
	desc = "A hood attached to a heavy winter jacket."
	icon_state = "winterhood"
	body_parts_covered = HEAD
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	flags_inv = HIDEHEADSETS|HIDEHAIR

	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/head.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/head.dmi'
		)

/obj/item/clothing/suit/hooded/wintercoat/captain
	name = "captain's winter coat"
	icon_state = "wintercoat_captain"
	w_class = WEIGHT_CLASS_NORMAL
	item_state = "coatcaptain"
	armor = list("melee" = 25, "bullet" = 30, "laser" = 30, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 50)
	allowed = list(/obj/item/gun/energy, /obj/item/reagent_containers/spray/pepper, /obj/item/gun/projectile, /obj/item/ammo_box,/obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/flashlight/seclite)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/captain

/obj/item/clothing/head/hooded/winterhood/captain
	icon_state = "winterhood_captain"

/obj/item/clothing/suit/hooded/wintercoat/security
	name = "security winter coat"
	icon_state = "wintercoat_sec"
	w_class = WEIGHT_CLASS_NORMAL
	item_state = "coatsecurity"
	armor = list("melee" = 15, "bullet" = 10, "laser" = 15, "energy" = 5, "bomb" = 15, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 30)
	allowed = list(/obj/item/gun/energy, /obj/item/reagent_containers/spray/pepper, /obj/item/gun/projectile, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/flashlight/seclite)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/security

/obj/item/clothing/head/hooded/winterhood/security
	icon_state = "winterhood_sec"

/obj/item/clothing/suit/hooded/wintercoat/security/hos
	name = "head of securiry winter coat"
	icon_state = "wintercoat_hos"
	item_state = "coathos"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/security/hos

/obj/item/clothing/head/hooded/winterhood/security/hos
	icon_state = "winterhood_hos"

/obj/item/clothing/suit/hooded/wintercoat/medical
	name = "medical winter coat"
	icon_state = "wintercoat_med"
	w_class = WEIGHT_CLASS_NORMAL
	item_state = "coatmedical"
	allowed = list(/obj/item/analyzer, /obj/item/dnainjector, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/syringe, /obj/item/reagent_containers/hypospray, /obj/item/reagent_containers/applicator,/obj/item/healthanalyzer,/obj/item/flashlight/pen, /obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/glass/beaker, /obj/item/storage/pill_bottle, /obj/item/paper, /obj/item/melee/baton/telescopic, /obj/item/stack/medical, /obj/item/reagent_containers/food/pill, /obj/item/rad_laser)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 50, "rad" = 0, "fire" = 0, "acid" = 45)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical

/obj/item/clothing/head/hooded/winterhood/medical
	icon_state = "winterhood_med"

/obj/item/clothing/suit/hooded/wintercoat/medical/cmo
	name = "chief medical officer winter coat"
	icon_state = "wintercoat_cmo"
	item_state = "coatcmo"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical/cmo

/obj/item/clothing/head/hooded/winterhood/medical/cmo
	icon_state = "winterhood_cmo"

/obj/item/clothing/suit/hooded/wintercoat/medical/science
	name = "science winter coat"
	icon_state = "wintercoat_sci"
	w_class = WEIGHT_CLASS_NORMAL
	item_state = "coatscience"
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 10, bio = 0, rad = 0, fire = 0, acid = 0)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/science

/obj/item/clothing/head/hooded/winterhood/science
	icon_state = "winterhood_sci"

/obj/item/clothing/suit/hooded/wintercoat/medical/science/rd
	name = "research director winter coat"
	icon_state = "wintercoat_rd"
	item_state = "coatrd"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/science/rd

/obj/item/clothing/head/hooded/winterhood/science/rd
	icon_state = "winterhood_rd"

/obj/item/clothing/suit/hooded/wintercoat/engineering
	name = "engineering winter coat"
	icon_state = "wintercoat_engi"
	w_class = WEIGHT_CLASS_NORMAL
	item_state = "coatengineer"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 20, "fire" = 30, "acid" = 45)
	allowed = list(/obj/item/flashlight, /obj/item/t_scanner, /obj/item/tank/internals/emergency_oxygen, /obj/item/rcd, /obj/item/rpd)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/engineering

/obj/item/clothing/head/hooded/winterhood/engineering
	icon_state = "winterhood_engi"

/obj/item/clothing/suit/hooded/wintercoat/engineering/atmos
	name = "atmospherics winter coat"
	icon_state = "wintercoat_atmos"
	item_state = "coatatmos"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/engineering/atmos

/obj/item/clothing/head/hooded/winterhood/engineering/atmos
	icon_state = "winterhood_atmos"

/obj/item/clothing/suit/hooded/wintercoat/engineering/ce
	name = "chief engineer winter coat"
	icon_state = "wintercoat_ce"
	item_state = "coatce"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/engineering/ce

/obj/item/clothing/head/hooded/winterhood/engineering/ce
	icon_state = "winterhood_ce"

/obj/item/clothing/suit/hooded/wintercoat/hydro
	name = "hydroponics winter coat"
	icon_state = "wintercoat_hydro"
	item_state = "coathydro"
	allowed = list(/obj/item/reagent_containers/spray/plantbgone,/obj/item/plant_analyzer,/obj/item/seeds,/obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/glass/beaker, /obj/item/cultivator,/obj/item/reagent_containers/spray/pestspray,/obj/item/hatchet,/obj/item/storage/bag/plants)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/hydro

/obj/item/clothing/head/hooded/winterhood/hydro
	icon_state = "winterhood_hydro"

/obj/item/clothing/suit/hooded/wintercoat/cargo
	name = "cargo winter coat"
	icon_state = "wintercoat_cargo"
	item_state = "coatcargo"
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/storage/fancy/cigarettes, /obj/item/clothing/mask/cigarette, /obj/item/lighter, /obj/item/rcs, /obj/item/stack/packageWrap, /obj/item/stack/wrapping_paper, /obj/item/destTagger, /obj/item/pen, /obj/item/paper, /obj/item/stamp)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/cargo

/obj/item/clothing/head/hooded/winterhood/cargo
	icon_state = "winterhood_cargo"

/obj/item/clothing/suit/hooded/wintercoat/miner
	name = "mining winter coat"
	icon_state = "wintercoat_miner"
	w_class = WEIGHT_CLASS_NORMAL
	item_state = "coatminer"
	allowed = list(/obj/item/flashlight, /obj/item/tank, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/kinetic_accelerator, /obj/item/pickaxe, /obj/item/twohanded/kinetic_crusher, /obj/item/hierophant_club, /obj/item/twohanded/fireaxe/boneaxe)
	armor = list("melee" = 30, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 50, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 50)
	resistance_flags = FIRE_PROOF
	hoodtype = /obj/item/clothing/head/hooded/winterhood/miner

/obj/item/clothing/head/hooded/winterhood/miner
	icon_state = "winterhood_miner"
	armor = list("melee" = 30, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 50, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 50)
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/hooded/wintercoat/hop
	name = "head of personel winter coat"
	icon_state = "wintercoat_hop"
	item_state = "coathop"
	armor = list("melee" = 15, "bullet" = 10, "laser" = 15, "energy" = 5, "bomb" = 15, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 30)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/hop

/obj/item/clothing/head/hooded/winterhood/hop
	icon_state = "winterhood_hop"

/obj/item/clothing/suit/hooded/wintercoat/cargo/qm
	name = "quartermaster winter coat"
	icon_state = "wintercoat_qm"
	item_state = "coatqm"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/qm

/obj/item/clothing/head/hooded/winterhood/qm
	icon_state = "winterhood_qm"
/*
 * Misc
 */

//hoodies
/obj/item/clothing/suit/hooded/hoodie
	name = "black hoodie"
	desc = "It's a hoodie. It has a hood. Most hoodies do."
	icon_state = "black_hoodie"
	item_state = "blueshieldcoat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen)
	hoodtype = /obj/item/clothing/head/hooded/hood
	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

/obj/item/clothing/head/hooded/hood
	name = "black hood"
	desc = "A hood attached to a hoodie."
	icon_state = "blackhood"
	body_parts_covered = HEAD
	cold_protection = HEAD
	flags_inv = HIDEHEADSETS|HIDEHAIR

	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/head.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/head.dmi'
		)

/obj/item/clothing/head/hooded/hood/blue
	icon_state = "bluehood"

/obj/item/clothing/head/hooded/hood/white
	icon_state = "whitehood"

/obj/item/clothing/suit/hooded/hoodie/blue
	name = "blue hoodie"
	icon_state = "blue_hoodie"
	hoodtype = /obj/item/clothing/head/hooded/hood/blue

/obj/item/clothing/suit/hooded/hoodie/mit
	name = "Martian Institute of Technology hoodie"
	desc = "A hoodie proudly worn by students and graduates alike, has the letters 'MIT' on the back."
	icon_state = "mit_hoodie"
	hoodtype = /obj/item/clothing/head/hooded/hood

/obj/item/clothing/suit/hooded/hoodie/cut
	name = "Canaan University of Technology hoodie"
	desc = "A bright hoodie with the Canaan University of Technology logo on the front."
	icon_state = "cut_hoodie"
	hoodtype = /obj/item/clothing/head/hooded/hood/white

/obj/item/clothing/suit/hooded/hoodie/lam
	name = "Lunar Academy of Medicine hoodie"
	desc = "A bright hoodie with the Lunar Academy of Medicine logo on the back."
	icon_state = "lam_hoodie"
	hoodtype = /obj/item/clothing/head/hooded/hood/white

/obj/item/clothing/suit/hooded/hoodie/nt
	name = "Nanotrasen hoodie"
	desc = "A blue hoodie with the Nanotrasen logo on the back."
	icon_state = "nt_hoodie"
	hoodtype = /obj/item/clothing/head/hooded/hood/blue

/obj/item/clothing/suit/hooded/hoodie/tp
	name = "Tharsis Polytech hoodie"
	desc = "A dark hoodie with the Tharsis Polytech logo on the back."
	icon_state = "tp_hoodie"
	hoodtype = /obj/item/clothing/head/hooded/hood

/obj/item/clothing/suit/straight_jacket
	name = "straight jacket"
	desc = "A suit that completely restrains the wearer."
	icon_state = "straight_jacket"
	item_state = "straight_jacket"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT|HIDETAIL
	strip_delay = 60
	breakouttime = 3000
	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/suit.dmi'
		)

/obj/item/clothing/suit/ianshirt
	name = "worn shirt"
	desc = "A worn out, curiously comfortable t-shirt with a picture of Ian. You wouldn't go so far as to say it feels like being hugged when you wear it but it's pretty close. Good for sleeping in."
	icon_state = "ianshirt"
	item_state = "ianshirt"

	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)



//pyjamas
//originally intended to be pinstripes >.>

/obj/item/clothing/under/bluepyjamas
	name = "blue pyjamas"
	desc = "Slightly old-fashioned sleepwear."
	icon_state = "blue_pyjamas"
	item_state = "blue_pyjamas"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS

/obj/item/clothing/under/redpyjamas
	name = "red pyjamas"
	desc = "Slightly old-fashioned sleepwear."
	icon_state = "red_pyjamas"
	item_state = "red_pyjamas"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS

//coats

/obj/item/clothing/suit/leathercoat
	name = "leather coat"
	desc = "A long, thick black leather coat."
	icon_state = "leathercoat"
	item_state = "leathercoat"
	resistance_flags = FIRE_PROOF
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 15, bomb = 15, bio = 0, rad = 0, fire = 15, acid = 15)

/obj/item/clothing/suit/browncoat
	name = "brown leather coat"
	desc = "A long, brown leather coat."
	icon_state = "browncoat"
	item_state = "browncoat"

/obj/item/clothing/suit/neocoat
	name = "black coat"
	desc = "A flowing, black coat."
	icon_state = "neocoat"
	item_state = "neocoat"

/obj/item/clothing/suit/storage/browntrenchcoat
	name = "brown trench coat"
	desc = "It makes you stand out. Just the opposite of why it's typically worn. Nice try trying to blend in while wearing it."
	icon_state = "brtrenchcoat"
	item_state = "brtrenchcoat"

	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

/obj/item/clothing/suit/storage/blacktrenchcoat
	name = "black trench coat"
	desc = "That shade of black just makes you look a bit more evil. Good for those mafia types."
	icon_state = "bltrenchcoat"
	item_state = "bltrenchcoat"
	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)
	armor = list(melee = 5, bullet = 5, laser = 10, energy = 10, bomb = 15, bio = 0, rad = 0, fire = 10, acid = 10)

/obj/item/clothing/suit/storage/leather_trenchcoat/runner
	name = "leather trenchcoat"
	desc = "Длинное кожаное пальто-тренч с натуральным мехом. Вы чувствуете себя одиноко, когда носите его..."
	icon_state = "bladerunner_coat"
	item_state = "bladerunner_coat"

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/suit.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

//trackjackets

/obj/item/clothing/suit/tracksuit
	name = "black tracksuit"
	desc = "Lightweight and stylish. What else could a man ask of his tracksuit?"
	icon_state = "trackjacket_open"
	item_state = "bltrenchcoat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	ignore_suitadjust = FALSE
	actions_types = list(/datum/action/item_action/openclose)
	adjust_flavour = "unzip"

	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

/obj/item/clothing/suit/tracksuit/green
	name = "green tracksuit"
	icon_state = "trackjacketgreen_open"

/obj/item/clothing/suit/tracksuit/red
	name = "red tracksuit"
	icon_state = "trackjacketred_open"

/obj/item/clothing/suit/tracksuit/white
	name = "white tracksuit"
	icon_state = "trackjacketwhite_open"

//actual suits

/obj/item/clothing/suit/creamsuit
	name = "cream suit"
	desc = "A cream coloured, genteel suit."
	icon_state = "creamsuit"
	item_state = "creamsuit"

/obj/item/clothing/under/stripper/mankini
	name = "the mankini"
	desc = "No honest man would wear this abomination"
	icon_state = "mankini"
	item_color = "mankini"

/obj/item/clothing/suit/jacket/miljacket
	name = "olive military jacket"
	desc = "A canvas jacket styled after classical American military garb. Feels sturdy, yet comfortable. This one comes in olive."
	icon_state = "militaryjacket"
	item_state = "militaryjacket"
	ignore_suitadjust = TRUE
	actions_types = null
	adjust_flavour = null
	allowed = list(/obj/item/flashlight,/obj/item/tank/internals/emergency_oxygen,/obj/item/toy,/obj/item/storage/fancy/cigarettes,/obj/item/lighter,/obj/item/gun/projectile/automatic/pistol,/obj/item/gun/projectile/revolver,/obj/item/gun/projectile/revolver/detective)

/obj/item/clothing/suit/jacket/miljacket/navy
	name = "navy military jacket"
	desc = "A canvas jacket styled after classical American military garb. Feels sturdy, yet comfortable. This one comes in navy blue."
	icon_state = "navy_jacket"

/obj/item/clothing/suit/jacket/miljacket/desert
	name = "desert military jacket"
	desc = "A canvas jacket styled after classical American military garb. Feels sturdy, yet comfortable. This one comes in desert beige."
	icon_state = "desert_jacket"

/obj/item/clothing/suit/jacket/miljacket/white
	name = "white military jacket"
	desc = "A canvas jacket styled after classical American military garb. Feels sturdy, yet comfortable. This one comes in snow white."
	icon_state = "white_jacket"

/obj/item/clothing/suit/xenos
	name = "xenos suit"
	desc = "A suit made out of chitinous alien hide."
	icon_state = "xenos"
	item_state = "xenos_helm"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT|HIDETAIL
	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/suit.dmi'
		)

//swimsuit
/obj/item/clothing/under/swimsuit/

/obj/item/clothing/under/swimsuit/black
	name = "black swimsuit"
	desc = "An oldfashioned black swimsuit."
	icon_state = "swim_black"
	item_color = "swim_black"

/obj/item/clothing/under/swimsuit/blue
	name = "blue swimsuit"
	desc = "An oldfashioned blue swimsuit."
	icon_state = "swim_blue"
	item_color = "swim_blue"

/obj/item/clothing/under/swimsuit/purple
	name = "purple swimsuit"
	desc = "An oldfashioned purple swimsuit."
	icon_state = "swim_purp"
	item_color = "swim_purp"

/obj/item/clothing/under/swimsuit/green
	name = "green swimsuit"
	desc = "An oldfashioned green swimsuit."
	icon_state = "swim_green"
	item_color = "swim_green"

/obj/item/clothing/under/swimsuit/red
	name = "red swimsuit"
	desc = "An oldfashioned red swimsuit."
	icon_state = "swim_red"
	item_color = "swim_red"

/obj/item/clothing/suit/storage/mercy_hoodie
	name = "mercy robe"
	desc = "A soft white robe made of a synthetic fiber that provides improved protection against biohazards. Possessing multiple overlapping layers, yet light enough to allow complete freedom of movement, it denotes its wearer as a master physician."
	icon_state = "mercy_hoodie"
	item_state = "mercy_hoodie"
	w_class = WEIGHT_CLASS_BULKY
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/tank/internals/emergency_oxygen,/obj/item/pen,/obj/item/flashlight/pen)
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 100, rad = 20, fire = 50, acid = 50)
	flags_inv = HIDEJUMPSUIT|HIDETAIL

/obj/item/clothing/head/mercy_hood
	name = "Mercy Hood"
	desc = "A soft white hood made of a synthetic fiber that provides improved protection against biohazards. Its elegant design allows a clear field of vision."
	icon_state = "mercy_hood"
	item_state = "mercy_hood"
	permeability_coefficient = 0.01
	flags_inv = HIDEHAIR|HIDEMASK|HIDEHEADSETS|HIDEGLASSES
	flags_cover = HEADCOVERSEYES
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 100, rad = 20, fire = 50, acid = 50)


/obj/item/clothing/suit/jacket
	name = "bomber jacket"
	desc = "Aviators not included."
	icon_state = "bomber"
	item_state = "bomber"
	ignore_suitadjust = FALSE
	suit_adjusted = TRUE
	allowed = list(/obj/item/flashlight,/obj/item/tank/internals/emergency_oxygen,/obj/item/toy,/obj/item/storage/fancy/cigarettes,/obj/item/lighter)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	actions_types = list(/datum/action/item_action/zipper)
	adjust_flavour = "unzip"

	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

/obj/item/clothing/suit/jacket/pilot
	name = "security bomber jacket"
	desc = "A stylish and worn-in armoured black bomber jacket emblazoned with the NT Security crest on the left breast. Looks rugged."
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "bombersec"
	item_state = "bombersec"
	ignore_suitadjust = FALSE
	suit_adjusted = TRUE
	//Inherited from Security armour.
	allowed = list(/obj/item/gun/energy,/obj/item/reagent_containers/spray/pepper,/obj/item/gun/projectile,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/restraints/handcuffs,/obj/item/flashlight/seclite,/obj/item/kitchen/knife/combat)
	heat_protection = UPPER_TORSO|LOWER_TORSO
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	strip_delay = 60
	put_on_delay = 40
	armor = list(melee = 25, bullet = 15, laser = 25, energy = 10, bomb = 25, bio = 0, rad = 0, fire = 50, acid = 50)
	//End of inheritance from Security armour.

/obj/item/clothing/suit/jacket/leather
	name = "leather jacket"
	desc = "Pompadour not included."
	icon_state = "leatherjacket"
	ignore_suitadjust = TRUE
	actions_types = null
	adjust_flavour = null
	resistance_flags = NONE
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 15, bomb = 15, bio = 0, rad = 0, fire = 15, acid = 15)

/obj/item/clothing/suit/jacket/motojacket
	name = "leather motorcycle jacket"
	desc = "A vintage classic, loved by rockers, rebels, and punks alike."
	icon_state = "motojacket_open"
	item_state = "motojacket_open"
	ignore_suitadjust = FALSE
	actions_types = list(/datum/action/item_action/zipper)
	adjust_flavour = "unzip"

	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/suit.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 15, bomb = 15, bio = 0, rad = 0, fire = 15, acid = 15)

/obj/item/clothing/suit/jacket/leather/overcoat
	name = "leather overcoat"
	desc = "That's a damn fine coat."
	icon_state = "leathercoat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS

/obj/item/clothing/suit/officercoat
	name = "Clown Officer's Coat"
	desc = "A classy clown officer's overcoat, also designed by Hugo Boss."
	icon_state = "officersuit"
	item_state = "officersuit"
	ignore_suitadjust = FALSE
	suit_adjusted = TRUE
	actions_types = list(/datum/action/item_action/button)
	adjust_flavour = "unbutton"

	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

/obj/item/clothing/suit/soldiercoat
	name = "Clown Soldier's Coat"
	desc = "An overcoat for the clown soldier, to keep him warm during those cold winter nights on the front."
	icon_state = "soldiersuit"
	item_state = "soldiersuit"
	ignore_suitadjust = FALSE
	suit_adjusted = TRUE
	actions_types = list(/datum/action/item_action/button)
	adjust_flavour = "unbutton"

	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

/obj/item/clothing/suit/sovietcoat
	name = "\improper Soviet greatcoat"
	desc = "A military overcoat made of rough wool that is thick enough to provide excellent protection against the elements."
	icon_state = "sovietcoat"
	item_state = "sovietcoat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	armor = list(melee = 15, bullet = 15, laser = 15, energy = 5, bomb = 15, bio = 0, rad = 0, fire = 30, acid = 30)
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/flashlight,/obj/item/gun/energy,/obj/item/gun/projectile,/obj/item/ammo_box)

/obj/item/clothing/suit/sovietcoat/officer
	name = "\improper Soviet officer's greatcoat"
	desc = "A military overcoat made with expensive wool. The U.S.S.P armband means it must belong to someone important."
	icon_state = "sovietofficercoat"
	item_state = "sovietofficercoat"
	armor = list(melee = 25, bullet = 25, laser = 25, energy = 10, bomb = 20, bio = 0, rad = 0, fire = 30, acid = 30)

/obj/item/clothing/suit/russiancoat
	name = "russian coat"
	desc = "Used in extremly cold fronts, made out of real bears."
	item_state = "rus_coat"
	icon_state = "rus_coat"

/obj/item/clothing/suit/lordadmiral
	name = "Lord Admiral's Coat"
	desc = "You'll be the Ruler of the King's Navy in no time."
	icon_state = "lordadmiral"
	item_state = "lordadmiral"
	allowed = list (/obj/item/gun)

/obj/item/clothing/suit/fluff/noble_coat
	name = "noble coat"
	desc = "The livid blues, purples and greens are awesome enough to evoke a visceral response in you; it is not dissimilar to indigestion."
	icon_state = "noble_coat"
	item_state = "noble_coat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS


///Advanced Protective Suit, AKA, God Mode in wearable form.

/obj/item/clothing/suit/advanced_protective_suit
	name = "Advanced Protective Suit"
	desc = "An incredibly advanced and complex suit; it has so many buttons and dials as to be incomprehensible."
	w_class = WEIGHT_CLASS_BULKY
	icon_state = "bomb"
	item_state = "bomb"
	actions_types = list(/datum/action/item_action/toggle)
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	clothing_flags = STOPSPRESSUREDMAGE|THICKMATERIAL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS|HEAD
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 100, bio = 100, rad = 100, fire = 100, acid = 100)
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS | HEAD
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = UPPER_TORSO | LOWER_TORSO|LEGS|FEET|ARMS|HANDS | HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	slowdown = -10
	siemens_coefficient = 0
	var/on = 0

/obj/item/clothing/suit/advanced_protective_suit/Destroy()
	if(on)
		on = 0
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/suit/advanced_protective_suit/ui_action_click(mob/user, datum/action/action, leftclick)
	if(on)
		on = 0
		REMOVE_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)
		to_chat(usr, "You turn the suit's special processes off.")
	else
		on = 1
		ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)
		to_chat(usr, "You turn the suit's special processes on.")
		START_PROCESSING(SSobj, src)


/obj/item/clothing/suit/advanced_protective_suit/IsReflect()
	return (on)

/obj/item/clothing/suit/advanced_protective_suit/process()
	if(on)
		var/mob/living/carbon/human/user = src.loc
		if(user && ishuman(user) && (user.wear_suit == src))
			if(user.reagents.get_reagent_amount("stimulants") < 15)
				user.reagents.add_reagent("stimulants", 15)
			if(user.reagents.get_reagent_amount("adminordrazine") < 15)
				user.reagents.add_reagent("adminordrazine", 15)
			if(user.reagents.get_reagent_amount("nanites") < 15)
				user.reagents.add_reagent("nanites", 15)
			if(user.reagents.get_reagent_amount("syndicate_nanites") < 15)
				user.reagents.add_reagent("syndicate_nanites", 15)
	else
		STOP_PROCESSING(SSobj, src)

//Syndicate Chaplain Robe (WOLOLO!)
/obj/item/clothing/suit/hooded/chaplain_hoodie/missionary_robe
	description_antag = "This robe is made of reinforced fibers, granting it superior protection. The robes also wirelessly generate power for the neurotransmitter in the linked missionary staff while being worn."
	w_class = WEIGHT_CLASS_NORMAL
	armor = list(melee = 10, bullet = 10, laser = 5, energy = 5, bomb = 0, bio = 0, rad = 15, fire = 30, acid = 30)
	var/obj/item/nullrod/missionary_staff/linked_staff = null

/obj/item/clothing/suit/hooded/chaplain_hoodie/missionary_robe/Destroy()
	if(linked_staff)	//delink on destruction
		linked_staff.robes = null
		linked_staff = null
	STOP_PROCESSING(SSobj, src)	//probably is cleared in a parent call already, but just in case we're gonna do it here
	return ..()

/obj/item/clothing/suit/hooded/chaplain_hoodie/missionary_robe/equipped(mob/living/carbon/human/H, slot, initial)
	. = ..()

	if(!istype(H) || slot != ITEM_SLOT_CLOTH_OUTER)
		STOP_PROCESSING(SSobj, src)
	else
		START_PROCESSING(SSobj, src)

/obj/item/clothing/suit/hooded/chaplain_hoodie/missionary_robe/process()
	if(!linked_staff)	//if we don't have a linked staff, the rest of this is useless
		return

	if(!ishuman(loc))		//if we somehow try to process while not on a human, remove ourselves from processing and return
		STOP_PROCESSING(SSobj, src)
		return

	var/mob/living/carbon/human/H = loc

	if(linked_staff.faith >= 100)	//if the linked staff is fully recharged, do nothing
		return

	// Do not allow the staff to recharge if it's more than 3 tiles away from the robe. If get_dist returns 0, the robe and the staff in the same tile.
	if(!(get_dist(H, linked_staff) <= 3))
		if(prob(10))	//10% chance per process should avoid being too spammy, can tweak if it ends up still being too frequent.
			to_chat(H, "<span class='warning'>Your staff is unable to charge at this range. Get closer!</span>")
		return

	linked_staff.faith += 5
	if(linked_staff.faith >= 100)	//if this charge puts the staff at or above full, notify the wearer
		to_chat(H, "<span class='notice'>Faith renewed; ready to convert new followers.</span>")

/obj/item/clothing/suit/tailcoat
	name = "victorian tailcoat"
	desc = "A fancy victorian tailcoat."
	icon_state = "tailcoat"
	item_state = "tailcoat"

/obj/item/clothing/suit/victcoat
	name = "ladies victorian coat"
	desc = "A fancy victorian coat."
	icon_state = "ladiesvictoriancoat"
	item_state = "ladiesvictoriancoat"

/obj/item/clothing/suit/victcoat/red
	name = "ladies red victorian coat"
	icon_state = "ladiesredvictoriancoat"
	item_state = "ladiesredvictoriancoat"

/obj/item/clothing/suit/ghost_sheet
	name = "ghost sheet"
	desc = "The hands float by themselves, so it's extra spooky."
	icon_state = "ghost_sheet"
	item_state = "ghost_sheet"
	throwforce = 0
	throw_speed = 1
	throw_range = 2
	w_class = WEIGHT_CLASS_TINY
	flags_inv = HIDEGLOVES|HIDEHEADSETS|HIDENAME|HIDEHAIR

/obj/item/clothing/suit/cyberpunk
	name = "long cyberpunk black coat"
	desc = "No one knows why it's called cyberpunk, but hey, it looks cool."
	icon_state = "cyberpunksleek_long_black"

/obj/item/clothing/suit/cyberpunk/white
	name = "long cyberpunk white coat"
	icon_state = "cyberpunksleek_long_white"

/obj/item/clothing/suit/cyberpunk/green
	name = "long cyberpunk green coat"
	icon_state = "cyberpunksleek_long_green"

/obj/item/clothing/suit/cyberpunk/brown
	name = "long cyberpunk brown coat"
	icon_state = "cyberpunksleek_long"

/obj/item/clothing/suit/triad
	name = "Long Tangzhuang"
	desc = "A traditional chinese suit worn for fashion."
	icon_state = "triadkillers"

/obj/item/clothing/suit/hooded/hijab
	name = "hijab"
	desc = "Тёмное одеяние скрывающее тело."
	icon_state = "hijab"
	flags_inv = HIDETAIL
	hoodtype = /obj/item/clothing/head/hooded/hijab
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/suit.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/suit.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

/obj/item/clothing/head/hooded/hijab
	name = "hijab hood"
	desc = "Тёмное одеяние скрывающее лицо."
	icon_state = "hijab_head"
	flags_inv = HIDEHEADSETS|HIDENAME|HIDEHAIR
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/head.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/head.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/head.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/head.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/head.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/head.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/head.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/head.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/head.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/head.dmi'
		)

// Suragi start
// Suragi parent
/obj/item/clothing/suit/storage/suragi_jacket
	name = "Suragi Jacket"
	desc = "Smoke one cigarette"
	icon_state = "suragi_jacket_civ"
	ignore_suitadjust = TRUE
	blood_overlay_type = ""
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	allowed = list(/obj/item/flashlight,/obj/item/tank/internals/emergency_oxygen,/obj/item/toy,/obj/item/storage/fancy/cigarettes,/obj/item/lighter,/obj/item/gun/projectile/automatic/pistol,/obj/item/gun/projectile/revolver,/obj/item/gun/projectile/revolver/detective)

// Suragi Children
/obj/item/clothing/suit/storage/suragi_jacket/civ
	name = "Suragi Jacket"
	desc = "Standard issue orange jacket manufactured by Suragi Kit. Extremely durable. This particular one unobtrusively makes you want to dance. How strange."
	icon_state = "suragi_jacket_civ"
	item_state = "suragi_jacket_civ"
	armor = list("melee" = 5, "bullet" = 2, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

/obj/item/clothing/suit/storage/suragi_jacket/sec
	name = "Security Suragi Jacket"
	desc = "Standard issue black and red jacket manufactured by Suragi Kit. Extremely durable. Is that a blood stain?"
	icon_state = "suragi_jacket_sec"
	item_state = "suragi_jacket_sec"
	armor = list("melee" = 25, "bullet" = 15, "laser" = 25, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	allowed = list(/obj/item/gun/energy,/obj/item/reagent_containers/spray/pepper,/obj/item/gun/projectile,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/restraints/handcuffs,/obj/item/flashlight/seclite,/obj/item/kitchen/knife/combat)

/obj/item/clothing/suit/storage/suragi_jacket/cargo
	name = "Cargo Suragi Jacket"
	desc = "Standard issue gray and yellow jacket manufactured by Suragi Kit. Extremely durable, smells of hard work. And sweat. Especially sweat. Oh god."
	icon_state = "suragi_jacket_carg"
	item_state = "suragi_jacket_carg"
	armor = list("melee" = 5, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/storage/fancy/cigarettes, /obj/item/clothing/mask/cigarette, /obj/item/lighter, /obj/item/rcs, /obj/item/stack/packageWrap, /obj/item/stack/wrapping_paper, /obj/item/destTagger, /obj/item/pen, /obj/item/paper, /obj/item/stamp)

/obj/item/clothing/suit/storage/suragi_jacket/atmos
	name = "Atmospherics Suragi Jacket"
	desc = "Standard issue light-blue and yellow jacket manufactured by Suragi Kit. Extremely durable but not fireproof. Or is it?"
	icon_state = "suragi_jacket_atmos"
	item_state = "suragi_jacket_atmos"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 5, "acid" = 0)
	allowed = list (/obj/item/flashlight, /obj/item/t_scanner, /obj/item/tank/internals/emergency_oxygen, /obj/item/rcd, /obj/item/rpd, /obj/item/holosign_creator/atmos)

/obj/item/clothing/suit/storage/suragi_jacket/eng
	name = "Engineering Suragi Jacket"
	desc = "Standard issue orange and gray jacket manufactured by Suragi Kit. Extremely durable. This one seemingly was scratched by some kind of bird. There are still some red feathers inside."
	icon_state = "suragi_jacket_eng"
	item_state = "suragi_jacket_eng"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 5, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	allowed = list (/obj/item/flashlight, /obj/item/t_scanner, /obj/item/tank/internals/emergency_oxygen, /obj/item/rcd, /obj/item/rpd, /obj/item/holosign_creator/atmos)

/obj/item/clothing/suit/storage/suragi_jacket/botany
	name = "Botany Suragi Jacket"
	desc = "Standard issue blue and green jacket manufactured by Suragi Kit. Extremely durable. It smells of ammonia and... duuuuude i dunno hehe"
	icon_state = "suragi_jacket_botan"
	item_state = "suragi_jacket_botan"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 5, "rad" = 0, "fire" = 0, "acid" = 0)
	allowed = list(/obj/item/reagent_containers/spray/plantbgone,/obj/item/plant_analyzer,/obj/item/seeds,/obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/glass/beaker, /obj/item/cultivator,/obj/item/reagent_containers/spray/pestspray,/obj/item/hatchet,/obj/item/storage/bag/plants)

/obj/item/clothing/suit/storage/suragi_jacket/medic
	name = "Medical Suragi Jacket"
	desc = "Standard issue white and green jacket manufactured by Suragi Kit. Extremely durable and easy to clean. And you will need to clean it A LOT."
	icon_state = "suragi_jacket_med"
	item_state = "suragi_jacket_med"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 5, "rad" = 0, "fire" = 0, "acid" = 0)
	allowed = list(/obj/item/analyzer, /obj/item/dnainjector, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/syringe, /obj/item/reagent_containers/hypospray, /obj/item/reagent_containers/applicator, /obj/item/healthanalyzer,
	/obj/item/flashlight/pen, /obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/glass/beaker, /obj/item/storage/pill_bottle, /obj/item/paper, /obj/item/melee/baton/telescopic, /obj/item/stack/medical, /obj/item/paper, /obj/item/rad_laser)

/obj/item/clothing/suit/storage/suragi_jacket/medsec
	name = "Medical Security Suragi Jacket"
	desc = "Standard issue white and red jacket manufactured by Suragi Kit. Extremely durable. Wear this and every single soul will know that you didn't take the Hippocratic Oath."
	icon_state = "suragi_jacket_brigmed"
	item_state = "suragi_jacket_brigmed"
	armor = list("melee" = 5, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 5, "rad" = 0, "fire" = 0, "acid" = 0)
	allowed = list(/obj/item/stack/medical, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/hypospray, /obj/item/reagent_containers/applicator, /obj/item/reagent_containers/syringe, /obj/item/healthanalyzer, /obj/item/flashlight, /obj/item/radio, /obj/item/tank/internals/emergency_oxygen, /obj/item/rad_laser,
	/obj/item/reagent_containers/hypospray, /obj/item/flashlight/pen,/obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/glass/beaker, /obj/item/reagent_containers/food/pill, /obj/item/storage/pill_bottle,/obj/item/paper,)

/obj/item/clothing/suit/storage/suragi_jacket/virus
	name = "Virology Suragi Jacket"
	desc = "Standard issue green and white jacket manufactured by Suragi Kit. Extremely durable. Congratulations! You are wearing the only one jacket of all Suragi's that doesn't have funny description. What an extremely boring must your profession be."
	icon_state = "suragi_jacket_virus"
	item_state = "suragi_jacket_virus"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 5, "rad" = 0, "fire" = 0, "acid" = 0)
	allowed = list(/obj/item/analyzer, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/syringe, /obj/item/reagent_containers/applicator,/obj/item/healthanalyzer,/obj/item/flashlight/pen, /obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/glass/beaker, /obj/item/paper,
	/obj/item/stack/medical, /obj/item/dnainjector, /obj/item/reagent_containers/hypospray, /obj/item/reagent_containers/food/pill, /obj/item/storage/pill_bottle, /obj/item/rad_laser)

/obj/item/clothing/suit/storage/suragi_jacket/chem
	name = "Chemistry Suragi Jacket"
	desc = "Standard issue white and orange jacket manufactured by Suragi Kit. Extremely durable. There is a small label attached inside. It says: 'DO NOT HEAT FUCKING OIL GOD FUCKING DAMMIT'"
	icon_state = "suragi_jacket_chem"
	item_state = "suragi_jacket_chem"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 5, "acid" = 5)
	allowed = list(/obj/item/analyzer, /obj/item/reagent_containers/syringe, /obj/item/reagent_containers/applicator, /obj/item/flashlight/pen, /obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/glass/beaker, /obj/item/storage/pill_bottle, /obj/item/paper,
	/obj/item/stack/medical,/obj/item/dnainjector, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/hypospray, /obj/item/healthanalyzer, /obj/item/reagent_containers/food/pill, /obj/item/rad_laser)

/obj/item/clothing/suit/storage/suragi_jacket/genetics
	name = "Genetics Suragi Jacket"
	desc = "Standard issue white and light-blue jacket manufactured by Suragi Kit. Extremely durable, but not for your kind. Please, take it off before irradiating yourself. It is expensive, you know."
	icon_state = "suragi_jacket_genet"
	item_state = "suragi_jacket_genet"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 5, "fire" = 0, "acid" = 0)
	allowed = list(/obj/item/analyzer,/obj/item/stack/medical,/obj/item/dnainjector,/obj/item/reagent_containers/dropper,/obj/item/reagent_containers/syringe,/obj/item/reagent_containers/hypospray,/obj/item/reagent_containers/applicator,/obj/item/healthanalyzer,/obj/item/flashlight/pen,/obj/item/reagent_containers/glass/bottle,/obj/item/reagent_containers/glass/beaker,/obj/item/reagent_containers/food/pill,/obj/item/storage/pill_bottle,/obj/item/paper,/obj/item/rad_laser)

/obj/item/clothing/suit/storage/suragi_jacket/robot
	name = "Robotiscist Suragi Jacket"
	desc = "Standard issue white and black jacket manufactured by Suragi Kit. Extremely durable. Start the nuclear arms race against security with style."
	icon_state = "suragi_jacket_robotist"
	item_state = "suragi_jacket_robotist"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 5,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	allowed = list(/obj/item/robotanalyzer, /obj/item/clothing/glasses/welding, /obj/item/analyzer,/obj/item/stack/medical,/obj/item/dnainjector,/obj/item/reagent_containers/dropper,/obj/item/reagent_containers/syringe,/obj/item/reagent_containers/hypospray,/obj/item/reagent_containers/applicator,/obj/item/healthanalyzer,/obj/item/flashlight/pen,/obj/item/reagent_containers/glass/bottle,/obj/item/reagent_containers/glass/beaker,/obj/item/reagent_containers/food/pill,/obj/item/storage/pill_bottle,/obj/item/paper,/obj/item/rad_laser)

/obj/item/clothing/suit/storage/suragi_jacket/sci
	name = "Science Suragi Jacket"
	desc = "Standard issue white and black jacket manufactured by Suragi Kit. Extremely durable. This one is particulary interesting. It seems that because of some bluespace anomaly pockets have switched places. Very fascinating and very useless effect."
	icon_state = "suragi_jacket_scien"
	item_state = "suragi_jacket_scien"
	armor = list("melee" = 1, "bullet" = 1, "laser" = 1, "energy" = 1, "bomb" = 1, "bio" = 1, "rad" = 1, "fire" = 1, "acid" = 1)
	allowed = list(/obj/item/analyzer,/obj/item/stack/medical,/obj/item/dnainjector,/obj/item/reagent_containers/dropper,/obj/item/reagent_containers/syringe,/obj/item/reagent_containers/hypospray,/obj/item/reagent_containers/applicator,/obj/item/healthanalyzer,/obj/item/flashlight/pen,/obj/item/reagent_containers/glass/bottle,/obj/item/reagent_containers/glass/beaker,/obj/item/reagent_containers/food/pill,/obj/item/storage/pill_bottle,/obj/item/paper,/obj/item/rad_laser)

/obj/item/clothing/suit/storage/suragi_jacket/janitor
	name = "Janitor Suragi Jacket"
	desc = "Standard issue purple jacket manufactured by Suragi Kit. Extremely durable and easy to clean. This particular one makes you feel like a pimp."
	icon_state = "suragi_jacket_jan"
	item_state = "suragi_jacket_jan"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 3, "rad" = 0, "fire" = 0, "acid" = 3)
	allowed = list(/obj/item/soap, /obj/item/reagent_containers/spray/cleaner, /obj/item/storage/bag/trash, /obj/item/lightreplacer)
// Suragi end

/obj/item/clothing/suit/mr_chang_coat
	name = "Marketing agent's haori"
	desc = "Fascinating apparel for every self-respecting salesman. Composition: 95% polyester, 15% cotton, 5% ramen noodles, 456% profit."
	icon_state = "mr_chang_coat"
	item_state = "mr_chang_coat"
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	allowed = list()
	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/suit.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
	)


/obj/item/clothing/suit/hoodie
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/suit.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

/obj/item/clothing/suit/hoodie/plaidhoodie_green
	name = "green plaid hoodie"
	desc = "Fashionable and stylish green plaid hoodie with hood."
	icon_state = "plaidhoodie_green"
	item_state = "plaidhoodie_green"

/obj/item/clothing/suit/hoodie/plaidhoodie_white
	name = "white plaid hoodie"
	desc = "Fashionable and stylish white plaid hoodie with hood."
	icon_state = "plaidhoodie_white"
	item_state = "plaidhoodie_white"

/obj/item/clothing/suit/hoodie/plaidhoodie_red
	name = "red plaid hoodie"
	desc = "Fashionable and stylish red plaid hoodie with hood."
	icon_state = "plaidhoodie_red"
	item_state = "plaidhoodie_red"

/obj/item/clothing/suit/hoodie/plaidhoodie_yellow
	name = "yellow plaid hoodie"
	desc = "Fashionable and stylish yellow plaid hoodie with hood."
	icon_state = "plaidhoodie_yellow"
	item_state = "plaidhoodie_yellow"

/obj/item/clothing/suit/blackcoat
	name = "black coat"
	desc = "A long leather raincoat. It makes you feel like a human being."
	icon_state = "blackcoat"
	item_state = "blackcoat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_inv = HIDEJUMPSUIT
	flags_inv_transparent = HIDEJUMPSUIT
	ignore_suitadjust = FALSE
	suit_adjusted = TRUE
	actions_types = list(/datum/action/item_action/button)
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/suit.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi',
	)


/obj/item/clothing/suit/towel
	name = "towel"
	desc = "A soft cotton towel."
	icon_state = "towel_long"
	item_state = "towel"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_CLOTH_OUTER
	body_parts_covered = LOWER_TORSO | UPPER_TORSO
	var/drop_amount = 3
	sprite_sheets = list(
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/suit.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi'
	)


/obj/item/clothing/suit/towel/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/spraycan_paintable)


/obj/item/clothing/suit/towel/attack_self(mob/living/carbon/user)
	if(!istype(user) || !user.wetlevel)
		return ..()

	INVOKE_ASYNC(src, PROC_REF(wipe_dry), user, user)


/obj/item/clothing/suit/towel/afterattack(mob/living/carbon/target, mob/user, proximity, params)
	. = ..()

	if(!istype(target) || !target.wetlevel)
		return

	INVOKE_ASYNC(src, PROC_REF(wipe_dry), target, user)


/obj/item/clothing/suit/towel/proc/wipe_dry(mob/living/carbon/target, mob/user)
	user.visible_message(span_warning("[user] begins to wipe [target == user ? target.p_themselves() : target] with [src]."))

	if(!do_after(user, 5 SECONDS, target))
		return

	if(!istype(target) || !target.wetlevel)
		return

	target.wetlevel = 0
	to_chat(user, span_notice("You wiped [target == user ? "yourself" : target] dry."))


/obj/item/clothing/suit/towel/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.) || !is_sharp(I))
		return .

	. |= ATTACK_CHAIN_BLOCKED_ALL
	var/obj/item/stack/sheet/cloth/cloth = new(drop_location(), drop_amount)
	transfer_fingerprints_to(cloth)
	cloth.add_fingerprint(user)
	to_chat(user, span_notice("You tear [src] up."))
	qdel(src)



/obj/item/clothing/suit/towel/alt
	icon_state = "towel_long_alt"
	item_state = "towel_alt"


/obj/item/clothing/suit/towel/alt/equipped(mob/user, slot, initial)
	. = ..()

	if(slot != ITEM_SLOT_CLOTH_OUTER)
		return .

	update_icon(UPDATE_ICON_STATE)
	user.wear_suit_update(src)


/obj/item/clothing/suit/towel/alt/update_icon_state()
	if(ishumanbasic(loc))
		var/mob/living/carbon/human/user = loc
		. = user.gender == FEMALE

	icon_state = "[initial(icon_state)][. ? "_woman" : null]"


/obj/item/clothing/suit/towel/short
	icon_state = "towel"
	drop_amount = 2
	slot_flags = ITEM_SLOT_CLOTH_OUTER | ITEM_SLOT_HEAD
	body_parts_covered = LOWER_TORSO


/obj/item/clothing/suit/towel/short/equipped(mob/user, slot, initial)
	. = ..()

	update_icon(UPDATE_ICON_STATE)

	if(slot & (ITEM_SLOT_CLOTH_OUTER | ITEM_SLOT_HEAD))
		update_equipped_item(update_speedmods = FALSE)


/obj/item/clothing/suit/towel/short/update_icon_state()
	if(!isliving(loc))
		return

	var/mob/living/user = loc
	var/slot = user.get_slot_by_item(src)

	icon_state = "[initial(icon_state)][slot == ITEM_SLOT_HEAD ? "_head" : null]"

/obj/item/clothing/suit/towel/short/alt
	icon_state = "towel_alt"
	item_state = "towel_alt"

/obj/item/clothing/suit/hooded/ghostfacesuit
	name = "Ghostface suit"
	ru_names = list(
		NOMINATIVE = "чёрный балахон",
		GENITIVE = "чёрного балахона",
		DATIVE = "чёрному балахону",
		ACCUSATIVE = "чёрный балахон",
		INSTRUMENTAL = "чёрным балахоном",
		PREPOSITIONAL = "чёрном балахоне"
	)
	desc = "Чёрный, просторный балахон, что может навеивать смутные напоминания о чём-то."
	icon_state = "ghostface_suit"
	item_state = "ghostface_suit"
	body_parts_covered = UPPER_TORSO|ARMS|LOWER_TORSO|LEGS|FEET
	flags_inv = HIDESHOES|HIDEJUMPSUIT|HIDETAIL
	hoodtype = /obj/item/clothing/head/hooded/ghostface
	sprite_sheets = list(
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/suit.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

/obj/item/clothing/suit/hooded/update_icon_state()
	return

/obj/item/clothing/head/hooded/ghostface
	name = "Ghostface hood"
	ru_names = list(
		NOMINATIVE = "чёрный капюшон",
		GENITIVE = "чёрного капюшона",
		DATIVE = "чёрному капюшону",
		ACCUSATIVE = "чёрный капюшон",
		INSTRUMENTAL = "чёрным капюшоном",
		PREPOSITIONAL = "чёрном капюшоне"
	)
	desc = "Чёрный капюшон. Он вам что-то точно напоминает..."
	icon_state = "ghostface_hood"
	item_state = "ghostface"
	flags_inv = HIDEHEADSETS|HIDEHAIR
	sprite_sheets = list(
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/suit.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

/obj/item/clothing/head/hooded/ghostface/true
	armor = list(melee = 30, bullet = 10, laser = 5, energy = 5, bomb = 0, bio = 0, rad = 0, fire = 10, acid = 10)

/obj/item/clothing/suit/hooded/ghostfacesuit/devil
	desc = "Чёрный с прожилками красного просторный балахон, что может навеивать смутные напоминания о чём-то."
	ru_names = list(
		NOMINATIVE = "кроваво-чёрный балахон",
		GENITIVE = "кроваво-чёрного балахона",
		DATIVE = "кроваво-чёрному балахону",
		ACCUSATIVE = "кроваво-чёрный балахон",
		INSTRUMENTAL = "кроваво-чёрным балахоном",
		PREPOSITIONAL = "кроваво-чёрном балахоне"
	)
	icon_state = "devil_ghostface_suit"
	item_state = "devil_ghostface_suit"


/obj/item/clothing/suit/hooded/ghostfacesuit/true
	armor = list(melee = 30, bullet = 10, laser = 5, energy = 5, bomb = 0, bio = 0, rad = 0, fire = 10, acid = 10)
	hoodtype = /obj/item/clothing/head/hooded/ghostface/true

/obj/item/clothing/suit/hooded/ghostfacesuit/devil/true
	armor = list(melee = 30, bullet = 10, laser = 5, energy = 5, bomb = 0, bio = 0, rad = 0, fire = 10, acid = 10)
	hoodtype = /obj/item/clothing/head/hooded/ghostface/true

/obj/item/clothing/suit/hooded/penguin_costume
	name = "penguin suit"
	desc = "Глупый и забавный полноразмерный костюм пингвина."
	ru_names = list(
		NOMINATIVE = "костюм пингвина",
		GENITIVE = "костюма пингвина",
		DATIVE = "костюму пингвина",
		ACCUSATIVE = "костюм пингвина",
		INSTRUMENTAL = "костюмом пингвина",
		PREPOSITIONAL = "костюме пингвина"
	)
	icon_state = "penguin"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|TAIL
	hide_tail_by_species = list(
		SPECIES_TAJARAN,
		SPECIES_UNATHI,
		SPECIES_ASHWALKER_BASIC,
		SPECIES_ASHWALKER_SHAMAN,
		SPECIES_DRACONOID,
		SPECIES_VOX,
		SPECIES_VULPKANIN,
		SPECIES_WRYN
		)
	hoodtype = /obj/item/clothing/head/hooded/penguin_hood
	sprite_sheets = list(
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/suit.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		)

/obj/item/clothing/head/hooded/penguin_hood
	name = "penguin hood"
	desc = "Капюшон от костюма пингвина."
	ru_names = list(
		NOMINATIVE = "капюшон костюма пингвина",
		GENITIVE = "капюшона костюма пингвина",
		DATIVE = "капюшону костюма пингвина",
		ACCUSATIVE = "капюшон костюма пингвина",
		INSTRUMENTAL = "капюшоном костюмома пингвина",
		PREPOSITIONAL = "капюшоне костюма пингвина"
	)
	icon_state = "penguin"
	body_parts_covered = HEAD
	flags_inv = HIDEHEADSETS|HIDEHAIR
	sprite_sheets = list(
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/head.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/head.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_KIDAN = 'icons/mob/clothing/species/unathi/head.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/head.dmi',
		SPECIES_WRYN = 'icons/mob/clothing/species/wryn/head.dmi'
		)
