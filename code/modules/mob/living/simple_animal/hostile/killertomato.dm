/mob/living/simple_animal/hostile/killertomato
	name = "Killer Tomato"
	desc = "Это чудовищно огромный мясной помидор, да ещё и с дополнительным запасом мякоти!"
	ru_names = list(
		NOMINATIVE = "Помидор-убийца",
		GENITIVE = "Помидора-убийцу",
		DATIVE = "Помидору-Убийце",
		ACCUSATIVE = "Помидора-Убийцу",
		INSTRUMENTAL = "Помидором-убийцей",
		PREPOSITIONAL = "Помидоре-убийце"
	)
	icon_state = "tomato"
	icon_living = "tomato"
	icon_dead = "tomato_dead"
	speak_chance = 0
	turns_per_move = 5
	maxHealth = 30
	health = 30
	nightvision = 3
	butcher_results = list(/obj/item/reagent_containers/food/snacks/tomatomeat = 2)
	response_help  = "толкает"
	response_disarm = "отталкивает"
	response_harm   = "ударяет"
	melee_damage_lower = 8
	melee_damage_upper = 12
	attacktext = "кусает"
	attack_sound = 'sound/weapons/punch1.ogg'
	ventcrawler_trait = TRAIT_VENTCRAWLER_ALWAYS
	faction = list("plants")

	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	gold_core_spawnable = HOSTILE_SPAWN
	AI_delay_max = 0 SECONDS

/mob/living/simple_animal/hostile/killertomato/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		maxbodytemp = 500, \
		minbodytemp = 150, \
	)
