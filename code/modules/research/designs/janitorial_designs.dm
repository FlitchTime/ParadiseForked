/////////////////////////////////////////
///////////Janitorial Designs////////////
/////////////////////////////////////////
/datum/design/advmop
	name = "Advanced Mop"
	desc = "An upgraded mop with a large internal capacity for holding water or other cleaning chemicals."
	id = "advmop"
	req_tech = list("materials" = 4, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2500, MAT_GLASS = 200)
	build_path = /obj/item/mop/advanced
	category = list("Janitorial")

/datum/design/bluespace_cleaner
	name = "Bluespace Cleaner"
	desc = "An technological cleaner with a large internal capacity for holding various chemicals."
	id = "bluespace_cleaner"
	req_tech = list("materials" = 5, "bluespace" = 5,"plasmatech" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_PLASMA = 1300, MAT_GLASS = 1400, MAT_DIAMOND = 100, MAT_BLUESPACE = 100)
	build_path = /obj/item/reagent_containers/spray/blue_cleaner
	category = list("Janitorial")

/datum/design/blutrash
	name = "Trashbag of Holding"
	desc = "An advanced trash bag with bluespace properties; capable of holding a plethora of garbage."
	id = "blutrash"
	req_tech = list("materials" = 5, "bluespace" = 4, "engineering" = 4, "plasmatech" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 1500, MAT_URANIUM = 250, MAT_PLASMA = 1500, MAT_BLUESPACE = 50)
	build_path = /obj/item/storage/bag/trash/bluespace
	category = list("Janitorial")

/datum/design/buffer
	name = "Floor Buffer Upgrade"
	desc = "A floor buffer that can be attached to vehicular janicarts."
	id = "buffer"
	req_tech = list("materials" = 4, "engineering" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000, MAT_GLASS = 200)
	build_path = /obj/item/janiupgrade
	category = list("Janitorial")

/datum/design/holosign
	name = "Janitoral Holographic Sign Projector"
	desc = "A holograpic projector used to project wet warning signs."
	id = "holosign"
	req_tech = list("programming" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000)
	build_path = /obj/item/holosign_creator/janitor
	category = list("Janitorial")

/datum/design/light_replacer
	name = "Light Replacer"
	desc = "A device to automatically replace lights. Refill with working lightbulbs."
	id = "light_replacer"
	req_tech = list("magnets" = 3, "engineering" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1500, MAT_SILVER = 150, MAT_GLASS = 3000)
	build_path = /obj/item/lightreplacer
	category = list("Janitorial")

/datum/design/light_replacer_bluespace
	name = "Bluespace Light Replacer"
	desc = "A device to automatically replace lights from a distance. Refill with working light bulbs."
	id = "light_replacer_bluespace"
	req_tech = list("bluespace" = 7, "materials" = 5, "engineering" = 6, "plasmatech" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1500, MAT_SILVER = 150, MAT_GLASS = 6000, MAT_BLUESPACE = 300)
	build_path = /obj/item/lightreplacer/bluespace
	category = list("Janitorial")
