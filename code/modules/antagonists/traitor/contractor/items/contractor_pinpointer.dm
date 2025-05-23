/obj/item/pinpointer/crew/contractor
	name = "contractor pinpointer"
	desc = "Портативное устройство слежения, которое указывает на членов экипажа, не используя датчики костюма, ценой снижения точности."
	ru_names = list(
		NOMINATIVE = "целеуказатель Контрактника",
		GENITIVE = "целеуказателя Контрактника",
		DATIVE = "целеуказателю Контрактника",
		ACCUSATIVE = "целеуказатель Контрактника",
		INSTRUMENTAL = "целеуказателем Контрактника",
		PREPOSITIONAL = "целеуказателе Контрактника"
	)
	icon_state = "pinoff_contractor"
	item_state = "pinoff_contractor"
	icon_off = "pinoff_contractor"
	icon_null = "pinonnull_contractor"
	icon_direct = "pinondirect_contractor"
	icon_close = "pinonclose_contractor"
	icon_medium = "pinonmedium_contractor"
	icon_far = "pinonfar_contractor"
	/// The minimum range for the pinpointer to function properly.
	var/min_range = 15
	/// The first person to have used the item. If this is set already, no one else can use it.
	var/mob/owner


/obj/item/pinpointer/crew/contractor/update_icon_state()
	if(mode == 0)	// MODE_OFF
		icon_state = icon_off
		return

	if(!target)
		icon_state = icon_null
		return

	if(ISINRANGE(prev_dist, -1, min_range))
		icon_state = icon_direct
	else if(ISINRANGE(prev_dist, min_range + 1, min_range + 8))
		icon_state = icon_close
	else if(ISINRANGE(prev_dist, min_range + 9, min_range + 16))
		icon_state = icon_medium
	else if(ISINRANGE(prev_dist, min_range + 16, INFINITY))
		icon_state = icon_far


/obj/item/pinpointer/crew/contractor/is_trackable(mob/living/carbon/human/pin_target)
	source_turf = get_turf(src)
	target_turf = get_turf(pin_target)
	return source_turf && target_turf && source_turf.z == target_turf.z


/obj/item/pinpointer/crew/contractor/cycle(mob/user, silent = FALSE)
	if(owner)
		if(owner != user)
			balloon_alert(user, "устройство не отвечает!")
			return
	else
		owner = user
		to_chat(user, span_notice("Теперь [declent_ru(NOMINATIVE)] признаёт вас своим единственным пользователем."))
	return ..()

