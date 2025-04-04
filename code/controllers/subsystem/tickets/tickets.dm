//Defines
//Deciseconds until ticket becomes stale if unanswered. Alerts admins.
#define TICKET_TIMEOUT 6000 // 10 minutes
//Decisecions before the user is allowed to open another ticket while their existing one is open.
#define TICKET_DUPLICATE_COOLDOWN 3000 // 5 minutes

//Status defines
#define TICKET_OPEN       1
#define TICKET_CLOSED     2
#define TICKET_RESOLVED   3
#define TICKET_STALE      4

#define TICKET_STAFF_MESSAGE_ADMIN_CHANNEL 1
#define TICKET_STAFF_MESSAGE_PREFIX 2

SUBSYSTEM_DEF(tickets)
	name = "Admin Tickets"
	init_order = INIT_ORDER_TICKETS
	wait = 300
	priority = FIRE_PRIORITY_TICKETS
	offline_implications = "Admin tickets will no longer be marked as stale. No immediate action is needed."
	flags = SS_BACKGROUND
	ss_id = "admin_tickets"
	var/span_class = "adminticket"
	var/ticket_system_name = "Admin Tickets"
	var/ticket_name = "Admin Ticket"
	var/close_rights = R_ADMIN
	var/rights_needed = R_ADMIN|R_MOD

	/// Text that will be added to the anchor link
	var/anchor_link_extra = ""

	var/ticket_help_type = "Adminhelp"
	var/ticket_help_span = "adminhelp"
	/// The name of the other ticket type to convert to
	var/other_ticket_name = "Mentor"
	/// Which permission to look for when seeing if there is staff available for the other ticket type
	var/other_ticket_permission = R_MENTOR
	var/list/close_messages
	var/list/allTickets = list()	//make it here because someone might ahelp before the system has initialized

	var/ticketCounter = 1


/datum/controller/subsystem/tickets/Initialize()
	close_messages = list("<font color='red' size='4'><b>- [ticket_name] Отклонено! -</b></font>",
				"<span class='boldmessage'>Пожалуйста, постарайтесь в тикетах вести себя спокойно, излагать проблему ясно и описательно. Не предполагайте что администратор видел какие-либо связанные события, и чётко укажите имена тех, о ком вы сообщаете. Если вы задали вопрос, то убедитесь, что из него понятно, о чём именно вы спрашиваете.</span>",
				"<span class='[span_class]'>Ваш [ticket_name] теперь закрыт.</span>")
	return SS_INIT_SUCCESS

/datum/controller/subsystem/tickets/fire()
	var/stales = checkStaleness()
	if(LAZYLEN(stales))
		var/report
		for(var/num in stales)
			report += "[num], "
		message_staff("<span class='[span_class]'>Тикет [report] был открыт [TICKET_TIMEOUT / 600] минут. Меняю статус на «Просрочен».</span>")


/datum/controller/subsystem/tickets/get_stat_details()
	return "Tickets: [LAZYLEN(allTickets)]"


/datum/controller/subsystem/tickets/proc/checkStaleness()
	var/stales = list()
	for(var/T in allTickets)
		var/datum/ticket/ticket = T
		if(!(ticket.ticketState == TICKET_OPEN))
			continue
		if(world.time > ticket.timeUntilStale && (!ticket.lastStaffResponse || !ticket.staffAssigned))
			var/id = ticket.makeStale()
			stales += id
	return stales

//Return the current ticket number ready to be called off.
/datum/controller/subsystem/tickets/proc/getTicketCounter()
	return ticketCounter

//Return the ticket counter and increment
/datum/controller/subsystem/tickets/proc/getTicketCounterAndInc()
	. = ticketCounter
	ticketCounter++
	return

/datum/controller/subsystem/tickets/proc/resolveAllOpenTickets() // Resolve all open tickets
	for(var/i in allTickets)
		var/datum/ticket/T = i
		resolveTicket(T.ticketNum)

/**
 * Will either make a new ticket using the given text or will add the text to an existing ticket.
 * Staff will get a message
 * Arguments:
 * C - The client who requests help
 * text - The text the client send
 */
/datum/controller/subsystem/tickets/proc/newHelpRequest(client/C, text)
	var/ticketNum // Holder for the ticket number
	var/datum/ticket/T
	// Get the open ticket assigned to the client and add a response. If no open tickets then make a new one
	if((T = checkForOpenTicket(C)))
		ticketNum = T.ticketNum
		T.addResponse(C, text)
		T.setCooldownPeriod()
		to_chat(C.mob, "<span class='[span_class]'>Ваш [ticket_name] #[ticketNum] остаётся открытым! Его можно найти в «My tickets» во вкладке «Admin».</span>", confidential=TRUE)
		var/url_message = makeUrlMessage(C, text, ticketNum)
		message_staff(url_message, NONE, TRUE)
	else
		newTicket(C, text, text)

/**
 * Will add the URLs usable by staff to the message and return it
 * Arguments:
 * C - The client who send the message
 * msg - The raw message
 * ticketNum - Which ticket number the ticket has
 */
/datum/controller/subsystem/tickets/proc/makeUrlMessage(client/C, msg, ticketNum)
	var/list/L = list()
	L += "<span class='[ticket_help_span]'>[ticket_help_type]: </span><span class='boldnotice'>[key_name(C, TRUE, ticket_help_type)] "
	L += "([ADMIN_QUE(C.mob,"?")]) ([ADMIN_PP(C.mob,"PP")]) ([ADMIN_VV(C.mob,"VV")]) ([ADMIN_TP(C.mob,"TP")]) ([ADMIN_OBS(C.mob, "OBS")]) ([ADMIN_SM(C.mob,"SM")]) "
	L += "([admin_jump_link(C.mob)]) (<a href='byond://?_src_=holder;openticket=[ticketNum][anchor_link_extra]'>TICKET</a>) "
	L += "[isAI(C.mob) ? "(<a href='byond://?_src_=holder;adminchecklaws=[C.mob.UID()]'>CL</a>)" : ""] (<a href='byond://?_src_=holder;take_question=[ticketNum][anchor_link_extra]'>TAKE</a>) "
	L += "(<a href='byond://?_src_=holder;resolve=[ticketNum][anchor_link_extra]'>RESOLVE</a>) (<a href='byond://?_src_=holder;autorespond=[ticketNum][anchor_link_extra]'>AUTO</a>) "
	L += "(<a href='byond://?_src_=holder;convert_ticket=[ticketNum][anchor_link_extra]'>CONVERT</a>) :</span> <span class='[ticket_help_span]'>[msg]</span>"
	return L.Join()

//Open a new ticket and populate details then add to the list of open tickets
/datum/controller/subsystem/tickets/proc/newTicket(client/C, passedContent, title)
	if(!C || !passedContent)
		return

	if(!title)
		title = passedContent

	var/new_ticket_num = getTicketCounterAndInc()
	var/url_title = makeUrlMessage(C, title, new_ticket_num)

	var/datum/ticket/T = new(url_title, title, passedContent, new_ticket_num)
	allTickets += T
	T.client_ckey = C.ckey
	T.locationSent = C.mob.loc.name
	T.mobControlled = C.mob

	//Inform the user that they have opened a ticket
	to_chat(C, "<span class='[span_class]'>Вы открыли [ticket_name] номер #[(getTicketCounter() - 1)]! Пожалуйста, ожидайте. Вам скоро ответят.</span>", confidential=TRUE)
	var/ticket_open_sound = sound('sound/effects/adminticketopen.ogg')
	SEND_SOUND(C, ticket_open_sound)

	message_staff(url_title, NONE, TRUE)

//Set ticket state with key N to open
/datum/controller/subsystem/tickets/proc/openTicket(N)
	var/datum/ticket/T = allTickets[N]
	if(T.ticketState != TICKET_OPEN)
		message_staff("<span class='[span_class]'>[usr.client] / ([usr]) снова открыл [ticket_name] номер #[N]</span>")
		T.ticketState = TICKET_OPEN
		return TRUE

//Set ticket state with key N to resolved
/datum/controller/subsystem/tickets/proc/resolveTicket(N)
	var/datum/ticket/T = allTickets[N]
	if(T.ticketState != TICKET_RESOLVED)
		T.ticketState = TICKET_RESOLVED
		message_staff("<span class='[span_class]'>[usr.client] / ([usr]) решил [ticket_name] номер [N]</span>")
		to_chat_safe(returnClient(N), "<span class='[span_class]'>Ваш [ticket_name] был решён.</span>", confidential=TRUE)
		return TRUE

/datum/controller/subsystem/tickets/proc/convert_to_other_ticket(ticketId)
	if(!check_rights(rights_needed))
		return
	if(alert("Вы уверены, что хотите перевести тикет в '[other_ticket_name]' тикет?", "Уверены?", "Да", "Нет") != "Да")
		return
	if(!other_ticket_system_staff_check())
		return
	var/datum/ticket/T = allTickets[ticketId]
	if(T.ticket_converted)
		to_chat(usr, "<span class='warning'>This ticket has already been converted!</span>", confidential=TRUE)
		return
	convert_ticket(T)

/datum/controller/subsystem/tickets/proc/other_ticket_system_staff_check()
	var/list/staff = staff_countup(other_ticket_permission)
	if(!staff[1])
		if(alert("Нет активных администраторов, чтобы ответить на тикет. Вы уверены что хотите перевести тикет?", "Уверены?", "Да", "Нет") != "Да")
			return FALSE
	return TRUE

/datum/controller/subsystem/tickets/proc/convert_ticket(datum/ticket/T)
	T.ticketState = TICKET_CLOSED
	T.ticket_converted = TRUE
	var/client/C = usr.client
	var/client/owner = get_client_by_ckey(T.client_ckey)
	to_chat_safe(owner, list("<span class='[span_class]'>[key_name_hidden(C)] перевёл ваш тикет в [other_ticket_name] тикет.</span>",\
									"<span class='[span_class]'>Be sure to use the correct type of help next time!</span>"), confidential=TRUE)
	message_staff("<span class='[span_class]'>[C] перевёл тикет под номером #[T.ticketNum] в [other_ticket_name] тикет.</span>")
	add_game_logs("[C] has converted ticket number [T.ticketNum] to a [other_ticket_name] ticket.")
	create_other_system_ticket(T)

/datum/controller/subsystem/tickets/proc/create_other_system_ticket(datum/ticket/T)
	var/client/C = get_client_by_ckey(T.client_ckey)
	SSmentor_tickets.newTicket(C, T.content, T.raw_title)

/datum/controller/subsystem/tickets/proc/autoRespond(N)
	if(!check_rights(rights_needed))
		return

	var/datum/ticket/T = allTickets[N]
	var/client/C = usr.client
	if((T.staffAssigned && T.staffAssigned != C) || (T.lastStaffResponse && T.lastStaffResponse != C) || ((T.ticketState != TICKET_OPEN) && (T.ticketState != TICKET_STALE))) //if someone took this ticket, is it the same admin who is autoresponding? if so, then skip the warning
		if(alert(usr, "[T.ticketState == TICKET_OPEN ? "Другой администратор уже разбирает этот тикет." : "Этот тикет уже закрыт или решён."] Вы точно хотите продолжить?", "Подтверждение", "Да", "Нет") != "Да")
			return
	T.assignStaff(C)

	var/response_phrases = list(
		"Спасибо" = "Спасибо, желаем вам удачного дня!",
		"Уже рассматриваем" = "Этот вопрос уже рассматривается, спасибо.",
		"Уже решено" = "Эта проблема уже решена.",
		"MentorHelp" = "Прошу перенаправьте этот вопрос в Mentorhelp, так как они лучше разбираются в подобных вопросах.",
		"Если ещё раз случится" = "Спасибо, дайте нам знать, если это продолжит происходить.",
		"Сообщите об ошибке" = "Чтобы сообщить об ошибке, пожалуйста перейдите в <a href='[CONFIG_GET(string/discordbugreporturl)]'>Discord</a>. Составьте баг-репорт согласно закрепленному сообщению в канале и отправьте. Если раунд всё ещё идёт, либо сохраните в текстовый файл, либо подождите пока раунд не закончится.",
		"Очистите кэш" = "Чтобы починить чёрный экран, зайдите в категорию 'Special Verbs' и нажмите 'Reload UI Resources'. Если это не помогло, очистите ваш BYOND-кэш (прилагаемая инструкция к 'Reload UI Resources'). Если и это не помогло, пожалуйста задействуйте AdminHelp ещё раз, написав, что вы уже это проходили." ,
		"IC-проблема" = "Это игровая (In Character, проблема между персонажами, а не между игроками) ситуация. Она не обрабатывается администраторами. Вы можете поговорить со службой безопасности, АВД, главой отдела, представителем Nanotrasen, или обратиться в любой другой соответствующий орган, находящийся в настоящее время на станции.",
		"Отказано" = "Отказано",
		"Мужайся" = "Мужайся",
		"Обжалование в Discord" = "Обжалование бана должно происходить в Discord. AdminHelp или личные сообщения администратору по поводу вашего бана скорее всего не решат эту проблему. Чтобы обжаловать ваш бан, пожалуйста, перейдите по адресу <a href='[CONFIG_GET(string/banappeals)]'>[CONFIG_GET(string/banappeals)]</a>"
		)

	var/sorted_responses = list()
	for(var/key in response_phrases)	//build a new list based on the short descriptive keys of the master list so we can send this as the input instead of the full paragraphs to the admin choosing which autoresponse
		sorted_responses += key

	var/message_key = input("Выберите авто-ответ. Это заменит тикет на решённый.", "Autoresponse") as null|anything in sortTim(sorted_responses, cmp = /proc/cmp_text_asc) //use sortTim and cmp_text_asc to sort alphabetically
	var/client/ticket_owner = get_client_by_ckey(T.client_ckey)
	switch(message_key)
		if(null) //they cancelled
			T.staffAssigned = initial(T.staffAssigned) //if they cancel we dont need to hold this ticket anymore
			return
		if("Отказано")
			if(!closeTicket(N))
				to_chat(C, "Невозможно закрыть тикет.", confidential=TRUE)
		if("Мужайся")
			C.man_up(returnClient(N))
			T.lastStaffResponse = "Автоматический ответ: [message_key]"
			resolveTicket(N)
			message_staff("[C] отправил автоматический ответ на тикет [ticket_owner] сообщением:<span class='adminticketalt'> [message_key]</span>")
			add_game_logs("[C] has auto responded to [ticket_owner]\'s adminhelp with: [response_phrases[message_key]]")
		if("Mentorhelp")
			convert_ticket(T)
		else
			var/msg_sound = sound('sound/effects/adminhelp.ogg')
			SEND_SOUND(returnClient(N), msg_sound)
			to_chat_safe(returnClient(N), "<span class='[span_class]'>[key_name_hidden(C)] is autoresponding with: <span/> <span class='adminticketalt'>[response_phrases[message_key]]</span>", confidential=TRUE)//for this we want the full value of whatever key this is to tell the player so we do response_phrases[message_key]
			message_staff("[C] has auto responded to [ticket_owner]\'s adminhelp with:<span class='adminticketalt'> [message_key]</span>") //we want to use the short named keys for this instead of the full sentence which is why we just do message_key
			T.lastStaffResponse = "Autoresponse: [message_key]"
			resolveTicket(N)
			add_game_logs("[C] has auto responded to [ticket_owner]\'s adminhelp with: [response_phrases[message_key]]")

//Set ticket state with key N to closed
/datum/controller/subsystem/tickets/proc/closeTicket(N)
	var/datum/ticket/T = allTickets[N]
	if(T.ticketState != TICKET_CLOSED)
		message_staff("<span class='[span_class]'>[usr.client] / ([usr]) закрыл [ticket_name] под номером [N]</span>")
		to_chat_safe(returnClient(N), close_messages, confidential=TRUE)
		T.ticketState = TICKET_CLOSED
		return TRUE

//Check if the user already has a ticket open and within the cooldown period.
/datum/controller/subsystem/tickets/proc/checkForOpenTicket(client/C)
	for(var/datum/ticket/T in allTickets)
		if(T.client_ckey == C.ckey && T.ticketState == TICKET_OPEN && (T.ticketCooldown > world.time))
			return T
	return FALSE

//Check if the user has ANY ticket not resolved or closed.
/datum/controller/subsystem/tickets/proc/checkForTicket(client/C)
	var/list/tickets = list()
	for(var/datum/ticket/T in allTickets)
		if(T.client_ckey == C.ckey && (T.ticketState == TICKET_OPEN || T.ticketState == TICKET_STALE))
			tickets += T
	if(tickets.len)
		return tickets
	return FALSE

//return the client of a ticket number
/datum/controller/subsystem/tickets/proc/returnClient(N)
	var/datum/ticket/T = allTickets[N]
	return get_client_by_ckey(T.client_ckey)

/datum/controller/subsystem/tickets/proc/assignStaffToTicket(client/C, N)
	var/datum/ticket/T = allTickets[N]
	if(T.staffAssigned != null && T.staffAssigned != C && alert("Тикет уже взят [T.staffAssigned.ckey]. Вы уверены, что хотите забрать его?", "Забрать тикет?", "Да", "Нет") != "Да")
		return FALSE
	T.assignStaff(C)
	return TRUE

//Single staff ticket

/datum/ticket
	/// Ticket number.
	var/ticketNum
	/// ckey of the client who opened the ticket.
	var/client_ckey
	/// Time the ticket was opened.
	var/timeOpened
	/// The initial message with links.
	var/title
	/// The title without URLs added.
	var/raw_title
	/// Content of the staff help.
	var/list/content
	/// Last staff member who responded.
	var/lastStaffResponse
	/// When the staff last responded.
	var/lastResponseTime
	/// The location the player was when they sent the ticket.
	var/locationSent
	/// The mob the player was controlling when they sent the ticket.
	var/mobControlled
	/// State of the ticket, open, closed, resolved etc.
	var/ticketState
	/// Has the ticket been converted to another type? (Mhelp to Ahelp, etc.)
	var/ticket_converted = FALSE
	/// When the ticket goes stale.
	var/timeUntilStale
	/// Cooldown before allowing the user to open another ticket.
	var/ticketCooldown
	/// Staff member who has assigned themselves to this ticket.
	var/client/staffAssigned

/datum/ticket/New(tit, raw_tit, cont, num)
	title = tit
	raw_title = raw_tit
	content = list()
	content += cont
	timeOpened = ROUND_TIME_TEXT()
	timeUntilStale = world.time + TICKET_TIMEOUT
	setCooldownPeriod()
	ticketNum = num
	ticketState = TICKET_OPEN

//Set the cooldown period for the ticket. The time when it's created plus the defined cooldown time.
/datum/ticket/proc/setCooldownPeriod()
	ticketCooldown = world.time + TICKET_DUPLICATE_COOLDOWN

//Set the last staff who responded as the client passed as an arguement.
/datum/ticket/proc/setLastStaffResponse(client/C)
	lastStaffResponse = C
	lastResponseTime = ROUND_TIME_TEXT()

//Return the ticket state as a colour coded text string.
/datum/ticket/proc/state2text()
	if(ticket_converted)
		return "<font color='yellow'>CONVERTED</font>"
	switch(ticketState)
		if(TICKET_OPEN)
			return "<font color='green'>OPEN</font>"
		if(TICKET_RESOLVED)
			return "<font color='blue'>RESOLVED</font>"
		if(TICKET_CLOSED)
			return "<font color='red'>CLOSED</font>"
		if(TICKET_STALE)
			return "<font color='orange'>STALE</font>"

//Assign the client passed to var/staffAsssigned
/datum/ticket/proc/assignStaff(client/C)
	if(!C)
		return
	staffAssigned = C
	return TRUE

/datum/ticket/proc/addResponse(client/C, msg)
	if(C.holder)
		setLastStaffResponse(C)
	msg = "[C]: [msg]"
	content += msg

/datum/ticket/proc/makeStale()
	ticketState = TICKET_STALE
	return ticketNum

/*

UI STUFF

*/

/datum/controller/subsystem/tickets/proc/returnUI(tab = TICKET_OPEN)
	set name = "Open Ticket Interface"
	set category = "Admin.Admin Tickets"

//dat
	var/trStyle = "border-top:2px solid; border-bottom:2px solid; padding-top: 5px; padding-bottom: 5px;"
	var/tdStyleleft = "border-top:2px solid; border-bottom:2px solid; width:150px; text-align:center;"
	var/tdStyle = "border-top:2px solid; border-bottom:2px solid;"
	var/datum/ticket/ticket
	var/dat = {"<!DOCTYPE html><meta charset="UTF-8">"}
	dat += "<head><style>.adminticket{border:2px solid}</style></head>"
	dat += "<body><h1>[ticket_system_name]</h1>"

	dat +="<a href='byond://?src=[UID()];refresh=1'>Refresh</a><br /><a href='byond://?src=[UID()];showopen=1'>Open Tickets</a><a href='byond://?src=[UID()];showresolved=1'>Resolved Tickets</a><a href='byond://?src=[UID()];showclosed=1'>Closed Tickets</a>"
	if(tab == TICKET_OPEN)
		dat += "<h2>Open Tickets</h2>"
	dat += "<table style='width:100%; border: 3px solid;'>"
	dat +="<tr style='[trStyle]'><th style='[tdStyleleft]'>Control</th><th style='[tdStyle]'>Ticket</th></tr>"
	if(tab == TICKET_OPEN)
		for(var/T in allTickets)
			ticket = T
			if(ticket.ticketState == TICKET_OPEN || ticket.ticketState == TICKET_STALE)
				dat += "<tr style='[trStyle]'><td style ='[tdStyleleft]'><a href='byond://?src=[UID()];resolve=[ticket.ticketNum]'>Resolve</a><a href='byond://?src=[UID()];details=[ticket.ticketNum]'>Details</a> <br /> #[ticket.ticketNum] ([ticket.timeOpened]) [ticket.ticketState == TICKET_STALE ? "<font color='red'><b>STALE</font>" : ""] </td><td style='[tdStyle]'><b>[ticket.title]</td></tr>"
			else
				continue
	else  if(tab == TICKET_RESOLVED)
		dat += "<h2>Resolved Tickets</h2>"
		for(var/T in allTickets)
			ticket = T
			if(ticket.ticketState == TICKET_RESOLVED)
				dat += "<tr style='[trStyle]'><td style ='[tdStyleleft]'><a href='byond://?src=[UID()];resolve=[ticket.ticketNum]'>Resolve</a><a href='byond://?src=[UID()];details=[ticket.ticketNum]'>Details</a> <br /> #[ticket.ticketNum] ([ticket.timeOpened]) </td><td style='[tdStyle]'><b>[ticket.title]</td></tr>"
			else
				continue
	else if(tab == TICKET_CLOSED)
		dat += "<h2>Closed Tickets</h2>"
		for(var/T in allTickets)
			ticket = T
			if(ticket.ticketState == TICKET_CLOSED)
				dat += "<tr style='[trStyle]'><td style ='[tdStyleleft]'><a href='byond://?src=[UID()];resolve=[ticket.ticketNum]'>Resolve</a><a href='byond://?src=[UID()];details=[ticket.ticketNum]'>Details</a> <br /> #[ticket.ticketNum] ([ticket.timeOpened]) </td><td style='[tdStyle]'><b>[ticket.title]</td></tr>"
			else
				continue

	dat += "</table>"
	dat += "<h1>Resolve All</h1>"
	if(ticket_system_name == "Mentor Tickets")
		dat += "<a href='byond://?src=[UID()];resolveall=1'>Resolve All Open Mentor Tickets</a></body>"
	else
		dat += "<a href='byond://?src=[UID()];resolveall=1'>Resolve All Open Admin Tickets</a></body>"

	return dat

/datum/controller/subsystem/tickets/proc/showUI(mob/user, tab)
	var/dat = {"<!DOCTYPE html><meta charset="UTF-8">"}
	dat += returnUI(tab)
	var/datum/browser/popup = new(user, ticket_system_name, ticket_system_name, 1400, 600)
	popup.set_content(dat)
	popup.open()

/datum/controller/subsystem/tickets/proc/showDetailUI(mob/user, ticketID)
	var/datum/ticket/T = allTickets[ticketID]
	var/status = "[T.state2text()]"

	var/dat = {"<meta charset="UTF-8"><h1>[ticket_system_name]</h1>"}

	dat +="<a href='byond://?src=[UID()];refresh=1'>Show All</a><a href='byond://?src=[UID()];refreshdetail=[T.ticketNum]'>Refresh</a>"

	dat += "<h2>Ticket #[T.ticketNum]</h2>"

	dat += "<h3>[T.client_ckey] / [T.mobControlled] opened this [ticket_name] at [T.timeOpened] at location [T.locationSent]</h3>"
	dat += "<h4>Ticket Status: [status]"
	dat += "<table style='width:950px; border: 3px solid;'>"
	dat += "<tr><td>[T.title]</td></tr>"

	if(T.content.len > 1)
		for(var/i = 2, i <= T.content.len, i++)
			dat += "<tr><td>[T.content[i]]</td></tr>"

	dat += "</table><br /><br />"
	dat += "<a href='byond://?src=[UID()];detailreopen=[T.ticketNum]'>Re-Open</a>[check_rights(rights_needed, 0) ? "<a href='byond://?src=[UID()];autorespond=[T.ticketNum]'>Auto</a>": ""]<a href='byond://?src=[UID()];detailresolve=[T.ticketNum]'>Resolve</a><br /><br />"

	if(!T.staffAssigned)
		dat += "No staff member assigned to this [ticket_name] - <a href='byond://?src=[UID()];assignstaff=[T.ticketNum]'>Take Ticket</a><br />"
	else
		dat += "[T.staffAssigned] is assigned to this Ticket. - <a href='byond://?src=[UID()];assignstaff=[T.ticketNum]'>Take Ticket</a> - <a href='byond://?src=[UID()];unassignstaff=[T.ticketNum]'>Unassign Ticket</a><br />"

	if(T.lastStaffResponse)
		dat += "<b>Last Staff response Response:</b> [T.lastStaffResponse] at [T.lastResponseTime]"
	else
		dat +="<font color='red'>No Staff Response</font>"

	dat += "<br /><br />"

	dat += "<a href='byond://?src=[UID()];detailclose=[T.ticketNum]'>Close Ticket</a>"
	dat += "<a href='byond://?src=[UID()];convert_ticket=[T.ticketNum]'>Convert Ticket</a>"

	var/datum/browser/popup = new(user, "[ticket_system_name]detail", "[ticket_system_name] #[T.ticketNum]", 1000, 600)
	popup.set_content(dat)
	popup.open()

/datum/controller/subsystem/tickets/proc/userDetailUI(mob/user)
//dat
	var/tickets = checkForTicket(user.client)
	var/dat = {"<!DOCTYPE html><meta charset="UTF-8">"}
	dat += "<h1>Ваши открытые [ticket_system_name]</h1>"
	dat += "<table>"
	for(var/datum/ticket/T in tickets)
		dat += "<tr><td><h2>Тикет #[T.ticketNum]</h2></td></tr>"
		for(var/i = 1, i <= T.content.len, i++)
			dat += "<tr><td>[T.content[i]]</td></tr>"
	dat += "</table>"

	var/datum/browser/popup = new(user, "[ticket_system_name]userticketsdetail", ticket_system_name, 1000, 600)
	popup.set_content(dat)
	popup.open()

//Sends a message to the target safely. If the target left the server it won't throw a runtime. Also accepts lists of text
/datum/controller/subsystem/tickets/proc/to_chat_safe(target, text, confidential = FALSE)
	if(!target)
		return FALSE
	if(istype(text, /list))
		for(var/T in text)
			to_chat(target, T, confidential = confidential)
	else
		to_chat(target, text, confidential = confidential)
	return TRUE

/**
 * Sends a message to the designated staff
 * Arguments:
 * msg - The message being send
 * alt - If an alternative prefix should be used or not. Defaults to TICKET_STAFF_MESSAGE_PREFIX
 * important - If the message is important. If TRUE it will ignore the CHAT_NO_TICKETLOGS preferences,
               send a sound and flash the window. Defaults to FALSE
 */
/datum/controller/subsystem/tickets/proc/message_staff(msg, prefix_type = TICKET_STAFF_MESSAGE_PREFIX, important = FALSE)
	switch(prefix_type)
		if(TICKET_STAFF_MESSAGE_ADMIN_CHANNEL)
			msg = "<span class='admin_channel'>ADMIN TICKET: [msg]</span>"
		if(TICKET_STAFF_MESSAGE_PREFIX)
			msg = "<span class='adminticket'><span class='prefix'>ADMIN TICKET:</span> [msg]</span>"
	message_adminTicket(msg, important)

/datum/controller/subsystem/tickets/Topic(href, href_list)

	if(href_list["refresh"])
		showUI(usr)
		return

	if(href_list["refreshdetail"])
		var/indexNum = text2num(href_list["refreshdetail"])
		showDetailUI(usr, indexNum)
		return

	if(href_list["showopen"])
		showUI(usr, TICKET_OPEN)
		return
	if(href_list["showresolved"])
		showUI(usr, TICKET_RESOLVED)
		return
	if(href_list["showclosed"])
		showUI(usr, TICKET_CLOSED)
		return

	if(href_list["details"])
		var/indexNum = text2num(href_list["details"])
		showDetailUI(usr, indexNum)
		return

	if(href_list["resolve"])
		var/indexNum = text2num(href_list["resolve"])
		if(resolveTicket(indexNum))
			showUI(usr)

	if(href_list["detailresolve"])
		var/indexNum = text2num(href_list["detailresolve"])
		if(resolveTicket(indexNum))
			showDetailUI(usr, indexNum)

	if(href_list["detailclose"])
		var/indexNum = text2num(href_list["detailclose"])
		if(!check_rights(close_rights))
			to_chat(usr, "<span class='warning'>Недостаточно прав чтобы закрыть тикет.</span>", confidential=TRUE)
			return
		if(alert("Вы уверены? Это отправит отрицательное сообщение.", "Уверены?", "Да","Нет") != "Да")
			return
		if(closeTicket(indexNum))
			showDetailUI(usr, indexNum)

	if(href_list["detailreopen"])
		var/indexNum = text2num(href_list["detailreopen"])
		if(openTicket(indexNum))
			showDetailUI(usr, indexNum)

	if(href_list["assignstaff"])
		var/indexNum = text2num(href_list["assignstaff"])
		takeTicket(indexNum)
		showDetailUI(usr, indexNum)

	if(href_list["unassignstaff"])
		var/indexNum = text2num(href_list["unassignstaff"])
		unassignTicket(indexNum)
		showDetailUI(usr, indexNum)

	if(href_list["autorespond"])
		var/indexNum = text2num(href_list["autorespond"])
		autoRespond(indexNum)

	if(href_list["convert_ticket"])
		var/indexNum = text2num(href_list["convert_ticket"])
		convert_to_other_ticket(indexNum)

	if(href_list["resolveall"])
		if(ticket_system_name == "Mentor Tickets")
			usr.client.resolveAllMentorTickets()
		else
			usr.client.resolveAllAdminTickets()

/datum/controller/subsystem/tickets/proc/takeTicket(var/index)
	if(assignStaffToTicket(usr.client, index))
		if(span_class == "mentorhelp")
			message_staff("<span class='[span_class]'>[usr.client] / ([usr]) взял [ticket_name] номер [index]</span>")
		else
			message_staff("<span class='admin_channel'>[usr.client] / ([usr]) взял [ticket_name] номер [index]</span>", TICKET_STAFF_MESSAGE_ADMIN_CHANNEL)
		to_chat_safe(returnClient(index), "<span class='[span_class]'>Ваш [ticket_name] обрабатывает [usr.client].</span>", confidential=TRUE)

/datum/controller/subsystem/tickets/proc/unassignTicket(index)
	var/datum/ticket/T = allTickets[index]
	if(T.staffAssigned != null && (T.staffAssigned == usr.client || alert("Тикет уже назначен [T.staffAssigned]. Вы хотите снять с тикета?","Снять с тикета","Нет","Да") == "Да"))
		T.staffAssigned = null
		to_chat_safe(returnClient(index), "<span class='[span_class]'>Ваш [ticket_name] больше не обрабатывают. Другой сотрудник скоро вам поможет.</span>", confidential=TRUE)
		if(span_class == "mentorhelp")
			message_staff("<span class='[span_class]'>[usr.client] / ([usr]) снят с тикета [ticket_name] номер [index]</span>")
		else
			message_staff("<span class='admin_channel'>[usr.client] / ([usr]) снят с тикета [ticket_name] номер [index]</span>", TICKET_STAFF_MESSAGE_ADMIN_CHANNEL)

/datum/controller/subsystem/tickets/can_vv_get(var_name)
	var/static/list/protected_vars = list(
		"allTickets"
	)
	if(!check_rights(R_ADMIN, FALSE, src) && (var_name in protected_vars))
		return FALSE
	return TRUE

#undef TICKET_STAFF_MESSAGE_ADMIN_CHANNEL
#undef TICKET_STAFF_MESSAGE_PREFIX
