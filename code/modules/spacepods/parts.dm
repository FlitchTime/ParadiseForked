/obj/item/pod_parts
	parent_type = /obj/item/mecha_parts
	icon = 'icons/goonstation/pods/pod_parts.dmi'

/obj/item/pod_parts/core
	name="Space Pod Core"
	icon_state = "core"
	flags = CONDUCT
	origin_tech = "programming=2;materials=2;biotech=2;engineering=2"

/obj/item/pod_parts/pod_frame
	name = "Space Pod Frame"
	icon_state = ""
	flags = CONDUCT
	density = FALSE
	anchored = FALSE
	var/link_to = null
	var/link_angle = 0

/obj/item/pod_parts/pod_frame/proc/find_square()
	/*
	each part, in essence, stores the relative position of another part
	you can find where this part should be by looking at the current direction of the current part and applying the link_angle
	the link_angle is the angle between the part's direction and its following part, which is the current part's link_to
	the code works by going in a loop - each part is capable of starting a loop by checking for the part after it, and that part checking, and so on
	this 4-part loop, starting from any part of the frame, can determine if all the parts are properly in place and aligned
	it also checks that each part is unique, and that all the parts are there for the spacepod itself
	*/
	var/neededparts = list(/obj/item/pod_parts/pod_frame/aft_port, /obj/item/pod_parts/pod_frame/aft_starboard, /obj/item/pod_parts/pod_frame/fore_port, /obj/item/pod_parts/pod_frame/fore_starboard)
	var/turf/T
	var/obj/item/pod_parts/pod_frame/linked
	var/obj/item/pod_parts/pod_frame/pointer
	var/list/connectedparts =  list()
	neededparts -= src
	//log_admin("Starting with [src]")
	linked = src
	for(var/i = 1; i <= 4; i++)
		T = get_turf(get_step(linked, turn(linked.dir, -linked.link_angle))) //get the next place that we want to look at
		if(locate(linked.link_to) in T)
			pointer = locate(linked.link_to) in T
			//log_admin("Looking at [pointer.type]")
		if(istype(pointer, linked.link_to) && pointer.dir == linked.dir && pointer.anchored)
			if(!(pointer in connectedparts))
				connectedparts += pointer
			linked = pointer
			pointer = null
	if(connectedparts.len < 4)
		return 0
	for(var/i = 1; i <=4; i++)
		var/obj/item/pod_parts/pod_frame/F = connectedparts[i]
		if(F.type in neededparts) //if one of the items can be founded in neededparts
			neededparts -= F.type
			log_admin("Found [F.type]")
		else //because neededparts has 4 distinct items, this must be called if theyre not all in place and wrenched
			return 0
	return connectedparts


/obj/item/pod_parts/pod_frame/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/rods))
		add_fingerprint(user)
		var/obj/item/stack/rods/rods = I
		var/list/linkedparts = find_square()
		if(!linkedparts)
			to_chat(user, span_warning("You cannot assemble a pod frame because you do not have the necessary assembly."))
			return ATTACK_CHAIN_PROCEED
		var/cached_sound = rods.usesound
		if(!rods.use(10))
			to_chat(user, span_warning("You need at least ten rods to strut the frame."))
			return ATTACK_CHAIN_PROCEED
		var/obj/structure/spacepod_frame/new_pod = new(loc)
		new_pod.setDir(dir)
		transfer_fingerprints_to(new_pod)
		new_pod.add_fingerprint(user)
		to_chat(user, span_notice("You have strutted the pod frame together."))
		for(var/obj/item/pod_parts/pod_frame/frame in linkedparts)
			//if the part links north during construction, as the bottom left part always does
			if(turn(frame.dir, -frame.link_angle) == NORTH)
				//log_admin("Repositioning")
				new_pod.forceMove(frame.loc)
			qdel(frame)
		playsound(new_pod.loc, cached_sound, 50, TRUE)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/item/pod_parts/pod_frame/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	set_anchored(!anchored)
	set_density(anchored)
	to_chat(user, span_notice("You have [anchored ? "secured [src] in place" : "removed the securing bolts"]."))


/obj/item/pod_parts/pod_frame/examine(mob/user)
	. = ..()
	. += span_info("<b>Alt-Click</b> to rotate it.")


/obj/item/pod_parts/pod_frame/verb/rotate()
	set name = "Rotate Frame"
	set category = "Object"
	set src in oview(1)

	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return FALSE

	if(anchored)
		to_chat(usr, "\The [src] is securely bolted!")
		return FALSE

	dir = turn(dir, -90)
	return TRUE


/obj/item/pod_parts/pod_frame/click_alt(mob/user)
	rotate()
	return CLICK_ACTION_SUCCESS


/obj/item/pod_parts/pod_frame/attack_hand()
	return


/obj/item/pod_parts/pod_frame/fore_port
	name = "fore port pod frame"
	icon_state = "pod_fp"
	desc = "A space pod frame component. This is the fore port component."
	link_to = /obj/item/pod_parts/pod_frame/fore_starboard
	link_angle = 90

/obj/item/pod_parts/pod_frame/fore_starboard
	name = "fore starboard pod frame"
	icon_state = "pod_fs"
	desc = "A space pod frame component. This is the fore starboard component."
	link_to = /obj/item/pod_parts/pod_frame/aft_starboard
	link_angle = 180

/obj/item/pod_parts/pod_frame/aft_port
	name = "aft port pod frame"
	icon_state = "pod_ap"
	desc = "A space pod frame component. This is the aft port component."
	link_to = /obj/item/pod_parts/pod_frame/fore_port
	link_angle = 0

/obj/item/pod_parts/pod_frame/aft_starboard
	name = "aft starboard pod frame"
	icon_state = "pod_as"
	desc = "A space pod frame component. This is the aft starboard component."
	link_to = /obj/item/pod_parts/pod_frame/aft_port
	link_angle = 270

/obj/item/pod_parts/armor
	name = "civilian pod armor"
	icon = 'icons/goonstation/pods/pod_parts.dmi'
	icon_state = "pod_armor_civ"
	desc = "Spacepod armor. This is the civilian version. It looks rather flimsy."
