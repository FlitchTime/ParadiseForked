// Allows you to monitor messages that passes the server.
/obj/machinery/computer/message_monitor
	name = "message monitoring console"
	desc = "Используется для отслеживания сообщений экипажа, отправляемых через КПК. Его также можно использовать для просмотра сообщений Консоли Запросов."
	icon_screen = "comm_logs"
	light_color = LIGHT_COLOR_GREEN
	var/hack_icon = "tcboss"
	var/normal_icon = "comm_logs"
	circuit = /obj/item/circuitboard/message_monitor
	//Server linked to.
	var/obj/machinery/message_server/linkedServer = null
	//Messages - Saves me time if I want to change something.
	var/noserver = span_alert("ALERT: No server detected.")
	var/incorrectkey = span_warning("ALERT: Incorrect decryption key!")
	var/defaultmsg = span_notice("Welcome. Please select an option.")
	var/rebootmsg = span_warning("%$&(�: Critical %$$@ Error // !RestArting! <lOadiNg backUp iNput ouTput> - ?pLeaSe wAit!")
	//Computer properties
	var/screen = 0 		// 0 = Main menu, 1 = Message Logs, 2 = Hacked screen, 3 = Custom Message
	var/hacking = 0		// Is it being hacked into by the AI/Cyborg
	var/emag = 0		// When it is emagged.
	var/message = span_notice("System bootup complete. Please select an option.")	// The message that shows on the main menu.
	var/auth = 0 // Are they authenticated?
	var/optioncount = 8
	// Custom Message Properties
	var/customsender = "System Administrator"
	var/obj/item/pda/customrecepient = null
	var/customjob		= "Admin"
	var/custommessage 	= "This is a test, please ignore."

	light_color = LIGHT_COLOR_DARKGREEN

/obj/machinery/computer/message_monitor/laptop
	name = "message monitor laptop"
	icon_state = "laptop"
	icon_keyboard = "seclaptop_key"
	icon_screen = "seclaptop"
	normal_icon = "seclaptop"
	density = FALSE

/obj/machinery/computer/message_monitor/screwdriver_act(mob/user, obj/item/I)
	if(emag) //Stops people from just unscrewing the monitor and putting it back to get the console working again.
		to_chat(user, span_warning("It is too hot to mess with!"))
		return
	return ..()

/obj/machinery/computer/message_monitor/emag_act(mob/user)
	// Will create sparks and print out the console's password. You will then have to wait a while for the console to be back online.
	// It'll take more time if there's more characters in the password..
	if(!emag)
		if(!isnull(src.linkedServer))
			icon_screen = hack_icon // An error screen I made in the computers.dmi
			emag = 1
			screen = 2
			do_sparks(5, 0, src)
			var/obj/item/paper/monitorkey/MK = new/obj/item/paper/monitorkey
			MK.loc = src.loc
			playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, 1)
			// Will help make emagging the console not so easy to get away with.
			MK.info += "<br><br><span style='color: red;'>�%@%(*$%&(�&?*(%&�/{}</span>"
			update_icon()
			spawn(100*length(src.linkedServer.decryptkey))
				UnmagConsole()
				update_icon()
			message = rebootmsg
		else if(user)
			to_chat(user, span_notice("A no server error appears on the screen."))


/obj/machinery/computer/message_monitor/update_icon_state()
	if(emag || hacking)
		icon_screen = hack_icon
	else
		icon_screen = normal_icon
	..()


/obj/machinery/computer/message_monitor/Initialize()
	. = ..()
	//Is the server isn't linked to a server, and there's a server available, default it to the first one in the list.
	if(!linkedServer)
		if(GLOB.message_servers && GLOB.message_servers.len > 0)
			linkedServer = GLOB.message_servers[1]
	return

/obj/machinery/computer/message_monitor/attack_hand(var/mob/user as mob)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return
	//If the computer is being hacked or is emagged, display the reboot message.
	if(hacking || emag)
		message = rebootmsg
	var/dat = ""
	dat += "<center><h2>Message Monitor Console</h2></center><hr>"
	dat += "<center><h4><span style='color: blue;'> [message]</span></h4></center>"

	if(auth)
		dat += "<h4><a href='byond://?src=[UID()];auth=1'><span style='color: green;'>\[Authenticated\]</span></a>/"
		dat += " Server Power: <a href='byond://?src=[UID()];active=1'>[src.linkedServer && src.linkedServer.active ? "<span style='color: green;'>\[On\]</span>":"<span style='color: red;'>\[Off\]</span>"]</a></h4>"
	else
		dat += "<h4><a href='byond://?src=[UID()];auth=1'><span style='color: red;'>\[Unauthenticated\]</span></a>/"
		dat += " Server Power: <u>[src.linkedServer && src.linkedServer.active ? "<span style='color: green;'>\[On\]</span>":"<span style='color: green;'>\[Off\]</span>"]</u></h4>"

	if(hacking || emag)
		screen = 2
	else if(!auth || !linkedServer || (linkedServer.stat & (NOPOWER|BROKEN)))
		if(!linkedServer || (linkedServer.stat & (NOPOWER|BROKEN))) message = noserver
		screen = 0

	switch(screen)
		//Main menu
		if(0)
			// = TAB
			var/i = 0
			dat += "<dd><a href='byond://?src=[UID()];find=1'>[++i]. Link To A Server</a></dd>"
			if(auth)
				if(!linkedServer || (linkedServer.stat & (NOPOWER|BROKEN)))
					dat += "<dd><a>ERROR: Server not found!</a><br></dd>"
				else
					dat += "<dd><a href='byond://?src=[UID()];view=1'>[++i]. View Message Logs </a><br></dd>"
					dat += "<dd><a href='byond://?src=[UID()];viewr=1'>[++i]. View Request Console Logs </a></br></dd>"
					dat += "<dd><a href='byond://?src=[UID()];clear=1'>[++i]. Clear Message Logs</a><br></dd>"
					dat += "<dd><a href='byond://?src=[UID()];clearr=1'>[++i]. Clear Request Console Logs</a><br></dd>"
					dat += "<dd><a href='byond://?src=[UID()];pass=1'>[++i]. Set Custom Key</a><br></dd>"
					dat += "<dd><a href='byond://?src=[UID()];msg=1'>[++i]. Send Admin Message</a><br></dd>"
			else
				for(var/n = ++i; n <= optioncount; n++)
					dat += "<dd><span style='color: blue;'>[n]. ---------------</span><br></dd>"
			if((isAI(user) || isrobot(user)) && (user.mind.special_role && user.mind.is_original_mob(user)))
				//Malf/Traitor AIs can bruteforce into the system to gain the Key.
				dat += "<dd><a href='byond://?src=[UID()];hack=1'><i><span style='color: red;'>*&@#. Bruteforce Key</span></i></a><br></dd>"
			else
				dat += "<br>"

			//Bottom message
			if(!auth)
				dat += "<br><hr><dd>[span_notice("Please authenticate with the server in order to show additional options.")]</dd>"
			else
				dat += "<br><hr><dd>[span_warning("Reg, #514 forbids sending messages containing Erotic Rendering Properties.")]</dd>"

		//Message Logs
		if(1)
			var/index = 0
			//var/recipient = "Unspecified" //name of the person
			//var/sender = "Unspecified" //name of the sender
			//var/message = "Blank" //transferred message
			dat += "<center><a href='byond://?src=[UID()];back=1'>Back</a> - <a href='byond://?src=[UID()];refresh=1'>Refresh</a></center><hr>"
			dat += "<table border='1' width='100%'><tr><th width = '5%'>X</th><th width='15%'>Sender</th><th width='15%'>Recipient</th><th width='300px' style='word-wrap: break-word;'>Message</th></tr>"
			for(var/datum/data_pda_msg/pda in src.linkedServer.pda_msgs)
				index++
				if(index > 3000)
					break
				// Del - Sender   - Recepient - Message
				// X   - Al Green - Your Mom  - WHAT UP!?
				dat += "<tr><td width = '5%'><center><a href='byond://?src=[UID()];delete=\ref[pda]' style='color: rgb(255,0,0)'>X</a></center></td><td width='15%'>[pda.sender]</td><td width='15%'>[pda.recipient]</td><td width='300px'>[pda.message]</td></tr>"
			dat += "</table>"
		//Hacking screen.
		if(2)
			if(istype(user, /mob/living/silicon/ai) || istype(user, /mob/living/silicon/robot))
				dat += "Brute-forcing for server key.<br> It will take 20 seconds for every character that the password has."
				dat += "In the meantime, this console can reveal your true intentions if you let someone access it. Make sure no humans enter the room during that time."
			else
				//It's the same message as the one above but in binary. Because robots understand binary and humans don't... well I thought it was clever.
				dat += {"01000010011100100111010101110100011001010010110<br>
				10110011001101111011100100110001101101001011011100110011<br>
				10010000001100110011011110111001000100000011100110110010<br>
				10111001001110110011001010111001000100000011010110110010<br>
				10111100100101110001000000100100101110100001000000111011<br>
				10110100101101100011011000010000001110100011000010110101<br>
				10110010100100000001100100011000000100000011100110110010<br>
				10110001101101111011011100110010001110011001000000110011<br>
				00110111101110010001000000110010101110110011001010111001<br>
				00111100100100000011000110110100001100001011100100110000<br>
				10110001101110100011001010111001000100000011101000110100<br>
				00110000101110100001000000111010001101000011001010010000<br>
				00111000001100001011100110111001101110111011011110111001<br>
				00110010000100000011010000110000101110011001011100010000<br>
				00100100101101110001000000111010001101000011001010010000<br>
				00110110101100101011000010110111001110100011010010110110<br>
				10110010100101100001000000111010001101000011010010111001<br>
				10010000001100011011011110110111001110011011011110110110<br>
				00110010100100000011000110110000101101110001000000111001<br>
				00110010101110110011001010110000101101100001000000111100<br>
				10110111101110101011100100010000001110100011100100111010<br>
				10110010100100000011010010110111001110100011001010110111<br>
				00111010001101001011011110110111001110011001000000110100<br>
				10110011000100000011110010110111101110101001000000110110<br>
				00110010101110100001000000111001101101111011011010110010<br>
				10110111101101110011001010010000001100001011000110110001<br>
				10110010101110011011100110010000001101001011101000010111<br>
				00010000001001101011000010110101101100101001000000111001<br>
				10111010101110010011001010010000001101110011011110010000<br>
				00110100001110101011011010110000101101110011100110010000<br>
				00110010101101110011101000110010101110010001000000111010<br>
				00110100001100101001000000111001001101111011011110110110<br>
				10010000001100100011101010111001001101001011011100110011<br>
				10010000001110100011010000110000101110100001000000111010<br>
				001101001011011010110010100101110"}

		//Fake messages
		if(3)
			dat += "<center><a href='byond://?src=[UID()];back=1'>Back</a> - <a href='byond://?src=[UID()];Reset=1'>Reset</a></center><hr>"

			dat += {"<table border='1' width='100%'>
					<tr><td width='20%'><a href='byond://?src=[UID()];select=Sender'>Sender</a></td>
					<td width='20%'><a href='byond://?src=[UID()];select=RecJob'>Sender's Job</a></td>
					<td width='20%'><a href='byond://?src=[UID()];select=Recepient'>Recipient</a></td>
					<td width='300px' word-wrap: break-word><a href='byond://?src=[UID()];select=Message'>Message</a></td></tr>"}
				//Sender  - Sender's Job  - Recepient - Message
				//Al Green- Your Dad	  - Your Mom  - WHAT UP!?

			dat += {"<tr><td width='20%'>[customsender]</td>
			<td width='20%'>[customjob]</td>
			<td width='20%'>[customrecepient ? customrecepient.owner : "NONE"]</td>
			<td width='300px'>[custommessage]</td></tr>"}
			dat += "</table><br><center><a href='byond://?src=[UID()];select=Send'>Send</a>"

		//Request Console Logs
		if(4)

			var/index = 0
			/* 	data_rc_msg
				X												 - 5%
				var/rec_dpt = "Unspecified" //name of the person - 15%
				var/send_dpt = "Unspecified" //name of the sender- 15%
				var/message = "Blank" //transferred message		 - 300px
				var/stamp = "Unstamped"							 - 15%
				var/id_auth = "Unauthenticated"					 - 15%
				var/priority = "Normal"							 - 10%
			*/
			dat += "<center><a href='byond://?src=[UID()];back=1'>Back</a> - <a href='byond://?src=[UID()];refresh=1'>Refresh</a></center><hr>"
			dat += {"<table border='1' width='100%'><tr><th width = '5%'>X</th><th width='15%'>Sending Dep.</th><th width='15%'>Receiving Dep.</th>
			<th width='300px' style='word-wrap: break-word;'>Message</th><th width='15%'>Stamp</th><th width='15%'>ID Auth.</th><th width='15%'>Priority.</th></tr>"}
			for(var/datum/data_rc_msg/rc in src.linkedServer.rc_msgs)
				index++
				if(index > 3000)
					break
				// Del - Sender   - Recepient - Message
				// X   - Al Green - Your Mom  - WHAT UP!?
				dat += {"<tr><td width = '5%'><center><a href='byond://?src=[UID()];deleter=\ref[rc]' style='color: rgb(255,0,0)'>X</a></center></td><td width='15%'>[rc.send_dpt]</td>
				<td width='15%'>[rc.rec_dpt]</td><td width='300px'>[rc.message]</td><td width='15%'>[rc.stamp]</td><td width='15%'>[rc.id_auth]</td><td width='15%'>[rc.priority]</td></tr>"}
			dat += "</table>"
	message = defaultmsg
	var/datum/browser/popup = new(user, "message", "Message Monitor Console", 700, 700)
	popup.set_content(dat)
	popup.open(TRUE)
	onclose(user, "message")
	return

/obj/machinery/computer/message_monitor/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/message_monitor/proc/BruteForce(mob/user as mob)
	if(isnull(linkedServer))
		to_chat(user, span_warning("Could not complete brute-force: Linked Server Disconnected!"))
	else
		var/currentKey = src.linkedServer.decryptkey
		to_chat(user, span_warning("Brute-force completed! The key is '[currentKey]'."))
	src.hacking = 0
	src.icon_screen = normal_icon
	src.screen = 0 // Return the screen back to normal

/obj/machinery/computer/message_monitor/proc/UnmagConsole()
	src.icon_screen = normal_icon
	src.emag = 0

/obj/machinery/computer/message_monitor/proc/ResetMessage()
	customsender 	= "System Administrator"
	customrecepient = null
	custommessage 	= "This is a test, please ignore."
	customjob 		= "Admin"

/obj/machinery/computer/message_monitor/Topic(href, href_list)
	if(..(href, href_list))
		return 1
	if((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		//Authenticate
		if(href_list["auth"])
			if(auth)
				auth = 0
				screen = 0
			else
				var/dkey = trim(clean_input("Please enter the decryption key."))
				if(dkey && dkey != "")
					if(src.linkedServer.decryptkey == dkey)
						auth = 1
					else
						message = incorrectkey

		//Turn the server on/off.
		if(href_list["active"])
			if(auth) linkedServer.active = !linkedServer.active
		//Find a server
		if(href_list["find"])
			if(GLOB.message_servers && GLOB.message_servers.len > 1)
				src.linkedServer = input(usr,"Please select a server.", "Select a server.", null) as null|anything in GLOB.message_servers
				message = span_alert("NOTICE: Server selected.")
			else if(GLOB.message_servers && GLOB.message_servers.len > 0)
				linkedServer = GLOB.message_servers[1]
				message = span_notice("NOTICE: Only Single Server Detected - Server selected.")
			else
				message = noserver

		//View the logs - KEY REQUIRED
		if(href_list["view"])
			if(src.linkedServer == null || (src.linkedServer.stat & (NOPOWER|BROKEN)))
				message = noserver
			else
				if(auth)
					src.screen = 1

		//Clears the logs - KEY REQUIRED
		if(href_list["clear"])
			if(!linkedServer || (src.linkedServer.stat & (NOPOWER|BROKEN)))
				message = noserver
			else
				if(auth)
					src.linkedServer.pda_msgs = list()
					message = span_notice("NOTICE: Logs cleared.")
		//Clears the request console logs - KEY REQUIRED
		if(href_list["clearr"])
			if(!linkedServer || (src.linkedServer.stat & (NOPOWER|BROKEN)))
				message = noserver
			else
				if(auth)
					src.linkedServer.rc_msgs = list()
					message = span_notice("NOTICE: Logs cleared.")
		//Change the password - KEY REQUIRED
		if(href_list["pass"])
			if(!linkedServer || (src.linkedServer.stat & (NOPOWER|BROKEN)))
				message = noserver
			else
				if(auth)
					var/dkey = trim(clean_input("Please enter the decryption key."))
					if(dkey && dkey != "")
						if(src.linkedServer.decryptkey == dkey)
							var/newkey = trim(input(usr,"Please enter the new key (3 - 16 characters max):"))
							if(length(newkey) <= 3)
								message = span_notice("NOTICE: Decryption key too short!")
							else if(length(newkey) > 16)
								message = span_notice("NOTICE: Decryption key too long!")
							else if(newkey && newkey != "")
								src.linkedServer.decryptkey = newkey
							message = span_notice("NOTICE: Decryption key set.")
						else
							message = incorrectkey

		//Hack the Console to get the password
		if(href_list["hack"])
			if((isAI(usr) || isrobot(usr)) && (usr.mind.special_role && usr.mind.is_original_mob(usr)))
				src.hacking = 1
				src.screen = 2
				src.icon_screen = hack_icon
				//Time it takes to bruteforce is dependant on the password length.
				spawn(100*length(src.linkedServer.decryptkey))
					if(src && src.linkedServer && usr)
						BruteForce(usr)
		//Delete the log.
		if(href_list["delete"])
			//Are they on the view logs screen?
			if(screen == 1)
				if(!linkedServer || (src.linkedServer.stat & (NOPOWER|BROKEN)))
					message = noserver
				else //if(istype(href_list["delete"], /datum/data_pda_msg))
					src.linkedServer.pda_msgs -= locate(href_list["delete"])
					message = span_notice("NOTICE: Log Deleted!")
		//Delete the request console log.
		if(href_list["deleter"])
			//Are they on the view logs screen?
			if(screen == 4)
				if(!linkedServer || (src.linkedServer.stat & (NOPOWER|BROKEN)))
					message = noserver
				else //if(istype(href_list["delete"], /datum/data_pda_msg))
					src.linkedServer.rc_msgs -= locate(href_list["deleter"])
					message = span_notice("NOTICE: Log Deleted!")
		//Create a custom message
		if(href_list["msg"])
			if(src.linkedServer == null || (src.linkedServer.stat & (NOPOWER|BROKEN)))
				message = noserver
			else
				if(auth)
					src.screen = 3
		//Fake messaging selection - KEY REQUIRED
		if(href_list["select"])
			if(src.linkedServer == null || (src.linkedServer.stat & (NOPOWER|BROKEN)))
				message = noserver
				screen = 0
			else
				switch(href_list["select"])

					//Reset
					if("Reset")
						ResetMessage()

					//Select Your Name
					if("Sender")
						customsender 	= clean_input("Please enter the sender's name.")

					//Select Receiver
					if("Recepient")
						//Get out list of viable PDAs
						var/list/obj/item/pda/sendPDAs = list()
						for(var/obj/item/pda/P in GLOB.PDAs)
							var/datum/data/pda/app/messenger/PM = P.find_program(/datum/data/pda/app/messenger)

							if(!PM || !PM.can_receive())
								continue
							sendPDAs += P
						if(GLOB.PDAs && GLOB.PDAs.len > 0)
							customrecepient = tgui_input_list(usr, "Select a PDA from the list.", items = sortAtom(sendPDAs))
						else
							customrecepient = null

					//Enter custom job
					if("RecJob")
						customjob	 	= clean_input("Please enter the sender's job.")

					//Enter message
					if("Message")
						custommessage	= clean_input("Please enter your message.")
						custommessage	= sanitize(copytext_char(custommessage, 1, MAX_MESSAGE_LEN))

					//Send message
					if("Send")
						if(isnull(customsender) || customsender == "")
							customsender = "UNKNOWN"

						if(isnull(customrecepient))
							message = span_notice("NOTICE: No recepient selected!")
							return src.attack_hand(usr)

						if(isnull(custommessage) || custommessage == "")
							message = span_notice("NOTICE: No message entered!")
							return src.attack_hand(usr)

						var/datum/data/pda/app/messenger/recipient_messenger = customrecepient.find_program(/datum/data/pda/app/messenger)

						if(!recipient_messenger)
							message = span_warning("ERROR: Message could not be transmitted!")
							return src.attack_hand(usr)

						var/obj/item/pda/PDARec = null
						for(var/obj/item/pda/P in GLOB.PDAs)
							var/datum/data/pda/app/messenger/PM = P.find_program(/datum/data/pda/app/messenger)

							if(!PM || !PM.can_receive())
								continue
							if(P.owner == customsender)
								PDARec = P
								break
						//Sender isn't faking as someone who exists
						if(isnull(PDARec))
							src.linkedServer.send_pda_message("[customrecepient.owner]", "[customsender]","[custommessage]")
							recipient_messenger.notify("<b>Message from [customsender] ([customjob]), </b>\"[custommessage]\" (<a href='byond://?src=[UID()];choice=Message;target=\ref[src]'>Reply</a>)")
							log_pda("(PDA: [customsender]) sent \"[custommessage]\" to [customrecepient.owner]", usr)
						//Sender is faking as someone who exists
						else
							src.linkedServer.send_pda_message("[customrecepient.owner]", "[PDARec.owner]","[custommessage]")
							recipient_messenger.tnote.Add(list(list("sent" = 0, "owner" = "[PDARec.owner]", "job" = "[customjob]", "message" = "[custommessage]", "target" ="\ref[PDARec]")))

							if(!recipient_messenger.conversations.Find("\ref[PDARec]"))
								recipient_messenger.conversations.Add("\ref[PDARec]")

							recipient_messenger.notify("<b>Message from [PDARec.owner] ([customjob]), </b>\"[custommessage]\" (<a href='byond://?src=[recipient_messenger.UID()];choice=Message;target=\ref[PDARec]'>Reply</a>)")
							log_pda("(PDA: [PDARec.owner]) sent \"[custommessage]\" to [customrecepient.owner]", usr)
						var/log_message = "sent PDA message \"[custommessage]\" using [src] as [customsender] ([customjob])"
						var/receiver
						if(ishuman(customrecepient.loc))
							receiver = customrecepient.loc
							log_message = "[log_message] to [customrecepient]"
						else
							receiver = customrecepient
							log_message = "[log_message] (no holder)"
						add_misc_logs(usr, "[log_message], [receiver]")
						//Finally..
						ResetMessage()

		//Request Console Logs - KEY REQUIRED
		if(href_list["viewr"])
			if(src.linkedServer == null || (src.linkedServer.stat & (NOPOWER|BROKEN)))
				message = noserver
			else
				if(auth)
					src.screen = 4

//			to_chat(usr, href_list["select"])

		if(href_list["back"])
			src.screen = 0

	return src.attack_hand(usr)


/obj/item/paper/monitorkey
	name = "Monitor Decryption Key"


/obj/item/paper/monitorkey/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD


/obj/item/paper/monitorkey/LateInitialize()
	for(var/obj/machinery/message_server/server as anything in GLOB.message_servers)
		if(!isnull(server.decryptkey))
			info = "<center><h2>Daily Key Reset</h2></center>\n\t<br>The new message monitor key is '[server.decryptkey]'.<br>Please keep this a secret and away from the clown.<br>If necessary, change the password to a more secure one."
			info_links = info
			update_icon()
			break

/obj/item/paper/rnd_logs_key
	name = "RnD logs Decryption Key"

/obj/item/paper/rnd_logs_key/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/item/paper/rnd_logs_key/LateInitialize()
	var/obj/machinery/r_n_d/server/located_server = locate() in GLOB.machines
	if(!located_server)
		return
	var/decryption_key = located_server.logs_decryption_key
	info = "<center><h2>RnD logs Access key</h2></center>\n\t<br>The new RnD logs access key is \"[decryption_key]\"."
	info_links = info
	update_icon()

