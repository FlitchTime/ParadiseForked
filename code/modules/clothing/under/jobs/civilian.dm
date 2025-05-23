//Alphabetical order of support jobs.

/obj/item/clothing/under/rank/bartender
	desc = "It looks like it could use some more flair."
	name = "bartender's uniform"
	icon_state = "ba_suit"
	item_state = "ba_suit"
	item_color = "ba_suit"

/obj/item/clothing/under/rank/bartender/skirt
	desc = "It looks like it could use some more flair."
	name = "bartender's skirt"
	icon_state = "ba_suitf"
	item_state = "ba_suitf"
	item_color = "ba_suitf"

/obj/item/clothing/under/rank/captain //Alright, technically not a 'civilian' but its better then giving a .dm file for a single define.
	desc = "It's a blue jumpsuit with some gold markings denoting the rank of \"Captain\"."
	name = "captain's jumpsuit"
	icon_state = "captain"
	item_state = "caparmor"
	item_color = "captain"
	dying_key = DYE_REGISTRY_UNDER

/obj/item/clothing/under/rank/cargo
	name = "quartermaster's jumpsuit"
	desc = "It's a jumpsuit worn by the quartermaster. It's specially designed to prevent back injuries caused by pushing paper."
	icon_state = "qm"
	item_state = "lb_suit"
	item_color = "qm"

/obj/item/clothing/under/rank/cargo/alt
	name = "quartermaster's dress"
	desc = "Dress for conducting bureaucracy and working with supplies, convenience and rigor in a single whole."
	icon_state = "qm_new"
	item_state = "clb_suit"
	item_color = "qm_new"

/obj/item/clothing/under/rank/cargo/skirt
	name = "quartermaster's jumpskirt"
	desc = "It's a jumpskirt worn by the quartermaster. It's specially designed to prevent back injuries caused by pushing paper."
	icon_state = "qmf"
	item_color = "qmf"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/cargo/official
	name = "quartermaster uniform"
	desc = "Pretty stylish for common NT supply workers uniform who are ready to check your request."
	icon_state = "qmu"
	item_state = "qmu"
	item_color = "qmu"

/obj/item/clothing/under/rank/cargotech
	name = "cargo technician's jumpsuit"
	desc = "Shooooorts! They're comfy and easy to wear!"
	icon_state = "cargotech"
	item_state = "lb_suit"
	item_color = "cargo"

/obj/item/clothing/under/rank/cargotech/skirt
	name = "cargo technician's jumpskirt"
	desc = "Skirrrrrts! They're comfy and easy to wear!"
	icon_state = "cargof"
	item_color = "cargof"

/obj/item/clothing/under/rank/cargotech/alt
	name = "cargo technician's dress"
	desc = "Pretty good and convenient to work dress for cargo technicians."
	icon_state = "cargotech_new"
	item_state = "clb_suit"
	item_color = "cargotech_new"

/obj/item/clothing/under/rank/chaplain
	desc = "It's a black jumpsuit, often worn by religious folk."
	name = "chaplain's jumpsuit"
	icon_state = "chaplain"
	item_state = "bl_suit"
	item_color = "chapblack"

/obj/item/clothing/under/rank/chaplain/skirt
	desc = "It's a black jumpskirt, often worn by religious folk."
	name = "chaplain's jumpskirt"
	icon_state = "chapblackf"
	item_state = "bl_suit"
	item_color = "chapblackf"
	over_shoes = TRUE

/obj/item/clothing/under/rank/chaplain/sensor
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/rank/chef
	desc = "It's an apron which is given only to the most <b>hardcore</b> chefs in space."
	name = "chef's uniform"
	icon_state = "chef"
	item_color = "chef"

/obj/item/clothing/under/rank/clown
	name = "clown suit"
	desc = "<i>'HONK!'</i>"
	icon_state = "clown"
	item_state = "clown"
	item_color = "clown"

/obj/item/clothing/under/rank/clown/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/items/bikehorn.ogg'), 50, falloff_exponent = 20) //die off quick please

/obj/item/clothing/under/rank/clown/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = ITEM_ATTACK)
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.mind && H.mind.assigned_role == JOB_TITLE_CLOWN)
			SSticker.score.score_clown_abuse++
	return ..()

/obj/item/clothing/under/rank/clown/sexy
	name = "sexy-clown suit"
	desc = "It makes you look HONKable!"
	icon_state = "sexyclown"
	item_state = "sexyclown"
	item_color = "sexyclown"

/obj/item/clothing/under/rank/clown/clussy
	name = "pink clown suit"
	desc = "It makes you look very HONKable!"
	icon_state = "clussy_clown"
	item_state = "clussy_clown"
	item_color = "clussy_clown"

/obj/item/clothing/under/rank/clown/nodrop


/obj/item/clothing/under/rank/clown/nodrop/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)



/obj/item/clothing/under/rank/head_of_personnel
	desc = "It's a jumpsuit worn by someone who works in the position of \"Head of Personnel\"."
	name = "head of personnel's jumpsuit"
	icon_state = "hop"
	item_state = "b_suit"
	item_color = "hop"

/obj/item/clothing/under/rank/head_of_personnel_whimsy
	desc = "A blue jacket and red tie, with matching red cuffs! Snazzy. Wearing this makes you feel more important than your job title does."
	name = "head of personnel's suit"
	icon_state = "hopwhimsy"
	item_state = "hopwhimsy"
	item_color = "hopwhimsy"

/obj/item/clothing/under/rank/head_of_personnel_alt
	name = "head of personnel's suit"
	desc = "It's a suit worn by someone who works in the position of \"Head of Personnel\"."
	icon_state = "hop_alt"
	item_state = "hop_alt"
	item_color = "hop_alt"

/obj/item/clothing/under/rank/head_of_personnel_f
	name = "head of personnel's skirt"
	desc = "It's a skirt worn by someone who works in the position of \"Head of Personnel\"."
	icon_state = "hop_skirt"
	item_state = "hop_skirt"
	item_color = "hop_skirt"

/obj/item/clothing/under/rank/hydroponics
	desc = "It's a jumpsuit designed to protect against minor plant-related hazards."
	name = "botanist's jumpsuit"
	icon_state = "hydroponics"
	item_state = "g_suit"
	item_color = "hydroponics"
	permeability_coefficient = 0.50

/obj/item/clothing/under/rank/hydroponics/skirt
	desc = "It's a jumpskirt designed to protect against minor plant-related hazards."
	name = "botanist's jumpskirt"
	icon_state = "hydroponicsf"
	item_state = "g_suit"
	item_color = "hydroponicsf"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/uniform.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/uniform.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/uniform.dmi'
		)

/obj/item/clothing/under/rank/internalaffairs
	desc = "The plain, professional attire of an Internal Affairs Agent. The collar is <i>immaculately</i> starched."
	name = "Internal Affairs uniform"
	icon_state = "internalaffairs"
	item_state = "internalaffairs"
	item_color = "internalaffairs"

/obj/item/clothing/under/rank/internalaffairs/skirt
	desc = "The plain, professional attire of an Internal Affairs Agent. The collar is <i>immaculately</i> starched."
	name = "Internal Affairs uniform with skirt"
	icon_state = "internalaffairsf"
	item_state = "internalaffairsf"
	item_color = "internalaffairsf"

/obj/item/clothing/under/rank/ntrep
	desc = "A well-ironed dress shirt and matching set of black pants."
	name = "dress shirt"
	icon_state = "internalaffairs"
	item_state = "internalaffairs"
	item_color = "internalaffairs"

/obj/item/clothing/under/rank/ntrep/skirt
	desc = "Black bottom, white top."
	name = "representative skirt"
	icon_state = "ntrepf"
	item_state = "ntrepf"
	item_color = "ntrepf"

/obj/item/clothing/under/rank/janitor
	desc = "It's the official uniform of the station's janitor. It has minor protection from biohazards."
	name = "janitor's jumpsuit"
	icon_state = "janitor"
	item_color = "janitor"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 0)


/obj/item/clothing/under/lawyer
	desc = "Slick threads."
	name = "Lawyer suit"

/obj/item/clothing/under/lawyer/black
	icon_state = "lawyer_black"
	item_state = "lawyer_black"
	item_color = "lawyer_black"

/obj/item/clothing/under/lawyer/female
	icon_state = "black_suit_fem"
	item_state = "black_suit_fem"
	item_color = "black_suit_fem"

/obj/item/clothing/under/lawyer/red
	icon_state = "lawyer_red"
	item_state = "lawyer_red"
	item_color = "lawyer_red"

/obj/item/clothing/under/lawyer/blue
	icon_state = "lawyer_blue"
	item_state = "lawyer_blue"
	item_color = "lawyer_blue"

/obj/item/clothing/under/lawyer/bluesuit
	name = "Blue Suit"
	desc = "A classy suit and tie"
	icon_state = "bluesuit"
	item_state = "bluesuit"
	item_color = "bluesuit"

/obj/item/clothing/under/lawyer/purpsuit
	name = "Purple Suit"
	icon_state = "lawyer_purp"
	item_state = "lawyer_purp"
	item_color = "lawyer_purp"

/obj/item/clothing/under/lawyer/oldman
	name = "Old Man's Suit"
	desc = "A classic suit for the older gentleman with built in back support."
	icon_state = "oldman"
	item_state = "oldman"
	item_color = "oldman"
	dying_key = DYE_REGISTRY_UNDER


/obj/item/clothing/under/librarian
	name = "sensible suit"
	desc = "It's very... sensible."
	icon_state = "red_suit"
	item_state = "red_suit"
	item_color = "red_suit"

/obj/item/clothing/under/mime
	name = "mime's outfit"
	desc = "It's not very colourful."
	icon_state = "mime"
	item_state = "mime"
	item_color = "mime"
	dying_key = DYE_REGISTRY_UNDER

/obj/item/clothing/under/mime/nodrop


/obj/item/clothing/under/mime/nodrop/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)


/obj/item/clothing/under/rank/miner
	desc = "It's a snappy jumpsuit with a sturdy set of overalls. It is very dirty."
	name = "shaft miner's jumpsuit"
	icon_state = "miner"
	item_state = "miner"
	item_color = "miner"

/obj/item/clothing/under/rank/miner/alt
	desc = "Cozy, old-style work sweater."
	name = "shaft miner's sweater"
	icon_state = "miner_alt"
	item_state = "miner_alt"
	item_color = "miner_alt"

/obj/item/clothing/under/rank/miner/lavaland
	desc = "A green uniform for operating in hazardous environments."
	name = "shaft miner's jumpsuit"
	icon_state = "explorer"
	item_state = "explorer"
	item_color = "explorer"

/obj/item/clothing/under/barber
	desc = "It's a barber's uniform."
	name = "barber's uniform"
	icon_state = "barber"
	item_state = "barber"
	item_color = "barber"

/obj/item/clothing/under/barber/skirt
	desc = "It's a barber's skirt."
	name = "barber's skirt"
	icon_state = "barberf"
	item_state = "barberf"
	item_color = "barberf"
	over_shoes = TRUE

/obj/item/clothing/under/artist
	desc = "Formal uniform with buttons on a side"
	name = "parade chef's uniform"
	icon_state = "artist"
	item_state = "artist"
	item_color = "artist"
