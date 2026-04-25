/datum/element/force_recall
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY
	var/mob/living/recall_target

/datum/element/force_recall/Attach(obj/item/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ITEM_RECALL, PROC_REF(on_recall))
	RegisterSignal(target, COMSIG_MOVABLE_IMPACT, PROC_REF(on_impact))

/datum/element/force_recall/Detach(obj/item/target)
	UnregisterSignal(target, list(COMSIG_ITEM_RECALL, COMSIG_MOVABLE_IMPACT))
	recall_target = null
	return ..()

/datum/element/force_recall/proc/on_recall(obj/item/source, mob/living/user)
	SIGNAL_HANDLER
	if(source.loc == user || source.loc == user.loc)
		user.put_in_active_hand(source)
		return

	recall_target = user
	var/distance = get_dist(user, source)
	source.throw_at(user, distance + 1, source.throw_speed)
	
	addtimer(CALLBACK(src, PROC_REF(clear_recall_target)), 3 SECONDS)

/datum/element/force_recall/proc/clear_recall_target()
	recall_target = null

/datum/element/force_recall/proc/on_impact(obj/item/source, atom/hit_atom)
	SIGNAL_HANDLER
	if(!recall_target || hit_atom != recall_target)
		return FALSE
	var/mob/living/carbon/human/H = recall_target
	recall_target = null
	if(!H.put_in_active_hand(source))
		source.forceMove(H.loc)
	if(source.throwing)
		var/datum/thrownthing/thrown_thing = source.throwing
		thrown_thing.thrownthing = null 
	return TRUE
