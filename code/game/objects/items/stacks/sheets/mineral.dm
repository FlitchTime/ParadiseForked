/*
Mineral Sheets
	Contains:
		- Sandstone
		- Diamond
		- Uranium
		- Plasma
		- Gold
		- Silver
		- Bananium
		- Tranqillite
		- Enriched Uranium
		- Platinum
		- Alien Alloy
		- Adamantine
*/

GLOBAL_LIST_INIT(sandstone_recipes, list ( \
	new/datum/stack_recipe("pile of dirt", /obj/machinery/hydroponics/soil, 3, time = 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("sandstone door", /obj/structure/mineral_door/sandstone, 10, time = 4 SECONDS, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe("Assistant Statue", /obj/structure/statue/sandstone/assistant, 5, time = 4 SECONDS, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe("Sandstone Plate", /obj/structure/bed/sandstone, 15, time = 4 SECONDS, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe("Breakdown into sand", /obj/item/stack/ore/glass, 1, one_per_turf = 0, on_floor = 1), \
	new/datum/stack_recipe("tribal oven", /obj/machinery/kitchen_machine/tribal_oven, 20, time = 4 SECONDS, one_per_turf = 1, on_floor = 1), \
	))

GLOBAL_LIST_INIT(silver_recipes, list ( \
	new/datum/stack_recipe("silver door", /obj/structure/mineral_door/silver, 10, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe("silver tile", /obj/item/stack/tile/mineral/silver, 1, 4, 20), \
	null, \
	new/datum/stack_recipe("Janitor Statue", /obj/structure/statue/silver/janitor, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Sec Officer Statue", /obj/structure/statue/silver/sec, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Sec Borg Statue", /obj/structure/statue/silver/secborg, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Med Doctor Statue", /obj/structure/statue/silver/md, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Med Borg Statue", /obj/structure/statue/silver/medborg, 5, one_per_turf = 1, on_floor = 1), \
	))

GLOBAL_LIST_INIT(diamond_recipes, list ( \
	new/datum/stack_recipe("diamond door", /obj/structure/mineral_door/transparent/diamond, 10, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe("diamond tile", /obj/item/stack/tile/mineral/diamond, 1, 4, 20),  \
	null, \
	new/datum/stack_recipe("Captain Statue", /obj/structure/statue/diamond/captain, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("AI Hologram Statue", /obj/structure/statue/diamond/ai1, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("AI Core Statue", /obj/structure/statue/diamond/ai2, 5, one_per_turf = 1, on_floor = 1), \
	))

GLOBAL_LIST_INIT(uranium_recipes, list ( \
	new/datum/stack_recipe("uranium door", /obj/structure/mineral_door/uranium, 10, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe("uranium tile", /obj/item/stack/tile/mineral/uranium, 1, 4, 20), \
	null, \
	new/datum/stack_recipe("Nuke Statue", /obj/structure/statue/uranium/nuke, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Engineer Statue", /obj/structure/statue/uranium/eng, 5, one_per_turf = 1, on_floor = 1), \
	))

GLOBAL_LIST_INIT(gold_recipes, list ( \
	new/datum/stack_recipe("golden door", /obj/structure/mineral_door/gold, 10, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe("gold tile", /obj/item/stack/tile/mineral/gold, 1, 4, 20), \
	null, \
	new/datum/stack_recipe("HoS Statue", /obj/structure/statue/gold/hos, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("HoP Statue", /obj/structure/statue/gold/hop, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("CE Statue", /obj/structure/statue/gold/ce, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("RD Statue", /obj/structure/statue/gold/rd, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("CMO Statue", /obj/structure/statue/gold/cmo, 5, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe("Simple Crown", /obj/item/clothing/head/crown, 5), \
	))

GLOBAL_LIST_INIT(plasma_recipes, list ( \
	new/datum/stack_recipe/dangerous("plasma door", /obj/structure/mineral_door/transparent/plasma, 10, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe/dangerous("plasma tile", /obj/item/stack/tile/mineral/plasma, 1, 4, 20), \
	null, \
	new/datum/stack_recipe/dangerous("Scientist Statue", /obj/structure/statue/plasma/scientist, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe/dangerous("Xenomorph Statue", /obj/structure/statue/plasma/xeno, 5, one_per_turf = 1, on_floor = 1), \
	))

GLOBAL_LIST_INIT(bananium_recipes, list ( \
	new/datum/stack_recipe("bananium tile", /obj/item/stack/tile/mineral/bananium, 1, 4, 20), \
	null, \
	new/datum/stack_recipe("Clown Statue", /obj/structure/statue/bananium/clown, 5, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe("bananium computer frame", /obj/structure/computerframe/HONKputer, 20, time = 25, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("bananium grenade casing", /obj/item/grenade/bananade/casing, 4, on_floor = 1), \
	))

GLOBAL_LIST_INIT(tranquillite_recipes, list ( \
	new/datum/stack_recipe("invisible wall", /obj/structure/barricade/mime, 5, one_per_turf = 1, on_floor = 1, time = 50), \
	null, \
	new/datum/stack_recipe("silent tile", /obj/item/stack/tile/mineral/tranquillite, 1, 4, 20), \
	null, \
	new/datum/stack_recipe("Mime Statue", /obj/structure/statue/tranquillite/mime, 5, one_per_turf = 1, on_floor = 1), \
	))

GLOBAL_LIST_INIT(abductor_recipes, list ( \
	new/datum/stack_recipe("alien bed", /obj/structure/bed/abductor, 2, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("alien locker", /obj/structure/closet/abductor, 1, time = 15, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("alien table frame", /obj/structure/table_frame/abductor, 1, time = 15, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("alien airlock assembly", /obj/structure/door_assembly/door_assembly_abductor, 4, time = 20, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe("alien floor tile", /obj/item/stack/tile/mineral/abductor, 1, 4, 20), \
	new/datum/stack_recipe("alien chair", /obj/structure/chair/comfy/abductor,  2, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("alien computer frame", /obj/structure/computerframe/abductor,  4, time = 25, one_per_turf = 1, on_floor = 1)
	))

GLOBAL_LIST_INIT(adamantine_recipes, list(
	new /datum/stack_recipe("incomplete servant golem shell", /obj/item/golem_shell/servant, req_amount = 1, res_amount = 1), \
	))

GLOBAL_LIST_INIT(snow_recipes, list(
	new/datum/stack_recipe("snowman", /obj/structure/snowman, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Snowball", /obj/item/snowball, 1)
	))

/obj/item/stack/sheet/mineral
	force = 5
	throwforce = 5
	throw_speed = 3

/obj/item/stack/sheet/mineral/New(loc, new_amount, merge = TRUE)
	..()
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4

/obj/item/stack/sheet/mineral/sandstone
	name = "sandstone brick"
	desc = "This appears to be a combination of both sand and stone."
	singular_name = "sandstone brick"
	icon_state = "sheet-sandstone"
	throw_range = 5
	origin_tech = "materials=1"
	sheettype = "sandstone"
	materials = list(MAT_GLASS=MINERAL_MATERIAL_AMOUNT)

/obj/item/stack/sheet/mineral/sandstone/Initialize(mapload, new_amount, merge = TRUE)
	. = ..()
	recipes = GLOB.sandstone_recipes

/obj/item/stack/sheet/mineral/sandstone/fifty
	amount = 50

/*
 * Sandbags
 */

/obj/item/stack/sheet/mineral/sandbags
	name = "sandbags"
	icon_state = "sandbags"
	singular_name = "sandbag"
	layer = LOW_ITEM_LAYER
	merge_type = /obj/item/stack/sheet/mineral/sandbags

GLOBAL_LIST_INIT(sandbag_recipes, list ( \
	new/datum/stack_recipe("sandbags", /obj/structure/barricade/sandbags, 1, time = 25, one_per_turf = 1, on_floor = 1), \
	))

/obj/item/stack/sheet/mineral/sandbags/Initialize(mapload, new_amount, merge = TRUE)
	. = ..()
	recipes = GLOB.sandbag_recipes

/obj/item/emptysandbag
	name = "empty sandbag"
	desc = "A bag to be filled with sand."
	icon = 'icons/obj/items.dmi'
	icon_state = "sandbag"
	w_class = WEIGHT_CLASS_TINY


/obj/item/emptysandbag/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/ore/glass))
		add_fingerprint(user)
		var/obj/item/stack/ore/glass/sand = I
		if(loc == user && !user.can_unEquip(src))
			return ATTACK_CHAIN_PROCEED
		if(!sand.use(1))
			to_chat(user, span_warning("There is not enough sand."))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You fill the sandbag."))
		var/obj/item/stack/sheet/mineral/sandbags/sandbag = new(drop_location())
		qdel(src)
		user.put_in_hands(sandbag, ignore_anim = FALSE)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/stack/sheet/mineral/diamond
	name = "diamond"
	icon_state = "sheet-diamond"
	item_state = "sheet-diamond"
	singular_name = "diamond"
	origin_tech = "materials=6"
	sheettype = "diamond"
	merge_type = /obj/item/stack/sheet/mineral/diamond
	materials = list(MAT_DIAMOND=MINERAL_MATERIAL_AMOUNT)
	point_value = 25

/obj/item/stack/sheet/mineral/diamond/Initialize(mapload, new_amount, merge = TRUE)
	. = ..()
	recipes = GLOB.diamond_recipes

/obj/item/stack/sheet/mineral/diamond/fifty
	amount = 50

/obj/item/stack/sheet/mineral/uranium
	name = "uranium"
	icon_state = "sheet-uranium"
	item_state = "sheet-uranium"
	singular_name = "uranium sheet"
	origin_tech = "materials=5"
	sheettype = "uranium"
	merge_type = /obj/item/stack/sheet/mineral/uranium
	materials = list(MAT_URANIUM=MINERAL_MATERIAL_AMOUNT)
	point_value = 20

/obj/item/stack/sheet/mineral/uranium/Initialize(mapload, new_amount, merge = TRUE)
	. = ..()
	recipes = GLOB.uranium_recipes

/obj/item/stack/sheet/mineral/uranium/fifty
	amount = 50

/obj/item/stack/sheet/mineral/plasma
	name = "solid plasma"
	icon_state = "sheet-plasma"
	item_state = "sheet-plasma"
	singular_name = "plasma sheet"
	origin_tech = "plasmatech=2;materials=2"
	sheettype = "plasma"
	merge_type = /obj/item/stack/sheet/mineral/plasma
	materials = list(MAT_PLASMA=MINERAL_MATERIAL_AMOUNT)
	resistance_flags = FLAMMABLE
	max_integrity = 100
	point_value = 20

/obj/item/stack/sheet/mineral/plasma/Initialize(mapload, new_amount, merge = TRUE)
	. = ..()
	recipes = GLOB.plasma_recipes

/obj/item/stack/sheet/mineral/plasma/fifty
	amount = 50

/obj/item/stack/sheet/mineral/plasma/welder_act(mob/user, obj/item/I)
	if(I.use_tool(src, user, volume = I.tool_volume))
		log_and_set_aflame(user, I)
	return TRUE


/obj/item/stack/sheet/mineral/plasma/attackby(obj/item/I, mob/user, params)
	if(I.get_heat())
		log_and_set_aflame(user, I)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/item/stack/sheet/mineral/plasma/proc/log_and_set_aflame(mob/user, obj/item/I)
	add_attack_logs(user, src, "Ignited [amount] amount, using [I]", ATKLOG_FEW)
	investigate_log("was <font color='red'><b>ignited</b></font> by [key_name_log(user)] in [amount] amount.", INVESTIGATE_ATMOS)
	fire_act()

/obj/item/stack/sheet/mineral/plasma/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	..()
	atmos_spawn_air(LINDA_SPAWN_HEAT | LINDA_SPAWN_TOXINS, amount*10)
	qdel(src)

/obj/item/stack/sheet/mineral/gold
	name = "gold"
	icon_state = "sheet-gold"
	item_state = "sheet-gold"
	singular_name = "gold bar"
	origin_tech = "materials=4"
	sheettype = "gold"
	merge_type = /obj/item/stack/sheet/mineral/gold
	materials = list(MAT_GOLD=MINERAL_MATERIAL_AMOUNT)
	point_value = 20

/obj/item/stack/sheet/mineral/gold/Initialize(mapload, new_amount, merge = TRUE)
	. = ..()
	recipes = GLOB.gold_recipes

/obj/item/stack/sheet/mineral/gold/fifty
	amount = 50

/obj/item/stack/sheet/mineral/silver
	name = "silver"
	icon_state = "sheet-silver"
	item_state = "sheet-silver"
	singular_name = "silver bar"
	origin_tech = "materials=4"
	sheettype = "silver"
	merge_type = /obj/item/stack/sheet/mineral/silver
	materials = list(MAT_SILVER=MINERAL_MATERIAL_AMOUNT)
	point_value = 20

/obj/item/stack/sheet/mineral/silver/Initialize(mapload, new_amount, merge = TRUE)
	. = ..()
	recipes = GLOB.silver_recipes

/obj/item/stack/sheet/mineral/silver/fifty
	amount = 50

/obj/item/stack/sheet/mineral/bananium
	name = "bananium"
	icon_state = "sheet-clown"
	singular_name = "bananium sheet"
	origin_tech = "materials=4"
	sheettype = "bananium"
	merge_type = /obj/item/stack/sheet/mineral/bananium
	materials = list(MAT_BANANIUM=MINERAL_MATERIAL_AMOUNT)
	point_value = 50

/obj/item/stack/sheet/mineral/bananium/fifty
	amount = 50

/obj/item/stack/sheet/mineral/bananium/Initialize(mapload, new_amount, merge = TRUE)
	. = ..()
	recipes = GLOB.bananium_recipes

/obj/item/stack/sheet/mineral/tranquillite
	name = "tranquillite"
	icon_state = "sheet-mime"
	singular_name = "beret"
	origin_tech = "materials=4"
	sheettype = "tranquillite"
	merge_type = /obj/item/stack/sheet/mineral/tranquillite
	materials = list(MAT_TRANQUILLITE=MINERAL_MATERIAL_AMOUNT)
	wall_allowed = FALSE	//no tranquilite walls in code
	point_value = 50

/obj/item/stack/sheet/mineral/tranquillite/fifty
	amount = 50

/obj/item/stack/sheet/mineral/tranquillite/Initialize(mapload, new_amount, merge = TRUE)
	. = ..()
	recipes = GLOB.tranquillite_recipes

/*
 * Titanium
 */
/obj/item/stack/sheet/mineral/titanium
	name = "titanium"
	icon_state = "sheet-titanium"
	item_state = "sheet-titanium"
	singular_name = "titanium sheet"
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 1
	throw_range = 3
	sheettype = "titanium"
	merge_type = /obj/item/stack/sheet/mineral/titanium
	materials = list(MAT_TITANIUM=MINERAL_MATERIAL_AMOUNT)
	point_value = 20

GLOBAL_LIST_INIT(titanium_recipes, list(
	new/datum/stack_recipe("titanium tile", /obj/item/stack/tile/mineral/titanium, 1, 4, 20),
	new/datum/stack_recipe("surgical tray", /obj/structure/table/tray, 2, one_per_turf = 1, on_floor = 1),
	))

/obj/item/stack/sheet/mineral/titanium/Initialize(mapload, new_amount, merge = TRUE)
	. = ..()
	recipes = GLOB.titanium_recipes

/obj/item/stack/sheet/mineral/titanium/fifty
	amount = 50


/*
 * Plastitanium
 */
/obj/item/stack/sheet/mineral/plastitanium
	name = "plastitanium"
	icon_state = "sheet-plastitanium"
	item_state = "sheet-plastitanium"
	singular_name = "plastitanium sheet"
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 1
	throw_range = 3
	sheettype = "plastitanium"
	merge_type = /obj/item/stack/sheet/mineral/plastitanium
	materials = list(MAT_TITANIUM=2000, MAT_PLASMA=2000)
	point_value = 45

/obj/item/stack/sheet/mineral/plastitanium/fifty
	amount = 50

GLOBAL_LIST_INIT(plastitanium_recipes, list(
	new/datum/stack_recipe("plas-titanium tile", /obj/item/stack/tile/mineral/plastitanium, 1, 4, 20),
	//adding syndie crate recipe here - Furu
	new/datum/stack_recipe("Suspicious crate", /obj/structure/closet/crate/syndicate, 10, 1, time = 20, one_per_turf = 1, on_floor = 1),

	//adding syndie airlocks recipe's here - Furu
	//WIP

	new /datum/stack_recipe_list("Evil airlock assemblies", list(

		new /datum/stack_recipe("Syndicate public airlock assembly", /obj/structure/door_assembly/syndicate/door_assembly_syndie_public, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("Syndicate security airlock assembly", /obj/structure/door_assembly/syndicate/door_assembly_syndie_sec, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("Syndicate cargo airlock assembly", /obj/structure/door_assembly/syndicate/door_assembly_syndie_cargo, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("Syndicate atmospherics airlock assembly", /obj/structure/door_assembly/syndicate/door_assembly_syndie_atmos, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("Syndicate research airlock assembly", /obj/structure/door_assembly/syndicate/door_assembly_syndie_research, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("Syndicate medical airlock assembly", /obj/structure/door_assembly/syndicate/door_assembly_syndie_med, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("Syndicate maintenance airlock assembly", /obj/structure/door_assembly/syndicate/door_assembly_syndie_maint, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("Syndicate command airlock assembly", /obj/structure/door_assembly/syndicate/door_assembly_syndie_com, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("Syndicate freezer airlock assembly", /obj/structure/door_assembly/syndicate/door_assembly_syndie_freezer, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("Syndicate external maintenance airlock assembly", /obj/structure/door_assembly/syndicate/door_assembly_syndie_extmai, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("Syndicate engineering airlock assembly", /obj/structure/door_assembly/syndicate/door_assembly_syndie_engi, 4, time = 50, one_per_turf = 1, on_floor = 1),

		//If i ever decide to make the rest syndie door types, here is the reference to what was not made - Furu
		/*
		new /datum/stack_recipe("standard airlock assembly", /obj/structure/door_assembly, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("science airlock assembly", /obj/structure/door_assembly/door_assembly_science, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("external airlock assembly", /obj/structure/door_assembly/door_assembly_ext, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("airtight hatch assembly", /obj/structure/door_assembly/door_assembly_hatch, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("maintenance hatch assembly", /obj/structure/door_assembly/door_assembly_mhatch, 4, time = 50, one_per_turf = 1, on_floor = 1),
		new /datum/stack_recipe("multi-tile airlock assembly", /obj/structure/door_assembly/multi_tile, 8, time = 50, one_per_turf = 1, on_floor = 1),
		*/
	))
	))

/obj/item/stack/sheet/mineral/plastitanium/Initialize(mapload, new_amount, merge = TRUE)
	. = ..()
	recipes = GLOB.plastitanium_recipes

/obj/item/stack/sheet/mineral/enruranium
	name = "enriched uranium"
	icon_state = "sheet-enruranium"
	origin_tech = "materials=6"
	materials = list(MAT_URANIUM=3000)

//Alien Alloy
/obj/item/stack/sheet/mineral/abductor
	name = "alien alloy"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "sheet-abductor"
	item_state = "sheet-abductor"
	singular_name = "alien alloy sheet"
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 1
	origin_tech = "materials=6;abductor=1"
	sheettype = "abductor"
	materials = list(MAT_METAL = 4000, MAT_PLASMA = 4000)

/obj/item/stack/sheet/mineral/abductor/fifty
	amount = 50

/obj/item/stack/sheet/mineral/abductor/Initialize(mapload, new_amount, merge = TRUE)
	. = ..()
	recipes = GLOB.abductor_recipes

/obj/item/stack/sheet/mineral/adamantine
	name = "adamantine"
	desc = "A strange mineral used in the construction of sentient golems."
	icon_state = "sheet-adamantine"
	item_state = "sheet-adamantine"
	singular_name = "adamantine sheet"
	origin_tech = "materials=5"
	merge_type = /obj/item/stack/sheet/mineral/adamantine
	wall_allowed = FALSE

/obj/item/stack/sheet/mineral/adamantine/fifty
	amount = 50

/obj/item/stack/sheet/mineral/adamantine/Initialize(mapload, new_amount, merge = TRUE)
	. = ..()
	recipes = GLOB.adamantine_recipes

/*
 * Mythril
 */
/obj/item/stack/sheet/mineral/mythril
	name = "mythril"
	desc = "A rare mineral used in construction of chitin armor."
	icon_state = "sheet-mythril"
	//item_state = "sheet-mythril"
	singular_name = "mythril sheet"
	origin_tech = "materials=7"
	merge_type = /obj/item/stack/sheet/mineral/mythril
	wall_allowed = FALSE

/obj/item/stack/sheet/mineral/mythril/fifty
	amount = 50

/*
 * Snow
 */
/obj/item/stack/sheet/mineral/snow
	name = "snow"
	icon_state = "sheet-snow"
	//item_state = "sheet-snow"
	singular_name = "snow block"
	force = 1
	throwforce = 2
	merge_type = /obj/item/stack/sheet/mineral/snow

/obj/item/stack/sheet/mineral/snow/fifty
	amount = 50

/obj/item/stack/sheet/mineral/snow/Initialize(mapload, new_amount, merge = TRUE)
	. = ..()
	recipes = GLOB.snow_recipes
