/obj/projectile/magic
	name = "bolt of nothing"
	ru_names = list(
		NOMINATIVE = "разряд пустоты",
		GENITIVE = "разряда пустоты",
		DATIVE = "разряду пустоты",
		ACCUSATIVE = "разряд пустоты",
		INSTRUMENTAL = "разрядом пустоты",
		PREPOSITIONAL = "разряде пустоты"
	)
	icon_state = "energy"
	damage = 0
	hitsound = 'sound/weapons/magic.ogg'
	hitsound_wall = 'sound/weapons/magic.ogg'
	damage_type = OXY
	nodamage = TRUE
	armour_penetration = 100
	flag = "magic"

/obj/projectile/magic/death
	name = "bolt of death"
	ru_names = list(
		NOMINATIVE = "заряд смерти",
		GENITIVE = "заряда смерти",
		DATIVE = "заряду смерти",
		ACCUSATIVE = "заряд смерти",
		INSTRUMENTAL = "зарядом смерти",
		PREPOSITIONAL = "заряде смерти"
	)
	icon_state = "pulse1_bl"

/obj/projectile/magic/fireball
	name = "bolt of fireball"
	ru_names = list(
		NOMINATIVE = "огненный шар",
		GENITIVE = "огненного шара",
		DATIVE = "огненному шару",
		ACCUSATIVE = "огненный шар",
		INSTRUMENTAL = "огненным шаром",
		PREPOSITIONAL = "огненном шаре"
	)
	icon_state = "fireball"
	damage = 10
	damage_type = BRUTE
	nodamage = FALSE

	//explosion values
	var/exp_devastate = -1
	var/exp_heavy = 0
	var/exp_light = 2
	var/exp_flash = 3
	var/exp_fire = 2

/obj/projectile/magic/death/on_hit(mob/living/carbon/C)
	. = ..()
	if(isliving(C))
		if(ismachineperson(C)) //speshul snowfleks deserv speshul treetment
			C.adjustFireLoss(6969)  //remember - slimes love fire
		else
			C.death()

		visible_message(span_danger("[capitalize(C.declent_ru(NOMINATIVE))] падает замертво, когда [genderize_ru(C.gender,"его","её","его","их")] поражает заряд смерти!"))

/obj/projectile/magic/fireball/Range()
	var/turf/T1 = get_step(src,turn(dir, -45))
	var/turf/T2 = get_step(src,turn(dir, 45))
	var/turf/T3 = get_step(src,dir)
	var/mob/living/L = locate(/mob/living) in T1 //if there's a mob alive in our front right diagonal, we hit it.
	if(L && L.stat != DEAD)
		Bump(L) //Magic Bullet #teachthecontroversy
		return
	L = locate(/mob/living) in T2
	if(L && L.stat != DEAD)
		Bump(L)
		return
	L = locate(/mob/living) in T3
	if(L && L.stat != DEAD)
		Bump(L)
		return
	..()

/obj/projectile/magic/fireball/on_hit(atom/target, blocked = 0, hit_zone)
	. = ..()
	var/turf/T = get_turf(target)
	explosion(T, exp_devastate, exp_heavy, exp_light, exp_flash, adminlog = FALSE, flame_range = exp_fire, cause = src)
	if(!ismob(target)) //multiple flavors of pain
		return
	var/mob/living/M = target
	M.take_overall_damage(0,10) //between this 10 burn, the 10 brute, the explosion brute, and the onfire burn, your at about 65 damage if you stop drop and roll immediately


/obj/projectile/magic/fireball/infernal
	name = "infernal fireball"
	ru_names = list(
		NOMINATIVE = "адский фаербол",
		GENITIVE = "адского фаербола",
		DATIVE = "адскому фаерболу",
		ACCUSATIVE = "адский фаербол",
		INSTRUMENTAL = "адским фаерболом",
		PREPOSITIONAL = "адском фаерболе"
	)
	exp_heavy = -1
	exp_light = -1
	exp_flash = 4
	exp_fire= -1
	var/hellfire_power = BURN_LEVEL_TIER_1
	var/hellfire_type = /datum/reagent/napalm/hellfire

/obj/projectile/magic/fireball/infernal/acsend
	name = "acsend fireball"
	hellfire_power = BURN_LEVEL_TIER_9
	hellfire_type = null

/obj/projectile/magic/fireball/infernal/on_hit(atom/target, blocked = 0, hit_zone)
	. = ..()
	var/turf/fire_turf = get_turf(target)
	flame_radius(3, fire_turf, BURN_TIME_DEVIL, hellfire_power, FLAMESHAPE_IRREGULAR, target, FIRE_VARIANT_DEFAULT, hellfire_type)

/obj/projectile/magic/resurrection
	name = "bolt of resurrection"
	ru_names = list(
		NOMINATIVE = "воскрешающий заряд",
		GENITIVE = "воскрешающего заряда",
		DATIVE = "воскрешающему заряду",
		ACCUSATIVE = "воскрешающий заряд",
		INSTRUMENTAL = "воскрешающим зарядом",
		PREPOSITIONAL = "воскрешающем заряде"
	)
	icon_state = "ion"

/obj/projectile/magic/resurrection/on_hit(var/mob/living/carbon/target)
	. = ..()
	if(ismob(target))
		if(target.mind && !target.mind.hasSoul)
			return .
		var/old_stat = target.stat
		target.suiciding = 0
		target.revive()
		if(!target.ckey)
			for(var/mob/dead/observer/ghost in GLOB.player_list)
				if(target.real_name == ghost.real_name)
					ghost.reenter_corpse()
					break
		if(old_stat != DEAD)
			to_chat(target, span_notice("Вы чувствуете себя великолепно!"))
		else
			to_chat(target, span_notice("Вы восстаете из мёртвых. <b>ВЫ СНОВА ЖИВЫ!!!</b>"))

/obj/projectile/magic/teleport
	name = "bolt of teleportation"
	ru_names = list(
		NOMINATIVE = "телепортационный импульс",
		GENITIVE = "телепортационного импульса",
		DATIVE = "телепортационному импульсу",
		ACCUSATIVE = "телепортационный импульс",
		INSTRUMENTAL = "телепортационным импульсом",
		PREPOSITIONAL = "телепортационном импульсе"
	)
	icon_state = "bluespace"
	var/inner_tele_radius = 0
	var/outer_tele_radius = 6

/obj/projectile/magic/teleport/on_hit(var/mob/target)
	. = ..()
	var/teleammount = 0
	var/teleloc = target
	if(!isturf(target))
		teleloc = target.loc
	for(var/atom/movable/stuff in teleloc)
		if(!stuff.anchored && stuff.loc)
			teleammount++
			do_teleport(stuff, stuff, 10)
			var/datum/effect_system/fluid_spread/smoke/smoke = new
			smoke.set_up(amount = max(round(10 - teleammount),1), location = stuff.loc) //Smoke drops off if a lot of stuff is moved for the sake of sanity
			smoke.start()

/obj/projectile/magic/door
	name = "bolt of door creation"
	ru_names = list(
		NOMINATIVE = "заряд создания дверей",
		GENITIVE = "заряда создания дверей",
		DATIVE = "заряду создания дверей",
		ACCUSATIVE = "заряд создания дверей",
		INSTRUMENTAL = "зарядом создания дверей",
		PREPOSITIONAL = "заряде создания дверей"
	)
	icon_state = "energy"
	var/list/door_types = list(/obj/structure/mineral_door/wood,/obj/structure/mineral_door/iron,/obj/structure/mineral_door/silver,\
		/obj/structure/mineral_door/gold,/obj/structure/mineral_door/uranium,/obj/structure/mineral_door/sandstone,/obj/structure/mineral_door/transparent/plasma,\
		/obj/structure/mineral_door/transparent/diamond)

/obj/projectile/magic/door/on_hit(var/atom/target)
	. = ..()
	var/atom/T = target.loc
	if(isturf(target) && target.density)
		CreateDoor(target)
	else if(isturf(T) && T.density)
		CreateDoor(T)
	else if(istype(target, /obj/machinery/door))
		OpenDoor(target)
	else if(istype(target, /obj/structure/closet))
		OpenCloset(target)

/obj/projectile/magic/door/proc/CreateDoor(turf/T)
	var/door_type = pick(door_types)
	var/obj/structure/mineral_door/D = new door_type(T)
	T.ChangeTurf(/turf/simulated/floor/plasteel)
	D.Open()

/obj/projectile/magic/door/proc/OpenDoor(var/obj/machinery/door/D)
	if(istype(D,/obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = D
		A.locked = FALSE
	D.open()

/obj/projectile/magic/door/proc/OpenCloset(var/obj/structure/closet/C)
	if(C?.locked)
		C.locked = FALSE
	C.open()

/obj/projectile/magic/change
	name = "bolt of change"
	ru_names = list(
		NOMINATIVE = "заряд полиморфа",
		GENITIVE = "заряда полиморфа",
		DATIVE = "заряду полиморфа",
		ACCUSATIVE = "заряд полиморфа",
		INSTRUMENTAL = "зарядом полиморфа",
		PREPOSITIONAL = "заряде полиморфа"
	)
	icon_state = "ice_1"
	damage_type = BURN

/obj/projectile/magic/change/on_hit(var/atom/change)
	. = ..()
	wabbajack(change)

/proc/wabbajack(mob/living/M)
	if(istype(M) && M.stat != DEAD && !HAS_TRAIT(M, TRAIT_NO_TRANSFORM))
		ADD_TRAIT(M, TRAIT_NO_TRANSFORM, PERMANENT_TRANSFORMATION_TRAIT)
		M.icon = null
		M.cut_overlays()
		M.invisibility = INVISIBILITY_ABSTRACT

		if(isrobot(M))
			var/mob/living/silicon/robot/Robot = M
			QDEL_NULL(Robot.mmi)
			Robot.notify_ai(ROBOT_NOTIFY_AI_CONNECTED)
		else
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				// Make sure there are no organs or limbs to drop
				for(var/t in H.bodyparts)
					qdel(t)
				for(var/i in H.internal_organs)
					qdel(i)
			for(var/obj/item/W in M)
				M.temporarily_remove_item_from_inventory(W, force = TRUE)
				qdel(W)

		var/mob/living/new_mob
		var/briefing_msg
		var/is_new_mind = FALSE

		var/randomize = pick("РОБОТ", "ТЕРРОР", "КСЕНОМОРФ", "ЧЕЛОВЕК", "ЖИВОТНОЕ")
		switch(randomize)
			if("РОБОТ")
				is_new_mind = TRUE
				var/path
				if(prob(50))
					path = pick(typesof(/mob/living/silicon/robot/syndicate))
					new_mob = new path(M.loc)
					briefing_msg = ""
				else
					new_mob = new /mob/living/silicon/robot/ert/gamma(M.loc)
					briefing_msg = ""
				new_mob.gender = M.gender
				new_mob.invisibility = 0
				new_mob.job = JOB_TITLE_CYBORG
				var/mob/living/silicon/robot/Robot = new_mob
				if(ishuman(M))
					Robot.mmi = new /obj/item/mmi(new_mob)
					Robot.mmi.transfer_identity(M)	//Does not transfer key/client.
				else
					Robot.mmi = new /obj/item/mmi/robotic_brain(new_mob)
					Robot.mmi.brainmob.timeofhostdeath = M.timeofdeath
					Robot.mmi.brainmob.set_stat(CONSCIOUS)
					Robot.mmi.update_appearance(UPDATE_ICON_STATE|UPDATE_NAME)
				Robot.lawupdate = FALSE
				Robot.disconnect_from_ai()
				Robot.clear_inherent_laws()
				Robot.clear_zeroth_law()
			if("ТЕРРОР")
				is_new_mind = TRUE
				var/terror = pick(prob(20); "lurker", prob(20); "knight", prob(20); "drone", prob(15); "widow", prob(15); "reaper", prob(10); "destroyer")
				switch(terror)
					if("lurker")
						new_mob = new /mob/living/simple_animal/hostile/poison/terror_spider/lurker(M.loc)
					if("knight")
						new_mob = new /mob/living/simple_animal/hostile/poison/terror_spider/knight(M.loc)
					if("drone")
						new_mob = new /mob/living/simple_animal/hostile/poison/terror_spider/builder(M.loc)
					if("widow")
						new_mob = new /mob/living/simple_animal/hostile/poison/terror_spider/widow(M.loc)
					if("reaper")
						new_mob = new /mob/living/simple_animal/hostile/poison/terror_spider/reaper(M.loc)
					if("destroyer")
						new_mob = new /mob/living/simple_animal/hostile/poison/terror_spider/destroyer(M.loc)
				new_mob.universal_speak = TRUE
			if("КСЕНОМОРФ")
				is_new_mind = TRUE
				if(prob(50))
					new_mob = new /mob/living/carbon/alien/humanoid/hunter(M.loc)
				else
					new_mob = new /mob/living/carbon/alien/humanoid/sentinel(M.loc)
				new_mob.universal_speak = TRUE

				briefing_msg = "Вам разрешается убивать нексеноморфов среди вас. Прежде всего вам лучше обнаружить других себеподобных и подготовить место для улья.."
			if("ЖИВОТНОЕ")
				is_new_mind = TRUE
				var/beast = pick("carp", "bear", "statue", "giantspider", "syndiemouse")
				switch(beast)
					if("carp")
						new_mob = new /mob/living/simple_animal/hostile/carp(M.loc)
					if("bear")
						new_mob = new /mob/living/simple_animal/hostile/bear(M.loc)
					if("statue")
						new_mob = new /mob/living/simple_animal/hostile/statue(M.loc)
					if("giantspider")
						var/spiderType = pick("hunterspider","nursespider","basicspider")
						switch(spiderType)
							if("hunterspider")
								new_mob = new /mob/living/simple_animal/hostile/poison/giant_spider/hunter(M.loc)
							if("nursespider")
								new_mob = new /mob/living/simple_animal/hostile/poison/giant_spider/nurse(M.loc)
							if("basicspider")
								new_mob = new /mob/living/simple_animal/hostile/poison/giant_spider(M.loc)
					if("syndiemouse")
						new_mob = new /mob/living/simple_animal/hostile/retaliate/syndirat(M.loc)
				briefing_msg = "Вы агрессивное животное, питаемое жаждой голода, вы можете совершать убийства, \
				сбиваться в стаи или следовать своему пути одиночки, но цель всегда будет одна - утолить свой голод."
				new_mob.universal_speak = TRUE
			if("ЧЕЛОВЕК")
				if(prob(50))
					new_mob = new /mob/living/carbon/human(M.loc)
					var/mob/living/carbon/human/H = new_mob
					var/datum/preferences/A = new()	//Randomize appearance for the human
					A.species = get_random_species(TRUE)
					A.copy_to(new_mob)
					randomize = H.dna.species.name
					if(ishuman(M))
						briefing_msg = "Вы тот же самый гуманоид, с тем же сознанием и той же памятью, \
						но ваша кожа теперь какая-то другая, да и вы сами теперь какой-то другой."
					else
						is_new_mind = TRUE
						briefing_msg = "Вы превратились в разумного гуманоида, знакомым с устройством мира и НТ."
				else
					new_mob = new /mob/living/carbon/human/lesser/monkey(M.loc)
					if(ishuman(M))
						briefing_msg = "Вы разумная мартышка, вам хоть и хочется бананов, \
						но у вас по прежнему память о своей прошлой жизни..."
					else
						is_new_mind = TRUE
						briefing_msg = "Вы разумная мартышка, и вам хочется бананов."

			else
				return

		add_attack_logs(null, M, "became [new_mob.real_name]", ATKLOG_ALL)

		new_mob.a_intent = INTENT_HARM
		if(M.mind)
			M.mind.transfer_to(new_mob)
			if(is_new_mind)
				new_mob.mind.wipe_memory()
				if(briefing_msg)
					new_mob.mind.store_memory(briefing_msg)
		else
			new_mob.key = M.key

		if(is_new_mind)
			to_chat(new_mob, span_danger("Вы потеряли свою личность и память! Отыгрывайте новое существо!"))
		to_chat(new_mob, span_danger("ТЕПЕРЬ ВЫ [uppertext(randomize)]"))
		if(briefing_msg)
			to_chat(new_mob, chat_box_red(span_userdanger("[briefing_msg]")))

		qdel(M)
		return new_mob

/obj/projectile/magic/animate
	name = "bolt of animation"
	ru_names = list(
		NOMINATIVE = "анимационный заряд",
		GENITIVE = "анимационного заряда",
		DATIVE = "анимационному заряду",
		ACCUSATIVE = "анимационный заряд",
		INSTRUMENTAL = "анимационным зарядом",
		PREPOSITIONAL = "анимационном заряде"
	)
	icon_state = "red_1"
	damage_type = BURN


/obj/projectile/magic/animate/on_hit(atom/target, blocked = 0, hit_zone)
	. = ..()

	if(isitem(target) || (isstructure(target) && !is_type_in_list(target, GLOB.protected_objects)))
		if(istype(target, /obj/structure/closet/statue))
			for(var/mob/living/carbon/human/prisoner in target)
				var/mob/living/simple_animal/hostile/statue/statue = new(target.loc, firer)
				statue.name = "statue of [prisoner.real_name]"
				statue.faction = list("\ref[firer]")
				statue.icon = target.icon
				if(prisoner.mind)
					prisoner.mind.transfer_to(statue)
					var/list/messages = list()
					messages.Add("<span class='userdanger'>You have been transformed into an animated statue.</span>")
					messages.Add("You cannot move when monitored, but are nearly invincible and deadly when unobserved! Hunt down those who shackle you.")
					messages.Add("Do not harm [firer.real_name], your creator.")
					to_chat(statue, chat_box_red(messages.Join("<br>")))
				prisoner.forceMove(statue)
				qdel(target)
		else
			if(isgun(target))
				new /mob/living/simple_animal/hostile/mimic/copy/ranged(target.loc, target, firer)
			else
				new /mob/living/simple_animal/hostile/mimic/copy(target.loc, target, firer)

	else if(istype(target, /mob/living/simple_animal/hostile/mimic/copy))
		// Change our allegiance!
		var/mob/living/simple_animal/hostile/mimic/copy/mimic = target
		mimic.ChangeOwner(firer)


/obj/projectile/magic/spellblade
	name = "blade energy"
	ru_names = list(
		NOMINATIVE = "энергия лезвия",
		GENITIVE = "энергии лезвия",
		DATIVE = "энергии лезвия",
		ACCUSATIVE = "энергию лезвия",
		INSTRUMENTAL = "энергией лезвия",
		PREPOSITIONAL = "энергии лезвия"
	)
	icon_state = "lavastaff"
	damage = 15
	damage_type = BURN
	flag = "magic"
	dismemberment = 50
	dismember_head = TRUE
	nodamage = FALSE

/obj/projectile/magic/slipping
	name = "magical banana"
	ru_names = list(
		NOMINATIVE = "волшебный банан",
		GENITIVE = "волшебного банана",
		DATIVE = "волшебному банану",
		ACCUSATIVE = "волшебный банан",
		INSTRUMENTAL = "волшебным бананом",
		PREPOSITIONAL = "волшебном банане"
	)
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "banana"
	hitsound = 'sound/items/bikehorn.ogg'
	var/slip_disable_time = 10 SECONDS

/obj/projectile/magic/slipping/New()
	..()
	SpinAnimation()

/obj/projectile/magic/slipping/on_hit(atom/target, blocked = 0)
	if(isrobot(target)) //You think you're safe, cyborg? FOOL!
		var/mob/living/silicon/robot/R = target
		if(!R.IsStunned())
			to_chat(target, span_warning("В вас попадает волшебный банан, ХОНКая ваши сенсоры!"))
			R.Stun(slip_disable_time)
	else if(isliving(target))
		var/mob/living/L = target
		playsound(L.loc, 'sound/misc/slip.ogg', 50, TRUE, -3)
		L.stop_pulling()
		// Something something don't run with scissors
		L.moving_diagonally = NONE //If this was part of diagonal move slipping will stop it.
		if(!L.IsWeakened())
			to_chat(target, span_warning("В вас попадает волшебный банан."))
			L.Weaken(slip_disable_time)
	. = ..()

/obj/projectile/magic/arcane_barrage
	name = "arcane bolt"
	ru_names = list(
		NOMINATIVE = "тайный заряд",
		GENITIVE = "тайного заряда",
		DATIVE = "тайному заряду",
		ACCUSATIVE = "тайный заряд",
		INSTRUMENTAL = "тайным зарядом",
		PREPOSITIONAL = "тайном заряде"
	)
	icon_state = "arcane_barrage"
	damage = 20
	damage_type = BURN
	nodamage = FALSE
	armour_penetration = 0
	flag = "magic"
	hitsound = 'sound/weapons/barragespellhit.ogg'
