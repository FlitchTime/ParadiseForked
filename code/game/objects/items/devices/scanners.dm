/*
CONTAINS:
T-RAY
HEALTH ANALYZER
GAS ANALYZER
REAGENT SCANNER
SLIME SCANNER
BODY SCANNERS
*/

////////////////////////////////////////
// MARK:	T-ray scanners
////////////////////////////////////////
/obj/item/t_scanner
	name = "T-ray scanner"
	desc = "A terahertz-ray emitter and scanner used to detect underfloor objects such as cables and pipes."
	gender = MALE
	icon = 'icons/obj/device.dmi'
	icon_state = "t-ray0"
	base_icon_state = "t-ray"
	var/on = FALSE
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	item_state = "electronic"
	materials = list(MAT_METAL=150)
	origin_tech = "magnets=1;engineering=1"
	var/scan_range = 1
	var/pulse_duration = 1 SECONDS

/obj/item/t_scanner/extended_range
	name = "T-ray сканер расширенной дальности"
	desc = "Излучатель и сканер терагерцевого излучения, используемый для обнаружения скрытых объектов и объектов под полом, таких как кабели и трубы. \
	\nДанная модель обладает расширенным радиусом действия."
	icon_state = "t-ray-range0"
	base_icon_state = "t-ray-range"
	scan_range = 3
	origin_tech = "magnets=2;engineering=3"
	materials = list(MAT_METAL=300)

/obj/item/t_scanner/longer_pulse
	name = "T-ray сканер с продолжительным импульсом"
	desc = "Излучатель и сканер терагерцевого излучения, используемый для обнаружения скрытых объектов и объектов под полом, таких как кабели и трубы. \
	\nДанная модель способна генерировать более продолжительные импульсы."
	icon_state = "t-ray-pulse0"
	base_icon_state = "t-ray-pulse"
	pulse_duration = 5 SECONDS
	origin_tech = "magnets=2;engineering=3"
	materials = list(MAT_METAL=300)

/obj/item/t_scanner/advanced
	name = "Продвинутый T-ray сканер"
	desc = "Излучатель и сканер терагерцевого излучения, используемый для обнаружения скрытых объектов и объектов под полом, таких как кабели и трубы. \
	\nДанная модель способна генерировать более продолжительные импульсы и обладает расширенным радиусом действия."
	icon_state = "t-ray-advanced0"
	base_icon_state = "t-ray-advanced"
	scan_range = 3
	pulse_duration = 5 SECONDS
	origin_tech = "magnets=3;engineering=3"
	materials = list(MAT_METAL=300)

/obj/item/t_scanner/science
	name = "Научный T-ray сканер"
	desc = "Излучатель и сканер терагерцевого излучения, используемый для обнаружения скрытых объектов и объектов под полом, таких как кабели и трубы. \
	\nВысокотехнологичная модель, способная генерировать очень продолжительные импульсы в пределах большого радиуса."
	icon_state = "t-ray-science0"
	base_icon_state = "t-ray-science"
	scan_range = 5
	pulse_duration = 10 SECONDS
	origin_tech = "magnets=4;engineering=5"
	materials = list(MAT_METAL=500)

/obj/item/t_scanner/experimental	//a high-risk that cannot be disassembled, since this garbage was invented by, well, you know who.
	name = "Экспериментальный T-ray сканер"
	desc = "Излучатель и сканер терагерцевого излучения, используемый для обнаружения скрытых объектов и объектов под полом, таких как кабели и трубы. \
	\nЭкспериментальный образец, обладающий расширенным радиусом действия и более продолжительным импульсом. \
	\nСудя по его виду, эта вещь была собрана безумными учеными в ходе спонтанных экспериментов."
	icon_state = "t-ray-experimental0"
	base_icon_state = "t-ray-experimental"
	scan_range = 3
	pulse_duration = 8 SECONDS
	origin_tech = null
	materials = list()
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/t_scanner/Destroy()
	if(on)
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/t_scanner/update_icon_state()
	icon_state = "[base_icon_state][on]"

/obj/item/t_scanner/proc/toggle_mode()
	on = !on
	update_icon(UPDATE_ICON_STATE)
	if(on)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)

/obj/item/t_scanner/attack_self(mob/user)
	toggle_mode()

/obj/item/t_scanner/process()
	if(!on)
		STOP_PROCESSING(SSobj, src)
		return null
	scan()

/obj/item/t_scanner/proc/scan()
	t_ray_scan(loc, pulse_duration, scan_range)

/proc/t_ray_scan(mob/viewer, flick_time, distance)
	if(!ismob(viewer) || !viewer.client)
		return
	var/list/t_ray_images = list()
	for(var/atom/movable/in_turf_atom in orange(distance, viewer))
		if(!isobj(in_turf_atom) && !isliving(in_turf_atom))
			continue

		if(isobj(in_turf_atom))
			var/obj/in_turf_object = in_turf_atom
			if(in_turf_object.level != 1)
				continue

			if(in_turf_object.invisibility != INVISIBILITY_MAXIMUM && in_turf_object.invisibility != INVISIBILITY_ANOMALY)
				continue

		if(isliving(in_turf_atom))
			var/mob/living/in_turf_living = in_turf_atom
			if(!(in_turf_living.alpha < 255 || in_turf_living.invisibility == INVISIBILITY_LEVEL_TWO))
				continue

		var/turf/T = get_turf(in_turf_atom)
		var/image/I = new(loc = T)
		var/mutable_appearance/MA = new(in_turf_atom)
		MA.alpha = isliving(in_turf_atom) ? 255 : 128
		MA.dir = in_turf_atom.dir
		if(MA.layer < TURF_LAYER)
			MA.layer += TRAY_SCAN_LAYER_OFFSET
		MA.plane = GAME_PLANE
		SET_PLANE_EXPLICIT(MA, GAME_PLANE, T)
		I.appearance = MA
		t_ray_images += I

	if(length(t_ray_images))
		flick_overlay(t_ray_images, list(viewer.client), flick_time)

/obj/item/t_scanner/security
	name = "Противо-маскировочное ТГц устройство"
	desc = "Излучатель терагерцевого типа используемый для сканирования области на наличие замаскированных биоорганизмов. Устройство уязвимо для ЭМИ излучения."
	icon = 'icons/obj/device.dmi'
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	item_state = "sb_t-ray"
	icon_state = "sb_t-ray0"
	base_icon_state = "sb_t-ray"
	scan_range = 2
	var/was_alerted = FALSE // Protection against spam alerts from this scanner
	var/burnt = FALSE // Did emp break us?
	var/datum/effect_system/spark_spread/spark_system	//The spark system, used for generating... sparks?
	origin_tech = "combat=3;magnets=5;biotech=5"


/obj/item/t_scanner/security/Initialize()
	. = ..()
	//Sets up a spark system
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)


/obj/item/t_scanner/security/update_icon_state()
	if(burnt)
		icon_state = "[base_icon_state]_burnt"
		return
	icon_state = "[base_icon_state][on]"


/obj/item/t_scanner/security/update_desc(updates = ALL)
	. = ..()
	if(!burnt)
		desc = initial(desc)
		return
	desc = "Излучатель терагерцевого типа используемый для сканирования области на наличие замаскированных биоорганизмов. Устройство сгорело, теперь можно обнаружить разве что крошки от пончика оставшиеся на нём..."


/obj/item/t_scanner/security/attack_self(mob/user)
	if(!burnt)
		on = !on
		update_icon(UPDATE_ICON_STATE)

	if(on)
		START_PROCESSING(SSprocessing, src)
	else
		STOP_PROCESSING(SSprocessing, src)


/obj/item/t_scanner/security/emp_act(severity)
	. = ..()
	if(prob(25) && !burnt)
		burnt = TRUE
		on = FALSE
		update_appearance(UPDATE_ICON_STATE|UPDATE_DESC)
		playsound(loc, "sparks", 50, TRUE, 5)
		spark_system.start()


/obj/item/t_scanner/security/scan()
	var/mob/viewer = loc
	if(!ismob(viewer) || !viewer.client)
		return
	new /obj/effect/temp_visual/scan(get_turf(src))
	var/list/t_ray_images = list()

	for(var/atom/movable/invisible_object as anything in view(scan_range, get_turf(src)))
		if(!(istype(invisible_object, /obj/structure/closet/cardboard/agent/) || isliving(invisible_object)))
			continue
		if(!(invisible_object.alpha < 255 || invisible_object.invisibility == INVISIBILITY_LEVEL_TWO))
			continue
		var/image/I = new(loc = get_turf(invisible_object))
		var/mutable_appearance/MA = new(invisible_object)
		MA.alpha = 255
		MA.dir = invisible_object.dir
		if(MA.layer < TURF_LAYER)
			MA.layer += TRAY_SCAN_LAYER_OFFSET
		MA.plane = GAME_PLANE
		I.appearance = MA
		t_ray_images += I
		alert_searchers(invisible_object)

	if(length(t_ray_images))
		flick_overlay(t_ray_images, list(viewer.client), pulse_duration)

/obj/item/t_scanner/security/proc/alert_searchers(mob/living/found_mob)
	var/list/alerted = viewers(7, found_mob)
	if(alerted && !was_alerted)
		for(var/mob/living/alerted_mob in alerted)
			if(!alerted_mob.stat)
				do_alert_animation(alerted_mob)
				alerted_mob.playsound_local(alerted, 'sound/machines/chime.ogg', 15, 0)
		was_alerted = TRUE
		addtimer(CALLBACK(src, PROC_REF(end_alert_cd)), 1 MINUTES)

/obj/item/t_scanner/security/proc/end_alert_cd()
	was_alerted = FALSE

/proc/chemscan(mob/living/user, mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.reagents)
			if(H.reagents.reagent_list.len)
				to_chat(user, span_notice("Subject contains the following reagents:"))
				for(var/datum/reagent/R in H.reagents.reagent_list)
					to_chat(user, "<span class='notice'>[R.volume]u of [R.name][R.overdosed ? "</span> – [span_boldannounceic("OVERDOSING")]" : ".</span>"]")
			else
				to_chat(user, span_notice("Subject contains no reagents."))
			if(H.reagents.addiction_list.len)
				to_chat(user, span_danger("Subject is addicted to the following reagents:"))
				for(var/datum/reagent/R in H.reagents.addiction_list)
					to_chat(user, span_danger("[R.name] Stage: [R.addiction_stage]/5"))
			else
				to_chat(user, span_notice("Subject is not addicted to any reagents."))

////////////////////////////////////////
// MARK:	Health analyser
////////////////////////////////////////
/obj/item/healthanalyzer
	name = "health analyzer"
	desc = "Ручной сканер тела, способный определить жизненные показатели субъекта."
	ru_names = list(
		NOMINATIVE = "анализатор здоровья",
		GENITIVE = "анализатора здоровья",
		DATIVE = "анализатору здоровья",
		ACCUSATIVE = "анализатор здоровья",
		INSTRUMENTAL = "анализатором здоровья",
		PREPOSITIONAL = "анализаторе здоровья"
	)
	icon = 'icons/obj/device.dmi'
	icon_state = "health"
	item_state = "healthanalyzer"
	belt_icon = "health_analyzer"
	flags = CONDUCT
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=200)
	origin_tech = "magnets=1;biotech=1"
	var/mode = 1
	var/advanced = FALSE
	var/theme

	var/scan_title
	var/scan_data

	var/reports_printed = 0
	var/reports_per_device = 20

	var/isPrinting = FALSE

	var/datum/money_account/connected_acc = null

	var/mob/scanned = null

/obj/item/healthanalyzer/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	add_fingerprint(user)
	scan_title = "Сканирование: [target]"
	scan_data = medical_scan_action(user, target, src, mode, advanced)
	show_results(user)
	return ATTACK_CHAIN_PROCEED_SUCCESS


/obj/item/healthanalyzer/attack_self(mob/user)
	if(!scan_data)
		to_chat(user, span_notice("[capitalize(declent_ru(NOMINATIVE))] не содержит сохранённых данных."))
		return
	show_results(user)

/obj/item/healthanalyzer/proc/print_report_verb()
	set name = "Печать отчёта"
	set category = STATPANEL_OBJECT
	set src = usr

	var/mob/user = usr
	if(!istype(user))
		return
	if(user.incapacitated())
		return
	print_report(user)

/obj/item/healthanalyzer/proc/print_report(var/mob/living/user)
	if(!scan_data)
		to_chat(user, "Нет данных для печати.")
		return
	isPrinting = TRUE
	if(reports_printed > reports_per_device || GLOB.copier_items_printed >= GLOB.copier_max_items)
		visible_message(span_warning("Ничего не происходит. Устройство печати сломано?"))
		if(!GLOB.copier_items_printed_logged)
			message_admins("Photocopier cap of [GLOB.copier_max_items] papers reached, all photocopiers/printers are now disabled. This may be the cause of any lag.")
			GLOB.copier_items_printed_logged = TRUE
		sleep(3 SECONDS)
		isPrinting = FALSE
		return

	playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, TRUE)
	flick("health_anim", src)
	sleep(3 SECONDS)
	var/obj/item/paper/P = new(drop_location())

	P.name = scan_title
	P.header += "<center><b>[scan_title]</b></center><br>"
	P.header += "<b>Время сканирования:</b> [station_time_timestamp()]<br><br>"
	P.header += "<hr>"

	if(scan_data["status"] == 2)
		P.header += "Состояние: <font color='red'><b>Смерть</b></font><br>"
	else
		P.header += "Состояние: [scan_data["status"] > 1 ? "<font color='red'><b>Смерть</b></font>" : scan_data["health"] > 0 ? "[scan_data["health"]]%" : "<font color='red'><b>[scan_data["health"]]%</b></font>"]<br>"

	P.header += "Тип повреждений: <font color='#0080ff'>Удушье</font>/<font color='green'>Отравление</font>/<font color='#FF8000'>Терм.</font>/<font color='red'>Мех.</font><br>"
	P.header += "Уровень повреждений: <font color='#0080ff'>[scan_data["damageLevels"]["oxy"]]</font> - <font color='green'>[scan_data["damageLevels"]["tox"]]</font> - <font color='#FF8000'>[scan_data["damageLevels"]["burn"]]</font> - <font color='red'>[scan_data["damageLevels"]["brute"]]</font><br>"
	P.header += "Температура тела: [scan_data["bodyTemperatureC"]] &deg;C ([scan_data["bodyTemperatureF"]] &deg;F)<br>"
	P.header += "Пульс: <font color='[scan_data["pulse_status"] == PULSE_NORM ? "#0080ff" : "red"]'>[scan_data["pulse"]] уд/мин.</font><br>"

	if(scan_data["genes"])
		if(scan_data["genes"] < 40)
			P.header += "<font color='red'><b>Критическая генная нестабильность!</b></font><br>"
		else if(scan_data["genes"] < 70)
			P.header += "<font color='red'><b>Тяжёлая генная нестабильность.</b></font><br>"
		else if(scan_data["genes"] < 85)
			P.header += "<font color='red'>Незначительная генная нестабильность.</font><br>"
		else
			P.header += "Гены стабильны.<br>"

	if(scan_data["bloodData"])
		var/blood_percent = scan_data["bloodData"]["blood_percent"]
		var/blood_volume = scan_data["bloodData"]["blood_volume"]
		var/blood_type = scan_data["bloodData"]["blood_type"]
		var/blood_species = scan_data["bloodData"]["blood_species"]
		var/ru_blood_species = list(
			"Diona" = "Диона",
			"Drask" = "Драск",
			"Grey" = "Грей",
			"Human" = "Человек",
			"Tajaran" = "Таяран",
			"Vulpkanin" = "Вульпканин",
			"Skrell" = "Скрелл",
			"Nian" = "Ниан",
			"Unathi" = "Унатх",
			"Vox" = "Вокс",
			"Wryn" = "Врин",
		)
		if(blood_volume <= BLOOD_VOLUME_SAFE && blood_percent > BLOOD_VOLUME_OKAY)
			P.header += "Уровень крови: [span_red("НИЗКИЙ")] - [blood_percent] %, [blood_volume] u</font>, тип: [blood_type], <br>кровь расы: [ru_blood_species[blood_species]].<br>"
		else if(blood_volume <= BLOOD_VOLUME_OKAY)
			P.header += "Уровень крови: [span_red("<b>КРИТИЧЕСКИЙ</b>")] - [blood_percent] %, [blood_volume] u</b></font>, тип: [blood_type], <br>кровь расы: [ru_blood_species[blood_species]].<br>"
		else
			P.header += "Уровень крови: [blood_percent] %, [blood_volume] u, тип: [blood_type], <br>кровь расы: [ru_blood_species[blood_species]]."

	if(scan_data["timeofdeath"])
		P.header += "Время смерти: [scan_data["timeofdeath"]]<br>"
		if(scan_data["timetodefibText"])
			P.header += span_red("&emsp;Субъект умер [scan_data["timetodefib"]] назад<br>")
			P.header += "&emsp;Дефибриляция возможна!</font><br>"
		else
			P.header += span_red("&emsp;Субъект умер [scan_data["timetodefib"]] назад<br>")

	if(scan_data["damageLocalization"])
		P.header += "<hr>"
		P.header += "Локализация повреждений, <font color='#FF8000'>Терм.</font>/<font color='red'>Мех.</font>:<br>"
		for(var/damage in scan_data["damageLocalization"])
			P.header += "&emsp;[span_notice(capitalize(damage["name"]))]: <span style='color: red;'><font color='#FF8000'>[damage["burn"]]</font> - <font color='red'>[damage["brute"]]</font><br>"

	if(scan_data["fractureList"])
		for(var/fracture in scan_data["fractureList"])
			P.header += span_red("Обнаружен перелом в [fracture].<br>")

	if(scan_data["infectedList"])
		for(var/infection in scan_data["infectedList"])
			P.header += span_red("Заражение в [infection].<<br>")

	if(scan_data["extraFacture"] == 1)
		P.header += span_red("Обнаружено перелом. Локализация невозможна.<br>")

	if(scan_data["extraBleeding"] == 1)
		P.header += span_red("Обнаружено внутреннее кровотечение. Локализация невозможна.<br>")

	if(scan_data["reagentList"])
		P.header += "Обнаружены реагенты:<br>"
		for(var/reagent in scan_data["reagentList"])
			P.header += "&emsp;[reagent["volume"]]u [reagent["name"]] [reagent["overdosed"] == "1" ? " - <b>ПЕРЕДОЗИРОВКА</b>" : "."]<br>"
	else
		P.header += "Реагенты не обнаружены.<br>"

	if(scan_data["addictionList"])
		P.header += "<b>Обнаружены зависимости от реагентов:</b><br>"
		for(var/addiction in scan_data["addictionList"])
			P.header += span_red("&emsp;[addiction["name"]] Стадия: [addiction["addiction_stage"]]/5<br>")
	else
		P.header += "Зависимости от реагентов не обнаружены.<br>"

	P.header += "<hr>"

	if(scan_data["diseases"])
		for(var/disease in scan_data["diseases"])
			P.header += "<font color='red'><b>Внимание: [disease["form"]]</b></font><br>"
			P.header += "&emsp;Название: [disease["name"]]<br>"
			P.header += "&emsp;Тип: [disease["additional_info"]]<br>"
			P.header += "&emsp;Стадия: [disease["stage"]]/[disease["max_stages"]]<br>"
			P.header += "&emsp;Лечение: [disease["cure_text"]]<br>"

	if(scan_data["heartCondition"] == "CRIT")
		P.header += "<font color='#d82020'><b>Внимание: Критическое состояние</b></font><br>"
		P.header += "&emsp;Название: Остановка сердца<br>"
		P.header += "&emsp;Тип: Сердце пациента остановилось<br>"
		P.header += "&emsp;Стадия: 1/1<br>"
		P.header += "&emsp;Лечение: Электрический шок<br>"
	else if(scan_data["heartCondition"] == "NECROSIS")
		P.header += "<font color='#d82020'><b>Обнаружен некроз сердца.</b></font><br>"
	else if(scan_data["heartCondition"] == "LESS")
		P.header += "<font color='#d82020'><b>Сердце не обнаружено.</b></font><br>"

	if(scan_data["staminaStatus"] == 1)
		P.header += span_notice("Обнаружено переутомление.<br>")

	if(scan_data["cloneStatus"] > 0)
		P.header += "<font color='#d82020'>Обнаружено [scan_data["cloneStatus"] > 30 ? "серьёзное" : "незначительное"] клеточное повреждение.</font><br>"

	if(scan_data["brainWorms"])
		P.header += "<font color='#d82020'>Обнаружены отклонения в работе мозга.</font><br>"

	if(scan_data["brainDamage"] >= 100)
		P.header += "<font color='#d82020'><b>Мозг мёртв.</b></font><br>"
	else if(scan_data["brainDamage"] >= 60)
		P.header += "<font color='#d82020'><b>Обнаружено серьёзное повреждение мозга.</b></font><br>"
	else if(scan_data["brainDamage"] >= 10)
		P.header += "<font color='#d82020'>Обнаружено значительное повреждение мозга.</font><br>"
	else if(scan_data["brainDamage"] == "LESS")
		P.header += "<font color='#d82020'><b>Мозг не обнаружен.</b></font><br>"

	if(scan_data["implantDetect"])
		P.header += "Обнаружены кибернетические модификации:<br>"
		for(var/implant in scan_data["implantDetect"])
			P.header += "&emsp;[implant]<br>"

	P.header += "<hr>"
	P.header += "Тип страховки - [scan_data["insuranceType"]].<br>"
	P.header += "Требуемое количество очков страховки: [scan_data["reqInsurance"]].<br>"
	if(scan_data["insurance"])
		P.header += "Текущее количество очков страховки: [scan_data["insurance"]].<br>"

	P.info += "<br><br><b>Заметки:</b><br>"

	if(in_range(user, src))
		user.put_in_hands(P, ignore_anim = FALSE)
		user.visible_message(span_notice("[capitalize(declent_ru(NOMINATIVE))] дребезжит, после чего из окна печати выпадает лист бумаги."))
	GLOB.copier_items_printed++
	reports_printed++
	isPrinting = FALSE

/obj/item/healthanalyzer/proc/show_results(mob/user)
	SStgui.update_uis(src)
	ui_interact(user)

/obj/item/healthanalyzer/examine(mob/user)
	. = ..()
	if(scan_data)
		if(in_range(user, src) || istype(user, /mob/dead/observer))
			show_results(user)
		else
			. += span_notice("Нужно подойти ближе, чтобы прочесть содержмое.")

/obj/item/healthanalyzer/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Healthanalyzer")
		ui.open()

/obj/item/healthanalyzer/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	switch(action)
		if("clear")
			to_chat(usr, "Вы очистили буфер данных [declent_ru(ACCUSATIVE)].")
			scan_data = null
			scan_title = null
		if("localize")
			to_chat(usr, "Вы переключили локализацию повреждений [declent_ru(ACCUSATIVE)].")
			toggle_mode()
		if("print")
			if(!isPrinting)
				print_report(usr)
		if("insurance")
			do_insurance_collection(usr, scanned, connected_acc)
		else
			return TRUE

	SStgui.update_uis(src)
	playsound(loc, "terminal_type", 25, TRUE)
	return TRUE

/obj/item/healthanalyzer/ui_data(mob/user)
	var/list/data = list()
	data["localize"] = mode
	data["advanced"] = advanced
	data["scan_title"] = scan_title
	data["theme"] = theme
	data["scan_data"] = scan_data

	return data

/obj/item/healthanalyzer/proc/medical_scan_action(mob/living/user, atom/target, var/obj/item/healthanalyzer/scanner, var/mode, var/advanced)
	if(!user.IsAdvancedToolUser())
		to_chat(user, span_warning("Вам не хватает ловкости, чтобы использовать [declent_ru(ACCUSATIVE)]!"))
		balloon_alert(user, "невозможно!")
		return

	if((HAS_TRAIT(user, TRAIT_CLUMSY) || user.getBrainLoss() >= 60) && prob(50))
		user.visible_message(
			span_warning("[user] анализиру[pluralize_ru(user.gender, "ет", "ют")] жизненные показатели пола!"),
			span_notice("Вы по глупости проанализировали жизненные показатели пола!")
		)
		var/list/data = list()
		data["status"] = "FLOOR"
		return data

	if(!ishuman(target) || ismachineperson(target))
		var/list/data = list()
		data["status"] = "ERROR"
		return data

	var/mob/living/carbon/human/scan_subject = null
	if(ishuman(target))
		scan_subject = target
	else if(istype(target, /obj/structure/closet/body_bag))
		var/obj/structure/closet/body_bag/B = target
		if(!B.opened)
			var/list/scan_content = list()
			for(var/mob/living/L in B.contents)
				scan_content.Add(L)

			if(scan_content.len == 1)
				for(var/mob/living/carbon/human/L in scan_content)
					scan_subject = L
			else if(scan_content.len > 1)
				balloon_alert(user, "внутри слишком много субъектов!")
				return
			else
				balloon_alert(user, "внутри пусто!")
				return

	if(!scan_subject)
		return

	if(user == target)
		user.visible_message(
			span_notice("[user] сканиру[pluralize_ru(user.gender,"ет","ют")] себя с помощью [declent_ru(GENITIVE)]."),
			span_notice("Вы сканируете себя с помощью [declent_ru(GENITIVE)].")
		)
	else
		user.visible_message(
			span_notice("[user] сканиру[pluralize_ru(user.gender,"ет","ют")] [target] с помощью [declent_ru(GENITIVE)]."),
			span_notice("Вы сканируете [target] с помощью [declent_ru(GENITIVE)].")
		)
	var/mob/living/carbon/human/H = target
	var/list/data = medical_scan_results(H, mode, advanced)
	scanner.scanned = scan_subject
	return data

// Scan data to TGUI
/proc/medical_scan_results(var/mob/living/M, var/mode = 1, var/advanced = FALSE)
	var/mob/living/carbon/human/H = M
	var/list/data = list()
	var/DNR = !H.ghost_can_reenter()
	if(HAS_TRAIT(H, TRAIT_FAKEDEATH))
		data["status"] = 2
	else
		data["status"] = H.stat
	data["health"] = H.health
	data["pulse_status"] = H.pulse
	data["pulse"] = H.get_pulse(GETPULSE_TOOL)

	if(H.timeofdeath)
		data["timeofdeath"] = "[station_time_timestamp("hh:mm:ss", H.timeofdeath)]"
		var/tdelta = round(world.time - H.timeofdeath)
		if(tdelta < DEFIB_TIME_LIMIT && !DNR)
			data["timetodefib"] = "[DisplayTimeText(tdelta)]"
			data["timetodefibText"] = "Дефибриляция возможна!"
		else
			data["timetodefib"] = "[DisplayTimeText(tdelta)]"

	var/oxyDamage = "[H.getOxyLoss()]"
	if(HAS_TRAIT(H, TRAIT_FAKEDEATH))
		oxyDamage = "[max(rand(1,40), H.getOxyLoss(), (300 - (H.getToxLoss() + H.getFireLoss() + H.getBruteLoss())))]"
	data["damageLevels"] = list(
		oxy =  oxyDamage,
		tox = "[H.getToxLoss()]",
		burn = "[H.getFireLoss()]",
		brute = "[H.getBruteLoss()]",
	)

	data["bodyTemperatureC"] = "[H.bodytemperature-T0C]"
	data["bodyTemperatureF"] = "[H.bodytemperature*1.8-459.67]"
	data["genes"] = H.gene_stability
	data["DRN"] = DNR

	var/blood_id = H.get_blood_id()
	if(blood_id)
		if(H.bleed_rate)
			data["bleed"] = TRUE

		var/blood_percent =  round((H.blood_volume / BLOOD_VOLUME_NORMAL)*100)
		var/blood_type = H.dna.blood_type
		var/blood_species = H.dna.species.blood_species

		if(blood_id != "blood")
			var/datum/reagent/R = GLOB.chemical_reagents_list[blood_id]
			if(R)
				blood_type = R.name
			else
				blood_type = blood_id

		data["bloodData"] = list(
			blood_percent = blood_percent,
			blood_volume = H.blood_volume,
			blood_type = "[blood_type]",
			blood_species = "[blood_species]"
		)

	var/list/damaged = H.get_damaged_organs(1,1)
	var/list/damageLocalization = list()
	if(length(damaged) > 0)
		for(var/obj/item/organ/external/org as anything in damaged)
			damageLocalization += list(list(
				name = "[org.name]",
				burn = "[org.burn_dam]",
				brute = "[org.brute_dam]"
			))
		data["damageLocalization"] = damageLocalization

	if(advanced)
		if(H.reagents)
			if(H.reagents.reagent_list.len)
				var/list/reagentList = list()
				for(var/datum/reagent/R in H.reagents.reagent_list)
					reagentList += list(list(
						volume = "[R.volume]",
						name = "[R.name]",
						overdosed = R.overdosed
					))
				data["reagentList"] = reagentList
			else
				data["reagentList"] = FALSE

			if(H.reagents.addiction_list.len)
				var/list/addictionList = list()
				for(var/datum/reagent/R in H.reagents.addiction_list)
					addictionList += list(list(
						name = "[R.name]",
						addiction_stage = "[R.addiction_stage]"
					))
				data["addictionList"] = addictionList
			else
				data["addictionList"] = FALSE

	var/list/diseases = list()
	for(var/thing in H.diseases)
		var/datum/disease/D = thing
		if(!(D.visibility_flags & HIDDEN_SCANNER))
			diseases += list(list(
				form = "[D.form]",
				name = "[D.name]",
				additional_info = "[D.additional_info]",
				stage = "[D.stage]",
				max_stages = "[D.max_stages]",
				cure_text = "[D.cure_text]"
				)
			)
	data["diseases"] = diseases

	if(H.undergoing_cardiac_arrest())
		var/obj/item/organ/internal/heart/heart = H.get_int_organ(/obj/item/organ/internal/heart)
		if(heart && !heart.is_dead())
			data["heartCondition"] = "CRIT"
		else if(heart && heart.is_dead())
			data["heartCondition"] = "NECROSIS"
		else if(!heart)
			data["heartCondition"] = "LESS"

	if(H.getStaminaLoss())
		data["staminaStatus"] = TRUE

	if(H.getCloneLoss())
		data["cloneStatus"] = H.getCloneLoss()

	if(H.has_brain_worms())
		data["brainWorms"] = TRUE

	if(H.get_int_organ(/obj/item/organ/internal/brain))
		data["brainDamage"] = H.getBrainLoss()
	else
		data["brainDamage"] = "LESS"

	var/list/fractureList = list()
	var/list/infectedList = list()
	for(var/name in H.bodyparts_by_name)
		var/obj/item/organ/external/e = H.bodyparts_by_name[name]
		if(!e)
			continue
		var/limb = e.name
		if(e.has_fracture())
			var/list/check_list = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT)
			if((e.limb_zone in check_list) && !e.is_splinted())
				fractureList += "[limb]"
		if(e.has_infected_wound())
			infectedList += "[limb]"

	data["fractureList"] = fractureList
	data["infectedList"] = infectedList


	for(var/name in H.bodyparts_by_name)
		var/obj/item/organ/external/e = H.bodyparts_by_name[name]
		if(!e)
			continue
		if(e.has_fracture())
			data["extraFacture"] = TRUE
			break
	for(var/obj/item/organ/external/e as anything in H.bodyparts)
		if(e.has_internal_bleeding())
			data["extraBleeding"] = TRUE
			break

	var/datum/money_account/acc = get_insurance_account(H)
	if(acc)
		data["insuranceType"] = "[acc.insurance_type]"
	else
		data["insuranceType"] = "Аккаунт не обнаружен."
	data["reqInsurance"] = "[get_req_insurance(H)]"
	if(acc)
		data["insurance"] = "[acc.insurance]"

	var/list/implant_detect = list()
	for(var/obj/item/organ/internal/cyberimp/cybernetics in H.internal_organs)
		if(cybernetics.is_robotic())
			implant_detect += "[cybernetics.name]"
	if(length(implant_detect))
		data["implantDetect"] = implant_detect

	return data


// This is the output to the chat
/proc/healthscan(mob/user, mob/living/M, mode = 1, advanced = FALSE)
	var/list/scan_data = list()
	if(!ishuman(M) || ismachineperson(M))
		//these sensors are designed for organic life
		scan_data += "Состояние: [span_danger("ОШИБКА")]</span></span>"
		scan_data += "Тип повреждений: <font color='#0080ff'>Удушье</font>/<font color='green'>Отравление</font>/<font color='#FF8000'>Терм.</font>/<font color='red'>Мех.</font></span>"
		scan_data += "Уровень повреждений: <font color='#0080ff'>?</font> - <font color='green'>?</font> - <font color='#FF8000'>?</font> - <font color='red'>?</font></span>"
		scan_data += "Температура тела: [M.bodytemperature-T0C] &deg;C ([M.bodytemperature*1.8-459.67] &deg;F)</span>"
		scan_data += "Уровень крови: --- %, --- u, тип: ---</span>"
		scan_data += "Пульс: <font color='#0080ff'>--- bpm.</font></span>"
		scan_data += "Гены не обнаружены."
		to_chat(user, chat_box_healthscan("[jointext(scan_data, "<br>")]"))
		return

	var/mob/living/carbon/human/H = M
	var/fake_oxy = max(rand(1,40), H.getOxyLoss(), (300 - (H.getToxLoss() + H.getFireLoss() + H.getBruteLoss())))
	var/OX = H.getOxyLoss() > 50 	? 	"<b>[H.getOxyLoss()]</b>" 		: H.getOxyLoss()
	var/TX = H.getToxLoss() > 50 	? 	"<b>[H.getToxLoss()]</b>" 		: H.getToxLoss()
	var/BU = H.getFireLoss() > 50 	? 	"<b>[H.getFireLoss()]</b>" 		: H.getFireLoss()
	var/BR = H.getBruteLoss() > 50 	? 	"<b>[H.getBruteLoss()]</b>" 	: H.getBruteLoss()
	var/DNR = !H.ghost_can_reenter()
	if(H.stat == DEAD)
		if(DNR)
			scan_data += "Состояние: [span_danger("Смерть<b>\[НР\]</b>")]"
		else
			scan_data += "Состояние: [span_danger("Смерть")]"
	else //Если живой или отключка
		if(HAS_TRAIT(H, TRAIT_FAKEDEATH))
			OX = fake_oxy > 50 			? 	"<b>[fake_oxy]</b>" 			: fake_oxy
			scan_data += "Состояние: [span_danger("Смерть")]"
		else
			scan_data += "Состояние: [H.stat > 1 ? span_danger("Смерть") : (H.health > 0 ? "[H.health]%" : span_danger("[H.health]%"))]"
	scan_data += "Тип повреждений: <font color='#0080ff'>Удушье</font>/<font color='green'>Отравление</font>/<font color='#FF8000'>Терм.</font>/<font color='red'>Мех.</font>"
	scan_data += "Уровень повреждений: <font color='#0080ff'>[OX]</font> - <font color='green'>[TX]</font> - <font color='#FF8000'>[BU]</font> - <font color='red'>[BR]</font>"
	scan_data += "Температура тела: [H.bodytemperature-T0C] &deg;C ([H.bodytemperature*1.8-459.67] &deg;F)"
	if(H.timeofdeath && (H.stat == DEAD || HAS_TRAIT(H, TRAIT_FAKEDEATH)))
		scan_data += "Время смерти: [station_time_timestamp("hh:mm:ss", H.timeofdeath)]"
		var/tdelta = round(world.time - H.timeofdeath)
		if(tdelta < DEFIB_TIME_LIMIT && !DNR)
			scan_data += span_danger("&emsp;Субъект умер [DisplayTimeText(tdelta)] назад")
			scan_data += span_danger("&emsp;Дефибриляция возможна!")
		else
			scan_data += span_danger("&emsp;Субъект умер [DisplayTimeText(tdelta)] назад")
	if(mode == 1)
		var/list/damaged = H.get_damaged_organs(1,1)
		scan_data += "Локализация повреждений, <font color='#FF8000'>Терм.</font>/<font color='red'>Мех.</font>:"
		if(length(damaged) > 0)
			for(var/obj/item/organ/external/org as anything in damaged)
				scan_data += "&emsp;[span_notice(capitalize(org.name))]: [(org.burn_dam > 0) ? "<font color='#FF8000'>[org.burn_dam]</font>" : "<font color='#FF8000'>0</font>"] - [(org.brute_dam > 0) ? "<font color='red'>[org.brute_dam]</font>" : "<font color='red'>0</font>"]"
	if(advanced)
		if(H.reagents)
			if(H.reagents.reagent_list.len)
				scan_data += "Обнаружены реагенты:"
				for(var/datum/reagent/R in H.reagents.reagent_list)
					scan_data += "&emsp;[R.volume]u [R.name][R.overdosed ? " - [span_boldannounceic("ПЕРЕДОЗИРОВКА")]" : "."]"
			else
				scan_data += "Реагенты не обнаружены."
			if(H.reagents.addiction_list.len)
				scan_data += span_danger("Обнаружены зависимости от реагентов:")
				for(var/datum/reagent/R in H.reagents.addiction_list)
					scan_data += span_danger("&emsp;[R.name] Стадия: [R.addiction_stage]/5")
			else
				scan_data += "Зависимости от реагентов не обнаружены."
	for(var/thing in H.diseases)
		var/datum/disease/D = thing
		if(!(D.visibility_flags & HIDDEN_SCANNER))
			scan_data += span_warning("<b>Внимание: обнаружен [D.form]</b>")
			scan_data += "&emsp;Название: [D.name]"
			scan_data += "&emsp;Тип: [D.additional_info]"
			scan_data += "&emsp;Стадия: [D.stage]/[D.max_stages]"
			scan_data += "&emsp;Лечение: [D.cure_text]"
	if(H.undergoing_cardiac_arrest())
		var/obj/item/organ/internal/heart/heart = H.get_int_organ(/obj/item/organ/internal/heart)
		if(heart && !heart.is_dead())
			scan_data += span_warning("<b>Внимание: Критическое состояние</b>")
			scan_data += "&emsp;Название: Остановка сердца"
			scan_data += "&emsp;Тип: Сердце пациента остановилось"
			scan_data += "&emsp;Стадия: 1/1"
			scan_data += "&emsp;Лечение: Электрический шок"
		else if(heart && heart.is_dead())
			scan_data += span_alert("<b>Обнаружен некроз сердца.</b>")
		else if(!heart)
			scan_data += span_alert("<b>Сердце не обнаружено.</b>")

	if(H.getStaminaLoss())
		scan_data += span_notice("Обнаружено переутомление.")
	if(H.getCloneLoss())
		scan_data += span_warning("Обнаружено [H.getCloneLoss() > 30 ? "серьёзное" : "незначительное"] клеточное повреждение.")
	if(H.has_brain_worms())
		scan_data += span_warning("Обнаружены отклонения в работе мозга.")

	if(H.get_int_organ(/obj/item/organ/internal/brain))
		if(H.getBrainLoss() >= 100)
			scan_data += span_warning("Мозг мёртв.")
		else if(H.getBrainLoss() >= 60)
			scan_data += span_warning("Обнаружено серьёзное повреждение мозга.")
		else if(H.getBrainLoss() >= 10)
			scan_data += span_warning("Обнаружено значительное повреждение мозга.")
	else
		scan_data += span_warning(">Мозг не обнаружен.")

	for(var/name in H.bodyparts_by_name)
		var/obj/item/organ/external/e = H.bodyparts_by_name[name]
		if(!e)
			continue
		var/limb = e.name
		if(e.has_fracture())
			var/list/check_list = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT)
			if((e.limb_zone in check_list) && !e.is_splinted())
				scan_data += span_warning("Обнаружен перелом в [limb].")
		if(e.has_infected_wound())
			scan_data += span_warning("Заражение в [limb].")

	for(var/name in H.bodyparts_by_name)
		var/obj/item/organ/external/e = H.bodyparts_by_name[name]
		if(!e)
			continue
		if(e.has_fracture())
			scan_data += span_warning("Обнаружены переломы. Локализация невозможна.")
			break
	for(var/obj/item/organ/external/e as anything in H.bodyparts)
		if(e.has_internal_bleeding())
			scan_data += span_warning("Обнаружено внутреннее кровотечение. Локализация невозможна.")
			break
	var/blood_id = H.get_blood_id()
	if(blood_id)
		if(H.bleed_rate)
			scan_data += span_danger("Обнаружено кровотечение.")
		var/blood_percent =  round((H.blood_volume / BLOOD_VOLUME_NORMAL)*100)
		var/blood_type = H.dna.blood_type
		var/blood_species = H.dna.species.blood_species
		var/ru_blood_species = list(
			"Diona" = "Диона",
			"Drask" = "Драск",
			"Grey" = "Грей",
			"Human" = "Человек",
			"Tajaran" = "Таяран",
			"Vulpkanin" = "Вульпканин",
			"Skrell" = "Скрелл",
			"Nian" = "Ниан",
			"Unathi" = "Унатх",
			"Vox" = "Вокс",
			"Wryn" = "Врин",
		)
		if(blood_id != "blood")//special blood substance
			var/datum/reagent/R = GLOB.chemical_reagents_list[blood_id]
			if(R)
				blood_type = R.name
			else
				blood_type = blood_id
		if(H.blood_volume <= BLOOD_VOLUME_SAFE && H.blood_volume > BLOOD_VOLUME_OKAY)
			scan_data += "Уровень крови: [span_danger("НИЗКИЙ")] - [blood_percent] %, [H.blood_volume] u, тип: [blood_type], кровь расы: [ru_blood_species[blood_species]]."
		else if(H.blood_volume <= BLOOD_VOLUME_OKAY)
			scan_data += "Уровень крови: [span_danger("<b>КРИТИЧЕСКИЙ</b>")] - [blood_percent] %, [H.blood_volume] u, тип: [blood_type], кровь расы: [ru_blood_species[blood_species]]."
		else
			scan_data += "Уровень крови: [blood_percent] %, [H.blood_volume] u, тип: [blood_type], кровь расы: [ru_blood_species[blood_species]]."

	scan_data += "Пульс: <font color='[H.pulse == PULSE_NORM ? "#0080ff" : "red"]'>[H.get_pulse(GETPULSE_TOOL)] уд/мин.</font>"
	var/list/implant_detect = list()
	for(var/obj/item/organ/internal/cyberimp/cybernetics in H.internal_organs)
		if(cybernetics.is_robotic())
			implant_detect += "&emsp;[cybernetics.name]"
	if(length(implant_detect))
		scan_data += "Обнаружены кибернетические модификации:"
		scan_data += implant_detect
	if(H.gene_stability < 40)
		scan_data += span_userdanger("Критическая генная нестабильность.")
	else if(H.gene_stability < 70)
		scan_data += span_danger("Тяжёлая генная нестабильность.")
	else if(H.gene_stability < 85)
		scan_data += span_warning("Незначительная генная нестабильность.")
	else
		scan_data += "Гены стабильны."

	var/datum/money_account/acc = get_insurance_account(H)
	if(acc)
		scan_data += "Тип страховки - [acc.insurance_type]."
	else
		scan_data += "Аккаунт не обнаружен."
	scan_data += "Требуемое количество очков страховки: [get_req_insurance(H)]."
	if(acc)
		scan_data += "Текущее количество очков страховки: [acc.insurance]."
	to_chat(user, chat_box_healthscan("[jointext(scan_data, "<br>")]"))

/obj/item/healthanalyzer/verb/toggle_mode()
	set name = "Вкл/Выкл локализацию"
	set category = STATPANEL_OBJECT

	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return

	mode = !mode
	switch(mode)
		if(1)
			to_chat(usr, "Локализация повреждений включена.")
		if(0)
			to_chat(usr, "Локализация повреждений выключена.")

/obj/item/healthanalyzer/update_overlays()
	. = ..()
	if(advanced)
		. += "advanced"


/obj/item/healthanalyzer/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/healthupgrade))
		add_fingerprint(user)
		if(advanced)
			balloon_alert(user, "уже установлено!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		balloon_alert(user, "модуль установлен")
		playsound(loc, I.usesound, 50, TRUE)
		advanced = TRUE
		update_icon(UPDATE_OVERLAYS)
		qdel(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/card/id))
		add_fingerprint(user)
		if(!advanced)
			to_chat(user, span_warning("Для привязки счёта требуется наличие продвинутого модуля сканирования."))
			return ATTACK_CHAIN_PROCEED

		var/obj/item/card/id/id = I

		if(!id.associated_account_number)
			to_chat(user, span_warning("Привязанный аккаунт не обнаружен."))
			return ATTACK_CHAIN_PROCEED

		connected_acc = id.associated_account_number
		to_chat(user, span_notice("Аккаунт привязан."))
		playsound(loc, I.usesound, 50, TRUE)
		return ATTACK_CHAIN_PROCEED

	return ..()


/obj/item/healthanalyzer/advanced
	advanced = TRUE

/obj/item/healthanalyzer/advanced/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_OVERLAYS)


/obj/item/healthupgrade
	name = "health analyzer upgrade"
	desc = "Модуль, устанавливаемый на анализатор здоровья для расширения его функционала."
	ru_names = list(
		NOMINATIVE = "модуль улучшения анализатора здоровья",
		GENITIVE = "модуля улучшения анализатора здоровья",
		DATIVE = "модулю улучшения анализатора здоровья",
		ACCUSATIVE = "модуль улучшения анализатора здоровья",
		INSTRUMENTAL = "модулем улучшения анализатора здоровья",
		PREPOSITIONAL = "модуле улучшения анализатора здоровья"
	)
	icon = 'icons/obj/device.dmi'
	icon_state = "healthupgrade"
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "magnets=2;biotech=2"
	usesound = 'sound/items/deconstruct.ogg'

/obj/item/healthanalyzer/gem_analyzer
	name = "eye of health"
	desc = "Необычный самоцвет в форме сердца. Позволяет пользователю ощущать раны и болезни других существ на метафизическом уровне. Магия, не иначе."
	ru_names = list(
		NOMINATIVE = "глаз здоровья",
		GENITIVE = "глаза здоровья",
		DATIVE = "глазу здоровья",
		ACCUSATIVE = "глаз здоровья",
		INSTRUMENTAL = "глазом здоровья",
		PREPOSITIONAL = "глазе здоровья"
	)
	icon = 'icons/obj/device.dmi'
	icon_state = "gem_analyzer"
	item_state = "gem_analyzer"
	origin_tech = null

/obj/item/healthanalyzer/gem_analyzer/attackby(obj/item/I, mob/user, params)
	return ATTACK_CHAIN_BLOCKED_ALL

////////////////////////////////////////
// MARK:	Gas analyzer
////////////////////////////////////////
/obj/item/analyzer
	desc = "A hand-held environmental scanner which reports current gas levels."
	name = "analyzer"
	icon = 'icons/obj/device.dmi'
	icon_state = "atmos"
	item_state = "analyzer"
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=30, MAT_GLASS=20)
	origin_tech = "magnets=1;engineering=1"
	tool_behaviour = TOOL_ANALYZER
	var/cooldown = FALSE
	var/cooldown_time = 250
	var/accuracy // 0 is the best accuracy.
	var/list/last_gasmix_data
	var/list/history_gasmix_data
	var/history_gasmix_index = 0
	var/history_view_mode = ANALYZER_HISTORY_MODE_KPA
	var/scan_range = 1
	var/auto_updating = TRUE
	var/target_mode = ANALYZER_MODE_SURROUNDINGS
	var/atom/scan_target

/obj/item/analyzer/examine(mob/user)
	. = ..()
	. += span_notice("To scan an environment, activate it or use it on your location.")
	. += span_notice("Alt-click [src] to activate the barometer function.")

/obj/item/analyzer/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to analyze [user.p_them()]self with [src]! The display shows that [user.p_theyre()] dead!"))
	return BRUTELOSS

/obj/item/analyzer/click_alt(mob/living/user) //Barometer output for measuring when the next storm happens
	if(cooldown)
		to_chat(user, span_warning("[src]'s barometer function is prepraring itself."))
		return CLICK_ACTION_BLOCKING
	var/turf/T = get_turf(user)
	if(!T)
		return NONE
	playsound(src, 'sound/effects/pop.ogg', 100)
	var/area/user_area = T.loc
	var/datum/weather/ongoing_weather = null
	if(!user_area.outdoors)
		to_chat(user, span_warning("[src]'s barometer function won't work indoors!"))
		return CLICK_ACTION_BLOCKING
	for(var/V in SSweather.processing)
		var/datum/weather/W = V
		if(W.barometer_predictable && (T.z in W.impacted_z_levels) && W.area_type == user_area.type && !(W.stage == END_STAGE))
			ongoing_weather = W
			break
	if(ongoing_weather)
		if((ongoing_weather.stage == MAIN_STAGE) || (ongoing_weather.stage == WIND_DOWN_STAGE))
			to_chat(user, span_warning("[src]'s barometer function can't trace anything while the storm is [ongoing_weather.stage == MAIN_STAGE ? "already here!" : "winding down."]"))
			return CLICK_ACTION_BLOCKING
		to_chat(user, span_warning("The next [ongoing_weather] will hit in [butchertime(ongoing_weather.next_hit_time - world.time)]."))
		if(ongoing_weather.aesthetic)
			to_chat(user, span_warning("[src]'s barometer function says that the next storm will breeze on by."))
	else
		var/next_hit = SSweather.next_hit_by_zlevel["[T.z]"]
		var/fixed = next_hit ? next_hit - world.time : -1
		if(fixed < 0)
			to_chat(user, span_warning("[src]'s barometer function was unable to trace any weather patterns."))
		else
			to_chat(user, span_warning("[src]'s barometer function says a storm will land in approximately [butchertime(fixed)]."))
	cooldown = TRUE
	addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/item/analyzer, ping)), cooldown_time)
	return CLICK_ACTION_SUCCESS

/obj/item/analyzer/proc/ping()
	if(isliving(loc))
		var/mob/living/L = loc
		to_chat(L, span_notice("[src]'s barometer function is ready!"))
	playsound(src, 'sound/machines/click.ogg', 100)
	cooldown = FALSE

/// Applies the barometer inaccuracy to the gas reading.
/obj/item/analyzer/proc/butchertime(amount)
	if(!amount)
		return
	if(accuracy)
		var/inaccurate = round(accuracy * (1 / 3))
		if(prob(50))
			amount -= inaccurate
		if(prob(50))
			amount += inaccurate
	return DisplayTimeText(max(1, amount))

/obj/item/analyzer/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GasAnalyzer", name)
		ui.open()

/obj/item/analyzer/ui_data(mob/user)
	var/list/data = list()
	if(auto_updating)
		on_analyze(source=src, target=scan_target)
	LAZYINITLIST(last_gasmix_data)
	LAZYINITLIST(history_gasmix_data)
	data["gasmixes"] = last_gasmix_data
	data["autoUpdating"] = auto_updating
	data["historyGasmixes"] = history_gasmix_data
	data["historyViewMode"] = history_view_mode
	data["historyIndex"] = history_gasmix_index
	return data

/obj/item/analyzer/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("autoscantoggle")
			auto_updating = !auto_updating
			return TRUE
		if("input")
			if(!length(history_gasmix_data))
				return TRUE
			var/target = text2num(params["target"])
			auto_updating = FALSE
			history_gasmix_index = target
			last_gasmix_data = history_gasmix_data[history_gasmix_index]
			return TRUE
		if("clearhistory")
			history_gasmix_data = list()
			return TRUE
		if("modekpa")
			history_view_mode = ANALYZER_HISTORY_MODE_KPA
			return TRUE
		if("modemol")
			history_view_mode = ANALYZER_HISTORY_MODE_MOL
			return TRUE

/// Called when our analyzer is used on something
/obj/item/analyzer/proc/on_analyze(datum/source, atom/target, save_data=TRUE)
	SIGNAL_HANDLER
	LAZYINITLIST(history_gasmix_data)
	switch(target_mode)
		if(ANALYZER_MODE_SURROUNDINGS)
			scan_target = get_turf(src)
		if(ANALYZER_MODE_TARGET)
			scan_target = target
			if(!can_see(target, scan_range))
				target_mode = ANALYZER_MODE_SURROUNDINGS
				scan_target = get_turf(src)
			if(!scan_target)
				target_mode = ANALYZER_MODE_SURROUNDINGS
				scan_target = get_turf(src)

	var/mixture = scan_target?.return_analyzable_air()
	if(!mixture)
		return FALSE
	var/list/airs = islist(mixture) ? mixture : list(mixture)
	var/list/new_gasmix_data = list()
	for(var/datum/gas_mixture/air as anything in airs)
		var/mix_name = capitalize(lowertext(scan_target.name))
		if(scan_target == get_turf(src))
			mix_name = "Location Reading"
		if(airs.len != 1) //not a unary gas mixture
			mix_name += " - Node [airs.Find(air)]"
		new_gasmix_data += list(gas_mixture_parser(air, mix_name))
	last_gasmix_data = new_gasmix_data
	history_gasmix_index = 0
	if(save_data)
		if(length(history_gasmix_data) >= ANALYZER_HISTORY_SIZE)
			history_gasmix_data.Cut(ANALYZER_HISTORY_SIZE, length(history_gasmix_data) + 1)
		history_gasmix_data.Insert(1, list(new_gasmix_data))

/obj/item/analyzer/attack_self(mob/user)
	if(user.stat != CONSCIOUS)
		return
	target_mode = ANALYZER_MODE_SURROUNDINGS
	atmos_scan(user=user, target=get_turf(src), silent=FALSE, print=FALSE)
	on_analyze(source=user, target=get_turf(src), save_data=!auto_updating)
	ui_interact(user)
	add_fingerprint(user)

/obj/item/analyzer/afterattack(atom/target, mob/user, proximity, params)
	. = ..()
	if(!user.can_see(target, scan_range))
		return
	target_mode = ANALYZER_MODE_TARGET
	if(target == user || target == user.loc)
		target_mode = ANALYZER_MODE_SURROUNDINGS
	atmos_scan(user=user, target=(target.return_analyzable_air() ? target : get_turf(src)), print=FALSE)
	on_analyze(source=user, target=(target.return_analyzable_air() ? target : get_turf(src)), save_data=!auto_updating)
	ui_interact(user)

/**
 * Outputs a message to the user describing the target's gasmixes.
 *
 * Gets called by analyzer_act, which in turn is called by tool_act.
 * Also used in other chat-based gas scans.
 */
/proc/atmos_scan(mob/user, atom/target, silent=FALSE, print=TRUE)
	var/mixture = target?.return_analyzable_air()
	if(!mixture)
		return FALSE

	var/icon = target
	var/message = list()
	if(!silent && isliving(user))
		user.visible_message(span_notice("[user] uses the analyzer on [bicon(icon)] [target]."), span_notice("You use the analyzer on [bicon(icon)] [target]"))
	message += span_boldnotice("Results of analysis of [bicon(icon)] [target].")

	if(!print)
		return TRUE

	var/list/airs = islist(mixture) ? mixture : list(mixture)
	for(var/datum/gas_mixture/air as anything in airs)
		var/mix_name = capitalize(lowertext(target.name))
		if(airs.len > 1) //not a unary gas mixture
			var/mix_number = airs.Find(air)
			message += span_boldnotice("Node [mix_number]")
			mix_name += " - Node [mix_number]"

		var/total_moles = air.total_moles()
		var/pressure = air.return_pressure()
		var/volume = air.return_volume() //could just do mixture.volume... but safety, I guess?
		var/temperature = air.return_temperature()
		var/heat_capacity = air.heat_capacity()
		var/thermal_energy = air.thermal_energy()

		//TODO: Port gas mixtures from TG
		if(total_moles > 0)
			message += span_notice("Moles: [round(total_moles, 0.01)] mol")
			if(air.oxygen)
				message += span_notice("Oxygen: [round(air.oxygen, 0.01)] mol ([round(air.oxygen / total_moles*100, 0.01)] %)")
			if(air.carbon_dioxide)
				message += span_notice("Carbon Dioxide: [round(air.carbon_dioxide, 0.01)] mol ([round(air.carbon_dioxide / total_moles*100, 0.01)] %)")
			if(air.nitrogen)
				message += span_notice("Nitrogen: [round(air.nitrogen, 0.01)] mol ([round(air.nitrogen / total_moles*100, 0.01)] %)")
			if(air.toxins)
				message += span_notice("Plasma: [round(air.toxins, 0.01)] mol ([round(air.toxins / total_moles*100, 0.01)] %)")
			if(air.sleeping_agent)
				message += span_notice("Nitrous Oxide: [round(air.sleeping_agent, 0.01)] mol ([round(air.sleeping_agent / total_moles*100, 0.01)] %)")
			if(air.agent_b)
				message += span_notice("Agent B: [round(air.agent_b, 0.01)] mol ([round(air.agent_b / total_moles*100, 0.01)] %)")

			message += span_notice("Temperature: [round(temperature - T0C,0.01)] &deg;C ([round(temperature, 0.01)] K)")
			message += span_notice("Volume: [volume] L")
			message += span_notice("Pressure: [round(pressure, 0.01)] kPa")
			message += span_notice("Heat Capacity: [display_joules(heat_capacity)] / K")
			message += span_notice("Thermal Energy: [display_joules(thermal_energy)]")
		else
			message += airs.len > 1 ? span_notice("This node is empty!") : span_notice("[target] is empty!")
			message += span_notice("Volume: [volume] L") // don't want to change the order volume appears in, suck it

	// we let the join apply newlines so we do need handholding
	to_chat(user, chat_box_examine((jointext(message, "\n"))))

////////////////////////////////////////
// MARK:	Reagent scanners
////////////////////////////////////////
/obj/item/reagent_scanner
	name = "reagent scanner"
	desc = "A hand-held reagent scanner which identifies chemical agents and blood types."
	icon = 'icons/obj/device.dmi'
	icon_state = "spectrometer"
	item_state = "analyzer"
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20
	materials = list(MAT_METAL=30, MAT_GLASS=20)
	origin_tech = "magnets=2;biotech=1;plasmatech=2"
	var/details = FALSE
	var/datatoprint = ""
	var/scanning = TRUE
	actions_types = list(/datum/action/item_action/print_report)

/obj/item/reagent_scanner/afterattack(obj/O, mob/user, proximity, params)
	if(user.stat)
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, span_warning("You don't have the dexterity to do this!"))
		return
	if(!istype(O))
		return

	if(!isnull(O.reagents))
		var/dat = ""
		var/blood_type = ""
		var/blood_species = ""
		if(O.reagents.reagent_list.len > 0)
			var/one_percent = O.reagents.total_volume / 100
			for(var/datum/reagent/R in O.reagents.reagent_list)
				if(R.id != "blood")
					dat += "<br>[TAB]<span class='notice'>[R][details ? ": [R.volume / one_percent]%" : ""]</span>"
				else
					blood_species = R.data["blood_species"]
					blood_type = R.data["blood_type"]
					dat += "<br>[TAB]<span class='notice'>[R][blood_type ? " [blood_type]" : ""][blood_species ? " [blood_species]" : ""][details ? ": [R.volume / one_percent]%" : ""]</span>"
		if(dat)
			to_chat(user, span_notice("Chemicals found: [dat]"))
			datatoprint = dat
			scanning = FALSE
		else
			to_chat(user, span_notice("No active chemical agents found in [O]."))
	else
		to_chat(user, span_notice("No significant chemical agents found in [O]."))
	return

/obj/item/reagent_scanner/adv
	name = "advanced reagent scanner"
	icon_state = "adv_spectrometer"
	details = TRUE
	origin_tech = "magnets=4;biotech=3;plasmatech=3"

/obj/item/reagent_scanner/proc/print_report()
	if(!scanning)
		usr.visible_message(span_warning("[src] rattles and prints out a sheet of paper."))
		playsound(loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, 1)
		if(!details)
			flick("spectrometer_anim", src)
		else
			flick("adv_spectrometer_anim", src)
		sleep(50)

		var/obj/item/paper/P = new(drop_location())
		P.name = "Reagent Scanner Report: [station_time_timestamp()]"
		P.info = "<center><b>Reagent Scanner</b></center><br><center>Data Analysis:</center><br><hr><br><b>Chemical agents detected:</b><br> [datatoprint]<br><hr>"

		if(ismob(loc))
			var/mob/M = loc
			M.put_in_hands(P, ignore_anim = FALSE)
			to_chat(M, span_notice("Report printed. Log cleared."))
			datatoprint = ""
			scanning = TRUE
	else
		to_chat(usr, span_notice("[src]  has no logs or is already in use."))

/obj/item/reagent_scanner/ui_action_click(mob/user, datum/action/action, leftclick)
	print_report()

////////////////////////////////////////
// MARK:	Slime scanner
////////////////////////////////////////
/obj/item/slime_scanner
	name = "slime scanner"
	icon = 'icons/obj/device.dmi'
	icon_state = "adv_spectrometer_s"
	item_state = "analyzer"
	origin_tech = "biotech=2"
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=30, MAT_GLASS=20)

/obj/item/slime_scanner/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED
	if(user.incapacitated() || user.AmountBlinded())
		return .
	if(!isslime(target))
		to_chat(user, span_warning("This device can only scan slimes!"))
		return .
	. |= ATTACK_CHAIN_SUCCESS
	slime_scan(target, user)

/proc/slime_scan(mob/living/simple_animal/slime/T, mob/living/user)
	var/list/msgs = list()
	msgs += "<b>Slime scan results:</b>"
	msgs += span_notice("[T.colour] [T.age_state.age] slime")
	msgs += "Nutrition: [T.nutrition]/[T.get_max_nutrition()]"
	if(T.nutrition < T.get_starve_nutrition())
		msgs += span_warning("Warning: slime is starving!")
	else if(T.nutrition < T.get_hunger_nutrition())
		msgs += span_warning("Warning: slime is hungry")
	msgs += "Electric change strength: [T.powerlevel]"
	msgs += "Health: [round(T.health/T.maxHealth,0.01)*100]%"
	if(T.slime_mutation[4] == T.colour)
		msgs += "This slime does not evolve any further."
	else
		if(T.slime_mutation[3] == T.slime_mutation[4])
			if(T.slime_mutation[2] == T.slime_mutation[1])
				msgs += "Possible mutation: [T.slime_mutation[3]]"
				msgs += "Genetic destability: [T.mutation_chance/2] % chance of mutation on splitting"
			else
				msgs += "Possible mutations: [T.slime_mutation[1]], [T.slime_mutation[2]], [T.slime_mutation[3]] (x2)"
				msgs += "Genetic destability: [T.mutation_chance] % chance of mutation on splitting"
		else
			msgs += "Possible mutations: [T.slime_mutation[1]], [T.slime_mutation[2]], [T.slime_mutation[3]], [T.slime_mutation[4]]"
			msgs += "Genetic destability: [T.mutation_chance] % chance of mutation on splitting"
	if(T.cores > 1)
		msgs += "Multiple cores detected"
	msgs += "Growth progress: [clamp(T.amount_grown, 0, T.age_state.amount_grown)]/[T.age_state.amount_grown]"
	msgs += "Split progress: [clamp(T.amount_grown, 0, T.age_state.amount_grown_for_split)]/[T.age_state.amount_grown_for_split]"
	msgs += "Evolve: preparing for [(T.amount_grown < T.age_state.amount_grown_for_split) ? (T.age_state.stat_text) : (T.age_state.age != SLIME_ELDER ? T.age_state.stat_text_evolve : T.age_state.stat_text)]"
	if(T.effectmod)
		msgs += span_notice("Core mutation in progress: [T.effectmod]")
		msgs += span_notice("Progress in core mutation: [T.applied] / [SLIME_EXTRACT_CROSSING_REQUIRED]")
	to_chat(user, chat_box_healthscan(msgs.Join("<br>")))

////////////////////////////////////////
// MARK:	Body analyzers
////////////////////////////////////////
/obj/item/bodyanalyzer
	name = "handheld body analyzer"
	icon = 'icons/obj/device.dmi'
	icon_state = "bodyanalyzer_0"
	base_icon_state = "bodyanalyzer"
	item_state = "healthanalyser"
	desc = "A handheld scanner capable of deep-scanning an entire body."
	slot_flags = ITEM_SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 5
	throw_range = 10
	origin_tech = "magnets=6;biotech=6"
	var/obj/item/stock_parts/cell/cell
	var/cell_type = /obj/item/stock_parts/cell/upgraded
	var/ready = TRUE // Ready to scan
	var/printing = FALSE
	var/time_to_use = 0 // How much time remaining before next scan is available.
	var/usecharge = 750
	var/scan_time = 10 SECONDS //how long does it take to scan
	var/scan_cd = 60 SECONDS //how long before we can scan again

/obj/item/bodyanalyzer/rnd
	icon_state = "bodyscan_0"
	item_state = "portable_bodyscan"
	base_icon_state = "bodyscan"

/obj/item/bodyanalyzer/get_cell()
	return cell

/obj/item/bodyanalyzer/advanced
	cell_type = /obj/item/stock_parts/cell/upgraded/plus

/obj/item/bodyanalyzer/borg
	name = "cyborg body analyzer"
	desc = "Scan an entire body to prepare for field surgery. Consumes power for each scan."

/obj/item/bodyanalyzer/borg/syndicate
	scan_time = 5 SECONDS
	scan_cd = 20 SECONDS

/obj/item/bodyanalyzer/New()
	..()
	cell = new cell_type(src)
	cell.give(cell.maxcharge)
	update_icon()

/obj/item/bodyanalyzer/Destroy()
	QDEL_NULL(cell)
	. = ..()

/obj/item/bodyanalyzer/proc/setReady()
	ready = TRUE
	playsound(src, 'sound/machines/defib_saftyon.ogg', 50, 0)
	update_icon()


/obj/item/bodyanalyzer/update_icon_state()
	if(!cell)
		icon_state = "[base_icon_state]_0"
		return
	if(ready)
		icon_state = "[base_icon_state]_1"
	else
		icon_state = "[base_icon_state]_2"


/obj/item/bodyanalyzer/update_overlays()
	. = ..()
	var/percent = cell.percent()
	var/overlayid = round(percent / 10)
	. += "[base_icon_state]_charge[overlayid]"
	if(printing)
		. += "[base_icon_state]_printing"


/obj/item/bodyanalyzer/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED

	if(user.incapacitated() || !user.Adjacent(target))
		return .

	if(!ready)
		to_chat(user, span_notice("The scanner beeps angrily at you! It's currently recharging - [round((time_to_use - world.time) * 0.1)] seconds remaining."))
		playsound(user.loc, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
		return .

	if(cell.charge >= usecharge)
		. |= ATTACK_CHAIN_SUCCESS
		mobScan(target, user)
	else
		to_chat(user, span_notice("The scanner beeps angrily at you! It's out of charge!"))
		playsound(user.loc, 'sound/machines/buzz-sigh.ogg', 50, TRUE)


/obj/item/bodyanalyzer/borg/attack(mob/living/target, mob/living/silicon/robot/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED

	if(user.incapacitated() || !user.Adjacent(target))
		return .

	if(!ready)
		to_chat(user, span_notice("[src] is currently recharging - [round((time_to_use - world.time) * 0.1)] seconds remaining."))
		return .

	if(user.cell.charge >= usecharge)
		. |= ATTACK_CHAIN_SUCCESS
		mobScan(target, user)
	else
		to_chat(user, span_notice("You need to recharge before you can use [src]"))


/obj/item/bodyanalyzer/proc/mobScan(mob/living/M, mob/user)
	if(ishuman(M))
		var/report = generate_printing_text(M, user)
		user.visible_message("[user] begins scanning [M] with [src].", "You begin scanning [M].")
		if(do_after(user, scan_time, M))
			var/obj/item/paper/printout = new(drop_location())
			printout.info = report
			printout.name = "Scan report - [M.name]"
			playsound(user.loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, 1)
			user.put_in_hands(printout, ignore_anim = FALSE)
			time_to_use = world.time + scan_cd
			if(isrobot(user))
				var/mob/living/silicon/robot/R = user
				R.cell.use(usecharge)
			else
				cell.use(usecharge)
			ready = FALSE
			printing = TRUE
			update_icon()
			addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/item/bodyanalyzer, setReady)), scan_cd)
			addtimer(VARSET_CALLBACK(src, printing, FALSE), 1.4 SECONDS)
			addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon), UPDATE_OVERLAYS), 1.5 SECONDS)
	else if(iscorgi(M) && M.stat == DEAD)
		to_chat(user, span_notice("You wonder if [M.p_they()] was a good dog. <b>[src] tells you they were the best...</b>")) // :'(
		playsound(loc, 'sound/machines/ping.ogg', 50, 0)
		ready = FALSE
		update_icon(UPDATE_ICON_STATE)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/item/bodyanalyzer, setReady)), scan_cd)
		time_to_use = world.time + scan_cd
	else
		to_chat(user, span_notice("Scanning error detected. Invalid specimen."))

//Unashamedly ripped from adv_med.dm
/obj/item/bodyanalyzer/proc/generate_printing_text(mob/living/M, mob/user)
	var/dat = ""
	var/mob/living/carbon/human/target = M

	dat = "<font color='blue'><b>Target Statistics:</b></font><br>"
	var/t1
	switch(target.stat) // obvious, see what their status is
		if(CONSCIOUS)
			t1 = "Conscious"
		if(UNCONSCIOUS)
			t1 = "Unconscious"
		else
			t1 = "*dead*"
	dat += "[target.health > 50 ? "<font color='blue'>" : "<font color='red'>"]\tHealth %: [target.health], ([t1])</font><br>"

	var/found_disease = FALSE
	for(var/thing in target.diseases)
		var/datum/disease/D = thing
		if(D.visibility_flags & HIDDEN_SCANNER)
			continue
		found_disease = TRUE
		break
	if(found_disease)
		dat += "<font color='red'>Disease detected in target.</font><br>"

	var/extra_font = null
	extra_font = (target.getBruteLoss() < 60 ? "<font color='blue'>" : "<font color='red'>")
	dat += "[extra_font]\t-Brute Damage %: [target.getBruteLoss()]</font><br>"

	extra_font = (target.getOxyLoss() < 60 ? "<font color='blue'>" : "<font color='red'>")
	dat += "[extra_font]\t-Respiratory Damage %: [target.getOxyLoss()]</font><br>"

	extra_font = (target.getToxLoss() < 60 ? "<font color='blue'>" : "<font color='red'>")
	dat += "[extra_font]\t-Toxin Content %: [target.getToxLoss()]</font><br>"

	extra_font = (target.getFireLoss() < 60 ? "<font color='blue'>" : "<font color='red'>")
	dat += "[extra_font]\t-Burn Severity %: [target.getFireLoss()]</font><br>"

	extra_font = (target.radiation < 10 ?"<font color='blue'>" : "<font color='red'>")
	dat += "[extra_font]\tRadiation Level %: [target.radiation]</font><br>"

	extra_font = (target.getCloneLoss() < 1 ?"<font color='blue'>" : "<font color='red'>")
	dat += "[extra_font]\tGenetic Tissue Damage %: [target.getCloneLoss()]<br>"

	extra_font = (target.getBrainLoss() < 1 ?"<font color='blue'>" : "<font color='red'>")
	dat += "[extra_font]\tApprox. Brain Damage %: [target.getBrainLoss()]<br>"

	dat += "Paralysis Summary %: [target.AmountParalyzed()] ([round(target.AmountParalyzed() / 10)] seconds left!)<br>"
	dat += "Body Temperature: [target.bodytemperature-T0C] &deg;C ([target.bodytemperature*1.8-459.67] &deg;F)<br>"

	dat += "<hr>"

	if(target.has_brain_worms())
		dat += "Large growth detected in frontal lobe, possibly cancerous. Surgical removal is recommended.<br>"

	var/blood_percent =  round((target.blood_volume / BLOOD_VOLUME_NORMAL))
	blood_percent *= 100

	extra_font = (target.blood_volume > 448 ? "<font color='blue'>" : "<font color='red'>")
	dat += "[extra_font]\tBlood Level %: [blood_percent] ([target.blood_volume] units)</font><br>"

	if(target.reagents)
		dat += "Epinephrine units: [target.reagents.get_reagent_amount("Epinephrine")] units<br>"
		dat += "Ether: [target.reagents.get_reagent_amount("ether")] units<br>"

		extra_font = (target.reagents.get_reagent_amount("silver_sulfadiazine") < 30 ? "<font color='black'>" : "<font color='red'>")
		dat += "[extra_font]\tSilver Sulfadiazine: [target.reagents.get_reagent_amount("silver_sulfadiazine")]</font><br>"

		extra_font = (target.reagents.get_reagent_amount("styptic_powder") < 30 ? "<font color='black'>" : "<font color='red'>")
		dat += "[extra_font]\tStyptic Powder: [target.reagents.get_reagent_amount("styptic_powder")] units<br>"

		extra_font = (target.reagents.get_reagent_amount("salbutamol") < 30 ? "<font color='black'>" : "<font color='red'>")
		dat += "[extra_font]\tSalbutamol: [target.reagents.get_reagent_amount("salbutamol")] units<br>"

	dat += "<hr><table border='1'>"
	dat += "<tr>"
	dat += "<th>Organ</th>"
	dat += "<th>Burn Damage</th>"
	dat += "<th>Brute Damage</th>"
	dat += "<th>Other Wounds</th>"
	dat += "</tr>"

	for(var/obj/item/organ/external/e as anything in target.bodyparts)
		dat += "<tr>"
		var/AN = ""
		var/open = ""
		var/infected = ""
		var/robot = ""
		var/imp = ""
		var/bled = ""
		var/splint = ""
		var/internal_bleeding = ""
		var/lung_ruptured = ""
		if(e.has_internal_bleeding())
			internal_bleeding = "<br>Internal bleeding"
		if(istype(e, /obj/item/organ/external/chest) && target.is_lung_ruptured())
			lung_ruptured = "Lung ruptured:"
		if(e.is_splinted())
			splint = "Splinted:"
		if(e.has_fracture())
			AN = "[e.broken_description]:"
		if(e.is_robotic())
			robot = "Robotic:"
		if(e.open)
			open = "Open:"
		switch(e.germ_level)
			if(INFECTION_LEVEL_ONE to INFECTION_LEVEL_ONE + 200)
				infected = "Mild Infection:"
			if(INFECTION_LEVEL_ONE + 200 to INFECTION_LEVEL_ONE + 300)
				infected = "Mild Infection+:"
			if(INFECTION_LEVEL_ONE + 300 to INFECTION_LEVEL_ONE + 400)
				infected = "Mild Infection++:"
			if(INFECTION_LEVEL_TWO to INFECTION_LEVEL_TWO + 200)
				infected = "Acute Infection:"
			if(INFECTION_LEVEL_TWO + 200 to INFECTION_LEVEL_TWO + 300)
				infected = "Acute Infection+:"
			if(INFECTION_LEVEL_TWO + 300 to INFECTION_LEVEL_TWO + 400)
				infected = "Acute Infection++:"
			if(INFECTION_LEVEL_THREE to INFINITY)
				infected = "Septic:"

		if(LAZYLEN(e.embedded_objects) || e.hidden)
			imp += "Unknown body present:"
		if(!AN && !open && !infected && !imp)
			AN = "None:"
		dat += "<td>[e.name]</td><td>[e.burn_dam]</td><td>[e.brute_dam]</td><td>[robot][bled][AN][splint][open][infected][imp][internal_bleeding][lung_ruptured]</td>"
		dat += "</tr>"
	for(var/obj/item/organ/internal/organ as anything in target.internal_organs)
		var/mech = organ.desc
		var/infection = "None"
		switch(organ.germ_level)
			if(1 to INFECTION_LEVEL_ONE + 200)
				infection = "Mild Infection:"
			if(INFECTION_LEVEL_ONE + 200 to INFECTION_LEVEL_ONE + 300)
				infection = "Mild Infection+:"
			if(INFECTION_LEVEL_ONE + 300 to INFECTION_LEVEL_ONE + 400)
				infection = "Mild Infection++:"
			if(INFECTION_LEVEL_TWO to INFECTION_LEVEL_TWO + 200)
				infection = "Acute Infection:"
			if(INFECTION_LEVEL_TWO + 200 to INFECTION_LEVEL_TWO + 300)
				infection = "Acute Infection+:"
			if(INFECTION_LEVEL_TWO + 300 to INFINITY)
				infection = "Acute Infection++:"

		dat += "<tr>"
		dat += "<td>[organ.name]</td><td>N/A</td><td>[organ.damage]</td><td>[infection]:[mech]</td><td></td>"
		dat += "</tr>"
	dat += "</table>"
	if(HAS_TRAIT(target, TRAIT_BLIND))
		dat += "<font color='red'>Cataracts detected.</font><br>"
	if(HAS_TRAIT(target, TRAIT_COLORBLIND))
		dat += "<font color='red'>Photoreceptor abnormalities detected.</font><br>"
	if(HAS_TRAIT(target, TRAIT_NEARSIGHTED))
		dat += "<font color='red'>Retinal misalignment detected.</font><br>"

	return dat
