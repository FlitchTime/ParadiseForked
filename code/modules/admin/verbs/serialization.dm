/client/proc/admin_serialize()
	set name = "Serialize Marked Datum"
	set desc = "Turns your marked object into a JSON string you can later use to re-create the object"
	set category = "Admin.Debug"

	if(!check_rights(R_ADMIN|R_DEBUG))
		return

	if(!istype(holder.marked_datum, /atom/movable))
		to_chat(src, "The marked datum is not an atom/movable!")
		return

	var/atom/movable/AM = holder.marked_datum
	to_chat(src, json_encode(AM.serialize()))

/client/proc/admin_deserialize()
	set name = "Deserialize JSON datum"
	set desc = "Creates an object from a JSON string"
	set category = "Admin.Debug"

	if(!check_rights(R_SPAWN)) // this involves spawning things
		return

	var/json_text = tgui_input_text(usr, "Enter the JSON code:", "Text", multiline = TRUE, encode = FALSE)
	if(json_text)
		json_to_object(json_text, get_turf(usr))
