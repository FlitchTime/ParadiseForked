
// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T1 HEALER TERROR ------------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: reproduction
// -------------: AI: after it kills you, it webs you and lays new terror eggs on your body
// -------------: SPECIAL: can also create webs, web normal objects, etc
// -------------: TO FIGHT IT: kill it however you like - just don't die to it!
// -------------: SPRITES FROM: FoS, https://www.paradisestation.org/forum/profile/335-fos

/mob/living/simple_animal/hostile/poison/terror_spider/healer
	name = "Healer of Terror"
	desc = "Зловещий зелёный паук. К нему прикреплен небольшой яичный мешок, а на панцире виднеются засохшие пятна крови."
	ru_names = list(
		NOMINATIVE = "Лекарь Ужаса",
		GENITIVE = "Лекаря Ужаса",
		DATIVE = "Лекарю Ужаса",
		ACCUSATIVE = "Лекаря Ужаса",
		INSTRUMENTAL = "Лекарем Ужаса",
		PREPOSITIONAL = "Лекаре Ужаса",
	)
	gender = MALE
	ai_target_method = TS_DAMAGE_BRUTE
	icon_state = "terror_green"
	icon_living = "terror_green"
	icon_dead = "terror_green_dead"
	maxHealth = 100
	health = 100
	death_sound = 'sound/creatures/terrorspiders/death4.ogg'
	delay_web = 20
	melee_damage_lower = 10
	melee_damage_upper = 15
	web_type = /obj/structure/spider/terrorweb/green
	special_abillity = list(/obj/effect/proc_holder/spell/aoe/terror_healing)
	spider_intro_text = "Будучи Лекарем Ужаса, ваша задача - исцелять других пауков и откладывать яйца. Чем больше трупов вы поглотили, тем эффективнее исцеление и тем больше яиц вы сможете отложить."
	var/feedings_to_lay = 3
	var/datum/action/innate/terrorspider/greeneggs/greeneggs_action
	tts_seed = "Jolene"

/mob/living/simple_animal/hostile/poison/terror_spider/healer/strong
	maxHealth = 220
	health = 220
	regeneration = 3
	melee_damage_lower = 20
	melee_damage_upper = 25

/mob/living/simple_animal/hostile/poison/terror_spider/healer/New()
	..()
	greeneggs_action = new()
	greeneggs_action.Grant(src)

/mob/living/simple_animal/hostile/poison/terror_spider/healer/proc/DoLayGreenEggs()
	var/obj/structure/spider/eggcluster/E = locate() in get_turf(src)
	if(E)
		to_chat(src, span_notice("Здесь уже имеется кладка яиц!"))
		return
	if(fed < feedings_to_lay)
		to_chat(src, span_warning("Прежде чем вы сможете это сделать, вам нужно обернуть в паутину больше гуманоидной добычи!"))
		return
	var/list/eggtypes = list(TS_DESC_KNIGHT, TS_DESC_LURKER, TS_DESC_HEALER, TS_DESC_REAPER, TS_DESC_BUILDER)
	var/list/spider_array = CountSpidersDetailed(FALSE)
	if(spider_array[/mob/living/simple_animal/hostile/poison/terror_spider/destroyer] < 2)
		eggtypes += TS_DESC_DESTROYER
	if(spider_array[/mob/living/simple_animal/hostile/poison/terror_spider/widow] < 2)
		eggtypes += TS_DESC_WIDOW
	var/eggtype = pick(eggtypes)
	if(client)
		eggtype = tgui_input_list(usr, "Какой тип яиц?", "", eggtypes)
		if(!(eggtype in eggtypes))
			to_chat(src, span_danger("Неизвестный тип яйца."))
			return FALSE
	if(!isturf(loc))
		// This has to be checked after we ask the user what egg type. Otherwise they could trigger prompt THEN move into a vent.
		to_chat(src, span_danger("Яйца можно откладывать только стоя на полу."))
		return
	if(fed < feedings_to_lay)
		// We have to check this again after the popup, to account for people spam-clicking the button, then doing all the popups at once.
		to_chat(src, span_warning("Прежде чем вы сможете это сделать, вам нужно обернуть в паутину больше гуманоидной добычи!"))
		return
	visible_message(span_notice("[capitalize(declent_ru(NOMINATIVE))] откладывает яица."))
	if(eggtype == TS_DESC_KNIGHT)
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/knight, 1)
	else if(eggtype == TS_DESC_LURKER)
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/lurker, 1)
	else if(eggtype == TS_DESC_HEALER)
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/healer, 1)
	else if(eggtype == TS_DESC_REAPER)
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/reaper, 1)
	else if(eggtype == TS_DESC_BUILDER)
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/builder, 1)
	else if(eggtype == TS_DESC_WIDOW)
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/widow, 1)
	else if(eggtype == TS_DESC_DESTROYER)
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/destroyer, 1)
	else
		to_chat(src, span_warning("Неизвестный тип яиц!"))
		fed += feedings_to_lay
	fed -= feedings_to_lay

/mob/living/simple_animal/hostile/poison/terror_spider/healer/spider_special_action()
	if(cocoon_target)
		handle_cocoon_target()
	else if(fed >= feedings_to_lay)
		DoLayGreenEggs()
	else if(world.time > (last_cocoon_object + freq_cocoon_object))
		seek_cocoon_target()

/mob/living/simple_animal/hostile/poison/terror_spider/healer/spider_specialattack(mob/living/carbon/human/L, poisonable)
	. = ..()
	if(!.)
		return FALSE
	if(!poisonable)
		return TRUE
	var/inject_target = pick(BODY_ZONE_CHEST, BODY_ZONE_HEAD)
	if(HAS_TRAIT(L, TRAIT_INCAPACITATED) || L.can_inject(null, FALSE, inject_target, FALSE))
		L.AdjustEyeBlurry(20 SECONDS, 0, 120 SECONDS)
		// instead of having a venom that only lasts seconds, we just add the eyeblur directly.
		visible_message(span_danger("[capitalize(declent_ru(NOMINATIVE))] вонзает свои клыки глубоко в [inject_target] [target.declent_ru(ACCUSATIVE)]!"))
	else
		visible_message(span_danger("[capitalize(declent_ru(NOMINATIVE))] кусает [target.declent_ru(ACCUSATIVE)], но не может ввести яд в [inject_target]!"))

/mob/living/simple_animal/hostile/poison/terror_spider/healer/AttackingTarget()
	. = ..()
	if(isterrorspider(target) && target != src) //no self healing
		var/mob/living/L = target
		if(L.stat != DEAD)
			if(fed <= 1)
				new /obj/effect/temp_visual/heal(get_turf(L), "#00ff00")
				L.adjustBruteLoss(-4)
			if(fed == 2)
				new /obj/effect/temp_visual/heal(get_turf(L), "#0077ff")
				L.adjustBruteLoss(-6)
			if(fed >= 3)
				new /obj/effect/temp_visual/heal(get_turf(L), "#ff0000")
				L.adjustBruteLoss(-8)

/obj/structure/spider/terrorweb/green
	name = "slimy web"
	desc = "Эта паутина частично состоит из нитей зелёной слизи."
	ru_names = list(
		NOMINATIVE = "скользкая паутина",
		GENITIVE = "скользкой паутины",
		DATIVE = "скользкой паутине",
		ACCUSATIVE = "скользкую паутину",
		INSTRUMENTAL = "скользкой паутиной",
		PREPOSITIONAL = "скользкой паутине",
	)

/obj/structure/spider/terrorweb/green/web_special_ability(mob/living/carbon/C)
	if(istype(C))
		if(C.AmountEyeBlurry() < 120 SECONDS)
			C.AdjustEyeBlurry(30 SECONDS, 0, 60 SECONDS)
