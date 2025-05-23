/datum/gear/suit
	subtype_path = /datum/gear/suit
	slot = ITEM_SLOT_CLOTH_OUTER
	sort_category = "External Wear"

//WINTER COATS
/datum/gear/suit/coat
	subtype_path = /datum/gear/suit/coat

/datum/gear/suit/coat/grey
	index_name = "winter coat"
	path = /obj/item/clothing/suit/hooded/wintercoat

/datum/gear/suit/coat/job
	subtype_path = /datum/gear/suit/coat/job
	subtype_cost_overlap = FALSE

/datum/gear/suit/coat/job/sec
	index_name = "winter coat, security"
	path = /obj/item/clothing/suit/hooded/wintercoat/security
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_DETECTIVE, JOB_TITLE_OFFICER, JOB_TITLE_PILOT, JOB_TITLE_BRIGDOC)

/datum/gear/suit/coat/job/hos
	index_name = "winter coat, head of security"
	path = /obj/item/clothing/suit/hooded/wintercoat/security/hos
	allowed_roles = list(JOB_TITLE_HOS)

/datum/gear/suit/coat/job/captain
	index_name = "winter coat, captain"
	path = /obj/item/clothing/suit/hooded/wintercoat/captain
	allowed_roles = list(JOB_TITLE_CAPTAIN)

/datum/gear/suit/coat/job/med
	index_name = "winter coat, medical"
	path = /obj/item/clothing/suit/hooded/wintercoat/medical
	allowed_roles = list(JOB_TITLE_CMO, JOB_TITLE_DOCTOR, JOB_TITLE_MINING_MEDIC, JOB_TITLE_INTERN, JOB_TITLE_CHEMIST, JOB_TITLE_PSYCHIATRIST, JOB_TITLE_PARAMEDIC, JOB_TITLE_VIROLOGIST, JOB_TITLE_BRIGDOC , JOB_TITLE_CORONER)

/datum/gear/suit/coat/job/cmo
	index_name = "winter coat, chief medical officer"
	path = /obj/item/clothing/suit/hooded/wintercoat/medical/cmo
	allowed_roles = list(JOB_TITLE_CMO)

/datum/gear/suit/coat/job/sci
	index_name = "winter coat, science"
	path = /obj/item/clothing/suit/hooded/wintercoat/medical/science
	allowed_roles = list(JOB_TITLE_SCIENTIST, JOB_TITLE_RD, JOB_TITLE_SCIENTIST_STUDENT)

/datum/gear/suit/coat/job/rd
	index_name = "winter coat, research director"
	path = /obj/item/clothing/suit/hooded/wintercoat/medical/science/rd
	allowed_roles = list(JOB_TITLE_RD)

/datum/gear/suit/coat/job/engi
	index_name = "winter coat, engineering"
	path = /obj/item/clothing/suit/hooded/wintercoat/engineering
	allowed_roles = list(JOB_TITLE_CHIEF, JOB_TITLE_ENGINEER, JOB_TITLE_ENGINEER_TRAINEE, JOB_TITLE_MECHANIC)

/datum/gear/suit/coat/job/atmos
	index_name = "winter coat, atmospherics"
	path = /obj/item/clothing/suit/hooded/wintercoat/engineering/atmos
	allowed_roles = list(JOB_TITLE_CHIEF, JOB_TITLE_ATMOSTECH)

/datum/gear/suit/coat/job/ce
	index_name = "winter coat, chief engineer"
	path = /obj/item/clothing/suit/hooded/wintercoat/engineering/ce
	allowed_roles = list(JOB_TITLE_CHIEF)

/datum/gear/suit/coat/job/hydro
	index_name = "winter coat, hydroponics"
	path = /obj/item/clothing/suit/hooded/wintercoat/hydro
	allowed_roles = list(JOB_TITLE_BOTANIST)

/datum/gear/suit/coat/job/cargo
	index_name = "winter coat, cargo"
	path = /obj/item/clothing/suit/hooded/wintercoat/cargo
	allowed_roles = list(JOB_TITLE_QUARTERMASTER, JOB_TITLE_CARGOTECH)

/datum/gear/suit/coat/job/qm
	index_name = "winter coat, quartermaster"
	path = /obj/item/clothing/suit/hooded/wintercoat/cargo/qm
	allowed_roles = list(JOB_TITLE_QUARTERMASTER)

/datum/gear/suit/coat/job/miner
	index_name = "winter coat, miner"
	path = /obj/item/clothing/suit/hooded/wintercoat/miner
	allowed_roles = list(JOB_TITLE_MINER, JOB_TITLE_MINING_MEDIC)

/datum/gear/suit/coat/job/hop
	index_name = "winter coat, head of personnel"
	path = /obj/item/clothing/suit/hooded/wintercoat/hop
	allowed_roles = list(JOB_TITLE_HOP)

//LABCOATS
/datum/gear/suit/labcoat_emt
	index_name = "labcoat, paramedic"
	path = /obj/item/clothing/suit/storage/labcoat/emt
	allowed_roles = list(JOB_TITLE_CMO, JOB_TITLE_PARAMEDIC)

//JACKETS
/datum/gear/suit/leather_jacket
	index_name = "leather jacket"
	path = /obj/item/clothing/suit/jacket/leather

/datum/gear/suit/motojacket
	index_name = "leather motorcycle jacket"
	path = /obj/item/clothing/suit/jacket/motojacket

/datum/gear/suit/br_tcoat
	index_name = "trenchcoat, brown"
	path = /obj/item/clothing/suit/storage/browntrenchcoat

/datum/gear/suit/bl_tcoat
	index_name = "trenchcoat, black"
	path = /obj/item/clothing/suit/storage/blacktrenchcoat

/datum/gear/suit/bomber_jacket
	index_name = "bomber jacket"
	path = /obj/item/clothing/suit/jacket

/datum/gear/suit/miljacket
	index_name = "military jacket, select"
	display_name = "military jacket"
	path = /obj/item/clothing/suit/jacket/miljacket

/datum/gear/suit/miljacket/New()
	..()
	var/list/jackets = list("olive" = /obj/item/clothing/suit/jacket/miljacket,
							"navy" = /obj/item/clothing/suit/jacket/miljacket/navy,
							"desert" = /obj/item/clothing/suit/jacket/miljacket/desert,
							"white" = /obj/item/clothing/suit/jacket/miljacket/white,
							)
	gear_tweaks += new /datum/gear_tweak/path(jackets, src)

/datum/gear/suit/secjacket
	index_name = "security jacket"
	path = /obj/item/clothing/suit/armor/secjacket
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_DETECTIVE, JOB_TITLE_OFFICER, JOB_TITLE_PILOT)

/datum/gear/suit/coat/russian
	index_name = "russian coat"
	path = /obj/item/clothing/suit/russiancoat

/datum/gear/suit/secbomber
	index_name = "security bomber"
	path = /obj/item/clothing/suit/jacket/pilot
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_DETECTIVE, JOB_TITLE_OFFICER, JOB_TITLE_PILOT)

/datum/gear/suit/sec_rps
	index_name = "security belt-shoulder system"
	path = /obj/item/clothing/suit/armor/vest/sec_rps
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_DETECTIVE, JOB_TITLE_OFFICER, JOB_TITLE_PILOT)

//SURAGI JACKET
/datum/gear/suit/suragi_jacket
	subtype_path = /datum/gear/suit/suragi_jacket

/datum/gear/suit/suragi_jacket/civ
	index_name = "Suragi Jacket"
	path = /obj/item/clothing/suit/storage/suragi_jacket/civ


/datum/gear/suit/suragi_jacket/sec
	index_name = "Suragi Jacket - Security"
	path = /obj/item/clothing/suit/storage/suragi_jacket/sec
	allowed_roles = list(JOB_TITLE_WARDEN, JOB_TITLE_DETECTIVE, JOB_TITLE_OFFICER, JOB_TITLE_PILOT)


/datum/gear/suit/suragi_jacket/cargo
	index_name = "Suragi Jacket - Cargo"
	path = /obj/item/clothing/suit/storage/suragi_jacket/cargo
	allowed_roles = list(JOB_TITLE_CARGOTECH)


/datum/gear/suit/suragi_jacket/atmos
	index_name = "Suragi Jacket - Atmospherics"
	path = /obj/item/clothing/suit/storage/suragi_jacket/atmos
	allowed_roles = list(JOB_TITLE_ATMOSTECH)


/datum/gear/suit/suragi_jacket/eng
	index_name = "Suragi Jacket - Engineering"
	path = /obj/item/clothing/suit/storage/suragi_jacket/eng
	allowed_roles = list(JOB_TITLE_ENGINEER, JOB_TITLE_ENGINEER_TRAINEE, JOB_TITLE_MECHANIC)


/datum/gear/suit/suragi_jacket/botany
	index_name = "Suragi Jacket - Hydroponics"
	path = /obj/item/clothing/suit/storage/suragi_jacket/botany
	allowed_roles = list(JOB_TITLE_BOTANIST)


/datum/gear/suit/suragi_jacket/medic
	index_name = "Suragi Jacket - Medical"
	path = /obj/item/clothing/suit/storage/suragi_jacket/medic
	allowed_roles = list(JOB_TITLE_DOCTOR, JOB_TITLE_MINING_MEDIC, JOB_TITLE_INTERN, JOB_TITLE_PSYCHIATRIST, JOB_TITLE_PARAMEDIC, JOB_TITLE_CORONER)


/datum/gear/suit/suragi_jacket/medsec
	index_name = "Suragi Jacket - Medical Security"
	path = /obj/item/clothing/suit/storage/suragi_jacket/medsec
	allowed_roles = list(JOB_TITLE_BRIGDOC)


/datum/gear/suit/suragi_jacket/virus
	index_name = "Suragi Jacket - Virology"
	path = /obj/item/clothing/suit/storage/suragi_jacket/virus
	allowed_roles = list(JOB_TITLE_VIROLOGIST)


/datum/gear/suit/suragi_jacket/chem
	index_name = "Suragi Jacket - Chemistry"
	path = /obj/item/clothing/suit/storage/suragi_jacket/chem
	allowed_roles = list(JOB_TITLE_CHEMIST)


/datum/gear/suit/suragi_jacket/genetics
	index_name = "Suragi Jacket - Genetics"
	path = /obj/item/clothing/suit/storage/suragi_jacket/genetics
	allowed_roles = list(JOB_TITLE_GENETICIST)


/datum/gear/suit/suragi_jacket/robot
	index_name = "Suragi Jacket - Roboticist"
	path = /obj/item/clothing/suit/storage/suragi_jacket/robot
	allowed_roles = list(JOB_TITLE_ROBOTICIST)


/datum/gear/suit/suragi_jacket/sci
	index_name = "Suragi Jacket - Science"
	path = /obj/item/clothing/suit/storage/suragi_jacket/sci
	allowed_roles = list(JOB_TITLE_SCIENTIST, JOB_TITLE_SCIENTIST_STUDENT)


/datum/gear/suit/suragi_jacket/janitor
	index_name = "Suragi Jacket - Janitor"
	path = /obj/item/clothing/suit/storage/suragi_jacket/janitor
	allowed_roles = list(JOB_TITLE_JANITOR)


/datum/gear/suit/ianshirt
	index_name = "Ian Shirt"
	path = /obj/item/clothing/suit/ianshirt

/datum/gear/suit/hoodie
	index_name = "hoodie, select"
	display_name = "hoodie"
	path = /obj/item/clothing/suit/hooded/hoodie

/datum/gear/suit/hoodie/New()
	..()
	var/list/hoods = list(/obj/item/clothing/suit/hooded/hoodie,
						  /obj/item/clothing/suit/hooded/hoodie/tp,
						  /obj/item/clothing/suit/hooded/hoodie/nt,
						  /obj/item/clothing/suit/hooded/hoodie/lam,
						  /obj/item/clothing/suit/hooded/hoodie/cut,
						  /obj/item/clothing/suit/hooded/hoodie/mit,
						  /obj/item/clothing/suit/hooded/hoodie/blue,
						  )
	gear_tweaks += new /datum/gear_tweak/path(hoods, src, TRUE)

//SUITS!

/datum/gear/suit/blacksuit
	index_name = "suit jacket, select"
	display_name = "suit jacket"
	path = /obj/item/clothing/suit/storage/lawyer/blackjacket

/datum/gear/suit/blacksuit/New()
	..()
	var/list/suits = list("black" = /obj/item/clothing/suit/storage/lawyer/blackjacket,
						  "blue" = /obj/item/clothing/suit/storage/lawyer/bluejacket,
						  "purple" = /obj/item/clothing/suit/storage/lawyer/purpjacket,)
	gear_tweaks += new /datum/gear_tweak/path(suits, src)

//Robes!

/datum/gear/suit/witch
	index_name = "witch robes"
	path = /obj/item/clothing/suit/wizrobe/marisa/fake


//Suspenders

/datum/gear/suit/suspenders
	index_name = "suspenders, color"
	path = /obj/item/clothing/suit/suspenders

/datum/gear/suit/suspenders/New()
	..()
	gear_tweaks += new /datum/gear_tweak/color(parent = src)
