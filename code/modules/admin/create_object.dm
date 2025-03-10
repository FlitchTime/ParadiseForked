GLOBAL_VAR(create_object_html)
GLOBAL_LIST_INIT(create_object_forms, list(/obj, /obj/structure, /obj/machinery, /obj/effect, /obj/item, /obj/mecha, /obj/item/clothing, /obj/item/stack, /obj/item/reagent_containers, /obj/item/gun))

/datum/admins/proc/create_object(var/mob/user)
	if(!GLOB.create_object_html)
		var/objectjs = null
		objectjs = jointext(typesof(/obj), ";")
		GLOB.create_object_html = file2text('html/create_object.html')
		GLOB.create_object_html = replacetext(GLOB.create_object_html, "null /* object types */", "\"[objectjs]\"")

	var/datum/browser/popup = new(user, "create_obj", "<div align='center'>Create Object</div>", 550, 600)
	var/unique_content = GLOB.create_object_html
	unique_content = replacetext(unique_content, "/* ref src */", UID())
	popup.set_content(unique_content)
	popup.set_window_options("can_close=1;can_minimize=0;can_maximize=1;can_resize=1")
	popup.add_stylesheet("dark_inputs", "html/dark_inputs.css")
	popup.open()
	onclose(user, "create_obj")

/datum/admins/proc/quick_create_object(var/mob/user)
	var/path = tgui_input_list(usr, "Select the path of the object you wish to create.", "Path", GLOB.create_object_forms, /obj)
	var/html_form = GLOB.create_object_forms[path]

	if(!html_form)
		var/objectjs = jointext(typesof(path), ";")
		html_form = file2text('html/create_object.html')
		html_form = replacetext(html_form, "null /* object types */", "\"[objectjs]\"")
		html_form = replacetext(html_form, "Create Object", "Create Object [path]")
		GLOB.create_object_forms[path] = html_form

	var/datum/browser/popup = new(user, "qco[path]", "<div align='center'>Quick Create [path]</div>", 550, 600)
	var/unique_content = html_form
	unique_content = replacetext(unique_content, "/* ref src */", UID())
	popup.set_content(unique_content)
	popup.set_window_options("can_close=1;can_minimize=0;can_maximize=1;can_resize=1")
	popup.add_stylesheet("dark_inputs", "html/dark_inputs.css")
	popup.open()
	onclose(user, "qco[path]")
