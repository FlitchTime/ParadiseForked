//Floorbot
/mob/living/simple_animal/bot/floorbot
	name = "\improper Floorbot"
	desc = "Маленький робот для починки полов и обшивки. Он выглядит таким увлечённым!"
	ru_names = list(
		NOMINATIVE = "ремонтный робот",
		GENITIVE = "ремонтного робота",
		DATIVE = "ремонтному роботу",
		ACCUSATIVE = "ремонтного робота",
		INSTRUMENTAL = "ремонтным роботом",
		PREPOSITIONAL = "ремонтном роботе",
	)
	icon = 'icons/obj/aibots.dmi'
	icon_state = "floorbot0"
	density = FALSE
	anchored = FALSE
	health = 25
	maxHealth = 25

	radio_channel = "Engineering"
	bot_type = FLOOR_BOT
	bot_filter = RADIO_FLOORBOT
	model = "Floorbot"
	bot_purpose = "найти повреждения в полу или обшивке и восстановить их целостность"
	bot_core_type = /obj/machinery/bot_core/floorbot
	window_id = "autofloor"
	window_name = "Автоматическая Ремонтная Единица v1.1"
	path_image_color = "#FFA500"

	/// Determines what to do when process_scan() recieves a target. See process_scan() for details.
	var/process_type
	var/targetdirection
	var/amount = 10
	var/replacetiles = FALSE
	var/eattiles = FALSE
	var/maketiles = FALSE
	var/fixfloors = FALSE
	var/autotile = FALSE
	var/nag_on_empty = TRUE
	/// Prevents the Floorbot nagging more than once per refill.
	var/nagged = FALSE
	var/max_targets = 50
	var/turf/target
	var/oldloc = null
	var/toolbox_color = ""

	#define HULL_BREACH		1
	#define BRIDGE_MODE		2
	#define FIX_TILE		3
	#define AUTO_TILE		4
	#define REPLACE_TILE	5
	#define TILE_EMAG		6


/mob/living/simple_animal/bot/floorbot/Initialize(mapload, new_toolbox_color)
	. = ..()
	toolbox_color = new_toolbox_color
	update_icon()
	var/datum/job/engineer/J = new/datum/job/engineer
	access_card.access += J.get_access()
	prev_access = access_card.access
	if(toolbox_color == "s")
		health = 50
		maxHealth = 50


/mob/living/simple_animal/bot/floorbot/bot_reset()
	..()
	target = null
	oldloc = null
	ignore_list.Cut()
	nagged = FALSE
	set_anchored(FALSE)
	update_icon()


/mob/living/simple_animal/bot/floorbot/set_custom_texts()
	text_hack = "Вы взломали рабочие протоколы [declent_ru(GENITIVE)]."
	text_dehack = "Вы восстановили рабочие протоколы [declent_ru(GENITIVE)]."
	text_dehack_fail = "[capitalize(declent_ru(NOMINATIVE))] не отвечает на команды сброса настроек!"


/mob/living/simple_animal/bot/floorbot/get_controls(mob/user)
	var/dat
	dat += hack(user)
	dat += showpai(user)
	dat += "<tt><b>Панель управления ремонтным роботом v1.1</b></tt><br><br>"
	dat += "Состояние: <a href='byond://?src=[UID()];power=1'>[on ? "Включён" : "Выключен"]</a><br>"
	dat += "Панель технического обслуживания [open ? "открыта" : "закрыта"]<br>"
	dat += "Плиток пола в запасе: [amount]<br>"
	dat += "Управление поведением [locked ? "заблокировано" : "разблокировано"]<br>"
	if(!locked || issilicon(user) || user.can_admin_interact())
		dat += "Устанавливать плитки пола на сегменты обшивки:<a href='byond://?src=[UID()];operation=autotile'>[autotile ? "Да" : "Нет"]</a><br>"
		dat += "Заменять плитки пола: <a href='byond://?src=[UID()];operation=replace'>[replacetiles ? "Да" : "Нет"]</a><br>"
		dat += "Загружать свободные плитки во внутреннее хранилище: <a href='byond://?src=[UID()];operation=tiles'>[eattiles ? "Да" : "Нет"]</a><br>"
		dat += "Перерабатывать металл в плитки пола, когда хранилище опустошено: <a href='byond://?src=[UID()];operation=make'>[maketiles ? "Да" : "Нет"]</a><br>"
		dat += "Уведомлять, когда хранилище опустошено: <a href='byond://?src=[UID()];operation=emptynag'>[nag_on_empty ? "Да" : "Нет"]</a><br>"
		dat += "Ремонтировать повреждения пола и обшивки: <a href='byond://?src=[UID()];operation=fix'>[fixfloors ? "Да" : "Нет"]</a><br>"
		dat += "Закрепиться на месте: <a href='byond://?src=[UID()];operation=anchor'>[anchored ? "Да" : "Нет"]</a><br>"
		dat += "Режим патрулирования: <a href='byond://?src=[UID()];operation=patrol'>[auto_patrol ? "Да" : "Нет"]</a><br>"
		var/bmode
		if(targetdirection)
			bmode = dir2text(targetdirection)
		else
			bmode = "Выключен"
		dat += "Режим постройки моста: <a href='byond://?src=[UID()];operation=bridgemode'>[bmode]</a><br>"

	return dat


/mob/living/simple_animal/bot/floorbot/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/stack/tile/plasteel))
		add_fingerprint(user)
		var/obj/item/stack/tile/plasteel/plasteel = I
		var/loaded = min(50 - amount, plasteel.get_amount())
		if(!plasteel.use(loaded))
			to_chat(user, span_warning("Вам нужна хотя бы одна плитка пола для загрузки в [declent_ru(ACCUSATIVE)]!"))
			return ATTACK_CHAIN_PROCEED
		amount += loaded
		balloon_alert(user, "плитки загружены")
		to_chat(user, span_notice("Вы загрузили [loaded] плитки в [declent_ru(ACCUSATIVE)]. Текущее количество плиток - [amount]."))
		nagged = FALSE
		update_icon()
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/mob/living/simple_animal/bot/floorbot/emag_act(mob/user)
	..()
	if(emagged == 2)
		if(user)
			to_chat(user, span_danger("[capitalize(declent_ru(NOMINATIVE))] жужжит и пищит."))


/mob/living/simple_animal/bot/floorbot/Topic(href, href_list)
	if(..())
		return TRUE

	switch(href_list["operation"])
		if("replace")
			replacetiles = !replacetiles
		if("tiles")
			eattiles = !eattiles
		if("make")
			maketiles = !maketiles
		if("fix")
			fixfloors = !fixfloors
		if("autotile")
			autotile = !autotile
		if("emptynag")
			nag_on_empty = !nag_on_empty
		if("anchor")
			set_anchored(!anchored)

		if("bridgemode")
			var/setdir = input("Выберите направление строительства:") as null|anything in list("север","юг","запад","восток","отключить")
			switch(setdir)
				if("север")
					targetdirection = 1
				if("юг")
					targetdirection = 2
				if("восток")
					targetdirection = 4
				if("запад")
					targetdirection = 8
				if("отключить")
					targetdirection = null
	update_controls()


/mob/living/simple_animal/bot/floorbot/handle_automated_action()
	if(!..())
		return

	if(mode == BOT_REPAIRING)
		return

	if(amount <= 0 && !target) //Out of tiles! We must refill!
		if(eattiles) //Configured to find and consume floortiles!
			target = scan(/obj/item/stack/tile/plasteel)
			process_type = null

		if(!target && maketiles) //We did not manage to find any floor tiles! Scan for metal stacks and make our own!
			target = scan(/obj/item/stack/sheet/metal)
			process_type = null
			return
		else
			if(nag_on_empty) //Floorbot is empty and cannot acquire more tiles, nag the engineers for more!
				nag()

	if(prob(5))
		custom_emote(EMOTE_VISIBLE, "бупает и бипает!")

	//Normal scanning procedure. We have tiles loaded, are not emagged.
	if(!target && emagged < 2 && amount > 0)
		if(targetdirection != null) //The bot is in bridge mode.
			//Try to find a space tile immediately in our selected direction.
			var/turf/T = get_step(src, targetdirection)
			if(isspaceturf(T))
				target = T

			else //Find a space tile farther way!
				target = scan(/turf/space)
			process_type = BRIDGE_MODE

		if(!target)
			process_type = HULL_BREACH //Ensures the floorbot does not try to "fix" space areas or shuttle docking zones.
			target = scan(/turf/space)

		if(!target && replacetiles) //Finds a floor without a tile and gives it one.
			process_type = REPLACE_TILE //The target must be the floor and not a tile. The floor must not already have a floortile.
			target = scan(/turf/simulated/floor)

		if(!target && fixfloors) //Repairs damaged floors and tiles.
			process_type = FIX_TILE
			target = scan(/turf/simulated/floor)

	if(!target && emagged == 2) //We are emagged! Time to rip up the floors!
		process_type = TILE_EMAG
		target = scan(/turf/simulated/floor)

	if(!target)
		if(auto_patrol)
			if(mode == BOT_IDLE || mode == BOT_START_PATROL)
				start_patrol()

			if(mode == BOT_PATROL)
				bot_patrol()

	if(target)
		if(loc == target || loc == target.loc)
			if(istype(target, /obj/item/stack/tile/plasteel))
				start_eattile(target)
			else if(istype(target, /obj/item/stack/sheet/metal))
				start_maketile(target)
			else if(isturf(target) && emagged < 2)
				repair(target)
			else if(emagged == 2 && isfloorturf(target))
				var/turf/simulated/floor/F = target
				set_anchored(TRUE)
				mode = BOT_REPAIRING
				if(prob(90))
					F.break_tile_to_plating()
				else
					F.ReplaceWithLattice()
				custom_emote(EMOTE_VISIBLE, "бупает.")
				addtimer(CALLBACK(src, PROC_REF(inc_amount_callback)), 5 SECONDS)

			path = list()
			return

		if(!length(path))
			if(!isturf(target))
				var/turf/TL = get_turf(target)
				path = get_path_to(src, TL, max_distance = 30, access = access_card.GetAccess(), simulated_only = FALSE)
			else
				path = get_path_to(src, target, max_distance = 30, access = access_card.GetAccess(), simulated_only = FALSE)

			if(!bot_move(target))
				add_to_ignore(target)
				target = null
				mode = BOT_IDLE
				return

		else if(!bot_move(target))
			target = null
			mode = BOT_IDLE
			return

	oldloc = loc


/mob/living/simple_animal/bot/floorbot/proc/inc_amount_callback()
	if(QDELETED(src))
		return
	amount++
	set_anchored(FALSE)
	mode = BOT_IDLE
	target = null


/mob/living/simple_animal/bot/floorbot/proc/nag() //Annoy everyone on the channel to refill us!
	if(!nagged)
		speak("Запрашивается пополнение стройматериалов в локации <b>[get_area(src)]</b>!", radio_channel)
		nagged = TRUE


/mob/living/simple_animal/bot/floorbot/proc/is_hull_breach(turf/t) //Ignore space tiles not considered part of a structure, also ignores shuttle docking areas.
	var/area/t_area = get_area(t)
	if(t_area && (t_area.name == "Space" || findtext(t_area.name, "huttle")))
		return FALSE
	return TRUE


/**
 * Floorbots, having several functions, need sort out special conditions here.
 */
/mob/living/simple_animal/bot/floorbot/process_scan(atom/scan_target)
	var/result
	var/turf/simulated/floor/F
	switch(process_type)
		if(HULL_BREACH) //The most common job, patching breaches in the station's hull.
			if(is_hull_breach(scan_target)) //Ensure that the targeted space turf is actually part of the station, and not random space.
				result = scan_target
				set_anchored(TRUE) //Prevent the floorbot being blown off-course while trying to reach a hull breach.
		if(BRIDGE_MODE) //Only space turfs in our chosen direction are considered.
			if(get_dir(src, scan_target) == targetdirection)
				result = scan_target
				set_anchored(TRUE)
		if(REPLACE_TILE)
			F = scan_target
			if(istype(F, /turf/simulated/floor/plating)) //The floor must not already have a tile.
				result = F
		if(FIX_TILE)	//Selects only damaged floors.
			F = scan_target
			if(istype(F) && (F.broken || F.burnt))
				result = F
		if(TILE_EMAG) //Emag mode! Rip up the floor and cause breaches to space!
			F = scan_target
			if(!istype(F, /turf/simulated/floor/plating))
				result = F
		else //If no special processing is needed, simply return the result.
			result = scan_target
	return result


/mob/living/simple_animal/bot/floorbot/proc/repair(turf/target_turf)
	if(isspaceturf(target_turf))
		//Must be a hull breach or in bridge mode to continue.
		if(!is_hull_breach(target_turf) && !targetdirection)
			target = null
			return

	else if(!isfloorturf(target_turf))
		return

	if(amount <= 0)
		mode = BOT_IDLE
		target = null
		return

	set_anchored(TRUE)

	if(isspaceturf(target_turf)) //If we are fixing an area not part of pure space, it is
		custom_emote(EMOTE_VISIBLE, "[targetdirection ? "начинает строить сегмент моста." : "начинает заделывать пробоину."]")
		mode = BOT_REPAIRING
		update_icon()
		addtimer(CALLBACK(src, PROC_REF(make_bridge_plating), target_turf), 5 SECONDS)

	else
		var/turf/simulated/floor/F = target_turf
		mode = BOT_REPAIRING
		update_icon()
		custom_emote(EMOTE_VISIBLE, "начинает ремонтировать пол.")
		addtimer(CALLBACK(src, PROC_REF(make_bridge_plating), F), 5 SECONDS)


/mob/living/simple_animal/bot/floorbot/proc/make_floor(turf/simulated/floor/F)
	if(mode != BOT_REPAIRING)
		return
	F.broken = FALSE
	F.burnt = FALSE
	F.ChangeTurf(/turf/simulated/floor/plasteel)
	mode = BOT_IDLE
	amount--
	update_icon()
	set_anchored(FALSE)
	target = null


/mob/living/simple_animal/bot/floorbot/proc/make_bridge_plating(turf/target_turf)
	if(QDELETED(src) || QDELETED(target_turf) || mode != BOT_REPAIRING)
		return
	if(autotile) //Build the floor and include a tile.
		target_turf.ChangeTurf(/turf/simulated/floor/plasteel)
	else //Build a hull plating without a floor tile.
		target_turf.ChangeTurf(/turf/simulated/floor/plating)
	mode = BOT_IDLE
	amount--
	update_icon()
	set_anchored(FALSE)
	target = null


/mob/living/simple_animal/bot/floorbot/proc/start_eattile(obj/item/stack/tile/plasteel/T)
	if(!istype(T, /obj/item/stack/tile/plasteel))
		return
	custom_emote(EMOTE_VISIBLE, "начинает собирать плитки.")
	mode = BOT_REPAIRING
	addtimer(CALLBACK(src, PROC_REF(do_eattile), T), 2 SECONDS)


/mob/living/simple_animal/bot/floorbot/proc/do_eattile(obj/item/stack/tile/plasteel/T)
	if(QDELETED(src) || QDELETED(T))
		return
	if(isnull(T))
		target = null
		mode = BOT_IDLE
		return
	if(amount + T.amount > T.max_amount)
		var/i = T.max_amount - amount
		amount += i
		T.use(i)
	else
		amount += T.amount
		qdel(T)
	target = null
	mode = BOT_IDLE
	update_icon()


/mob/living/simple_animal/bot/floorbot/proc/start_maketile(obj/item/stack/sheet/metal/M)
	if(!istype(M, /obj/item/stack/sheet/metal))
		return
	custom_emote(EMOTE_VISIBLE, "начинает создавать плитки.")
	mode = BOT_REPAIRING
	addtimer(CALLBACK(src, PROC_REF(do_maketile), M), 2 SECONDS)


/mob/living/simple_animal/bot/floorbot/proc/do_maketile(obj/item/stack/sheet/metal/M)
	if(QDELETED(src))
		return
	if(isnull(M))
		target = null
		mode = BOT_IDLE
		return
	new /obj/item/stack/tile/plasteel(M.loc, 4)
	if(M.amount > 1)
		M.amount--
	else
		qdel(M)
	target = null
	mode = BOT_IDLE
	update_icon()


/mob/living/simple_animal/bot/floorbot/update_icon_state()
	if(mode == BOT_REPAIRING)
		icon_state = "[toolbox_color]floorbot-c"
		return

	if(amount > 0)
		icon_state = "[toolbox_color]floorbot[on]"
	else
		icon_state = "[toolbox_color]floorbot[on]e"


/mob/living/simple_animal/bot/floorbot/explode()
	on = FALSE
	visible_message(span_userdanger("[capitalize(declent_ru(NOMINATIVE))] разлетается на части!"))
	var/turf/Tsec = get_turf(src)
	var/obj/item/storage/toolbox/mechanical/N = new /obj/item/storage/toolbox/mechanical(Tsec)
	N.contents = list()
	new /obj/item/assembly/prox_sensor(Tsec)
	if(prob(50))
		drop_part(robot_arm, Tsec)

	while(amount)//Dumps the tiles into the appropriate sized stacks
		if(amount >= 16)
			new /obj/item/stack/tile/plasteel(Tsec, 16)
			amount -= 16
		else
			new /obj/item/stack/tile/plasteel(Tsec, amount)
			amount = 0

	do_sparks(3, TRUE, src)
	..()


/mob/living/simple_animal/bot/floorbot/OnUnarmedAttack(atom/A)
	if(isturf(A))
		repair(A)
	else if(istype(A,/obj/item/stack/tile/plasteel))
		start_eattile(A)
	else if(istype(A,/obj/item/stack/sheet/metal))
		start_maketile(A)
	else
		..()


/obj/machinery/bot_core/floorbot
	req_access = list(ACCESS_CONSTRUCTION, ACCESS_ROBOTICS)

