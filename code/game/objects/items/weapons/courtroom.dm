// Contains:
// Gavel Hammer
// Gavel Block

/obj/item/gavelhammer
	name = "gavel hammer"
	desc = "Order, order! No bombs in my courthouse."
	icon = 'icons/obj/items.dmi'
	icon_state = "gavelhammer"
	force = 5.0
	throwforce = 6.0
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("ударил", "засудил", "огрел")
	resistance_flags = FLAMMABLE

/obj/item/gavelhammer/suicide_act(mob/user)
	user.visible_message("<span class='warning'>[user] has sentenced [user.p_them()]self to death with the [src.name]! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	playsound(loc, 'sound/items/gavel.ogg', 50, 1, -1)
	return BRUTELOSS

/obj/item/gavelblock
	name = "gavel block"
	desc = "Smack it with a gavel hammer when the assistants get rowdy."
	icon = 'icons/obj/items.dmi'
	icon_state = "gavelblock"
	force = 2.0
	throwforce = 2.0
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	COOLDOWN_DECLARE(next_gavel_hit)


/obj/item/gavelblock/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/gavelhammer) || !COOLDOWN_FINISHED(src, next_gavel_hit))
		return ..()
	COOLDOWN_START(src, next_gavel_hit, 5 SECONDS)
	playsound(loc, 'sound/items/gavel.ogg', 100, TRUE)
	user.visible_message(span_warning("[user] strikes [src] with [I]!"))
	return ATTACK_CHAIN_PROCEED

