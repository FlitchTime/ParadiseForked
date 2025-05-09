/obj/item/clothing/head/soft
	name = "cargo cap"
	desc = "It's a baseball hat in a tasteless yellow colour."
	icon_state = "cargosoft"
	item_state = "helmet"
	item_color = "cargo"
	dying_key = DYE_REGISTRY_SOFTCAP
	var/flipped = FALSE
	actions_types = list(/datum/action/item_action/flip_cap)
	dog_fashion = /datum/dog_fashion/head/cargo_tech
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/head.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/head.dmi'
		)


/obj/item/clothing/head/soft/update_icon_state()
	icon_state = flipped ? "[item_color]soft_flipped" : "[item_color]soft"
	update_equipped_item(update_speedmods = FALSE)


/obj/item/clothing/head/soft/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	if(flipped)
		flipped = FALSE
		update_icon(UPDATE_ICON_STATE)


/obj/item/clothing/head/soft/attack_self(mob/user)
	flip(user)


/obj/item/clothing/head/soft/proc/flip(mob/user)
	flipped = !flipped
	update_icon(UPDATE_ICON_STATE)
	if(flipped)
		to_chat(user, span_notice("You flip the hat backwards."))
	else
		to_chat(user, span_notice("You flip the hat back in normal position."))

/obj/item/clothing/head/soft/red
	name = "red cap"
	desc = "It's a baseball hat in a tasteless red colour."
	icon_state = "redsoft"
	item_color = "red"
	dog_fashion = null

/obj/item/clothing/head/soft/blue
	name = "blue cap"
	desc = "It's a baseball hat in a tasteless blue colour."
	icon_state = "bluesoft"
	item_color = "blue"
	dog_fashion = null

/obj/item/clothing/head/soft/green
	name = "green cap"
	desc = "It's a baseball hat in a tasteless green colour."
	icon_state = "greensoft"
	item_color = "green"
	dog_fashion = null

/obj/item/clothing/head/soft/yellow
	name = "yellow cap"
	desc = "It's a baseball hat in a tasteless yellow colour."
	icon_state = "yellowsoft"
	item_color = "yellow"
	dog_fashion = null

/obj/item/clothing/head/soft/grey
	name = "grey cap"
	desc = "It's a baseball hat in a tasteful grey colour."
	icon_state = "greysoft"
	item_color = "grey"
	dog_fashion = null

/obj/item/clothing/head/soft/orange
	name = "orange cap"
	desc = "It's a baseball hat in a tasteless orange colour."
	icon_state = "orangesoft"
	item_color = "orange"

/obj/item/clothing/head/soft/mime
	name = "white cap"
	desc = "It's a baseball hat in a tasteless white colour."
	icon_state = "mimesoft"
	item_color = "mime"
	dog_fashion = null

/obj/item/clothing/head/soft/purple
	name = "purple cap"
	desc = "It's a baseball hat in a tasteless purple colour."
	icon_state = "purplesoft"
	item_color = "purple"
	dog_fashion = null

/obj/item/clothing/head/soft/black
	name = "black cap"
	desc = "It's a baseball hat in a tasteless black colour."
	icon_state = "blacksoft"
	item_color = "black"
	dog_fashion = null

/obj/item/clothing/head/soft/rainbow
	name = "rainbow cap"
	desc = "It's a baseball hat in a bright rainbow of colors."
	icon_state = "rainbowsoft"
	item_color = "rainbow"
	dog_fashion = null

/obj/item/clothing/head/soft/paramedic
	name = "paramedic`s cap"
	desc = "A soft cap worn by a paramedic."
	icon_state = "paramedicsoft"
	item_state = "paramedicsoft"
	item_color = "paramedic"
	dog_fashion = null

/obj/item/clothing/head/soft/brigphys
	name = "brigphysic`s cap"
	desc = "A soft cap worn by a brig physician."
	icon_state = "brigphyssoft"
	item_state = "brigphyssoft"
	item_color = "brigphys"
	dog_fashion = null

/obj/item/clothing/head/soft/sec
	name = "security cap"
	desc = "It's baseball hat in tasteful red colour."
	icon_state = "secsoft"
	item_color = "sec"
	armor = list("melee" = 35, "bullet" = 30, "laser" = 30, "energy" = 10, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 20, "acid" = 50)
	strip_delay = 60
	dog_fashion = null

/obj/item/clothing/head/soft/sec/corp
	name = "corporate security cap"
	desc = "It's a baseball hat in corporate colours."
	icon_state = "corpsoft"
	item_color = "corp"

/obj/item/clothing/head/soft/solgov
	name = "Trans-Solar Federation marine cap"
	desc = "A soft cap worn by marines of the Sol Federation."
	icon_state = "solgovsoft"
	item_color = "solgov"
	dog_fashion = null

/obj/item/clothing/head/soft/solgov/elite
	name = "\improper Trans-Solar Federation Specops marine cap"
	desc = "A cap worn by marines of the Trans-Solar Federation Specops division."
	armor = list("melee" = 40, "bullet" = 30, "laser" = 30, "energy" = 10, "bomb" = 25, "bio" = 10, "rad" = 0, "fire" = 50, "acid" = 60)
	icon_state = "solgovelitesoft_flipped"
	item_color = "solgovelite"

/obj/item/clothing/head/soft/solgov/command
	name = "Trans-Solar Federation Lieutenant's cap"
	desc = "A soft cap worn by marines of the Sol Federation. The insignia signifies the wearer bears the rank of a Lieutenant."
	armor= list("melee" = 40, "bullet" = 30, "laser" = 30, "energy" = 10, "bomb" = 25, "bio" = 10, "rad" = 0, "fire" = 50, "acid" = 60)
	icon_state = "solgovcsoft"
	item_color = "solgovc"
	dog_fashion = null

/obj/item/clothing/head/soft/solgov/command/elite
	name = "\improper Trans-Solar Federation Specops Lieutenant's cap"
	desc = "A cap worn by marines of the Trans-Solar Federation Specops division. The insignia signifies the wearer bears the rank of a Lieutenant."
	icon_state = "solgovcelitesoft"
	item_color = "solgovcelite"
