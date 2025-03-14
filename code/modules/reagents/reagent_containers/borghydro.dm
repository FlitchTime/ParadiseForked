#define BORGHYPO_REFILL_VALUE 5

/obj/item/reagent_containers/borghypo
	name = "Cyborg Hypospray"
	desc = "Передовой химический синтезатор, оборудованный системой инъекции, разработанный для тяжёлого медицинского оборудования."
	ru_names = list(
        NOMINATIVE = "робо-гипоспрей",
        GENITIVE = "робо-гипоспрея",
        DATIVE = "робо-гипоспрею",
        ACCUSATIVE = "робо-гипоспрей",
        INSTRUMENTAL = "робо-гипоспреем",
        PREPOSITIONAL = "робо-гипоспрее"
	)
	icon = 'icons/obj/hypo.dmi'
	item_state = "hypo"
	icon_state = "borghypo"
	amount_per_transfer_from_this = 5
	volume = 30
	possible_transfer_amounts = null
	var/mode = 1
	var/charge_cost = 50
	var/charge_tick = 0
	var/recharge_time = 5 //Time it takes for shots to recharge (in seconds)
	var/bypass_protection = FALSE //If the hypospray can go through armor or thick material
	var/upgrade_path = /obj/item/reagent_containers/borghypo/upgraded

	var/list/datum/reagents/reagent_list = list()
	var/list/reagent_ids = list( \
		"salglu_solution" = list('icons/effects/bleed.dmi', "bleed10"), \
		"mannitol" = list('icons/obj/species_organs/grey.dmi', "brain2"), \
		"epinephrine" = list('icons/obj/surgery.dmi', "heart-on"), \
		"spaceacillin" = list('icons/effects/effects.dmi', "greenglow"), \
		"charcoal" = list('icons/mob/screen_corgi.dmi', "tox1"), \
		"hydrocodone" = list('icons/mob/actions/actions.dmi', "magicm"))



/obj/item/reagent_containers/borghypo/syndicate
	name = "syndicate cyborg hypospray"
	desc = "Передовой химический синтезатор, оборудованный системой инъекции, разработанный для тяжёлого медицинского оборудования. Специальная версия, производимая Синдикатом для установки в боевых роботов поддержики, оснащённая передовыми лечебными препаратами."
	ru_names = list(
        NOMINATIVE = "Синди-робо-гипоспрей",
        GENITIVE = "Синди-робо-гипоспрея",
        DATIVE = "Синди-робо-гипоспрею",
        ACCUSATIVE = "Синди-робо-гипоспрей",
        INSTRUMENTAL = "Синди-робо-гипоспреем",
        PREPOSITIONAL = "Синди-робо-гипоспрее"
	)
	icon_state = "borghypo_s"
	charge_cost = 20
	recharge_time = 2
	reagent_ids = list( \
		"syndicate_nanites" = list('icons/mob/swarmer.dmi', "swarmer_ranged"), \
		"salglu_solution" = list('icons/effects/bleed.dmi', "bleed10"), \
		"epinephrine" = list('icons/obj/surgery.dmi', "heart-on"), \
		"potass_iodide" = list('icons/obj/decals.dmi', "radiation"), \
		"hydrocodone" = list('icons/mob/actions/actions.dmi', "magicm"))
	bypass_protection = TRUE
	upgrade_path = null //no upgrades


/obj/item/reagent_containers/borghypo/upgraded
	name = "upgraded cyborg hypospray"
	desc = "Улучшенная версия робо-гипоспрея. Передовой химический синтезатор, оборудованный системой инъекции, разработанный для тяжёлого медицинского оборудования."
	ru_names = list(
        NOMINATIVE = "улучшенный робо-гипоспрей",
        GENITIVE = "улучшенного робо-гипоспрея",
        DATIVE = "улучшенному робо-гипоспрею",
        ACCUSATIVE = "улучшенный робо-гипоспрей",
        INSTRUMENTAL = "улучшенным робо-гипоспреем",
        PREPOSITIONAL = "улучшенном робо-гипоспрее"
	)
	reagent_ids = list( \
		"salglu_solution" = list('icons/effects/bleed.dmi', "bleed10"), \
		"mannitol" = list('icons/obj/species_organs/grey.dmi', "brain2"), \
		"epinephrine" = list('icons/obj/surgery.dmi', "heart-on"), \
		"spaceacillin" = list('icons/effects/effects.dmi', "greenglow"), \
		"pen_acid" = list('icons/mob/screen_corgi.dmi', "tox1"), \
		"hydrocodone" = list('icons/mob/actions/actions.dmi', "magicm"), \
		"perfluorodecalin" = list('icons/obj/surgery.dmi', "lungs"), \
		"calomel" = list('icons/obj/items.dmi', "soap"), \
		"oculine" = list('icons/obj/surgery.dmi', "eyes"))
	upgrade_path = null //no upgrades

/obj/item/reagent_containers/borghypo/upgraded/super
	bypass_protection = TRUE

/obj/item/reagent_containers/borghypo/empty()
	set hidden = TRUE


/obj/item/reagent_containers/borghypo/Initialize(mapload)
	for(var/R in reagent_ids)
		add_reagent(R)
	. = ..()

	START_PROCESSING(SSobj, src)


/obj/item/reagent_containers/borghypo/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/item/reagent_containers/borghypo/process() //Every [recharge_time] seconds, recharge some reagents for the cyborg
	charge_tick++
	if(charge_tick < recharge_time)
		return FALSE
	charge_tick = 0

	var/target_loc
	if (isrobot(loc))
		target_loc = loc
	else if (isrobot(loc.loc))
		target_loc = loc.loc
	else
		return TRUE

	var/mob/living/silicon/robot/R = target_loc
	if(R && R.cell)
		var/datum/reagents/RG = reagent_list[mode]
		if(!refill_borghypo(RG, reagent_ids[mode], R)) 	//If the storage is not full recharge reagents and drain power.
			for(var/i in 1 to reagent_list.len)     	//if active mode is full loop through the list and fill the first one that is not full
				RG = reagent_list[i]
				if(refill_borghypo(RG, reagent_ids[i], R))
					break
	//update_icon()
	return TRUE


// Use this to add more chemicals for the borghypo to produce.
/obj/item/reagent_containers/borghypo/proc/add_reagent(reagent)
	reagent_ids |= reagent
	var/datum/reagents/RG = new(30)
	RG.my_atom = src
	reagent_list += RG

	var/datum/reagents/R = reagent_list[reagent_list.len]
	R.add_reagent(reagent, 30)


/obj/item/reagent_containers/borghypo/proc/refill_borghypo(datum/reagents/RG, reagent_id, mob/living/silicon/robot/R)
	if(RG.total_volume < RG.maximum_volume)
		RG.add_reagent(reagent_id, BORGHYPO_REFILL_VALUE)
		R.cell.use(charge_cost)
		return TRUE
	return FALSE


/obj/item/reagent_containers/borghypo/attack(mob/living/carbon/human/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED

	if(!ishuman(target) || !target.reagents)
		return .

	var/datum/reagents/our_reagents = reagent_list[mode]
	if(!our_reagents.total_volume)
		balloon_alert(user, "пусто!")
		return .

	if(!target.can_inject(user, TRUE, user.zone_selected, bypass_protection, bypass_protection))
		return .

	. |= ATTACK_CHAIN_SUCCESS

	to_chat(user, span_notice("Вы делаете укол [target] своим инъектором."))
	to_chat(target, span_notice("Вы чувствуете едва заметный укол!"))
	our_reagents.add_reagent(target)
	var/datum/reagent/injected = GLOB.chemical_reagents_list[reagent_ids[mode]]
	var/contained = injected.name
	var/trans = our_reagents.trans_to(target, amount_per_transfer_from_this)
	add_attack_logs(user, target, "Injected with [name] containing [contained], transfered [trans] units", injected.harmless ? ATKLOG_ALMOSTALL : null)
	to_chat(user, span_notice("Вы вкалываете <b>[trans]</b> единиц[declension_ru(trans, "у", "ы", "")]. В хранилище осталось ещё <b>[our_reagents.total_volume]</b> единиц[declension_ru(our_reagents.total_volume, "а", "ы", "")] вещества."))


/obj/item/reagent_containers/borghypo/attack_self(mob/user)
	radial_menu(user)


/obj/item/reagent_containers/borghypo/proc/radial_menu(mob/user)
	var/list/choices = list()
	for(var/i in 1 to length(reagent_ids))
		choices[GLOB.chemical_reagents_list[reagent_ids[i]]] = image(icon = reagent_ids[reagent_ids[i]][1], icon_state = reagent_ids[reagent_ids[i]][2])
	var/choice = show_radial_menu(user, src, choices)
	if(!choice)
		return 0
	playsound(loc, 'sound/effects/pop.ogg', 50, 0)
	mode = choices.Find(choice)

	var/datum/reagent/R = GLOB.chemical_reagents_list[reagent_ids[mode]]
	amount_per_transfer_from_this  = (reagent_ids[mode] == "perfluorodecalin") ? 3 : 5
	to_chat(user, span_notice("Конфигурация синтезатора обновлена. Активирован синтез вещества \"[R.name]\"."))


/obj/item/reagent_containers/borghypo/examine(mob/user)
	. = ..()

	if(bypass_protection)
		. += span_boldnotice("На этом модуле установлен усовершенствованный инъектор, позволяющий пробивать толстые ткани и материалы.")

	if(get_dist(user, src) <= 2)
		var/empty = TRUE

		for(var/datum/reagents/RS in reagent_list)
			var/datum/reagent/R = locate() in RS.reagent_list
			if(R)
				. += span_notice("Содержит в себе <b>[R.volume]</b> единиц[declension_ru(R.volume, "у", "ы", "")] вещества \"[R.name]\".")
				empty = FALSE

		if(empty)
			. += span_notice("Пусто.")


/obj/item/reagent_containers/borghypo/basic
	name = "Basic Medical Hypospray"
	desc = "Сильно упрощённая версия медицинского гипоспрея, способная ввести узко-ограниченный набор лекарственных медикаментов для оказания первой помощи."
	ru_names = list(
        NOMINATIVE = "стандартный медицинский гипоспрей",
        GENITIVE = "стандартного медицинского гипоспрея",
        DATIVE = "стандартному медицинскому гипоспрею",
        ACCUSATIVE = "стандартный медицинский гипоспрей",
        INSTRUMENTAL = "стандартным медицинским гипоспреем",
        PREPOSITIONAL = "стандартном медицинском гипоспрее"
	)
	reagent_ids = list( \
		"salglu_solution" = list('icons/effects/bleed.dmi', "bleed10"), \
		"epinephrine" = list('icons/obj/surgery.dmi', "heart-on"))
	upgrade_path = /obj/item/reagent_containers/borghypo/basic/upgraded


/obj/item/reagent_containers/borghypo/basic/upgraded
	name = "Upgraded Basic Medical Hypospray"
	desc = "Упрощённная версия медицинского гипоспрея, способная ввести ограниченный набор медикаментов для лечения пациентов."
	ru_names = list(
        NOMINATIVE = "улучшенный медицинский гипоспрей",
        GENITIVE = "улучшенного медицинского гипоспрея",
        DATIVE = "улучшенному медицинскому гипоспрею",
        ACCUSATIVE = "улучшенный медицинский гипоспрей",
        INSTRUMENTAL = "улучшенным медицинским гипоспреем",
        PREPOSITIONAL = "улучшенном медицинском гипоспрее"
	)
	reagent_ids = list( \
		"salglu_solution" = list('icons/effects/bleed.dmi', "bleed10"), \
		"epinephrine" = list('icons/obj/surgery.dmi', "heart-on"), \
		"charcoal" = list('icons/mob/screen_corgi.dmi', "tox1"), \
		"sal_acid" = list('icons/mob/actions/actions.dmi', "fleshmend"), \
		"salbutamol" = list('icons/obj/surgery.dmi', "lungs"))
	upgrade_path = null //no upgrades

/obj/item/reagent_containers/borghypo/emagged
	name = "ERR3NU1l_INJ3C70R"
	desc = "Этот инъектор будет впрыскивать смертоносные химикаты в каждого, кому не посчастливилось оказаться врагом Синдиката. Кто бы мог подумать, что роботы НаноТрейзен способы синтезировать такое?"
	ru_names = list(
        NOMINATIVE = "0ШNBK4_IИБ3KT0Я",
        GENITIVE = "0ШNBK4_IИБ3KT0Я",
        DATIVE = "0ШNBK4_IИБ3KT0Я",
        ACCUSATIVE = "0ШNBK4_IИБ3KT0Я",
        INSTRUMENTAL = "0ШNBK4_IИБ3KT0Я",
        PREPOSITIONAL = "0ШNBK4_IИБ3KT0Я"
	)
	icon = 'icons/obj/hypo.dmi'
	item_state = "borghypo_emag"
	icon_state = "borghypo_emag"
	amount_per_transfer_from_this = 10
	// volume = 30
	var/emagged = TRUE
	var/safety_hypo = FALSE
	reagent_ids = list( \
		"amanitin" = list('icons/obj/hydroponics/harvest.dmi', "amanita"), \
		"cyanide" = list('icons/mob/screen_corgi.dmi', "tox1"), \
		"sodium_thiopental" = list('icons/obj/surgery.dmi', "lungs"))
	upgrade_path = null //no upgrades



#undef BORGHYPO_REFILL_VALUE
