#define TENTACLE_PATCH 1
#define SPAWN_CHILDREN 2
#define RAGE 3
#define CALL_CHILDREN 4

/**
 * # Goliath Broodmother
 *
 * A stronger, faster variation of the goliath.  Has the ability to spawn baby goliaths, which it can later detonate at will.
 * When it's health is below half, tendrils will spawn randomly around it.  When it is below a quarter of health, this effect is doubled.
 * It's attacks are as follows:
 * - Spawns a 3x3/plus shape of tentacles on the target location
 * - Spawns 2 baby goliaths on its tile, up to a max of 8.  Children blow up when they die.
 * - The broodmother lets out a noise, and is able to move faster for 6.5 seconds.
 * - Summons your children around you.
 * The broodmother is a fight revolving around stage control, as the activator has to manage the baby goliaths and the broodmother herself, along with all the tendrils.
 */

/mob/living/simple_animal/hostile/asteroid/elite/broodmother
	name = "goliath broodmother"
	desc = "Пример полового диморфизма - эта самка голиафа сильно отличается от самцов своего вида. Однако она столь же опасна, если не опаснее."
	ru_names = list(
		NOMINATIVE = "матка голиафов",
		GENITIVE = "матки голиафов",
		DATIVE = "матке голиафов",
		ACCUSATIVE = "матку голиафов",
		INSTRUMENTAL = "маткой голиафов",
		PREPOSITIONAL = "матке голиафов"
	)
	gender = FEMALE
	icon_state = "broodmother"
	icon_living = "broodmother"
	icon_aggro = "broodmother"
	icon_dead = "egg_sac"
	icon_gib = "syndicate_gib"
	maxHealth = 1000
	health = 1000
	melee_damage_lower = 30
	melee_damage_upper = 30
	armour_penetration = 40
	attacktext = "обрушивается на"
	attack_sound = 'sound/weapons/punch1.ogg'
	throw_message = "отскакивает от крепкой шкуры"
	speed = 2
	move_to_delay = 5
	mouse_opacity = MOUSE_OPACITY_ICON
	deathmessage = "взрывается, разлетаясь на куски!"
	loot_drop = /obj/item/crusher_trophy/broodmother_tongue
	tts_seed = "Azalina"

	attack_action_types = list(/datum/action/innate/elite_attack/tentacle_patch,
								/datum/action/innate/elite_attack/spawn_children,
								/datum/action/innate/elite_attack/rage,
								/datum/action/innate/elite_attack/call_children)

	var/rand_tent = 0
	var/list/mob/living/simple_animal/hostile/asteroid/elite/broodmother_child/children_list = list()

/datum/action/innate/elite_attack/tentacle_patch
	name = "Поле из щупалец"
	button_icon_state = "tentacle_patch"
	chosen_message = span_boldwarning("Теперь вы атакуете щупальцами!")
	chosen_attack_num = TENTACLE_PATCH

/datum/action/innate/elite_attack/spawn_children
	name = "Выпуск выводка"
	button_icon_state = "spawn_children"
	chosen_message = span_boldwarning("Вы создаёте двух детёнышей для помощи в бою. Максимум - 8.")
	chosen_attack_num = SPAWN_CHILDREN

/datum/action/innate/elite_attack/rage
	name = "Бешенство"
	button_icon_state = "rage"
	chosen_message = span_boldwarning("Вы временно увеличиваете скорость передвижения.")
	chosen_attack_num = RAGE

/datum/action/innate/elite_attack/call_children
	name = "Зов"
	button_icon_state = "call_children"
	chosen_message = span_boldwarning("Вы призываете своих детёнышей к себе.")
	chosen_attack_num = CALL_CHILDREN

/mob/living/simple_animal/hostile/asteroid/elite/broodmother/Destroy()
	for(var/mob/living/simple_animal/hostile/asteroid/elite/broodmother_child/C in children_list)
		C.mother = null
	children_list.Cut()
	children_list = null
	return ..()

/mob/living/simple_animal/hostile/asteroid/elite/broodmother/OpenFire()
	if(client)
		switch(chosen_attack)
			if(TENTACLE_PATCH)
				tentacle_patch(target)
			if(SPAWN_CHILDREN)
				spawn_children()
			if(RAGE)
				rage()
			if(CALL_CHILDREN)
				call_children()
		return
	var/aiattack = rand(1,4)
	switch(aiattack)
		if(TENTACLE_PATCH)
			tentacle_patch(target)
		if(SPAWN_CHILDREN)
			spawn_children()
		if(RAGE)
			rage()
		if(CALL_CHILDREN)
			call_children()

/mob/living/simple_animal/hostile/asteroid/elite/broodmother/Life(seconds, times_fired)
	. = ..()
	if(!.) //Checks if they are dead as a rock.
		return
	if(rand_tent < world.time)
		rand_tent = world.time + 30
		var/tentacle_amount = 3
		if(health < maxHealth * 0.5)
			tentacle_amount = 5
		if(health < maxHealth * 0.25)
			tentacle_amount = 10
		var/tentacle_loc = spiral_range_turfs(5, get_turf(src))
		for(var/i in 1 to tentacle_amount)
			var/turf/t = pick_n_take(tentacle_loc)
			new /obj/effect/temp_visual/goliath_tentacle/broodmother(t, src)

/mob/living/simple_animal/hostile/asteroid/elite/broodmother/proc/tentacle_patch(target)
	ranged_cooldown = world.time + 4 SECONDS * revive_multiplier()
	var/tturf = get_turf(target)
	if(!isturf(tturf))
		return
	visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] зарывает свои щупальца под [target]!"))
	new /obj/effect/temp_visual/goliath_tentacle/broodmother/patch(tturf, src)

/mob/living/simple_animal/hostile/asteroid/elite/broodmother/proc/spawn_children(target)
	ranged_cooldown = world.time + 3 SECONDS * revive_multiplier()
	visible_message(span_danger("За [declent_ru(INSTRUMENTAL)] вздымается земля!!"))
	for(var/i in 1 to 2)
		if(length(children_list) >= 8)
			return
		var/mob/living/simple_animal/hostile/asteroid/elite/broodmother_child/newchild = new(loc)
		newchild.GiveTarget(target)
		newchild.faction = faction.Copy()
		newchild.maxHealth *= dif_mult
		newchild.health *= dif_mult
		newchild.melee_damage_lower = newchild.melee_damage_lower * dif_mult_dmg
		newchild.melee_damage_upper = newchild.melee_damage_upper * dif_mult_dmg
		visible_message(span_danger("Под [declent_ru(INSTRUMENTAL)] появляется [newchild.declent_ru(NOMINATIVE)]!"))
		newchild.mother = src
		children_list += newchild

/mob/living/simple_animal/hostile/asteroid/elite/broodmother/proc/rage()
	ranged_cooldown = world.time + 10 SECONDS * revive_multiplier()
	visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] начинает набирать скорость!"))
	color = "#FF0000"
	set_varspeed(0)
	move_to_delay = 3
	addtimer(CALLBACK(src, PROC_REF(reset_rage)), 7 SECONDS)

/mob/living/simple_animal/hostile/asteroid/elite/broodmother/proc/reset_rage()
	color = "#FFFFFF"
	set_varspeed(2)
	move_to_delay = 5

/mob/living/simple_animal/hostile/asteroid/elite/broodmother/proc/call_children()
	ranged_cooldown = world.time + 4 SECONDS * revive_multiplier()
	visible_message(span_warning("Земля дрожит рядом с [declent_ru(INSTRUMENTAL)]!"))
	var/list/directions = GLOB.cardinal.Copy() + GLOB.diagonals.Copy()
	for(var/mob/living/child in children_list)
		var/spawndir = pick_n_take(directions)
		var/turf/T = get_step(src, spawndir)
		if(T)
			child.forceMove(T)
			child.revive() // at most this is a 49 hp heal.
			playsound(src, 'sound/effects/bamf.ogg', 100, 1)

/mob/living/simple_animal/hostile/asteroid/elite/broodmother/AltShiftClickOn(atom/A)
	if(isliving(A))
		var/mob/living/mob = A
		var/mobref = "\ref[mob]"
		if(mob == reviver)
			return
		if(mobref in faction)
			faction -= mobref
			friends -= mob
			for(var/mob/living/simple_animal/hostile/asteroid/elite/child in children_list)
				if(mobref in child.faction)
					child.faction -= mobref
					child.friends -= mob
			to_chat(src, span_warning("Вы удалили [mob.declent_ru(ACCUSATIVE)] из списка друзей."))
		else
			faction += mobref
			friends += mob
			for(var/mob/living/simple_animal/hostile/asteroid/elite/child in children_list)
				if(!(mobref in child.faction))
					child.faction += mobref
					child.friends += mob
			to_chat(src, span_notice("Вы добавили [mob.declent_ru(ACCUSATIVE)] в список друзей."))



//The goliath's children.  Pretty weak, simple mobs which are able to put a single tentacle under their target when at range.
/mob/living/simple_animal/hostile/asteroid/elite/broodmother_child
	name = "baby goliath"
	desc = "Молодой голиаф, недавно появившийся на свет. Хотя они вылупляются из яиц, эти яйца инкубируются в матери, пока не будут готовы к рождению."
	ru_names = list(
		NOMINATIVE = "детёныш голиафа",
		GENITIVE = "детёныша голиафа",
		DATIVE = "детёнышу голиафа",
		ACCUSATIVE = "детёныша голиафа",
		INSTRUMENTAL = "детёнышем голиафа",
		PREPOSITIONAL = "детёныше голиафа"
	)
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "goliath_baby"
	icon_living = "goliath_baby"
	icon_aggro = "goliath_baby"
	icon_dead = "goliath_baby_dead"
	icon_gib = "syndicate_gib"
	maxHealth = 100
	health = 100
	melee_damage_lower = 12.5
	melee_damage_upper = 12.5
	armour_penetration = 50
	response_help = "гладит"
	attacktext = "бьётся о"
	attack_sound = 'sound/weapons/punch1.ogg'
	throw_message = "отскакивает от крепкой шкуры"
	speed = 1.6
	move_to_delay = 5
	mouse_opacity = MOUSE_OPACITY_ICON
	deathmessage = "падает на землю."
	status_flags = CANPUSH
	var/mob/living/simple_animal/hostile/asteroid/elite/broodmother/mother = null


/mob/living/simple_animal/hostile/asteroid/elite/broodmother_child/Destroy()
	if(!QDELETED(mother))
		mother.children_list -= src
	mother = null
	return ..()


/mob/living/simple_animal/hostile/asteroid/elite/broodmother_child/death(gibbed)
	. = ..()
	if(!QDELETED(mother))
		mother.children_list -= src
	visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] взрывается!"))
	explosion(src, flame_range = 3, adminlog = FALSE)
	new /obj/item/stack/sheet/animalhide/goliath_hide(loc)
	new /obj/effect/gibspawner/human(get_turf(src))
	qdel(src)


/obj/effect/temp_visual/goliath_tentacle/broodmother
	var/damage = 25
	var/stun_duration = 1
	var/stun_delay = 1.5

/obj/effect/temp_visual/goliath_tentacle/broodmother/tripanim()
	icon_state = "Goliath_tentacle_wiggle"
	deltimer(timerid)
	timerid = addtimer(CALLBACK(src, PROC_REF(trip)), stun_delay, TIMER_STOPPABLE)

//Tentacles stun WAY less compared to regular variant, to balance being able to use them much more often. Also, 10 more damage.
/obj/effect/temp_visual/goliath_tentacle/broodmother/trip()
	var/latched = FALSE
	for(var/mob/living/L in loc)
		if((!QDELETED(spawner) && spawner.faction_check_mob(L)) || L.stat == DEAD)
			continue
		visible_message(span_danger("[capitalize(declent_ru(NOMINATIVE))] опутывает щупальцами [L.declent_ru(ACCUSATIVE)]!"))
		L.Stun(stun_duration)
		L.adjustBruteLoss(damage)
		latched = TRUE
	if(!latched)
		retract()
	else
		deltimer(timerid)
		timerid = addtimer(CALLBACK(src, PROC_REF(retract)), stun_duration * 10, TIMER_STOPPABLE)

/obj/effect/temp_visual/goliath_tentacle/broodmother/patch/Initialize(mapload, new_spawner)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(createpatch))

/obj/effect/temp_visual/goliath_tentacle/broodmother/patch/proc/createpatch()
	var/tentacle_locs = spiral_range_turfs(2, get_turf(src))
	for(var/T in tentacle_locs)
		new /obj/effect/temp_visual/goliath_tentacle/broodmother(T, spawner)
	var/list/directions = GLOB.cardinal.Copy()
	for(var/i in directions)
		var/turf/T = get_step(get_turf(src), i)
		for(var/j in 1 to 2)
			T = get_step(T, i)
			new /obj/effect/temp_visual/goliath_tentacle/broodmother(T, spawner)

// Broodmother's loot: Broodmother Tongue
/obj/item/crusher_trophy/broodmother_tongue
	name = "broodmother tongue"
	desc = "Язык матери целой стаи. На ощупь очень губчатый, интересно что будет если на него надавить? Может быть прикреплен на крушитель в качестве трофея."
	ru_names = list(
            NOMINATIVE = "материнский язык",
            GENITIVE = "материнского языка",
            DATIVE = "материнскому языку",
            ACCUSATIVE = "материнский язык",
            INSTRUMENTAL = "материнским языком",
            PREPOSITIONAL = "материнском языке"
	)
	gender = MALE
	icon = 'icons/obj/lavaland/elite_trophies.dmi'
	icon_state = "broodmother_tongue"
	denied_type = /obj/item/crusher_trophy/broodmother_tongue
	bonus_value = 75 // same reasoning as legionnaire trophy, target if moving will dodge it, and things like hiero trophy does more anyway.
	/// Time at which the item becomes usable again
	var/use_time

/obj/item/crusher_trophy/broodmother_tongue/effect_desc()
	return "Взрыв метки с <b>[bonus_value]%</b> шансом призывает поле щупалец под врагом"

/obj/item/crusher_trophy/broodmother_tongue/on_mark_detonation(mob/living/target, mob/living/user)
	if(prob(bonus_value) && target.stat != DEAD)
		new /obj/effect/temp_visual/goliath_tentacle/broodmother/patch(get_turf(target), user)

/obj/item/crusher_trophy/broodmother_tongue/attack_self(mob/user)
	if(!isliving(user))
		return
	var/mob/living/living_user = user
	if(use_time > world.time)
		balloon_alert(living_user, "перезарядка")
		return
	else if(HAS_TRAIT(living_user, TRAIT_LAVA_IMMUNE))
		balloon_alert(living_user, "мне это не нужно")
		return

	ADD_TRAIT(living_user, TRAIT_LAVA_IMMUNE, BROODMOTHER_TONGUE_TRAIT)
	addtimer(TRAIT_CALLBACK_REMOVE(living_user, TRAIT_LAVA_IMMUNE, BROODMOTHER_TONGUE_TRAIT), 20 SECONDS)
	to_chat(user, span_notice("Вы сжимаете <b>[declent_ru(ACCUSATIVE)]</b> в руке, разбрызгивая на себя полупрозрачную жидкость."))
	use_time = world.time + 60 SECONDS


#undef TENTACLE_PATCH
#undef SPAWN_CHILDREN
#undef RAGE
#undef CALL_CHILDREN
