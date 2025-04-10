/**
  * # Contractor Uplink
  *
  * A contractor's point of contact with their Contractor Hub.
  */
/obj/item/contractor_uplink
	name = "contractor uplink"
	desc = "Устройство, выданное Синдикатом, для работы с контрактами в полевых условиях."
	ru_names = list(
		NOMINATIVE = "аплинк контрактника",
		GENITIVE = "аплинка контрактника",
		DATIVE = "аплинку контрактнику",
		ACCUSATIVE = "аплинк контрактника",
		INSTRUMENTAL = "аплинком контрактником",
		PREPOSITIONAL = "аплинке контрактнике"
	)
	gender = MALE
	icon = 'icons/obj/device.dmi'
	icon_state = "contractor_uplink"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	origin_tech = "programming=5;syndicate=4" // Hackerman encryption
	/// The Contractor Hub associated with this uplink.
	var/datum/contractor_hub/hub = null

/obj/item/contractor_uplink/Destroy()
	// Right now, one uplink = one hub so this is fine.
	if(hub)
		var/datum/antagonist/contractor/antag = hub.owner?.has_antag_datum(/datum/antagonist/contractor)
		if(antag)
			antag.contractor_uplink = null
		QDEL_NULL(hub)
	return ..()

/obj/item/contractor_uplink/attack_self(mob/user)
	hub.ui_interact(user)

/**
  * Sends a message to the mob holding this item.
  *
  * Arguments:
  * * text - The text to send.
  * * sndfile - The sound to play to the holder only.
  */
/obj/item/contractor_uplink/proc/message_holder(text, sndfile)
	var/mob/living/M = loc
	while(!istype(M) && M?.loc)
		M = M.loc
	if(!istype(M))
		return

	to_chat(M, span_notice("[bicon(src)] Входящая зашифрованная передача от ваших кураторов. Сообщение следующее:<br/>")\
			 + span_boldnotice("[text]"))
	if(sndfile)
		M.playsound_local(get_turf(M), sndfile, 30, FALSE)
