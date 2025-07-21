/obj/item/assembly/signaler
	name = "remote signaling device"
	desc = "Used to remotely activate devices."
	icon_state = "signaller"
	item_state = "signaler"
	materials = list(MAT_METAL=400, MAT_GLASS=120)
	origin_tech = "magnets=1;bluespace=1"
	wires = WIRE_RECEIVE | WIRE_PULSE | WIRE_RADIO_PULSE | WIRE_RADIO_RECEIVE

	secured = TRUE
	var/receiving = FALSE

	bomb_name = "remote-control bomb"

	var/code = 30
	var/frequency = RSD_FREQ
	var/delay = 0
	var/datum/radio_frequency/radio_connection
	var/airlock_wire = null


/obj/item/assembly/signaler/Initialize()
	. = ..()
	if(SSradio)
		set_frequency(frequency)


/obj/item/assembly/signaler/Destroy()
	if(SSradio)
		SSradio.remove_object(src, frequency)
	radio_connection = null
	return ..()


/obj/item/assembly/signaler/examine(mob/user)
	. = ..()
	. += span_notice("The power light is <b>[receiving ? "on" : "off"]</b>.")
	. += span_notice("<b>Alt+Click</b> to send a signal.")


/obj/item/assembly/signaler/click_alt(mob/user)
	to_chat(user, span_notice("You activate [src]."))
	activate()
	return CLICK_ACTION_SUCCESS


/obj/item/assembly/signaler/activate()
	if(cooldown > 0)
		return FALSE
	cooldown = 2
	addtimer(CALLBACK(src, PROC_REF(process_cooldown)), 10)

	signal()
	return TRUE


/obj/item/assembly/signaler/update_icon_state()
	holder?.update_icon()


/obj/item/assembly/signaler/interact(mob/user, flag1)
	var/t1 = "-------"
	var/dat = "<tt>"
	if(!flag1)
		dat += {"
			<a href='byond://?src=[UID()];send=1'>Send Signal</a><br>
			Receiver is <a href='byond://?src=[UID()];receive=1'>[receiving?"on":"off"]</a><br>
		"}
	dat += {"
		<b>Frequency/Code</b> for signaler:<br>
		Frequency:
		<a href='byond://?src=[UID()];freq=-10'>-</a>
		<a href='byond://?src=[UID()];freq=-2'>-</a>
		[format_frequency(frequency)]
		<a href='byond://?src=[UID()];freq=2'>+</a>
		<a href='byond://?src=[UID()];freq=10'>+</a><br>

		Code:
		<a href='byond://?src=[UID()];code=-5'>-</a>
		<a href='byond://?src=[UID()];code=-1'>-</a>
		[code]
		<a href='byond://?src=[UID()];code=1'>+</a>
		<a href='byond://?src=[UID()];code=5'>+</a><br>
		[t1]
		</tt>
	"}
	var/datum/browser/popup = new(user, "radio", name, 400, 400)
	popup.set_content(dat)
	popup.open(FALSE)
	onclose(user, "radio")


/obj/item/assembly/signaler/Topic(href, href_list)
	..()

	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED) || !in_range(loc, usr))
		close_window(usr, "radio")
		onclose(usr, "radio")
		return

	if(href_list["freq"])
		var/new_frequency = (frequency + text2num(href_list["freq"]))
		if(new_frequency < RADIO_LOW_FREQ || new_frequency > RADIO_HIGH_FREQ)
			new_frequency = sanitize_frequency(new_frequency, RADIO_LOW_FREQ, RADIO_HIGH_FREQ)
		set_frequency(new_frequency)

	if(href_list["code"])
		code += text2num(href_list["code"])
		code = round(code)
		code = min(100, code)
		code = max(1, code)

	if(href_list["receive"])
		receiving = !receiving

	if(href_list["send"])
		INVOKE_ASYNC(src, PROC_REF(signal))

	if(usr)
		attack_self(usr)


/obj/item/assembly/signaler/proc/signal()
	if(!radio_connection)
		return

	var/datum/signal/signal = new
	signal.source = src
	signal.encryption = code
	signal.data["message"] = "ACTIVATE"
	signal.user = usr
	radio_connection.post_signal(src, signal)

	var/time = time2text(world.realtime,"hh:mm:ss")
	var/turf/T = get_turf(src)
	if(usr)
		GLOB.lastsignalers.Add("[time] <b>:</b> [usr.key] used [src] @ location ([T.x],[T.y],[T.z]) <b>:</b> [format_frequency(frequency)]/[code]")


/obj/item/assembly/signaler/receive_signal(datum/signal/signal)
	if(!receiving || !signal)
		return FALSE

	if(signal.encryption != code)
		return FALSE

	if(!(wires & WIRE_RADIO_RECEIVE))
		return FALSE
	pulse(1, signal.user)

	for(var/mob/hearer in hearers(1, loc))
		hearer.show_message("[bicon(src)] *beep* *beep* *beep*", 3, "*beep* *beep* *beep*", 2)
		playsound(src, 'sound/machines/triple_beep.ogg', 40, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	return TRUE


/obj/item/assembly/signaler/proc/set_frequency(new_frequency)
	if(!SSradio)
		return
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_CHAT)

