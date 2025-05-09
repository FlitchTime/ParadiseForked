/datum/reagent/medicine
	name = "Медицина"
	id = "medicine"
	taste_description = "горечи"
	harmless = TRUE

/datum/reagent/medicine/on_mob_life(mob/living/M)
	current_cycle++
	var/total_depletion_rate = (metabolization_rate / M.metabolism_efficiency) * M.digestion_ratio // Cache it

	handle_addiction(M, total_depletion_rate)
	sate_addiction(M)
	holder.remove_reagent(id, total_depletion_rate) //medicine reagents stay longer if you have a better metabolism
	return STATUS_UPDATE_NONE

/datum/reagent/medicine/hydrocodone
	name = "Гидрокодон"
	id = "hydrocodone"
	description = "Чрезвычайно эффективное болеутоляющее средство; может иметь долгосрочные последствия злоупотребления."
	reagent_state = LIQUID
	color = "#C805DC"
	metabolization_rate = 0.75 * REAGENTS_METABOLISM // Lasts 1.5 minutes for 15 units
	shock_reduction = 200
	taste_description = "онемения во рту"

/datum/reagent/medicine/hydrocodone/on_mob_life(mob/living/M) //Needed so the hud updates when injested / removed from system
	var/update_flags = STATUS_UPDATE_HEALTH
	return ..() | update_flags

/datum/reagent/medicine/sterilizine
	name = "Стерилизин"
	id = "sterilizine"
	description = "Стерилизует раны для подготовки к операции."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	taste_description = "антисептика"

	//makes you squeaky clean
/datum/reagent/medicine/sterilizine/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_TOUCH)
		M.germ_level -= min(volume*20, M.germ_level)

/datum/reagent/medicine/sterilizine/reaction_obj(obj/O, volume)
	O.germ_level -= min(volume*20, O.germ_level)

/datum/reagent/medicine/sterilizine/reaction_turf(turf/T, volume)
	T.germ_level -= min(volume*20, T.germ_level)

/datum/reagent/medicine/synaptizine
	name = "Синаптизин"
	id = "synaptizine"
	description = "Синаптизин используется для лечения нейролептического шока. Может использоваться для устранения инвалидизирующих симптомов, таких как паралич."
	reagent_state = LIQUID
	color = "#FA46FA"
	overdose_threshold = 40
	harmless = FALSE
	taste_description = "бодрости"

/datum/reagent/medicine/synaptizine/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustDrowsy(-10 SECONDS)
	M.AdjustParalysis(-2 SECONDS)
	M.AdjustStunned(-2 SECONDS)
	M.AdjustWeakened(-2 SECONDS)
	M.SetSleeping(0)
	update_flags |= M.adjustStaminaLoss(-8, FALSE)
	if(prob(50))
		update_flags |= M.adjustBrainLoss(-1, FALSE)
	return ..() | update_flags

/datum/reagent/medicine/synaptizine/overdose_process(mob/living/M, severity)
	var/list/overdose_info = ..()
	var/effect = overdose_info[REAGENT_OVERDOSE_EFFECT]
	var/update_flags = overdose_info[REAGENT_OVERDOSE_FLAGS]
	if(severity == 1)
		if(effect <= 1)
			M.visible_message(span_warning("[M] блю[pluralize_ru(M.gender, "ёт", "ют")]!"))
			M.fakevomit(no_text = 1)
		else if(effect <= 3)
			M.emote(pick("groan","moan"))
		if(effect <= 8)
			update_flags |= M.adjustToxLoss(1, FALSE)
	else if(severity == 2)
		if(effect <= 2)
			M.visible_message(span_warning("[M] блю[pluralize_ru(M.gender, "ёт", "ют")]!"))
			M.fakevomit(no_text = 1)
		else if(effect <= 5)
			M.visible_message(span_warning("[M] пошатыва[pluralize_ru(M.gender, "ет", "ют")]ся и пуска[pluralize_ru(M.gender, "ет", "ют")] слюни. Из [genderize_ru(M.gender, "его", "её", "его", "их")] глаз течёт кровь!"))
			M.Dizzy(16 SECONDS)
			M.Weaken(8 SECONDS)
		if(effect <= 15)
			update_flags |= M.adjustToxLoss(1, FALSE)
	return list(effect, update_flags)

/datum/reagent/medicine/mitocholide
	name = "Митоколид"
	id = "mitocholide"
	description = "Специализированный препарат, стимулирующий митохондрии клеток для заживления внутренних органов."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	taste_description = "горечи"

/datum/reagent/medicine/mitocholide/on_mob_life(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M

		//Mitocholide is hard enough to get, it's probably fair to make this all internal organs
		for(var/obj/item/organ/internal/organ as anything in H.internal_organs)
			organ.unnecrotize()
			organ.heal_internal_damage(0.4)
	return ..()

/datum/reagent/medicine/mitocholide/reaction_obj(obj/O, volume)
	if(istype(O, /obj/item/organ))
		var/obj/item/organ/Org = O
		if(!Org.is_robotic())
			Org.rejuvenate()

/datum/reagent/medicine/cryoxadone
	data = list("diseases" = null)
	name = "Криоксадон"
	id = "cryoxadone"
	description = "Плазменная смесь, обладающая почти магической целительной силой. Его главное ограничение - температура тела субъекта должна быть ниже 265 К, чтобы он мог правильно метаболизироваться."
	reagent_state = LIQUID
	color = "#0000C8" // rgb: 200, 165, 220
	heart_rate_decrease = 1
	taste_description = "холодящей горечи"

/datum/reagent/medicine/cryoxadone/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(data && data["diseases"])
		for(var/datum/disease/virus/V in data["diseases"])

			if(V.spread_flags < BLOOD)
				continue

			if(method == REAGENT_TOUCH)
				V.Contract(M, need_protection_check = TRUE, act_type = CONTACT)
			else
				V.Contract(M, need_protection_check = FALSE)

	if(method == REAGENT_INGEST && iscarbon(M))
		var/mob/living/carbon/C = M
		if(C.get_blood_id() == id && !HAS_TRAIT(C, TRAIT_NO_BLOOD_RESTORE))
			C.setBlood(min(C.blood_volume + round(volume, 0.1), BLOOD_VOLUME_NORMAL))
			C.reagents.del_reagent(id)

/datum/reagent/medicine/cryoxadone/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(iscarbon(M) && M.bodytemperature < TCRYO)
		update_flags |= M.adjustCloneLoss(-1, FALSE)
		update_flags |= M.adjustOxyLoss(-2, FALSE)
		update_flags |= M.adjustToxLoss(-0.5, FALSE)
		update_flags |= M.adjustBruteLoss(-2, FALSE, affect_robotic = FALSE)
		update_flags |= M.adjustFireLoss(-4, FALSE, affect_robotic = FALSE)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/organ/external/head/head = H.get_organ(BODY_ZONE_HEAD)
			head?.undisfigure()
	return ..() | update_flags

/datum/reagent/medicine/cryoxadone/on_merge(list/mix_data)
	merge_diseases_data(mix_data)

/datum/reagent/medicine/cryoxadone/reaction_turf(turf/T, volume, color)
	if(volume >= 3 && !isspaceturf(T) && !locate(/obj/effect/decal/cleanable/blood/drask) in T)
		var/obj/effect/decal/cleanable/blood/drask/new_blood = new(T)
		new_blood.basecolor = color
		new_blood.update_icon()

/datum/reagent/medicine/rezadone
	name = "Резадон"
	id = "rezadone"
	description = "Порошок, полученный из рыбьего токсина. Резадон может эффективно лечить генетические повреждения, а также восстанавливать мелкие раны. Передозировка вызывает сильную тошноту и отравление."
	reagent_state = SOLID
	color = "#669900" // rgb: 102, 153, 0
	overdose_threshold = 30
	harmless = FALSE
	taste_description = "обновления"

/datum/reagent/medicine/rezadone/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustCloneLoss(-5, FALSE) //What? We just set cloneloss to 0. Why? Simple; this is so external organs properly unmutate. // why don't you fix the code instead // i fix the code dont worry
	update_flags |= M.adjustBruteLoss(-1, FALSE, affect_robotic = FALSE)
	update_flags |= M.adjustFireLoss(-1, FALSE, affect_robotic = FALSE)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/head/head = H.get_organ(BODY_ZONE_HEAD)
		head?.undisfigure()
	return ..() | update_flags

/datum/reagent/medicine/rezadone/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(1, FALSE)
	M.Dizzy(10 SECONDS)
	M.Jitter(10 SECONDS)
	return list(0, update_flags)

/datum/reagent/medicine/spaceacillin
	name = "Космоциллин"
	id = "spaceacillin"
	description = "Универсальный антибиотик, получаемый из космической плесени."
	reagent_state = LIQUID
	color = "#0AB478"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	taste_description = "антибиотиков"

/datum/reagent/medicine/spaceacillin/on_mob_life(mob/living/M)
	var/list/organs_list = list()
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		organs_list += C.internal_organs

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		organs_list += H.bodyparts

	for(var/obj/item/organ/organ as anything in organs_list)
		if(organ.germ_level < INFECTION_LEVEL_ONE)
			organ.germ_level = 0	//cure instantly
		else if(organ.germ_level < INFECTION_LEVEL_TWO)
			organ.germ_level = max(M.germ_level - 25, 0)	//at germ_level == 500, this should cure the infection in 34 seconds
		else
			organ.germ_level = max(M.germ_level - 10, 0)	// at germ_level == 1000, this will cure the infection in 1 minutes, 14 seconds

	organs_list.Cut()
	M.germ_level = max(M.germ_level - 20, 0) // Reduces the mobs germ level, too
	return ..()

/datum/reagent/medicine/silver_sulfadiazine
	name = "Сульфадиазин серебра"
	id = "silver_sulfadiazine"
	description = "Это антибактериальное соединение используется для лечения пострадавших от ожогов."
	reagent_state = LIQUID
	color = "#F0DC00"
	metabolization_rate = 7.5 * REAGENTS_METABOLISM
	harmless = FALSE	//toxic if ingested, and I am NOT going to account for the difference
	taste_description = "мази от ожогов"

/datum/reagent/medicine/silver_sulfadiazine/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.heal_damage_type(1, BURN, updating_health = FALSE)
	return ..() | update_flags

/datum/reagent/medicine/silver_sulfadiazine/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume, show_message = 1)
	if(iscarbon(M))
		if(method == REAGENT_TOUCH)
			if(M.heal_damage_type(volume, BURN) && show_message)
				to_chat(M, span_notice("Сульфадиазин серебра заживляет ваши ожоги."))
		if(method == REAGENT_INGEST)
			if(M.apply_damage(0.5 * volume, TOX) && show_message)
				to_chat(M, span_warning("Вас подташнивает..."))
	..()

/datum/reagent/medicine/styptic_powder
	name = "Кровоостанавливающая пудра"
	id = "styptic_powder"
	description = "Кровоостанавливающий порошок (сульфат алюминия), который помогает остановить кровотечение и заживить физические раны."
	reagent_state = LIQUID
	color = "#FF9696"
	metabolization_rate = 7.5 * REAGENTS_METABOLISM
	harmless = FALSE
	taste_description = "мази от порезов"

/datum/reagent/medicine/styptic_powder/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.heal_damage_type(1, BRUTE, updating_health = FALSE)
	return ..() | update_flags

/datum/reagent/medicine/styptic_powder/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume, show_message = 1)
	if(iscarbon(M))
		if(method == REAGENT_TOUCH)
			if(M.heal_damage_type(volume, BRUTE) && show_message && M.has_pain())
				to_chat(M, span_notice("Кровоостанавливающая пудра заживляет ваши раны. Как же щиплет!"))
		else if(method == REAGENT_INGEST)
			if(M.apply_damage(0.5 * volume, TOX) && show_message)
				to_chat(M, span_warning("Вас подташнивает..."))
	..()

/datum/reagent/medicine/salglu_solution
	name = "Физиологический раствор"
	id = "salglu_solution"
	description = "Этот раствор соли и глюкозы помогает стабилизировать состояние тяжелораненых пациентов и очистить раны."
	reagent_state = LIQUID
	color = "#C8A5DC"
	penetrates_skin = TRUE
	metabolization_rate = 0.75 * REAGENTS_METABOLISM
	taste_description = "солёной воды"

/datum/reagent/medicine/salglu_solution/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(33))
		update_flags |= M.adjustBruteLoss(-1, FALSE, affect_robotic = FALSE)
		update_flags |= M.adjustFireLoss(-1, FALSE, affect_robotic = FALSE)
	if(ishuman(M) && prob(33))
		var/mob/living/carbon/human/H = M
		//do not restore blood on things with no blood by nature.
		if(!HAS_TRAIT(H, TRAIT_NO_BLOOD) && !HAS_TRAIT(H, TRAIT_NO_BLOOD_RESTORE) && H.blood_volume < BLOOD_VOLUME_NORMAL)
			H.AdjustBlood(1)

	return ..() | update_flags

/datum/reagent/medicine/synthflesh
	name = "Синт-плоть"
	id = "synthflesh"
	description = "Резорбируемая смесь микрофибриллярного коллагена и белков, способная быстро заживлять повреждения при местном применении."
	reagent_state = LIQUID
	color = "#FFEBEB"
	taste_description = "крови"

/datum/reagent/medicine/synthflesh/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume, show_message = 1)
	if(iscarbon(M))
		if(method == REAGENT_TOUCH)
			var/heal_amount = 1.5 * volume
			M.heal_overall_damage(heal_amount, heal_amount)
			if(show_message)
				to_chat(M, span_notice("Синт-плоть начинает сращиваться с вашей кожей, заживляя раны."))
	..()

/datum/reagent/medicine/synthflesh/reaction_turf(turf/T, volume) //let's make a mess!
	if(volume >= 5 && !isspaceturf(T))
		new /obj/effect/decal/cleanable/blood/gibs/cleangibs(T)
		playsound(T, 'sound/effects/splat.ogg', 50, 1, -3)

/datum/reagent/medicine/ab_stimulant
	name = "Анти-ожоговый стимулянт"
	id = "antiburn_stimulant"
	description = "Стимулятор регенеративных способностей клеток, способный излечить обугленную кожу в кратчайшие сроки."
	reagent_state = LIQUID
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 3
	color = "#fab9b9"
	taste_description = "горечи"

/datum/reagent/medicine/ab_stimulant/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	to_chat(M, span_notice("Ваша кожа чешется."))
	update_flags |= M.adjustFireLoss(-1.5, FALSE, affect_robotic = FALSE)
	if(volume > 1.9)
		if(HAS_TRAIT(M, TRAIT_HUSK))
			var/mob/living/carbon/human/H = M
			H.cure_husk()
			to_chat(M, span_warning("Ваша обугленная кожа отпадает!"))
	return ..() | update_flags

/datum/reagent/medicine/ab_stimulant/overdose_process(mob/living/M, severity)
	to_chat(M, span_warning("Ваша кожа лопается!"))
	var/update = NONE
	update |= M.apply_damage(4, BRUTE, spread_damage = TRUE, updating_health = FALSE)
	update |= M.heal_damage_type(6, BURN, updating_health = FALSE)
	if(update)
		M.updatehealth()
	if(prob(25) && ishuman(M) && !HAS_TRAIT(M, TRAIT_NO_BLOOD))
		var/mob/living/carbon/human/H = M
		H.bleed(20)
	return ..()

/datum/reagent/medicine/charcoal
	name = "Активированный уголь"
	id = "charcoal"
	description = "Активированный уголь поглощает токсины."
	reagent_state = LIQUID
	color = "#000000"
	taste_description = "пыли"

/datum/reagent/medicine/charcoal/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(-0.75, FALSE)
	if(prob(50))
		for(var/datum/reagent/R in M.reagents.reagent_list)
			if(R != src)
				M.reagents.remove_reagent(R.id,1)
	return ..() | update_flags

/datum/reagent/medicine/coaltree_extract
	name = "Экстракт Угледрева"
	id = "coaltree_extract"
	description = "Экстракт, полученный из угледрева. Выводит из организма вредные токсины, но имеет ряд побочных эффектов."
	reagent_state = LIQUID
	metabolization_rate = 0.4 * REAGENTS_METABOLISM
	color = "#000000"
	taste_description = "пепла"

/datum/reagent/medicine/coaltree_extract/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(-3, FALSE)
	update_flags |= M.adjustBruteLoss(1, FALSE)
	if(prob(10))
		to_chat(M, span_warning("Ваша кожа покрывается кровавыми волдырями."))
	if(prob(50))
		for(var/datum/reagent/R in M.reagents.reagent_list)
			if(R != src)
				M.reagents.remove_reagent(R.id,1)
	return ..() | update_flags

/datum/reagent/medicine/omnizine
	name = "Омнизин"
	id = "omnizine"
	description = "Омнизин - это высокоэффективный лечебный препарат, который можно использовать для лечения широкого спектра травм."
	reagent_state = LIQUID
	color = "#C8A5DC"
	overdose_threshold = 30
	addiction_chance = 3
	addiction_chance_additional = 20
	addiction_threshold = 5
	harmless = FALSE
	taste_description = "горько-сладкого лекарства"

/datum/reagent/medicine/omnizine/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(-0.5, FALSE)
	update_flags |= M.adjustOxyLoss(-0.5, FALSE)
	update_flags |= M.adjustBruteLoss(-1, FALSE, affect_robotic = FALSE)
	update_flags |= M.adjustFireLoss(-1, FALSE, affect_robotic = FALSE)
	if(prob(50))
		M.AdjustLoseBreath(-2 SECONDS)
	return ..() | update_flags

/datum/reagent/medicine/omnizine/overdose_process(mob/living/M, severity)
	if(HAS_TRAIT(M, TRAIT_BADASS))
		return
	var/list/overdose_info = ..()
	var/effect = overdose_info[REAGENT_OVERDOSE_EFFECT]
	var/update_flags = overdose_info[REAGENT_OVERDOSE_FLAGS]
	if(severity == 1) //lesser
		M.AdjustStuttering(2 SECONDS)
		if(effect <= 1)
			M.visible_message(span_warning("[M] хвата[pluralize_ru(M.gender, "ет", "ют")]ся за живот от боли!"))
			M.emote("scream")
			M.Weaken(8 SECONDS)
		else if(effect <= 3)
			M.visible_message(span_warning("[M] на мгновение теря[pluralize_ru(M.gender, "ет", "ют")] сознание!"))
			M.AdjustConfused(30 SECONDS)
		else if(effect <= 5)
			M.visible_message(span_warning("[M] спотыка[pluralize_ru(M.gender, "ет", "ют")]ся и едва не падает!"))
			M.Dizzy(10 SECONDS)
			M.Weaken(6 SECONDS)
		else if(effect <= 7)
			M.visible_message(span_warning("[M] тряс[pluralize_ru(M.gender, "ёт", "ют")]ся!"))
			M.Jitter(60 SECONDS)
	else if(severity == 2) // greater
		if(effect <= 2)
			M.visible_message(span_warning("[M] хвата[pluralize_ru(M.gender, "ет", "ют")]ся за живот от боли!"))
			M.emote("scream")
			M.Weaken(14 SECONDS)
		else if(effect <= 5)
			M.visible_message(span_warning("[M] резко дёрга[pluralize_ru(M.gender, "ет", "ют")]ся и падает!"))
			M.Paralyse(10 SECONDS)
			M.Weaken(8 SECONDS)
		else if(effect <= 8)
			M.visible_message(span_warning("[M] пошатыва[pluralize_ru(M.gender, "ет", "ют")]ся из стороны в сторону!"))
			M.Dizzy(10 SECONDS)
			M.Weaken(6 SECONDS)
	return list(effect, update_flags)

/datum/reagent/medicine/calomel
	name = "Каломель"
	id = "calomel"
	description = "Это мощное чистящее средство избавляет организм от нечистот. Однако он очень токсичен, поэтому необходим тщательный контроль."
	reagent_state = LIQUID
	color = "#22AB35"
	metabolization_rate = 2 * REAGENTS_METABOLISM
	harmless = FALSE
	taste_description = "болезненного очищение"

/datum/reagent/medicine/calomel/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(R != src)
			M.reagents.remove_reagent(R.id,5)
	if(M.health > 20)
		update_flags |= M.adjustToxLoss(2.5, FALSE)
	if(prob(6))
		M.fakevomit()
	return ..() | update_flags

/datum/reagent/medicine/potass_iodide
	name = "Йодид калия"
	id = "potass_iodide"
	description = "Йодид калия - лекарственный препарат, используемый для борьбы с последствиями радиационного отравления."
	reagent_state = LIQUID
	color = "#B4DCBE"
	taste_description = "очищения"

/datum/reagent/medicine/potass_iodide/on_mob_life(mob/living/M)
	if(prob(80))
		M.radiation = max(0, M.radiation-1)
	return ..()

/datum/reagent/medicine/pen_acid
	name = "Пентетовая кислота"
	id = "pen_acid"
	description = "Диэтилентриаминпентаацетат (сокращённо \"пентетовая кислота\" или \"ДТПА\") - агрессивный хелатирующий агент. Может вызвать повреждение тканей. Используйте с осторожностью."
	reagent_state = LIQUID
	color = "#C8A5DC"
	harmless = FALSE
	taste_description = "очищения"

/datum/reagent/medicine/pen_acid/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(R != src)
			M.reagents.remove_reagent(R.id,4)
	M.radiation = max(0, M.radiation-7)
	if(prob(75))
		update_flags |= M.adjustToxLoss(-2, FALSE)
	if(prob(33))
		if(ishuman(M))
			var/mob/living/carbon/human/human = M
			human.take_overall_damage(0.5, 0.5, updating_health = FALSE, affect_robotic = FALSE)
		else
			update_flags |= M.adjustBruteLoss(0.5, FALSE)
			update_flags |= M.adjustFireLoss(0.5, FALSE)

	return ..() | update_flags

/datum/reagent/medicine/sal_acid
	name = "Салициловая кислота"
	id = "sal_acid"
	description = "Это стандартное обезболивающее и жаропонижающее средство."
	reagent_state = LIQUID
	color = "#B54848"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	shock_reduction = 25
	overdose_threshold = 25
	harmless = FALSE
	taste_description = "облегчения"

/datum/reagent/medicine/sal_acid/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(55))
		update_flags |= M.adjustBruteLoss(-1, FALSE, affect_robotic = FALSE)
	if(M.bodytemperature > BODYTEMP_NORMAL)
		M.adjust_bodytemperature(-10)
	return ..() | update_flags

/datum/reagent/medicine/menthol
	name = "Ментол"
	id = "menthol"
	description = "Ментол снимает ожоги и боль, обеспечивая ощущение прохлады."
	reagent_state = LIQUID
	color = "#F0F9CA"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	taste_description = "успокоения"

/datum/reagent/medicine/menthol/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(55))
		update_flags |= M.adjustFireLoss(-1, FALSE, affect_robotic = FALSE)
	if(M.bodytemperature > 280)
		M.adjust_bodytemperature(-10)
	return ..() | update_flags

/datum/reagent/medicine/salbutamol
	name = "Сальбутамол"
	id = "salbutamol"
	description = "Сальбутамол - распространенное бронхорасширяющее лекарство для астматиков. Он может помочь и при других проблемах с дыханием."
	reagent_state = LIQUID
	color = "#00FFFF"
	taste_description = "свежего воздуха"

/datum/reagent/medicine/salbutamol/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustOxyLoss(-3, FALSE)
	M.AdjustLoseBreath(-8 SECONDS)
	return ..() | update_flags

/datum/reagent/medicine/perfluorodecalin
	name = "Перфтордекалин"
	id = "perfluorodecalin"
	description = "Этот экспериментальный перфторированный растворитель находит применение в жидкостном дыхании и оксигенации тканей. Использовать с осторожностью."
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	addiction_chance = 1
	addiction_chance_additional = 20
	addiction_threshold = 10
	harmless = FALSE
	taste_description = "оксигенации"

/datum/reagent/medicine/perfluorodecalin/on_mob_life(mob/living/carbon/human/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustOxyLoss(-12.5, FALSE)
	if(volume >= 4)
		M.LoseBreath(12 SECONDS)
	if(prob(33))
		update_flags |= M.adjustBruteLoss(-0.5, FALSE, affect_robotic = FALSE)
		update_flags |= M.adjustFireLoss(-0.5, FALSE, affect_robotic = FALSE)
	return ..() | update_flags

/datum/reagent/medicine/ephedrine
	name = "Эфедрин"
	id = "ephedrine"
	description = "Эфедрин - это стимулятор растительного происхождения."
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 0.75 * REAGENTS_METABOLISM
	overdose_threshold = 35
	addiction_chance = 1
	addiction_chance_additional = 10
	addiction_threshold = 10
	harmless = FALSE
	taste_description = "стимуляции"

/datum/reagent/medicine/ephedrine/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustDrowsy(-10 SECONDS)
	M.AdjustParalysis(-2 SECONDS)
	M.AdjustStunned(-2 SECONDS)
	M.AdjustWeakened(-2 SECONDS)
	update_flags |= M.adjustStaminaLoss(-1.5, FALSE)
	M.AdjustLoseBreath(-2 SECONDS, bound_lower = 10 SECONDS)
	if(M.getOxyLoss() > 75)
		update_flags |= M.adjustOxyLoss(-1, FALSE)
	if(M.health < 0 || M.health > 0 && prob(33))
		update_flags |= M.adjustToxLoss(-1, FALSE)
		update_flags |= M.adjustBruteLoss(-1, FALSE, affect_robotic = FALSE)
		update_flags |= M.adjustFireLoss(-1, FALSE, affect_robotic = FALSE)
	return ..() | update_flags

/datum/reagent/medicine/ephedrine/overdose_process(mob/living/M, severity)
	var/list/overdose_info = ..()
	var/effect = overdose_info[REAGENT_OVERDOSE_EFFECT]
	var/update_flags = overdose_info[REAGENT_OVERDOSE_FLAGS]
	if(severity == 1)
		if(effect <= 1)
			M.visible_message(span_warning("[M] блю[pluralize_ru(M.gender, "ёт", "ют")]!"))
			M.fakevomit(no_text = 1)
		else if(effect <= 3)
			M.emote(pick("groan","moan"))
		if(effect <= 8)
			M.emote("collapse")
	else if(severity == 2)
		if(effect <= 2)
			M.visible_message(span_warning("[M] блю[pluralize_ru(M.gender, "ёт", "ют")]!"))
			M.fakevomit(no_text = 1)
		else if(effect <= 5)
			M.visible_message(span_warning("[M] пошатыва[pluralize_ru(M.gender, "ет", "ют")]ся и пуска[pluralize_ru(M.gender, "ет", "ют")] слюни. Из [genderize_ru(M.gender, "его", "её", "его", "их")] глаз течёт кровь!"))
			M.Dizzy(4 SECONDS)
			M.Weaken(6 SECONDS)
		if(effect <= 15)
			M.emote("collapse")
	return list(effect, update_flags)

/datum/reagent/medicine/diphenhydramine
	name = "Дифенгидрамин"
	id = "diphenhydramine"
	description = "Противоаллергические препараты. Может вызывать сонливость, не работайте с тяжелыми механизмами при использовании этого препарата."
	reagent_state = LIQUID
	color = "#5BCBE1"
	addiction_chance = 1
	addiction_threshold = 10
	harmless = FALSE
	taste_description = "антигистамина"

/datum/reagent/medicine/diphenhydramine/on_mob_life(mob/living/M)
	M.AdjustJitter(-40 SECONDS)
	M.reagents.remove_reagent("histamine",3)
	M.reagents.remove_reagent("itching_powder",3)
	if(prob(7))
		M.emote("yawn")
	if(prob(3))

		M.AdjustDrowsy(2 SECONDS)
		M.visible_message(span_notice("[M] выгляд[pluralize_ru(M.gender, "ит вялым", "ят вялыми")]."))
	return ..()

/datum/reagent/medicine/morphine
	name = "Морфин"
	id = "morphine"
	description = "Сильное, но вызывающее сильное привыкание опиатное болеутоляющее средство с седативными побочными эффектами."
	reagent_state = LIQUID
	color = "#C8A5DC"
	overdose_threshold = 20
	addiction_chance = 10
	addiction_threshold = 15
	shock_reduction = 50
	harmless = FALSE
	taste_description = "приятного оцепенения"


/datum/reagent/medicine/morphine/on_mob_add(mob/living/M)
	. = ..()
	if(isslime(M))
		M.add_movespeed_modifier(/datum/movespeed_modifier/slime_morphine_mod)


/datum/reagent/medicine/morphine/on_mob_delete(mob/living/M)
	. = ..()
	M.remove_movespeed_modifier(/datum/movespeed_modifier/slime_morphine_mod)


/datum/reagent/medicine/morphine/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustJitter(-50 SECONDS)
	switch(current_cycle)
		if(1 to 15)
			if(prob(7))
				M.emote("yawn")
		if(16 to 35)
			M.Drowsy(40 SECONDS)
		if(36 to INFINITY)
			M.Paralyse(30 SECONDS)
			M.Drowsy(40 SECONDS)
	return ..() | update_flags

/datum/reagent/medicine/morphine/syntmorphine
	name = "Синт-морфин"
	id = "syntmorphine"

/datum/reagent/medicine/oculine
	name = "Окулин"
	id = "oculine"
	description = "Окулин - это солевой глазной препарат с мидриатическим и антибиотическим действием."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "ясности"

/datum/reagent/medicine/oculine/on_mob_life(mob/living/M)
	if(prob(80))
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			var/obj/item/organ/internal/eyes/eyes = C.get_int_organ(/obj/item/organ/internal/eyes)
			if(eyes && !eyes.is_dead())
				eyes.heal_internal_damage(1)
				M.AdjustEyeBlurry(-2 SECONDS)
			var/obj/item/organ/internal/ears/ears = C.get_int_organ(/obj/item/organ/internal/ears)
			if(ears && !ears.is_dead())
				ears.heal_internal_damage(1)
				if(ears.damage < 25 && prob(30))
					C.SetDeaf(0)
		else
			M.AdjustEyeBlurry(-2 SECONDS)
	return ..()

/datum/reagent/medicine/atropine
	name = "Атропин"
	id = "atropine"
	description = "Атропин - мощный сердечный реаниматор, но он может вызвать спутанность сознания, головокружение и гипертермию."
	reagent_state = LIQUID
	color = "#000000"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 25
	harmless = FALSE
	taste_description = "передышки"

/datum/reagent/medicine/atropine/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustDizzy(2 SECONDS)
	M.Confused(10 SECONDS)
	if(prob(4))
		M.emote("collapse")
	M.AdjustLoseBreath(-10 SECONDS, bound_lower = 10 SECONDS)
	if(M.getOxyLoss() > 65)
		update_flags |= M.adjustOxyLoss(-5, FALSE)
	if(M.health < -25)
		update_flags |= M.adjustToxLoss(-1, FALSE)
		update_flags |= M.adjustBruteLoss(-1.5, FALSE, affect_robotic = FALSE)
		update_flags |= M.adjustFireLoss(-1.5, FALSE, affect_robotic = FALSE)
	else if(M.health > -60)
		update_flags |= M.adjustToxLoss(1, FALSE)
	M.reagents.remove_reagent("sarin", 20)
	return ..() | update_flags

/datum/reagent/medicine/epinephrine
	name = "Эпинефрин"
	id = "epinephrine"
	description = "Эпинефрин - мощный нейротрансмиттер, используемый в экстренных медицинских ситуациях для купирования анафилактического шока и предотвращения остановки сердца."
	reagent_state = LIQUID
	color = "#96B1AE"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 20
	harmless = FALSE
	taste_description = "выигранного времени"

/datum/reagent/medicine/epinephrine/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustDrowsy(-10 SECONDS)
	if(prob(20))
		M.AdjustParalysis(-2 SECONDS)
	if(prob(20))
		M.AdjustStunned(-2 SECONDS)
	if(prob(20))
		M.AdjustWeakened(-2 SECONDS)
	if(prob(5))
		M.SetSleeping(0)
	if(prob(5))
		update_flags |= M.adjustBrainLoss(-1, FALSE)
	holder.remove_reagent("histamine", 15)
	M.AdjustLoseBreath(-2 SECONDS, bound_lower = 6 SECONDS)
	if(M.getOxyLoss() > 35)
		update_flags |= M.adjustOxyLoss(-5, FALSE)
	if(M.health < -10 && M.health > -65)
		update_flags |= M.adjustToxLoss(-0.5, FALSE)
		update_flags |= M.adjustBruteLoss(-0.5, FALSE, affect_robotic = FALSE)
		update_flags |= M.adjustFireLoss(-0.5, FALSE, affect_robotic = FALSE)
	return ..() | update_flags

/datum/reagent/medicine/epinephrine/overdose_process(mob/living/M, severity)
	var/list/overdose_info = ..()
	var/effect = overdose_info[REAGENT_OVERDOSE_EFFECT]
	var/update_flags = overdose_info[REAGENT_OVERDOSE_FLAGS]
	if(severity == 1)
		if(effect <= 1)
			M.visible_message(span_warning("[M] блю[pluralize_ru(M.gender, "ёт", "ют")]!"))
			M.fakevomit(no_text = 1)
		else if(effect <= 3)
			M.emote(pick("groan","moan"))
		if(effect <= 8)
			M.emote("collapse")
	else if(severity == 2)
		if(effect <= 2)
			M.visible_message(span_warning("[M] блю[pluralize_ru(M.gender, "ёт", "ют")]!"))
			M.fakevomit(no_text = 1)
		else if(effect <= 5)
			M.visible_message(span_warning("[M] пошатыва[pluralize_ru(M.gender, "ет", "ют")]ся и пуска[pluralize_ru(M.gender, "ет", "ют")] слюни. Из [genderize_ru(M.gender, "его", "её", "его", "их")] глаз течёт кровь!"))
			M.Dizzy(4 SECONDS)
			M.Weaken(6 SECONDS)
		if(effect <= 15)
			M.emote("collapse")
	return list(effect, update_flags)

/datum/reagent/medicine/strange_reagent
	name = "Странный реагент"
	id = "strange_reagent"
	description = "Светящаяся зелёная жидкость, очень напоминающая ядерные отходы."
	reagent_state = LIQUID
	color = "#A0E85E"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	taste_description = "жизни"
	harmless = FALSE
	var/revive_type = SENTIENCE_ORGANIC //So you can't revive boss monsters or robots with it

/datum/reagent/medicine/strange_reagent/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(10))
		update_flags |= M.adjustBruteLoss(1, FALSE)
		update_flags |= M.adjustToxLoss(1, FALSE)
	return ..() | update_flags

/datum/reagent/medicine/strange_reagent/reaction_mob(mob/living/M, method = REAGENT_TOUCH, volume)
	if(volume < 1)
		// gotta pay to play
		return ..()
	if(isanimal(M) && method == REAGENT_TOUCH)
		var/mob/living/simple_animal/SM = M
		if(SM.sentience_type != revive_type) // No reviving Ash Drakes for you
			return
		if(SM.stat == DEAD)
			SM.revive()
			SM.loot.Cut() //no abusing strange reagent for farming unlimited resources
			SM.visible_message(span_warning("[SM] ожива[pluralize_ru(SM.gender, "ет", "ют")]!"))

	if(iscarbon(M))
		if(method == REAGENT_INGEST || (method == REAGENT_TOUCH && prob(25)))
			if(M.stat == DEAD)
				if(M.getBruteLoss() + M.getFireLoss() + M.getCloneLoss() >= 150)
					add_attack_logs(M, M, "delay gib by [name]")
					M.delayed_gib()
					return
				if(!M.ghost_can_reenter())
					M.visible_message(span_warning("[M] слегка вздрагива[pluralize_ru(M.gender, "ет", "ют")], но в остальном не реагиру[pluralize_ru(M.gender, "ет", "ют")]!"))
					return
				if(!M.suiciding && !HAS_TRAIT(M, TRAIT_NO_CLONE) && (!M.mind || M.mind?.is_revivable()))
					var/time_dead = world.time - M.timeofdeath
					M.visible_message(span_warning("[M] ожива[pluralize_ru(M.gender, "ет", "ют")]!"))
					var/update = NONE
					update |= M.take_overall_damage(rand(0, 15), rand(0, 15), updating_health = FALSE)
					update |= M.apply_damages(tox = rand(0, 15), clone = 50, updating_health = FALSE)
					update |= M.setOxyLoss(0, updating_health = FALSE)
					if(update)
						M.updatehealth()
					if(ishuman(M))
						var/mob/living/carbon/human/H = M
						var/necrosis_prob = 40 * min((20 MINUTES), max((time_dead - (1 MINUTES)), 0)) / ((20 MINUTES) - (1 MINUTES))
						for(var/obj/item/organ/organ as anything in (H.bodyparts|H.internal_organs))
							// Per non-vital body part:
							// 0% chance of necrosis within 1 minute of death
							// 40% chance of necrosis after 20 minutes of death
							if(!organ.vital && prob(necrosis_prob))
								// side effects may include: Organ failure
								if(organ.necrotize())
									organ.germ_level = INFECTION_LEVEL_THREE
						H.update_body()

					M.update_revive(TRUE, TRUE)
					M.grab_ghost()
					add_attack_logs(M, M, "Revived with strange reagent") //Yes, the logs say you revived yourself.
	..()

/datum/reagent/medicine/mannitol
	name = "Маннитол"
	id = "mannitol"
	description = "Маннитол - это сахарный спирт, который может восстановить повреждённые ткани мозга."
	color = "#D1D1F1"
	taste_description = "сладкого спирта"

/datum/reagent/medicine/mannitol/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(M.getBrainLoss() <= 100)
		update_flags |= M.adjustBrainLoss(-3, FALSE)
	return ..() | update_flags

/datum/reagent/medicine/fomepizole
	name = "Фомепизол"
	id = "fomepizole"
	description = "Фомепизол является конкурентным ингибитором АДГ. Он используется для блокировки метаболизма этанола до его токсичных метаболитов."
	color = "#95bb72"
	taste_description = "адекватности"

/datum/reagent/medicine/fomepizole/on_mob_life(mob/living/M)
	M.AdjustDizzy(-120 SECONDS)
	M.AdjustJitter(-20 SECONDS)
	return ..()

/datum/reagent/medicine/mutadone
	name = "Мутадон"
	id = "mutadone"
	description = "Мутадон - это экспериментальный бромид, который может лечить генетические аномалии."
	color = "#5096C8"
	taste_description = "очищения"


/datum/reagent/medicine/mutadone/on_mob_life(mob/living/carbon/human/M)
	if(M.mind && M.mind.assigned_role == "Cluwne") // HUNKE
		return ..()

	M.SetJitter(0)

	if(!ishuman(M))
		return ..()

	for(var/datum/dna/gene/gene as anything in GLOB.dna_genes)
		if(!LAZYIN(M.dna.default_blocks, gene.block))
			M.force_gene_block(gene.block, FALSE)

	M.dna.struc_enzymes = M.dna.struc_enzymes_original

	return ..()


/datum/reagent/medicine/antihol
	name = "Антиголь"
	id = "antihol"
	description = "Препарат, который быстро выводит алкоголь из организма."
	color = "#009CA8"
	taste_description = "трезвости"

/datum/reagent/medicine/antihol/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.SetSlur(0)
	M.AdjustDrunk(-8 SECONDS)
	M.reagents.remove_all_type(/datum/reagent/consumable/ethanol, 8, 0, 1)
	if(M.getToxLoss() <= 25)
		update_flags |= M.adjustToxLoss(-2.0, FALSE)
	return ..() | update_flags

/datum/reagent/medicine/stimulants
	name = "Стимулятор"
	id = "stimulants"
	description = "Запрещённое вещество, резко повышающее работоспособность и лечебные возможности организма."
	color = "#C8A5DC"
	harmless = FALSE
	can_synth = FALSE
	taste_description = span_userdanger("нереальной бодрости")
	var/absorption_applied = FALSE

/datum/reagent/medicine/stimulants/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(volume > 5)
		update_flags |= M.adjustOxyLoss(-2.5, FALSE)
		update_flags |= M.adjustToxLoss(-2.5, FALSE)
		update_flags |= M.adjustBruteLoss(-5, FALSE, affect_robotic = FALSE)
		update_flags |= M.adjustFireLoss(-5, FALSE, affect_robotic = FALSE)
		update_flags |= M.setStaminaLoss(0, FALSE)
		M.SetSlowed(0)
		M.AdjustDizzy(-20 SECONDS)
		M.AdjustDrowsy(-20 SECONDS)
		M.SetConfused(0)
		M.SetSleeping(0)
		if(!absorption_applied)
			absorption_applied = TRUE
			M.add_status_effect_absorption(source = id, effect_type = list(STUN, WEAKEN, STAMCRIT, PARALYZE, KNOCKDOWN))
	else
		if(absorption_applied)
			absorption_applied = FALSE
			M.remove_status_effect_absorption(source = id, effect_type = list(STUN, WEAKEN, STAMCRIT, PARALYZE, KNOCKDOWN))
		update_flags |= M.adjustToxLoss(2, FALSE)
		update_flags |= M.adjustBruteLoss(1, FALSE)
		if(prob(10))
			M.Stun(6 SECONDS)

	return ..() | update_flags


/datum/reagent/medicine/stimulants/on_mob_delete(mob/living/M)
	. = ..()
	if(absorption_applied)	// somehow???
		M.remove_status_effect_absorption(source = id, effect_type = list(STUN, WEAKEN, STAMCRIT, PARALYZE, KNOCKDOWN))


/datum/reagent/medicine/stimulative_agent
	name = "Стимулирующий агент"
	id = "stimulative_agent"
	description = "Увеличивает скорость бега и устраняет оглушение, может исцелять небольшие повреждения. При передозировке отравляет и менее эффективен для восстановления выносливости."
	color = "#C8A5DC"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 60
	harmless = FALSE
	can_synth = FALSE

/datum/reagent/medicine/stimulative_agent/on_mob_life(mob/living/user)
	var/update_flags = STATUS_UPDATE_NONE
	if(user.health < 50 && user.health > 0)
		update_flags |= user.adjustOxyLoss(-2, FALSE)
		update_flags |= user.adjustBruteLoss(-2, FALSE, affect_robotic = FALSE)
		update_flags |= user.adjustFireLoss(-2, FALSE, affect_robotic = FALSE)
	user.AdjustParalysis(-6 SECONDS)
	user.AdjustStunned(-6 SECONDS)
	user.AdjustWeakened(-6 SECONDS)
	update_flags |= user.adjustStaminaLoss(-7.5, FALSE)
	if(!(user.dna && (user.dna.species.reagent_tag & PROCESS_ORG)))
		user.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/stimulative_agent)
	return ..() | update_flags


/datum/reagent/medicine/stimulative_agent/on_mob_add(mob/living/user)
	. = ..()
	if(user.dna && (user.dna.species.reagent_tag & PROCESS_ORG))
		user.add_movespeed_modifier(/datum/movespeed_modifier/reagent/stimulative_agent)


/datum/reagent/medicine/stimulative_agent/on_mob_delete(mob/living/user)
	. = ..()
	user.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/stimulative_agent)


/datum/reagent/medicine/stimulative_agent/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(33))
		update_flags |= M.adjustStaminaLoss(1.25, FALSE)
		update_flags |= M.adjustToxLoss(0.5, FALSE)
		M.AdjustLoseBreath(2 SECONDS)
	return list(0, update_flags)

/datum/reagent/medicine/insulin
	name = "Инсулин"
	id = "insulin"
	description = "Гормон, вырабатываемый поджелудочной железой и отвечающий за метаболизм углеводов и жиров в кровеносной системе.."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "усталости"
	chemuse = 50

/datum/reagent/medicine/insulin/on_mob_life(mob/living/M)
	M.reagents.remove_reagent("sugar", 5)
	return ..()

/datum/reagent/heparin
	name = "Гепарин"
	id = "heparin"
	description = "Антикоагулянт, используемый при операциях на сердце, а также при лечении инфарктов и тромбозов."
	reagent_state = LIQUID
	color = "#eee6da"
	overdose_threshold = 20
	taste_description = "горечи"

/datum/reagent/heparin/on_mob_life(mob/living/M)
	M.reagents.remove_reagent("cholesterol", 2)
	return ..()

/datum/reagent/heparin/overdose_process(mob/living/carbon/M, severity)
	var/list/overdose_info = ..()
	var/effect = overdose_info[REAGENT_OVERDOSE_EFFECT]
	var/update_flags = overdose_info[REAGENT_OVERDOSE_FLAGS]
	if(severity == 1)
		if(effect <= 2)
			M.vomit(0, VOMIT_BLOOD, 0 SECONDS)
			M.AdjustBlood(-rand(5, 10))
		else if(effect <= 4)
			M.vomit(0, VOMIT_BLOOD, 0 SECONDS)
			M.AdjustBlood(-rand(1, 2))
	else if(severity == 2)
		if(effect <= 2)
			M.visible_message(span_warning("[M] тряс[pluralize_ru(M.gender, "ёт", "ют")]ся, кровь хлещет прямо из [genderize_ru(M.gender, "его", "её", "его", "их")] пор!"))
			M.bleed(rand(10, 20))
		else if(effect <= 4)
			M.vomit(0, VOMIT_BLOOD, 0 SECONDS)
			M.AdjustBlood(-rand(5, 10))
		else if(effect <= 8)
			M.vomit(0, VOMIT_BLOOD, 0 SECONDS)
			M.AdjustBlood(-rand(1, 2))
	return list(effect, update_flags)


/datum/reagent/medicine/teporone
	name = "Тепорон"
	id = "teporone"
	description = "Это экспериментальное соединение на основе плазмы крови, которое регулирует температуру тела."
	reagent_state = LIQUID
	color = "#D782E6"
	addiction_chance = 1
	addiction_chance_additional = 10
	addiction_threshold = 10
	overdose_threshold = 50
	taste_description = "согревающей горечи"
	var/temperature_effect = 40

/datum/reagent/medicine/teporone/on_mob_life(mob/living/M)
	var/normal_temperature = M?.dna?.species.body_temperature
	if(!normal_temperature)
		normal_temperature = BODYTEMP_NORMAL
	var/difference = M.bodytemperature - normal_temperature
	if(abs(difference) > temperature_effect)
		var/current_effect = difference > 0 ? -temperature_effect : temperature_effect
		M.adjust_bodytemperature(current_effect * TEMPERATURE_DAMAGE_COEFFICIENT)
	return ..()

/datum/reagent/medicine/haloperidol
	name = "Галоперидол"
	id = "haloperidol"
	description = "Галоперидол - мощный антипсихотик и седативное средство. Помогает справиться с психическими проблемами, но может вызвать повреждение мозга."
	reagent_state = LIQUID
	color = "#FFDCFF"
	taste_description = "стабильности и успокоения"
	harmless = FALSE
	var/list/drug_list = list("crank","methamphetamine","space_drugs","psilocybin","ephedrine","epinephrine","stimulants","bath_salts","lsd","thc")

/datum/reagent/medicine/haloperidol/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	for(var/I in M.reagents.reagent_list)
		var/datum/reagent/R = I
		if(drug_list.Find(R.id))
			M.reagents.remove_reagent(R.id, 5)
	M.AdjustDruggy(-10 SECONDS)
	M.AdjustHallucinate(-5 SECONDS)
	M.AdjustJitter(-10 SECONDS)
	if(prob(10))
		M.emote("drool")
	if(prob(20))
		update_flags |= M.adjustBrainLoss(1, FALSE)
	if(current_cycle > 20)
		if(prob(50))
			M.Drowsy(6 SECONDS)
	return ..() | update_flags

/datum/reagent/medicine/ether
	name = "Эфир"
	id = "ether"
	description = "Сильное обезболивающее и седативное средство."
	reagent_state = LIQUID
	color = "#96DEDE"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	harmless = FALSE
	taste_description = "снотворного"

/datum/reagent/medicine/ether/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustJitter(-50 SECONDS)
	switch(current_cycle)
		if(1 to 30)
			if(prob(7))
				M.emote("yawn")
		if(31 to 40)
			M.Drowsy(40 SECONDS)
		if(41 to INFINITY)
			M.Paralyse(30 SECONDS)
			M.Drowsy(40 SECONDS)
	return ..() | update_flags

/datum/reagent/medicine/syndicate_nanites //Used exclusively by Syndicate medical cyborgs
	name = "Восстановительные наниты"
	id = "syndicate_nanites"
	description = "Миниатюрные медицинские роботы, которые быстро восстанавливают повреждения тела. Могут начать атаковать клетки своего хозяина в больших количествах."
	reagent_state = SOLID
	color = "#555555"
	can_synth = FALSE
	taste_description = "нано-технологий"

/datum/reagent/medicine/syndicate_nanites/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustBruteLoss(-2.5, FALSE, affect_robotic = FALSE) //A ton of healing - this is a 50 telecrystal investment.
	update_flags |= M.adjustFireLoss(-2.5, FALSE, affect_robotic = FALSE)
	update_flags |= M.adjustOxyLoss(-7.5, FALSE)
	update_flags |= M.adjustToxLoss(-2.5, FALSE)
	update_flags |= M.adjustBrainLoss(-7.5, FALSE)
	update_flags |= M.adjustCloneLoss(-1.5, FALSE)
	return ..() | update_flags

/datum/reagent/medicine/omnizine_diluted
	name = "Разбавленный омнизин"
	id = "weak_omnizine"
	description = "Медленно исцеляет все типы повреждений. Гораздо более слабая версия настоящего омнизина."
	reagent_state = LIQUID
	color = "#DCDCDC"
	overdose_threshold = 30
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	harmless = FALSE
	taste_description = "слабой надежды"

/datum/reagent/medicine/omnizine_diluted/godblood
	name = "Кровь Бога"
	id = "godblood"
	description = "Медленно исцеляет все типы повреждений. Имеет довольно высокий порог передозировки. Светится таинственной силой."
	overdose_threshold = 150

/datum/reagent/medicine/omnizine_diluted/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(-0.25, FALSE)
	update_flags |= M.adjustOxyLoss(-0.25, FALSE)
	update_flags |= M.adjustBruteLoss(-0.25, FALSE, affect_robotic = FALSE)
	update_flags |= M.adjustFireLoss(-0.25, FALSE, affect_robotic = FALSE)
	return ..() | update_flags

/datum/reagent/medicine/omnizine_diluted/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(0.75, FALSE)
	update_flags |= M.adjustOxyLoss(0.75, FALSE)
	update_flags |= M.adjustBruteLoss(0.75, FALSE)
	update_flags |= M.adjustFireLoss(0.75, FALSE)
	return list(0, update_flags)

//////////////////////////////
//		Synth-Meds			//
//////////////////////////////

//Degreaser: Mild Purgative / Lube Remover
/datum/reagent/medicine/degreaser
	name = "Обезжириватель"
	id = "degreaser"
	description = "Промышленный обезжириватель, который можно использовать для удаления остатков налёта с оборудования и поверхностей."
	reagent_state = LIQUID
	color = "#CC7A00"
	process_flags = SYNTHETIC
	taste_description = "очищения внутренних систем"

/datum/reagent/medicine/degreaser/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(50))		//Same effects as coffee, to help purge ill effects like paralysis
		M.AdjustParalysis(-2 SECONDS)
		M.AdjustStunned(-2 SECONDS)
		M.AdjustWeakened(-2 SECONDS)
		M.AdjustConfused(-10 SECONDS)
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(R != src)
			if(R.id == "ultralube" || R.id == "lube")
				//Flushes lube and ultra-lube even faster than other chems
				M.reagents.remove_reagent(R.id, 5)
			else
				M.reagents.remove_reagent(R.id,1)
	return ..() | update_flags

/datum/reagent/medicine/degreaser/reaction_turf(turf/simulated/T, volume)
	if(volume >= 1 && istype(T))
		T.MakeDry(TURF_WET_LUBE)

//Liquid Solder: Mannitol
/datum/reagent/medicine/liquid_solder
	name = "Жидкий припой"
	id = "liquid_solder"
	description = "Раствор, предназначенный для очистки и восстановления поврежденных соединений в позитронных блоках в процессе эксплуатации."
	reagent_state = LIQUID
	color = "#D7B395"
	process_flags = SYNTHETIC
	taste_description = "тяжёлых металлов"

/datum/reagent/medicine/liquid_solder/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustBrainLoss(-3, FALSE)
	return ..() | update_flags

//Coolant: Antihol
/datum/reagent/medicine/coolant
	name = "Охлаждающая жидкость"
	id = "coolant"
	description = "Исправляет ошибки модуля общения."
	reagent_state = LIQUID
	color = "#0af0f0"
	process_flags = SYNTHETIC
	taste_description = "исправленных багов"

/datum/reagent/medicine/coolant/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.SetSlur(0)
	M.AdjustDrunk(-8 SECONDS)
	M.reagents.remove_all_type(/datum/reagent/consumable/ethanol/synthanol, 8, 0, 1)
	return ..() | update_flags


//Trek-Chems. DO NOT USE THES OUTSIDE OF BOTANY OR FOR VERY SPECIFIC PURPOSES. NEVER GIVE A RECIPE UNDER ANY CIRCUMSTANCES//
/datum/reagent/medicine/bicaridine
	name = "Бикаридин"
	id = "bicaridine"
	description = "Залечивает травмы. При передозировке вызывает их появление."
	reagent_state = LIQUID
	color = "#C8A5DC"
	overdose_threshold = 30
	harmless = FALSE
	taste_description = "восстановления ран"

/datum/reagent/medicine/bicaridine/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustBruteLoss(-1, FALSE, affect_robotic = FALSE)
	return ..() | update_flags

/datum/reagent/medicine/bicaridine/overdose_process(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustBruteLoss(2, FALSE)
	return list(0, update_flags)

/datum/reagent/medicine/kelotane
	name = "Келотан"
	id = "kelotane"
	description = "Залечивает ожоги. При передозировке вызывает их появление."
	reagent_state = LIQUID
	color = "#C8A5DC"
	overdose_threshold = 30
	harmless = FALSE
	taste_description = "восстановления ожогов"

/datum/reagent/medicine/kelotane/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustFireLoss(-1, FALSE, affect_robotic = FALSE)
	return ..() | update_flags

/datum/reagent/medicine/kelotane/overdose_process(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustFireLoss(2, FALSE)
	return ..() | update_flags


/datum/reagent/medicine/earthsblood //Created by ambrosia gaia plants
	name = "Кровь Земли"
	id = "earthsblood"
	description = "Ихор от чрезвычайно мощного растения. Отлично восстанавливает раны, но немного тяжеловат для мозга."
	color = "#FFAF00"
	overdose_threshold = 25
	harmless = FALSE
	taste_description = "природного восстановления"

/datum/reagent/medicine/earthsblood/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustBruteLoss(-1.5, FALSE, affect_robotic = FALSE)
	update_flags |= M.adjustFireLoss(-1.5, FALSE, affect_robotic = FALSE)
	update_flags |= M.adjustOxyLoss(-7.5, FALSE)
	update_flags |= M.adjustToxLoss(-1.5, FALSE)
	update_flags |= M.adjustBrainLoss(1, FALSE) //This does, after all, come from ambrosia, and the most powerful ambrosia in existence, at that!
	update_flags |= M.adjustCloneLoss(-0.5, FALSE)
	update_flags |= M.adjustStaminaLoss(-4.5, FALSE)
	M.AdjustDruggy(10 SECONDS, 0, 15 SECONDS)
	M.AdjustJitter(6 SECONDS, 0, 60 SECONDS) //See above
	return ..() | update_flags

/datum/reagent/medicine/earthsblood/overdose_process(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustHallucinate(5 SECONDS, 0, 60 SECONDS)
	M.last_hallucinator_log = "[name] overdose"
	update_flags |= M.adjustToxLoss(2.5, FALSE)
	return list(0, update_flags)

/datum/reagent/medicine/syndiezine
	name = "Синдизин"
	id = "syndiezine"
	description = "Попытка синдиката вывести синтетический аналог вещества \"Кровь Земли\". Слабо лечит раны, но быстро избавляет от усталости, вызывает галлюцинации."
	color = "#332300"
	overdose_threshold = 25
	harmless = FALSE
	taste_description = "металла с табаком"

/datum/reagent/medicine/syndiezine/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustBruteLoss(-0.5, FALSE, affect_robotic = FALSE)
	update_flags |= M.adjustFireLoss(-0.5, FALSE, affect_robotic = FALSE)
	update_flags |= M.adjustOxyLoss(-4.5, FALSE)
	update_flags |= M.adjustToxLoss(-0.5, FALSE)
	update_flags |= M.adjustCloneLoss(-0.5, FALSE)
	update_flags |= M.adjustStaminaLoss(-10, FALSE)
	M.AdjustDruggy(10 SECONDS, 0, 15 SECONDS)
	M.AdjustJitter(6 SECONDS, 0, 60 SECONDS) //See above
	return ..() | update_flags

/datum/reagent/medicine/syndiezine/overdose_process(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustHallucinate(5 SECONDS, 0, 60 SECONDS)
	M.last_hallucinator_log = "[name] overdose"
	update_flags |= M.adjustToxLoss(1.5, FALSE)
	return list(0, update_flags)

/datum/reagent/medicine/corazone
	name = "Коразон"
	id = "corazone"
	description = "Лекарство, используемое для лечения боли, лихорадки и воспаления, а также сердечных приступов."
	color = "#F5F5F5"
	taste_description = "короткой передышки"

// This reagent's effects are handled in heart attack handling code

/datum/reagent/medicine/nanocalcium
	name = "Нано-Кальций"
	id = "nanocalcium"
	description = "Высокотехнологичные наниты, оснащённые экспериментальной полезной нагрузкой, предназначенной для восстановления тела. Наномашины, сынок."
	color = "#9b3401"
	metabolization_rate = 1.25 * REAGENTS_METABOLISM
	can_synth = FALSE
	harmless = FALSE
	taste_description = "предстоящих страданий"
	var/list/stimulant_list = list("methamphetamine", "crank", "bath_salts", "stimulative_agent", "stimulants", "adrenaline")

/datum/reagent/medicine/nanocalcium/on_mob_life(mob/living/carbon/human/M)
	var/update_flags = STATUS_UPDATE_NONE
	var/has_stimulant = FALSE
	for(var/I in M.reagents.reagent_list)
		var/datum/reagent/R = I
		if(stimulant_list.Find(R.id))
			has_stimulant = TRUE
	switch(current_cycle)
		if(1 to 9)
			M.AdjustJitter(8 SECONDS)
			if(prob(20))
				to_chat(M, span_warning("Ваша кожа горит, а кровь в венах закипает!"))
				update_flags |= M.adjustFireLoss(1, FALSE)
			if(has_stimulant)
				for(var/datum/reagent/R in M.reagents.reagent_list)
					if(stimulant_list.Find(R.id))
						M.reagents.remove_reagent(R.id, 1) //We will be generous (for nukies really) and purge out the chemicals during this phase, so they don't fucking die during the next phase. Of course, if they try to use adrenals in the next phase, well...
		if(10 to 21)
			//If they have stimulants or stimulant drugs then just apply toxin damage instead.
			if(has_stimulant)
				update_flags |= M.adjustToxLoss(20, FALSE)
			else //apply debilitating effects
				if(prob(75))
					M.AdjustConfused(10 SECONDS)
				else
					M.AdjustWeakened(10 SECONDS)
		if(22)
			to_chat(M, span_warning("Ваше тело онемело, вы не можете пошевелиться!"))
			M.AdjustWeakened(15 SECONDS)
		if(23 to INFINITY) // Start fixing bones | If they have stimulants or stimulant drugs in their system then the nanites won't work.
			if(has_stimulant)
				return ..()
			else
				for(var/obj/item/organ/external/bodypart as anything in M.bodyparts)
					if(prob(50)) // Each tick has a 50% chance of repearing a bone.
						if(bodypart.has_fracture()) //I can't just check for !E.status
							to_chat(M, span_notice("Вы чувствуете жжение в ваш[genderize_ru(bodypart.gender, "ем", "ей", "ем", "их")] [bodypart.declent_ru(PREPOSITIONAL)], по мере того как [genderize_ru(bodypart.gender, "он", "она", "оно", "они")] применяют правильную форму!"))
							bodypart.mend_fracture()
						if(bodypart.has_internal_bleeding())
							to_chat(M, span_notice("Вы чувствуете жжение в ваш[genderize_ru(bodypart.gender, "ем", "ей", "ем", "их")] [bodypart.declent_ru(PREPOSITIONAL)], по мере того как сосуды в [genderize_ru(bodypart.gender, "нём", "ней", "нём", "них")] восстанавливаются!"))
							bodypart.stop_internal_bleeding()

				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					for(var/obj/item/organ/internal/I as anything in M.internal_organs) // 56 healing to all internal organs.
						I.heal_internal_damage(8)
					if(!HAS_TRAIT(H, TRAIT_NO_BLOOD_RESTORE) && H.blood_volume < BLOOD_VOLUME_NORMAL * 0.9)// If below 90% blood, regenerate 210 units total
						H.AdjustBlood(30)
					for(var/datum/disease/critical/heart_failure/HF in H.diseases)
						HF.cure() //Won't fix a stopped heart, but it will sure fix a critical one. Shock is not fixed as healing will fix it
				if(M.health < 40)
					update_flags |= M.adjustOxyLoss(-6, FALSE)
					update_flags |= M.adjustToxLoss(-2, FALSE)
					update_flags |= M.adjustBruteLoss(-4, FALSE, affect_robotic = FALSE)
					update_flags |= M.adjustFireLoss(-4, FALSE, affect_robotic = FALSE)
				else
					if(prob(50))
						to_chat(M, span_warning("Ваша кожа словно разрывается на части, а вены горят!")) //It is experimental and does cause scars, after all.
						update_flags |= M.adjustBruteLoss(2, FALSE)
						update_flags |= M.adjustFireLoss(2, FALSE)
	return ..() | update_flags

/datum/reagent/medicine/lavaland_extract
	name = "Экстракт Лаваленда"
	id = "lavaland_extract"
	description = "Экстракт атмосферы Лаваленда и минеральные элементы в придачу. В небольших дозах исцеляет пользователя, но в остальных случаях крайне токсичен."
	color = "#C8A5DC" // rgb: 200, 165, 220
	overdose_threshold = 3 //To prevent people stacking massive amounts of a very strong healing reagent
	harmless = FALSE
	can_synth = FALSE

/datum/reagent/medicine/lavaland_extract/on_mob_life(mob/living/carbon/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustBruteLoss(-2.5, FALSE, affect_robotic = FALSE)
	update_flags |= M.adjustFireLoss(-2.5, FALSE, affect_robotic = FALSE)
	return ..() | update_flags

/datum/reagent/medicine/lavaland_extract/overdose_process(mob/living/M) // This WILL be brutal
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustConfused(10 SECONDS)
	update_flags |= M.adjustBruteLoss(1.5, FALSE)
	update_flags |= M.adjustFireLoss(1.5, FALSE)
	update_flags |= M.adjustToxLoss(1.5, FALSE)
	return ..() | update_flags

/datum/reagent/medicine/zessulblood   //unique chemical for unathi
	name = "Кровь Зессул"
	id = "zessulblood"
	description = "Природное химическое вещество, вырабатываемое в кровотоке унатхов."
	reagent_state = LIQUID
	color = "#00ff15"
	metabolization_rate = REAGENTS_METABOLISM
	shock_reduction = 20
	taste_description = "благословления"
	can_synth = FALSE

/datum/reagent/medicine/zessulblood/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustBruteLoss(-1, FALSE, affect_robotic = FALSE)
	update_flags |= M.adjustFireLoss(-1, FALSE, affect_robotic = FALSE)
	return ..() | update_flags

/datum/reagent/medicine/pure_plasma   //unique chemical for plasmaman
	name = "Чистая плазма"
	id = "pure_plasma"
	description = "Продукт метаболизма плазмаменов, отвечающий за восстановление тканей и противодействие болевому шоку. Чрезвычайно токсичен."
	reagent_state = LIQUID
	color = "#b521c2"
	metabolization_rate = REAGENTS_METABOLISM
	shock_reduction = 20
	taste_description = "превосходства"
	can_synth = FALSE

/datum/reagent/medicine/pure_plasma/on_mob_life(mob/living/carbon/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(isplasmaman(M))
		var/normal_temperature = M?.dna?.species.body_temperature
		if(!normal_temperature)
			normal_temperature = BODYTEMP_NORMAL
		if(M.bodytemperature < normal_temperature)
			M.adjust_bodytemperature(5 * TEMPERATURE_DAMAGE_COEFFICIENT)
		update_flags |= M.adjustBruteLoss(-0.25, FALSE, affect_robotic = FALSE)
		update_flags |= M.adjustFireLoss(-0.25, FALSE, affect_robotic = FALSE)
	else
		update_flags |= M.adjustToxLoss(4, FALSE)
	return ..() | update_flags

/datum/reagent/medicine/grubjuice
	name = "Жучиный сок"
	id = "grub_juice"
	description = "Сильнодействующее лекарственное средство, которое при чрезмерном употреблении может вызвать опасные побочные эффекты."
	color = "#43bf1d"
	taste_description = "жучиных кишков"
	overdose_threshold = 10
	can_synth = FALSE

/datum/reagent/medicine/grubjuice/on_mob_life(mob/living/carbon/M) //huge heal for huge liver problems
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.heal_overall_damage(4, 4)
	return ..() | update_flags

/datum/reagent/medicine/grubjuice/overdose_process(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.take_overall_damage(3, 3, updating_health = FALSE)
	update_flags |= M.apply_damage(5, TOX, updating_health = FALSE)
	return list(0, update_flags)

/datum/reagent/medicine/adrenaline
	name = "Адреналин"
	id = "adrenaline"
	description = "Мощный стимулятор, который делает вас невосприимчивым к оглушению на некоторое время."
	color = "#C8A5DC"
	metabolization_rate = 0.8 * REAGENTS_METABOLISM
	overdose_threshold = 2.1
	shock_reduction = 80
	harmless = TRUE
	can_synth = FALSE


/datum/reagent/medicine/adrenaline/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.setStaminaLoss(0, FALSE)
	return ..() | update_flags


/datum/reagent/medicine/adrenaline/on_mob_add(mob/living/M)
	. = ..()
	M.add_status_effect_absorption(source = id, effect_type = list(STUN, WEAKEN, STAMCRIT, PARALYZE, KNOCKDOWN))


/datum/reagent/medicine/adrenaline/on_mob_delete(mob/living/M)
	. = ..()
	M.remove_status_effect_absorption(source = id, effect_type = list(STUN, WEAKEN, STAMCRIT, PARALYZE, KNOCKDOWN))


/datum/reagent/medicine/adrenaline/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(10, FALSE)

	return list(0, update_flags)

/datum/reagent/medicine/adv_lava_extract
	name = "Модифицированный Экстракт Лаваленда"
	id = "adv_lava_extract"
	description = "Очень дорогое лекарство, которое помогает перекачивать кровь по телу и предотвращает замедление работы сердца, исцеляя пациента в процессе. Передозировка приводит к сердечным приступам."
	reagent_state = LIQUID
	color = "#F5F5F5"
	overdose_threshold = 10
	harmless = FALSE
	taste_description = "плохих идей"
	can_synth = FALSE

/atom/movable/screen/alert/adv_lava_extract
	name = "Учащённое сердцебиение"
	desc = "Ваше сердце бьется с огромной силой! Будьте осторожны, чтобы не вызвать сердечный приступ."
	icon_state = "penthrite"

/datum/reagent/medicine/adv_lava_extract/on_mob_add(mob/living/carbon/human/user)
	. = ..()
	user.throw_alert("penthrite", /atom/movable/screen/alert/adv_lava_extract)

/datum/reagent/medicine/adv_lava_extract/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustOxyLoss(-3.5, FALSE)
	update_flags |= M.adjustToxLoss(-2.5, FALSE)
	update_flags |= M.adjustBruteLoss(-3, FALSE, affect_robotic = FALSE)
	update_flags |= M.adjustFireLoss(-3, FALSE, affect_robotic = FALSE)
	if(prob(50))
		M.AdjustLoseBreath(-2 SECONDS)
	M.SetConfused(0)
	M.SetSleeping(0)
	if(M.getFireLoss() > 35)
		update_flags |= M.adjustFireLoss(-4, FALSE, affect_robotic = FALSE)
	if(M.health < 0)
		update_flags |= M.adjustToxLoss(-1, FALSE)
		update_flags |= M.adjustBruteLoss(-1, FALSE, affect_robotic = FALSE)
		update_flags |= M.adjustFireLoss(-1, FALSE, affect_robotic = FALSE)
	return ..() | update_flags

/datum/reagent/medicine/adv_lava_extract/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustOxyLoss(4, FALSE)
	update_flags |= M.adjustToxLoss(3, FALSE)
	update_flags |= M.adjustBruteLoss(5, FALSE)
	update_flags |= M.adjustFireLoss(5, FALSE)
	update_flags |= M.adjustStaminaLoss(10, FALSE)
	if(M.getFireLoss())
		update_flags |= M.adjustFireLoss(5, FALSE) //It only makes existing burns worse
	if(ishuman(M) && prob(7))
		var/mob/living/carbon/human/H = M
		if(!H.undergoing_cardiac_arrest())
			H.set_heartattack(TRUE)
	return ..() | update_flags

/datum/reagent/medicine/adv_lava_extract/on_mob_delete(mob/living/carbon/human/user)
	. = ..()
	user.clear_alert("penthrite")

/datum/reagent/medicine/ashiezine
	name = "Сироп Лаваленда"
	id = "ashiezine"
	description = "Странный реагент, найденный на Лазис Ардаксе. Судя по всему, он работает только на пеплоходцев."
	reagent_state = LIQUID
	color = "#f45555"
	harmless = FALSE
	taste_description = "потрохов"
	can_synth = FALSE

/datum/reagent/medicine/ashiezine/on_mob_life(mob/living/M)
	if(isashwalker(M))
		M.reagents.add_reagent("epinephrine", 0.2)
		M.reagents.add_reagent("heparin", 0,4)
	return ..()
