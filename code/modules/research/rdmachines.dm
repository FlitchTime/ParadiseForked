//All devices that link into the R&D console fall into thise type for easy identification and some shared procs.


/obj/machinery/r_n_d
	name = "R&D Device"
	icon = 'icons/obj/machines/research.dmi'
	var/icon_open = null
	var/icon_closed = null
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	var/busy = 0
	var/hacked = 0
	var/disabled = 0
	var/shocked = 0
	var/list/wires = list()
	var/hack_wire
	var/disable_wire
	var/shock_wire
	var/obj/machinery/computer/rdconsole/linked_console
	var/obj/item/loaded_item = null
	var/datum/component/material_container/materials	//Store for hyper speed!
	var/efficiency_coeff = 1
	var/list/categories = list()

/obj/machinery/r_n_d/Initialize(mapload)
	. = ..()
	materials = AddComponent(/datum/component/material_container, list(MAT_METAL, MAT_GLASS, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_PLASMA, MAT_URANIUM, MAT_BANANIUM, MAT_TRANQUILLITE, MAT_TITANIUM, MAT_BLUESPACE, MAT_PLASTIC), 0, TRUE, /obj/item/stack, CALLBACK(src, PROC_REF(is_insertion_ready)), CALLBACK(src, PROC_REF(AfterMaterialInsert)))
	materials.precise_insertion = TRUE
	wires["Red"] = 0
	wires["Blue"] = 0
	wires["Green"] = 0
	wires["Yellow"] = 0
	wires["Black"] = 0
	wires["White"] = 0
	var/list/w = list("Red","Blue","Green","Yellow","Black","White")
	hack_wire = pick_n_take(w)
	shock_wire = pick_n_take(w)
	disable_wire = pick_n_take(w)

/obj/machinery/r_n_d/Destroy()
	if(loaded_item)
		loaded_item.forceMove(get_turf(src))
		loaded_item = null
	linked_console = null
	materials = null
	return ..()

/obj/machinery/r_n_d/attack_hand(mob/user as mob)
	if(..())
		return TRUE
	add_fingerprint(user)
	if(shocked)
		shock(user,50)
	if(panel_open)
		var/list/dat = list()
		dat += "[src.name] Wires:<br>"
		for(var/wire in wires)
			dat += "[wire] Wire: <a href='byond://?src=[UID()];wire=[wire];cut=1'>[src.wires[wire] ? "Mend" : "Cut"]</a> <a href='byond://?src=[UID()];wire=[wire];pulse=1'>Pulse</a><br>"

		dat += "The red light is [src.disabled ? "off" : "on"].<br>"
		dat += "The green light is [src.shocked ? "off" : "on"].<br>"
		dat += "The blue light is [src.hacked ? "off" : "on"].<br>"
		var/datum/browser/popup = new(user, "hack_win", "[src.name] Hacking")
		popup.set_content(dat.Join(""))
		popup.open(FALSE)
	return


/obj/machinery/r_n_d/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["pulse"])
		var/temp_wire = href_list["wire"]
		if(!istype(usr.get_active_hand(), /obj/item/multitool))
			to_chat(usr, "You need a multitool!")
		else
			if(src.wires[temp_wire])
				to_chat(usr, "You can't pulse a cut wire.")
			else
				if(src.hack_wire == href_list["wire"])
					src.hacked = !src.hacked
					spawn(100) src.hacked = !src.hacked
				if(src.disable_wire == href_list["wire"])
					src.disabled = !src.disabled
					src.shock(usr,50)
					spawn(100) src.disabled = !src.disabled
				if(src.shock_wire == href_list["wire"])
					src.shocked = !src.shocked
					src.shock(usr,50)
					spawn(100) src.shocked = !src.shocked
	if(href_list["cut"])
		if(!istype(usr.get_active_hand(), /obj/item/wirecutters))
			to_chat(usr, "You need wirecutters!")
		else
			var/temp_wire = href_list["wire"]
			wires[temp_wire] = !wires[temp_wire]
			if(src.hack_wire == temp_wire)
				src.hacked = !src.hacked
			if(src.disable_wire == temp_wire)
				src.disabled = !src.disabled
				src.shock(usr,50)
			if(src.shock_wire == temp_wire)
				src.shocked = !src.shocked
				src.shock(usr,50)
	src.updateUsrDialog()

//whether the machine can have an item inserted in its current state.
/obj/machinery/r_n_d/proc/is_insertion_ready(mob/user)
	if(panel_open)
		to_chat(user, "<span class='warning'>You can't load [src] while it's opened!</span>")
		return FALSE
	if(disabled)
		return FALSE
	if(!linked_console)
		to_chat(user, "<span class='warning'>[src] must be linked to an R&D console first!</span>")
		return FALSE
	if(busy)
		to_chat(user, "<span class='warning'>[src] is busy right now.</span>")
		return FALSE
	if(stat & BROKEN)
		to_chat(user, "<span class='warning'>[src] is broken.</span>")
		return FALSE
	if(stat & NOPOWER)
		to_chat(user, "<span class='warning'>[src] has no power.</span>")
		return FALSE
	if(loaded_item)
		to_chat(user, "<span class='warning'>[src] is already loaded.</span>")
		return FALSE
	return TRUE

/obj/machinery/r_n_d/proc/AfterMaterialInsert(type_inserted, id_inserted, amount_inserted)
	var/stack_name
	var/obj/item/stack/S = type_inserted
	if(ispath(type_inserted, /obj/item/stack/ore/bluespace_crystal))
		use_power(MINERAL_MATERIAL_AMOUNT / 10)
	else
		use_power(min(1000, (amount_inserted / 100)))
	stack_name = S.protolathe_name
	flick_overlay_view(mutable_appearance(icon, "[base_icon_state]_[stack_name]"), 1.5 SECONDS)


/obj/machinery/r_n_d/proc/check_mat(datum/design/being_built, M)
	return 0 // number of copies of design beign_built you can make with material M
