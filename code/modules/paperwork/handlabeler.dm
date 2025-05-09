/obj/item/hand_labeler
	name = "hand labeler"
	desc = "A combined label printer, applicator, and remover, all in a single portable device. Designed to be easy to operate and use."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "labeler0"
	item_state = "labeler0"
	var/label = null
	var/labels_left = 30
	var/mode = FALSE

/obj/item/hand_labeler/afterattack(atom/A, mob/user, proximity, params)
	if(!proximity)
		return
	if(!mode)	//if it's off, give up.
		return

	if(!labels_left)
		to_chat(user, "<span class='warning'>No labels left!</span>")
		return
	if(!label || !length(label))
		to_chat(user, "<span class='warning'>No text set!</span>")
		return
	if(length(A.name) + length(label) > 64)
		to_chat(user, "<span class='warning'>Label too big!</span>")
		return
	if(ismob(A))
		to_chat(user, "<span class='warning'>You can't label creatures!</span>") // use a collar
		return

	user.visible_message("<span class='notice'>[user] labels [A] as [label].</span>", \
						 "<span class='notice'>You label [A] as [label].</span>")
	A.AddComponent(/datum/component/label, label)
	playsound(A, 'sound/items/handling/component_pickup.ogg', 20, TRUE)
	labels_left--


/obj/item/hand_labeler/update_icon_state()
	icon_state = "labeler[mode]"


/obj/item/hand_labeler/attack_self(mob/user)
	mode = !mode
	update_icon(UPDATE_ICON_STATE)
	if(mode)
		to_chat(user, "<span class='notice'>You turn on \the [src].</span>")
		//Now let them chose the text.
		var/str = reject_bad_text(tgui_input_text(user,"Label text?", "Set label"))
		if(!str || !length(str))
			to_chat(user, "<span class='notice'>Invalid text.</span>")
			return
		label = str
		to_chat(user, "<span class='notice'>You set the text to '[str]'.</span>")
	else
		to_chat(user, "<span class='notice'>You turn off \the [src].</span>")


/obj/item/hand_labeler/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/hand_labeler_refill))
		add_fingerprint(user)
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		to_chat(user, span_notice("You have refilled [src]."))
		labels_left = initial(labels_left)	//Yes, it's capped at its initial value
		qdel(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/hand_labeler_refill
	name = "hand labeler paper roll"
	icon = 'icons/obj/bureaucracy.dmi'
	desc = "A roll of paper. Use it on a hand labeler to refill it."
	icon_state = "labeler_refill"
	item_state = "labeler_refill"
	w_class = WEIGHT_CLASS_TINY
