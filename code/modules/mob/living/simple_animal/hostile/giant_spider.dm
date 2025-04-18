//basic spider mob, these generally guard nests
/mob/living/simple_animal/hostile/poison/giant_spider
	name = "giant spider"
	desc = "Furry and dark brown, it makes you shudder to look at it. This one has deep red eyes."
	icon_state = "guard"
	var/butcher_state = 8 // Icon state for dead spider icons
	icon_living = "guard"
	icon_dead = "guard_dead"
	speak_emote = list("chitters")
	emote_hear = list("chitters")
	tts_seed = "Anubarak"
	speak_chance = 5
	turns_per_move = 5
	nightvision = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	butcher_results = list(/obj/item/reagent_containers/food/snacks/monstermeat/spidermeat= 2, /obj/item/reagent_containers/food/snacks/monstermeat/spiderleg= 8)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "hits"
	maxHealth = 200
	health = 200
	obj_damage = 60
	melee_damage_lower = 15
	melee_damage_upper = 20
	faction = list("spiders")
	pass_flags = PASSTABLE
	move_to_delay = 6
	attacktext = "кусает"
	attack_sound = 'sound/weapons/bite.ogg'
	death_sound = 'sound/creatures/spider_death.ogg'
	talk_sound = list('sound/creatures/spider_talk1.ogg', 'sound/creatures/spider_talk2.ogg')
	damaged_sound = list('sound/creatures/spider_attack1.ogg', 'sound/creatures/spider_attack2.ogg')
	gold_core_spawnable = HOSTILE_SPAWN
	var/busy = 0
	footstep_type = FOOTSTEP_MOB_CLAW
	AI_delay_max = 0.5 SECONDS
	hud_type = /datum/hud/simple_animal/spider

/mob/living/simple_animal/hostile/poison/giant_spider/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		heat_damage = 20, \
		cold_damage = 20, \
	)

/mob/living/simple_animal/hostile/poison/giant_spider/get_spacemove_backup(moving_direction, continuous_move)
	. = ..()
	// If we don't find any normal thing to use, attempt to use any nearby spider structure instead.
	if(!.)
		for(var/obj/structure/spider/spider_thing in range(1, get_turf(src)))
			return spider_thing

//nursemaids - these create webs and eggs
/mob/living/simple_animal/hostile/poison/giant_spider/nurse
	desc = "Furry and pale green, it makes you shudder to look at it. This one has brilliant green eyes."
	icon_state = "nurse"
	icon_living = "nurse"
	icon_dead = "nurse_dead"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/monstermeat/spidermeat= 2, /obj/item/reagent_containers/food/snacks/monstermeat/spiderleg= 8, /obj/item/reagent_containers/food/snacks/monstermeat/spidereggs= 4)

	maxHealth = 40
	health = 40
	melee_damage_lower = 5
	melee_damage_upper = 10
	var/atom/cocoon_target
	var/fed = 0

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/Initialize(mapload)
	. = ..()

	AddElement( \
		/datum/element/reagent_attack, \
		"spidertoxin", \
		30, \
		FALSE, \
		null, \
		list(BODY_ZONE_CHEST, BODY_ZONE_HEAD), \
		)

//hunters have the most poison and move the fastest, so they can find prey
/mob/living/simple_animal/hostile/poison/giant_spider/hunter
	desc = "Furry and dark purple, it makes you shudder to look at it. This one has sparkling purple eyes."
	icon_state = "hunter"
	icon_living = "hunter"
	icon_dead = "hunter_dead"
	maxHealth = 120
	health = 120
	melee_damage_lower = 10
	melee_damage_upper = 20
	move_to_delay = 5

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/Initialize(mapload)
	. = ..()

	AddElement(
		/datum/element/reagent_attack, \
		"spidertoxin", \
		10, \
		FALSE, \
		null, \
		list(BODY_ZONE_CHEST, BODY_ZONE_HEAD), \
		)

/mob/living/simple_animal/hostile/poison/giant_spider/handle_automated_movement() //Hacky and ugly.
	. = ..()
	if(AIStatus != AI_IDLE)
		return .

	. = TRUE

	//1% chance to skitter madly away
	if(busy || !prob(1))
		return .

	var/turf/where
	for(var/turf/check as anything in RANGE_TURFS(20, src))
		if(!check.density)
			where = check
			break
	if(!where)
		return .

	stop_automated_movement = TRUE
	Goto(where, move_to_delay)
	addtimer(CALLBACK(src, PROC_REF(start_automated_movement)), 5 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)


/mob/living/simple_animal/hostile/poison/giant_spider/proc/start_automated_movement()
	SSmove_manager.stop_looping(src)
	stop_automated_movement = FALSE


/mob/living/simple_animal/hostile/poison/giant_spider/nurse/proc/GiveUp(C)
	spawn(100)
		if(busy == MOVING_TO_TARGET)
			if(cocoon_target == C && get_dist(src,cocoon_target) > 1)
				cocoon_target = null
			busy = 0
			stop_automated_movement = 0

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/handle_automated_movement() //Hacky and ugly.
	if(..())
		var/list/can_see = view(src, 10)
		if(!busy && prob(30))	//30% chance to stop wandering and do something
			//first, check for potential food nearby to cocoon
			for(var/mob/living/C in can_see)
				if(C.stat && !istype(C, /mob/living/simple_animal/hostile/poison/giant_spider) && !C.anchored)
					cocoon_target = C
					busy = MOVING_TO_TARGET
					Goto(C, move_to_delay)
					//give up if we can't reach them after 10 seconds
					GiveUp(C)
					return
			//second, spin a sticky spiderweb on this tile
			var/obj/structure/spider/stickyweb/W = locate() in get_turf(src)
			if(!W)
				Web()
			else
				//third, lay an egg cluster there
				if(fed)
					LayEggs()
				else
					//fourthly, cocoon any nearby items so those pesky pinkskins can't use them
					for(var/obj/O in can_see)
						if(O.anchored)
							continue

						if(isitem(O) || isstructure(O) || ismachinery(O))
							cocoon_target = O
							busy = MOVING_TO_TARGET
							stop_automated_movement = 1
							Goto(O, move_to_delay)
							//give up if we can't reach them after 10 seconds
							GiveUp(O)

		else if(busy == MOVING_TO_TARGET && cocoon_target)
			if(get_dist(src, cocoon_target) <= 1)
				Wrap()

	else
		busy = 0
		stop_automated_movement = 0

/mob/living/simple_animal/hostile/poison/giant_spider/verb/Web()
	set name = "Lay Web"
	set category = "Spider"
	set desc = "Spread a sticky web to slow down prey."

	var/T = src.loc

	if(busy != SPINNING_WEB)
		busy = SPINNING_WEB
		src.visible_message("<span class='notice'>\the [src] begins to secrete a sticky substance.</span>")
		stop_automated_movement = 1
		spawn(40)
			if(busy == SPINNING_WEB && src.loc == T)
				new /obj/structure/spider/stickyweb(T)
			busy = 0
			stop_automated_movement = 0


/mob/living/simple_animal/hostile/poison/giant_spider/nurse/verb/Wrap()
	set name = "Wrap"
	set category = "Spider"
	set desc = "Wrap up prey to feast upon and objects for safe keeping."

	if(!cocoon_target)
		var/list/choices = list()
		for(var/mob/living/L in view(1, src))
			if(L == src)
				continue
			if(L.stat != DEAD)
				continue
			if(istype(L, /mob/living/simple_animal/hostile/poison/giant_spider))
				continue
			if(Adjacent(L))
				choices += L
		for(var/obj/O in get_turf(src))
			if(O.anchored)
				continue
			if(!(isitem(O) || isstructure(O) || ismachinery(O)))
				continue
			if(Adjacent(O))
				choices += O
		if(length(choices))
			cocoon_target = input(src,"What do you wish to cocoon?") in null|choices
		else
			to_chat(src, "<span class='warning'>No suitable dead prey or wrappable objects found nearby.")
			return

	if(cocoon_target && busy != SPINNING_COCOON)
		busy = SPINNING_COCOON
		src.visible_message("<span class='notice'>\the [src] begins to secrete a sticky substance around \the [cocoon_target].</span>")
		stop_automated_movement = 1
		SSmove_manager.stop_looping(src)
		spawn(50)
			if(busy == SPINNING_COCOON)
				if(cocoon_target && istype(cocoon_target.loc, /turf) && get_dist(src,cocoon_target) <= 1)
					var/obj/structure/spider/cocoon/C = new(cocoon_target.loc)
					var/large_cocoon = 0
					C.pixel_x = cocoon_target.pixel_x
					C.pixel_y = cocoon_target.pixel_y
					for(var/obj/item/I in C.loc)
						I.loc = C
					for(var/obj/structure/S in C.loc)
						if(!S.anchored)
							S.loc = C
							large_cocoon = 1
					for(var/obj/machinery/M in C.loc)
						if(!M.anchored)
							M.loc = C
							large_cocoon = 1
					for(var/mob/living/L in C.loc)
						if(istype(L, /mob/living/simple_animal/hostile/poison/giant_spider))
							continue
						if(L.stat != DEAD)
							continue
						large_cocoon = 1
						L.forceMove(C)
						C.pixel_x = L.pixel_x
						C.pixel_y = L.pixel_y
						fed++
						visible_message("<span class='danger'>\the [src] sticks a proboscis into \the [L] and sucks a viscous substance out.</span>")

						break
					if(large_cocoon)
						C.icon_state = pick("cocoon_large1","cocoon_large2","cocoon_large3")
			cocoon_target = null
			busy = 0
			stop_automated_movement = 0

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/verb/LayEggs()
	set name = "Lay Eggs"
	set category = "Spider"
	set desc = "Lay a clutch of eggs, but you must wrap a creature for feeding first."

	var/obj/structure/spider/eggcluster/E = locate() in get_turf(src)
	if(E)
		to_chat(src, "<span class='notice'>There is already a cluster of eggs here!</span>")
	else if(!fed)
		to_chat(src, "<span class='warning'>You are too hungry to do this!</span>")
	else if(busy != LAYING_EGGS)
		busy = LAYING_EGGS
		src.visible_message("<span class='notice'>\the [src] begins to lay a cluster of eggs.</span>")
		stop_automated_movement = 1
		spawn(50)
			if(busy == LAYING_EGGS)
				E = locate() in get_turf(src)
				if(!E)
					var/obj/structure/spider/eggcluster/C = new /obj/structure/spider/eggcluster(src.loc)
					C.faction = faction.Copy()
					C.master_commander = master_commander
					if(ckey)
						C.player_spiders = 1
					fed--
			busy = 0
			stop_automated_movement = 0
