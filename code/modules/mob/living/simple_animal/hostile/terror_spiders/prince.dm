
// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T3 PRINCE OF TERROR --------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: boss
// -------------: AI: no special ai
// -------------: SPECIAL: massive health
// -------------: TO FIGHT IT: a squad of at least 4 people with laser rifles.
// -------------: SPRITES FROM: Travelling Merchant, https://www.paradisestation.org/forum/profile/2715-travelling-merchant/

/mob/living/simple_animal/hostile/poison/terror_spider/prince
	name = "Prince of Terror"
	desc = "Огромный, ужасающий паук. Похоже, он уничтожает всё, что видит. Его шкура кажется непробиваемой, и на нём видны шрамы многих сражений."
	ru_names = list(
		NOMINATIVE = "Принц Ужаса",
		GENITIVE = "Принца Ужаса",
		DATIVE = "Принцу Ужаса",
		ACCUSATIVE = "Принца Ужаса",
		INSTRUMENTAL = "Принцем Ужаса",
		PREPOSITIONAL = "Принце Ужаса",
	)
	ai_target_method = TS_DAMAGE_BRUTE
	icon_state = "terror_allblack"
	icon_living = "terror_allblack"
	icon_dead = "terror_allblack_dead"
	maxHealth = 600
	health = 600
	speed = -0.1
	damage_coeff = list(BRUTE = 0.3, BURN = 0.6, TOX = 1, CLONE = 0, STAMINA = 0, OXY = 0.2)
	deathmessage =  "болезненно рычит, трясётся и ослабевает, пока смерть наконец не смывает пылающую ненависть из его ужасающих глаз."
	death_sound = 'sound/creatures/terrorspiders/prince_dead.ogg'
	regeneration = 0 //no healing on life, prince should play agressive
	force_threshold = 30
	melee_damage_lower = 35
	melee_damage_upper = 45
	armour_penetration = 20
	obj_damage = 100
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	var/delimb_chance = 10
	attack_sound = 'sound/creatures/terrorspiders/bite2.ogg'
	ventcrawler_trait = null
	ai_ventcrawls = FALSE
	idle_ventcrawl_chance = 0
	spider_tier = TS_TIER_3
	spider_opens_doors = 2
	web_type = null
	special_abillity = list(/obj/effect/proc_holder/spell/aoe/terror_slam)
	spider_intro_text = "Будучи Принцом Ужаса, ваша задача - устроить резню. У вас больше здоровья и урона, чем у любого другого паука, вы можете отрывать конечности, быстро уничтожать мехи, однако, если вы не будете пожирать трупы, сразу потеряете способность регенерировать. Ваша активная способность оглушает противников в радиусе двух плиток, попутно замедляя их."
	datum_type = /datum/antagonist/terror_spider/main_spider/prince
	gender = MALE
	move_resist = MOVE_FORCE_STRONG // no more pushing a several hundred if not thousand pound spider
	tts_seed = "Alduin"

/mob/living/simple_animal/hostile/poison/terror_spider/prince/death(gibbed)
	if(can_die() && !hasdied && spider_uo71)
		UnlockBlastDoors("UO71_SciStorage")
	return ..()

/mob/living/simple_animal/hostile/poison/terror_spider/prince/spider_specialattack(mob/living/carbon/human/L)
	if(prob(delimb_chance))
		if(L.stat != DEAD) //no dismemberment for dead carbons, less griefy
			do_attack_animation(L)
			if(L.check_shields(src, 25, "[name]", ITEM_ATTACK, armour_penetration))
				return FALSE
			L.adjustBruteLoss(25)
			L.Weaken(2 SECONDS)
			playsound(src, 'sound/creatures/terrorspiders/rip.ogg', 100, 1)
			var/obj/item/organ/external/NB = pick(L.bodyparts)
			visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] отрывает [NB.declent_ru(ACCUSATIVE)] [L.declent_ru(GENITIVE)] своими острыми, как бритва, челюстями!"))
			NB.droplimb()  //dismemberment
			L.apply_damage(35, STAMINA)
	else
		. = ..()


