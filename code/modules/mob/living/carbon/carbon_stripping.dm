/datum/strippable_item/mob_item_slot/head
	key = STRIPPABLE_ITEM_HEAD
	item_slot = ITEM_SLOT_HEAD

/datum/strippable_item/mob_item_slot/back
	key = STRIPPABLE_ITEM_BACK
	item_slot = ITEM_SLOT_BACK

/datum/strippable_item/mob_item_slot/back/get_alternate_actions(atom/source, mob/user)
	return get_strippable_alternate_action_internals(get_item(source), source)

/datum/strippable_item/mob_item_slot/back/alternate_action(atom/source, mob/user, action_key)
	if(!..())
		return
	strippable_alternate_action_internals(get_item(source), source, user)

/datum/strippable_item/mob_item_slot/mask
	key = STRIPPABLE_ITEM_MASK
	item_slot = ITEM_SLOT_MASK

/datum/strippable_item/mob_item_slot/mask/get_body_action(atom/source, mob/user)
	if(!ishuman(source))
		return
	var/mob/living/carbon/human/H = source
	var/obj/item/organ/internal/headpocket/pocket = H.get_int_organ(/obj/item/organ/internal/headpocket)
	if(istype(pocket) && pocket.pocket.master_item)
		return "dislodge_headpocket"

/datum/strippable_item/mob_item_slot/mask/get_alternate_actions(atom/source, mob/user)
	var/obj/item/clothing/mask/muzzle/muzzle = get_item(source)
	if(!istype(muzzle))
		return
	if(muzzle.security_lock)
		return "[muzzle.locked ? "dis" : "en"]able_lock"

/datum/strippable_item/mob_item_slot/mask/alternate_action(atom/source, mob/user, action_key)
	if(!..())
		return
	// Headpocket dislodging
	if(action_key == "dislodge_headpocket")
		var/mob/living/carbon/human/H = source
		var/obj/item/organ/internal/headpocket/pocket = H.get_int_organ(/obj/item/organ/internal/headpocket)
		if(!pocket.pocket.master_item)
			return
		user.visible_message(span_danger("[user] пыта[pluralize_ru(user.gender, "ет", "ют")]ся достать что-то из головного кармана [source]!"),
							span_danger("Вы пытаетесь достать предмет из головного кармана [source]!"))
		if(do_after(user, POCKET_STRIP_DELAY, source, max_interact_count = 1))
			user.visible_message(span_danger("[user] доста[pluralize_ru(user.gender, "ёт", "ют")] что-то из головного кармана [source]!"),
								span_danger("Вы достаёте предмет из головного кармана [source]!"))
			pocket.empty_contents()
			add_attack_logs(user, source, "Stripped of headpocket items", isLivingSSD(source) ? null : ATKLOG_ALL)
		return

	// Altering a muzzle
	if(action_key != "enable_lock" && action_key != "disable_lock")
		return
	var/obj/item/clothing/mask/muzzle/muzzle = get_item(source)
	if(!istype(muzzle))
		return
	if(!ishuman(user))
		user.balloon_alert(user, "не получится!")
		return

	muzzle.visible_message(span_danger("[user] пыта[pluralize_ru(user.gender, "ет", "ют")]ся [muzzle.locked ? "раз" : "за"]блокировать [muzzle.declent_ru(ACCUSATIVE)] [source]!"), \
					span_userdanger("[user] пыта[pluralize_ru(user.gender, "ет", "ют")]ся [muzzle.locked ? "раз" : "за"]блокировать [muzzle.declent_ru(ACCUSATIVE)] [source]!"))
	if(!do_after(user, POCKET_STRIP_DELAY, source, max_interact_count = 1))
		return

	var/success = FALSE
	if(muzzle.locked)
		success = muzzle.do_unlock(user)
	else
		success = muzzle.do_lock(user)

	if(!success)
		return
	muzzle.visible_message(span_danger("[user] [muzzle.locked ? "за" : "раз"]блокировал[genderize_ru(user.gender, "", "а", "о", "и")] [muzzle.declent_ru(ACCUSATIVE)] [source]!"), \
					span_userdanger("[user] [muzzle.locked ? "за" : "раз"]блокировал[genderize_ru(user.gender, "", "а", "о", "и")] [muzzle.declent_ru(ACCUSATIVE)] [source]!"))


/datum/strippable_item/mob_item_slot/handcuffs
	key = STRIPPABLE_ITEM_HANDCUFFS
	item_slot = ITEM_SLOT_HANDCUFFED

/datum/strippable_item/mob_item_slot/handcuffs/should_show(atom/source, mob/user)
	if(!iscarbon(source))
		return FALSE

	var/mob/living/carbon/carbon_source = source
	return !isnull(carbon_source.handcuffed)

// You shouldn't be able to equip things to handcuff slots.
/datum/strippable_item/mob_item_slot/handcuffs/try_equip(atom/source, obj/item/equipping, mob/user)
	return FALSE

/datum/strippable_item/mob_item_slot/legcuffs
	key = STRIPPABLE_ITEM_LEGCUFFS
	item_slot = ITEM_SLOT_LEGCUFFED

/datum/strippable_item/mob_item_slot/legcuffs/should_show(atom/source, mob/user)
	if(!iscarbon(source))
		return FALSE

	var/mob/living/carbon/carbon_source = source
	return !isnull(carbon_source.legcuffed)

// You shouldn't be able to equip things to legcuff slots.
/datum/strippable_item/mob_item_slot/legcuffs/try_equip(atom/source, obj/item/equipping, mob/user)
	return FALSE

/// A strippable item for a hand
/datum/strippable_item/hand

	/// Which hand?
	var/which_hand

/datum/strippable_item/hand/belt/get_alternate_actions(atom/source, mob/user)
	return get_strippable_alternate_action_internals(get_item(source), source)

/datum/strippable_item/hand/get_item(atom/source)
	if(!ismob(source))
		return null

	var/mob/mob_source = source
	return mob_source.get_item_by_slot(which_hand)

/datum/strippable_item/hand/try_equip(atom/source, obj/item/equipping, mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(!ismob(source))
		return FALSE

	var/mob/mob_source = source
	if(!mob_source.put_in_hand_check(equipping, which_hand))
		user.balloon_alert(user, "нет места!")
		return FALSE

	return TRUE

/datum/strippable_item/hand/start_equip(atom/source, obj/item/equipping, mob/user)
	. = ..()
	if(!.)
		return

	if(!ismob(source))
		return FALSE

	var/mob/mob_source = source

	if(!mob_source.put_in_hand_check(equipping, which_hand))
		return FALSE

	return TRUE

/datum/strippable_item/hand/finish_equip(atom/source, obj/item/equipping, mob/user)
	if(!iscarbon(source))
		return FALSE

	var/mob/mob_source = source
	mob_source.put_in_hand(equipping, which_hand)

/datum/strippable_item/hand/finish_unequip(atom/source, mob/user)
	var/obj/item/item = get_item(source)
	if(isnull(item))
		return FALSE

	if(!ismob(source))
		return FALSE

	finish_unequip_mob(item, source, user)

/datum/strippable_item/hand/left
	key = STRIPPABLE_ITEM_LHAND
	which_hand = ITEM_SLOT_HAND_LEFT

/datum/strippable_item/hand/right
	key = STRIPPABLE_ITEM_RHAND
	which_hand = ITEM_SLOT_HAND_RIGHT
