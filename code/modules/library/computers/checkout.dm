/*
 * Library Computer
 */
/obj/machinery/computer/library/checkout
	name = "Check-In/Out Computer"
	var/arcanecheckout = 0
	//var/screenstate = 0 // 0 - Main Menu, 1 - Inventory, 2 - Checked Out, 3 - Check Out a Book
	var/buffer_book
	var/buffer_mob
	var/upload_category = "Fiction"
	var/list/checkouts = list()
	var/list/inventory = list()
	var/checkoutperiod = 5 // In minutes
	var/obj/machinery/libraryscanner/scanner // Book scanner that will be used when uploading books to the Archive

	var/bibledelay = 0 // LOL NO SPAM (1 minute delay) -- Doohl
	var/booklist

/obj/machinery/computer/library/checkout/attack_hand(var/mob/user as mob)
	if(..())
		return
	interact(user)

/obj/machinery/computer/library/checkout/interact(var/mob/user)
	if(interact_check(user))
		return

	var/dat = ""
	switch(screenstate)
		if(0)
			// Main Menu

			dat += {"<ol>
				<li><a href='byond://?src=[UID()];switchscreen=1'>View General Inventory</a></li>
				<li><a href='byond://?src=[UID()];switchscreen=2'>View Checked Out Inventory</a></li>
				<li><a href='byond://?src=[UID()];switchscreen=3'>Check out a Book</a></li>
				<li><a href='byond://?src=[UID()];switchscreen=4'>Connect to External Archive</a></li>
				<li><a href='byond://?src=[UID()];switchscreen=5'>Upload New Title to Archive</a></li>
				<li><a href='byond://?src=[UID()];switchscreen=6'>Print a Bible</a></li>
				<li><a href='byond://?src=[UID()];switchscreen=7'>Print a Manual</a></li>"}
			if(src.emagged)
				dat += "<li><a href='byond://?src=[UID()];switchscreen=8'>Access the Forbidden Lore Vault</a></li>"
			dat += "</ol>"

			if(src.arcanecheckout)
				new /obj/item/melee/cultblade/dagger(src.loc)
				to_chat(user, "<span class='warning'>Your sanity barely endures the seconds spent in the vault's browsing window. The only thing to remind you of this when you stop browsing is a strange looking dagger sitting on the desk. You don't really remember where it came from.</span>")
				user.visible_message("[user] stares at the blank screen for a few moments, [user.p_their()] expression frozen in fear. When [user.p_they()] finally awaken[user.p_s()] from it, [user.p_they()] look[user.p_s()] a lot older.", 2)
				src.arcanecheckout = 0
		if(1)
			// Inventory
			dat += "<h3>Inventory</h3>"
			for(var/obj/item/book/b in inventory)
				dat += "[b.name] <a href='byond://?src=[UID()];delbook=\ref[b]'>(Delete)</a><br>"
			dat += "<a href='byond://?src=[UID()];switchscreen=0'>(Return to main menu)</a><br>"
		if(2)
			// Checked Out
			dat += "<h3>Checked Out Books</h3><br>"
			for(var/datum/borrowbook/b in checkouts)
				var/timetaken = world.time - b.getdate
				//timetaken *= 10
				timetaken /= 600
				timetaken = round(timetaken)
				var/timedue = b.duedate - world.time
				//timedue *= 10
				timedue /= 600
				if(timedue <= 0)
					timedue = "<span style='color: red;'><b>(OVERDUE)</b> [timedue]</span>"
				else
					timedue = round(timedue)

				dat += {"\"[b.bookname]\", Checked out to: [b.mobname]<br>--- Taken: [timetaken] minutes ago, Due: in [timedue] minutes<br>
					<a href='byond://?src=[UID()];checkin=\ref[b]'>(Check In)</a><br><br>"}
			dat += "<a href='byond://?src=[UID()];switchscreen=0'>(Return to main menu)</a><br>"
		if(3)
			// Check Out a Book

			dat += {"<h3>Check Out a Book</h3><br>
				Book: [src.buffer_book]
				<a href='byond://?src=[UID()];editbook=1'>\[Edit\]</a><br>
				Recipient: [src.buffer_mob]
				<a href='byond://?src=[UID()];editmob=1'>\[Edit\]</a><br>
				Checkout Date : [world.time/600]<br>
				Due Date: [(world.time + checkoutperiod)/600]<br>
				(Checkout Period: [checkoutperiod] minutes) (<a href='byond://?src=[UID()];increasetime=1'>+</a>/<a href='byond://?src=[UID()];decreasetime=1'>-</a>)
				<a href='byond://?src=[UID()];checkout=1'>(Commit Entry)</a><br>
				<a href='byond://?src=[UID()];switchscreen=0'>(Return to main menu)</a><br>"}
		if(4)
			dat += "<h3>External Archive</h3>"
			if(!SSdbcore.IsConnected())
				dat += "<span style='color: red;'<b>ERROR</b>: Unable to contact External Archive. Please contact your system administrator for assistance.</span>"
			else
				num_results = src.get_num_results()
				num_pages = CEILING(num_results/LIBRARY_BOOKS_PER_PAGE, 1)
				dat += {"<ul>
					<li><a href='byond://?src=[UID()];id=-1'>(Order book by SS<sup>13</sup>BN)</a></li>
				</ul>"}
				var/pagelist = get_pagelist()

				dat += {"<h2>Search Settings</h2><br />
					<a href='byond://?src=[UID()];settitle=1'>Filter by Title: [query.title]</a><br />
					<a href='byond://?src=[UID()];setcategory=1'>Filter by Category: [query.category]</a><br />
					<a href='byond://?src=[UID()];setauthor=1'>Filter by Author: [query.author]</a><br />
					<a href='byond://?src=[UID()];search=1'>\[Start Search\]</a><br />"}
				dat += pagelist

				dat += {"<form name='pagenum' action='?src=[UID()]' method='get'>
										<input type='hidden' name='src' value='[UID()]'>
										<input type='text' name='pagenum' value='[page_num]' maxlength="5" size="5">
										<input type='submit' value='Jump To Page'>
							</form>"}

				dat += {"<table border=\"0\">
					<tr>
						<td>Author</td>
						<td>Title</td>
						<td>Category</td>
						<td>Controls</td>
					</tr>"}

				for(var/datum/cachedbook/CB in get_page(page_num))
					var/author = CB.author
					var/controls =  "<a href='byond://?src=[UID()];id=[CB.id]'>\[Order\]</a>"
					controls += {" <a href="byond://?src=[UID()];flag=[CB.id]">\[Flag[CB.flagged ? "ged" : ""]\]</a>"}
					if(check_rights(R_ADMIN, 0, user = user))
						controls +=  " <a style='color:red' href='byond://?src=[UID()];del=[CB.id]'>\[Delete\]</a>"
						author += " (<a style='color:red' href='byond://?src=[UID()];delbyckey=[ckey(CB.ckey)]'>[ckey(CB.ckey)])</a>)"
					dat += {"<tr>
						<td>[author]</td>
						<td>[CB.title]</td>
						<td>[CB.category]</td>
						<td>[controls]</td>
					</tr>"}

				dat += "</table><br />[pagelist]"

			dat += "<br /><a href='byond://?src=[UID()];switchscreen=0'>(Return to main menu)</a><br>"
		if(5)
			dat += "<h3>Upload a New Title</h3>"
			if(!scanner)
				for(var/obj/machinery/libraryscanner/S in range(9))
					scanner = S
					break
			if(!scanner)
				dat += "<span style='color: red;'>No scanner found within wireless network range.</span><br>"
			else if(!scanner.cache)
				dat += "<span style='color: red;'>No data found in scanner memory.</span><br>"
			else

				dat += {"<tt>Data marked for upload...</tt><br>
					<tt>Title: </tt>[scanner.cache.name]<br>"}
				if(!scanner.cache.author)
					scanner.cache.author = "Anonymous"

				dat += {"<tt>Author: </tt><a href='byond://?src=[UID()];uploadauthor=1'>[scanner.cache.author]</a><br>
					<tt>Category: </tt><a href='byond://?src=[UID()];uploadcategory=1'>[upload_category]</a><br>
					<a href='byond://?src=[UID()];upload=1'>\[Upload\]</a><br>"}
			dat += "<a href='byond://?src=[UID()];switchscreen=0'>(Return to main menu)</a><br>"
		if(7)
			dat += "<h3>Print a Manual</h3>"
			dat += "<table>"

			var/list/forbidden = list(
				/obj/item/book/manual/random
			)

			if(!emagged)
				forbidden |= /obj/item/book/manual/nuclear

			var/manualcount = 1
			var/obj/item/book/manual/M = null

			for(var/manual_type in subtypesof(/obj/item/book/manual))
				if(!(manual_type in forbidden))
					M = new manual_type()
					dat += "<tr><td><a href='byond://?src=[UID()];manual=[manualcount]'>[M.title]</a></td></tr>"
					QDEL_NULL(M)
				manualcount++
			dat += "</table>"
			dat += "<br><a href='byond://?src=[UID()];switchscreen=0'>(Return to main menu)</a><br>"

		if(8)

			dat += {"<h3>Accessing Forbidden Lore Vault v 1.3</h3>
				Are you absolutely sure you want to proceed? EldritchArtifacts Inc. takes no responsibilities for loss of sanity resulting from this action.<p>
				<a href='byond://?src=[UID()];arccheckout=1'>Yes.</a><br>
				<a href='byond://?src=[UID()];switchscreen=0'>No.</a><br>"}

	var/datum/browser/B = new /datum/browser(user, "library", "Book Inventory Management")
	B.set_content(dat)
	B.add_stylesheet("dark_inputs", "html/dark_inputs.css")
	B.open()

/obj/machinery/computer/library/checkout/emag_act(mob/user)
	if(density && !emagged)
		emagged = 1
		if(user)
			to_chat(user, "<span class='notice'>You override the library computer's printing restrictions.</span>")


/obj/machinery/computer/library/checkout/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/barcodescanner))
		add_fingerprint(user)
		var/obj/item/barcodescanner/scanner = I
		scanner.computer = src
		to_chat(user, span_notice("The [scanner.name]'s associated machine has been set to [src]."))
		audible_message("The [name] lets out a low, short blip.", hearing_distance = 2)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/machinery/computer/library/checkout/wrench_act(mob/living/user, obj/item/I)
	return default_unfasten_wrench(user, I)


/obj/machinery/computer/library/checkout/Topic(href, href_list)
	if(..())
		close_window(usr, "library")
		onclose(usr, "library")
		return 1

	if(href_list["pagenum"])
		if(!num_pages)
			page_num = 1
		else
			var/pn = text2num(href_list["pagenum"])
			if(!isnull(pn))
				page_num = clamp(pn, 1, num_pages)

	if(href_list["page"])
		if(num_pages == 0)
			page_num = 1
		else
			page_num = clamp(text2num(href_list["page"]), 1, num_pages)
	if(href_list["settitle"])
		var/newtitle = input("Enter a title to search for:") as text|null
		if(newtitle)
			query.title = sanitize(newtitle)
		else
			query.title = null
	if(href_list["setcategory"])
		var/newcategory = input("Choose a category to search for:") in (list("Any") + GLOB.library_section_names)
		if(newcategory == "Any")
			query.category = null
		else if(newcategory)
			query.category = sanitize(newcategory)
	if(href_list["setauthor"])
		var/newauthor = input("Enter an author to search for:") as text|null
		if(newauthor)
			query.author = sanitize(newauthor)
		else
			query.author = null

	if(href_list["search"])
		num_results = src.get_num_results()
		num_pages = CEILING(num_results/LIBRARY_BOOKS_PER_PAGE, 1)
		page_num = 1

		screenstate = 4
	if(href_list["del"])
		if(!check_rights(R_ADMIN))
			return
		var/datum/cachedbook/target = getBookByID(href_list["del"]) // Sanitized in getBookByID
		var/ans = alert(usr, "Are you sure you wish to delete \"[target.title]\", by [target.author]? This cannot be undone.", "Library System", "Yes", "No")
		if(ans=="Yes")
			var/datum/db_query/query = SSdbcore.NewQuery("DELETE FROM [format_table_name("library")] WHERE id=:id", list(
				"id" = text2num(target.id)
			))
			if(!query.warn_execute())
				qdel(query)
				return
			qdel(query)
			log_admin("LIBRARY: [key_name(usr)] has deleted \"[target.title]\", by [target.author] ([target.ckey])!")
			message_admins("[key_name_admin(usr)] has deleted \"[target.title]\", by [target.author] ([target.ckey])!")
			src.updateUsrDialog()
			return

	if(href_list["delbyckey"])
		if(!check_rights(R_ADMIN))
			return
		var/tckey = ckey(href_list["delbyckey"])
		var/ans = alert(usr,"Are you sure you wish to delete all books by [tckey]? This cannot be undone.", "Library System", "Yes", "No")
		if(ans=="Yes")
			var/datum/db_query/query = SSdbcore.NewQuery("DELETE FROM [format_table_name("library")] WHERE ckey=:ckey", list(
				"ckey" = tckey
			))
			if(!query.warn_execute())
				qdel(query)
				return

			if(query.affected == 0)
				to_chat(usr, "<span class='danger'>Unable to find any matching rows.</span>")
				qdel(query)
				return
			qdel(query)
			log_admin("LIBRARY: [key_name(usr)] has deleted [query.affected] books written by [tckey]!")
			message_admins("[key_name_admin(usr)] has deleted [query.affected] books written by [tckey]!")
			src.updateUsrDialog()
			return

	if(href_list["flag"])
		if(!SSdbcore.IsConnected())
			alert("Connection to Archive has been severed. Aborting.")
			return
		var/id = href_list["flag"]
		if(id)
			var/datum/cachedbook/B = getBookByID(id)
			if(B)
				if((input(usr, "Are you sure you want to flag [B.title] as having inappropriate content?", "Flag Book #[B.id]") in list("Yes", "No")) == "Yes")
					GLOB.library_catalog.flag_book_by_id(usr, id)

	if(href_list["switchscreen"])
		switch(href_list["switchscreen"])
			if("0")
				screenstate = 0
			if("1")
				screenstate = 1
			if("2")
				screenstate = 2
			if("3")
				screenstate = 3
			if("4")
				screenstate = 4
			if("5")
				screenstate = 5
			if("6")
				if(!bibledelay)

					var/obj/item/storage/bible/B = new /obj/item/storage/bible(src.loc)
					if(SSticker && ( SSticker.Bible_icon_state && SSticker.Bible_item_state) )
						B.icon_state = SSticker.Bible_icon_state
						B.item_state = SSticker.Bible_item_state
						B.name = SSticker.Bible_name
						B.deity_name = SSticker.Bible_deity_name

					bibledelay = 1
					spawn(60)
						bibledelay = 0

				else
					visible_message("<b>[src]</b>'s monitor flashes, \"Bible printer currently unavailable, please wait a moment.\"")

			if("7")
				screenstate = 7
			if("8")
				screenstate = 8
	if(href_list["arccheckout"])
		if(src.emagged)
			src.arcanecheckout = 1
		src.screenstate = 0
	if(href_list["increasetime"])
		checkoutperiod += 1
	if(href_list["decreasetime"])
		checkoutperiod -= 1
		if(checkoutperiod < 1)
			checkoutperiod = 1
	if(href_list["editbook"])
		buffer_book = copytext(sanitize(input("Enter the book's title:") as text|null),1,MAX_MESSAGE_LEN)
	if(href_list["editmob"])
		buffer_mob = copytext(sanitize(input("Enter the recipient's name:") as text|null),1,MAX_NAME_LEN)
	if(href_list["checkout"])
		var/datum/borrowbook/b = new /datum/borrowbook
		b.bookname = sanitize(buffer_book)
		b.mobname = sanitize(buffer_mob)
		b.getdate = world.time
		b.duedate = world.time + (checkoutperiod * 600)
		checkouts.Add(b)
	if(href_list["checkin"])
		var/datum/borrowbook/b = locate(href_list["checkin"])
		checkouts.Remove(b)
	if(href_list["delbook"])
		var/obj/item/book/b = locate(href_list["delbook"])
		inventory.Remove(b)
	if(href_list["uploadauthor"])
		var/newauthor = copytext(sanitize(input("Enter the author's name: ") as text|null),1,MAX_MESSAGE_LEN)
		if(newauthor && scanner)
			scanner.cache.author = newauthor
	if(href_list["uploadcategory"])
		var/newcategory = input("Choose a category: ") in list("Fiction", "Non-Fiction", "Adult", "Reference", "Religion")
		if(newcategory)
			upload_category = newcategory
	if(href_list["upload"])
		if(scanner)
			if(scanner.cache)
				var/choice = input("Are you certain you wish to upload this title to the Archive?") in list("Confirm", "Abort")
				if(choice == "Confirm")
					if(!SSdbcore.IsConnected())
						alert("Connection to Archive has been severed. Aborting.")
					else
						var/datum/db_query/query = SSdbcore.NewQuery({"
							INSERT INTO [format_table_name("library")] (author, title, content, category, ckey, flagged)
							VALUES (:author, :title, :content, :category, :ckey, 0)"}, list(
								"author" = scanner.cache.author,
								"title" = scanner.cache.name,
								"content" = scanner.cache.dat,
								"category" = upload_category,
								"ckey" = usr.ckey
							))

						if(!query.warn_execute())
							qdel(query)
							return

						qdel(query)
						log_admin("[usr.name]/[usr.key] has uploaded the book titled [scanner.cache.name], [length(scanner.cache.dat)] characters in length")
						message_admins("[key_name_admin(usr)] has uploaded the book titled [scanner.cache.name], [length(scanner.cache.dat)] characters in length")

	if(href_list["id"])
		if(href_list["id"]=="-1")
			href_list["id"] = input("Enter your order:") as null|num
			if(!href_list["id"])
				return

		if(!SSdbcore.IsConnected())
			alert("Connection to Archive has been severed. Aborting.")
			return

		var/datum/cachedbook/newbook = getBookByID(href_list["id"]) // Sanitized in getBookByID
		if(!newbook)
			alert("No book found")
			return
		if((newbook.forbidden == 2 && !emagged) || newbook.forbidden == 1)
			alert("This book is forbidden and cannot be printed.")
			return

		if(bibledelay)
			visible_message("<b>[src]</b>'s monitor flashes, \"Printer unavailable. Please allow a short time before attempting to print.\"")
		else
			bibledelay = 1
			spawn(60)
				bibledelay = 0
			make_external_book(newbook)
	if(href_list["manual"])
		if(!href_list["manual"]) return
		var/bookid = href_list["manual"]

		if(!SSdbcore.IsConnected())
			alert("Connection to Archive has been severed. Aborting.")
			return

		var/datum/cachedbook/newbook = getBookByID("M[bookid]")
		if(!newbook)
			alert("No book found")
			return
		if((newbook.forbidden == 2 && !emagged) || newbook.forbidden == 1)
			alert("This book is forbidden and cannot be printed.")
			return

		if(bibledelay)
			for(var/mob/V in hearers(src))
				V.show_message("<b>[src]</b>'s monitor flashes, \"Printer unavailable. Please allow a short time before attempting to print.\"")
		else
			bibledelay = 1
			spawn(60)
				bibledelay = 0
			make_external_book(newbook)

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

/*
 * Library Scanner
 */

/obj/machinery/computer/library/checkout/proc/make_external_book(var/datum/cachedbook/newbook)
	if(!newbook || !newbook.id)
		return
	var/obj/item/book/B = new newbook.path(loc)

	if(!newbook.programmatic)
		B.name = "Book: [newbook.title]"
		B.title = newbook.title
		B.author = newbook.author
		B.dat = newbook.content
		B.icon_state = "book[rand(1,16)]"
		B.has_drm = TRUE
	visible_message("[src]'s printer hums as it produces a completely bound book. How did it do that?")
