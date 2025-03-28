// Do not attemtp to remove the blank string from the server arg. It will break DB saving.
/proc/add_note(target_ckey, notetext, timestamp, adminckey, logged = 1, server = "", checkrights = 1)
	if(checkrights && !check_rights(R_ADMIN|R_MOD))
		return
	if(!SSdbcore.IsConnected())
		if(usr)
			to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
		return

	if(!target_ckey)
		var/new_ckey = ckey(tgui_input_text(usr, "Who would you like to add a note for?", "Enter a ckey", null))
		if(!new_ckey)
			return
		target_ckey = ckey(new_ckey)
	else
		target_ckey = ckey(target_ckey)

	var/datum/db_query/query_find_ckey = SSdbcore.NewQuery("SELECT ckey, exp FROM [format_table_name("player")] WHERE ckey=:ckey", list(
		"ckey" = target_ckey
	))

	if(!query_find_ckey.warn_execute())
		qdel(query_find_ckey)
		return

	var/ckey_found = FALSE
	var/exp_data
	while(query_find_ckey.NextRow())
		exp_data = query_find_ckey.item[2]
		ckey_found = TRUE

	qdel(query_find_ckey)

	if(!ckey_found)
		if(usr)
			to_chat(usr, "<span class='redtext'>[target_ckey] has not been seen before, you can only add notes to known players.</span>")
		return

	var/crew_number = 0
	if(exp_data)
		var/list/play_records = params2list(exp_data)
		crew_number = play_records[EXP_TYPE_CREW]

	if(!notetext)
		notetext = tgui_input_text(usr, "Write your note", "Add Note", multiline = TRUE, encode = FALSE)
		if(!notetext)
			return

	if(!adminckey)
		adminckey = usr.ckey
		if(!adminckey)
			return
	else if(usr && (usr.ckey == ckey(adminckey))) // Don't ckeyize special note sources
		adminckey = ckey(adminckey)

	if(!server)
		if(config && CONFIG_GET(string/servername))
			server = CONFIG_GET(string/servername)

	var/datum/db_query/query_noteadd = SSdbcore.NewQuery({"
		INSERT INTO [CONFIG_GET(string/utility_database)].[format_table_name("notes")] (ckey, timestamp, notetext, adminckey, server, crew_playtime)
		VALUES (:targetckey, NOW(), :notetext, :adminkey, :server, :crewnum)
	"}, list(
		"targetckey" = target_ckey,
		"notetext" = notetext,
		"adminkey" = adminckey,
		"server" = server,
		"crewnum" = crew_number
	))
	if(!query_noteadd.warn_execute())
		qdel(query_noteadd)
		return
	qdel(query_noteadd)
	if(logged)
		log_admin("[usr ? key_name(usr) : adminckey] has added a note to [target_ckey]: [notetext]")
		message_admins("[usr ? key_name_admin(usr) : adminckey] has added a note to [target_ckey]:<br>[notetext]")
		show_note(target_ckey)

/proc/remove_note(note_id)
	if(!check_rights(R_ADMIN|R_MOD))
		return
	var/ckey
	var/notetext
	var/adminckey
	if(!SSdbcore.IsConnected())
		if(usr)
			to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
		return
	if(!note_id)
		return
	note_id = text2num(note_id)
	var/datum/db_query/query_find_note_del = SSdbcore.NewQuery("SELECT ckey, notetext, adminckey FROM [CONFIG_GET(string/utility_database)].[format_table_name("notes")] WHERE id=:note_id", list(
		"note_id" = note_id
	))
	if(!query_find_note_del.warn_execute())
		qdel(query_find_note_del)
		return
	if(query_find_note_del.NextRow())
		ckey = query_find_note_del.item[1]
		notetext = query_find_note_del.item[2]
		adminckey = query_find_note_del.item[3]
	qdel(query_find_note_del)

	var/datum/db_query/query_del_note = SSdbcore.NewQuery("DELETE FROM [CONFIG_GET(string/utility_database)].[format_table_name("notes")] WHERE id=:note_id", list(
		"note_id" = note_id
	))
	if(!query_del_note.warn_execute())
		qdel(query_del_note)
		return
	qdel(query_del_note)

	log_admin("[usr ? key_name(usr) : "Bot"] has removed a note made by [adminckey] from [ckey]: [notetext]")
	message_admins("[usr ? key_name_admin(usr) : "Bot"] has removed a note made by [adminckey] from [ckey]:<br>[notetext]")
	show_note(ckey)

/proc/edit_note(note_id)
	if(!check_rights(R_ADMIN|R_MOD))
		return
	if(!SSdbcore.IsConnected())
		if(usr)
			to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
		return
	if(!note_id)
		return
	note_id = text2num(note_id)
	var/target_ckey
	var/datum/db_query/query_find_note_edit = SSdbcore.NewQuery("SELECT ckey, notetext, adminckey FROM [CONFIG_GET(string/utility_database)].[format_table_name("notes")] WHERE id=:note_id", list(
		"note_id" = note_id
	))
	if(!query_find_note_edit.warn_execute())
		qdel(query_find_note_edit)
		return
	if(query_find_note_edit.NextRow())
		target_ckey = query_find_note_edit.item[1]
		var/old_note = query_find_note_edit.item[2]
		var/adminckey = query_find_note_edit.item[3]
		var/new_note = tgui_input_text(usr, "Input new note", "New Note", "[old_note]", multiline = TRUE, encode = FALSE)
		if(!new_note)
			return
		var/server
		if(config && CONFIG_GET(string/servername))
			server = CONFIG_GET(string/servername)
		var/edit_text = "Last edit by [usr.ckey] at [SQLtime()][server ? " on [server]" : ""]"
		var/datum/db_query/query_update_note = SSdbcore.NewQuery("UPDATE [CONFIG_GET(string/utility_database)].[format_table_name("notes")] SET notetext=:new_note, last_editor=:akey, edits = CONCAT(IFNULL(edits,''),:edit_text) WHERE id=:note_id", list(
			"new_note" = new_note,
			"akey" = usr.ckey,
			"edit_text" = edit_text,
			"note_id" = note_id
		))
		if(!query_update_note.warn_execute())
			qdel(query_update_note)
			return
		log_admin("[usr ? key_name(usr) : "Bot"] has edited [target_ckey]'s note made by [adminckey] from \"[old_note]\" to \"[new_note]\"")
		message_admins("[usr ? key_name_admin(usr) : "Bot"] has edited [target_ckey]'s note made by [adminckey] from \"[old_note]\" to \"[new_note]\"")
		show_note(target_ckey)
		qdel(query_update_note)

/proc/show_note(target_ckey, index, linkless = 0)
	if(!check_rights(R_ADMIN|R_MOD))
		return
	var/list/output = list()
	var/list/navbar = list()
	var/ruler = "<hr style='background:#000000; border:0; height:3px'>"

	navbar = "<a href='byond://?_src_=holder;nonalpha=1'>\[All\]</a>|<a href='byond://?_src_=holder;nonalpha=2'>\[#\]</a>"
	for(var/letter in GLOB.alphabet)
		navbar += "|<a href='byond://?_src_=holder;shownote=[letter]'>\[[letter]\]</a>"
	navbar += "<br><form method='GET' name='search' action='?'>\
	<input type='hidden' name='_src_' value='holder'>\
	<input type='text' name='notessearch' value='[index]'>\
	<input style='margin-left: 5px;' type='submit' value='Search'></form>"
	if(!linkless)
		output += navbar
	if(target_ckey)
		var/target_sql_ckey = ckey(target_ckey)
		var/datum/db_query/query_get_notes = SSdbcore.NewQuery({"
			SELECT id, timestamp, notetext, adminckey, last_editor, server, crew_playtime
			FROM [CONFIG_GET(string/utility_database)].[format_table_name("notes")] WHERE ckey=:targetkey ORDER BY timestamp"}, list(
				"targetkey" = target_sql_ckey
			))
		if(!query_get_notes.warn_execute())
			qdel(query_get_notes)
			return
		output += "<h2><center>Notes of [target_ckey]</center></h2>"
		if(!linkless)
			output += "<center><a href='byond://?_src_=holder;addnote=[target_ckey]'>\[Add Note\]</a></center>"
		output += ruler
		while(query_get_notes.NextRow())
			var/id = query_get_notes.item[1]
			var/timestamp = query_get_notes.item[2]
			var/notetext = query_get_notes.item[3]
			var/adminckey = query_get_notes.item[4]
			var/last_editor = query_get_notes.item[5]
			var/server = query_get_notes.item[6]
			var/mins = text2num(query_get_notes.item[7])
			output += "<b>[timestamp] | [server] | [adminckey]"
			if(mins)
				var/playstring = get_exp_format(mins)
				output += " | [playstring] as Crew"
			output += "</b>"

			if(!linkless)
				output += " <a href='byond://?_src_=holder;removenote=[id]'>\[Remove Note\]</a> <a href='byond://?_src_=holder;editnote=[id]'>\[Edit Note\]</a>"
				if(last_editor)
					output += " <span style='font-size: 2;'>Last edit by [last_editor]</span>"
			output += "<br>[notetext]<hr style='background:#000000; border:0; height:1px'>"
		qdel(query_get_notes)
	else if(index)
		var/index_ckey
		var/search
		output += "<center><a href='byond://?_src_=holder;addnoteempty=1'>\[Add Note\]</a></center>"
		output += ruler
		switch(index)
			if(1)
				search = "^."
			if(2)
				search = "^\[^\[:alpha:\]\]"
			else
				search = "^[index]"
		var/datum/db_query/query_list_notes = SSdbcore.NewQuery("SELECT DISTINCT ckey FROM [CONFIG_GET(string/utility_database)].[format_table_name("notes")] WHERE ckey REGEXP :search ORDER BY ckey", list(
			"search" = search
		))
		if(!query_list_notes.warn_execute())
			qdel(query_list_notes)
			return
		to_chat(usr, "<span class='notice'>Started regex note search for [search]. Please wait for results...</span>")
		message_admins("[usr.ckey] has started a note search with the following regex: [search] | CPU usage may be higher.")
		while(query_list_notes.NextRow())
			index_ckey = query_list_notes.item[1]
			output += "<a href='byond://?_src_=holder;shownoteckey=[index_ckey]'>[index_ckey]</a><br>"
			CHECK_TICK
		qdel(query_list_notes)
		message_admins("The note search started by [usr.ckey] has complete. CPU should return to normal.")
	else
		output += "<center><a href='byond://?_src_=holder;addnoteempty=1'>\[Add Note\]</a></center>"
		output += ruler
	var/datum/browser/popup = new(usr, "show_notes", "<div align='center'>Notes</div>", 900, 500)
	popup.set_content(output.Join(""))
	popup.set_window_options("can_close=1;can_minimize=0;can_maximize=0;can_resize=0;titlebar=1;")
	popup.add_stylesheet("dark_inputs", "html/dark_inputs.css")
	popup.open(TRUE)
	onclose(usr, "show_notes")

