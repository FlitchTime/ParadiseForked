/// UI helper for converting the associative list to a list of lists
/datum/lootpanel/proc/get_contents()
	var/list/items = list()

	for(var/datum/search_object/index as anything in contents)
		UNTYPED_LIST_ADD(items, list(
			"icon_state" = index.icon_state,
			"icon" = index.icon,
			"name" = index.name,
			"path" = index.path,
			"uid" = index.UID(),
		))

	return items


/// Clicks an object from the contents. Validates the object and the user
/datum/lootpanel/proc/grab(mob/user, list/params)
	var/uid = params["uid"]
	if(isnull(uid))
		return FALSE

	if(!source_turf.Adjacent(user)) // Source tile is no longer valid
		reset_contents()
		return FALSE

	var/datum/search_object/index = locate(uid) in contents
	var/atom/thing = index?.item
	if(QDELETED(index) || QDELETED(thing)) // Obj is gone
		return FALSE

	if(thing != source_turf && !(locate(thing) in source_turf.contents))
		qdel(index) // Item has moved
		return TRUE

	var/modifiers = ""
	if(params["ctrl"])
		modifiers += "ctrl=1;"
	if(params["middle"])
		modifiers += "middle=1;"
	if(params["shift"])
		modifiers += "shift=1;"

	user.ClickOn(thing, modifiers)

	return TRUE
