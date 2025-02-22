/client/proc/delbook()
	set name = "Delete Book"
	set desc = "Permamently deletes a book from the database."
	set category = "Admin.Admin"

	if(!check_rights(R_ADMIN))
		return

	var/isbn = input("ISBN number?", "Delete Book") as num | null
	if(!isbn)
		return

	var/datum/db_query/query_delbook = SSdbcore.NewQuery("DELETE FROM [format_table_name("library")] WHERE id=:isbn", list(
		"isbn" = text2num(isbn) // just to be sure
	))
	if(!query_delbook.warn_execute())
		qdel(query_delbook)
		return

	qdel(query_delbook)
	log_admin("[key_name_log(usr)] has deleted the book [isbn].")
	message_admins("[key_name_admin(usr)] has deleted the book [isbn].")

/client/proc/view_flagged_books()
	set name = "View Flagged Books"
	set desc = "View books flagged for content."
	set category = "Admin.Admin"

	if(!check_rights(R_ADMIN))
		return

	holder.view_flagged_books()

#define FLAGGED_BOOKS_PER_PAGE 10

/datum/admins/proc/view_flagged_books(page_num = 1)
	if(!usr.client.holder)
		return

	var/dat = {"<meta charset="UTF-8"><table><tr><th>ISBN</th><th>Title</th><th>Total Flags</th><th>Flagged by (Last ckey)</th><th>Options</th></tr>"}

	var/datum/db_query/query = SSdbcore.NewQuery("SELECT id, title, flagged, flaggedby FROM [format_table_name("library")] WHERE \
	 flagged > 0 ORDER BY flagged DESC LIMIT :lowerlimit, :upperlimit", list(
		"lowerlimit" = text2num((page_num - 1) * FLAGGED_BOOKS_PER_PAGE),
		"upperlimit" = FLAGGED_BOOKS_PER_PAGE
		))


	if(!query.warn_execute())
		qdel(query)
		return

	var/books = 0
	while(query.NextRow())
		books++
		var/isbn = query.item[1]
		dat += "<tr><td>[add_zero(isbn, 4)]</td><td>[query.item[2]]</td><td>[query.item[3]]</td><td>[query.item[4]]</td><td>"
		dat += "<a href='byond://?_src_=holder;library_book_id=[isbn];view_library_book=1;'>View Content</a>"
		dat += "<a href='byond://?_src_=holder;library_book_id=[isbn];unflag_library_book=1;'>Unflag</a>"
		dat += "<a href='byond://?_src_=holder;library_book_id=[isbn];delete_library_book=1;'>Delete</a>"
		dat += "</td>"

	dat += "</table>"
	qdel(query)

	if(!books)
		dat = "<h1>No flagged books! :)</h1>"

	var/datum/browser/popup = new(usr, "admin_view_flagged_books", "Flagged Books (Shown first [FLAGGED_BOOKS_PER_PAGE] books)", 700, 400)
	popup.set_content(dat)
	popup.open(0)

#undef FLAGGED_BOOKS_PER_PAGE
