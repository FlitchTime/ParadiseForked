/datum/team/xenomorph
	name = "Ксеноморфы"
	antag_datum_type = /datum/antagonist/xenomorph
	var/datum/mind/current_queen
	var/list/queens = list()
	var/datum/mind/current_empress
	var/datum/objective/xeno_get_power/xeno_power_objective
	var/datum/objective/create_queen/create_queen
	var/datum/objective/protect_queen/protect_queen
	var/datum/objective/protect_cocon/protect_cocon
	var/announce = FALSE
	var/evolves_count = 0
	var/grant_action = FALSE
	var/stage = XENO_STAGE_START
	var/delay_xeno_end = FALSE
	var/list/facehuggers = list()

/datum/team/xenomorph/New(list/starting_members)
	. = ..()
	create_queen = new
	create_queen.owner = src
	create_queen.team = src
	add_objective_to_members(create_queen)


/datum/team/xenomorph/add_member(datum/mind/new_member, add_objectives)
	var/is_queen = new_member?.current && isalienqueen(new_member.current)
	var/is_facehuggger = new_member?.current && isfacehugger(new_member.current)
	. = ..(new_member, !is_queen)
	if(!is_facehuggger)
		RegisterSignal(new_member, COMSIG_ALIEN_EVOLVE, PROC_REF(on_alien_evolve))
	else
		facehuggers |= new_member
	if(is_queen && !current_queen)
		add_queen(new_member)
	check_queen_power()

/datum/team/xenomorph/remove_member(datum/mind/new_member)
	UnregisterSignal(new_member, COMSIG_ALIEN_EVOLVE)
	. = ..()

/datum/team/xenomorph/add_objective_to_members(datum/objective/objective, member_blacklist = list(current_queen, current_empress))
	. = ..()


/datum/team/xenomorph/proc/on_alien_evolve(datum/mind/source, old_type, new_type)
	SIGNAL_HANDLER
	if(!istype(source))
		return
	if(ispath(old_type, LARVA_TYPE))
		evolves_count++
		check_announce()
		source.remove_antag_datum(/datum/antagonist/xenomorph)
		var/datum/antagonist/xenomorph/datum = new
		source.add_antag_datum(datum, type)

	if(ispath(new_type, QUEEN_TYPE))
		add_queen(source)

	if(ispath(new_type, EMPRESS_TYPE))
		current_empress = source
		evolve_end()

/datum/team/xenomorph/proc/add_queen(datum/mind/queen)
	current_queen = queen
	queens |= queen
	create_queen.completed = TRUE
	protect_queen = new
	protect_queen.owner = src
	protect_queen.team = src
	add_objective_to_members(protect_queen)
	xeno_power_objective = new
	xeno_power_objective.owner = src
	xeno_power_objective.team = src
	xeno_power_objective.generate_text()
	queen.remove_antag_datum(/datum/antagonist/xenomorph)
	var/datum/antagonist/xenomorph/queen/datum = new
	datum.objectives |= xeno_power_objective
	datum.team = src
	queen.add_antag_datum(datum, type)
	if(announce)
		SSshuttle?.add_hostile_environment(current_queen.current)
	grant_action = FALSE
	check_queen_power()

/datum/team/xenomorph/proc/check_queen_power()
	var/mob/queen_mob = current_queen?.current
	if(!grant_action && xeno_power_objective?.check_completion(src) && !isnull(queen_mob?.stat) && queen_mob.stat != DEAD)
		var/datum/action/innate/start_evolve_to_empress/evolve = new
		evolve.Grant(queen_mob)
		evolve.xeno_team = WEAKREF(src)
		grant_action = TRUE

/datum/team/xenomorph/proc/check_announce()
	if(announce)
		return TRUE
	var/crew_count = num_station_players()
	var/queen_exist = current_queen?.current && current_queen.current.stat != DEAD
	if(queen_exist && evolves_count > crew_count * EVOLVE_ANNOUNCE_TRIGGER)
		announce = TRUE
		announce()
		return TRUE
	return FALSE

/datum/team/xenomorph/proc/announce()
	GLOB.major_announcement.announce("Вспышка биологической угрозы 4-го уровня зафиксирована на борту станции [station_name()]. Всему персоналу надлежит сдержать её распространение любой ценой! Особая директива распечатана на всех консолях связи.",
									ANNOUNCE_BIOHAZARD_RU,
									'sound/effects/siren-spooky.ogg',
									new_sound2 = 'sound/AI/outbreak_xeno.ogg'
	)
	SSticker?.mode?.special_directive()
	SSshuttle?.emergency.cancel()
	SSshuttle?.add_hostile_environment(current_queen.current)

/datum/team/xenomorph/proc/evolve_announce(area/loc)
	GLOB.major_announcement.announce("Зафиксировано изменение организации улья, указывающее на начало трансформации в Императрицу Ксеноморфов. Обнаружено значительное скопление биоугрозы в [loc.name]. Уничтожте огранизм до окончания трансформации любой ценой.",
									ANNOUNCE_BIOHAZARD_RU,
									'sound/effects/siren-spooky.ogg'
	)

/datum/team/xenomorph/proc/win_announce()
	GLOB.major_announcement.announce("Подтверждено наличие Императрицы Ксеноморфов на борту [station_name()]. Обнаружено загрязнение систем жизнеобеспечения. Станция переклассифицирована в гнездо биоугрозы 4-го уровня. Взведение устройства самоуничтожения персоналом или внешними силами в данный момент не представляется возможным. Активация протоколов изоляции.",
									"Отчёт об объекте [station_name()].",
									'sound/AI/commandreport.ogg'
	)


/datum/team/xenomorph/proc/evolve_start(area/loc)
	protect_queen.completed = TRUE
	protect_cocon = new
	protect_cocon.owner = src
	protect_cocon.team = src
	protect_cocon.generate_text(loc)
	add_objective_to_members(protect_cocon)
	stage = XENO_STAGE_PROTECT_COCON
	addtimer(CALLBACK(src, PROC_REF(evolve_announce), loc), TIME_TO_ANNOUNCE)
	for(var/datum/mind/mind as anything in members)
		if(mind == current_queen || mind == current_empress)
			continue
		if(!mind?.current || mind.current.stat == DEAD)
			continue
		to_chat(mind.current, span_alien("Королева начала эволюционировать в [loc.name]. Она находится в стазисе внутри кокона и полностью беззащитна. Защитите её любой ценой."))

/datum/team/xenomorph/proc/evolve_end()
	RegisterSignal(SSdcs, COMSIG_GLOB_XENO_STORM_ENDED, PROC_REF(on_xeno_storm_ended))
	INVOKE_ASYNC(SSweather, TYPE_PROC_REF(/datum/controller/subsystem/weather, run_weather), /datum/weather/xeno_storm)
	protect_cocon.completed = TRUE
	stage = XENO_STAGE_STORM

/datum/team/xenomorph/proc/on_xeno_storm_ended()
	SIGNAL_HANDLER
	win_announce()
	stage = XENO_STAGE_END
	if(delay_xeno_end)
		stage = XENO_STAGE_POST_END
	else
		SSticker?.mode?.end_game()
	UnregisterSignal(SSdcs, COMSIG_GLOB_XENO_STORM_ENDED)

/datum/team/xenomorph/get_admin_texts()
	. = ..()
	if(current_queen)
		if(check_rights(R_EVENT))
			. += "<br/><a href='byond://?_src_=holder;team_command=delay_xeno_end;team=[UID()]'>Отложить победу Ксеноморфов</a> Сейчас: [delay_xeno_end? "ON" : "OFF"]<br>"
		var/datum/admins/holder = usr.client.holder
		. += holder.check_role_table("Королева", list(current_queen))


/datum/team/xenomorph/proc/declare_results()
	var/list/text = list()
	if(SSticker?.mode?.station_was_nuked && !stage == XENO_STAGE_POST_END)
		text += span_fontsize3("<br><br><b>Частичная победа Ксеноморфов!</b>")
		text += "<br><b>Станция была уничтожена!</b>"
		text += "<br><b>Устройство самоуничтожения сработало, предотвратив распространение Ксеноморфов.</b>"
	else if(protect_cocon?.check_completion(src))
		text += span_fontsize3("<br><br><b>Полная победа Ксеноморфов!</b>")
		text += "<br><b>Ксеноморфы захватили станцию!</b>"
		text += "<br><b>Императрица Ксеноморфов появилась на свет, превратив всю станцию в гнездо.</b>"
	else if(!current_queen?.current || current_queen.current.stat == DEAD)
		text += span_fontsize3("<br><br><b>Полная победа персонала станции!</b>")
		text += "<br><b>Экипаж защитил станцию от Ксеноморфов!</b>"
		text += "<br><b>Ксеноморфы были истреблены.</b>"
	else
		text += span_fontsize3("<br><br><b>Ничья!</b>")
		text += "<br><b>Экипаж эвакуирован!</b>"
		text += "<br><b>Ксеноморфы не были истреблены.</b>"

	text += "<br><b>Целями Ксеноморфов было:</b>"

	if(xeno_power_objective)
		text += "<br/>Цель Королевы: [xeno_power_objective.explanation_text] [xeno_power_objective.check_completion()? span_green("<b>Успех!</b>") : span_red("Провал.")]"
		SSblackbox.record_feedback("nested tally", "traitor_objective", 1, list("[xeno_power_objective.type]", xeno_power_objective.check_completion()? "SUCCESS" : "FAIL"))
	if(create_queen)
		text +="<br/>Создание королевы: [create_queen.explanation_text] [create_queen.check_completion()? span_green("<b>Успех!</b>") : span_red("Провал.")]"
		SSblackbox.record_feedback("nested tally", "traitor_objective", 1, list("[create_queen.type]", create_queen.check_completion()? "SUCCESS" : "FAIL"))
	if(protect_queen)
		text += "<br/>Защита королевы: [protect_queen.explanation_text] [protect_queen.check_completion()? span_green("<b>Успех!</b>") : span_red("Провал.")]"
		SSblackbox.record_feedback("nested tally", "traitor_objective", 1, list("[protect_queen.type]", protect_queen.check_completion()? "SUCCESS" : "FAIL"))
	if(protect_cocon)
		text += "<br/>Защита кокона: [protect_cocon.explanation_text] [protect_cocon.check_completion()? span_green("<b>Успех!</b>") : span_red("Провал.")]"
		SSblackbox.record_feedback("nested tally", "traitor_objective", 1, list("[protect_cocon.type]", protect_cocon.check_completion()? "SUCCESS" : "FAIL"))
	return text.Join("")


/datum/team/xenomorph/declare_completion()
	if(members.len)
		var/list/text = declare_results()
		if(queens?.len)
			text += "<br/><span style='font-size: 2;'><b>Королев[(queens.len > 1 ? "ами были" : "ой была")]:</b></span>"
			for(var/datum/mind/queen in queens)
				text += "<br/><b>[queen.key]</b> был <b>[queen.name]</b>"
		text += "<br/><span style='font-size: 2;'><b>Ксеноморф[(members?.len > 1 ? "ами были" : "ом был")]:</b></span>"
		for(var/datum/mind/alien in members)
			if(alien in facehuggers)
				continue
			text += "<br/><b>[alien.key]</b> был <b>[alien.name]</b>"
		text += "<br/><span style='font-size: 2;'><b>Лицехват[(members?.len > 1 ? "ами были" : "ом был")]:</b></span>"
		for(var/datum/mind/alien in facehuggers)
			text += "<br/><b>[alien.key]</b> был <b>[alien.name]</b>"
		return text.Join("")

/datum/team/xenomorph/proc/delay_xeno_win()
	delay_xeno_end = TRUE

/datum/team/xenomorph/proc/return_xeno_win()
	delay_xeno_end = FALSE

/datum/team/xenomorph/admin_topic(comand)
	if(comand == "delay_xeno_end")
		if(!check_rights(R_ADMIN) || !check_rights(R_EVENT))
			return

		if(!SSticker || !SSticker.mode)
			return

		if(tgui_alert(usr,"Вы действительно хотите [delay_xeno_end? "вернуть" : "преостановить"] конец раунда в случае победы Ксеноморфов?", "", list("Да", "Нет")) == "Нет")
			return

		if(!delay_xeno_end)
			delay_xeno_win()
		else
			return_xeno_win()

		log_and_message_admins("has [delay_xeno_end? "stopped" : "returned"] stopped delayed xeno win")


/proc/spawn_aliens(spawn_count)
	var/spawn_vectors = tgui_alert(usr, "Какой тип ксеноморфа заспавнить?", "Тип ксеноморфов", list("Вектор", "Грудолом")) == "Вектор"
	var/list/vents = get_valid_vent_spawns(exclude_visible_by_mobs = TRUE)
	if(spawn_vectors)
		spawn_vectors(vents, spawn_count)
	else
		spawn_larvas(vents, spawn_count)

/proc/spawn_larvas(list/vents, spawncount)
	var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите сыграть за Ксеноморфа?", ROLE_ALIEN, TRUE, source = /mob/living/carbon/alien/larva)
	var/first_spawn = TRUE
	while(spawncount && length(vents) && length(candidates))
		var/obj/vent = pick_n_take(vents)
		var/mob/C = pick_n_take(candidates)
		if(C)
			GLOB.respawnable_list -= C
			var/mob/living/carbon/alien/larva/new_xeno = new(vent.loc)
			new_xeno.evolution_points += (0.75 * new_xeno.max_evolution_points)	//event spawned larva start off almost ready to evolve.
			new_xeno.key = C.key
			new_xeno.move_into_vent(vent, FALSE)
			if(first_spawn)
				new_xeno.queen_maximum++
				first_spawn = FALSE

			new_xeno.update_datum()

			spawncount--
			log_game("[new_xeno.key] has become [new_xeno].")

/proc/spawn_vectors(list/vents, spawncount)
	spawncount = 1
	var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите сыграть за Ксеноморфа (Вектор)?", ROLE_ALIEN, TRUE, source = /mob/living/carbon/alien/humanoid/hunter/vector)
	var/first_spawn = TRUE
	while(spawncount && length(vents) && length(candidates))
		var/obj/vent = pick_n_take(vents)
		var/mob/C = pick_n_take(candidates)
		if(C)
			GLOB.respawnable_list -= C
			var/mob/living/carbon/alien/humanoid/hunter/vector/new_xeno = new(vent.loc)
			new_xeno.move_into_vent(vent, FALSE)
			new_xeno.key = C.key
			if(first_spawn)
				new_xeno.queen_maximum++
				first_spawn = FALSE
			new_xeno.update_datum()

			spawncount--
			log_game("[new_xeno.key] has become [new_xeno].")
