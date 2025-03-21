#define OP_COMPUTER_COOLDOWN 60

/obj/machinery/computer/operating
	name = "operating computer"
	desc = "Высокотехнологичный медицинский компьютер, используемый для контролирования процесса хиругических операций."
	ru_names = list(
		NOMINATIVE = "операционный компьютер",
		GENITIVE = "операционного компьютера",
		DATIVE = "операционному компьютеру",
		ACCUSATIVE = "операционный компьютер",
		INSTRUMENTAL = "операционным компьютером",
		PREPOSITIONAL = "операционном компьютере"
	)
	density = TRUE
	anchored = TRUE
	icon_keyboard = "med_key"
	icon_screen = "crew"
	circuit = /obj/item/circuitboard/operating
	light_color = LIGHT_COLOR_PURE_BLUE
	var/obj/machinery/optable/table
	var/verbose = TRUE //general speaker toggle
	var/oxyAlarm = 30 //oxy damage at which the computer will beep
	var/choice = FALSE //just for going into and out of the options menu
	var/healthAnnounce = TRUE //healther announcer toggle
	var/crit = TRUE //crit beeping toggle
	var/nextTick = OP_COMPUTER_COOLDOWN
	var/healthAlarm = 50
	var/oxy = TRUE //oxygen beeping toggle
	/// Who is on the Operating Table connected to the respective Operating Computer?
	/// Only used to see if it changed from the previous occupant. If you want any actual information
	/// about the mob - use `table.patient` instead.
	var/mob/living/carbon/currentPatient
	var/patientStatusHolder //Hold the last instance of table.patient.status. When table.patient.status no longer matches this variable, the computer should tell the doctor

/obj/machinery/computer/operating/New()
	..()
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		table = locate(/obj/machinery/optable, get_step(src, dir))
		if(table)
			table.computer = src
			break

/obj/machinery/computer/operating/Destroy()
	if(table)
		table.computer = null
		table = null
	if(currentPatient)
		currentPatient = null
	return ..()

/obj/machinery/computer/operating/attack_ai(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	ui_interact(user)

/obj/machinery/computer/operating/attack_hand(mob/user)
	if(..(user))
		return

	if(stat & (NOPOWER|BROKEN))
		return

	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/computer/operating/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OperatingComputer", "Patient Monitor")
		ui.open()

/obj/machinery/computer/operating/ui_data(mob/user)
	var/list/data = list()
	var/mob/living/carbon/occupant
	if(table)
		occupant = table.patient
	data["hasOccupant"] = occupant ? 1 : 0
	var/occupantData[0]

	if(occupant)
		occupantData["name"] = occupant.name
		occupantData["stat"] = occupant.stat
		occupantData["health"] = occupant.health
		occupantData["maxHealth"] = occupant.maxHealth
		occupantData["minHealth"] = HEALTH_THRESHOLD_DEAD
		occupantData["bruteLoss"] = occupant.getBruteLoss()
		occupantData["oxyLoss"] = occupant.getOxyLoss()
		occupantData["toxLoss"] = occupant.getToxLoss()
		occupantData["fireLoss"] = occupant.getFireLoss()
		occupantData["paralysis"] = occupant.AmountParalyzed()
		occupantData["hasBlood"] = 0
		occupantData["bodyTemperature"] = occupant.bodytemperature
		occupantData["maxTemp"] = 1000 // If you get a burning vox armalis into the sleeper, congratulations
		// Because we can put simple_animals in here, we need to do something tricky to get things working nice
		occupantData["temperatureSuitability"] = 0 // 0 is the baseline
		if(ishuman(occupant) && occupant.dna.species)
			var/datum/species/sp = occupant.dna.species
			if(occupant.bodytemperature < sp.cold_level_3)
				occupantData["temperatureSuitability"] = -3
			else if(occupant.bodytemperature < sp.cold_level_2)
				occupantData["temperatureSuitability"] = -2
			else if(occupant.bodytemperature < sp.cold_level_1)
				occupantData["temperatureSuitability"] = -1
			else if(occupant.bodytemperature > sp.heat_level_3)
				occupantData["temperatureSuitability"] = 3
			else if(occupant.bodytemperature > sp.heat_level_2)
				occupantData["temperatureSuitability"] = 2
			else if(occupant.bodytemperature > sp.heat_level_1)
				occupantData["temperatureSuitability"] = 1
		else if(isanimal(occupant))
			var/mob/living/simple_animal/silly = occupant
			var/datum/component/animal_temperature/temp = silly.GetComponent(/datum/component/animal_temperature)
			if(silly.bodytemperature < temp?.minbodytemp)
				occupantData["temperatureSuitability"] = -3
			else if(silly.bodytemperature > temp?.maxbodytemp)
				occupantData["temperatureSuitability"] = 3
		// Blast you, imperial measurement system
		occupantData["btCelsius"] = occupant.bodytemperature - T0C
		occupantData["btFaren"] = ((occupant.bodytemperature - T0C) * (9.0/5.0))+ 32

		if(ishuman(occupant) && !HAS_TRAIT(occupant, TRAIT_NO_BLOOD))
			var/mob/living/carbon/human/H = occupant
			occupantData["pulse"] = occupant.get_pulse(GETPULSE_TOOL)
			occupantData["hasBlood"] = 1
			occupantData["bloodLevel"] = round(occupant.blood_volume)
			occupantData["bloodMax"] = H.max_blood
			occupantData["bloodPercent"] = round(100*(occupant.blood_volume/H.max_blood), 0.01) //copy pasta ends here

			occupantData["bloodType"] = occupant.dna.blood_type
		if(length(occupant.surgeries))
			occupantData["inSurgery"] = 1
			occupantData["surgeries"] = list()
			for(var/datum/surgery/procedure in occupant.surgeries)
				var/datum/surgery_step/surgery_step = procedure.get_surgery_step()
				var/list/surgery_desc = list("[capitalize(surgery_step.get_step_information(procedure))]")
				if(surgery_step.repeatable)
					var/datum/surgery_step/next = procedure.get_surgery_next_step()
					if(next)
						surgery_desc += " or [capitalize(next.get_step_information(procedure))]"
				var/obj/item/organ/organ
				if(ishuman(occupant))
					var/mob/living/carbon/human/H = occupant
					organ = H.bodyparts_by_name[procedure.location]
				occupantData["surgeries"] += list(list(
					"bodypartName" = capitalize(organ?.name || procedure.location),
					"surgeryName" = capitalize(procedure.name),
					"stepName" = surgery_desc.Join("")
				))

	data["occupant"] = occupantData
	data["verbose"] = verbose
	data["oxyAlarm"] = oxyAlarm
	data["choice"] = choice
	data["health"] = healthAnnounce
	data["crit"] = crit
	data["healthAlarm"] = healthAlarm
	data["oxy"] = oxy

	return data


/obj/machinery/computer/operating/ui_act(action, params)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return

	if((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.set_machine(src)

	. = TRUE
	switch(action)
		if("verboseOn")
			verbose = TRUE
		if("verboseOff")
			verbose = FALSE
		if("healthOn")
			healthAnnounce = TRUE
		if("healthOff")
			healthAnnounce = FALSE
		if("critOn")
			crit = TRUE
		if("critOff")
			crit = FALSE
		if("oxyOn")
			oxy = TRUE
		if("oxyOff")
			oxy = FALSE
		if("oxy_adj")
			oxyAlarm = clamp(text2num(params["new"]), -100, 100)
		if("choiceOn")
			choice = TRUE
		if("choiceOff")
			choice = FALSE
		if("health_adj")
			healthAlarm = clamp(text2num(params["new"]), -100, 100)
		else
			return FALSE

/obj/machinery/computer/operating/process()
	if(!table) //Does this Operating Computer have an Operating Table connected to it?
		return
	if(!verbose) //Are the speakers on?
		return
	if(!table.patient) //Is there a patient on the table?
		currentPatient = null
		return
	var/patientStatus // Tell the computer what to say based on the status of the patient on the table.
	var/isNewPatient = (table.patient != currentPatient) //Is this a new Patient?

	if(table.patient.stat == DEAD || HAS_TRAIT(table.patient, TRAIT_FAKEDEATH))
		patientStatus = "зафиксирована смерть"
	else if(table.patient.stat == CONSCIOUS)
		patientStatus = "в сознании"
	else if(table.patient.stat == UNCONSCIOUS)
		patientStatus = "без сознания"

	if(isNewPatient)
		atom_say("Обнаружен новый пациент, загрузка показаний.")
		var/blood_type_msg
		if(ishuman(table.patient))
			blood_type_msg = table.patient.dna.blood_type
		else
			blood_type_msg = "\[ОШИБКА: НЕИЗВЕСТНО\]"
		atom_say("[table.patient], группа крови [blood_type_msg], [patientStatus].")
		SStgui.update_uis(src)
		patientStatusHolder = table.patient.stat
		currentPatient = table.patient

	if(nextTick < world.time)
		nextTick=world.time + OP_COMPUTER_COOLDOWN
		if(crit && table.patient.health <= -50 )
			playsound(src.loc, 'sound/machines/defib_success.ogg', 50, 0)
		if(oxy && table.patient.getOxyLoss()>oxyAlarm)
			playsound(src.loc, 'sound/machines/defib_saftyoff.ogg', 50, 0)
		if(healthAnnounce && table.patient.health <= healthAlarm)
			atom_say("Оценка здоровья пациента: [round(table.patient.health)] %.")
		if(table.patient.stat != patientStatusHolder)
			atom_say("Состояние пациента: [patientStatus].")
			patientStatusHolder = table.patient.stat

/obj/machinery/computer/operating/old_frame
	icon = 'icons/obj/machines/computer3.dmi'
	icon_screen = "med_oldframe"
	icon_state = "frame-med"
	icon_keyboard = "kb5"
