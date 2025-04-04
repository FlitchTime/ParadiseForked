#define REGENERATION_DELAY 20  // After taking damage, how long it takes for automatic regeneration to begin for megacarps (ty robustin!)

/mob/living/simple_animal/hostile/carp
	name = "space carp"
	desc = "Свирепое, клыкастое существо, похожее на рыбу."
	ru_names = list(
		NOMINATIVE = "космокарп",
		GENITIVE = "космокарпа",
		DATIVE = "космокарпу",
		ACCUSATIVE = "космокарпа",
		INSTRUMENTAL = "космокарпом",
		PREPOSITIONAL = "космокарпе"
	)
	icon = 'icons/mob/carp.dmi'
	icon_state = "base"
	icon_living = "base"
	icon_dead = "base_dead"
	icon_gib = "carp_gib"
	speak_chance = 0
	turns_per_move = 5
	butcher_results = list(/obj/item/reagent_containers/food/snacks/carpmeat = 2)
	response_help = "гладит"
	response_disarm = "осторожно отодвигает в сторону"
	emote_taunt = list("рычит", "фырчит", "пыхтит")
	taunt_chance = 30
	speed = 0
	maxHealth = 25
	health = 25

	harm_intent_damage = 8
	obj_damage = 50
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "кусает"
	attack_sound = 'sound/weapons/bite.ogg'
	speak_emote = list("гаркает")
	tts_seed = "Peon"

	//Space carp aren't affected by atmos.
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	faction = list("carp")
	pressure_resistance = 200
	gold_core_spawnable = HOSTILE_SPAWN
	AI_delay_max = 0.5 SECONDS

	var/carp_stamina_damage = 8

	var/random_color = TRUE //if the carp uses random coloring
	var/rarechance = 1 //chance for rare color variant

	var/static/list/carp_colors = list(\
	"lightpurple" = "#c3b9f1", \
	"lightpink" = "#da77a8", \
	"green" = "#70ff25", \
	"grape" = "#df0afb", \
	"swamp" = "#e5e75a", \
	"turquoise" = "#04e1ed", \
	"brown" = "#ca805a", \
	"teal" = "#20e28e", \
	"lightblue" = "#4d88cc", \
	"rusty" = "#dd5f34", \
	"beige" = "#bbaeaf", \
	"yellow" = "#f3ca4a", \
	"blue" = "#09bae1", \
	"palegreen" = "#7ef099", \
	)
	var/static/list/carp_colors_rare = list(\
	"silver" = "#fdfbf3", \
	)


/mob/living/simple_animal/hostile/carp/Initialize(mapload)
	. = ..()
	carp_randomify(rarechance)
	update_icons()
	ADD_TRAIT(src, TRAIT_HEALS_FROM_CARP_RIFTS, INNATE_TRAIT)
	AddElement(/datum/element/simple_flying)

/mob/living/simple_animal/hostile/carp/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		maxbodytemp = 1500, \
		minbodytemp = 0, \
	)

/mob/living/simple_animal/hostile/carp/proc/carp_randomify(rarechance)
	if(random_color)
		var/our_color
		if(prob(rarechance))
			our_color = pick(carp_colors_rare)
			add_atom_colour(carp_colors_rare[our_color], FIXED_COLOUR_PRIORITY)
		else
			our_color = pick(carp_colors)
			add_atom_colour(carp_colors[our_color], FIXED_COLOUR_PRIORITY)
		regenerate_icons()

/mob/living/simple_animal/hostile/carp/proc/add_carp_overlay()
	if(!random_color)
		return
	var/mutable_appearance/base_overlay = mutable_appearance(icon, "base_mouth")
	base_overlay.appearance_flags = RESET_COLOR
	add_overlay(base_overlay)

/mob/living/simple_animal/hostile/carp/proc/add_dead_carp_overlay()
	if(!random_color)
		return
	var/mutable_appearance/base_dead_overlay = mutable_appearance(icon, "base_dead_mouth")
	base_dead_overlay.appearance_flags = RESET_COLOR
	add_overlay(base_dead_overlay)

/mob/living/simple_animal/hostile/carp/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	return TRUE	//No drifting in space for space carp!	//original comments do not steal

/mob/living/simple_animal/hostile/carp/AttackingTarget()
	. = ..()
	if(. && ishuman(target))
		var/mob/living/carbon/human/H = target
		H.apply_damage(carp_stamina_damage, STAMINA)

/mob/living/simple_animal/hostile/carp/death(gibbed)
	. = ..()
	if(!random_color || gibbed)
		return
	regenerate_icons()

/mob/living/simple_animal/hostile/carp/revive()
	..()
	regenerate_icons()

/mob/living/simple_animal/hostile/carp/regenerate_icons()
	..()
	if(!random_color)
		return
	if(stat != DEAD)
		add_carp_overlay()
	else
		add_dead_carp_overlay()

/mob/living/simple_animal/hostile/carp/holocarp
	icon_state = "holocarp"
	icon_living = "holocarp"
	del_on_death = 1
	random_color = FALSE

/mob/living/simple_animal/hostile/carp/holocarp/ComponentInitialize()
	. = ..()
	AddComponent( \
		/datum/component/animal_temperature, \
		maxbodytemp = INFINITY, \
	)

/mob/living/simple_animal/hostile/carp/megacarp
	name = "Mega Space Carp"
	desc = "Свирепое, клыкастое существо, напоминающее акулу. Похоже, оно особенно озлоблено."
	ru_names = list(
		NOMINATIVE = "мегакосмокарп",
		GENITIVE = "мегакосмокарпа",
		DATIVE = "мегакосмокарпу",
		ACCUSATIVE = "мегакосмокарпа",
		INSTRUMENTAL = "мегакосмокарпом",
		PREPOSITIONAL = "мегакосмокарпе"
	)
	icon = 'icons/mob/alienqueen.dmi'
	icon_state = "megacarp"
	icon_living = "megacarp"
	icon_dead = "megacarp_dead"
	icon_gib = "megacarp_gib"
	pixel_x = -16
	mob_size = MOB_SIZE_LARGE
	random_color = FALSE

	obj_damage = 80
	melee_damage_lower = 30
	melee_damage_upper = 30

	var/regen_cooldown = 0
	tts_seed = "Shaker"

/mob/living/simple_animal/hostile/carp/megacarp/Initialize()
	. = ..()
	name = "[pick(GLOB.megacarp_first_names)] [pick(GLOB.megacarp_last_names)]"
	melee_damage_lower += rand(5, 10)
	melee_damage_upper += rand(10, 20)
	maxHealth += rand(60, 90)


/mob/living/simple_animal/hostile/carp/megacarp/adjustHealth(
	amount = 0,
	updating_health = TRUE,
	blocked = 0,
	damage_type = BRUTE,
	forced = FALSE,
)
	. = ..()
	if(. && amount > 0)
		regen_cooldown = world.time + REGENERATION_DELAY


/mob/living/simple_animal/hostile/carp/megacarp/Life()
	..()
	if(regen_cooldown < world.time)
		heal_overall_damage(4)

/mob/living/simple_animal/hostile/carp/sea
	name = "sea carp"
	desc = "Большая рыба, имеющая сходства с дальними космическими родственниками."
	ru_names = list(
		NOMINATIVE = "морской карп",
		GENITIVE = "морского карпа",
		DATIVE = "морскому карпу",
		ACCUSATIVE = "морского карпа",
		INSTRUMENTAL = "морским карпом",
		PREPOSITIONAL = "морском карпе"
	)
	icon_state = "carp"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/carpmeat = 1)
	response_help = "гладит"
	response_disarm = "осторожно отодвигает в сторону"
	response_harm = "ударяет"
	retreat_distance = 6
	vision_range = 5
	retaliate_only = TRUE
	gold_core_spawnable = NO_SPAWN
	var/carp_color = "carp" //holder for icon set

/mob/living/simple_animal/hostile/carp/sea/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		maxbodytemp = 350, \
		minbodytemp = 250, \
	)

/mob/living/simple_animal/hostile/carp/mcarp
	name = "mutated Carp"
	desc = "Космический карп со странной внешностью."
	ru_names = list(
		NOMINATIVE = "мутировавший карп",
		GENITIVE = "мутирововшего карпа",
		DATIVE = "мутирововшему карпу",
		ACCUSATIVE = "мутировавшего карпа",
		INSTRUMENTAL = "мутировавшим карпом",
		PREPOSITIONAL = "мутировавшем карпе"
	)
	icon_state = "Mcarp"
	icon_living = "Mcarp"
	icon_dead = "MCarp_Dead"

	obj_damage = 50
	melee_damage_lower = 25
	melee_damage_upper = 30
	maxHealth = 150
	health = 150

/mob/living/simple_animal/hostile/carp/koi
	name = "space koi"
	desc = "Дружелюбный кои, бороздящий просторы космоса."
	ru_names = list(
		NOMINATIVE = "космический кои",
		GENITIVE = "космического кои",
		DATIVE = "космическому кои",
		ACCUSATIVE = "космического кои",
		INSTRUMENTAL = "космическим кои",
		PREPOSITIONAL = "космическом кои"
	)
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "koi1"
	icon_living = "koi1"
	icon_dead = "koi1-dead"

	harm_intent_damage = 1
	melee_damage_lower = 2
	melee_damage_upper = 2
	obj_damage = 5
	maxHealth = 25
	health = 25
	speak_emote = list("бурчит")
	butcher_results = list(/obj/item/reagent_containers/food/snacks/salmonmeat = 1)

	var/randomize_icon = TRUE

	retaliate_only = TRUE

/mob/living/simple_animal/hostile/carp/koi/Initialize(mapload)
	. = ..()
	if(randomize_icon)
		var/koinum = rand(1, 4)
		icon_state = "koi[koinum]"
		icon_living = "koi[koinum]"
		icon_dead = "koi[koinum]-dead"

/mob/living/simple_animal/hostile/carp/koi/honk
	icon_state = "koi5"
	icon_living = "koi5"
	icon_dead = "koi5-dead"
	randomize_icon = FALSE
	retaliate_only = TRUE

#undef REGENERATION_DELAY
