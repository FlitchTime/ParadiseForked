/obj/item/assembly/prox_sensor
	name = "proximity sensor"
	desc = "Used for scanning and alerting when someone enters a certain proximity."
	icon_state = "prox"
	materials = list(MAT_METAL = 800, MAT_GLASS = 200)
	origin_tech = "magnets=1;engineering=1"

	secured = FALSE

	bomb_name = "proximity mine"

	var/scanning = FALSE
	var/timing = FALSE
	var/time = 10


/obj/item/assembly/prox_sensor/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/proximity_monitor)


/obj/item/assembly/prox_sensor/examine(mob/user)
	. = ..()
	if(timing)
		. += span_notice("The proximity sensor is arming.")
	else
		. += span_notice("The proximity sensor is [scanning ? "armed" : "disarmed"].")


/obj/item/assembly/prox_sensor/activate()
	if(!..())
		return FALSE //Cooldown check
	timing = !timing
	update_icon()
	return FALSE


/obj/item/assembly/prox_sensor/toggle_secure()
	secured = !secured
	if(secured)
		START_PROCESSING(SSobj, src)
	else
		scanning = FALSE
		timing = FALSE
		STOP_PROCESSING(SSobj, src)
	update_icon()
	return secured


/obj/item/assembly/prox_sensor/HasProximity(atom/movable/AM)
	if(!isobj(AM) && !isliving(AM))
		return
	if(iseffect(AM))
		return
	if(AM.move_speed < 12)
		sense(AM)


/obj/item/assembly/prox_sensor/proc/sense(atom/movable/AM)
	var/mob/triggered
	if(ismob(AM))
		triggered = AM
	if(!secured || !scanning || cooldown > 0)
		return FALSE
	cooldown = 2
	pulse(FALSE, triggered)
	visible_message("[bicon(src)] *beep* *beep*", "*beep* *beep*")
	addtimer(CALLBACK(src, PROC_REF(process_cooldown)), 1 SECONDS)


/obj/item/assembly/prox_sensor/process()
	if(timing && (time >= 0))
		time--
	if(timing && time <= 0)
		timing = FALSE
		toggle_scan()
		time = 10


/obj/item/assembly/prox_sensor/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(sense), user)


/obj/item/assembly/prox_sensor/proc/toggle_scan()
	if(!secured)
		return FALSE
	scanning = !scanning
	update_icon()


/obj/item/assembly/prox_sensor/update_overlays()
	. = ..()
	attached_overlays = list()
	if(timing)
		. += "prox_timing"
		attached_overlays += "prox_timing"
	if(scanning)
		. += "prox_scanning"
		attached_overlays += "prox_scanning"
	holder?.update_icon()


/obj/item/assembly/prox_sensor/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	. = ..()
	sense()


/obj/item/assembly/prox_sensor/holder_movement(user)
	sense(user)


/obj/item/assembly/prox_sensor/interact(mob/user)//TODO: Change this to the wires thingy
	if(!secured)
		user.show_message(span_warning("The [name] is unsecured!"))
		return FALSE
	var/second = time % 60
	var/minute = (time - second) / 60
	var/dat = "<tt><b>Proximity Sensor</b>\n[(timing ? "<a href='byond://?src=[UID()];time=0'>Arming</a>" : "<a href='byond://?src=[UID()];time=1'>Not Arming</a>")] [minute]:[second]\n \
	<a href='byond://?src=[UID()];tp=-30'>-</a> <a href='byond://?src=[UID()];tp=-1'>-</a> <a href='byond://?src=[UID()];tp=1'>+</a> <a href='byond://?src=[UID()];tp=30'>+</a>\n</tt>"
	dat += "<br><a href='byond://?src=[UID()];scanning=1'>[scanning?"Armed":"Unarmed"]</a> (Movement sensor active when armed!)"
	dat += "<br><br><a href='byond://?src=[UID()];refresh=1'>Refresh</a>"
	dat += "<br><br><a href='byond://?src=[UID()];close=1'>Close</a>"
	var/datum/browser/popup = new(user, "prox", name, 400, 400, src)
	popup.set_content(dat)
	popup.open()


/obj/item/assembly/prox_sensor/Topic(href, href_list)
	..()
	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED) || !in_range(loc, usr))
		close_window(usr, "prox")
		onclose(usr, "prox")
		return

	if(href_list["scanning"])
		toggle_scan()

	if(href_list["time"])
		timing = text2num(href_list["time"])
		update_icon()

	if(href_list["tp"])
		var/tp = text2num(href_list["tp"])
		time += tp
		time = min(max(round(time), 0), 600)

	if(href_list["close"])
		close_window(usr, "prox")
		return

	if(usr)
		attack_self(usr)

