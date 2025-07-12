/turf/simulated/floor/lava
	name = "lava"
	desc = "Раскалённая жидкая порода, бурлящая адским жаром. Контакт с ней приведёт к мгновенным ожогам."
	ru_names = list(
		NOMINATIVE = "лава",
		GENITIVE = "лавы",
		DATIVE = "лаве",
		ACCUSATIVE = "лаву",
		INSTRUMENTAL = "лавой",
		PREPOSITIONAL = "лаве"
	)
	icon = 'icons/turf/floors/lava.dmi'
	icon_state = "unsmooth"
	base_icon_state = "lava"
	smooth = SMOOTH_BITMASK
	canSmoothWith = SMOOTH_GROUP_FLOOR_LAVA
	smoothing_groups = SMOOTH_GROUP_FLOOR_LAVA
	gender = PLURAL //"That's some lava."
	baseturf = /turf/simulated/floor/lava //lava all the way down
	slowdown = 2
	light_range = 2
	light_power = 0.75
	light_color = LIGHT_COLOR_LAVA
	footstep = FOOTSTEP_LAVA
	barefootstep = FOOTSTEP_LAVA
	clawfootstep = FOOTSTEP_LAVA
	heavyfootstep = FOOTSTEP_LAVA
	real_layer = PLATING_LAYER
	/// How much fire damage we deal to living mobs stepping on us
	var/lava_damage = 20
	/// How many firestacks we add to living mobs stepping on us
	var/lava_firestacks = 20
	/// How much temperature we expose objects with
	var/temperature_damage = 10000
	/// Mobs with this trait won't burn.
	var/immunity_trait = TRAIT_LAVA_IMMUNE
	/// Objects with these flags won't burn.
	var/immunity_resistance_flags = LAVA_PROOF
	/// Is the lava close to the shore
	var/deep_water = TRUE

/turf/simulated/floor/lava/ex_act()
	return

/turf/simulated/floor/lava/acid_act(acidpwr, acid_volume)
	return

/turf/simulated/floor/lava/rcd_act(mob/user, obj/item/rcd/our_rcd, rcd_mode)
	return

/turf/simulated/floor/lava/airless
	temperature = TCMB

/turf/simulated/floor/lava/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(burn_stuff(arrived))
		START_PROCESSING(SSprocessing, src)

/turf/simulated/floor/lava/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(istype(AM, /obj/item/reagent_containers/food/snacks/charred_krill))
		krill_act(AM)
	else
		if(burn_stuff(AM))
			START_PROCESSING(SSprocessing, src)

/turf/simulated/floor/lava/proc/krill_act(atom/movable/AM)
	return

/turf/simulated/floor/lava/process()
	if(!burn_stuff())
		STOP_PROCESSING(SSprocessing, src)

/turf/simulated/floor/lava/singularity_act()
	return

/turf/simulated/floor/lava/singularity_pull(S, current_size)
	return

/turf/simulated/floor/lava/make_plating()
	return

/turf/simulated/floor/lava/remove_plating()
	return

/turf/simulated/floor/lava/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/floors.dmi'
	underlay_appearance.icon_state = "basalt"
	return TRUE

/turf/simulated/floor/lava/is_safe()
	if(HAS_TRAIT(src, TRAIT_LAVA_STOPPED) && ..())
		return TRUE
	return FALSE


///Generic return value of the can_burn_stuff() proc. Does nothing.
#define LAVA_BE_IGNORING 0
/// Another. Won't burn the target but will make the turf start processing.
#define LAVA_BE_PROCESSING 1
/// Burns the target and makes the turf process (depending on the return value of do_burn()).
#define LAVA_BE_BURNING 2

///Proc that sets on fire something or everything on the turf that's not immune to lava. Returns TRUE to make the turf start processing.
/turf/simulated/floor/lava/proc/burn_stuff(atom/movable/to_burn)
	if(HAS_TRAIT(src, TRAIT_LAVA_STOPPED))
		return FALSE

	var/thing_to_check = contents
	if(to_burn)
		thing_to_check = list(to_burn)
	for(var/atom/movable/burn_target as anything in thing_to_check)
		switch(can_burn_stuff(burn_target))
			if(LAVA_BE_IGNORING)
				continue
			if(LAVA_BE_BURNING)
				if(!do_burn(burn_target))
					continue
		. = TRUE


/turf/simulated/floor/lava/proc/can_burn_stuff(atom/movable/burn_target)
	if(QDELETED(burn_target))
		return LAVA_BE_IGNORING
	if(burn_target.movement_type & MOVETYPES_NOT_TOUCHING_GROUND || burn_target.no_gravity()) //you're flying over it.
		return LAVA_BE_IGNORING

	if(isobj(burn_target))
		if(burn_target.throwing) // to avoid gulag prisoners easily escaping, throwing only works for objects.
			return LAVA_BE_IGNORING
		var/obj/burn_obj = burn_target
		if((burn_obj.resistance_flags & immunity_resistance_flags) || (burn_obj.resistance_flags & INDESTRUCTIBLE))
			return LAVA_BE_PROCESSING
		return LAVA_BE_BURNING

	if(!isliving(burn_target))
		return LAVA_BE_IGNORING

	if(HAS_TRAIT(burn_target, immunity_trait))
		return LAVA_BE_PROCESSING

	var/mob/living/burn_living = burn_target
	if(burn_living.incorporeal_move)
		return LAVA_BE_PROCESSING

	var/atom/movable/burn_buckled = burn_living.buckled
	if(burn_buckled)
		if(burn_buckled.movement_type & MOVETYPES_NOT_TOUCHING_GROUND || burn_buckled.no_gravity())
			return LAVA_BE_PROCESSING
		if(isobj(burn_buckled))
			var/obj/burn_buckled_obj = burn_buckled
			if((burn_buckled_obj.resistance_flags & immunity_resistance_flags) || (burn_buckled_obj.resistance_flags & INDESTRUCTIBLE))
				return LAVA_BE_PROCESSING
		else if(HAS_TRAIT(burn_buckled, immunity_trait))
			return LAVA_BE_PROCESSING

	return LAVA_BE_BURNING

#undef LAVA_BE_IGNORING
#undef LAVA_BE_PROCESSING
#undef LAVA_BE_BURNING


/turf/simulated/floor/lava/proc/do_burn(atom/movable/burn_target)
	if(QDELETED(burn_target))
		return FALSE

	if(isobj(burn_target))
		var/obj/burn_obj = burn_target
		if(burn_obj.resistance_flags & ON_FIRE) // already on fire; skip it.
			return TRUE
		if(!(burn_obj.resistance_flags & FLAMMABLE))
			burn_obj.resistance_flags |= FLAMMABLE //Even fireproof things burn up in lava
		if(burn_obj.resistance_flags & FIRE_PROOF)
			burn_obj.resistance_flags &= ~FIRE_PROOF
		if(burn_obj.armor.getRating(FIRE) > 50) //obj with 100% fire armor still get slowly burned away.
			burn_obj.armor = burn_obj.armor.setRating(fire_value = 50)
		burn_obj.fire_act(exposed_temperature = temperature_damage, exposed_volume = 1000)
		return TRUE

	if(isliving(burn_target))
		var/mob/living/burn_living = burn_target
		burn_living.adjust_fire_stacks(lava_firestacks)
		burn_living.IgniteMob()
		burn_living.apply_damage(lava_damage, BURN, spread_damage = TRUE)
		return TRUE

	return FALSE


/turf/simulated/floor/lava/can_have_cabling()
	if(locate(/obj/structure/lattice/catwalk/fireproof, src))
		return TRUE
	return FALSE


/turf/simulated/floor/lava/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		return .

	if(istype(I, /obj/item/stack/fireproof_rods))
		var/obj/item/stack/fireproof_rods/rods = I
		if(locate(/obj/structure/lattice/catwalk/fireproof, src))
			to_chat(user, span_warning("Здесь уже есть мостик!"))
			return .
		var/obj/structure/lattice/fireproof/lattice = locate() in src
		if(!lattice)
			if(!rods.use(1))
				to_chat(user, span_warning("Вам нужен один огнеупорный стержень для постройки решётки!"))
				return .
			to_chat(user, span_notice("Вы установили прочную решётку."))
			playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
			new /obj/structure/lattice/fireproof(src)
			return .|ATTACK_CHAIN_SUCCESS
		if(!rods.use(2))
			to_chat(user, span_warning("Вам нужно два огнеупорных стержня для постройки мостика!"))
			return .
		qdel(lattice)
		playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
		to_chat(user, span_notice("Вы установили огнеупорный мостик."))
		new /obj/structure/lattice/catwalk/fireproof(src)
		return .|ATTACK_CHAIN_SUCCESS


/turf/simulated/floor/lava/screwdriver_act()
	return

/turf/simulated/floor/lava/welder_act()
	return

/turf/simulated/floor/lava/break_tile()
	return

/turf/simulated/floor/lava/burn_tile()
	return

/turf/simulated/floor/lava/lava_land_surface
	temperature = 300
	oxygen = 14
	nitrogen = 23
	planetary_atmos = TRUE
	baseturf = /turf/simulated/floor/chasm/straight_down/lava_land_surface
	/// Check for plasma river, subtype of lava, prevents simple fishing
	var/can_be_fished_on = TRUE


/turf/simulated/floor/lava/lava_land_surface/Initialize(mapload)
	. = ..()
	add_to_lazis_primary()
	if(can_be_fished_on)
		calculate_deep()

/turf/simulated/floor/lava/lava_land_surface/proc/add_to_lazis_primary()
	GLOB.lazis_primary_turfs |= src


/turf/simulated/floor/lava/lava_land_surface/Destroy()
	GLOB.lazis_primary_turfs -= src
	. = ..()


/turf/simulated/floor/lava/lava_land_surface/proc/calculate_deep()
	if(locate(/turf/simulated/floor/plating/asteroid/basalt) in range(3, src))
		deep_water = FALSE

/turf/simulated/floor/lava/lava_land_surface/proc/get_fish()
	if(deep_water)
		return GLOB.deep_fish
	else
		return GLOB.shore_fish

/turf/simulated/floor/lava/lava_land_surface/krill_act(atom/movable/AM)
	var/obj/item/reagent_containers/food/snacks/charred_krill/krill = AM //yourself
	krill.in_lava = TRUE
	krill.anchored = TRUE	//no closet kidnaping
	visible_message(span_warning("[capitalize(krill.declent_ru(NOMINATIVE))] медленно тон[pluralize_ru(krill.gender, "ет", "ут")] в лаве!"))
	sleep(5 SECONDS)
	qdel(krill)
	if(!can_be_fished_on)
		visible_message(span_warning("И ничего не происходит..."))
		return
	visible_message(span_warning("Неожиданно, из лавы выныривают две рыбы и разрывают [krill.declent_ru(ACCUSATIVE)] на части!"))
	var/list/fishable_list = get_fish()
	for(var/i in 1 to 2)
		var/fish = pick(fishable_list)
		new fish(src)

/turf/simulated/floor/lava/lava_land_surface/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		return .

	if(istype(I, /obj/item/reagent_containers/food/snacks/charred_krill))
		to_chat(user, span_notice("Вы осторожно кладёте креветку на поверхность лавы..."))
		if(do_after(user, 5 SECONDS, target = src))
			if(QDELETED(I))
				return .
			if(!can_be_fished_on)
				to_chat(user, span_warning("И ничего не происходит..."))
				return .
			to_chat(user, span_notice("Неожиданно, из лавы выныривают две рыбы и разрывают креветку на части!"))
			var/list/fishable_list = get_fish()
			for(var/i in 1 to 2)
				var/fish = pick(fishable_list)
				new fish(src)
			qdel(I)
			return .|ATTACK_CHAIN_SUCCESS

/turf/simulated/floor/lava/airless
	temperature = TCMB

/turf/simulated/floor/lava/lava_land_surface/plasma
	name = "liquid plasma"
	baseturf = /turf/simulated/floor/lava/lava_land_surface/plasma
	desc = "Текучая масса охлаждённой жидкой плазмы. Вам определённо не стоит в этом купаться."
	ru_names = list(
		NOMINATIVE = "жидкая плазма",
		GENITIVE = "жидкой плазмы",
		DATIVE = "жидкой плазме",
		ACCUSATIVE = "жидкую плазму",
		INSTRUMENTAL = "жидкой плазмой",
		PREPOSITIONAL = "жидкой плазме"
	)
	icon = 'icons/turf/floors/liquidplasma.dmi'
	base_icon_state = "liquidplasma"
	icon_state = "unsmooth"
	smooth = SMOOTH_BITMASK
	can_be_fished_on = FALSE // ~ Sin City's cold and empty, No one`s around to judge me ~
	light_range = 3
	light_power = 0.75
	light_color = LIGHT_COLOR_PINK
	lava_damage = 2
	/// How much fire and toxic damage we deal to human mobs stepping on us
	var/human_tox_fire_damage = 15


/turf/simulated/floor/lava/lava_land_surface/plasma/examine(mob/user)
	. = ..()
	. += span_info("Можно зачерпнуть <b>жидкую плазму</b> с помощью <b>ёмкости</b>.")


/turf/simulated/floor/lava/lava_land_surface/plasma/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.) || !I.is_open_container())
		return .

	. |= ATTACK_CHAIN_SUCCESS
	if(!I.reagents.add_reagent("plasma", 10))
		to_chat(user, span_warning("[capitalize(I.declent_ru(NOMINATIVE))] уже заполнен[genderize_ru(I.gender,"","а","о","ы")] до краёв."))
		return .
	to_chat(user, span_notice("Вы черпаете лаву из [declent_ru(GENITIVE)] используя [I.declent_ru(ACCUSATIVE)]."))


/turf/simulated/floor/lava/lava_land_surface/plasma/do_burn(atom/movable/burn_target)
	if(QDELETED(burn_target))
		return FALSE

	if(isobj(burn_target))
		var/obj/burn_obj = burn_target
		if(burn_obj.resistance_flags & ON_FIRE) // already on fire; skip it.
			return TRUE
		if(!(burn_obj.resistance_flags & FLAMMABLE))
			burn_obj.resistance_flags |= FLAMMABLE //Even fireproof things burn up in lava
		if(burn_obj.resistance_flags & FIRE_PROOF)
			burn_obj.resistance_flags &= ~FIRE_PROOF
		if(burn_obj.armor.getRating(FIRE) > 50) //obj with 100% fire armor still get slowly burned away.
			burn_obj.armor.setRating(fire_value = 50)
		burn_obj.fire_act(exposed_temperature = temperature_damage, exposed_volume = 1000)
		return TRUE

	if(isliving(burn_target))
		var/burn_damage = lava_damage
		var/tox_damage = 0
		var/mob/living/burn_living = burn_target
		burn_living.adjust_fire_stacks(lava_firestacks)
		burn_living.IgniteMob()
		burn_living.adjust_bodytemperature(-rand(50, 65)) //its cold, man
		if(ishuman(burn_living) && prob(65))
			var/mob/living/carbon/human/burn_human = burn_living
			var/datum/species/burn_species = burn_human.dna.species.name
			if(burn_species != SPECIES_PLASMAMAN && burn_species != SPECIES_MACNINEPERSON) //ignore plasmamen/robotic species.
				burn_damage += human_tox_fire_damage
				tox_damage += human_tox_fire_damage
		burn_living.apply_damages(burn = burn_damage, tox = tox_damage, spread_damage = TRUE)	//Cold mutagen is bad for you, more at 11.
		return TRUE

	return FALSE


// It's not the liquid itself. It's the atmos over it. Don't wanna spend resources on simulating over snow and lava.
/turf/simulated/floor/lava/lava_land_surface/plasma/cold
	oxygen = 22
	nitrogen = 82
	temperature = 180

/turf/simulated/floor/lava/mapping_lava
	name = "Adaptive lava / chasm / plasma"
	icon_state = "mappinglava"
	baseturf = /turf/simulated/floor/lava/mapping_lava
	temperature = 300
	oxygen = 14
	nitrogen = 23
	planetary_atmos = TRUE

/turf/simulated/floor/lava/mapping_lava/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD //Lateload is needed, otherwise atmos does not setup right on the turf roundstart, leading it to be vacume. This is bad.

/turf/simulated/floor/lava/mapping_lava/LateInitialize()
	. = ..()
	if(SSmapping.lavaland_theme?.primary_turf_type)
		ChangeTurf(SSmapping.lavaland_theme.primary_turf_type, after_flags = CHANGETURF_IGNORE_AIR)

/turf/simulated/floor/lava/lava_land_surface/lava_only //used to override reader.dm for lava only instead of adaptive type

/turf/simulated/floor/lava/lava_land_surface/lava_only/add_to_lazis_primary()
	return
