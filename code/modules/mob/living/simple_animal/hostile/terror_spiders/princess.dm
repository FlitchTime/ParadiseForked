
// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T3 PRINCESS OF TERROR --------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: mini-queen, maintains a smaller nest, but also more expendable
// -------------: AI: maintains a small group of spiders. Small fraction of a queen's nest.
// -------------: SPECIAL: lays eggs over time, like a queen
// -------------: TO FIGHT IT: hunt it before it lays eggs
// -------------: SPRITES FROM: FoS, https://www.paradisestation.org/forum/profile/335-fos

/mob/living/simple_animal/hostile/poison/terror_spider/queen/princess
	name = "Princess of Terror spider"
	desc = "Огромный паук. Он выглядит необычайно милым и пушистым."
	ru_names = list(
		NOMINATIVE = "Принцесса Ужаса",
		GENITIVE = "Принцессы Ужаса",
		DATIVE = "Принцессе Ужаса",
		ACCUSATIVE = "Принцессу Ужаса",
		INSTRUMENTAL = "Принцессой Ужаса",
		PREPOSITIONAL = "Принцессе Ужаса",
	)
	ai_target_method = TS_DAMAGE_SIMPLE
	icon_state = "terror_princess1"
	icon_living = "terror_princess1"
	icon_dead = "terror_princess1_dead"
	melee_damage_lower = 15
	melee_damage_upper = 20
	obj_damage = 60
	maxHealth = 200
	health = 200
	speed = -0.1
	delay_web = 20
	deathmessage = "Издаёт пронзительный визг и медленно опадает на землю."
	death_sound = 'sound/creatures/terrorspiders/princess_death.ogg'
	spider_tier = TS_TIER_3
	move_resist = MOVE_FORCE_STRONG // no more pushing a several hundred if not thousand pound spider
	spider_intro_text = "Будучи Принцессой Ужаса, ваша задача - откладывать яйца и охранять их. Хоть вы и умеете плеваться кислотой, а также обладаете визгом, помогающим в бою, вам не стоит сражаться намеренно, ведь для этого есть другие пауки."
	datum_type = /datum/antagonist/terror_spider/main_spider/princess
	ranged = 1
	projectiletype = /obj/projectile/terrorspider/princess
	ranged_cooldown_time = 30
	canlay = 1
	hasnested = TRUE
	spider_spawnfrequency = 1600 // 160 seconds
	special_abillity = list(/obj/effect/proc_holder/spell/aoe/terror_shriek_princess)
	var/spider_max_children = 20
	tts_seed = "Lissandra"


/mob/living/simple_animal/hostile/poison/terror_spider/queen/princess/grant_queen_subtype_abilities()
	// Queens start in movement mode, where they can ventcrawl but not lay eggs. Then they move to NestMode() where they can wallsmash and egglay, but not ventcrawl.
	// Princesses are simpler, and can always lay eggs, always vent crawl, but never smash walls. Unlike queens, they don't have a "nesting" transformation.
	queeneggs_action = new()
	queeneggs_action.Grant(src)
	queensense_action = new()
	queensense_action.Grant(src)


/mob/living/simple_animal/hostile/poison/terror_spider/queen/princess/ListAvailableEggTypes()
	var/list/valid_types = list(TS_DESC_KNIGHT, TS_DESC_LURKER, TS_DESC_HEALER, TS_DESC_REAPER, TS_DESC_REAPER, TS_DESC_BUILDER)

	// Each princess can also have ONE black/purple/brown. If it dies, they can pick a new spider from the 3 advanced types to lay.
	var/list/spider_array = CountSpidersDetailed(TRUE, list(/mob/living/simple_animal/hostile/poison/terror_spider/widow, /mob/living/simple_animal/hostile/poison/terror_spider/guardian, /mob/living/simple_animal/hostile/poison/terror_spider/destroyer))
	if(spider_array["all"] < 3)
		valid_types |= TS_DESC_WIDOW
		valid_types |= TS_DESC_GUARDIAN
		valid_types |= TS_DESC_DESTROYER

	return valid_types

/mob/living/simple_animal/hostile/poison/terror_spider/queen/princess/Life(seconds, times_fired)
	. = ..()
	if(stat != DEAD)
		if(ckey)
			if(world.time > (spider_lastspawn + spider_spawnfrequency))
				grant_eggs()

/mob/living/simple_animal/hostile/poison/terror_spider/queen/princess/grant_eggs()
	spider_lastspawn = world.time

	var/list/spider_array = CountSpidersDetailed(TRUE)
	var/brood_count = spider_array["all"]

	// Color shifts depending on how much of their brood capacity they have used.
	if(brood_count == 0)
		icon_state = "terror_princess1"
		icon_living = "terror_princess1"
		icon_dead = "terror_princess1_dead"
		desc = "Огромный паук. Он выглядит странно милым и пушистым, с нежно-розовым мехом, покрывающим большую часть его тела"
	else if(brood_count < (spider_max_children /2))
		icon_state = "terror_princess2"
		icon_living = "terror_princess2"
		icon_dead = "terror_princess2_dead"
		desc = "Огромный паук. Раньше он выглядел странно милым и пушистым, но теперь этот эффект портят части меха, которые приобрели зловещий кроваво-красный цвет."
	else
		icon_state = "terror_princess3"
		icon_living = "terror_princess3"
		icon_dead = "terror_princess3_dead"
		desc = "Огромный паук. Всё его тело покрыто засохшей кровью."

	if((brood_count + canlay) >= spider_max_children)
		return
	canlay++
	if(canlay == 1)
		to_chat(src, span_notice("У вас есть яйцо, которое можно отложить."))
		SEND_SOUND(src, sound('sound/effects/ping.ogg'))
	else
		to_chat(src, span_notice("У вас есть [canlay] [declension_ru(canlay, "яйцо", "яйца", "яиц")], которые можно отложить."))
		SEND_SOUND(src, sound('sound/effects/ping.ogg'))

/mob/living/simple_animal/hostile/poison/terror_spider/queen/princess/NestMode()
	// Princesses don't nest. However, we still need to override this in case an AI princess calls it.
	return

/mob/living/simple_animal/hostile/poison/terror_spider/queen/princess/spider_special_action()
	// Princess AI routine. GREATLY simplified version of queen routine.
	if(!stat && !ckey)
		// Utilize normal queen AI for finding a nest site (neststep=0), and activating NestMode() (neststep=1)
		if(neststep != 2)
			return ..()
		// After that, simply lay an egg once per nestfrequency, until we have the max.
		if(world.time < (lastnestsetup + nestfrequency))
			return
		lastnestsetup = world.time
		if(ai_nest_is_full())
			return
		spider_lastspawn = world.time
		DoLayTerrorEggs(pick(spider_types_standard), 1)
		// Yes, this means NPC princesses won't create T2 spiders.


/mob/living/simple_animal/hostile/poison/terror_spider/queen/princess/ai_nest_is_full()
	var/list/spider_array = CountSpidersDetailed(TRUE)
	if(spider_array["all"] >= spider_max_children)
		return TRUE
	return FALSE

/obj/projectile/terrorspider/princess
	name = "princess venom"
	icon_state = "toxin4"
	damage = 25
	stamina = 25
	damage_type = BURN
