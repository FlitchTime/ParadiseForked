/obj/item/clothing/suit/armor
	allowed = list(/obj/item/gun/energy,/obj/item/reagent_containers/spray/pepper,/obj/item/gun/projectile,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/restraints/handcuffs,/obj/item/flashlight/seclite,/obj/item/kitchen/knife/combat)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	cold_protection = UPPER_TORSO|LOWER_TORSO
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	heat_protection = UPPER_TORSO|LOWER_TORSO
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	strip_delay = 60
	put_on_delay = 40
	max_integrity = 250
	resistance_flags = NONE
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 20, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)
	w_class = WEIGHT_CLASS_NORMAL
	undyeable = TRUE

/obj/item/clothing/suit/armor/vest
	name = "armor"
	desc = "An armored vest that protects against some damage."
	icon_state = "armor"
	item_state = "armor"
	blood_overlay_type = "armor"
	dog_fashion = /datum/dog_fashion/back

/obj/item/clothing/suit/armor/vest/jacket
	name = "military jacket"
	desc = "An old military jacket, it has armoring."
	icon_state = "militaryjacket"
	item_state = "militaryjacket"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/suit/armor/vest/combat
	name = "combat vest"
	desc = "An armored vest that protects against some damage."
	icon_state = "armor-combat"
	item_state = "bulletproof"
	blood_overlay_type = "armor"

/obj/item/clothing/suit/armor/vest/security
	name = "security armor"
	desc = "An armored vest that protects against some damage. This one has a clip for a holobadge."
	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
	)
	icon_state = "armor"
	item_state = "armor"
	var/obj/item/clothing/accessory/holobadge/attached_badge


/obj/item/clothing/suit/armor/vest/security/update_icon_state()
	icon_state = "armor[attached_badge ? "sec" : ""]"
	update_equipped_item(update_speedmods = FALSE)


/obj/item/clothing/suit/armor/vest/security/update_desc(updates = ALL)
	. = ..()
	if(attached_badge)
		desc = "An armored vest that protects against some damage. This one has [attached_badge] attached to it."
	else
		desc = initial(desc)


/obj/item/clothing/suit/armor/vest/security/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clothing/accessory/holobadge))
		add_fingerprint(user)
		if(attached_badge)
			to_chat(user, span_warning("На [declent_ru(PREPOSITIONAL)] уже есть [attached_badge.declent_ru(NOMINATIVE)]."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		to_chat(user, span_notice("Вы прицепили [I.declent_ru(ACCUSATIVE)] к [declent_ru(DATIVE)]."))
		attached_badge = I
		var/datum/action/item_action/remove_badge/holoaction = new(src)
		holoaction.Grant(user)
		update_appearance(UPDATE_ICON_STATE|UPDATE_DESC)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/clothing/suit/armor/vest/security/attack_self(mob/user)
	if(attached_badge)
		add_fingerprint(user)
		user.put_in_hands(attached_badge)
		for(var/datum/action/item_action/remove_badge/action in actions)
			LAZYREMOVE(actions, action)
			action.Remove(user)
		attached_badge = null
		update_appearance(UPDATE_ICON_STATE|UPDATE_DESC)
		update_equipped_item()
		to_chat(user, span_notice("Вы снимаете [attached_badge.declent_ru(ACCUSATIVE)] с [declent_ru(GENITIVE)]."))
		return
	..()


/obj/item/clothing/suit/armor/vest/blueshield
	name = "blueshield security armor"
	desc = "An armored vest with the badge of a Blueshield Lieutenant."
	icon_state = "blueshield"
	item_state = "blueshield"

/obj/item/clothing/suit/armor/vest/bloody
	name = "bloodied security armor"
	desc = "A vest drenched in the blood of Greytide. It has seen better days."
	icon_state = "bloody_armor"
	item_state = "bloody_armor"
	sprite_sheets = null

/obj/item/clothing/suit/armor/secjacket
	name = "security jacket"
	desc = "A sturdy black jacket with reinforced fabric. Bears insignia of NT corporate security."
	icon_state = "secjacket_open"
	item_state = "secjacket"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	armor = list(melee = 25, bullet = 15, laser = 25, energy = 10, bomb = 25, bio = 0, rad = 0, fire = 50, acid = 50)
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	heat_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	ignore_suitadjust = FALSE
	actions_types = list(/datum/action/item_action/openclose)
	adjust_flavour = "unzip"

/obj/item/clothing/suit/armor/hos
	name = "armored coat"
	desc = "A trench coat enhanced with a special alloy for some protection and style."
	icon_state = "hos"
	item_state = "hos"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 25, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 70, "acid" = 90)
	flags_inv = HIDEJUMPSUIT
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	strip_delay = 80

/obj/item/clothing/suit/armor/hos/alt
	name = "armored trenchoat"
	desc = "A trenchcoat enhanced with a special lightweight kevlar. The epitome of tactical plainclothes."
	icon_state = "hostrench_open"
	item_state = "hostrench_open"
	flags_inv_transparent = HIDEJUMPSUIT
	ignore_suitadjust = FALSE
	actions_types = list(/datum/action/item_action/openclose)
	adjust_flavour = "unbutton"

/obj/item/clothing/suit/armor/hos/jensen
	name = "armored trenchcoat"
	desc = "A trenchcoat augmented with a special alloy for some protection and style."
	icon_state = "jensencoat"
	item_state = "jensencoat"
	flags_inv_transparent = HIDEJUMPSUIT
	sprite_sheets = null

/obj/item/clothing/suit/armor/vest/warden
	name = "Warden's armored jacket"
	desc = "An armored jacket with silver rank pips and livery."
	icon_state = "warden_jacket"
	item_state = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	cold_protection = UPPER_TORSO|LOWER_TORSO|HANDS
	heat_protection = UPPER_TORSO|LOWER_TORSO|HANDS
	strip_delay = 70
	resistance_flags = FLAMMABLE
	dog_fashion = null

/obj/item/clothing/suit/armor/vest/warden/alt
	name = "warden's jacket"
	desc = "A navy-blue armored jacket with blue shoulder designations and '/Warden/' stitched into one of the chest pockets."
	icon_state = "warden_jacket_alt"

/obj/item/clothing/suit/armor/vest/sec_rps
	name = "security belt-shoulder system"
	desc = "A belt-shoulder system for officers that are more inclined towards style than safety."
	icon_state = "sec_rps"
	armor=  list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 5, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

/obj/item/clothing/suit/armor/vest/capcarapace
	name = "captain's carapace"
	desc = "An armored vest reinforced with ceramic plates and pauldrons to provide additional protection whilst still offering maximum mobility and flexibility. Issued only to the station's finest, although it does chafe your nipples."
	icon_state = "capcarapace"
	item_state = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	armor = list("melee" = 50, "bullet" = 40, "laser" = 50, "energy" = 20, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 90)
	dog_fashion = null
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/armor/vest/capcarapace/alt
	name = "captain's parade jacket"
	desc = "For when an armored vest isn't fashionable enough."
	icon_state = "capformal"
	item_state = "capspacesuit"

/obj/item/clothing/suit/armor/riot
	name = "Riot Suit"
	desc = "A suit of armor with heavy padding to protect against melee attacks. Looks like it might impair movement."
	icon_state = "riot"
	item_state = "swat_suit"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	armor = list("melee" = 50, "bullet" = 10, "laser" = 10, "energy" = 20, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80)
	flags_inv = HIDEJUMPSUIT
	flags_inv_transparent = HIDEJUMPSUIT
	strip_delay = 80
	put_on_delay = 60
	hide_tail_by_species = list(SPECIES_VOX)
	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/suit.dmi'
		)

/obj/item/clothing/suit/armor/riot/knight
	name = "plate armour"
	desc = "A classic suit of plate armour, highly effective at stopping melee attacks."
	icon_state = "knight_green"
	item_state = "knight_green"
	slowdown = 1
	hide_tail_by_species = list(SPECIES_VULPKANIN)
	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/suit.dmi'
		)

/obj/item/clothing/suit/armor/riot/knight/yellow
	icon_state = "knight_yellow"
	item_state = "knight_yellow"
	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/suit.dmi'
		)

/obj/item/clothing/suit/armor/riot/knight/blue
	icon_state = "knight_blue"
	item_state = "knight_blue"
	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/suit.dmi'
		)

/obj/item/clothing/suit/armor/riot/knight/red
	icon_state = "knight_red"
	item_state = "knight_red"
	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/suit.dmi'
		)

/obj/item/clothing/suit/armor/riot/knight/templar
	name = "crusader armour"
	desc = "God wills it!"
	icon_state = "knight_templar"
	item_state = "knight_templar"
	allowed = list(/obj/item/nullrod/claymore, /obj/item/storage/belt/claymore)
	armor = list(melee = 25, bullet = 5, laser = 5, energy = 5, bomb = 0, bio = 0, rad = 0, fire = 80, acid = 80)
	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/suit.dmi'
		)

/obj/item/clothing/suit/armor/vest/durathread
	name = "durathread vest"
	desc = "A vest made of durathread with strips of leather acting as trauma plates."
	icon_state = "durathread"
	item_state = "durathread"
	strip_delay = 60
	max_integrity = 200
	resistance_flags = FLAMMABLE
	armor = list("melee" = 20, "bullet" = 10, "laser" = 30, "energy" = 15, "bomb" = 15, "bio" = 0, "rad" = 0, "fire" = 40, "acid" = 50)

/obj/item/clothing/suit/armor/bulletproof
	name = "Bulletproof Vest"
	desc = "A bulletproof vest that excels in protecting the wearer against traditional projectile weaponry and explosives to a minor extent."
	icon_state = "bulletproof"
	item_state = "armor"
	blood_overlay_type = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	armor = list("melee" = 15, "bullet" = 60, "laser" = 10, "energy" = 20, "bomb" = 40, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	strip_delay = 70
	put_on_delay = 50
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
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/suit.dmi'
		)

/obj/item/clothing/suit/armor/laserproof
	name = "Ablative Armor Vest"
	desc = "Экспериментальный высокотехнологичный бронежилет, изготовленный из светоотражающего материала, предназначен для отражения энергетических лучей. Устаревшая амуниция, была снята с вооружения НаноТрейзен."
	ru_names = list(
		NOMINATIVE = "абляционный бронежилет",
		GENITIVE = "абляционного бронежилета",
		DATIVE = "абляционному бронежилету",
		ACCUSATIVE = "абляционный бронежилет",
		INSTRUMENTAL = "абляционным бронежилетом",
		PREPOSITIONAL = "абляционном бронежилете"
	)
	icon_state = "armor_reflec"
	item_state = "armor_reflec"
	blood_overlay_type = "armor"
	armor = list("melee" = 10, "bullet" = 10, "laser" = 60, "energy" = 50, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/hit_reflect_chance = 50

/obj/item/clothing/suit/armor/reflector
	name = "reflector coat"
	desc = "Высокотехнологичное инновационное пальто, изготовленное из светоотражающего материала, предназначенное для отражения энергетических лучей. Сочетает в себе стиль и самые передовые технологии."
	ru_names = list(
		NOMINATIVE = "рефлекторное пальто",
		GENITIVE = "рефлекторное пальто",
		DATIVE = "рефлекторному пальто",
		ACCUSATIVE = "рефлекторное пальто",
		INSTRUMENTAL = "рефлекторным пальто",
		PREPOSITIONAL = "рефлекторном пальто"
	)
	icon_state = "reflector"
	item_state = "reflector"
	blood_overlay_type = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	armor = list("melee" = 10, "bullet" = 10, "laser" = 60, "energy" = 60, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
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
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		)
	var/list/reflect_zones = list(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
	var/hit_reflect_chance = 50

/obj/item/clothing/suit/armor/reflector/IsReflect(def_zone)
	if(!(def_zone in reflect_zones))
		return FALSE
	if (prob(hit_reflect_chance))
		return TRUE

/obj/item/clothing/suit/armor/laserproof/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/high_value_item)

/obj/item/clothing/suit/armor/laserproof/IsReflect()
	if(prob(hit_reflect_chance))
		return 1

/obj/item/clothing/suit/armor/vest/det_suit
	name = "armor"
	desc = "An armored vest with a detective's badge on it."
	icon_state = "detective-armor"
	item_state = "armor"
	blood_overlay_type = "armor"
	allowed = list(/obj/item/tank/internals/emergency_oxygen,/obj/item/reagent_containers/spray/pepper,/obj/item/flashlight,/obj/item/gun,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/restraints/handcuffs,/obj/item/storage/fancy/cigarettes,/obj/item/lighter,/obj/item/detective_scanner,/obj/item/taperecorder)
	resistance_flags = FLAMMABLE
	dog_fashion = null

//Reactive armor
/obj/item/clothing/suit/armor/reactive
	name = "reactive armor"
	desc = "Doesn't seem to do much for some reason."
	var/active = FALSE
	var/emp_d = FALSE
	icon_state = "reactiveoff"
	item_state = "reactiveoff"
	blood_overlay_type = "armor"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100)
	actions_types = list(/datum/action/item_action/toggle)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	hit_reaction_chance = 50


/obj/item/clothing/suit/armor/reactive/update_icon_state()
	icon_state =  "reactive[active ? "" : "off"]"
	item_state =  "reactive[active ? "" : "off"]"


/obj/item/clothing/suit/armor/reactive/attack_self(mob/user)
	if(emp_d)
		to_chat(user, span_warning("[capitalize(declent_ru(NOMINATIVE))] отключён из-за электромагнитного импульса!"))
		return
	active = !active
	update_icon(UPDATE_ICON_STATE)
	add_fingerprint(user)
	to_chat(user, span_notice("[capitalize(declent_ru(NOMINATIVE))] теперь [active ? "активен" : "неактивен"]."))
	update_equipped_item()


/obj/item/clothing/suit/armor/reactive/emp_act(severity)
	active = FALSE
	emp_d = TRUE
	update_icon(UPDATE_ICON_STATE)
	addtimer(CALLBACK(src, PROC_REF(reboot)), 100 / severity)
	if(ishuman(loc))
		var/mob/living/carbon/human/user = loc
		to_chat(user, span_warning("[capitalize(declent_ru(NOMINATIVE))] начинает глючить!"))
		update_equipped_item()
	..()


/obj/item/clothing/suit/armor/reactive/proc/reboot()
	emp_d = FALSE
	if(ishuman(loc))
		var/mob/living/carbon/human/user = loc
		update_equipped_item()
		to_chat(user, span_notice("Похоже, [declent_ru(NOMINATIVE)] снова функционирует нормально."))


//When the wearer gets hit, this armor will teleport the user a short distance away (to safety or to more danger, no one knows. That's the fun of it!)
/obj/item/clothing/suit/armor/reactive/teleport
	name = "reactive teleport armor"
	desc = "Someone seperated our Research Director from his own head!"
	var/tele_range = 2

/obj/item/clothing/suit/armor/reactive/teleport/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/high_value_item)

/obj/item/clothing/suit/armor/reactive/teleport/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "атаку", final_block_chance = 0, damage = 0, attack_type = ITEM_ATTACK)
	if(!active)
		return 0
	if(prob(hit_reaction_chance))
		var/mob/living/carbon/human/H = owner
		owner.visible_message(
			span_danger("Реактивная телепортная система отражает [attack_text] [H.declent_ru(GENITIVE)]!"),
			projectile_message = (attack_type == PROJECTILE_ATTACK)
		)
		var/list/turfs = new/list()
		for(var/turf/T in orange(tele_range, H))
			if(isspaceturf(T))
				continue
			if(T.density)
				continue
			if(T.x>world.maxx-tele_range || T.x<tele_range)
				continue
			if(T.y>world.maxy-tele_range || T.y<tele_range)
				continue
			turfs += T
		if(!turfs.len)
			turfs += pick(/turf in orange(tele_range, H))
		var/turf/picked = pick(turfs)
		if(!isturf(picked))
			return
		H.forceMove(picked)
		return 1
	return 0

/obj/item/clothing/suit/armor/reactive/fire
	name = "reactive incendiary armor"

/obj/item/clothing/suit/armor/reactive/fire/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "атаку", final_block_chance = 0, damage = 0, attack_type = ITEM_ATTACK)
	if(!active)
		return 0
	if(prob(hit_reaction_chance))
		owner.visible_message(
			span_danger("[capitalize(declent_ru(NOMINATIVE))] блокирует [attack_text], выпуская струи пламени!"),
			projectile_message = (attack_type == PROJECTILE_ATTACK)
		)
		for(var/mob/living/carbon/C in range(6, owner))
			if(C != owner)
				C.fire_stacks += 8
				C.IgniteMob()
		owner.fire_stacks = -20
		return 1
	return 0

/obj/item/clothing/suit/armor/reactive/stealth
	name = "reactive stealth armor"

/obj/item/clothing/suit/armor/reactive/stealth/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "удар", final_block_chance = 0, damage = 0, attack_type = ITEM_ATTACK)
	if(!active)
		return 0
	if(prob(hit_reaction_chance))
		var/mob/living/simple_animal/hostile/illusion/escape/E = new(owner.loc)
		E.Copy_Parent(owner, 50)
		E.GiveTarget(owner) //so it starts running right away
		E.Goto(owner, E.move_to_delay, E.minimum_distance)
		owner.alpha = 0
		owner.visible_message(
			span_danger("[owner] получает [attack_text] в грудь!"),
			projectile_message = (attack_type == PROJECTILE_ATTACK)
		) //We pretend to be hit, since blocking it would stop the message otherwise
		spawn(40)
			owner.alpha = initial(owner.alpha)
		return 1

/obj/item/clothing/suit/armor/reactive/tesla
	name = "reactive tesla armor"

/obj/item/clothing/suit/armor/reactive/tesla/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "атаку", final_block_chance = 0, damage = 0, attack_type = ITEM_ATTACK)
	if(!active)
		return 0
	if(prob(hit_reaction_chance))
		owner.visible_message(
			span_danger("[capitalize(declent_ru(NOMINATIVE))] блокирует [attack_text], испуская разряды молний!"),
			projectile_message = (attack_type == PROJECTILE_ATTACK)
		)
		for(var/mob/living/M in view(6, owner))
			if(M == owner)
				continue
			owner.Beam(M,icon_state="lightning[rand(1, 12)]",icon='icons/effects/effects.dmi',time=5)
			M.adjustFireLoss(25)
			playsound(M, 'sound/machines/defib_zap.ogg', 50, TRUE, -1)
		return 1

//All of the armor below is mostly unused


/obj/item/clothing/suit/armor/centcomm
	name = "Cent. Com. armor"
	desc = "A suit that protects against some damage."
	icon_state = "centcom"
	item_state = "centcom"
	w_class = WEIGHT_CLASS_BULKY
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/gun/energy,/obj/item/melee/baton,/obj/item/restraints/handcuffs,/obj/item/tank/internals/emergency_oxygen)
	clothing_flags = THICKMATERIAL
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	sprite_sheets = null
	armor = list("melee" = 80, "bullet" = 80, "laser" = 50, "energy" = 50, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 90)

/obj/item/clothing/suit/armor/heavy
	name = "heavy armor"
	desc = "A heavily armored suit that protects against moderate damage."
	icon_state = "heavy"
	item_state = "swat_suit"
	armor = list("melee" = 80, "bullet" = 80, "laser" = 50, "energy" = 50, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 90)
	w_class = WEIGHT_CLASS_BULKY
	gas_transfer_coefficient = 0.90
	clothing_flags = THICKMATERIAL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	slowdown = 3
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	hide_tail_by_species = list(SPECIES_VOX)
	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/suit.dmi'
	)

/obj/item/clothing/suit/armor/tdome
	armor = list("melee" = 80, "bullet" = 80, "laser" = 50, "energy" = 50, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 90)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	clothing_flags = THICKMATERIAL
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	hide_tail_by_species = list(SPECIES_VOX, SPECIES_VULPKANIN)

/obj/item/clothing/suit/armor/tdome/red
	name = "Red Thunderdome Armor"
	desc = "Armor worn by the red Thunderdome team."
	icon_state = "tdred"
	item_state = "tdred"
	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/suit.dmi'
	)

/obj/item/clothing/suit/armor/tdome/green
	name = "Green Thunderdome Armor"
	desc = "Armor worn by the green Thunderdome team."
	icon_state = "tdgreen"
	item_state = "tdgreen"
	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/suit.dmi'
	)

//Non-hardsuit ERT armor.
/obj/item/clothing/suit/armor/vest/ert
	name = "emergency response team armor"
	desc = "A set of armor worn by members of the Nanotrasen Emergency Response Team."
	icon_state = "ertarmor_cmd"
	item_state = "armor"
	armor = list(melee = 30, bullet = 30, laser = 30, energy = 30, bomb = 20, bio = 0, rad = 0, fire = 50, acid = 50)

//Commander
/obj/item/clothing/suit/armor/vest/ert/command
	name = "emergency response team commander armor"
	desc = "A set of armor worn by the commander of a Nanotrasen Emergency Response Team. Has blue highlights."

//Security
/obj/item/clothing/suit/armor/vest/ert/security
	name = "emergency response team security armor"
	desc = "A set of armor worn by security members of the Nanotrasen Emergency Response Team. Has red highlights."
	icon_state = "ertarmor_sec"


/obj/item/clothing/suit/armor/vest/ert/security/paranormal
	name = "emergency response team paranormal armor"
	desc = "A set of armor worn by paranormal members of the Nanotrasen Emergency Response Team. Has crusader sigils."
	icon_state = "knight_templar"
	item_state = "knight_templar"
	hide_tail_by_species = list(SPECIES_VOX, SPECIES_VULPKANIN)
	allowed = list(/obj/item/nullrod/claymore, /obj/item/storage/belt/claymore, /obj/item/gun/energy,/obj/item/reagent_containers/spray/pepper,/obj/item/gun/projectile,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/restraints/handcuffs,/obj/item/flashlight/seclite,/obj/item/kitchen/knife/combat)
	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/suit.dmi'
		)

//Engineer
/obj/item/clothing/suit/armor/vest/ert/engineer
	name = "emergency response team engineer armor"
	desc = "A set of armor worn by engineering members of the Nanotrasen Emergency Response Team. Has orange highlights."
	icon_state = "ertarmor_eng"

//Medical
/obj/item/clothing/suit/armor/vest/ert/medical
	name = "emergency response team medical armor"
	desc = "A set of armor worn by medical members of the Nanotrasen Emergency Response Team. Has red and white highlights."
	icon_state = "ertarmor_med"

//Janitorial
/obj/item/clothing/suit/armor/vest/ert/janitor
	name = "emergency response team janitor armor"
	desc = "A set of armor worn by janitorial members of the Nanotrasen Emergency Response Team. Has red and white highlights."
	icon_state = "ertarmor_jan"

//same defense as basic sec armor
/obj/item/clothing/suit/storage/lawyer/blackjacket/armored
	desc = "A snappy dress jacket, reinforced with a layer of armor protecting the torso."
	allowed = list(/obj/item/tank/internals/emergency_oxygen, /obj/item/gun/projectile/revolver, /obj/item/gun/projectile/automatic/pistol)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	cold_protection = UPPER_TORSO|LOWER_TORSO
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	heat_protection = UPPER_TORSO|LOWER_TORSO
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	armor = list(melee = 25, bullet = 15, laser = 25, energy = 10, bomb = 25, bio = 0, rad = 0, fire = 40, acid = 40)

//LAVALAND!

/obj/item/clothing/suit/hooded/drake
	name = "drake armour"
	icon_state = "dragon"
	item_state = "dragon"
	desc = "Доспехи, созданные из останков пепельного дракона."
	ru_names = list(
		NOMINATIVE = "доспех из дрейка",
		GENITIVE = "доспеха из дрейка",
		DATIVE = "доспеху из дрейка",
		ACCUSATIVE = "доспех из дрейка",
		INSTRUMENTAL = "доспехом из дрейка",
		PREPOSITIONAL = "доспехе из дрейка"
	)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/kinetic_accelerator, /obj/item/pickaxe, /obj/item/twohanded/spear, /obj/item/twohanded/kinetic_crusher, /obj/item/hierophant_club, /obj/item/twohanded/fireaxe/boneaxe)
	armor = list("melee" = 70, "bullet" = 30, "laser" = 50, "energy" = 40, "bomb" = 70, "bio" = 60, "rad" = 50, "fire" = 100, "acid" = 100)
	hoodtype = /obj/item/clothing/head/hooded/drake
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/suit.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/suit.dmi'
		)
	hide_tail_by_species = list(SPECIES_VULPKANIN)

/obj/item/clothing/head/hooded/drake
	name = "drake helmet"
	icon_state = "dragon"
	item_state = "dragon"
	desc = "Череп дрейка."
	ru_names = list(
		NOMINATIVE = "шлем из дрейка",
		GENITIVE = "шлема из дрейка",
		DATIVE = "шлему из дрейка",
		ACCUSATIVE = "шлем из дрейка",
		INSTRUMENTAL = "шлемом из дрейка",
		PREPOSITIONAL = "шлеме из дрейка"
	)
	armor = list("melee" = 70, "bullet" = 30, "laser" = 50, "energy" = 40, "bomb" = 70, "bio" = 60, "rad" = 50, "fire" = 100, "acid" = 100)
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF|ACID_PROOF
	flags_inv = HIDEHAIR
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/suit/hooded/goliath
	name = "goliath cloak"
	icon_state = "goliath_cloak"
	item_state = "goliath_cloak"
	desc = "Прочный и практичный плащ, созданный из различных материалов, добытых из монстров. Он пользуется большим спросом у тех, кто ведёт жизнь отшельника или изгнанника."
	ru_names = list(
		NOMINATIVE = "накидка из голиафа",
		GENITIVE = "накидки из голиафа",
		DATIVE = "накидке из голиафа",
		ACCUSATIVE = "накидку из голиафа",
		INSTRUMENTAL = "накидкой из голиафа",
		PREPOSITIONAL = "накидке из голиафа"
	)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/pickaxe, /obj/item/twohanded/spear, /obj/item/organ/internal/regenerative_core/legion, /obj/item/kitchen/knife/combat/survival, /obj/item/twohanded/kinetic_crusher, /obj/item/hierophant_club, /obj/item/twohanded/fireaxe/boneaxe)
	armor = list(MELEE = 40, BULLET = 15, LASER = 30, ENERGY = 15, BOMB = 35, BIO = 0, RAD = 0, FIRE = 80, ACID = 60) //a fair alternative to bone armor, requiring alternative materials and gaining a suit slot
	hoodtype = /obj/item/clothing/head/hooded/goliath
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/head/hooded/goliath
	name = "goliath cloak hood"
	icon_state = "golhood"
	item_state = "golhood"
	desc = "Защитный и скрывающий капюшон."
	ru_names = list(
		NOMINATIVE = "капюшон накидки из голиафа",
		GENITIVE = "капюшона накидки из голиафа",
		DATIVE = "капюшону накидки из голиафа",
		ACCUSATIVE = "капюшон накидки из голиафа",
		INSTRUMENTAL = "капюшоном накидки из голиафа",
		PREPOSITIONAL = "капюшоне накидки из голиафа"
	)
	armor = list(MELEE = 40, BULLET = 15, LASER = 30, ENERGY = 15, BOMB = 35, BIO = 0, RAD = 0, FIRE = 80, ACID = 60)
	flags_inv = HIDEHAIR
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/suit/hooded/goliath/wizard
	armor = list("melee" = 60, "bullet" = 10, "laser" = 25, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 60)
	hoodtype = /obj/item/clothing/head/hooded/goliath/wizard
	magical = TRUE

/obj/item/clothing/head/hooded/goliath/wizard
	name = "shaman skull"
	icon_state = "shamskull"
	item_state = "shamskull"
	desc = "К передней части переделанного шлема прикрутили череп какого-то дохлого зверя."
	ru_names = list(
		NOMINATIVE = "череп шамана",
		GENITIVE = "черепа шамана",
		DATIVE = "черепу шамана",
		ACCUSATIVE = "череп шамана",
		INSTRUMENTAL = "черепом шамана",
		PREPOSITIONAL = "черепе шамана"
	)
	armor = list("melee" = 60, "bullet" = 10, "laser" = 25, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 60)
	magical = TRUE

//mob_size using for crusher mark
/obj/item/clothing/suit/hooded/goliath/wizard/equipped(mob/living/user, slot, initial = FALSE)
	. = ..()
	if(istype(user) && slot == ITEM_SLOT_HEAD)
		user.mob_size = MOB_SIZE_LARGE

/obj/item/clothing/suit/hooded/goliath/wizard/dropped(mob/living/user, slot, silent = FALSE)
	. = ..()
	if(istype(user)&& slot == ITEM_SLOT_HEAD)
		user.mob_size = MOB_SIZE_HUMAN

/obj/item/clothing/suit/armor/bone
	name = "bone armor"
	desc = "Племенной доспех, созданный из костей животных."
	ru_names = list(
		NOMINATIVE = "костяная броня",
		GENITIVE = "костяной брони",
		DATIVE = "костяной броне",
		ACCUSATIVE = "костяную броню",
		INSTRUMENTAL = "костяной броней",
		PREPOSITIONAL = "костяной броне"
	)
	icon_state = "bonearmor"
	item_state = "bonearmor"
	blood_overlay_type = "armor"
	armor = list("melee" = 45, "bullet" = 30, "laser" = 30, "energy" = 20, "bomb" = 40, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/pickaxe, /obj/item/twohanded/spear, /obj/item/organ/internal/regenerative_core/legion, /obj/item/kitchen/knife/combat/survival, /obj/item/twohanded/kinetic_crusher, /obj/item/hierophant_club, /obj/item/twohanded/fireaxe/boneaxe)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS
	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/suit.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/suit.dmi'
		)
	hide_tail_by_species = list(SPECIES_VULPKANIN)

/obj/item/clothing/suit/armor/makeshift_armor
	name = "makeshift armor"
	desc = "This is a makeshift armor. Somehow duct tape grants more protection, than a sign itself."
	icon_state = "makeshift_armor"
	item_state = "makeshift_armor"
	resistance_flags = FIRE_PROOF
	armor = list("melee" = 8, "bullet" = 5, "laser" = 5, "energy" = 30, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

//Dredd

/obj/item/clothing/suit/armor/vest/street_judge
	name = "judge's security armor"
	desc = "Perfect for when you're looking to send a message rather than performing your actual duties."
	icon_state = "streetjudgearmor"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/suit.dmi',
		)

/obj/item/clothing/suit/armor/cartilage //parent type, used in order not to copy-paste same lines in 3 same armors
	name = "cartilage armor"
	desc = "Полностью завершённая броня, сделанная из хрящевых пластин лавовой рыбы. Крепче своих костяных аналогов."
	ru_names = list(
		NOMINATIVE = "броня из хрящевых пластин",
		GENITIVE = "брони из хрящевых пластин",
		DATIVE = "броне из хрящевых пластин",
		ACCUSATIVE = "броню из хрящевых пластин",
		INSTRUMENTAL = "броней из хрящевых пластин",
		PREPOSITIONAL = "броне из хрящевых пластин"
	)
	gender = FEMALE
	icon_state = "cartilage_set"
	item_state = "cartilage_set"
	blood_overlay_type = "armor"
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/pickaxe, /obj/item/twohanded/spear, /obj/item/organ/internal/regenerative_core/legion, /obj/item/kitchen/knife/combat/survival, /obj/item/twohanded/kinetic_crusher, /obj/item/hierophant_club, /obj/item/twohanded/fireaxe/boneaxe)
	armor = list(MELEE = 50, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 10, BIO = 0, RAD = 0, FIRE = 60, ACID = 60)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)


/obj/item/clothing/suit/armor/cartilage/cartilage_pads
	name = "cartilage shoulder pads"
	desc = "Достаточно крепкие наплечники, сделанные из хрящевых пластин. Защищают тело, но не предоставляют защиты для ног. Могут быть улучшены до полноценной брони в случае, если будут соединены с поножами, сделанными из того же материала."
	ru_names = list(
		NOMINATIVE = "наплечники из хрящевых пластин",
		GENITIVE = "наплечников из хрящевых пластин",
		DATIVE = "наплечникам из хрящевых пластин",
		ACCUSATIVE = "наплечники из хрящевых пластин",
		INSTRUMENTAL = "наплечниками из хрящевых пластин",
		PREPOSITIONAL = "наплечниках из хрящевых пластин"
	)
	gender = PLURAL
	icon_state = "cartilage_shoulder_pads"
	item_state = "cartilage_shoulder_pads"
	body_parts_covered = UPPER_TORSO|ARMS

/obj/item/clothing/suit/armor/cartilage/cartilage_pads/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clothing/suit/armor/cartilage/cartilage_greaves))
		add_fingerprint(user)
		to_chat(user, span_notice("Вы начинаете подвязывать части брони."))
		if(do_after(user, 4 SECONDS, src, max_interact_count = 1))
			to_chat(user, span_notice("Вы улучшили броню!"))
			var/turf/user_turf = get_turf(user)
			var/obj/item/clothing/suit/armor/cartilage/armor = new(user_turf)
			user.put_in_inactive_hand(armor)
			qdel(I)
			qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()

/obj/item/clothing/suit/armor/cartilage/cartilage_greaves
	name = "cartilage greaves"
	desc = "Достаточно крепкие поножи, сделанные из хрящевых пластин. Защищают ноги, но не предоставляют защиты для торса. Могут быть улучшены до полноценной брони в случае, если будут соединены с наплечниками, сделанными из того же материала."
	ru_names = list(
		NOMINATIVE = "поножи из хрящевых пластин",
		GENITIVE = "поножей из хрящевых пластин",
		DATIVE = "поножам из хрящевых пластин",
		ACCUSATIVE = "поножи из хрящевых пластин",
		INSTRUMENTAL = "поножами из хрящевых пластин",
		PREPOSITIONAL = "поножах из хрящевых пластин"
	) //i actually have to google it
	gender = PLURAL
	icon_state = "cartilage_greaves"
	item_state = "cartilage_greaves"
	body_parts_covered = LOWER_TORSO|LEGS

/obj/item/clothing/suit/armor/cartilage/cartilage_greaves/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clothing/suit/armor/cartilage/cartilage_pads))
		add_fingerprint(user)
		to_chat(user, span_notice("Вы начинаете подвязывать части брони."))
		if(do_after(user, 4 SECONDS, src, max_interact_count = 1))
			to_chat(user, span_notice("Вы улучшили броню!"))
			var/turf/user_turf = get_turf(user)
			var/obj/item/clothing/suit/armor/cartilage/armor = new(user_turf)
			user.put_in_inactive_hand(armor)
			qdel(I)
			qdel(src)
			return ATTACK_CHAIN_BLOCKED_ALL
	return ..()
