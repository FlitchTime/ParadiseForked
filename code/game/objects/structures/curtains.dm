#define SHOWER_OPEN_LAYER OBJ_LAYER + 0.4
#define SHOWER_CLOSED_LAYER MOB_LAYER + 0.1

/obj/structure/curtain
	icon = 'icons/obj/curtain.dmi'
	name = "curtain"
	icon_state = "closed"
	layer = SHOWER_CLOSED_LAYER
	opacity = TRUE
	density = FALSE


/obj/structure/curtain/open
	icon_state = "open"
	layer = SHOWER_OPEN_LAYER
	opacity = FALSE


/obj/structure/curtain/attack_hand(mob/user)
	playsound(get_turf(loc), "rustle", 15, 1, -5)
	toggle()
	..()

/obj/structure/curtain/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src.loc, 'sound/weapons/slash.ogg', 80, TRUE)
			else
				playsound(loc, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 80, TRUE)


/obj/structure/curtain/proc/toggle()
	set_opacity(!opacity)
	layer = opacity ? SHOWER_CLOSED_LAYER : SHOWER_OPEN_LAYER
	update_icon(UPDATE_ICON_STATE)


/obj/structure/curtain/update_icon_state()
	icon_state = opacity ? "closed" : "open"


/obj/structure/curtain/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/toy/crayon))
		add_fingerprint(user)
		var/new_color = tgui_input_color(user, "Choose Color")
		if(isnull(new_color))
			return ATTACK_CHAIN_PROCEED
		color = new_color
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/structure/curtain/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_start_check(src, user, 0))
		return
	if(anchored)
		user.visible_message("<span class='warning'>[user] unscrews [src] from the floor.</span>", "<span class='notice'>You start to unscrew [src] from the floor...</span>", "You hear rustling noises.")
		if(I.use_tool(src, user, 50, volume = I.tool_volume) && anchored)
			set_anchored(FALSE)
			to_chat(user, "<span class='notice'>You unscrew [src] from the floor.</span>")
	else
		user.visible_message("<span class='warning'>[user] screws [src] to the floor.</span>", "<span class='notice'>You start to screw [src] to the floor...</span>", "You hear rustling noises.")
		if(I.use_tool(src, user, 50, volume = I.tool_volume) && !anchored)
			set_anchored(TRUE)
			to_chat(user, "<span class='notice'>You screw [src] to the floor.</span>")



/obj/structure/curtain/wirecutter_act(mob/user, obj/item/I)
	if(anchored)
		return
	. = TRUE
	if(!I.tool_start_check(src, user, 0))
		return
	WIRECUTTER_ATTEMPT_DISMANTLE_MESSAGE
	if(I.use_tool(src, user, 50, volume = I.tool_volume))
		WIRECUTTER_DISMANTLE_SUCCESS_MESSAGE
		deconstruct()

/obj/structure/curtain/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/cloth(loc, 2)
	new /obj/item/stack/sheet/plastic(loc, 1)
	new /obj/item/stack/rods(loc, 1)
	qdel(src)

/obj/structure/curtain/black
	name = "black curtain"
	color = "#222222"

/obj/structure/curtain/medical
	name = "plastic curtain"
	color = "#B8F5E3"
	alpha = 200

/obj/structure/curtain/open/shower
	name = "shower curtain"
	color = "#ACD1E9"
	alpha = 200

/obj/structure/curtain/open/shower/engineering
	color = "#FFA500"

/obj/structure/curtain/open/shower/security
	color = "#AA0000"

/obj/structure/curtain/open/shower/centcom
	color = "#000066"

#undef SHOWER_OPEN_LAYER
#undef SHOWER_CLOSED_LAYER
