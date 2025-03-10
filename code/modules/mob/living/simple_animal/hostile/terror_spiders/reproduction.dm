
// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: SPIDERLINGS (USED BY GREEN, WHITE, QUEEN AND MOTHER TYPES)
// --------------------------------------------------------------------------------

/obj/structure/spider/spiderling/terror_spiderling
	name = "spiderling"
	desc = "Быстро движущийся крошечный паук, склонный издавать агрессивные шипящие звуки. Надеюсь, оно не вырастет."
	ru_names = list(
		NOMINATIVE = "паучок",
		GENITIVE = "паучка",
		DATIVE = "паучку",
		ACCUSATIVE = "паучка",
		INSTRUMENTAL = "паучком",
		PREPOSITIONAL = "паучке",
	)
	icon_state = "spiderling"
	anchored = FALSE
	layer = 2.75
	max_integrity = 3
	var/stillborn = FALSE
	var/mob/living/simple_animal/hostile/poison/terror_spider/queen/spider_myqueen = null
	var/mob/living/simple_animal/hostile/poison/terror_spider/spider_mymother = null
	var/goto_mother = FALSE
	var/ventcrawl_chance = 30 // 30% every process(), assuming 33% wander does not trigger
	var/immediate_ventcrawl = TRUE
	var/list/enemies = list()
	var/spider_awaymission = FALSE
	var/frustration = 0
	var/debug_ai_choices = FALSE
	var/movement_disabled = FALSE
	var/mob/asigned_ghost

/obj/structure/spider/spiderling/terror_spiderling/Initialize(mapload)
	. = ..()
	GLOB.ts_spiderling_list += src
	var/datum/team/terror_spiders/spider_team = GLOB.antagonist_teams[/datum/team/terror_spiders]
	if(is_away_level(z))
		spider_awaymission = TRUE
	else
		spider_team?.terror_eggs |= src

/obj/structure/spider/spiderling/terror_spiderling/Destroy()
	GLOB.ts_spiderling_list -= src
	for(var/obj/structure/spider/spiderling/terror_spiderling/S in view(7, src))
		S.immediate_ventcrawl = TRUE
	var/datum/team/terror_spiders/spider_team = GLOB.antagonist_teams[/datum/team/terror_spiders]
	spider_team?.terror_eggs -= src
	return ..()

/obj/structure/spider/spiderling/terror_spiderling/proc/score_surroundings(atom/A = src)
	var/safety_score = 0
	var/turf/T = get_turf(A)
	for(var/mob/living/L in viewers(T))
		if(isterrorspider(L))
			if(L.stat == DEAD)
				safety_score--
			else
				safety_score++
				if(spider_mymother && L == spider_mymother)
					safety_score++
		else if(L.stat != DEAD)
			safety_score--
	if(debug_ai_choices)
		debug_visual(T, safety_score, A)
	return safety_score

/obj/structure/spider/spiderling/terror_spiderling/proc/debug_visual(turf/T, score, atom/A)
	// This proc exists to help debug why spiderlings are making the ventcrawl AI choices they do.
	// It won't be called unless you set the spiderling's debug_ai_choices to true.
	if(debug_ai_choices && istype(T))
		if(A == src)
			if(score > 0)
				new /obj/effect/temp_visual/heart(T) // heart symbol, I am safe here, protected by a friendly spider
			else if (score == 0)
				new /obj/effect/temp_visual/heal(T) // white "+" symbol, I am neutral here
			else
				new /obj/effect/temp_visual/at_shield(T) // octagon symbol, I am unsafe here, I need to flee
		else
			if(score > 0)
				new /obj/effect/temp_visual/telekinesis(T) // blue sparks, this is a safe area, I want to go here
			else if (score == 0)
				new /obj/effect/temp_visual/revenant(T) // purple sparks, this is a neutral area, an acceptable choice
			else
				new /obj/effect/temp_visual/cult/sparks(T) // red sparks, this is an unsafe area, I won't go here unless fleeing something worse

/obj/structure/spider/spiderling/terror_spiderling/process()
	var/turf/T = get_turf(src)
	if(spider_awaymission && !is_away_level(T.z))
		stillborn = TRUE
	if(GLOB.global_degenerate && !spider_awaymission && !QDELETED(src))
		qdel(src)
		return
	if(stillborn)
		// Fake spiderlings stick around for awhile, just to be spooky.
		qdel(src)
	else
		if(!grow_as)
			grow_as = pick(/mob/living/simple_animal/hostile/poison/terror_spider/knight, /mob/living/simple_animal/hostile/poison/terror_spider/lurker, /mob/living/simple_animal/hostile/poison/terror_spider/healer, /mob/living/simple_animal/hostile/poison/terror_spider/reaper, /mob/living/simple_animal/hostile/poison/terror_spider/builder)
		var/mob/living/simple_animal/hostile/poison/terror_spider/S = new grow_as(T)
		S.spider_myqueen = spider_myqueen
		S.spider_mymother = spider_mymother
		S.enemies = enemies

		if(!spider_awaymission && asigned_ghost)
			S.key = asigned_ghost.key
			S.add_datum_if_not_exist()
			asigned_ghost = null
		else if(!spider_awaymission)
			S.AddComponent(\
			/datum/component/ghost_direct_control,\
			ban_type = ROLE_TERROR_SPIDER,\
			ban_syndicate = TRUE,\
			poll_candidates = FALSE,\
			question_text =" Роль: [S.spider_intro_text]" ,\
			extra_control_checks = CALLBACK(S, \
			TYPE_PROC_REF(/mob/living/simple_animal/hostile/poison/terror_spider, extra_checks)),\
			after_assumed_control = CALLBACK(S, \
			TYPE_PROC_REF(/mob/living/simple_animal/hostile/poison/terror_spider, humanize_spider)),\
		)
		qdel(src)

	if(movement_disabled)
		return
	if(travelling_in_vent)
		if(isturf(loc))
			travelling_in_vent = 0
			entry_vent = null
	else if(entry_vent)
		if(get_dist(src, entry_vent) <= 1)
			frustration = 0
			var/list/vents = list()
			for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in entry_vent.parent.other_atmosmch)
				if(temp_vent.welded) // no point considering a vent we can't even use
					continue
				vents.Add(temp_vent)
			if(!vents.len)
				entry_vent = null
				return
			var/obj/machinery/atmospherics/unary/vent_pump/exit_vent = pick(vents)
			if(spider_mymother && (goto_mother || prob(10)))
				for(var/obj/machinery/atmospherics/unary/vent_pump/v in view(5, spider_mymother))
					if(!v.welded)
						exit_vent = v
				goto_mother = FALSE
			if(!stillborn)
				var/current_safety_score = score_surroundings(src)
				var/new_safety_score = score_surroundings(exit_vent)
				if(new_safety_score < current_safety_score)
					// Try to find an alternative.
					exit_vent = pick(vents)
					new_safety_score = score_surroundings(exit_vent)
					if(new_safety_score < current_safety_score)
						// No alternative safe vent could be found. Abort.
						entry_vent = null
						return
			var/original_location = loc
			spawn(rand(20,60))
				forceMove(exit_vent)
				var/travel_time = round(get_dist(loc, exit_vent.loc) / 2)
				spawn(travel_time)
					if(!exit_vent || exit_vent.welded)
						forceMove(original_location)
						entry_vent = null
						return
					if(prob(50))
						audible_message(span_notice("Слышно, как что-то сжимается в вентиляционных каналах."))
					spawn(travel_time)
						if(!exit_vent || exit_vent.welded)
							forceMove(original_location)
							entry_vent = null
							return
						forceMove(exit_vent.loc)
						entry_vent = null
						var/area/new_area = get_area(loc)
						if(new_area)
							new_area.Entered(src)
		else
			frustration++
			SSmove_manager.move_to(src, entry_vent, 1, rand(2, 4))
			if(frustration > 2)
				entry_vent = null
	else if(prob(33))
		random_skitter()
	else if(immediate_ventcrawl || prob(ventcrawl_chance))
		immediate_ventcrawl = FALSE
		if(!stillborn && !goto_mother)
			var/safety_score = score_surroundings(src)
			if(safety_score > 0)
				// This area seems safe (friendly spiders present). Do not leave this area.
				return
		for(var/obj/machinery/atmospherics/unary/vent_pump/v in view(7,src))
			if(!v.welded)
				entry_vent = v
				SSmove_manager.move_to(src, entry_vent, 1, rand(2, 4))
				break



// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: EGGS (USED BY NURSE AND QUEEN TYPES) ---------
// --------------------------------------------------------------------------------

/mob/living/simple_animal/hostile/poison/terror_spider/proc/DoLayTerrorEggs(lay_type, lay_number)
	stop_automated_movement = 1
	var/obj/structure/spider/eggcluster/terror_eggcluster/C = new /obj/structure/spider/eggcluster/terror_eggcluster(get_turf(src), lay_type)
	C.spiderling_number = lay_number
	C.spider_myqueen = spider_myqueen
	C.spider_mymother = src
	C.enemies = enemies
	var/datum/team/terror_spiders/spider_team = GLOB.antagonist_teams[/datum/team/terror_spiders]
	if(mind)
		spider_team?.terror_eggs |= C
	if(spider_growinstantly)
		C.amount_grown = 250
		C.spider_growinstantly = TRUE
	spawn(10)
		stop_automated_movement = 0

/obj/structure/spider/eggcluster/terror_eggcluster
	name = "terror egg cluster"
	desc = "Скопление крошечных паучьих яиц. Они активно пульсируют и имеют острые шипы по бокам."
	gender = PLURAL
	icon_state = "egg"
	max_integrity = 40
	grown_tick_count = 140
	var/spider_growinstantly = FALSE
	var/mob/living/simple_animal/hostile/poison/terror_spider/queen/spider_myqueen = null
	var/mob/living/simple_animal/hostile/poison/terror_spider/spider_mymother = null
	var/mob/living/simple_animal/hostile/poison/terror_spider/spiderling_type = null
	var/spiderling_number = 1
	var/list/enemies = list()
	var/list/asigned_ghosts = list()
	var/ghost_poll = FALSE

/obj/structure/spider/eggcluster/terror_eggcluster/Initialize(mapload, lay_type)
	. = ..()
	GLOB.ts_egg_list += src
	spiderling_type = lay_type
	var/ru_prefix = "паука ужаса"
	switch(spiderling_type)
		if(/mob/living/simple_animal/hostile/poison/terror_spider/knight)
			name = "knight of terror eggs"
			ru_prefix = "рыцаря ужаса"
		if(/mob/living/simple_animal/hostile/poison/terror_spider/lurker)
			name = "lurker of terror eggs"
			ru_prefix = "наблюдателя ужаса"
		if(/mob/living/simple_animal/hostile/poison/terror_spider/healer)
			name = "healer of terror eggs"
			ru_prefix = "лекаря ужаса"
		if(/mob/living/simple_animal/hostile/poison/terror_spider/reaper)
			name = "reaper of terror eggs"
			ru_prefix = "жнеца ужаса"
		if(/mob/living/simple_animal/hostile/poison/terror_spider/builder)
			name = "builder of terror eggs"
			ru_prefix = "дрона ужаса"
		if(/mob/living/simple_animal/hostile/poison/terror_spider/widow)
			name = "widow of terror eggs"
			ru_prefix = "вдовы ужаса"
		if(/mob/living/simple_animal/hostile/poison/terror_spider/guardian)
			name = "guardian of terror eggs"
			ru_prefix = "защитника ужаса"
		if(/mob/living/simple_animal/hostile/poison/terror_spider/destroyer)
			name = "destroyer of terror eggs"
			ru_prefix = "разрушителя ужаса"
		if(/mob/living/simple_animal/hostile/poison/terror_spider/defiler)
			name = "defiler of terror eggs"
			ru_prefix = "осквернителя ужаса"
		if(/mob/living/simple_animal/hostile/poison/terror_spider/mother)
			name = "mother of terror eggs"
			ru_prefix = "матери ужаса"
		if(/mob/living/simple_animal/hostile/poison/terror_spider/prince)
			name = "prince of terror eggs"
			ru_prefix = "принца ужаса"
		if(/mob/living/simple_animal/hostile/poison/terror_spider/queen)
			name = "queen of terror eggs"
			ru_prefix = "королевы ужаса"
		if(/mob/living/simple_animal/hostile/poison/terror_spider/queen/princess)
			name = "princess of terror eggs"
			ru_prefix = "принцессы ужаса"
	ru_names = list(
		NOMINATIVE = "яйца [ru_prefix]",
		GENITIVE = "яиц [ru_prefix]",
		DATIVE = "яйцам [ru_prefix]",
		ACCUSATIVE = "яйца [ru_prefix]",
		INSTRUMENTAL = "яйцами [ru_prefix]",
		PREPOSITIONAL = "яйцах [ru_prefix]"
	)

/obj/structure/spider/eggcluster/terror_eggcluster/Destroy()
	GLOB.ts_egg_list -= src
	var/datum/team/terror_spiders/spider_team = GLOB.antagonist_teams[/datum/team/terror_spiders]
	spider_team?.terror_eggs -= src
	return ..()

/obj/structure/spider/eggcluster/terror_eggcluster/proc/find_spider_owner()
	ghost_poll = TRUE
	var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите занять роль Паука Ужаса([spiderling_type.name])?", ROLE_TERROR_SPIDER, TRUE, TERROR_VOTE_LEN, source = spiderling_type, role_cleanname = "Паук Ужаса")
	if(QDELETED(src))
		return FALSE
	ghost_poll = FALSE
	if(!length(candidates) || spider_mymother.spider_awaymission)
		burst_eggs()
		return FALSE
	for(var/i = 0, i < spiderling_number, i++)
		asigned_ghosts |= pick_n_take(candidates)
	burst_eggs()

/obj/structure/spider/eggcluster/terror_eggcluster/process()
	amount_grown += 1
	if(GLOB.global_degenerate && !spider_mymother.spider_awaymission && !QDELETED(src))
		qdel(src)
		return
	if(grown_tick_count - amount_grown <= TERROR_VOTE_TICKS && !asigned_ghosts?.len \
		&& !ghost_poll && !spider_mymother.spider_awaymission)
		find_spider_owner()
	if(amount_grown >= grown_tick_count && spider_mymother.spider_awaymission)  //x2 time for egg process, spiderlings grows instantly
		burst_eggs()

/obj/structure/spider/eggcluster/terror_eggcluster/proc/burst_eggs()
	var/num = spiderling_number
	playsound(src, 'sound/creatures/terrorspiders/eggburst.ogg', 100)
	for(var/i=0, i<num, i++)
		var/obj/structure/spider/spiderling/terror_spiderling/S = new /obj/structure/spider/spiderling/terror_spiderling(get_turf(src))
		if(spiderling_type)
			S.grow_as = spiderling_type
		S.spider_myqueen = spider_myqueen
		S.spider_mymother = spider_mymother
		S.enemies = enemies
		if(asigned_ghosts.len)
			S.asigned_ghost = pick_n_take(asigned_ghosts)
		if(spider_growinstantly)
			S.amount_grown = 250
	qdel(src)

/obj/structure/spider/eggcluster/terror_eggcluster/empress
	name = "empress egg cluster"
	ru_names = list(
		NOMINATIVE = "яйца Императрицы Ужаса",
		GENITIVE = "яиц Императрицы Ужаса",
		DATIVE = "яйцам Императрицы Ужаса",
		ACCUSATIVE = "яйца Императрицы Ужаса",
		INSTRUMENTAL = "яйцами Императрицы Ужаса",
		PREPOSITIONAL = "яйцах Императрицы Ужаса",
	)
	spiderling_type = /mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/weak
	max_integrity = 1000
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 100, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	explosion_block = 100
	grown_tick_count = 250
	explosion_vertical_block = 100
	var/save_burst = FALSE


/obj/structure/spider/eggcluster/terror_eggcluster/empress/Initialize(mapload, lay_type)
	. = ..(mapload, spiderling_type)

/obj/structure/spider/eggcluster/terror_eggcluster/empress/Destroy()
	. = ..()
	var/datum/team/terror_spiders/spider_team = GLOB.antagonist_teams[/datum/team/terror_spiders]
	if(!save_burst)
		spider_team?.on_empress_egg_destroyed()

/obj/structure/spider/eggcluster/terror_eggcluster/empress/ex_act(severity)
	return

/obj/structure/spider/eggcluster/terror_eggcluster/empress/burst_eggs()
	save_burst = TRUE
	var/datum/team/terror_spiders/spider_team = GLOB.antagonist_teams[/datum/team/terror_spiders]
	spider_team?.on_empress_egg_burst()
	. = ..()

/obj/structure/spider/royaljelly
	name = "royal jelly"
	desc = "Пульсирующая масса слизи, желе, крови или сжиженных органов гуманоидов, которую Пауки Ужаса считают вкусной и очень питательной."
	ru_names = list(
		NOMINATIVE = "королевское желе",
		GENITIVE = "королевского желе",
		DATIVE = "королевскому желе",
		ACCUSATIVE = "королевское желе",
		INSTRUMENTAL = "королевским желе",
		PREPOSITIONAL = "королевском желе",
	)
	gender = NEUTER
	icon_state = "spiderjelly"
