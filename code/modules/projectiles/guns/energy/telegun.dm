// Telegun for Tator RDs

/obj/item/gun/energy/telegun
	name = "Teleporter Gun"
	desc = "An extremely high-tech bluespace energy gun capable of teleporting targets to far off locations."
	ru_names = list(
		NOMINATIVE = "телепушка",
		GENITIVE = "телепушки",
		DATIVE = "телепушке",
		ACCUSATIVE = "телепушку",
		INSTRUMENTAL = "телепушкой",
		PREPOSITIONAL = "телепушке"
	)
	gender = FEMALE
	icon_state = "telegun"
	item_state = "telegun"
	origin_tech = "combat=6;materials=7;powerstorage=5;bluespace=5;syndicate=4"
	ammo_type = list(/obj/item/ammo_casing/energy/teleport)
	shaded_charge = TRUE
	var/teleport_target = null

/obj/item/gun/energy/telegun/Destroy()
	teleport_target = null
	return ..()

/obj/item/gun/energy/telegun/attack_self(mob/living/user as mob)
	var/list/L = list()
	var/list/areaindex = list()

	for(var/obj/item/radio/beacon/R in GLOB.beacons)
		var/turf/T = get_turf(R)
		if(!T)
			continue
		if(!is_teleport_allowed(T.z))
			continue
		if(R.syndicate == 1)
			continue
		var/tmpname = T.loc.name
		if(areaindex[tmpname])
			tmpname = "[tmpname] ([++areaindex[tmpname]])"
		else
			areaindex[tmpname] = 1
		L[tmpname] = R

	var/desc = input("Please select a location to lock in.", "Telegun Target Interface") in L
	teleport_target = L[desc]

/obj/item/gun/energy/telegun/newshot()
	var/obj/item/ammo_casing/energy/teleport/T = ammo_type[select]
	T.teleport_target = teleport_target
	..()
