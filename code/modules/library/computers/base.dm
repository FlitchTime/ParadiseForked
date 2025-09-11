#define MAX_BOOK_FLAGS 3 // maximum number of times a book can be flagged before being removed from results

/obj/machinery/computer/library
	name = "visitor computer"
	desc = "Старый библиотечный компьютер с ограниченным функционалом – специально для посетителей книжного храма."
	icon = 'icons/obj/library.dmi'
	icon_state = "oldcomp"
	icon_screen = "library"
	icon_keyboard = null
	anchored = TRUE
	density = TRUE
	var/screenstate = 0
	var/page_num = 1
	var/num_pages = 0
	var/num_results = 0
	var/datum/library_query/query = new()

/obj/machinery/computer/library/get_ru_names()
	return list(
		NOMINATIVE = "гостевой компьютер",
		GENITIVE = "гостевого компьютера",
		DATIVE = "гостевому компьютеру",
		ACCUSATIVE = "гостевой компьютер",
		INSTRUMENTAL = "гостевым компьютером",
		PREPOSITIONAL = "гостевом компьютере"
	)

/obj/machinery/computer/library/attack_animal(mob/living/simple_animal/M)
	if(istype(M, /mob/living/simple_animal/pet/library_owl))
		interact(M)
	. = ..()

/obj/machinery/computer/library/proc/interact_check(mob/user)
	if(stat & (BROKEN | NOPOWER))
		return 1

	if(!Adjacent(user))
		if(!issilicon(user) && !isobserver(user))
			user.unset_machine()
			close_window(user, "library")
			return 1

	user.set_machine(src)
	return 0

/obj/machinery/computer/library/proc/get_page(page_num)
	var/searchquery = ""
	var/where = 0
	var/list/sql_params = list()
	if(query)
		if(query.title && query.title != "")
			searchquery += " WHERE title LIKE :title"
			sql_params["title"] = "%[query.title]%"
			where = 1
		if(query.author && query.author != "")
			searchquery += " [!where ? "WHERE" : "AND"] author LIKE :author"
			sql_params["author"] = "%[query.author]%"
			where = 1
		if(query.category && query.category != "")
			searchquery += " [!where ? "WHERE" : "AND"] category LIKE :cat"
			sql_params["cat"] = "%[query.category]%"
			if(query.category == "Fiction")
				searchquery += " AND category NOT LIKE '%Non-Fiction%'"
			where = 1

	// This one doesnt take player input directly, so it doesnt require params
	searchquery += " [!where ? "WHERE" : "AND"] flagged < [MAX_BOOK_FLAGS]"
	// This does though
	var/sql = "SELECT id, author, title, category, ckey, flagged FROM [format_table_name("library")] [searchquery] LIMIT :lowerlimit, :upperlimit"
	sql_params["lowerlimit"] = text2num((page_num - 1) * LIBRARY_BOOKS_PER_PAGE)
	sql_params["upperlimit"] = LIBRARY_BOOKS_PER_PAGE

	// Pagination
	var/datum/db_query/select_query = SSdbcore.NewQuery(sql, sql_params)

	if(!select_query.warn_execute())
		qdel(select_query)
		return

	var/list/results = list()
	while(select_query.NextRow())
		var/datum/cachedbook/CB = new()
		CB.LoadFromRow(list(
			"id"      =select_query.item[1],
			"author"  =select_query.item[2],
			"title"   =select_query.item[3],
			"category"=select_query.item[4],
			"ckey"    =select_query.item[5],
			"flagged" =text2num(select_query.item[6])
		))
		results += CB
	qdel(select_query)
	return results

/obj/machinery/computer/library/proc/get_num_results()
	var/sql = "SELECT COUNT(id) FROM [format_table_name("library")]"

	var/datum/db_query/count_query = SSdbcore.NewQuery(sql)
	if(!count_query.warn_execute())
		qdel(count_query)
		return

	while(count_query.NextRow())
		var/value = text2num(count_query.item[1])
		qdel(count_query)
		return value
	qdel(count_query)
	return 0

/obj/machinery/computer/library/proc/get_pagelist()
	var/pagelist = "<div class='pages'>"
	var/start = max(1, page_num - 3)
	var/end = min(num_pages, page_num + 3)
	for(var/i = start to end)
		var/dat = "<a href='byond://?src=[UID()];page=[i]'>[i]</a>"
		if(i == page_num)
			dat = (span_bold(span_fontsize3("[dat]")))
		if(i != end)
			dat += " "
		pagelist += dat
	pagelist += "</div>"
	return pagelist

/obj/machinery/computer/library/proc/getBookByID(id)
	return GLOB.library_catalog.getBookByID(id)

#undef MAX_BOOK_FLAGS
