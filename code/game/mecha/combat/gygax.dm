/obj/mecha/combat/gygax
	desc = "A lightweight, security exosuit. Popular among private and corporate security."
	name = "Gygax"
	icon_state = "gygax"
	initial_icon = "gygax"
	step_in = 3
	dir_in = 1 //Facing North.
	max_integrity = 250
	deflect_chance = 5
	armor = list(melee = 25, bullet = 20, laser = 30, energy = 15, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 100)
	max_temperature = 25000
	infra_luminosity = 6
	maint_access = TRUE
	leg_overload_coeff = 2
	wreckage = /obj/structure/mecha_wreckage/gygax
	internal_damage_threshold = 35
	max_equip = 3
	maxsize = 2
	step_energy_drain = 3
	normal_step_energy_drain = 3

	mech_type = MECH_TYPE_GYGAX

/obj/mecha/combat/gygax/GrantActions(mob/living/user, human_occupant = 0)
	..()
	overload_action.Grant(user, src)

/obj/mecha/combat/gygax/RemoveActions(mob/living/user, human_occupant = 0)
	..()
	overload_action.Remove(user)

/obj/mecha/combat/gygax/loaded/New()
	..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/taser
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang
	ME.attach(src)

/obj/mecha/combat/gygax/ert
	desc = "A lightweight exosuit, painted in a blue scheme. This model appears to have some modifications for ERT."
	name = "Nanotrasen Special Gygax"
	icon_state = "ntgygax"
	initial_icon = "ntgygax"
	max_integrity = 350
	deflect_chance = 10
	armor = list(melee = 35, bullet = 30, laser = 35, energy = 30, bomb = 20, bio = 0, rad = 20, fire = 100, acid = 100)
	max_temperature = 35000
	leg_overload_coeff = 100
	operation_req_access = list(ACCESS_CENT_SPECOPS)
	maint_access = FALSE
	wreckage = /obj/structure/mecha_wreckage/gygax/ert
	max_equip = 5
	maxsize = 2
	starting_voice = /obj/item/mecha_modkit/voice/nanotrasen
	destruction_sleep_duration = 1

/obj/mecha/combat/gygax/ert/loaded/New()
	..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/taser
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser
	ME.attach(src)

/obj/mecha/combat/gygax/ert/add_cell()
	cell = new /obj/item/stock_parts/cell/bluespace(src)

/obj/mecha/combat/gygax/dark
	desc = "A lightweight exosuit, painted in a dark scheme. This model appears to have some modifications."
	name = "Dark Gygax"
	icon_state = "darkgygax"
	initial_icon = "darkgygax"
	max_integrity = 300
	deflect_chance = 20
	armor = list(melee = 40, bullet = 40, laser = 50, energy = 35, bomb = 20, bio = 0, rad = 20, fire = 100, acid = 100)
	max_temperature = 35000
	leg_overload_coeff = 2
	operation_req_access = list(ACCESS_SYNDICATE)
	maint_access = FALSE
	wreckage = /obj/structure/mecha_wreckage/gygax/dark
	max_equip = 4
	maxsize = 2
	starting_voice = /obj/item/mecha_modkit/voice/syndicate
	destruction_sleep_duration = 2 SECONDS
	strafe_allowed = TRUE

	mech_type = MECH_TYPE_DARK_GYGAX

/obj/mecha/combat/gygax/dark/GrantActions(mob/living/user, human_occupant = 0)
	. = ..()
	thrusters_action.Grant(user, src)

/obj/mecha/combat/gygax/dark/RemoveActions(mob/living/user, human_occupant = 0)
	. = ..()
	thrusters_action.Remove(user)

/obj/mecha/combat/gygax/dark/loaded/New()
	..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot/syndi
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/repair_droid
	ME.attach(src)

/obj/mecha/combat/gygax/dark/add_cell()
	cell = new /obj/item/stock_parts/cell/bluespace(src)
