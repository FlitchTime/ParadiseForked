/obj/item/storage/pill_bottle/dice
	name = "dice pack"
	desc = "Мешочек с игральными костями внутри."
	ru_names = list(
        NOMINATIVE = "мешок игральных костей",
        GENITIVE = "мешка игральных костей",
        DATIVE = "мешку игральных костей",
        ACCUSATIVE = "мешок игральных костей",
        INSTRUMENTAL = "мешком игральных костей",
        PREPOSITIONAL = "мешке игральных костей"
	)
	icon = 'icons/obj/dice.dmi'
	icon_state = "dicebag"
	can_hold = list(/obj/item/dice)
	allow_wrap = FALSE


/obj/item/storage/pill_bottle/dice/populate_contents()
	var/special_die = pick("1", "2", "fudge", "00", "100")
	if(special_die == "1")
		new /obj/item/dice/d1(src)
	if(special_die == "2")
		new /obj/item/dice/d2(src)
	new /obj/item/dice/d4(src)
	new /obj/item/dice/d6(src)
	if(special_die == "fudge")
		new /obj/item/dice/fudge(src)
	new /obj/item/dice/d8(src)
	new /obj/item/dice/d10(src)
	if(special_die == "00")
		new /obj/item/dice/d00(src)
	new /obj/item/dice/d12(src)
	new /obj/item/dice/d20(src)
	if(special_die == "100")
		new /obj/item/dice/d100(src)


/obj/item/storage/box/dice
	name = "Коробка игральных костей"
	desc = "ЕЩЁ ОДНИ!? ДА БЛЯДЬ!"
	icon_state = "box"


/obj/item/storage/box/dice/populate_contents()
	new /obj/item/dice/d2(src)
	new /obj/item/dice/d4(src)
	new /obj/item/dice/d8(src)
	new /obj/item/dice/d10(src)
	new /obj/item/dice/d00(src)
	new /obj/item/dice/d12(src)
	new /obj/item/dice/d20(src)


/obj/item/storage/pill_bottle/dice/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] Игра[pluralize_ru(user.gender,"ет","ют")] со смертью! Похоже, он[genderize_ru(user.gender,"","а","о","и")] пыта[pluralize_ru(user.gender,"ется","ются")] покончить жизнь самоубийством!</span>")
	return (OXYLOSS)

/obj/item/dice //depreciated d6, use /obj/item/dice/d6 if you actually want a d6
	name = "dice"
	desc = "Кость с шестью гранями. Непримечательна и проста в обращении."
	ru_names = list(
		NOMINATIVE = "игральная кость",
		GENITIVE = "игральной кости",
		DATIVE = "игральной кости",
		ACCUSATIVE = "игральную кость",
		INSTRUMENTAL = "игральной костью",
		PREPOSITIONAL = "игральной кости"
	)
	gender = FEMALE
	icon = 'icons/obj/dice.dmi'
	icon_state = "d6"
	w_class = WEIGHT_CLASS_TINY

	var/sides = 6
	var/result = null
	var/list/special_faces = list() //entries should match up to sides var if used

	var/rigged = DICE_NOT_RIGGED
	var/rigged_value


/obj/item/dice/Initialize(mapload)
	. = ..()
	if(!result)
		result = roll(sides)
	update_icon(UPDATE_OVERLAYS)


/obj/item/dice/update_overlays()
	. = ..()
	. += "[icon_state][result]"


/obj/item/dice/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] играет со смертью! Похоже [user.p_theyre()] пытается покончить жизнь самоубийством!</span>")
	return (OXYLOSS)

/obj/item/dice/d1
	name = "d1"
	desc = "Кость с одной гранью. Очень детерминировано!"
	icon_state = "d1"
	sides = 1

/obj/item/dice/d2
	name = "d2"
	desc = "Кость с двумя гранями. Если монеты вас не достойны."
	icon_state = "d2"
	sides = 2

/obj/item/dice/d4
	name = "d4"
	desc = "Кость с четырьмя гранями. По задротски - «чеснок»."
	icon_state = "d4"
	sides = 4

/obj/item/dice/d4/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/caltrop, 1, 4) //1d4 damage

/obj/item/dice/d6
	name = "d6"

/obj/item/dice/fudge
	name = "Fudge-кость"
	desc = "Кость с шестью гранями, но только с тремя результатами. Это плюс или минус? Ваш разум опустел..."
	sides = 3
	icon_state = "fudge"
	special_faces = list("minus","blank","plus")

/obj/item/dice/d8
	name = "d8"
	desc = "Кость с восемью гранями. Кажется… везучей."
	icon_state = "d8"
	sides = 8

/obj/item/dice/d10
	name = "d10"
	desc = "Кость с десятью гранями. Полезно для процентов."
	icon_state = "d10"
	sides = 10

/obj/item/dice/d00
	name = "d00"
	desc = "Кость с десятью гранями. Подходит для бросков d100 лучше мяча для гольфа."
	icon_state = "d00"
	sides = 10

/obj/item/dice/d12
	name = "d12"
	desc = "Кость с двенадцатью гранями. Похоже им никогда не пользовались..."
	icon_state = "d12"
	sides = 12

/obj/item/dice/d20
	name = "d20"
	desc = "Кость с двадцатью гранями. Именно такой чаще всего бросают в игровых мастеров."
	icon_state = "d20"
	sides = 20

/obj/item/dice/d100
	name = "d100"
	desc = "Игральная кость с сотней граней! Вряд ли развесовка выверена…"
	icon_state = "d100"
	sides = 100


/obj/item/dice/d100/update_overlays()
	return list()


/obj/item/dice/d20/e20
	var/triggered = FALSE

/obj/item/dice/attack_self(mob/user)
	diceroll(user)

/obj/item/dice/throw_impact(atom/target, datum/thrownthing/throwingdatum)
	diceroll(locateUID(thrownby))
	. = ..()

/obj/item/dice/proc/diceroll(mob/user)
	result = roll(sides)
	if(rigged != DICE_NOT_RIGGED && result != rigged_value)
		if(rigged == DICE_BASICALLY_RIGGED && prob(clamp(1 / (sides - 1) * 100, 25, 80)))
			result = rigged_value
		else if(rigged == DICE_TOTALLY_RIGGED)
			result = rigged_value

	. = result

	var/fake_result = roll(sides)//Daredevil isn't as good as he used to be
	var/comment = ""
	if(sides == 20 && result == 20)
		comment = "ДВАДЦАТКА!"
	else if(sides == 20 && result == 1)
		comment = "М-да, невезуха."
	update_icon(UPDATE_OVERLAYS)
	if(initial(icon_state) == "d00")
		result = (result - 1) * 10
	if(length(special_faces) == sides)
		result = special_faces[result]
	if(user != null) //Dice was rolled in someone's hand
		user.visible_message("[user] броса[pluralize_ru(user.gender,"ет","ют")] [src.name]. На [src.name] выпадает [result]. [comment]",
							 "<span class='notice'>Вы бросили [src.name] и выпало [result]. [comment]</span>",
							 "<span class='italics'>Вы слышите как катится [src.name], звучит как [fake_result].</span>")
	else if(!throwing) //Dice was thrown and is coming to rest
		visible_message("<span class='notice'>[src.name] прекращает катиться, остановившись на [result]. [comment]</span>")

/obj/item/dice/d20/e20/diceroll(mob/user, thrown)
	if(triggered)
		return

	. = ..()

	if(result == 1)
		to_chat(user, "<span class='danger'>На вас упали камни и вы умерли.</span>")
		user.gib()
		add_attack_logs(src, user, "detonated with a roll of [result], gibbing them!", ATKLOG_FEW)
	else
		triggered = TRUE
		visible_message("<span class='notice'>Вы слышите тихий щелчок.</span>")
		addtimer(CALLBACK(src, PROC_REF(boom), user, result), 4 SECONDS)

/obj/item/dice/d20/e20/proc/boom(mob/user, result)
	var/capped = FALSE
	var/actual_result = result
	if(result != 20)
		capped = TRUE
		result = min(result, GLOB.max_ex_light_range) // Apply the bombcap
	else // Rolled a nat 20, screw the bombcap
		result = 24

	var/turf/epicenter = get_turf(src)
	investigate_log("E20 detonated with a roll of [actual_result]. Triggered by: [key_name_log(user)]", INVESTIGATE_BOMB)
	add_game_logs("threw E20, detonating at [AREACOORD(epicenter)] with a roll of [actual_result].", user)
	add_attack_logs(user, src, "detonated with a roll of [actual_result]", ATKLOG_FEW)
	explosion(epicenter, round(result * 0.25), round(result * 0.5), round(result), round(result * 1.5), TRUE, capped, cause = key_name(user)+" E20")


// Die of Fate
/obj/item/dice/d20/fate
	name = "\improper Die of Fate"
	desc = "A die with twenty sides. You can feel unearthly energies radiating from it. Using this might be VERY risky."
	icon_state = "d20"
	var/reusable = TRUE
	var/used = FALSE

/obj/item/dice/d20/fate/stealth
	name = "d20"
	desc = "A die with twenty sides. The preferred die to throw at the GM."

/obj/item/dice/d20/fate/one_use
	reusable = FALSE

/obj/item/dice/d20/fate/one_use/stealth
	name = "d20"
	desc = "A die with twenty sides. The preferred die to throw at the GM."

/obj/item/dice/d20/fate/cursed
	name = "cursed Die of Fate"
	desc = "A die with twenty sides. You feel that rolling this is a REALLY bad idea."
	color = "#00BB00"

	rigged = DICE_TOTALLY_RIGGED
	rigged_value = 1

/obj/item/dice/d20/fate/diceroll(mob/user)
	. = ..()
	if(!used)
		if(!ishuman(user) || !user.mind || (user.mind in SSticker.mode.wizards))
			to_chat(user, "<span class='warning'>You feel the magic of the dice is restricted to ordinary humans!</span>")
			return

		if(!reusable)
			used = TRUE

		var/turf/T = get_turf(src)
		T.visible_message("<span class='userdanger'>[src] flares briefly.</span>")

		addtimer(CALLBACK(src, PROC_REF(effect), user, .), 1 SECONDS)

/obj/item/dice/d20/fate/equipped(mob/user, slot, initial)
	. = ..()

	if(!ishuman(user) || !user.mind || (user.mind in SSticker.mode.wizards))
		to_chat(user, "<span class='warning'>You feel the magic of the dice is restricted to ordinary humans! You should leave it alone.</span>")
		user.drop_item_ground(src)

/obj/item/dice/d20/fate/proc/create_smoke(amount)
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(amount = amount, location = drop_location())
	smoke.start()

/obj/item/dice/d20/fate/proc/effect(mob/living/carbon/human/user, roll)
	var/turf/T = get_turf(src)
	switch(roll)
		if(1)
			//Dust
			T.visible_message("<span class='userdanger'>[user] turns to dust!</span>")
			user.dust()
		if(2)
			//Death
			T.visible_message("<span class='userdanger'>[user] suddenly dies!</span>")
			user.death()
		if(3)
			//Swarm of creatures
			T.visible_message("<span class='userdanger'>A swarm of creatures surround [user]!</span>")
			for(var/direction in GLOB.alldirs)
				new /mob/living/simple_animal/hostile/netherworld(get_step(get_turf(user),direction))
		if(4)
			//Destroy Equipment
			T.visible_message("<span class='userdanger'>Everything [user] is holding and wearing disappears!</span>")
			for(var/obj/item/I in user)
				if(istype(I, /obj/item/implant) || istype(I, /obj/item/organ))
					continue
				qdel(I)
		if(5)
			//Monkeying
			T.visible_message("<span class='userdanger'>[user] transforms into a monkey!</span>")
			user.monkeyize()
		if(6)
			//Cut speed
			T.visible_message("<span class='userdanger'>[user] starts moving slower!</span>")
			user.add_movespeed_modifier(/datum/movespeed_modifier/die_of_fate)
		if(7)
			//Throw
			T.visible_message("<span class='userdanger'>Unseen forces throw [user]!</span>")
			user.Stun(12 SECONDS)
			user.adjustBruteLoss(50)
			var/throw_dir = GLOB.cardinal
			var/atom/throw_target = get_edge_target_turf(user, throw_dir)
			user.throw_at(throw_target, 200, 4)
		if(8)
			//Fueltank Explosion
			T.visible_message("<span class='userdanger'>An explosion bursts into existence around [user]!</span>")
			explosion(get_turf(user),-1,0,2, flame_range = 2, cause = src)
		if(9)
			//Cold
			T.visible_message("<span class='userdanger'>[user] looks a little under the weather!</span>")
			var/datum/disease/virus/cold/D = new
			D.Contract(user)
		if(10)
			//Nothing
			T.visible_message("<span class='userdanger'>Nothing seems to happen.</span>")
		if(11)
			//Cookie
			T.visible_message("<span class='userdanger'>A cookie appears out of thin air!</span>")
			var/obj/item/reagent_containers/food/snacks/cookie/C = new(drop_location())
			create_smoke(2)
			C.name = "Cookie of Fate"
		if(12)
			//Healing
			T.visible_message("<span class='userdanger'>[user] looks very healthy!</span>")
			user.revive()
		if(13)
			//Mad Dosh
			T.visible_message("<span class='userdanger'>Mad dosh shoots out of [src]!</span>")
			var/turf/Start = get_turf(src)
			for(var/direction in GLOB.alldirs)
				var/turf/dirturf = get_step(Start,direction)
				if(rand(0,1))
					new /obj/item/stack/spacecash/c1000(dirturf)
				else
					var/obj/item/storage/bag/money/M = new(dirturf)
					for(var/i in 1 to rand(5,50))
						new /obj/item/coin/gold(M)
		if(14)
			//Free Gun
			T.visible_message("<span class='userdanger'>An impressive gun appears!</span>")
			create_smoke(2)
			new /obj/item/gun/projectile/revolver/mateba(drop_location())
		if(15)
			//Random One-use spellbook
			T.visible_message("<span class='userdanger'>A magical looking book drops to the floor!</span>")
			create_smoke(2)
			new /obj/item/spellbook/oneuse/random(drop_location())
		if(16)
			//Servant & Servant Summon
			T.visible_message("<span class='userdanger'>A Dice Servant appears in a cloud of smoke!</span>")
			var/mob/living/carbon/human/H = new(drop_location())
			create_smoke(2)

			H.equipOutfit(/datum/outfit/butler)
			var/datum/mind/servant_mind = new /datum/mind()
			var/datum/objective/O = new
			O.owner = servant_mind
			O.target = user.mind
			O.explanation_text = "Служить [user.real_name]."
			O.antag_menu_name = "Служить"
			servant_mind.objectives += O
			servant_mind.transfer_to(H)

			var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Вы хотите поиграть играть за слугу [user.real_name]?", ROLE_WIZARD, role_cleanname = "слугу", poll_time = 30 SECONDS, source = H)
			if(LAZYLEN(candidates))
				var/mob/dead/observer/C = pick(candidates)
				message_admins("[ADMIN_LOOKUPFLW(C)] was spawned as Dice Servant")
				H.key = C.key
				to_chat(H, span_notice("Вы слуга [user.real_name]. Вы должны сделать всё, что в ваших силах, чтобы выполнить [genderize_ru(user.gender, "его", "eё", "его", "их")] приказы."))

			var/obj/effect/proc_holder/spell/summonmob/S = new
			S.target_mob = H
			user.mind.AddSpell(S)

		if(17)
			//Choose from 1 of 3 random syndie bundles
			T.visible_message("<span class='userdanger'>A suspicious radio beacon appears!</span>")
			new /obj/item/radio/beacon/syndicate/bundle/magical(drop_location())
			create_smoke(2)
		if(18)
			//Captain ID
			T.visible_message("<span class='userdanger'>A golden identification card appears!</span>")
			new /obj/item/card/id/captains_spare(drop_location())
			create_smoke(2)
		if(19)
			//Instrinct Resistance
			T.visible_message("<span class='userdanger'>[user] looks very robust!</span>")
			user.physiology.brute_mod *= 0.5
			user.physiology.burn_mod *= 0.5

		if(20)
			//Free wizard!
			T.visible_message("<span class='userdanger'>Magic flows out of [src] and into [user]!</span>")
			user.mind.make_Wizard()

