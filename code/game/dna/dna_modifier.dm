#define DNA_BLOCK_SIZE 3

// Buffer datatype flags.
#define DNA2_BUF_UI 1
#define DNA2_BUF_UE 2
#define DNA2_BUF_SE 4

#define NEGATE_MUTATION_THRESHOLD 30 // Occupants with over ## percent radiation threshold will not gain mutations

#define PAGE_UI "ui"
#define PAGE_SE "se"
#define PAGE_BUFFER "buffer"
#define PAGE_REJUVENATORS "rejuvenators"

//list("data" = null, "owner" = null, "label" = null, "type" = null, "ue" = 0),
/datum/dna2/record
	var/datum/dna/dna = null
	var/types = 0
	var/name = "Empty"

	// Stuff for cloners
	var/id = null
	var/implant = null
	var/ckey = null
	var/mind = null
	var/languages = null

/datum/dna2/record/proc/GetData()
	var/list/ser=list("data" = null, "owner" = null, "label" = null, "type" = null, "ue" = 0)
	if(dna)
		ser["ue"] = (types & DNA2_BUF_UE) == DNA2_BUF_UE
		if(types & DNA2_BUF_SE)
			ser["data"] = dna.SE
		else
			ser["data"] = dna.UI
		ser["owner"] = dna.real_name
		ser["label"] = name
		if(types & DNA2_BUF_UI)
			ser["type"] = "ui"
		else
			ser["type"] = "se"
	return ser

/datum/dna2/record/proc/copy()
	var/datum/dna2/record/newrecord = new /datum/dna2/record
	newrecord.dna = dna.Clone()
	newrecord.types = types
	newrecord.name = name
	newrecord.mind = mind
	newrecord.ckey = ckey
	newrecord.languages = languages
	newrecord.implant = implant
	return newrecord


/////////////////////////// DNA MACHINES
/obj/machinery/dna_scannernew
	name = "\improper DNA modifier"
	desc = "Высокотехнологичное устройство, предназначенное для сканирования и изменения структуры ДНК гуманоидов. Здесь и происходит всё волшебство."
	ru_names = list(
		NOMINATIVE = "ДНК-модификатор",
		GENITIVE = "ДНК-модификатора",
		DATIVE = "ДНК-модификатору",
		ACCUSATIVE = "ДНК-модификатор",
		INSTRUMENTAL = "ДНК-модификатором",
		PREPOSITIONAL = "ДНК-модификаторе"
	)
	icon = 'icons/obj/machines/cryogenic2.dmi'
	icon_state = "scanner_open"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	active_power_usage = 300
	interact_offline = 1
	var/locked = FALSE
	var/mob/living/carbon/occupant = null
	var/obj/item/reagent_containers/glass/beaker = null
	var/opened = 0
	var/damage_coeff
	var/scan_level
	var/precision_coeff


/obj/machinery/dna_scannernew/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/clonescanner(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/dna_scannernew/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/clonescanner(null)
	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/dna_scannernew/RefreshParts()
	scan_level = 0
	damage_coeff = 0
	precision_coeff = 0
	for(var/obj/item/stock_parts/scanning_module/P in component_parts)
		scan_level += P.rating
	for(var/obj/item/stock_parts/manipulator/P in component_parts)
		precision_coeff = P.rating
	for(var/obj/item/stock_parts/micro_laser/P in component_parts)
		damage_coeff = P.rating

/obj/machinery/dna_scannernew/examine(mob/user)
	. = ..()
	if(occupant)
		. += span_notice("Внутри кто-то есть.")
	if(Adjacent(user))
		. += span_info("Наведите курсор на гуманоида, зажмите <b>ЛКМ</b> и перетяните на [declent_ru(ACCUSATIVE)], чтобы поместить его внутрь.")

/obj/machinery/dna_scannernew/AllowDrop()
	return FALSE

/obj/machinery/dna_scannernew/verb/eject()
	set src in oview(1)
	set name = "Извлечь субъект"

	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return
	eject_occupant(usr)
	add_fingerprint(usr)

/obj/machinery/dna_scannernew/Destroy()
	eject_occupant(null, TRUE)
	return ..()

/obj/machinery/dna_scannernew/proc/eject_occupant(user, force)
	go_out(user, force)
	for(var/obj/O in src)
		if(!istype(O,/obj/item/circuitboard/clonescanner) && \
		   !istype(O,/obj/item/stock_parts) && \
		   !istype(O,/obj/item/stack/cable_coil) && \
		   O != beaker)
			O.forceMove(get_turf(src))//Ejects items that manage to get in there (exluding the components and beaker)
	if(!occupant)
		for(var/mob/M in src)//Failsafe so you can get mobs out
			M.forceMove(get_turf(src))

/obj/machinery/dna_scannernew/MouseDrop_T(atom/movable/O, mob/user, params)
	if(!istype(O))
		return
	if(O.loc == user) //no you can't pull things out of your ass
		return
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)) //are you cuffed, dying, lying, stunned or other
		return
	if(O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src)) // is the mob anchored, too far away from you, or are you too far away from the source
		return
	if(!ismob(O)) //humans only
		return
	if(isanimal(O) || istype(O, /mob/living/silicon)) //animals and robutts dont fit
		return
	if(!ishuman(user) && !isrobot(user)) //No ghosts or mice putting people into the sleeper
		return
	if(user.loc==null) // just in case someone manages to get a closet into the blue light dimension, as unlikely as that seems
		return
	if(!istype(user.loc, /turf) || !istype(O.loc, /turf)) // are you in a container/closet/pod/etc?
		return
	if(occupant)
		balloon_alert(user, "внутри кто-то есть!")
		return TRUE
	var/mob/living/L = O
	if(!istype(L) || L.buckled)
		return
	if(L.abiotic())
		balloon_alert(user, "руки субъекта заняты!")
		return TRUE
	if(L.has_buckled_mobs()) //mob attached to us
		to_chat(user, span_warning("[L] не помест[pluralize_ru(L.gender, "ит", "ят")]ся в [declent_ru(ACCUSATIVE)], пока на [genderize_ru(L.gender, "нём", "ней", "нём", "них")] сидит слайм!"))
		return TRUE
	put_in(L, user)
	return TRUE


/obj/machinery/dna_scannernew/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(exchange_parts(user, I))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/reagent_containers/glass))
		add_fingerprint(user)
		if(beaker)
			balloon_alert(user, "слот для ёмкости занят!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		beaker = I
		visible_message(span_notice("[user] вставля[pluralize_ru(user.gender,"ет","ют")] [I.declent_ru(GENITIVE)] в [declent_ru(ACCUSATIVE)]."))
		balloon_alert(user, "ёмкость установлена")
		SStgui.update_uis(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/machinery/dna_scannernew/grab_attack(mob/living/grabber, atom/movable/grabbed_thing)
	. = TRUE
	if(grabber.grab_state < GRAB_AGGRESSIVE || !ismob(grabbed_thing))
		return .
	if(panel_open)
		balloon_alert(grabber, "техпанель открыта!")
		return .
	var/mob/target = grabbed_thing
	if(occupant)
		balloon_alert(grabber, "внутри кто-то есть!")
		return .
	if(target.abiotic())
		balloon_alert(grabber, "руки субъекта заняты!")
		return .
	if(target.has_buckled_mobs()) //mob attached to us
		to_chat(grabber, span_warning("[target] не помест[pluralize_ru(target.gender, "ит", "ят")]ся в [declent_ru(ACCUSATIVE)], пока на [genderize_ru(target.gender, "нём", "ней", "нём", "них")] сидит слайм!"))
		return .
	put_in(target, grabber)
	add_fingerprint(grabber)


/obj/machinery/dna_scannernew/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		for(var/obj/thing in contents) // in case there is something in the scanner
			thing.forceMove(loc)
		return TRUE

/obj/machinery/dna_scannernew/screwdriver_act(mob/user, obj/item/I)
	if(occupant)
		balloon_alert(user, "панель заблокирована!")
		return TRUE
	if(default_deconstruction_screwdriver(user, "[icon_state]_maintenance", "[initial(icon_state)]", I))
		return TRUE

/obj/machinery/dna_scannernew/relaymove(mob/user)
	if(user.incapacitated())
		return FALSE //maybe they should be able to get out with cuffs, but whatever
	go_out()

/obj/machinery/dna_scannernew/proc/put_in(mob/M, mob/living/user)
	add_fingerprint(user)
	if(M == user)
		visible_message("[user] начина[pluralize_ru(user.gender,"ет","ют")] залезать в [declent_ru(ACCUSATIVE)].")
	else
		visible_message("[user] начина[pluralize_ru(user.gender,"ет","ют")] укладывать [M] в [declent_ru(ACCUSATIVE)].")

	if(!do_after(user, 2 SECONDS, M))
		return

	if(occupant)
		balloon_alert(user, "внутри кто-то есть!")
		return
	var/mob/living/L = M
	if(!istype(L) || L.buckled)
		return
	if(L.abiotic())
		balloon_alert(user, "руки субъекта заняты!")
		return
	if(L.has_buckled_mobs()) //mob attached to us
		to_chat(user, span_warning("[L] не помест[pluralize_ru(L.gender, "ит", "ят")]ся в [declent_ru(ACCUSATIVE)], пока на [genderize_ru(L.gender, "нём", "ней", "нём", "них")] сидит слайм!"))
		return

	M.forceMove(src)
	occupant = M
	icon_state = "scanner_occupied"
	SStgui.update_uis(src)

	// search for ghosts, if the corpse is empty and the scanner is connected to a cloner
	if(locate(/obj/machinery/computer/cloning, get_step(src, NORTH)) \
		|| locate(/obj/machinery/computer/cloning, get_step(src, SOUTH)) \
		|| locate(/obj/machinery/computer/cloning, get_step(src, EAST)) \
		|| locate(/obj/machinery/computer/cloning, get_step(src, WEST)))

		occupant.notify_ghost_cloning(source = src)

/obj/machinery/dna_scannernew/proc/go_out(mob/user, force)
	if(!occupant)
		if(user)
			to_chat(user, span_warning("Сканер пуст!"))
		return
	if(locked && !force)
		if(user)
			to_chat(user, span_warning("Сканер заблокирован!"))
		return
	occupant.forceMove(loc)
	occupant = null
	icon_state = "scanner_open"
	SStgui.update_uis(src)

/obj/machinery/dna_scannernew/force_eject_occupant(mob/target)
	go_out(null, TRUE)

/obj/machinery/dna_scannernew/ex_act(severity)
	if(occupant)
		occupant.ex_act(severity)
	..()

/obj/machinery/dna_scannernew/handle_atom_del(atom/A)
	..()
	if(A == occupant)
		occupant = null
		updateUsrDialog()
		update_icon()
		SStgui.update_uis(src)

// Checks if occupants can be irradiated/mutated - prevents exploits where wearing full rad protection would still let you gain mutations
/obj/machinery/dna_scannernew/proc/radiation_check()
	if(!occupant)
		return TRUE

	if(HAS_TRAIT(occupant, TRAIT_NO_DNA))
		return TRUE

	var/radiation_protection = occupant.run_armor_check(null, "rad", "Ваша одежда кажется теплой.", "Ваша одежда кажется теплой.")
	if(radiation_protection > NEGATE_MUTATION_THRESHOLD)
		return TRUE
	return FALSE

/obj/machinery/computer/scan_consolenew
	name = "\improper DNA Modifier access console"
	desc = "Консоль для работы с ДНК-модификатором."
	ru_names = list(
		NOMINATIVE = "консоль управления ДНК-модификатором",
		GENITIVE = "консоли управления ДНК-модификатором",
		DATIVE = "консоли управления ДНК-модификатором",
		ACCUSATIVE = "консоль управления ДНК-модификатором",
		INSTRUMENTAL = "консолью управления ДНК-модификатором",
		PREPOSITIONAL = "консоли управления ДНК-модификатором"
	)
	icon = 'icons/obj/machines/computer.dmi'
	icon_screen = "dna"
	icon_keyboard = "med_key"
	density = TRUE
	circuit = /obj/item/circuitboard/scan_consolenew
	var/selected_ui_block = 1.0
	var/selected_ui_subblock = 1.0
	var/selected_se_block = 1.0
	var/selected_se_subblock = 1.0
	var/selected_ui_target = 1
	var/selected_ui_target_hex = 1
	var/radiation_duration = 2.0
	var/radiation_intensity = 1.0
	var/list/datum/dna2/record/buffers[3]
	var/irradiating = 0
	var/injector_ready = FALSE	//Quick fix for issue 286 (screwdriver the screen twice to restore injector)	-Pete
	var/obj/machinery/dna_scannernew/connected = null
	var/obj/item/disk/data/disk = null
	var/selected_menu_key = PAGE_UI
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 400


/obj/machinery/computer/scan_consolenew/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/disk/data)) //INSERT SOME diskS
		add_fingerprint(user)
		if(disk)
			balloon_alert(user, "слот для дискеты занят!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		disk = I
		visible_message(span_notice("[user] вставля[pluralize_ru(user.gender, "ет", "ют")] [I.declent_ru(ACCUSATIVE)] в [declent_ru(ACCUSATIVE)]."))
		balloon_alert(user, "дискета вставлена")
		SStgui.update_uis(src)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/machinery/computer/scan_consolenew/New()
	..()
	for(var/i=0;i<3;i++)
		buffers[i+1]=new /datum/dna2/record
	spawn(5)
		for(dir in list(NORTH,EAST,SOUTH,WEST))
			connected = locate(/obj/machinery/dna_scannernew, get_step(src, dir))
			if(!isnull(connected))
				break
		spawn(250)
			injector_ready = TRUE

/obj/machinery/computer/scan_consolenew/proc/all_dna_blocks(list/buffer)
	var/list/arr = list()
	for(var/i = 1, i <= buffer.len, i++)
		arr += "[i]:[EncodeDNABlock(buffer[i])]"
	return arr

/obj/machinery/computer/scan_consolenew/proc/setInjectorBlock(obj/item/dnainjector/I, blk, datum/dna2/record/buffer)
	var/pos = findtext(blk,":")
	if(!pos)
		return FALSE
	var/id = text2num(copytext(blk,1,pos))
	if(!id)
		return FALSE
	I.block = id
	I.buf = buffer
	I.origin_tech = GetInjectorTechs(I)

	return TRUE

/obj/machinery/computer/scan_consolenew/attack_ai(mob/user)
	add_hiddenprint(user)
	attack_hand(user)

/obj/machinery/computer/scan_consolenew/attack_hand(mob/user)
	if(isnull(connected))
		for(dir in list(NORTH,EAST,SOUTH,WEST))
			connected = locate(/obj/machinery/dna_scannernew, get_step(src, dir))
			if(!isnull(connected))
				add_fingerprint(user)
				attack_hand(user)
				break
	else
		if(..(user))
			return

		if(stat & (NOPOWER|BROKEN))
			return

		ui_interact(user)

/obj/machinery/computer/scan_consolenew/ui_interact(mob/user, datum/tgui/ui = null)
	if(user == connected.occupant)
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DNAModifier", "Консоль управления ДНК-модификатором")
		ui.open()

/obj/machinery/computer/scan_consolenew/ui_data(mob/user)
	var/list/data = list()
	data["selectedMenuKey"] = selected_menu_key
	data["locked"] = connected.locked
	data["hasOccupant"] = connected.occupant ? 1 : 0

	data["isInjectorReady"] = injector_ready

	data["hasDisk"] = disk ? 1 : 0

	var/diskData[0]
	if(!disk || !disk.buf)
		diskData["data"] = null
		diskData["owner"] = null
		diskData["label"] = null
		diskData["type"] = null
		diskData["ue"] = null
	else
		diskData = disk.buf.GetData()
	data["disk"] = diskData

	var/list/new_buffers = list()
	for(var/datum/dna2/record/buf in buffers)
		new_buffers += list(buf.GetData())
	data["buffers"]=new_buffers

	data["radiationIntensity"] = radiation_intensity
	data["radiationDuration"] = radiation_duration
	data["irradiating"] = irradiating

	data["dnaBlockSize"] = DNA_BLOCK_SIZE
	data["selectedUIBlock"] = selected_ui_block
	data["selectedUISubBlock"] = selected_ui_subblock
	data["selectedSEBlock"] = selected_se_block
	data["selectedSESubBlock"] = selected_se_subblock
	data["selectedUITarget"] = selected_ui_target
	data["selectedUITargetHex"] = selected_ui_target_hex

	var/occupantData[0]
	if(!connected.occupant || !connected.occupant.dna)
		occupantData["name"] = null
		occupantData["stat"] = null
		occupantData["isViableSubject"] = null
		occupantData["health"] = null
		occupantData["maxHealth"] = null
		occupantData["minHealth"] = null
		occupantData["uniqueEnzymes"] = null
		occupantData["uniqueIdentity"] = null
		occupantData["structuralEnzymes"] = null
		occupantData["radiationLevel"] = null
	else
		occupantData["name"] = connected.occupant.dna.real_name
		occupantData["stat"] = connected.occupant.stat
		occupantData["isViableSubject"] = 1
		if((HAS_TRAIT(connected.occupant, TRAIT_NO_CLONE) && connected.scan_level < 3) || !connected.occupant.dna || HAS_TRAIT(connected.occupant, TRAIT_NO_DNA))
			occupantData["isViableSubject"] = 0
		occupantData["health"] = connected.occupant.health
		occupantData["maxHealth"] = connected.occupant.maxHealth
		occupantData["minHealth"] = HEALTH_THRESHOLD_DEAD
		occupantData["uniqueEnzymes"] = connected.occupant.dna.unique_enzymes
		occupantData["uniqueIdentity"] = connected.occupant.dna.uni_identity
		occupantData["structuralEnzymes"] = connected.occupant.dna.struc_enzymes
		occupantData["radiationLevel"] = connected.occupant.radiation
	data["occupant"] = occupantData

	data["isBeakerLoaded"] = connected.beaker ? 1 : 0
	data["beakerLabel"] = null
	data["beakerVolume"] = 0
	if(connected.beaker)
		data["beakerLabel"] = connected.beaker.label_text ? connected.beaker.label_text : null
		if(connected.beaker.reagents && connected.beaker.reagents.reagent_list.len)
			for(var/datum/reagent/R in connected.beaker.reagents.reagent_list)
				data["beakerVolume"] += R.volume

	// Transfer modal information if there is one
	data["modal"] = ui_modal_data(src)

	return data

/obj/machinery/computer/scan_consolenew/ui_act(action, params)
	if(..())
		return FALSE // don't update uis
	if(!istype(usr.loc, /turf))
		return FALSE // don't update uis
	if(!src || !connected)
		return FALSE // don't update uis
	if(irradiating) // Make sure that it isn't already irradiating someone...
		return FALSE // don't update uis
	if(stat & (NOPOWER|BROKEN))
		return

	add_fingerprint(usr)

	if(ui_act_modal(action, params))
		return TRUE

	. = TRUE
	switch(action)
		if("selectMenuKey")
			var/key = params["key"]
			if(!(key in list(PAGE_UI, PAGE_SE, PAGE_BUFFER, PAGE_REJUVENATORS)))
				return
			selected_menu_key = key
		if("toggleLock")
			if(connected && connected.occupant)
				connected.locked = !(connected.locked)
		if("pulseRadiation")
			irradiating = radiation_duration
			var/lock_state = connected.locked
			connected.locked = TRUE //lock it

			SStgui.update_uis(src)
			sleep(10 * radiation_duration) // sleep for radiation_duration seconds

			irradiating = 0
			connected.locked = lock_state

			if(!connected.occupant)
				return

			var/radiation = (((radiation_intensity * 3) + radiation_duration * 3) / connected.damage_coeff)
			connected.occupant.apply_effect(radiation, IRRADIATE, 0)
			if(connected.radiation_check())
				return

			if(prob(95))
				if(prob(75))
					randmutb(connected.occupant)
				else
					randmuti(connected.occupant)
			else
				if(prob(95))
					randmutg(connected.occupant)
				else
					randmuti(connected.occupant)
		if("radiationDuration")
			radiation_duration = clamp(text2num(params["value"]), 1, 20)
		if("radiationIntensity")
			radiation_intensity = clamp(text2num(params["value"]), 1, 10)
	////////////////////////////////////////////////////////
		if("changeUITarget")
			selected_ui_target = clamp(text2num(params["value"]), 1, 15)
			selected_ui_target_hex = num2text(selected_ui_target, 1, 16)
		if("selectUIBlock") // This chunk of code updates selected block / sub-block based on click
			var/select_block = text2num(params["block"])
			var/select_subblock = text2num(params["subblock"])
			if(!select_block || !select_subblock)
				return

			selected_ui_block = clamp(select_block, 1, DNA_UI_LENGTH)
			selected_ui_subblock = clamp(select_subblock, 1, DNA_BLOCK_SIZE)
		if("pulseUIRadiation")
			var/block = connected.occupant.dna.GetUISubBlock(selected_ui_block, selected_ui_subblock)

			irradiating = radiation_duration
			var/lock_state = connected.locked
			connected.locked = TRUE //lock it

			SStgui.update_uis(src)
			sleep(10 * radiation_duration) // sleep for radiation_duration seconds

			irradiating = 0
			connected.locked = lock_state

			if(!connected.occupant)
				return

			if(prob((80 + (radiation_duration / 2))))
				var/radiation = (radiation_intensity + radiation_duration)
				connected.occupant.apply_effect(radiation,IRRADIATE,0)

				if(connected.radiation_check())
					return

				block = miniscrambletarget(num2text(selected_ui_target), radiation_intensity, radiation_duration)
				connected.occupant.dna.SetUISubBlock(selected_ui_block, selected_ui_subblock, block)
				connected.occupant.UpdateAppearance()
			else
				var/radiation = ((radiation_intensity * 2) + radiation_duration)
				connected.occupant.apply_effect(radiation, IRRADIATE, 0)
				if(connected.radiation_check())
					return

				if(prob(20 + radiation_intensity))
					randmutb(connected.occupant)
					connected.occupant.check_genes()
				else
					randmuti(connected.occupant)
					connected.occupant.UpdateAppearance()
	////////////////////////////////////////////////////////
		if("injectRejuvenators")
			if(!connected.occupant || !connected.beaker)
				return
			var/inject_amount = clamp(round(text2num(params["amount"]), 5), 0, 50) // round to nearest 5 and clamp to 0-50
			if(!inject_amount)
				return
			connected.beaker.reagents.trans_to(connected.occupant, inject_amount)
			connected.beaker.reagents.reaction(connected.occupant)
	////////////////////////////////////////////////////////
		if("selectSEBlock") // This chunk of code updates selected block / sub-block based on click (se stands for strutural enzymes)
			var/select_block = text2num(params["block"])
			var/select_subblock = text2num(params["subblock"])
			if(!select_block || !select_subblock)
				return

			selected_se_block = clamp(select_block, 1, DNA_SE_LENGTH)
			selected_se_subblock = clamp(select_subblock, 1, DNA_BLOCK_SIZE)
		if("pulseSERadiation")
			var/block = connected.occupant.dna.GetSESubBlock(selected_se_block, selected_se_subblock)
			//var/original_block=block
			//testing("Irradiating SE block [selected_se_block]:[selected_se_subblock] ([block])...")

			irradiating = radiation_duration
			var/lock_state = connected.locked
			connected.locked = TRUE //lock it

			SStgui.update_uis(src)
			sleep(10 * radiation_duration) // sleep for radiation_duration seconds

			irradiating = 0
			connected.locked = lock_state

			if(connected.occupant)
				if(prob((80 + ((radiation_duration / 2) + (connected.precision_coeff ** 3)))))
					var/radiation = ((radiation_intensity + radiation_duration) / connected.damage_coeff)
					connected.occupant.apply_effect(radiation, IRRADIATE, 0)

					if(connected.radiation_check())
						return 1

					var/real_SE_block=selected_se_block
					block = miniscramble(block, radiation_intensity, radiation_duration)
					if(prob(20))
						if(selected_se_block > 1 && selected_se_block < DNA_SE_LENGTH/2)
							real_SE_block++
						else if(selected_se_block > DNA_SE_LENGTH/2 && selected_se_block < DNA_SE_LENGTH)
							real_SE_block--

					//testing("Irradiated SE block [real_SE_block]:[selected_se_subblock] ([original_block] now [block]) [(real_SE_block!=selected_se_block) ? "(SHIFTED)":""]!")
					connected.occupant.dna.SetSESubBlock(real_SE_block, selected_se_subblock, block)
					connected.occupant.check_genes()
				else
					var/radiation = (((radiation_intensity * 2) + radiation_duration) / connected.damage_coeff)
					connected.occupant.apply_effect(radiation, IRRADIATE, 0)

					if(connected.radiation_check())
						return

					if(prob(80 - radiation_duration))
						//testing("Random bad mut!")
						randmutb(connected.occupant)
						connected.occupant.check_genes()
					else
						randmuti(connected.occupant)
						//testing("Random identity mut!")
						connected.occupant.UpdateAppearance()
		if("ejectBeaker")
			if(connected.beaker)
				var/obj/item/reagent_containers/glass/B = connected.beaker
				B.forceMove(connected.loc)
				connected.beaker = null
				if(Adjacent(usr) && !issilicon(usr))
					usr.put_in_hands(B, ignore_anim = FALSE)
		if("ejectOccupant")
			connected.eject_occupant()
		// Transfer Buffer Management
		if("bufferOption")
			var/bufferOption = params["option"]
			var/bufferId = text2num(params["id"])
			if(bufferId < 1 || bufferId > 3) // Not a valid buffer id
				return

			var/datum/dna2/record/buffer = buffers[bufferId]
			switch(bufferOption)
				if("saveUI")
					if(connected.occupant && connected.occupant.dna)
						var/datum/dna2/record/databuf = new
						databuf.types = DNA2_BUF_UI // DNA2_BUF_UE
						databuf.dna = connected.occupant.dna.Clone()
						if(ishuman(connected.occupant))
							databuf.dna.real_name=connected.occupant.name
						databuf.name = "Уникальные Идентификаторы"
						buffers[bufferId] = databuf
				if("saveUIAndUE")
					if(connected.occupant && connected.occupant.dna)
						var/datum/dna2/record/databuf = new
						databuf.types = DNA2_BUF_UI|DNA2_BUF_UE
						databuf.dna = connected.occupant.dna.Clone()
						if(ishuman(connected.occupant))
							databuf.dna.real_name=connected.occupant.dna.real_name
						databuf.name = "Уникальные Идентификаторы + Уникальные Ферменты"
						buffers[bufferId] = databuf
				if("saveSE")
					if(connected.occupant && connected.occupant.dna)
						var/datum/dna2/record/databuf = new
						databuf.types = DNA2_BUF_SE
						databuf.dna = connected.occupant.dna.Clone()
						if(ishuman(connected.occupant))
							databuf.dna.real_name = connected.occupant.dna.real_name
						databuf.name = "Структурные Ферменты"
						buffers[bufferId] = databuf
				if("clear")
					buffers[bufferId] = new /datum/dna2/record()
				if("changeLabel")
					ui_modal_input(src, "changeBufferLabel", "Введите название для ячейки буфера:", null, list("id" = bufferId), buffer.name, UI_MODAL_INPUT_MAX_LENGTH_NAME)
				if("transfer")
					if(!connected.occupant || (HAS_TRAIT(connected.occupant, TRAIT_NO_CLONE) && connected.scan_level < 3) || !connected.occupant.dna)
						return

					irradiating = 2
					var/lock_state = connected.locked
					connected.locked = TRUE //lock it

					SStgui.update_uis(src)
					sleep(2 SECONDS)

					irradiating = 0
					connected.locked = lock_state

					var/radiation = (rand(20,50) / connected.damage_coeff)
					connected.occupant.apply_effect(radiation, IRRADIATE, 0)

					if(connected.radiation_check())
						return

					var/datum/dna2/record/buf = buffers[bufferId]

					if((buf.types & DNA2_BUF_UI))
						if((buf.types & DNA2_BUF_UE))
							connected.occupant.real_name = buf.dna.real_name
							connected.occupant.name = buf.dna.real_name
						connected.occupant.UpdateAppearance(buf.dna.UI.Copy())
					else if(buf.types & DNA2_BUF_SE)
						connected.occupant.dna.SE = buf.dna.SE.Copy()
						connected.occupant.dna.UpdateSE()
						connected.occupant.check_genes()
				if("createInjector")
					if(!injector_ready)
						return
					if(text2num(params["block"]) > 0)
						var/list/choices = all_dna_blocks((buffer.types & DNA2_BUF_SE) ? buffer.dna.SE : buffer.dna.UI)
						ui_modal_choice(src, "createInjectorBlock", "Выберите блок, на основе которого будет создан инъектор:", null, list("id" = bufferId), null, choices)
					else
						create_injector(bufferId, TRUE)
				if("loadDisk")
					if(isnull(disk) || disk.read_only)
						return
					buffers[bufferId] = disk.buf.copy()
				if("saveDisk")
					if(isnull(disk) || disk.read_only)
						return
					var/datum/dna2/record/buf = buffers[bufferId]
					disk.buf = buf.copy()
					disk.name = "data disk - '[buf.dna.real_name]'"
		if("wipeDisk")
			if(isnull(disk) || disk.read_only)
				return
			disk.buf = null
		if("ejectDisk")
			if(!disk)
				return
			disk.forceMove(get_turf(src))
			disk = null

/**
  * Creates a blank injector with the name of the buffer at the given buffer_id
  *
  * Arguments:
  * * buffer_id - The ID of the buffer
  * * copy_buffer - Whether the injector should copy the buffer contents
  */
/obj/machinery/computer/scan_consolenew/proc/create_injector(buffer_id, copy_buffer = FALSE)
	if(buffer_id < 1 || buffer_id > length(buffers))
		return

	// Cooldown
	injector_ready = FALSE
	addtimer(CALLBACK(src, PROC_REF(injector_cooldown_finish)), (30 / connected.precision_coeff) SECONDS)

	// Create it
	var/datum/dna2/record/buf = buffers[buffer_id]
	var/obj/item/dnainjector/I = new()
	I.forceMove(loc)
	I.name += " ([buf.name])"
	if(copy_buffer)
		I.buf = buf.copy()
	if(connected)
		I.damage_coeff = connected.damage_coeff
	return I

/**
  * Called when the injector creation cooldown finishes
  */
/obj/machinery/computer/scan_consolenew/proc/injector_cooldown_finish()
	injector_ready = TRUE

/**
  * Called in ui_act() to process modal actions
  *
  * Arguments:
  * * action - The action passed by tgui
  * * params - The params passed by tgui
  */
/obj/machinery/computer/scan_consolenew/proc/ui_act_modal(action, params)
	. = TRUE
	var/id = params["id"] // The modal's ID
	var/list/arguments = istext(params["arguments"]) ? json_decode(params["arguments"]) : params["arguments"]
	switch(ui_modal_act(src, action, params))
		if(UI_MODAL_ANSWER)
			var/answer = params["answer"]
			switch(id)
				if("createInjectorBlock")
					var/buffer_id = text2num(arguments["id"])
					if(buffer_id < 1 || buffer_id > length(buffers))
						return
					var/datum/dna2/record/buf = buffers[buffer_id]
					var/obj/item/dnainjector/I = create_injector(buffer_id)
					setInjectorBlock(I, answer, buf.copy())
				if("changeBufferLabel")
					var/buffer_id = text2num(arguments["id"])
					if(buffer_id < 1 || buffer_id > length(buffers))
						return
					var/datum/dna2/record/buf = buffers[buffer_id]
					buf.name = answer
					buffers[buffer_id] = buf
				else
					return FALSE
		else
			return FALSE


#undef PAGE_UI
#undef PAGE_SE
#undef PAGE_BUFFER
#undef PAGE_REJUVENATORS

/////////////////////////// DNA MACHINES
