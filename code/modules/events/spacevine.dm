//Types of usual mutations
#define	POSITIVE 			1
#define	NEGATIVE			2
#define	MINOR_NEGATIVE		3

/datum/event/spacevine
	announceWhen = 120
	var/obj/structure/spacevine_controller/SC

/datum/event/spacevine/Destroy(force)
	SC = null
	return ..()

/datum/event/spacevine/start()
	var/list/turfs = list() //list of all the empty floor turfs in the hallway areas

	var/obj/structure/spacevine/SV = new()

	for(var/area/hallway/A in GLOB.areas)
		for(var/turf/F in A)
			if(F.Enter(SV))
				turfs += F

	qdel(SV)

	if(turfs.len) //Pick a turf to spawn at if we can
		var/turf/T = pick(turfs)
		SC = new /obj/structure/spacevine_controller(T, null, rand(30, 70), rand(5, 2)) // spawn a controller at turf

		// Make the event start fun - give the vine a random hostile mutation
		if(SC.vines.len)
			SV = SC.vines[1]
			var/list/mutations = SC.mutations_list.Copy()
			while(mutations.len)
				var/datum/spacevine_mutation/SM = pick_n_take(mutations)
				if(SM.quality == NEGATIVE && !SM.nofun)
					SM.add_mutation_to_vinepiece(SV)
					break
			mutations.Cut()
			mutations = null

/datum/event/spacevine/announce(false_alarm)
	if((false_alarm || LAZYLEN(SC?.vines)) && (LAZYLEN(GLOB.player_list) < 20))
		GLOB.event_announcement.Announce("Биосканеры фиксируют рост космической лозы в [get_area(SC.loc)]. Избавьтесь от неё, прежде чем она нанесёт ущерб станции.", "ВНИМАНИЕ: БИОЛОГИЧЕСКАЯ УГРОЗА.")

/datum/spacevine_mutation
	var/name = ""
	var/severity = 1
	var/hue
	var/quality
	// For stuff that isn't fun as a random-event vine
	var/nofun = FALSE

/datum/spacevine_mutation/proc/add_mutation_to_vinepiece(obj/structure/spacevine/holder)
	holder.mutations |= src
	holder.color = hue

/datum/spacevine_mutation/proc/remove_mutation_from_vinepiece(obj/structure/spacevine/holder)
	holder.mutations -= src
	var/datum/spacevine_mutation/oldmutation
	if(holder.mutations.len)
		oldmutation = pick(holder.mutations)
		holder.color = oldmutation.hue
	else
		holder.color = ""

/datum/spacevine_mutation/proc/process_mutation(obj/structure/spacevine/holder)
	return

/datum/spacevine_mutation/proc/process_temperature(obj/structure/spacevine/holder, temp, volume)
	return

/datum/spacevine_mutation/proc/on_birth(obj/structure/spacevine/holder)
	return

/datum/spacevine_mutation/proc/on_grow(obj/structure/spacevine/holder)
	return

/datum/spacevine_mutation/proc/on_death(obj/structure/spacevine/holder)
	return

/datum/spacevine_mutation/proc/on_deletion(obj/structure/spacevine/holder)
	return

/datum/spacevine_mutation/proc/on_hit(obj/structure/spacevine/holder, mob/hitter, obj/item/I, expected_damage)
	. = expected_damage

/datum/spacevine_mutation/proc/on_cross(obj/structure/spacevine/holder, mob/crosser)
	return

/datum/spacevine_mutation/proc/on_chem(obj/structure/spacevine/holder, datum/reagent/R)
	return

/datum/spacevine_mutation/proc/on_eat(obj/structure/spacevine/holder, mob/living/eater)
	return

/datum/spacevine_mutation/proc/on_spread(obj/structure/spacevine/holder, turf/target)
	return

/datum/spacevine_mutation/proc/on_buckle(obj/structure/spacevine/holder, mob/living/buckled)
	return

/datum/spacevine_mutation/proc/on_explosion(severity, obj/structure/spacevine/holder)
	return

/datum/spacevine_mutation/proc/on_search(severity, obj/structure/spacevine/holder)
	return


/datum/spacevine_mutation/space_covering
	name = "space protective"
	hue = "#aa77aa"
	quality = POSITIVE

/turf/simulated/floor/vines
	color = "#aa77aa"
	icon_state = "vinefloor"
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_GRASS
	clawfootstep = FOOTSTEP_GRASS
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/simulated/floor/vines/broken_states()
	return list()

//All of this shit is useless for vines


/turf/simulated/floor/vines/attackby(obj/item/I, mob/user, params)
	return ATTACK_CHAIN_BLOCKED_ALL


/turf/simulated/floor/vines/burn_tile()
	return

/turf/simulated/floor/vines/break_tile()
	return

/turf/simulated/floor/vines/make_plating()
	return

/turf/simulated/floor/vines/break_tile_to_plating()
	return

/turf/simulated/floor/vines/ex_act(severity)
	if(severity < 3)
		ChangeTurf(baseturf)

/turf/simulated/floor/vines/narsie_act()
	if(prob(20))
		ChangeTurf(baseturf) //nar sie eats this shit

/turf/simulated/floor/vines/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		if(prob(50))
			ChangeTurf(baseturf)

/turf/simulated/floor/vines/ChangeTurf(turf/simulated/floor/T, defer_change = FALSE, keep_icon = TRUE, after_flags = NONE, copy_existing_baseturf = TRUE)
	. = ..()
	//Do this *after* the turf has changed as qdel in spacevines will call changeturf again if it hasn't
	for(var/obj/structure/spacevine/SV in src)
		SV.wither()

/datum/spacevine_mutation/space_covering
	var/static/list/coverable_turfs

/datum/spacevine_mutation/space_covering/New()
	. = ..()
	if(!coverable_turfs)
		coverable_turfs = typecacheof(list(
			/turf/space
		))
		coverable_turfs -= typecacheof(list(
			/turf/space/transit
		))

/datum/spacevine_mutation/space_covering/on_grow(obj/structure/spacevine/holder)
	process_mutation(holder)

/datum/spacevine_mutation/space_covering/on_spread(obj/structure/spacevine/holder, turf/target)
	if(isspaceturf(target) && !(locate(/obj/structure/spacevine) in target) && is_location_within_transition_boundaries(target))
		holder.master.spawn_spacevine_piece(target, holder)
		. = TRUE

/datum/spacevine_mutation/space_covering/process_mutation(obj/structure/spacevine/holder)
	var/turf/T = get_turf(holder)
	if(is_type_in_typecache(T, coverable_turfs))
		var/currtype = T.type
		T.ChangeTurf(/turf/simulated/floor/vines)
		T.baseturf = currtype

/datum/spacevine_mutation/space_covering/on_deletion(obj/structure/spacevine/holder)
	var/turf/T = get_turf(holder)
	if(istype(T, /turf/simulated/floor/vines))
		T.ChangeTurf(T.baseturf)

/datum/spacevine_mutation/bluespace
	name = "bluespace"
	hue = "#3333ff"
	quality = MINOR_NEGATIVE

/datum/spacevine_mutation/bluespace/on_spread(obj/structure/spacevine/holder, turf/target)
	if(holder.energy > 1 && !(locate(/obj/structure/spacevine) in target) && is_location_within_transition_boundaries(target))
		// Lose bluespace upon piercing a single tile, and drop it from our own mutations too
		// Representing a loss in "high potential"
		// also conveniently prevents this from spreading too crazily
		remove_mutation_from_vinepiece(holder)
		holder.master.spawn_spacevine_piece(target, holder)
		playsound(holder, 'sound/misc/interference.ogg', 50, 1)
		. = TRUE

/datum/spacevine_mutation/light
	name = "light"
	hue = "#ffff00"
	quality = POSITIVE
	severity = 4

/datum/spacevine_mutation/light/on_grow(obj/structure/spacevine/holder)
	if(holder.energy)
		holder.set_light(severity)

/datum/spacevine_mutation/toxicity
	name = "toxic"
	hue = "#ff00ff"
	severity = 10
	quality = NEGATIVE

/datum/spacevine_mutation/toxicity/on_cross(obj/structure/spacevine/holder, mob/living/crosser)
	if(issilicon(crosser))
		return
	if(prob(severity) && istype(crosser) && !isvineimmune(crosser))
		to_chat(crosser, "<span class='alert'>You accidently touch the vine and feel a strange sensation.</span>")
		crosser.apply_damage(5, TOX)

/datum/spacevine_mutation/toxicity/on_eat(obj/structure/spacevine/holder, mob/living/eater)
	if(!isvineimmune(eater))
		eater.apply_damage(5, TOX)

/datum/spacevine_mutation/explosive  //OH SHIT IT CAN CHAINREACT RUN!!!
	name = "explosive"
	hue = "#ff0000"
	quality = NEGATIVE
	severity = 2
	// kaboom events aren't fun
	nofun = TRUE

/datum/spacevine_mutation/explosive/on_explosion(explosion_severity, obj/structure/spacevine/holder)
	if(explosion_severity < 3)
		qdel(holder)
	else
		. = 1
		spawn(5)
			holder.wither()

/datum/spacevine_mutation/explosive/on_death(obj/structure/spacevine/holder, mob/hitter, obj/item/I)
	explosion(holder.loc, 0, 0, severity, 0, 0)

/datum/spacevine_mutation/fire_proof
	name = "fire proof"
	hue = "#ff8888"
	quality = MINOR_NEGATIVE

/datum/spacevine_mutation/fire_proof/process_temperature(obj/structure/spacevine/holder, temp, volume)
	return 1

/datum/spacevine_mutation/fire_proof/on_hit(obj/structure/spacevine/holder, mob/hitter, obj/item/I, expected_damage)
	if(I && I.damtype == BURN)
		. = 0
	else
		. = expected_damage

/datum/spacevine_mutation/vine_eating
	name = "vine eating"
	hue = "#ff7700"
	quality = MINOR_NEGATIVE

/datum/spacevine_mutation/vine_eating/on_spread(obj/structure/spacevine/holder, turf/target)
	var/obj/structure/spacevine/prey = locate() in target
	if(prey && !prey.mutations.Find(src))  //Eat all vines that are not of the same origin
		prey.wither()
		. = TRUE

/datum/spacevine_mutation/aggressive_spread  //very OP, but im out of other ideas currently
	name = "aggressive spreading"
	hue = "#333333"
	severity = 3
	quality = NEGATIVE

/datum/spacevine_mutation/aggressive_spread/on_spread(obj/structure/spacevine/holder, turf/target)
	if(isreinforcedwallturf(target))
		// Too tough to pierce - should lead to interesting spread patterns
		return
	// Bust through windows or other stuff blocking the way
	if(!target.Enter(holder))
		for(var/atom/movable/AM in target)
			if(istype(AM, /obj/structure/spacevine) || !AM.density)
				continue
			AM.ex_act(severity)
	target.ex_act(severity) // vine immunity handled at /mob/ex_act
	. = TRUE

/datum/spacevine_mutation/aggressive_spread/on_buckle(obj/structure/spacevine/holder, mob/living/buckled)
	buckled.ex_act(severity)

/datum/spacevine_mutation/transparency
	name = "transparent"
	hue = ""
	quality = POSITIVE

/datum/spacevine_mutation/transparency/on_grow(obj/structure/spacevine/holder)
	holder.set_opacity(0)
	holder.alpha = 125

/datum/spacevine_mutation/thorns
	name = "thorny"
	hue = "#666666"
	severity = 10
	quality = NEGATIVE

/datum/spacevine_mutation/thorns/on_cross(obj/structure/spacevine/holder, mob/living/crosser)
	if(prob(severity) && istype(crosser) && !isvineimmune(holder))
		var/mob/living/M = crosser
		M.adjustBruteLoss(5)
		to_chat(M, "<span class='alert'>You cut yourself on the thorny vines.</span>")

/datum/spacevine_mutation/thorns/on_hit(obj/structure/spacevine/holder, mob/living/hitter, obj/item/I, expected_damage)
	if(prob(severity) && istype(hitter) && !isvineimmune(holder))
		var/mob/living/M = hitter
		M.adjustBruteLoss(5)
		to_chat(M, "<span class='alert'>You cut yourself on the thorny vines.</span>")
	. =	expected_damage

/datum/spacevine_mutation/woodening
	name = "hardened"
	hue = "#997700"
	quality = NEGATIVE

/datum/spacevine_mutation/woodening/on_grow(obj/structure/spacevine/holder)
	if(holder.energy)
		holder.set_density(TRUE)
	holder.max_integrity = 100
	holder.obj_integrity = holder.max_integrity

/datum/spacevine_mutation/woodening/on_hit(obj/structure/spacevine/holder, mob/living/hitter, obj/item/I, expected_damage)
	if(!is_sharp(I))
		. = expected_damage * 0.5
	else
		. = expected_damage

/datum/spacevine_mutation/flowering
	name = "flowering"
	hue = "#0A480D"
	quality = NEGATIVE
	severity = 10

/datum/spacevine_mutation/flowering/on_grow(obj/structure/spacevine/holder)
	if(holder.energy == 2 && prob(severity) && !locate(/obj/structure/alien/resin/flower_bud_enemy) in range(5,holder))
		new /obj/structure/alien/resin/flower_bud_enemy(get_turf(holder))

/datum/spacevine_mutation/flowering/on_cross(obj/structure/spacevine/holder, mob/living/crosser)
	if(prob(25))
		holder.entangle(crosser)


/datum/spacevine_mutation/virulent_spread
	name = "virulently spreading"
	hue = "#FF8080"
	quality = MINOR_NEGATIVE

/datum/spacevine_mutation/virulent_spread/on_search(obj/structure/spacevine/holder)
	return 1

// Sure, let's encourage crew members to deliberately breed a highly dangerous
// threat. What could *possibly* go wrong? ;)
/datum/spacevine_mutation/mineral
	name = "metallic"
	hue = "#444444"
	quality = POSITIVE
	severity = 3
	var/drop_rate = 40
	var/list/mineral_results = list(
	/obj/item/stack/sheet/metal = 1
	)

/datum/spacevine_mutation/mineral/on_death(obj/structure/spacevine/holder)
	if(!prob(drop_rate))
		return
	var/itemtype = pickweight(mineral_results)
	var/turf/pos = get_turf(holder)
	new itemtype(pos, severity)

/datum/spacevine_mutation/mineral/valuables
	name = "glimmering"
	hue = "#888800"
	drop_rate = 20
	mineral_results = list(
	/obj/item/stack/sheet/mineral/silver = 4,
	/obj/item/stack/sheet/mineral/gold = 2,
	/obj/item/stack/sheet/mineral/diamond = 1
	)

/datum/spacevine_mutation/mineral/glass
	name = "glassy"
	hue = "#8888FF"
	mineral_results = list(
	/obj/item/stack/sheet/glass = 1
	)

/datum/spacevine_mutation/mineral/plastic
	name = "plasticine"
	hue = "#222288"
	mineral_results = list(
	/obj/item/stack/sheet/plastic = 1
	)

/datum/spacevine_mutation/mineral/wood
	name = "wooden"
	hue = "#442200"
	mineral_results = list(
	/obj/item/stack/sheet/wood = 1
	)

// SPACE VINES (Note that this code is very similar to Biomass code)
/obj/structure/spacevine
	name = "space vines"
	desc = "An extremely expansionistic species of vine."
	icon = 'icons/effects/spacevines.dmi'
	icon_state = "Light1"
	anchored = TRUE
	density = FALSE
	layer = SPACEVINE_LAYER
	mouse_opacity = MOUSE_OPACITY_OPAQUE //Clicking anywhere on the turf is good enough
	pass_flags = PASSTABLE | PASSGRILLE
	max_integrity = 50
	var/energy = 0
	var/obj/structure/spacevine_controller/master = null
	var/list/mutations = list()


/obj/structure/spacevine/Initialize(mapload)
	. = ..()
	color = "#ffffff"
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/obj/structure/spacevine/Destroy()
	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_deletion(src)
	if(master)
		master.vines -= src
		master.growth_queue -= src
		if(!master.vines.len)
			var/obj/item/seeds/kudzu/KZ = new(loc)
			KZ.mutations |= mutations
			KZ.set_potency(10 ** sqrt(master.mutativeness))
			KZ.set_production(10 - (master.spread_cap / 10))
			qdel(master)
	master = null
	mutations.Cut()
	set_opacity(FALSE)
	if(has_buckled_mobs())
		unbuckle_all_mobs(force = TRUE)
	return ..()


/obj/structure/spacevine/examine(mob/user)
	. = ..()
	var/text = "This one is a"
	if(mutations.len)
		for(var/A in mutations)
			var/datum/spacevine_mutation/SM = A
			text += " [SM.name]"
	else
		text += " normal"
	text += " vine."
	. += "<span class='notice'>[text]</span>"


/obj/structure/spacevine/proc/wither()
	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_death(src)
	qdel(src)


/obj/structure/spacevine/has_prints()
	return FALSE

/obj/structure/spacevine/proc/add_mutation(datum/spacevine_mutation/mutation)
	mutations |= mutation
	color = mutation.hue

/obj/structure/spacevine/proc/on_chem_effect(datum/reagent/R)
	var/override = 0
	for(var/datum/spacevine_mutation/SM in mutations)
		override += SM.on_chem(src, R)
	if(!override && istype(R, /datum/reagent/glyphosate))
		if(prob(50))
			wither()

/obj/structure/spacevine/proc/eat(mob/eater)
	var/override = 0
	for(var/datum/spacevine_mutation/SM in mutations)
		override += SM.on_eat(src, eater)
	if(!override)
		if(prob(10))
			eater.say("Nom")
		wither()


/obj/structure/spacevine/proceed_attack_results(obj/item/I, mob/living/user, params, def_zone)
	. = ATTACK_CHAIN_PROCEED_SUCCESS
	if(!I.force)
		user.visible_message(
			span_warning("[user] gently pokes [src] with [I]."),
			span_warning("You gently poke [src] with [I]."),
		)
		return .
	user.visible_message(
		span_danger("[user] has hit [src] with [I]!"),
		span_danger("You have hit [src] with [I]!"),
	)
	var/damage_dealt = I.force
	var/obj/item/scythe/scythe = I
	//so folded telescythes won't get damage boosts / insta-clears (they instead will be treated like non-scythes)
	if(istype(I, /obj/item/scythe) && scythe.extend)
		damage_dealt *= 4
		for(var/obj/structure/spacevine/spacevine in range(1, src))
			for(var/datum/spacevine_mutation/mutation as anything in spacevine.mutations)
				//on_hit now takes override damage as arg and returns new value for other mutations to permutate further
				damage_dealt = mutation.on_hit(src, user, I, damage_dealt)
			//this only is going to occur for woodening mutation vines (increased health) or if we nerf scythe damage/multiplier
			if(spacevine.obj_integrity > damage_dealt)
				spacevine.take_damage(damage_dealt, I.damtype, MELEE, TRUE, get_dir(user, spacevine), I.armour_penetration)
			else
				spacevine.wither()
		if(QDELETED(src))
			return ATTACK_CHAIN_BLOCKED_ALL
		return .

	if(is_sharp(I) || I.damtype == BURN)
		damage_dealt *= 4

	for(var/datum/spacevine_mutation/mutation as anything in mutations)
		damage_dealt = mutation.on_hit(src, user, I, damage_dealt)

	take_damage(damage_dealt, I.damtype, MELEE, TRUE, get_dir(user, src), I.armour_penetration)
	if(QDELETED(src))
		return ATTACK_CHAIN_BLOCKED_ALL


/obj/structure/spacevine/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/weapons/slash.ogg', 50, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/spacevine/obj_destruction()
	wither()


/obj/structure/spacevine/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(isliving(arrived))
		for(var/datum/spacevine_mutation/mutation in mutations)
			mutation.on_cross(src, arrived)


/obj/structure/spacevine/attack_hand(mob/user)
	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_hit(src, user)
	user_unbuckle_mob(user, user)

/obj/structure/spacevine/attack_alien(mob/living/user)
	eat(user)

/obj/structure/spacevine_controller
	invisibility = INVISIBILITY_ABSTRACT
	var/list/obj/structure/spacevine/vines = list()
	var/list/growth_queue = list()
	var/spread_multiplier = 5
	var/spread_cap = 30
	var/list/mutations_list = list()
	var/mutativeness = 0

/obj/structure/spacevine_controller/New(loc, list/muts, potency, production)
	color = "#ffffff"
	spawn_spacevine_piece(loc, null, muts)
	START_PROCESSING(SSobj, src)
	init_subtypes(/datum/spacevine_mutation/, mutations_list)
	// 1 mutativeness at 10 potency
	// 4 mutativeness at 100 potency
	if(potency)
		mutativeness = log(10, potency) ** 2

	if(production != null)
		// 1 production is crazy powerful
		var/spread_value = max(10 - production, 1)
		// 40 at 6 production
		// 90 at 1 production
		spread_cap = spread_value * 10
		// 6 vines/spread at 6 production
		// ~2.5 vines/spread at 1 production
		spread_multiplier /= spread_value / 5

	..()


/obj/structure/spacevine_controller/ex_act() //only killing all vines will end this suffering
	return

/obj/structure/spacevine_controller/singularity_act()
	return

/obj/structure/spacevine_controller/singularity_pull()
	return

/obj/structure/spacevine_controller/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/spacevine_controller/has_prints()
	return FALSE

/obj/structure/spacevine_controller/proc/spawn_spacevine_piece(turf/location, obj/structure/spacevine/parent, list/muts)
	var/obj/structure/spacevine/SV = new(location)
	growth_queue += SV
	vines += SV
	SV.master = src
	if(muts && muts.len)
		for(var/datum/spacevine_mutation/M in muts)
			M.add_mutation_to_vinepiece(SV)
		return
	if(parent)
		SV.mutations |= parent.mutations
		SV.color = parent.color
		if(prob(mutativeness))
			var/list/random_mutations_picked = mutations_list - SV.mutations
			if(random_mutations_picked.len)
				var/datum/spacevine_mutation/randmut = pick(random_mutations_picked)
				randmut.add_mutation_to_vinepiece(SV)

	for(var/datum/spacevine_mutation/SM in SV.mutations)
		SM.on_birth(SV)

/obj/structure/spacevine_controller/process()
	if(!vines || !vines.len)
		qdel(src) //space vines exterminated. Remove the controller
		return
	if(!growth_queue)
		qdel(src) //Sanity check
		return

	var/length = 0

	length = min( spread_cap , max( 1 , vines.len / spread_multiplier ) )
	var/i = 0
	var/list/obj/structure/spacevine/queue_end = list()

	for(var/obj/structure/spacevine/SV in growth_queue)
		if(QDELETED(SV))
			continue
		i++
		queue_end += SV
		growth_queue -= SV
		for(var/datum/spacevine_mutation/SM in SV.mutations)
			SM.process_mutation(SV)
		if(SV.energy < 2) //If tile isn't fully grown
			if(prob(20))
				SV.grow()
		else //If tile is fully grown
			SV.entangle_mob()

		//if(prob(25))
		SV.spread()
		if(i >= length)
			break

	growth_queue = growth_queue + queue_end

/obj/structure/spacevine/proc/grow()
	if(!energy)
		icon_state = pick("Med1", "Med2", "Med3")
		energy = 1
		set_opacity(TRUE)
	else
		icon_state = pick("Hvy1", "Hvy2", "Hvy3")
		energy = 2

	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_grow(src)

/obj/structure/spacevine/proc/entangle_mob()
	if(!has_buckled_mobs() && prob(25))
		for(var/mob/living/V in loc)
			entangle(V)
			if(has_buckled_mobs())
				break //only capture one mob at a time


/obj/structure/spacevine/proc/entangle(mob/living/V)
	if(!V || isvineimmune(V))
		return
	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_buckle(src, V)
	if((V.stat != DEAD) && (V.buckled != src)) //not dead or captured
		to_chat(V, "<span class='danger'>The vines [pick("wind", "tangle", "tighten")] around you!</span>")
		buckle_mob(V, 1)

/obj/structure/spacevine/proc/spread()
	var/list/dir_list = GLOB.cardinal.Copy()
	var/spread_search = FALSE // Whether to exhaustive search all 4 cardinal dirs for an open direction
	for(var/datum/spacevine_mutation/SM in mutations)
		spread_search |= SM.on_search(src)
	while(dir_list.len)
		var/direction = pick_n_take(dir_list)
		var/turf/stepturf = get_step(src, direction)
		if(!stepturf)
			continue
		var/spread_success = FALSE
		for(var/datum/spacevine_mutation/SM in mutations)
			spread_success |= SM.on_spread(src, stepturf) // If this returns 1, spreading succeeded
		if(!locate(/obj/structure/spacevine, stepturf))
			// snowflake for space turf, but space turf is super common and a big deal
			if(!isspaceturf(stepturf) && stepturf.Enter(src) && is_location_within_transition_boundaries(stepturf))
				master?.spawn_spacevine_piece(stepturf, src)
				spread_success = TRUE
		if(spread_success || !spread_search)
			break

/obj/structure/spacevine/ex_act(severity)
	var/i
	for(var/datum/spacevine_mutation/SM in mutations)
		i += SM.on_explosion(severity, src)
	if(!i && prob(100/severity))
		wither()

/obj/structure/spacevine/temperature_expose(null, temp, volume)
	..()
	var/override = 0
	for(var/datum/spacevine_mutation/SM in mutations)
		override += SM.process_temperature(src, temp, volume)
	if(!override)
		wither()


/obj/structure/spacevine/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(isvineimmune(mover))
		return TRUE


/proc/isvineimmune(atom/A)
	. = FALSE
	if(isliving(A))
		var/mob/living/M = A
		if(("vines" in M.faction) || ("plants" in M.faction))
			. = TRUE
