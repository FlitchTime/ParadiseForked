//Verbs

/client/proc/openAdminTicketUI()

	set name = "Open Admin Ticket Interface"
	set category = "Admin.Admin Tickets"

	if(!check_rights(R_ADMIN|R_MOD))
		return

	SStickets.showUI(usr)

/client/proc/resolveAllAdminTickets()
	set name = "Resolve All Open Admin Tickets"

	if(!check_rights(R_ADMIN))
		return

	if(tgui_alert(usr, "Are you sure you want to resolve ALL open admin tickets?", "Resolve all open admin tickets?", list("Yes", "No")) != "Yes")
		return

	SStickets.resolveAllOpenTickets()

/client/verb/openAdminUserUI()
	set name = "My Admin Tickets"
	set category = "Admin.Admin Tickets"
	SStickets.userDetailUI(usr)
