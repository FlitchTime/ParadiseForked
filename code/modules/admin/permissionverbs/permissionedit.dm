/client/proc/edit_admin_permissions()
	set category = "Admin.Admin"
	set name = "Permissions Panel"
	set desc = "Edit admin permissions"
	if(!check_rights(R_PERMISSIONS))
		return
	usr.client.holder.edit_admin_permissions()

/datum/admins/proc/edit_admin_permissions()
	if(!check_rights(R_PERMISSIONS))
		return

	var/datum/asset/permissions_asset = get_asset_datum(/datum/asset/simple/permissions)
	permissions_asset.send(usr)

	var/output = {"
<body onload='selectTextField(); updateSearch();'>
<style>
table {
    table-layout: fixed; /* Фиксирует ширину колонок */
    width: 100%; /* Заставляет таблицу занимать всю доступную ширину */
    border-collapse: collapse;
	max-width: 100%;
}

#main {
	overflow:hidden;
	max-width: 600px;
}

td, th {
    overflow: hidden; /* Скрывает содержимое, выходящее за пределы */
	white-space: nowrap; /* Запрещает перенос текста */
	margin: 5px;
	text-align:center;
}



</style>
<div id='main'>
<table id='searchable'>
<colgroup>
    <col style='width: 20%;'>
    <col style='width: 20%;'>
    <col style='width: 60%;'>
</colgroup>
<thead>
<tr class='title'>
<th>CKEY <a class='small' href='byond://?src=[UID()];editrights=add'>\[+\]</a></th>
<th>RANK</th>
<th>PERMISSIONS</th>
</tr>
</thead>
<tbody>
"}

	for(var/adm_ckey in GLOB.admin_datums)
		var/datum/admins/D = GLOB.admin_datums[adm_ckey]
		if(!D)	continue
		var/rank = D.rank ? D.rank : "*none*"
		var/rights = rights2text(D.rights," ")
		if(!rights)	rights = "*none*"
		output += {"<tr>
<td style='min-width: 20%;'>[adm_ckey] <a class='small' href='byond://?src=[UID()];editrights=remove;ckey=[adm_ckey]'>\[-\]</a></td>
<td slyle='min-width: 20%;'><a href='byond://?src=[UID()];editrights=rank;ckey=[adm_ckey]'>[rank]</a></td>
<td style='min-width: 60%;'><a class='small' href='byond://?src=[UID()];editrights=permissions;ckey=[adm_ckey]'>[rights]</a></td>
</tr>"}

	output += {"
</tbody>
</table>
</div>
<div id='top'><b>Search:</b> <input type='text' id='filter' value='' style='width:70%;' onkeyup='updateSearch();'></div>
</body>
"}

	var/datum/browser/popup = new(usr, "editrights", "<div align='center'>Permissions Panel</div>", 600, 500)
	popup.set_content(output)
	popup.set_window_options("can_close=1;can_minimize=0;can_maximize=0;can_resize=0;titlebar=1;")
	//popup.add_stylesheet("dark_inputs", "html/panels.css")
	popup.add_stylesheet("dark_inputs", "html/dark_inputs.css")
	popup.add_script("search", "html/search.js")
	popup.open()
	onclose(usr, "editrights")

/datum/admins/proc/log_admin_rank_modification(adm_ckey, new_rank, new_rigths = 0)
	if(CONFIG_GET(flag/admin_legacy_system))	return

	if(!usr.client)
		return

	if(!check_rights(R_PERMISSIONS))
		return

	if(!SSdbcore.IsConnected())
		to_chat(usr, "<span class='warning'>Failed to establish database connection</span>")
		return

	if(!adm_ckey || !new_rank)
		return

	adm_ckey = ckey(adm_ckey)

	if(!adm_ckey)
		return

	if(!istext(adm_ckey) || !istext(new_rank))
		return

	var/datum/db_query/select_query = SSdbcore.NewQuery("SELECT id FROM [format_table_name("admin")] WHERE ckey=:adm_ckey", list(
		"adm_ckey" = adm_ckey
	))
	if(!select_query.warn_execute())
		qdel(select_query)
		return

	var/new_admin = TRUE
	var/admin_id
	while(select_query.NextRow())
		new_admin = FALSE
		admin_id = text2num(select_query.item[1])
	qdel(select_query)
	flag_account_for_forum_sync(adm_ckey)
	if(new_admin)
		var/datum/db_query/insert_query = SSdbcore.NewQuery("INSERT INTO [format_table_name("admin")] (`id`, `ckey`, `rank`, `level`, `flags`) VALUES (null, :adm_ckey, :new_rank, -1, :new_flags)", list(
			"adm_ckey" = adm_ckey,
			"new_rank" = new_rank,
			"new_flags" = new_rigths
		))
		if(!insert_query.warn_execute())
			qdel(insert_query)
			return
		qdel(insert_query)

		var/logtxt = "Added new admin [adm_ckey] to rank [new_rank]"
		var/datum/db_query/log_query = SSdbcore.NewQuery("INSERT INTO [format_table_name("admin_log")] (`datetime` ,`adminckey` ,`adminip` ,`log` ) VALUES (Now() , :uckey, :uip, :logtxt)", list(
			"uckey" = usr.ckey,
			"uip" = usr.client.address,
			"logtxt" = logtxt
		))
		if(!log_query.warn_execute())
			qdel(log_query)
			return
		qdel(log_query)

		to_chat(usr, "<span class='notice'>New admin added.</span>")
	else
		if(!isnull(admin_id) && isnum(admin_id))
			var/datum/db_query/insert_query = SSdbcore.NewQuery("UPDATE [format_table_name("admin")] SET rank=:new_rank, flags=:new_flags WHERE id=:admin_id", list(
				"new_rank" = new_rank,
				"new_flags" = new_rigths,
				"admin_id" = admin_id,
			))
			if(!insert_query.warn_execute())
				qdel(insert_query)
				return
			qdel(insert_query)

			var/logtxt = "Edited the rank of [adm_ckey] to [new_rank]"
			var/datum/db_query/log_query = SSdbcore.NewQuery("INSERT INTO [format_table_name("admin_log")] (`datetime` ,`adminckey` ,`adminip` ,`log` ) VALUES (Now() , :uckey, :uip, :logtxt)", list(
				"uckey" = usr.ckey,
				"uip" = usr.client.address,
				"logtxt" = logtxt,
			))
			if(!log_query.warn_execute())
				qdel(log_query)
				return
			qdel(log_query)
			to_chat(usr, "<span class='notice'>Admin rank changed.</span>")

/datum/admins/proc/log_admin_permission_modification(adm_ckey, new_permission)
	if(IsAdminAdvancedProcCall())
		to_chat(usr, span_boldannounceooc("Admin edit blocked: Advanced ProcCall detected."))
		message_admins("[key_name(usr)] attempted to edit admin ranks via advanced proc-call")
		log_admin("[key_name(usr)] attempted to edit admin ranks via advanced proc-call")
		return
	if(CONFIG_GET(flag/admin_legacy_system))
		return

	if(!usr.client)
		return

	if(!check_rights(R_PERMISSIONS))
		return

	if(!SSdbcore.IsConnected())
		to_chat(usr, span_warning("Failed to establish database connection"))
		return

	if(!adm_ckey || !new_permission)
		return

	adm_ckey = ckey(adm_ckey)

	if(!adm_ckey)
		return

	if(istext(new_permission))
		new_permission = text2num(new_permission)

	if(!istext(adm_ckey) || !isnum(new_permission))
		return

	var/datum/db_query/select_query = SSdbcore.NewQuery("SELECT id FROM [format_table_name("admin")] WHERE ckey=:adm_ckey", list(
		"adm_ckey" = adm_ckey
	))
	if(!select_query.warn_execute())
		qdel(select_query)
		return

	var/admin_id

	while(select_query.NextRow())
		admin_id = text2num(select_query.item[1])

	qdel(select_query)
	if(!admin_id)
		return

	flag_account_for_forum_sync(adm_ckey)
	var/datum/db_query/insert_query = SSdbcore.NewQuery("UPDATE [format_table_name("admin")] SET flags=:newflags WHERE id=:admin_id", list(
		"newflags" = new_permission,
		"admin_id" = admin_id
	))
	if(!insert_query.warn_execute())
		qdel(insert_query)
		return
	qdel(insert_query)

	var/logtxt = "Updated permission [rights2text(new_permission, " ")] (flags = [new_permission]) to admin [adm_ckey]"
	var/datum/db_query/log_query = SSdbcore.NewQuery({"
			INSERT INTO [format_table_name("admin_log")] (`datetime` ,`adminckey` ,`adminip` ,`log`)
			VALUES (Now() , :uckey, :uip, :logtxt)"}, list(
				"uckey" = usr.ckey,
				"uip" = usr.client.address,
				"logtxt" = logtxt
			))

	if(!log_query.warn_execute())
		qdel(log_query)
		return
	qdel(log_query)
	to_chat(usr, span_notice("Permission Updated."))

/datum/admins/proc/updateranktodb(ckey,newrank)
	if(!SSdbcore.IsConnected())
		return
	if(!check_rights(R_PERMISSIONS))
		return

	var/datum/db_query/query_update = SSdbcore.NewQuery("UPDATE [format_table_name("player")] SET lastadminrank=:admin_rank WHERE ckey=:ckey", list(
		"admin_rank" = newrank,
		"ckey" = ckey
	))
	if(!query_update.warn_execute())
		qdel(query_update)
		return

	qdel(query_update)
	flag_account_for_forum_sync(ckey)
