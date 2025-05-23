/obj/machinery/r_n_d/server
	name = "R&D Server"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "server"
	base_icon_state = "server"
	var/datum/research/files
	var/health = 100
	var/list/id_with_upload = list()		//List of R&D consoles with upload to server access.
	var/list/id_with_download = list()	//List of R&D consoles with download from server access.
	var/id_with_upload_string = ""		//String versions for easy editing in map editor.
	var/id_with_download_string = ""
	var/server_id = 0
	var/heat_gen = 100
	var/heating_power = 40000
	var/delay = 10
	req_access = list(ACCESS_RD) //Only the R&D can change server settings.
	var/plays_sound = 0
	var/syndicate = 0 //добавленный для синдибазы флаг
	var/list/usage_logs
	var/list/logs_for_logs_clearing
	var/static/logs_decryption_key = null

/obj/machinery/r_n_d/server/New()
	..()
	if(!logs_decryption_key)
		logs_decryption_key = GenerateKey()
	if(is_taipan(z))
		syndicate = 1
		req_access = list(ACCESS_SYNDICATE_RESEARCH_DIRECTOR)
		icon_state = "syndie_server"
		base_icon_state = "syndie_server"
	component_parts = list()
	component_parts += new /obj/item/circuitboard/rdserver(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stack/cable_coil(null,1)
	component_parts += new /obj/item/stack/cable_coil(null,1)
	RefreshParts()
	initialize_serv() //Agouri // fuck you agouri

/obj/machinery/r_n_d/server/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/rdserver(null)
	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)
	component_parts += new /obj/item/stack/cable_coil(null,1)
	component_parts += new /obj/item/stack/cable_coil(null,1)
	RefreshParts()

/obj/machinery/r_n_d/server/Destroy()
	griefProtection()
	return ..()

/obj/machinery/r_n_d/server/RefreshParts()
	var/tot_rating = 0
	for(var/obj/item/stock_parts/SP in src)
		tot_rating += SP.rating
	heat_gen /= max(1, tot_rating)

/obj/machinery/r_n_d/server/proc/initialize_serv()
	if(!files)
		files = new /datum/research(src)
	var/list/temp_list
	if(!id_with_upload.len)
		temp_list = list()
		temp_list = splittext(id_with_upload_string, ";")
		for(var/N in temp_list)
			id_with_upload += text2num(N)
	if(!id_with_download.len)
		temp_list = list()
		temp_list = splittext(id_with_download_string, ";")
		for(var/N in temp_list)
			id_with_download += text2num(N)

/obj/machinery/r_n_d/server/process()
	if(prob(3) && plays_sound)
		playsound(loc, "computer_ambience", 50, 1)

	var/datum/gas_mixture/environment = loc.return_air()
	switch(environment.temperature)
		if(0 to T0C)
			health = min(100, health + 1)
		if(T0C to (T20C + 20))
			health = clamp(health, 0, 100)
		if((T20C + 20) to INFINITY)
			health = max(0, health - 1)
	if(health <= 0)
		/*griefProtection() This seems to get called twice before running any code that deletes/damages the server or it's files anwyay.
							refreshParts and the hasReq procs that get called by this are laggy and do not need to be called by every server on the map every tick */
		var/updateRD = 0
		files.known_designs = list()
		for(var/v in files.known_tech)
			var/datum/tech/T = files.known_tech[v]
			// Slowly decrease research if health drops below 0
			if(prob(1))
				updateRD++
				T.level--
		if(updateRD)
			files.RefreshResearch()
	if(delay)
		delay--
	else
		produce_heat(heat_gen)
		delay = initial(delay)

/obj/machinery/r_n_d/server/emp_act(severity)
	griefProtection()
	..()


/obj/machinery/r_n_d/server/ex_act(severity)
	griefProtection()
	return ..()

/obj/machinery/r_n_d/server/blob_act(obj/structure/blob/B)
	griefProtection()
	return ..()

// Backup files to CentComm to help admins recover data after griefer attacks
/obj/machinery/r_n_d/server/proc/griefProtection()
	for(var/obj/machinery/r_n_d/server/centcom/C in GLOB.machines)
		files.push_data(C.files)

/obj/machinery/r_n_d/server/proc/produce_heat(heat_amt)
	if(!(stat & (NOPOWER|BROKEN))) // Blatantly stolen from space heater.
		var/turf/simulated/L = loc
		if(istype(L))
			var/datum/gas_mixture/env = L.return_air()
			if(env.temperature < (heat_amt+T0C))

				var/transfer_moles = 0.25 * env.total_moles()

				var/datum/gas_mixture/removed = env.remove(transfer_moles)

				if(removed)

					var/heat_capacity = removed.heat_capacity()
					if(heat_capacity == 0 || heat_capacity == null)
						heat_capacity = 1
					removed.temperature = min((removed.temperature*heat_capacity + heating_power)/heat_capacity, 1000)

				env.merge(removed)
				air_update_turf()


/obj/machinery/r_n_d/server/attackby(obj/item/I, mob/user, params)
	if(shocked && shock(user, 50))
		add_fingerprint(user)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(user.a_intent == INTENT_HARM)
		return ..()

	if(exchange_parts(user, I))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/machinery/r_n_d/server/screwdriver_act(mob/living/user, obj/item/I)
	if(shocked && shock(user, 50))
		add_fingerprint(user)
		return TRUE
	. = default_deconstruction_screwdriver(user, "[base_icon_state]_o", base_icon_state, I)


/obj/machinery/r_n_d/server/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(shocked && shock(user, 50))
		add_fingerprint(user)
		return .
	if(!panel_open)
		add_fingerprint(user)
		to_chat(user, span_warning("Open the maintenance panel first."))
		return .
	griefProtection()
	default_deconstruction_crowbar(user, I)


/obj/machinery/r_n_d/server/attack_hand(mob/user)
	if(..())
		return TRUE

	if(disabled)
		return

	if(shocked)
		add_fingerprint(user)
		shock(user,50)
	return

/obj/machinery/r_n_d/server/proc/add_usage_log(mob/user, datum/design/built_design, obj/machinery/r_n_d/machine)
	var/time_created = station_time_timestamp()
	var/user_name = user.name
	var/user_job = "no job"
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		user_name = human_user.get_authentification_name()
		user_job = human_user.get_assignment()
	var/blueprint_name = built_design.name
	var/used_machine = machine.name

	LAZYINITLIST(usage_logs)
	usage_logs.len++
	usage_logs[usage_logs.len] = list(time_created, user_name, user_job, blueprint_name, used_machine)

/obj/machinery/r_n_d/server/proc/clear_logs(mob/user)
	if(!LAZYLEN(usage_logs))
		return
	var/time_cleared = station_time_timestamp()
	var/user_name = user.name
	var/user_job = "no job"
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		user_name = human_user.get_authentification_name()
		user_job = human_user.get_assignment()

	LAZYINITLIST(logs_for_logs_clearing)
	logs_for_logs_clearing.len++
	logs_for_logs_clearing[logs_for_logs_clearing.len] = list(time_cleared, user_name, user_job)

	LAZYCLEARLIST(usage_logs)

/obj/machinery/r_n_d/server/centcom
	name = "CentComm. Central R&D Database"
	server_id = -1

/obj/machinery/r_n_d/server/centcom/Initialize()
	. = ..()
	var/list/no_id_servers = list()
	var/list/server_ids = list()
	for(var/obj/machinery/r_n_d/server/S in GLOB.machines)
		switch(S.server_id)
			if(-1)
				continue
			if(0)
				no_id_servers += S
			else
				server_ids += S.server_id

	for(var/obj/machinery/r_n_d/server/S in no_id_servers)
		var/num = 1
		while(!S.server_id)
			if(num in server_ids)
				num++
			else
				S.server_id = num
				server_ids += num
		no_id_servers -= S

/obj/machinery/r_n_d/server/centcom/process()
	return PROCESS_KILL	//don't need process()


/obj/machinery/computer/rdservercontrol
	name = "\improper R&D server controller"
	icon_screen = "rdcomp"
	icon_keyboard = "rd_key"
	light_color = LIGHT_COLOR_FADEDPURPLE
	circuit = /obj/item/circuitboard/rdservercontrol
	var/screen = 0
	var/obj/machinery/r_n_d/server/temp_server
	var/list/servers = list()
	var/list/consoles = list()
	var/badmin = 0
	var/syndicate = 0 //добавленный для синдибазы флаг

/obj/machinery/computer/rdservercontrol/Initialize()
	. = ..()
	if(is_taipan(z))
		syndicate = 1
		req_access = list(ACCESS_SYNDICATE_RESEARCH_DIRECTOR)

/obj/machinery/computer/rdservercontrol/Topic(href, href_list)
	if(..())
		return

	add_fingerprint(usr)
	usr.set_machine(src)
	if(!src.allowed(usr) && !emagged)
		to_chat(usr, "<span class='warning'>You do not have the required access level</span>")
		return

	if(href_list["main"])
		screen = 0

	else if(href_list["access"] || href_list["data"] || href_list["transfer"] || href_list["logs"])
		temp_server = null
		consoles = list()
		servers = list()
		for(var/obj/machinery/r_n_d/server/S in GLOB.machines)
			if(S.server_id == text2num(href_list["access"]) || S.server_id == text2num(href_list["data"]) || S.server_id == text2num(href_list["logs"]) || S.server_id == text2num(href_list["transfer"]))
				temp_server = S
				break
		if(href_list["access"])
			screen = 1
			for(var/obj/machinery/computer/rdconsole/C in GLOB.machines)
				if(C.sync)
					consoles += C
		else if(href_list["data"])
			screen = 2
		else if(href_list["logs"])
			var/awaiting_input = input(usr, "Please input access key", "Security check") as text|null
			if(awaiting_input != temp_server.logs_decryption_key)
				return
			screen = 3
		else if(href_list["transfer"])
			screen = 4
			for(var/obj/machinery/r_n_d/server/S in GLOB.machines)
				if(S == src)
					continue
				servers += S

	else if(href_list["upload_toggle"])
		var/num = text2num(href_list["upload_toggle"])
		if(num in temp_server.id_with_upload)
			temp_server.id_with_upload -= num
		else
			temp_server.id_with_upload += num

	else if(href_list["download_toggle"])
		var/num = text2num(href_list["download_toggle"])
		if(num in temp_server.id_with_download)
			temp_server.id_with_download -= num
		else
			temp_server.id_with_download += num

	else if(href_list["reset_tech"])
		var/choice = tgui_alert(usr, "Technology Data Reset", "Are you sure you want to reset this technology to its default data? Data lost cannot be recovered.", list("Continue", "Cancel"))
		if(choice == "Continue")
			for(var/I in temp_server.files.known_tech)
				var/datum/tech/T = temp_server.files.known_tech[I]
				if(T.id == href_list["reset_tech"])
					T.level = 1
					break
		temp_server.files.RefreshResearch()

	else if(href_list["reset_design"])
		var/choice = tgui_alert(usr, "Design Data Deletion", "Are you sure you want to blacklist this design? Ensure you sync servers after this decision.", list("Continue", "Cancel"))
		if(choice == "Continue")
			for(var/I in temp_server.files.known_designs)
				var/datum/design/D = temp_server.files.known_designs[I]
				if(D.id == href_list["reset_design"])
					temp_server.files.known_designs -= D.id
					break
		temp_server.files.RefreshResearch()

	else if(href_list["clear_logs"])
		temp_server.clear_logs(usr)

	updateUsrDialog()
	return

/obj/machinery/computer/rdservercontrol/attack_hand(mob/user as mob)
	if(stat & (BROKEN|NOPOWER))
		return
	if(..())
		return TRUE
	add_fingerprint(user)
	user.set_machine(src)
	var/dat = ""

	switch(screen)
		if(0) //Main Menu
			dat += "Connected Servers:<br><br>"

			for(var/obj/machinery/r_n_d/server/S in GLOB.machines)
				if(istype(S, /obj/machinery/r_n_d/server/centcom) && !badmin)
					continue
				if(S.syndicate != syndicate) // Флаг в действии
					continue
				dat += "[S.name] || "
				dat += "<a href='byond://?src=[UID()];access=[S.server_id]'>Access Rights</a> | "
				dat += "<a href='byond://?src=[UID()];data=[S.server_id]'>Data Management</a> | "
				dat += "<a href='byond://?src=[UID()];logs=[S.server_id]'>Logs</a>"
				if(badmin)
					dat += " | <a href='byond://?src=[UID()];transfer=[S.server_id]'>Server-to-Server Transfer</a>"
				dat += "<br>"

		if(1) //Access rights menu
			dat += "[temp_server.name] Access Rights<br><br>"
			dat += "Consoles with Upload Access<br>"
			for(var/obj/machinery/computer/rdconsole/C in consoles)
				if(C.syndicate != syndicate) // Флаг в действии 2
					continue
				var/turf/console_turf = get_turf(C)
				dat += "* <a href='byond://?src=[UID()];upload_toggle=[C.id]'>[console_turf.loc]" //FYI, these are all numeric ids, eventually.
				if(C.id in temp_server.id_with_upload)
					dat += " (Remove)</a><br>"
				else
					dat += " (Add)</a><br>"
			dat += "Consoles with Download Access<br>"
			for(var/obj/machinery/computer/rdconsole/C in consoles)
				if(C.syndicate != syndicate) // Флаг в действии 3
					continue
				var/turf/console_turf = get_turf(C)
				dat += "* <a href='byond://?src=[UID()];download_toggle=[C.id]'>[console_turf.loc]"
				if(C.id in temp_server.id_with_download)
					dat += " (Remove)</a><br>"
				else
					dat += " (Add)</a><br>"
			dat += "<hr><a href='byond://?src=[UID()];main=1'>Main Menu</a>"

		if(2) //Data Management menu
			dat += "[temp_server.name] Data Management<br><br>"
			dat += "Known Technologies<br>"
			for(var/I in temp_server.files.known_tech)
				var/datum/tech/T = temp_server.files.known_tech[I]
				if(T.level <= 0)
					continue
				dat += "* [T.name] "
				dat += "<a href='byond://?src=[UID()];reset_tech=[T.id]'>(Reset)</a><br>" //FYI, these are all strings.
			dat += "Known Designs<br>"
			for(var/I in temp_server.files.known_designs)
				var/datum/design/D = temp_server.files.known_designs[I]
				dat += "* [D.name] "
				dat += "<a href='byond://?src=[UID()];reset_design=[D.id]'>(Delete)</a><br>"
			dat += "<hr><a href='byond://?src=[UID()];main=1'>Main Menu</a>"

		if(3) //Logs menu
			dat += "[temp_server.name] Logs viewing<br><br>"
			for(var/who_cleared in temp_server.logs_for_logs_clearing)
				var/clear_time = who_cleared[1]
				var/user_name = who_cleared[2]
				var/user_job = who_cleared[3]
				dat += "[clear_time]: [user_name] ([user_job]) cleared logs<br>"

			for(var/use_log in temp_server.usage_logs)
				var/log_time = use_log[1]
				var/user_name = use_log[2]
				var/user_job = use_log[3]
				var/blueprint_printed = use_log[4]
				var/machine_name = use_log[5]
				dat += "[log_time]: [user_name] ([user_job]) printed [blueprint_printed] using [machine_name]<br>"

			dat += "<br><hr><a href='byond://?src=[UID()];clear_logs=1'>Clear Logs</a>"
			dat += "<br><hr><a href='byond://?src=[UID()];main=1'>Main Menu</a>"

		if(4) //Server Data Transfer
			dat += "[temp_server.name] Server to Server Transfer<br><br>"
			dat += "Send Data to what server?<br>"
			for(var/obj/machinery/r_n_d/server/S in servers)
				dat += "[S.name] <a href='byond://?src=[UID()];send_to=[S.server_id]'> (Transfer)</a><br>"
			dat += "<hr><a href='byond://?src=[UID()];main=1'>Main Menu</a>"
	var/datum/browser/popup = new(user, "server_control", "R&D Server Control", 575, 400)
	popup.set_content("<hr>[dat]")
	popup.open(TRUE)
	onclose(user, "server_control")
	return

/obj/machinery/computer/rdservercontrol/emag_act(mob/user)
	if(!emagged)
		add_attack_logs(user, src, "emagged")
		playsound(src.loc, 'sound/effects/sparks4.ogg', 75, 1)
		emagged = 1
		if(user)
			to_chat(user, "<span class='notice'>You you disable the security protocols</span>")
	src.updateUsrDialog()

/obj/machinery/r_n_d/server/core
	name = "Core R&D Server"
	id_with_upload_string = "1;3"
	id_with_download_string = "1;3"
	server_id = 1
	plays_sound = 1

/obj/machinery/r_n_d/server/robotics
	name = "Robotics and Mechanic R&D Server"
	id_with_upload_string = "1;2;4"
	id_with_download_string = "1;2;4"
	server_id = 2
