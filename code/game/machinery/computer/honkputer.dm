/obj/machinery/computer/HONKputer
	name = "\improper HONKputer Mark I"
	desc = "Яркий жёлтый компьютер. Воспользуйтесь им, если уровень ХОНКА упал до критически низкого уровня!"
	icon = 'icons/obj/machines/HONKputer.dmi'
	icon_state = "honkputer"
	icon_keyboard = "key_honk"
	icon_screen = "honkcomms"
	light_color = LIGHT_COLOR_PINK
	req_access = list(ACCESS_CLOWN)
	circuit = /obj/item/circuitboard/HONKputer
	frame = /obj/structure/computerframe/HONKputer
	var/authenticated = 0
	var/message_cooldown = 0
	var/state = STATE_DEFAULT
	var/const/STATE_DEFAULT = 1

/obj/machinery/computer/HONKputer/process()
	if(..())
		src.updateDialog()

/obj/machinery/computer/HONKputer/Topic(href, href_list)
	if(..())
		return 1
	if(is_away_level(src.z))
		to_chat(usr, span_danger("Unable to establish a connection") + ": You're too far away from the station!")
		return
	usr.set_machine(src)

	if(!href_list["operation"])
		return
	switch(href_list["operation"])
		// main interface
		if("main")
			src.state = STATE_DEFAULT
		if("login")
			var/mob/M = usr
			var/obj/item/I = M.get_id_card()
			if(istype(I) && I.GetID())
				if(src.check_access(I.GetID()) || src.emagged == 1)
					authenticated = 1
		if("logout")
			authenticated = 0

		if("MessageHonkplanet")
			if(src.authenticated==1)
				if(message_cooldown)
					to_chat(usr, "Arrays recycling.  Please stand by.")
					return
				var/input = stripped_input(usr, "Please choose a message to transmit to your HONKbrothers on the homeworld. Transmission does not guarantee a response.", "To abort, send an empty message.", "")
				if(!input || !(usr in view(1,src)))
					return
				HONK_announce(input, usr)
				to_chat(usr, "Message transmitted.")
				add_game_logs("has made a HONKplanet announcement: [input]", usr)
				message_cooldown = 1
				spawn(6000)//10 minute cooldown
					message_cooldown = 0

	src.updateUsrDialog()

/obj/machinery/computer/HONKputer/emag_act(mob/user)
	if(!emagged)
		emagged = 1
		if(user)
			to_chat(user, "You scramble the login circuits, allowing anyone to use the console!")

/obj/machinery/computer/HONKputer/attack_hand(mob/user)
	if(..())
		return
	if(is_away_level(src.z))
		to_chat(user, span_danger("Unable to establish a connection") + ": You're too far away from the station!")
		return

	user.set_machine(src)
	var/dat = ""

	if(istype(user, /mob/living/silicon))
		to_chat(user, "This console is not networked to the rest of the grid.")
		return

	switch(src.state)
		if(STATE_DEFAULT)
			if(src.authenticated)
				dat += "<br> <a href='byond://?src=[UID()];operation=logout'>Log Out</a> "
				dat += "<br> <a href='byond://?src=[UID()];operation=MessageHonkplanet'>Send an emergency message to Honkplanet</a>"
			else
				dat += "<br> <a href='byond://?src=[UID()];operation=login'>Log In</a>"


	dat += "<br> [(src.state != STATE_DEFAULT) ? "<a href='byond://?src=[UID()];operation=main'>Main Menu</a><br>" : ""]<a href='byond://?src=[user.UID()];mach_close=honkputer'>Close</a>"
	var/datum/browser/popup = new(user, "honkputer", "HONKputer Interface", 400, 500)
	popup.set_content(dat)
	popup.open(TRUE)
	onclose(user, "honkputer")
