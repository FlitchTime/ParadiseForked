/* Two-handed Weapons
 * Contains:
 * 		Twohanded
 *		Fireaxe
 *		Double-Bladed Energy Swords
 *		Spears
 *		Kidan spear
 *		Chainsaw
 *		Singularity hammer
 * 		Mjolnnir
 *		Knighthammer
 *      Pyro Claws
 */

/*##################################################################
##################### TWO HANDED WEAPONS BE HERE~ -Agouri :3 ########
####################################################################*/

//Rewrote TwoHanded weapons stuff and put it all here. Just copypasta fireaxe to make new ones ~Carn
//This rewrite means we don't have two variables for EVERY item which are used only by a few weapons.
//It also tidies stuff up elsewhere.
//
//										ALL TWOHANDED WEAPONS ARE BASED ON COMPONENT FROM NOW ON
//												SEE TWOHANDED.DM FOR DOCUMENTATION
//

/*
 * Twohanded
 */
/obj/item/twohanded
	//All these vars used only for component initialization (twohanded.dm)
	//`wielded` is actually changed in component, because i'm too lazy to replace it everywhere. At least for now.
	//But you can use HAS_TRAIT(src, TRAIT_WIELDED) to emulate same behavior.
	var/wielded = FALSE
	var/force_unwielded = 0
	var/force_wielded = 0
	var/wieldsound = FALSE
	var/unwieldsound = FALSE
	var/sharp_when_wielded = FALSE

	lefthand_file = 'icons/mob/inhands/twohanded_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/twohanded_righthand.dmi'


/obj/item/twohanded/Initialize(mapload)
	. = ..()
	apply_twohanded_component()


/**
 * Proc handles adding component during Initialize()
 *
 * Applies general twohanded component based on item vars. You can easily override this proc for child items to avoid inheritance.
 * Component is flexible and will rewrite old initial values to new ones if needed.
 */
/obj/item/twohanded/proc/apply_twohanded_component()
	AddComponent(/datum/component/two_handed, \
		force_unwielded = src.force_unwielded, \
		force_wielded = src.force_wielded, \
		wieldsound = src.wieldsound, \
		unwieldsound = src.unwieldsound, \
		sharp_when_wielded = src.sharp_when_wielded, \
		wield_callback = CALLBACK(src, PROC_REF(wield)), \
		unwield_callback = CALLBACK(src, PROC_REF(unwield)) \
	)


/**
 * Generic CALLBACK when twohanded item get `wielded`. Avoid inheritance unless you know what you are doing.
 *
 * Parameters actually useless since you can use `src` and `usr` already.
 */
/obj/item/twohanded/proc/wield(obj/item/source, mob/living/carbon/user)


/**
 * Generic CALLBACK when twohanded item get `UNwielded`. Avoid inheritance unless you know what you are doing.
 *
 * Parameters actually useless since you can use `src` and `usr` already.
 */
/obj/item/twohanded/proc/unwield(obj/item/source, mob/living/carbon/user)


///////////Two hand required objects///////////////
//This is for objects that require two hands to even pick up
/obj/item/twohanded/required
	w_class = WEIGHT_CLASS_HUGE


//We are adding new parameter to old component
/obj/item/twohanded/required/apply_twohanded_component()
	..()
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)


/*
 * Fireaxe
 */
/obj/item/twohanded/fireaxe  // DEM AXES MAN, marker -Agouri
	icon_state = "fireaxe0"
	name = "fire axe"
	desc = "Truly, the weapon of a madman. Who would think to fight fire with an axe?"
	gender = MALE
	force = 5
	throwforce = 15
	sharp = TRUE
	embed_chance = 25
	embedded_ignore_throwspeed_threshold = TRUE
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	force_unwielded = 5
	force_wielded = 24
	toolspeed = 0.25
	attack_verb = list("атаковал", "рубанул", "поранил", "порезал")
	hitsound = 'sound/weapons/bladeslice.ogg'
	usesound = 'sound/items/crowbar.ogg'
	max_integrity = 200
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 30)
	resistance_flags = FIRE_PROOF

/obj/item/twohanded/fireaxe/ComponentInitialize()
	. = ..()
	AddComponent( \
		/datum/component/cleave_attack, \
		arc_size = 180, \
		swing_speed_mod = 2, \
		afterswing_slowdown = 0.25, \
		slowdown_duration = 1 SECONDS, \
		requires_wielded = TRUE, \
		no_multi_hit = TRUE, \
		swing_sound = "chop_swing_heavy" \
	)

/obj/item/twohanded/fireaxe/update_icon_state()  //Currently only here to fuck with the on-mob icons.
	icon_state = "fireaxe[HAS_TRAIT(src, TRAIT_WIELDED)]"


/obj/item/twohanded/fireaxe/afterattack(atom/A, mob/user, proximity, params)
	. = ..()
	if(!proximity)
		return
	if(HAS_TRAIT(src, TRAIT_WIELDED)) //destroys windows and grilles in one hit
		if(istype(A, /obj/structure/window) || istype(A, /obj/structure/grille))
			var/obj/structure/W = A
			W.obj_destruction("fireaxe")

/obj/item/twohanded/fireaxe/boneaxe  // Blatant imitation of the fireaxe, but made out of bone.
	icon_state = "bone_axe0"
	name = "bone axe"
	desc = "Большой и мощный топор, созданный из нескольких остро заточенных костяных пластин, грубо связанных вместе. Создан из монстров, путём убийства монстров, для убийства монстров."
	ru_names = list(
		NOMINATIVE = "костяной топор",
		GENITIVE = "костяного топора",
		DATIVE = "костяному топору",
		ACCUSATIVE = "костяной топор",
		INSTRUMENTAL = "костяным топором",
		PREPOSITIONAL = "костяном топоре"
	)
	force_wielded = 23
	needs_permit = TRUE

/obj/item/twohanded/fireaxe/boneaxe/update_icon_state()
	icon_state = "bone_axe[HAS_TRAIT(src, TRAIT_WIELDED)]"

/obj/item/twohanded/fireaxe/boneaxe/guillotine
	name = "guillotine"
	desc = "Массивный, грозно выглядящий пилотопор, созданный с использованием костяного нароста ослеплённого жнеца. Идеален для убийства и последующей разделки чудовищ."
	ru_names = list(
		NOMINATIVE = "гильотина",
		GENITIVE = "гильотины",
		DATIVE = "гильотине",
		ACCUSATIVE = "гильотину",
		INSTRUMENTAL = "гильотиной",
		PREPOSITIONAL = "гильотине"
	)
	icon_state = "guillotine0"
	hitsound = 'sound/weapons/circsawhit.ogg'
	force_unwielded = 7
	force_wielded = 25
	throwforce = 20
	armour_penetration = 30
	lefthand_file = 'icons/mob/inhands/lavaland/lava_items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/lava_items_righthand.dmi'
	has_speed_harvest = TRUE

/obj/item/twohanded/fireaxe/boneaxe/guillotine/ComponentInitialize()
	. = ..()
	AddComponent( \
		/datum/component/cleave_attack, \
		arc_size = 180, \
		swing_speed_mod = 2, \
		afterswing_slowdown = 0.25, \
		slowdown_duration = 1 SECONDS, \
		requires_wielded = TRUE, \
		swing_sound = "chop_swing_heavy" \
	)

/obj/item/twohanded/fireaxe/boneaxe/guillotine/update_icon_state()
	icon_state = "guillotine[HAS_TRAIT(src, TRAIT_WIELDED)]"

/obj/item/twohanded/fireaxe/boneaxe/guillotine/sharped
	desc = "Массивный, грозно выглядящий пилотопор, созданный с использованием костяного нароста ослеплённого жнеца. Идеален для убийства и последующей разделки чудовищ. Выглядит острее обычного"

/obj/item/twohanded/fireaxe/boneaxe/guillotine/sharped/Initialize(mapload)
	. = ..()
	SEND_SIGNAL(src, COMSIG_ITEM_SHARPEN_ACT, 4, 30)

/obj/item/twohanded/fireaxe/energized
	desc = "Someone with a love for fire axes decided to turn this one into a high-powered energy weapon. Seems excessive."
	force_wielded = 30
	armour_penetration = 20
	var/charge = 30
	var/max_charge = 30


/obj/item/twohanded/fireaxe/energized/update_icon_state()
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		icon_state = "fireaxe2"
	else
		icon_state = "fireaxe0"


/obj/item/twohanded/fireaxe/energized/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/twohanded/fireaxe/energized/ComponentInitialize()
	. = ..()
	AddComponent( \
		/datum/component/cleave_attack, \
		arc_size = 180, \
		swing_speed_mod = 2, \
		afterswing_slowdown = 0.25, \
		slowdown_duration = 1 SECONDS, \
		requires_wielded = TRUE, \
		swing_sound = "chop_swing_heavy" \
	)

/obj/item/twohanded/fireaxe/energized/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/item/twohanded/fireaxe/energized/process()
	charge = min(charge + 1, max_charge)


/obj/item/twohanded/fireaxe/energized/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.) || !HAS_TRAIT(src, TRAIT_WIELDED) || charge != max_charge)
		return .

	charge = 0
	playsound(loc, 'sound/magic/lightningbolt.ogg', 5, TRUE)
	user.visible_message(
		span_danger("[capitalize(user.declent_ru(NOMINATIVE))] со всей силы вгоня[pluralize_ru(user.gender,"ет","ют")] заряженный топор в [target.declent_ru(ACCUSATIVE)]!"),
		span_warning("Вы со всей мощи вгоняете заряженный топор в [target.declent_ru(ACCUSATIVE)]!")
	)
	do_sparks(1, 1, src)
	target.Weaken(6 SECONDS)
	var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))
	INVOKE_ASYNC(target, TYPE_PROC_REF(/atom/movable, throw_at), throw_target, 5, 1)


/*
 * Double-Bladed Energy Swords - Cheridan
 */
/obj/item/twohanded/dualsaber
	var/hacked = FALSE
	var/blade_color
	icon_state = "dualsaber0"
	name = "double-bladed energy sword"
	desc = "Handle with care."
	force = 3
	throwforce = 5
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	var/w_class_on = WEIGHT_CLASS_BULKY
	item_flags = NOSHARPENING
	force_unwielded = 3
	force_wielded = 34
	wieldsound = 'sound/weapons/saberon.ogg'
	unwieldsound = 'sound/weapons/saberoff.ogg'
	armour_penetration = 35
	origin_tech = "magnets=4;syndicate=5"
	attack_verb = list("атаковал", "полоснул", "уколол", "поранил", "порезал")
	block_chance = 75
	sharp_when_wielded = TRUE // only sharp when wielded
	max_integrity = 200
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 70)
	resistance_flags = FIRE_PROOF
	light_power = 2
	light_range = 2
	light_on = FALSE
	light_system = MOVABLE_LIGHT
	needs_permit = TRUE
	var/colormap = list(red=LIGHT_COLOR_RED, blue=LIGHT_COLOR_LIGHTBLUE, green=LIGHT_COLOR_GREEN, purple=LIGHT_COLOR_PURPLE, yellow=LIGHT_COLOR_RED, pink =LIGHT_COLOR_PURPLE, orange =LIGHT_COLOR_RED, darkblue=LIGHT_COLOR_LIGHTBLUE, rainbow=LIGHT_COLOR_WHITE)


/obj/item/twohanded/dualsaber/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_TWOHANDED_WIELD, PROC_REF(on_wield))	//We need to listen for item wield
	if(!blade_color)
		blade_color = pick("red", "blue", "green", "purple", "yellow", "pink", "orange", "darkblue")

/obj/item/twohanded/dualsaber/ComponentInitialize()
	. = ..()
	AddComponent( \
		/datum/component/cleave_attack, \
		arc_size = 360, \
		swing_speed_mod = 2, \
		afterswing_slowdown = 0, \
		requires_wielded = TRUE, \
		swing_sound = "double_energy_swing" \
	)

/obj/item/twohanded/dualsaber/proc/on_wield(obj/item/source, mob/living/carbon/user)
	if(HAS_TRAIT(user, TRAIT_HULK))
		to_chat(user, span_warning("Вам не хватает ловкости для этого!"))
		return COMPONENT_TWOHANDED_BLOCK_WIELD


//Specific wield () hulk checks due to reflection chance for balance
/obj/item/twohanded/dualsaber/wield(obj/item/source, mob/living/carbon/user)
	hitsound = 'sound/weapons/blade1.ogg'
	w_class = w_class_on


/obj/item/twohanded/dualsaber/unwield(obj/item/source, mob/living/carbon/user)
	hitsound = "swing_hit"
	w_class = initial(w_class)


/obj/item/twohanded/dualsaber/IsReflect()
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		return TRUE


/obj/item/twohanded/dualsaber/update_icon_state()
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		icon_state = "dualsaber[blade_color]1"
		set_light_on(TRUE)
		set_light_color(colormap[blade_color])
	else
		icon_state = "dualsaber0"
		set_light_on(FALSE)


/obj/item/twohanded/dualsaber/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.) || !HAS_TRAIT(src, TRAIT_WIELDED))
		return .

	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(40))
		to_chat(user, span_warning("Вы крутитесь на месте, теряете равновесие и напарываетесь на [declent_ru(ACCUSATIVE)]!"))
		user.take_organ_damage(20, 25)
		return .

	if(prob(50))
		INVOKE_ASYNC(src, GLOBAL_PROC_REF(jedi_spin), user)


/proc/jedi_spin(mob/living/user)
	for(var/i in list(NORTH, SOUTH, EAST, WEST, EAST, SOUTH, NORTH, SOUTH, EAST, WEST, EAST, SOUTH))
		user.setDir(i)
		if(i == WEST)
			user.SpinAnimation(7, 1)
		sleep(1)


/obj/item/twohanded/dualsaber/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "атакует", final_block_chance = 0, damage = 0, attack_type = ITEM_ATTACK)
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		return ..()
	return FALSE


/obj/item/twohanded/dualsaber/green
	blade_color = "green"

/obj/item/twohanded/dualsaber/red
	blade_color = "red"

/obj/item/twohanded/dualsaber/purple
	blade_color = "purple"

/obj/item/twohanded/dualsaber/blue
	blade_color = "blue"

/obj/item/twohanded/dualsaber/orange
	blade_color = "orange"

/obj/item/twohanded/dualsaber/darkblue
	blade_color = "darkblue"

/obj/item/twohanded/dualsaber/pink
	blade_color = "pink"

/obj/item/twohanded/dualsaber/yellow
	blade_color = "yellow"


/obj/item/twohanded/dualsaber/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!hacked)
		hacked = TRUE
		to_chat(user, span_warning("2XRNBW_ENGAGE"))
		blade_color = "rainbow"
		update_icon()
	else
		to_chat(user, span_warning("Похоже на тройную радугу... хотя нет, показалось."))


//spears
/obj/item/twohanded/spear
	icon_state = "spearglass0"
	name = "spear"
	desc = "Оружие древней конструкции, хоть и изготовленное небрежно, но всё ещё остаётся смертоносным."
	ru_names = list(
		NOMINATIVE = "копьё",
		GENITIVE = "копья",
		DATIVE = "копью",
		ACCUSATIVE = "копьё",
		INSTRUMENTAL = "копьём",
		PREPOSITIONAL = "копье"
	)
	force = 10
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	force_unwielded = 10
	force_wielded = 18
	throwforce = 20
	throw_speed = 4
	armour_penetration = 10
	materials = list(MAT_METAL = 1150, MAT_GLASS = 2075)
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("атаковал", "ткнул", "уколол", "поранил", "пронзил")
	sharp = TRUE
	embed_chance = 50
	embedded_ignore_throwspeed_threshold = TRUE
	no_spin_thrown = TRUE
	var/obj/item/grenade/explosive = null
	max_integrity = 200
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 30)
	needs_permit = TRUE
	var/icon_prefix = "spearglass"


/obj/item/twohanded/spear/update_icon_state()
	icon_state = "[icon_prefix][HAS_TRAIT(src, TRAIT_WIELDED)]"


/obj/item/twohanded/spear/CheckParts(list/parts_list)
	var/obj/item/shard/tip = locate() in parts_list
	if(istype(tip, /obj/item/shard/plasma))
		force_wielded = 19
		force_unwielded = 11
		throwforce = 21
		icon_prefix = "spearplasma"
	update_icon()
	qdel(tip)
	..()


/obj/item/twohanded/spear/afterattack(atom/movable/AM, mob/user, proximity, params)
	if(!proximity)
		return
	if(isturf(AM)) //So you can actually melee with it
		return
	if(explosive && HAS_TRAIT(src, TRAIT_WIELDED))
		explosive.forceMove(AM)
		explosive.prime()
		qdel(src)


/obj/item/twohanded/spear/throw_impact(atom/target, datum/thrownthing/throwingdatum)
	. = ..()
	if(explosive)
		explosive.prime()
		qdel(src)


/obj/item/twohanded/spear/bonespear	//Blatant imitation of spear, but made out of bone. Not valid for explosive modification.
	icon_state = "bone_spear0"
	name = "bone spear"
	desc = "Небрежно изготовленное, но смертоносное оружие. Венец современных технологий."
	ru_names = list(
		NOMINATIVE = "костяное копьё",
		GENITIVE = "костяного копья",
		DATIVE = "костяному копью",
		ACCUSATIVE = "костяное копьё",
		INSTRUMENTAL = "костяным копьём",
		PREPOSITIONAL = "костяном копье"
	)
	force = 11
	force_unwielded = 11
	force_wielded = 20					//I have no idea how to balance
	throwforce = 22
	armour_penetration = 15				//Enhanced armor piercing
	icon_prefix = "bone_spear"

/obj/item/twohanded/spear/bonespear/chitinspear //like a mix of a bone spear and bone axe, but more like a bone spear. And better.
	icon_state = "chitin_spear0"
	name = "chitin spear"
	desc = "Тщательно изготовленное копьё с острым краем, похожее на нагинату, отлично подходит как для рубящих ударов, так и для метания."
	ru_names = list(
		NOMINATIVE = "хитиновое копьё",
		GENITIVE = "хитинового копья",
		DATIVE = "хитиновому копью",
		ACCUSATIVE = "хитиновое копьё",
		INSTRUMENTAL = "хитиновым копьём",
		PREPOSITIONAL = "хитиновом копье"
	)
	force = 14
	force_unwielded = 14
	force_wielded = 24 // I have no idea about balance too
	throwforce = 26
	icon_prefix = "chitin_spear"

/obj/item/twohanded/spear/bonespear/her_biting_embrace
	name = "her biting embrace"
	desc = "Качественно созданное копьё, украшенное церемониальными узорами и использующее хвост донного угря в качестве наконечника. Настоящее произведение первобытного оружейного искусства."
	ru_names = list(
		NOMINATIVE = "копьё \"Её Обжигающие Объятия\"",
		GENITIVE = "копья \"Её Обжигающие Объятия\"",
		DATIVE = "копью \"Её Обжигающие Объятия\"",
		ACCUSATIVE = "копьё \"Её Обжигающие Объятия\"",
		INSTRUMENTAL = "копьём \"Её Обжигающие Объятия\"",
		PREPOSITIONAL = "копьё \"Её Обжигающие Объятия\""
	) //holy fuck
	icon_state = "her_biting_embrace0"
	icon_prefix = "her_biting_embrace"
	lefthand_file = 'icons/mob/inhands/lavaland/lava_items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/lava_items_righthand.dmi'
	force = 16
	force_unwielded = 16
	force_wielded = 28 // I have no idea about balance too
	throwforce = 45

/obj/item/twohanded/spear/bonespear/her_biting_embrace/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim)
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.) || !HAS_TRAIT(src, TRAIT_WIELDED))
		return .
	var/datum/status_effect/saw_bleed/bloodletting/A = target.has_status_effect(STATUS_EFFECT_BLOODLETTING)
	if(!A)
		target.apply_status_effect(STATUS_EFFECT_BLOODLETTING)
	else
		A.add_bleed(6)

/obj/item/twohanded/spear/plasma
	name = "plasma spear"
	icon_state = "spearplasma0"
	force = 11
	force_wielded = 19
	force_unwielded = 11
	throwforce = 21
	icon_prefix = "spearplasma"


//GREY TIDE
/obj/item/twohanded/spear/grey_tide
	icon_state = "spearglass0"
	name = "Grey Tide"
	desc = "Recovered from the aftermath of a revolt aboard Defense Outpost Theta Aegis, in which a seemingly endless tide of Assistants caused heavy casualities among Nanotrasen military forces."
	force_unwielded = 15
	force_wielded = 25
	throwforce = 20
	throw_speed = 4

/obj/item/twohanded/spear/grey_tide/afterattack(atom/movable/AM, mob/living/user, proximity, params)
	..()
	if(!proximity)
		return
	user.faction |= "greytide(\ref[user])"
	if(isliving(AM))
		var/mob/living/L = AM
		if(istype (L, /mob/living/simple_animal/hostile/illusion))
			return
		if(!L.stat && prob(50))
			var/mob/living/simple_animal/hostile/illusion/M = new(user.loc)
			M.faction = user.faction.Copy()
			M.attack_sound = hitsound
			M.Copy_Parent(user, 100, user.health/2.5, 12, 30)
			M.GiveTarget(L)


/obj/item/twohanded/spear/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/organ/external/head))	//Putting heads on spears
		add_fingerprint(user)
		if(loc == user && !user.can_unEquip(src))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		user.visible_message(
			span_warning("[capitalize(user.declent_ru(NOMINATIVE))] насажива[pluralize_ru(user.gender,"ет","ют")] [I.declent_ru(ACCUSATIVE)] на копьё перед собой!"),
			span_notice("Вы насаживаете [I.declent_ru(ACCUSATIVE)] на копьё и устанавливаете его вертикально.")
		)
		var/obj/structure/headspear/trophy = new(get_turf(src))
		trophy.add_fingerprint(user)
		I.transform = matrix()
		var/image/head_olay = image(I.icon, I.icon_state)
		head_olay.copy_overlays(I)
		trophy.add_overlay(head_olay)
		I.forceMove(trophy)
		if(loc == user)
			user.temporarily_remove_item_from_inventory(src)
		forceMove(trophy)
		trophy.mounted_head = I
		trophy.contained_spear = src
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/structure/headspear
	name = "head on a spear"
	desc = "Какое варварство."
	ru_names = list(
		NOMINATIVE = "голова на копье",
		GENITIVE = "головы на копье",
		DATIVE = "голове на копье",
		ACCUSATIVE = "голову на копье",
		INSTRUMENTAL = "головой на копье",
		PREPOSITIONAL = "голове на копье"
	)
	icon_state = "headspear"
	density = FALSE
	anchored = TRUE
	var/obj/item/organ/external/head/mounted_head = null
	var/obj/item/twohanded/spear/contained_spear = null

/obj/structure/headspear/Destroy()
	if(!obj_integrity)
		mounted_head.forceMove(loc)
		mounted_head = null
	else
		QDEL_NULL(mounted_head)
	QDEL_NULL(contained_spear)
	return ..()

/obj/structure/headspear/attack_hand(mob/living/user)
	user.visible_message(
		span_warning("[capitalize(user.declent_ru(NOMINATIVE))] сбива[pluralize_ru(user.gender,"ет","ют")] [declent_ru(ACCUSATIVE)] ногой!"),
		span_danger("Вы с пинаете [declent_ru(ACCUSATIVE)], опрокидывая его!")
	)
	playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
	var/turf/T = get_turf(src)
	if(contained_spear)
		contained_spear.forceMove(T)
		contained_spear = null
	if(mounted_head)
		mounted_head.forceMove(T)
		mounted_head = null
	qdel(src)


// DIY CHAINSAW
/obj/item/twohanded/chainsaw_handmade
	name = "chainsaw"
	desc = "A versatile power tool. Useful for limbing trees and delimbing humans."
	icon_state = "chainsaw_handmade0"
	flags = CONDUCT
	w_class = WEIGHT_CLASS_BULKY
	force = 13
	force_unwielded = 13
	force_wielded = 24
	throwforce = 13
	throw_speed = 2
	throw_range = 4
	materials = list(MAT_METAL = 13000)
	origin_tech = "materials=3;engineering=4;combat=2"
	attack_verb = list("пропилил", "порезал", "покромсал", "рубанул")
	hitsound = "swing_hit"
	sharp = TRUE
	embed_chance = 10
	embedded_ignore_throwspeed_threshold = TRUE
	actions_types = list(/datum/action/item_action/startchainsaw)
	wielded = FALSE
	var/datum/looping_sound/chainsaw/soundloop


/obj/item/twohanded/chainsaw_handmade/Initialize(mapload)
	. = ..()
	soundloop = new(list(src))


/obj/item/twohanded/chainsaw_handmade/ComponentInitialize()
	. = ..()
	AddComponent( \
		/datum/component/cleave_attack, \
		swing_speed_mod = 2, \
		afterswing_slowdown = 0.3, \
		slowdown_duration = 1 SECONDS, \
		requires_wielded = TRUE, \
		no_multi_hit = TRUE, \
		swing_sound = "chainsaw_swing" \
	)


/obj/item/twohanded/chainsaw_handmade/Destroy(force)
	QDEL_NULL(soundloop)
	return ..()


/obj/item/twohanded/chainsaw_handmade/wield(obj/item/source, mob/living/carbon/user)
	soundloop.start()
	hitsound = 'sound/weapons/chainsaw.ogg'
	to_chat(user, "Дёргая стартовый шнур [declent_ru(GENITIVE)], вы слышите нарастающее гудение.")


/obj/item/twohanded/chainsaw_handmade/unwield(obj/item/source, mob/living/carbon/user)
	soundloop.stop()
	hitsound = "swing_hit"
	to_chat(user, "Вы дёргаете стартовый шнур [declent_ru(GENITIVE)], и цепь останавливается.")


/obj/item/twohanded/chainsaw/update_icon_state()
	icon_state = "chainsaw_handmade[HAS_TRAIT(src, TRAIT_WIELDED)]"


/obj/item/twohanded/chainsaw_handmade/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.) || !HAS_TRAIT(src, TRAIT_WIELDED))
		return .


/obj/item/twohanded/chainsaw_handmade/doomslayer
	name = "OOOH BABY"
	desc = span_warning("VRRRRRRR!!!")
	armour_penetration = 100
	force_wielded = 30


/obj/item/twohanded/chainsaw_handmade/doomslayer/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "атакует", final_block_chance = 0, damage = 0, attack_type = ITEM_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		owner.visible_message(span_danger("Дальние атаки только сильнее злят [owner.declent_ru(ACCUSATIVE)]!"), projectile_message = TRUE)
		playsound(src, pick('sound/weapons/bulletflyby.ogg','sound/weapons/bulletflyby2.ogg','sound/weapons/bulletflyby3.ogg'), 75, 1)
		return TRUE
	return FALSE


///CHAINSAW///
/obj/item/twohanded/chainsaw
	icon_state = "chainsaw0"
	name = "Chainsaw"
	desc = "Perfect for felling trees or fellow spacemen."
	force = 15
	throwforce = 15
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_BULKY // can't fit in backpacks
	force_unwielded = 15 //still pretty robust
	force_wielded = 40  //you'll gouge their eye out! Or a limb...maybe even their entire body!
	armour_penetration = 35
	origin_tech = "materials=6;syndicate=4"
	attack_verb = list("пропилил", "порезал", "покромсал", "рубанул")
	sharp = TRUE
	embed_chance = 10
	embedded_ignore_throwspeed_threshold = TRUE
	wielded = FALSE
	var/datum/looping_sound/chainsaw/soundloop


/obj/item/twohanded/chainsaw/Initialize(mapload)
	. = ..()
	soundloop = new(list(src))


/obj/item/twohanded/chainsaw/ComponentInitialize()
	. = ..()
	AddComponent( \
		/datum/component/cleave_attack, \
		arc_size = 180, \
		swing_speed_mod = 2.5, \
		afterswing_slowdown = 0.3, \
		slowdown_duration = 1 SECONDS, \
		requires_wielded = TRUE, \
		swing_sound = "chainsaw_swing" \
	)


/obj/item/twohanded/chainsaw/Destroy(force)
	QDEL_NULL(soundloop)
	return ..()


/obj/item/twohanded/chainsaw/wield(obj/item/source, mob/living/carbon/user)
	soundloop.start()
	hitsound = 'sound/weapons/chainsaw.ogg'
	to_chat(user, "Дёргая стартовый шнур [declent_ru(GENITIVE)], вы слышите нарастающее гудение.")
	ADD_TRAIT(src, TRAIT_NODROP, CHAINSAW_TRAIT)


/obj/item/twohanded/chainsaw/unwield(obj/item/source, mob/living/carbon/user)
	soundloop.stop()
	hitsound = "swing_hit"
	to_chat(user, "Вы дёргаете стартовый шнур [declent_ru(GENITIVE)], и цепь останавливается.")
	REMOVE_TRAIT(src, TRAIT_NODROP, CHAINSAW_TRAIT)


/obj/item/twohanded/chainsaw/update_icon_state()
	icon_state = "chainsaw[HAS_TRAIT(src, TRAIT_WIELDED)]"


/obj/item/twohanded/chainsaw/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.) || !HAS_TRAIT(src, TRAIT_WIELDED))
		return .

	if(!isrobot(target))
		target.Weaken(2 SECONDS)


// SINGULOHAMMER
/obj/item/twohanded/singularityhammer
	name = "singularity hammer"
	desc = "The pinnacle of close combat technology, the hammer harnesses the power of a miniaturized singularity to deal crushing blows."
	icon_state = "mjollnir0"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BACK
	force = 5
	force_unwielded = 5
	force_wielded = 20
	throwforce = 15
	throw_range = 1
	w_class = WEIGHT_CLASS_HUGE
	armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 0, BOMB = 50, BIO = 0, RAD = 0, FIRE = 100, ACID = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/charged = 5
	origin_tech = "combat=4;bluespace=4;plasmatech=7"


/obj/item/twohanded/singularityhammer/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/twohanded/singularityhammer/ComponentInitialize()
	. = ..()
	// hammer, but multi hit allowed for it is a MAGIC weapon
	AddComponent( \
		/datum/component/cleave_attack, \
		arc_size = 360, \
		swing_speed_mod = 2.5, \
		afterswing_slowdown = 0.3, \
		slowdown_duration = 1 SECONDS, \
		requires_wielded = TRUE, \
		swing_sound = "blunt_swing_heavy" \
	)

/obj/item/twohanded/singularityhammer/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/item/twohanded/singularityhammer/process()
	if(charged < 5)
		charged++

/obj/item/twohanded/singularityhammer/update_icon_state()  //Currently only here to fuck with the on-mob icons.
	icon_state = "mjollnir[HAS_TRAIT(src, TRAIT_WIELDED)]"


/obj/item/twohanded/singularityhammer/afterattack(atom/A, mob/user, proximity, params)
	. = ..()
	if(!proximity || charged < 5 || !HAS_TRAIT(src, TRAIT_WIELDED))
		return

	charged = 0
	var/turf/target = get_turf(A)
	playsound(target, 'sound/weapons/marauder.ogg', 50, TRUE)

	if(isliving(A))
		var/mob/living/victim = A
		victim.take_organ_damage(20)

	for(var/atom/pulled_thing as anything in (orange(5, target) - user))
		pulled_thing.singularity_hammer_act(target)


/atom/proc/singularity_hammer_act(turf/pull)
	return


/atom/movable/singularity_hammer_act(turf/pull)
	if(anchored)
		return

	unbuckle_all_mobs()

	for(var/a in 1 to 3)
		if(!step_towards(src, pull))
			return


/mob/dead/observer/singularity_hammer_act(turf/pull)
	return


/mob/living/singularity_hammer_act(turf/pull)
	if(HAS_TRAIT(src, TRAIT_NEGATES_GRAVITY))
		return

	buckled?.unbuckle_mob(src)
	Weaken(2 SECONDS)
	..()


/obj/item/twohanded/mjollnir
	name = "Mjolnir"
	desc = "A weapon worthy of a god, able to strike with the force of a lightning bolt. It crackles with barely contained energy."
	icon_state = "mjollnir0"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BACK
	force = 5
	force_unwielded = 5
	force_wielded = 25
	throwforce = 30
	throw_range = 7
	w_class = WEIGHT_CLASS_HUGE
	//var/charged = 5
	origin_tech = "combat=4;powerstorage=7"

/obj/item/twohanded/mjollnir/ComponentInitialize()
	. = ..()
	// no multi hits since this is pretty much strong weapon already
	AddComponent( \
		/datum/component/cleave_attack, \
		arc_size = 180, \
		swing_speed_mod = 2.5, \
		afterswing_slowdown = 0.3, \
		slowdown_duration = 1 SECONDS, \
		requires_wielded = TRUE, \
		no_multi_hit = TRUE, \
		swing_sound = "blunt_swing_heavy" \
	)

/obj/item/twohanded/mjollnir/proc/shock(mob/living/target)
	target.Stun(4 SECONDS)
	do_sparks(5, 1, target.loc)
	target.visible_message(
		span_danger("[capitalize(target.declent_ru(NOMINATIVE))] поражён[genderize_ru(target.gender,"", "а", "о", "ы")] разрядом [declent_ru(GENITIVE)]!"),
		span_userdanger("Мощный разряд пронзает ваше тело, отбрасывая вас!"),
		span_italics("Раздаётся оглушительный электрический треск!")
	)
	var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))
	INVOKE_ASYNC(target, TYPE_PROC_REF(/atom/movable, throw_at), throw_target, 200, 4)


/obj/item/twohanded/mjollnir/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.) || !HAS_TRAIT(src, TRAIT_WIELDED))
		return .
	shock(target)


/obj/item/twohanded/mjollnir/throw_impact(atom/target, datum/thrownthing/throwingdatum)
	. = ..()
	if(isliving(target))
		shock(target)


/obj/item/twohanded/mjollnir/update_icon_state()  //Currently only here to fuck with the on-mob icons.
	icon_state = "mjollnir[HAS_TRAIT(src, TRAIT_WIELDED)]"


/obj/item/twohanded/knighthammer
	name = "singuloth knight's hammer"
	desc = "A hammer made of sturdy metal with a golden skull adorned with wings on either side of the head. <br>This weapon causes devastating damage to those it hits due to a power field sustained by a mini-singularity inside of the hammer."
	icon_state = "knighthammer0"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BACK
	force = 5
	force_unwielded = 5
	force_wielded = 30
	throwforce = 15
	throw_range = 1
	w_class = WEIGHT_CLASS_HUGE
	var/charged = 5
	origin_tech = "combat=5;bluespace=4"

/obj/item/twohanded/knighthammer/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/twohanded/knighthammer/ComponentInitialize()
	. = ..()
	AddComponent( \
		/datum/component/cleave_attack, \
		arc_size = 180, \
		swing_speed_mod = 2.5, \
		afterswing_slowdown = 0.3, \
		slowdown_duration = 1 SECONDS, \
		requires_wielded = TRUE, \
		no_multi_hit = TRUE, \
		swing_sound = "blunt_swing_heavy" \
	)

/obj/item/twohanded/knighthammer/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/twohanded/knighthammer/process()
	if(charged < 5)
		charged++

/obj/item/twohanded/knighthammer/update_icon_state()  //Currently only here to fuck with the on-mob icons.
	icon_state = "knighthammer[HAS_TRAIT(src, TRAIT_WIELDED)]"


/obj/item/twohanded/knighthammer/afterattack(atom/A, mob/user, proximity, params)
	. = ..()
	if(!proximity)
		return
	if(charged == 5)
		charged = 0
		if(isliving(A))
			var/mob/living/Z = A
			if(Z.health >= 1)
				Z.visible_message(
					span_danger("[capitalize(Z.declent_ru(NOMINATIVE))] отброшен[genderize_ru(Z.gender,"", "а", "о", "ы")] сокрушительным ударом [declent_ru(GENITIVE)]!"),
					span_userdanger("Мощный удар разрывает ваше тело и отшвыривает вас!"),
					span_danger("Слышен глухой удар и хлюпающий звук разрыва плоти!")
				)
				var/atom/throw_target = get_edge_target_turf(Z, get_dir(src, get_step_away(Z, src)))
				Z.throw_at(throw_target, 200, 4)
				playsound(user, 'sound/weapons/marauder.ogg', 50, TRUE)
			else if(HAS_TRAIT(src, TRAIT_WIELDED) && Z.health < 1)
				Z.visible_message(
					span_danger("[capitalize(Z.declent_ru(NOMINATIVE))] разрыва[pluralize_ru(Z.gender,"ет","ют")]ся на куски силой [declent_ru(GENITIVE)]!"),
					span_userdanger("Вы чувствуете, как ваше тело разрывается на куски!"),
					span_danger("Слышен мощный удар и звук разрывающейся плоти!")
				)
				Z.gib()
				playsound(user, 'sound/weapons/marauder.ogg', 50, TRUE)
		if(HAS_TRAIT(src, TRAIT_WIELDED))
			if(iswallturf(A))
				var/turf/simulated/wall/Z = A
				Z.ex_act(2)
				charged = 3
				playsound(user, 'sound/weapons/marauder.ogg', 50, TRUE)
			else if(isstructure(A) || ismecha(A))
				var/obj/Z = A
				Z.ex_act(2)
				charged = 3
				playsound(user, 'sound/weapons/marauder.ogg', 50, TRUE)

/obj/item/twohanded/pitchfork
	icon_state = "pitchfork0"
	name = "pitchfork"
	desc = "A simple tool used for moving hay."
	force = 7
	throwforce = 15
	w_class = WEIGHT_CLASS_BULKY
	force_unwielded = 7
	force_wielded = 15
	attack_verb = list("атаковал", "пронзил", "проколол")
	hitsound = 'sound/weapons/bladeslice.ogg'
	max_integrity = 200
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 30)
	resistance_flags = FIRE_PROOF

/obj/item/twohanded/pitchfork/demonic
	name = "demonic pitchfork"
	desc = "Красные вилы. Похоже, это инструмент дьявола."
	ru_names = list(
		NOMINATIVE = "демонические вилы",
		GENITIVE = "демонических вил",
		DATIVE = "демоническим вилам",
		ACCUSATIVE = "демонические вилы",
		INSTRUMENTAL = "демоническими вилами",
		PREPOSITIONAL = "демонических вилах"
	)
	force = 19
	throwforce = 24
	force_unwielded = 19
	force_wielded = 25
	block_chance = 50
	block_type = MELEE_ATTACKS
	light_system = MOVABLE_LIGHT
	light_range = 3
	light_power = 6
	siemens_coefficient = 0
	light_color = COLOR_SOFT_RED
	gender = PLURAL

/obj/item/twohanded/pitchfork/demonic/greater
	force = 24
	throwforce = 50
	force_unwielded = 24
	force_wielded = 34

/obj/item/twohanded/pitchfork/demonic/ascended
	force = 100
	throwforce = 100
	force_unwielded = 100
	force_wielded = 500000 // Kills you DEAD.

/obj/item/twohanded/pitchfork/update_icon_state()
	icon_state = "pitchfork[HAS_TRAIT(src, TRAIT_WIELDED)]"

/obj/item/twohanded/pitchfork/suicide_act(mob/user)
	user.visible_message(span_suicide("[capitalize(user.declent_ru(NOMINATIVE))] пронза[pluralize_ru(user.gender, "ет", "ют")] свой живот [declent_ru(INSTRUMENTAL)]! Похоже, [genderize_ru(user.gender, "он", "она", "оно", "они")] пытается покончить с собой..."))
	return BRUTELOSS

/obj/item/twohanded/pitchfork/demonic/pickup(mob/user)
	. = ..()
	if(!isliving(user))
		return

	var/mob/living/living_user = user

	if(living_user.mind?.has_antag_datum(/datum/antagonist/devil) || living_user.mind.soulOwner != living_user.mind) //Burn hands unless they are a devil or have sold their soul
		return

	living_user.visible_message(span_warning("Когда [living_user.declent_ru(NOMINATIVE)] поднима[pluralize_ru(living_user.gender, "ет", "ют")] [declent_ru(ACCUSATIVE)], [genderize_ru(living_user.gender, "его", "её", "его", "их")] руки на мгновение загораются."), \
					span_warning("Когда вы поднимаете [declent_ru(ACCUSATIVE)], ваши руки воспламеняются, напоминая вам обо всех ваших прошлых грехах."))

	if(!ishuman(living_user))
		living_user.adjustFireLoss(rand(living_user.health / 4, force))
		return

	var/mob/living/carbon/human/human = living_user
	human.apply_damage(rand(living_user.health / 4, living_user.health / 2), BURN, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))

/obj/item/twohanded/pitchfork/demonic/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()

	if(!ATTACK_CHAIN_SUCCESS_CHECK(.))
		return .

	if(user.mind?.has_antag_datum(/datum/antagonist/devil) || (user.mind.soulOwner != user.mind))
		return .

	to_chat(user, span_warning("[capitalize(declent_ru(NOMINATIVE))] пылают в ваших руках!"))
	user.apply_damage(rand(user.health / 2, force), BURN, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))


// It's no fun being the lord of all hell if you can't get out of a simple room
/obj/item/twohanded/pitchfork/demonic/ascended/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity || !HAS_TRAIT(src, TRAIT_WIELDED))
		return

	if(iswallturf(target))
		var/turf/simulated/wall/wall = target
		user.visible_message(span_danger("[capitalize(user.declent_ru(NOMINATIVE))] разрушает [target.declent_ru(ACCUSATIVE)] с помощью [declent_ru(INSTRUMENTAL)]"))
		playsound(target, 'sound/magic/Disintegrate.ogg', 100, TRUE)
		wall.dismantle_wall(TRUE)
		return TRUE

	if(ismineralturf(target))
		var/turf/simulated/mineral/mineral = target
		user.visible_message(span_danger("[capitalize(user.declent_ru(NOMINATIVE))] разрушает [target.declent_ru(ACCUSATIVE)] с помощью [declent_ru(INSTRUMENTAL)]"))
		playsound(target, 'sound/magic/Disintegrate.ogg', 100, TRUE)
		mineral.gets_drilled(user)
		return TRUE

	..()

/obj/item/twohanded/bamboospear
	icon_state = "bamboo_spear0"
	name = "bamboo spear"
	desc = "A haphazardly-constructed bamboo stick with a sharpened tip, ready to poke holes into unsuspecting people."
	force = 10
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	force_unwielded = 10
	force_wielded = 18
	throwforce = 22
	throw_speed = 4
	armour_penetration = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("атаковал", "ткнул", "уколол", "пронзил")
	sharp = TRUE
	embed_chance = 50
	embedded_ignore_throwspeed_threshold = TRUE

/obj/item/twohanded/bamboospear/update_icon_state()
	icon_state = "bamboo_spear[HAS_TRAIT(src, TRAIT_WIELDED)]"

/obj/item/twohanded/sechammer
	name = "tactical sledgehammer"
	desc = "Тяжёлая кувалда, используемая силовыми структурами НаноТрейзен. Удобная эргономичная рукоятка обеспечивает надёжный хват, а боёк кувалды увеличенной массы позволяет наносить мощные и точные удары, что делает её отличным инструментом для разрушения препятствий и создания брешей в стенах. Хотя конструкция и является слишком неудобной для эффективного использования в качестве оружия, силы удара достаточно, чтобы раздробить любую кость в теле гуманоида."
	ru_names = list(
		NOMINATIVE = "тактическая кувалда",
		GENITIVE = "тактической кувалды",
		DATIVE = "тактической кувалде",
		ACCUSATIVE = "тактическую кувалду",
		INSTRUMENTAL = "тактической кувалдой",
		PREPOSITIONAL = "тактической кувалде"
	)
	gender = FEMALE
	icon_state = "sechammer0"
	throwforce = 20
	throw_range = 2
	w_class = WEIGHT_CLASS_BULKY
	attack_speed = 1.6 SECONDS
	force_unwielded = 15
	force_wielded = 35
	armour_penetration = 40
	attack_verb = list("атаковал", "ударил", "шибанул", "долбанул", "припечатал")
	max_integrity = 200
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 50)
	resistance_flags = FIRE_PROOF
	item_flags = SLOWS_WHILE_IN_HAND

	var/wall_damage = 35
	var/extra_girder_damage = 65
	var/extra_door_damage = 25

	var/stamina_drain = 8
	var/max_stamina_damage = 40

/obj/item/twohanded/sechammer/ComponentInitialize()
	. = ..()
	AddComponent( \
		/datum/component/cleave_attack, \
		arc_size = 180, \
		swing_speed_mod = 1.75, \
		afterswing_slowdown = 0.3, \
		slowdown_duration = 1 SECONDS, \
		requires_wielded = TRUE, \
		no_multi_hit = TRUE, \
		swing_sound = "blunt_swing_heavy" \
	)

/obj/item/twohanded/sechammer/update_icon_state()
	icon_state = "sechammer[HAS_TRAIT(src, TRAIT_WIELDED)]"

/obj/item/twohanded/sechammer/wield(obj/item/source, mob/living/carbon/user)
	slowdown = 0.5


/obj/item/twohanded/sechammer/unwield(obj/item/source, mob/living/carbon/user)
	slowdown = 0

/obj/item/twohanded/sechammer/pre_attackby(atom/target, mob/living/user, params)
	. = ..()
	if(user.getStaminaLoss() >= max_stamina_damage)
		balloon_alert(user, "вы слишком устали!")
		return .|ATTACK_CHAIN_BLOCKED

/obj/item/twohanded/sechammer/afterattack(atom/A, mob/living/user, proximity, params)
	. = ..()
	if(!proximity || !HAS_TRAIT(src, TRAIT_WIELDED))
		return
	if(iswallturf(A))
		var/turf/simulated/wall/W = A
		user.changeNext_move(attack_speed)
		user.do_attack_animation(src)
		playsound(src, 'sound/weapons/smash.ogg', 50, TRUE)
		W.take_damage(wall_damage)
	if(user.getStaminaLoss() < max_stamina_damage)
		if(istype(A, /obj/structure/girder))
			var/obj/structure/G = A
			G.take_damage(extra_girder_damage)
		else if(istype(A, /obj/machinery/door))
			var/obj/machinery/D = A
			D.take_damage(extra_door_damage)
	user.adjustStaminaLoss(stamina_drain)
