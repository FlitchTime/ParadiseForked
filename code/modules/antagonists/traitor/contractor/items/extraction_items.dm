/**
  * # Contractor Extraction Flare
  *
  * Used to designate where the [/obj/effect/portal/redspace/contractor] should spawn during the extraction process.
  */
/obj/effect/contractor_flare
	name = "contractor extraction flare"
	ru_names = list(
		NOMINATIVE = "сигнальная ракета контрактника",
		GENITIVE = "сигнальной ракеты контрактника",
		DATIVE = "сигнальной ракете контрактника",
		ACCUSATIVE = "сигнальную ракету контрактника",
		INSTRUMENTAL = "сигнальной ракетой контрактника",
		PREPOSITIONAL = "сигнальной ракете контрактника"
	)
	gender = MALE
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flare-contractor-on"

/obj/effect/contractor_flare/New()
	..()
	playsound(loc, 'sound/goonstation/misc/matchstick_light.ogg', 50, TRUE)
	set_light(8, l_color = "#FFD165")

/obj/effect/contractor_flare/Destroy()
	new /obj/effect/decal/cleanable/ash(loc)
	return ..()


/obj/effect/contractor_flare/attackby(obj/item/clothing/mask/cigarette/cigarette, mob/user, params)
	. = ..()
	if(ATTACK_CHAIN_CANCEL_CHECK(.) || !istype(cigarette) || cigarette.lit)
		return .
	. |= ATTACK_CHAIN_SUCCESS
	cigarette.light(span_rose("[user] привычным движением прикурива[pluralize_ru(user.gender, "ет", "ют")] заслуженную \
					[genderize_ru(user.gender, "им", "ей", "им", "ими")] [cigarette.declent_ru(ACCUSATIVE)] [declent_ru(INSTRUMENTAL)]. В воздухе запахло телекристаллами."))


/**
  * # Contractor Extraction Portal
  *
  * Used to extract contract targets and send them to the Syndicate jail for a few minutes.
  */
/obj/effect/portal/redspace/contractor
	name = "suspicious portal"
	ru_names = list(
		NOMINATIVE = "подозрительный портал",
		GENITIVE = "подозрительного портала",
		DATIVE = "подозрительному порталу",
		ACCUSATIVE = "подозрительный портал",
		INSTRUMENTAL = "подозрительным порталом",
		PREPOSITIONAL = "подозрительном портале"
	)
	icon_state = "portal-syndicate"
	/// The contract associated with this portal.
	var/datum/syndicate_contract/contract = null
	/// The mind of the contractor. Used to tell them they shouldn't be taking the portal.
	var/datum/mind/contractor_mind = null
	/// The mind of the kidnapping target. Prevents non-targets from taking the portal.
	var/datum/mind/target_mind = null


/obj/effect/portal/redspace/contractor/can_teleport(atom/movable/A, silent = FALSE)
	var/mob/living/M = A
	if(!istype(M))
		return FALSE
	if(M == usr && M.mind == contractor_mind)
		if(!silent)
			to_chat(M, span_warning("Портал здесь для того, чтобы эвакуировать цель контракта, а не вас!"))
		return FALSE
	if(M.mind != target_mind)
		if(usr?.mind == contractor_mind) // Contractor shoving a non-target into the portal
			if(!silent)
				to_chat(M, span_warning("Почему-то вы не уверены, что [M] — именно та цель, которую вам нужно эвакуировать."))
			return FALSE
		else if(usr == M) // Non-target trying to enter the portal
			if(!silent)
				to_chat(M, span_warning("Почему-то вы не уверены, что это хорошая идея."))
			return FALSE
		return FALSE
	return ..()

/obj/effect/portal/redspace/contractor/teleport(atom/movable/M)
	. = ..()
	if(.)
		contract.target_received(M, src)

/**
  * # Prisoner Belongings Closet
  *
  * Cannot be opened. Contains the belongings of all kidnapped targets.
  * Any item added inside stops processing and starts again when removed.
  */
/obj/structure/closet/secure_closet/contractor
	anchored = TRUE
	can_be_emaged = FALSE
	max_integrity = INFINITY
	/// Lazy list of atoms which should process again when taken out.
	var/list/atom/suspended_items = null
	/// Lazy, associative list of prisoners being held as part of a contract.
	/// Structure: [/mob/living] => [/datum/syndicate_contract]
	var/list/prisoners = null

/obj/structure/closet/secure_closet/contractor/Initialize(mapload)
	. = ..()
	if(!GLOB.prisoner_belongings)
		GLOB.prisoner_belongings = src

/obj/structure/closet/secure_closet/contractor/allowed(mob/M)
	return FALSE

/**
  * Tries to add an atom for temporary holding, suspending its processing.
  *
  * Arguments:
  * * A - The atom to add.
  */
/obj/structure/closet/secure_closet/contractor/proc/give_item(atom/A)
	if(ismob(A)) // No mobs allowed
		return FALSE
	var/obj/item/I = A
	if(!istype(I))
		return FALSE
	if(I.isprocessing)
		LAZYSET(suspended_items, I.UID(), list(I, (I in SSfastprocess.processing)))
		STOP_PROCESSING(SSobj, I)
	I.loc = src // No forceMove because we don't want to trigger anything here
	return TRUE

/**
  * Removes an atom from temporary holding.
  *
  * Arguments:
  * * A - The atom to remove.
  */
/obj/structure/closet/secure_closet/contractor/proc/remove_item(atom/A)
	if(!(A in contents))
		return
	var/obj/item/I = A
	if(!istype(I))
		return FALSE
	// Resume processing if it was paused
	var/list/tuple = LAZYACCESS(suspended_items, I.UID())
	if(tuple)
		if(tuple[2])
			START_PROCESSING(SSfastprocess, I)
		else
			START_PROCESSING(SSobj, I)
		suspended_items[I.UID()] = null
	I.loc = loc // No forceMove because we don't want to trigger anything here
	return I
