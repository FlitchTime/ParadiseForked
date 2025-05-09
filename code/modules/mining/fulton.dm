GLOBAL_LIST_EMPTY(total_extraction_beacons)

/obj/item/extraction_pack
	name = "fulton extraction pack"
	desc = "A balloon that can be used to extract equipment or personnel to a Fulton Recovery Beacon. Anything not bolted down can be moved. Link the pack to a beacon by using the pack in hand."
	gender = MALE
	icon = 'icons/obj/fulton.dmi'
	icon_state = "extraction_pack"
	w_class = WEIGHT_CLASS_NORMAL
	var/obj/structure/extraction_point/beacon
	var/list/beacon_networks = list("station")
	var/uses_left = 3
	var/can_use_indoors
	var/safe_for_living_creatures = TRUE
	var/max_force_fulton = MOVE_FORCE_STRONG

/obj/item/extraction_pack/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It has [uses_left] use\s remaining.</span>"

/obj/item/extraction_pack/attack_self(mob/user)
	var/list/possible_beacons = list()
	for(var/B in GLOB.total_extraction_beacons)
		var/obj/structure/extraction_point/EP = B
		if(EP.beacon_network in beacon_networks)
			possible_beacons += EP

	if(!possible_beacons.len)
		balloon_alert(user, "маяки не найдены!")
		return

	else
		var/A

		A = tgui_input_list(user, "Select a beacon to connect to", "Balloon Extraction Pack", possible_beacons)

		if(!A)
			return
		beacon = A
		balloon_alert(user, "синхронизация завершена")

/obj/item/extraction_pack/MouseDrop(atom/over_object, src_location, over_location, src_control, over_control, params)
	if(!..())
		return FALSE
	if(!(loc == usr && loc.Adjacent(over_object)))
		return FALSE
	if(!ishuman(usr) || usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return FALSE
	over_object.add_fingerprint(usr)
	afterattack(over_object, usr, TRUE, params)
	return TRUE

/obj/item/extraction_pack/afterattack(atom/movable/A, mob/living/carbon/human/user, flag, params)
	. = ..()
	if(!beacon)
		balloon_alert(user, "синхронизируйте с маяком!")
		return
	if(!can_use_indoors)
		var/area/area = get_area(A)
		if(!area.outdoors)
			balloon_alert(user, "используйте снаружи!")
			return
	if(!flag)
		return
	if(!istype(A))
		return
	else
		if(!safe_for_living_creatures && check_for_living_mobs(A))
			to_chat(user, "<span class='warning'>[src] is not safe for use with living creatures, they wouldn't survive the trip back!</span>")
			return
		if(!isturf(A.loc)) // no extracting stuff inside other stuff
			return
		if(A.anchored || (A.move_resist > max_force_fulton))
			return
		balloon_alert(user, "подготовка эвакуации...")
		if(do_after(user, 5 SECONDS, A))
			balloon_alert(user, "эвакуация завершена")
			if(loc == user && istype(user.back, /obj/item/storage/backpack))
				var/obj/item/storage/backpack/B = user.back
				if(B.can_be_inserted(src, stop_messages = TRUE))
					B.handle_item_insertion(src)
			uses_left--
			if(uses_left <= 0)
				user.drop_from_active_hand(src)
				forceMove(A)
			var/mutable_appearance/balloon
			var/mutable_appearance/balloon2
			var/mutable_appearance/balloon3
			if(isliving(A))
				var/mob/living/M = A
				M.Weaken(32 SECONDS) // Keep them from moving during the duration of the extraction
				M.buckled?.unbuckle_mob(force = TRUE) // Unbuckle them to prevent anchoring problems
			else
				A.set_anchored(TRUE)
				ADD_TRAIT(A, TRAIT_UNDENSE, FULTON_TRAIT)
			var/obj/effect/extraction_holder/holder_obj = new(A.loc)
			holder_obj.appearance = A.appearance
			A.forceMove(holder_obj)
			balloon2 = mutable_appearance('icons/obj/fulton_balloon.dmi', "fulton_expand")
			balloon2.pixel_y = 10
			balloon2.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
			holder_obj.add_overlay(balloon2)
			sleep(4)
			balloon = mutable_appearance('icons/obj/fulton_balloon.dmi', "fulton_balloon")
			balloon.pixel_y = 10
			balloon.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
			holder_obj.cut_overlay(balloon2)
			holder_obj.add_overlay(balloon)
			playsound(holder_obj.loc, 'sound/items/fultext_deploy.ogg', 50, 1, -3)
			animate(holder_obj, pixel_z = 10, time = 20)
			sleep(20)
			animate(holder_obj, pixel_z = 15, time = 10)
			sleep(10)
			animate(holder_obj, pixel_z = 10, time = 10)
			sleep(10)
			animate(holder_obj, pixel_z = 15, time = 10)
			sleep(10)
			animate(holder_obj, pixel_z = 10, time = 10)
			sleep(10)
			playsound(holder_obj.loc, 'sound/items/fultext_launch.ogg', 50, 1, -3)
			animate(holder_obj, pixel_z = 1000, time = 30)
			if(ishuman(A))
				var/mob/living/carbon/human/L = A
				L.SetParalysis(0)
				L.SetDrowsy(0)
				L.SetSleeping(0)
			sleep(30)
			var/list/flooring_near_beacon = list()
			for(var/turf/floor in orange(1, beacon))
				if(floor.density)
					continue
				flooring_near_beacon += floor
			if(!length(flooring_near_beacon))
				to_chat(user, "<span class='notice'>It is impossible to find a connected beacon. Your fulton pack brings you back.</span>")
				flooring_near_beacon = get_turf(user)
			holder_obj.forceMove(pick(flooring_near_beacon))
			animate(holder_obj, pixel_z = 10, time = 50)
			sleep(50)
			animate(holder_obj, pixel_z = 15, time = 10)
			sleep(10)
			animate(holder_obj, pixel_z = 10, time = 10)
			sleep(10)
			balloon3 = mutable_appearance('icons/obj/fulton_balloon.dmi', "fulton_retract")
			balloon3.pixel_y = 10
			balloon3.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
			holder_obj.cut_overlay(balloon)
			holder_obj.add_overlay(balloon3)
			sleep(4)
			holder_obj.cut_overlay(balloon3)
			A.set_anchored(FALSE) // An item has to be unanchored to be extracted in the first place.
			REMOVE_TRAIT(A, TRAIT_UNDENSE, FULTON_TRAIT)
			animate(holder_obj, pixel_z = 0, time = 5)
			sleep(5)
			A.forceMove(holder_obj.loc)
			qdel(holder_obj)
			if(uses_left <= 0)
				qdel(src)


/obj/item/fulton_core
	name = "extraction beacon signaller"
	desc = "Emits a signal which fulton recovery devices can lock onto. Activate in hand to create a beacon."
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "subspace_amplifier"

/obj/item/fulton_core/attack_self(mob/user)
	if(do_after(user, 1.5 SECONDS, user) && !QDELETED(src))
		var/obj/structure/extraction_point/point = new(get_turf(user))
		point.add_fingerprint(user)
		qdel(src)

/obj/structure/extraction_point
	name = "fulton recovery beacon"
	desc = "A beacon for the fulton recovery system. Activate a pack in your hand to link it to a beacon."
	icon = 'icons/obj/fulton.dmi'
	icon_state = "extraction_point"
	anchored = TRUE
	density = FALSE
	var/beacon_network = "station"

/obj/structure/extraction_point/Initialize(mapload)
	. = ..()
	name += " ([rand(100,999)]) ([get_location_name(src)])"
	GLOB.total_extraction_beacons += src

/obj/structure/extraction_point/Destroy()
	GLOB.total_extraction_beacons -= src
	return ..()

/obj/effect/extraction_holder
	name = "extraction holder"
	desc = "you shouldnt see this"
	var/atom/movable/stored_obj

/obj/item/extraction_pack/proc/check_for_living_mobs(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		if(L.stat != DEAD)
			return TRUE
	for(var/thing in A.GetAllContents())
		if(isliving(A))
			var/mob/living/L = A
			if(L.stat != DEAD)
				return TRUE
	return FALSE

/obj/effect/extraction_holder/singularity_act()
	return

/obj/effect/extraction_holder/singularity_pull()
	return
