/datum/element/force_recall
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY
	var/mob/living/recall_mob

/datum/element/force_recall/Attach(obj/item/esword)
	. = ..()
	if(!isitem(esword))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(esword, COMSIG_ITEM_RECALL, PROC_REF(on_recall))
	RegisterSignal(esword, COMSIG_MOVABLE_IMPACT, PROC_REF(on_impact))

/datum/element/force_recall/Detach(obj/item/esword)
	UnregisterSignal(esword, list(COMSIG_ITEM_RECALL, COMSIG_MOVABLE_IMPACT))
	recall_mob = null
	. = ..()

/datum/element/force_recall/proc/on_recall(obj/item/esword, mob/living/user)
	SIGNAL_HANDLER
	if(esword.loc == user || esword.loc == user.loc)
		user.put_in_active_hand(esword)
		return

	recall_mob = user
	var/distance = get_dist(user, esword)
	esword.throw_at(user, distance + 1, esword.throw_speed, user)

/datum/element/force_recall/proc/on_impact(obj/item/esword, atom/hit_atom)
	SIGNAL_HANDLER
	if(!recall_mob || !hit_atom)
		return

	var/mob/living/carbon/human/human = recall_mob
	human.put_in_active_hand(esword)
	recall_mob = null
	// Stops /obj/item/throw_impact from calling hitby() and applying throw damage to the summoner.
	return COMPONENT_MOVABLE_IMPACT_NEVERMIND
