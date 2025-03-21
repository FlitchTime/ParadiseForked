// IPC limbs.
/obj/item/organ/external/head/ipc
	species_type = /datum/species/machine
	can_intake_reagents = 0
	max_damage = 50 //made same as arm, since it is not vital
	min_broken_damage = 30
	encased = null
	status = ORGAN_ROBOT
	emp_resistant = TRUE
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	drop_sound = 'sound/items/handling/component_drop.ogg'

/obj/item/organ/external/head/ipc/Initialize(mapload, special = ORGAN_MANIPULATION_NOEFFECT)
	. = ..()

	robotize(company = "Morpheus Cyberkinetics")

/obj/item/organ/external/chest/ipc
	species_type = /datum/species/machine
	encased = null
	status = ORGAN_ROBOT
	emp_resistant = TRUE
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	drop_sound = 'sound/items/handling/component_drop.ogg'

/obj/item/organ/external/chest/ipc/Initialize(mapload, special = ORGAN_MANIPULATION_NOEFFECT)
	. = ..()

	robotize(company = "Morpheus Cyberkinetics")

/obj/item/organ/external/groin/ipc
	species_type = /datum/species/machine
	encased = null
	status = ORGAN_ROBOT
	emp_resistant = TRUE
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	drop_sound = 'sound/items/handling/component_drop.ogg'

/obj/item/organ/external/groin/ipc/Initialize(mapload, special = ORGAN_MANIPULATION_NOEFFECT)
	. = ..()

	robotize(company = "Morpheus Cyberkinetics")

/obj/item/organ/external/arm/ipc
	species_type = /datum/species/machine
	encased = null
	status = ORGAN_ROBOT
	emp_resistant = TRUE
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	drop_sound = 'sound/items/handling/component_drop.ogg'

/obj/item/organ/external/arm/ipc/Initialize(mapload, special = ORGAN_MANIPULATION_NOEFFECT)
	. = ..()

	robotize(company = "Morpheus Cyberkinetics")

/obj/item/organ/external/arm/right/ipc
	species_type = /datum/species/machine
	encased = null
	status = ORGAN_ROBOT
	emp_resistant = TRUE

/obj/item/organ/external/arm/right/ipc/Initialize(mapload, special = ORGAN_MANIPULATION_NOEFFECT)
	. = ..()

	robotize(company = "Morpheus Cyberkinetics")

/obj/item/organ/external/leg/ipc
	species_type = /datum/species/machine
	encased = null
	status = ORGAN_ROBOT
	emp_resistant = TRUE
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	drop_sound = 'sound/items/handling/component_drop.ogg'

/obj/item/organ/external/leg/ipc/Initialize(mapload, special = ORGAN_MANIPULATION_NOEFFECT)
	. = ..()

	robotize(company = "Morpheus Cyberkinetics")

/obj/item/organ/external/leg/right/ipc
	species_type = /datum/species/machine
	encased = null
	status = ORGAN_ROBOT
	emp_resistant = TRUE

/obj/item/organ/external/leg/right/ipc/Initialize(mapload, special = ORGAN_MANIPULATION_NOEFFECT)
	. = ..()

	robotize(company = "Morpheus Cyberkinetics")

/obj/item/organ/external/foot/ipc
	species_type = /datum/species/machine
	encased = null
	status = ORGAN_ROBOT
	emp_resistant = TRUE
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	drop_sound = 'sound/items/handling/component_drop.ogg'

/obj/item/organ/external/foot/ipc/Initialize(mapload, special = ORGAN_MANIPULATION_NOEFFECT)
	. = ..()

	robotize(company = "Morpheus Cyberkinetics")

/obj/item/organ/external/foot/right/ipc
	species_type = /datum/species/machine
	encased = null
	status = ORGAN_ROBOT
	emp_resistant = TRUE

/obj/item/organ/external/foot/right/ipc/Initialize(mapload, special = ORGAN_MANIPULATION_NOEFFECT)
	. = ..()

	robotize(company = "Morpheus Cyberkinetics")

/obj/item/organ/external/hand/ipc
	species_type = /datum/species/machine
	encased = null
	status = ORGAN_ROBOT
	emp_resistant = TRUE
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	drop_sound = 'sound/items/handling/component_drop.ogg'

/obj/item/organ/external/hand/ipc/Initialize(mapload, special = ORGAN_MANIPULATION_NOEFFECT)
	. = ..()

	robotize(company = "Morpheus Cyberkinetics")

/obj/item/organ/external/hand/right/ipc
	species_type = /datum/species/machine
	encased = null
	status = ORGAN_ROBOT
	emp_resistant = TRUE

/obj/item/organ/external/hand/right/ipc/Initialize(mapload, special = ORGAN_MANIPULATION_NOEFFECT)
	. = ..()

	robotize(company = "Morpheus Cyberkinetics")

/obj/item/organ/internal/cell
	species_type = /datum/species/machine
	name = "microbattery"
	desc = "Маленькая, но мощная батарея, используемая для питания роботизированных систем. Такие устанавливаются в КПБ."
	ru_names = list(
		NOMINATIVE = "микробатарея",
		GENITIVE = "микробатареи",
		DATIVE = "микробатарее",
		ACCUSATIVE = "микробатарею",
		INSTRUMENTAL = "микробатареей",
		PREPOSITIONAL = "микробатарее"
	)
	gender = FEMALE
	icon = 'icons/obj/engines_and_power/power.dmi'
	icon_state = "scell"
	parent_organ_zone = BODY_ZONE_CHEST
	slot = INTERNAL_ORGAN_HEART
	vital = TRUE
	status = ORGAN_ROBOT
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	drop_sound = 'sound/items/handling/component_drop.ogg'

/obj/item/organ/internal/eyes/optical_sensor
	species_type = /datum/species/machine
	name = "optical sensor"
	desc = "Сенсор, оснащённый светочувствительной матрицей, выполняет зрительную функцию. Такие устанавливаются в КПБ."
	ru_names = list(
		NOMINATIVE = "оптический сенсор",
		GENITIVE = "оптического сенсора",
		DATIVE = "оптическому сенсору",
		ACCUSATIVE = "оптический сенсор",
		INSTRUMENTAL = "оптическим сенсором",
		PREPOSITIONAL = "оптическом сенсоре"
	)
	gender = MALE
	icon = 'icons/obj/robot_component.dmi'
	icon_state = "camera"
	status = ORGAN_ROBOT
//	dead_icon = "camera_broken"
	weld_proof = 1
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	drop_sound = 'sound/items/handling/component_drop.ogg'

/obj/item/organ/internal/eyes/optical_sensor/remove(mob/living/user, special = ORGAN_MANIPULATION_DEFAULT)
	if(!special)
		to_chat(owner, span_userdanger("Ошибка #404: ОПТИЧЕСКИЙ СЕНСОР - не обнаружено."))

	. = ..()

/obj/item/organ/internal/brain/mmi_holder/posibrain
	species_type = /datum/species/machine
	name = "positronic brain"
	desc = "Компьютер, обладающий огромной вычислительной мощностью, содержит внутри себя синтетический разум. Именно здесь и находится сознание КПБ."
	ru_names = list(
		NOMINATIVE = "позитронный мозг",
		GENITIVE = "позитронного мозга",
		DATIVE = "позитронному мозгу",
		ACCUSATIVE = "позитронный мозг",
		INSTRUMENTAL = "позитронным мозгом",
		PREPOSITIONAL = "позитронном мозге"
	)
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	drop_sound = 'sound/items/handling/component_drop.ogg'

/obj/item/organ/internal/brain/mmi_holder/posibrain/New()
	..()
	stored_mmi = new /obj/item/mmi/robotic_brain/positronic(src)
	if(!owner)
		stored_mmi.forceMove(get_turf(src))
		qdel(src)

/obj/item/organ/internal/brain/mmi_holder/posibrain/remove(mob/living/user, special = ORGAN_MANIPULATION_DEFAULT)
	if(stored_mmi && dna)
		stored_mmi.name = "[initial(name)] ([dna.real_name])"
		if(stored_mmi.ru_names)
			for(var/i = 1; i <=6; i++)
				stored_mmi.ru_names[i] = initial(ru_names[i]) + " [dna.real_name]"
		stored_mmi.brainmob.real_name = dna.real_name
		stored_mmi.brainmob.name = stored_mmi.brainmob.real_name
		stored_mmi.icon_state = "posibrain-occupied"
		if(!stored_mmi.brainmob.dna)
			stored_mmi.brainmob.dna = dna.Clone()
	. = ..()

/obj/item/organ/internal/ears/microphone
	species_type = /datum/species/machine
	name = "microphone"
	desc = "Пара микрофонов. Используются для получения аудиальной информации об окружающей среде. Такие устанавливаются в КПБ."
	ru_names = list(
		NOMINATIVE = "парные микрофоны",
		GENITIVE = "парных микрофонов",
		DATIVE = "парным микрофонам",
		ACCUSATIVE = "парные микрофоны",
		INSTRUMENTAL = "парными микрофонами",
		PREPOSITIONAL = "парных микрофонах"
	)
	icon = 'icons/obj/device.dmi'
	icon_state = "taperecorder_idle"
	status = ORGAN_ROBOT
	dead_icon = "taperecorder_empty"
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	drop_sound = 'sound/items/handling/component_drop.ogg'

/obj/item/organ/internal/ears/microphone/remove(mob/living/user, special = ORGAN_MANIPULATION_DEFAULT)
	if(!special)
		to_chat(owner, span_userdanger("Ошибка #406: МИКРОФОН - не обнаружено."))
	. = ..()
