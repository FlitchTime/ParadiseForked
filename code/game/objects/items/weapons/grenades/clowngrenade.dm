/obj/item/grenade/clown_grenade
	name = "Banana Grenade"
	desc = "Банановые кожурки торговой марки \"ХОНК!\" в специальном аппликаторе, который позволяет быстро наносить их на большие поверхности."
	ru_names = list(
		NOMINATIVE = "банановая граната",
		GENITIVE = "банановой гранаты",
		DATIVE = "банановой гранате",
		ACCUSATIVE = "банановую гранату",
		INSTRUMENTAL = "банановой гранатой",
		PREPOSITIONAL = "банановой гранате"
	)
	icon_state = "banana"
	item_state = "flashbang"
	w_class = WEIGHT_CLASS_SMALL
	force = 2.0
	var/stage = 0
	var/state = 0
	var/path = 0
	var/affected_area = 2

/obj/item/grenade/clown_grenade/prime()
	. = ..()
	playsound(src.loc, 'sound/items/bikehorn.ogg', 25, -3)
	var/i = 0
	var/number = 0
	for(var/direction in GLOB.alldirs)
		for(i = 0; i < 2; i++)
			number++
			var/obj/item/grown/bananapeel/traitorpeel/peel = new /obj/item/grown/bananapeel/traitorpeel(get_turf(src.loc))
			var/a = 1
			if(number & 2)
				for(a = 1; a <= 2; a++)
					step(peel,direction)
			else
				step(peel,direction)
	new /obj/item/grown/bananapeel/traitorpeel(get_turf(src.loc))
	qdel(src)
	return

/obj/item/grown/bananapeel/traitorpeel/New(newloc, obj/item/seeds/new_seed)
	. = ..()
	// The reason this AddComponent is here and not in ComponentInitialize() is because if it's put there, it will be ran before the parent New proc for /grown types.
	// And then be overriden by the generic component placed onto it by the `/datum/plant_gene/trait/slip`.
	AddComponent(/datum/component/slippery, 4 SECONDS, lube_flags = (SLIDE|SLIP_WHEN_LYING), on_slip_callback = CALLBACK(src, PROC_REF(on_slip)))

/obj/item/grown/bananapeel/traitorpeel/proc/on_slip(mob/living/carbon/target)
	to_chat(target, span_warning("Ваши ноги словно охвачены пламенем!"))
	target.take_overall_damage(0, rand(2,8))
	target.take_organ_damage(2)

/obj/item/grown/bananapeel/traitorpeel/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/burned = rand(1,3)
	if(isliving(hit_atom))
		var/mob/living/M = hit_atom
		M.take_organ_damage(0, burned)
	return ..()
