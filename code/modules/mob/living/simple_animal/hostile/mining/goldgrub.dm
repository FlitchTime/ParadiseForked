//An ore-devouring but easily scared creature
/mob/living/simple_animal/hostile/asteroid/goldgrub
	name = "goldgrub"
	desc = "A worm that grows fat from eating everything in its sight. Seems to enjoy precious metals and other shiny things, hence the name."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "Goldgrub"
	icon_living = "Goldgrub"
	icon_aggro = "Goldgrub_alert"
	icon_dead = "Goldgrub_dead"
	icon_gib = "syndicate_gib"
	vision_range = 2
	aggro_vision_range = 9
	move_to_delay = 5
	friendly = "harmlessly rolls into"
	maxHealth = 45
	health = 45
	harm_intent_damage = 5
	melee_damage_lower = 0
	melee_damage_upper = 0
	attacktext = "давит"
	attack_sound = 'sound/weapons/punch1.ogg'
	a_intent = INTENT_HELP
	speak_emote = list("screeches")
	throw_message = "sinks in slowly, before being pushed out of "
	deathmessage = "spits up the contents of its stomach before dying!"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/monstermeat/goldgrub = 1)
	status_flags = CANPUSH
	search_objects = 1
	wanted_objects = list(/obj/item/stack/ore/diamond, /obj/item/stack/ore/gold, /obj/item/stack/ore/silver,
						  /obj/item/stack/ore/uranium, /obj/item/stack/ore/titanium)
	jewelry_loot = /obj/item/gem/rupee
	var/chase_time = 100
	var/will_burrow = TRUE
	var/max_loot = 15 // The maximum amount of ore that can be stored in this thing's gut

/mob/living/simple_animal/hostile/asteroid/goldgrub/Initialize(mapload)
	. = ..()
	var/i = rand(1,3)
	while(i)
		loot += pick(wanted_objects)
		i--

/mob/living/simple_animal/hostile/asteroid/goldgrub/GiveTarget(new_target)
	add_target(new_target)
	if(!QDELETED(target))
		if(wanted_objects[target.type] && loot.len < max_loot)
			visible_message("<span class='notice'>\The [name] looks at [target.name] with hungry eyes.</span>")
		else if(iscarbon(target) || issilicon(target))
			Aggro()
			visible_message("<span class='danger'>\The [name] tries to flee from \the [target.name]!</span>")
			retreat_distance = 10
			minimum_distance = 10
			if(will_burrow)
				addtimer(CALLBACK(src, PROC_REF(Burrow)), chase_time)

/mob/living/simple_animal/hostile/asteroid/goldgrub/AttackingTarget()
	if(wanted_objects[target.type])
		EatOre(target)
		return
	return ..()

/mob/living/simple_animal/hostile/asteroid/goldgrub/proc/EatOre(atom/targeted_ore)
	var/obj/item/stack/ore/O = targeted_ore
	if(length(loot) < max_loot)
		var/using = min(max_loot - length(loot), O.amount)
		for(var/i in 1 to using)
			loot += O.type
		O.use(using)
		visible_message("<span class='notice'>\The ore was swallowed whole by \the [name]!</span>")
	else // We are now full! We will consume no more ore ever again.
		search_objects = 0
		visible_message("<span class='notice'>\The [name] nibbles some of the ore and then stops. \She seems to be full!</span>")

/mob/living/simple_animal/hostile/asteroid/goldgrub/proc/Burrow()//You failed the chase to kill the goldgrub in time!
	if(stat == CONSCIOUS)
		visible_message("<span class='danger'>\The [name] buries into the ground, vanishing from sight!</span>")
		qdel(src)

/mob/living/simple_animal/hostile/asteroid/goldgrub/bullet_act(obj/projectile/P)
	visible_message(span_danger("[P.name] was repelled by \the [name]'s blubberous girth!"), projectile_message = TRUE)


/mob/living/simple_animal/hostile/asteroid/goldgrub/adjustHealth(
	amount = 0,
	updating_health = TRUE,
	blocked = 0,
	damage_type = BRUTE,
	forced = FALSE,
)
	. = ..()
	if(. && amount > 0)
		vision_range = 9

