//Human hulk
/mob/living/simple_animal/hulk
	name = "Hulk"
	real_name = "Hulk"
	desc = "Huge and strong!"
	icon = 'icons/mob/hulk.dmi'
	icon_state = "Hulk"
	icon_living = "Hulk"
	maxHealth = 280
	health = 280
	speed = 1.25
	harm_intent_damage = 20
	melee_damage_lower = 20
	melee_damage_upper = 20

	speak_emote = list("roars")
	emote_hear = list("roars")
	tts_seed = "Grunt"
	response_help  = "thinks better of touching"
	response_disarm = "flails at"
	response_harm   = "punches"
	environment_smash = 2
	sentience_type = SENTIENCE_OTHER
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	status_flags = CANPUSH
	universal_speak = 1
	universal_understand = 1
	attack_sound = list('sound/weapons/punch1.ogg')
	var/hulk_powers = list()
	var/mob/living/original_body
	var/health_regen = 6

/mob/living/simple_animal/hulk/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		minbodytemp = 0, \
	)

/mob/living/simple_animal/hulk/human
	hulk_powers = list(/obj/effect/proc_holder/spell/hulk_jump,
	/obj/effect/proc_holder/spell/hulk_dash)
	tts_seed = "Grunt"

//Clown Hulk

/mob/living/simple_animal/hulk/clown_hulk
	name = "Champion of Honk"
	real_name = "Champion of Honk"
	icon = 'icons/mob/hulk.dmi'
	icon_state = "Champion of Honk"
	icon_living = "Champion of Honk"
	maxHealth = 175
	health = 175
	speed = 1
	harm_intent_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 5

	speak_emote = list("honks")
	emote_hear = list("honks")
	tts_seed = "Bandit"
	attack_sound = list('sound/items/bikehorn.ogg')
	health_regen = 24

	hulk_powers = list(/obj/effect/proc_holder/spell/hulk_honk,
	/obj/effect/proc_holder/spell/hulk_joke)

//Godzilla

/mob/living/simple_animal/hulk/zilla
	name = "Zilla"
	real_name = " Zilla"
	icon = 'icons/mob/zilla.dmi'
	icon_state = "zilla"
	icon_living = "zilla"
	maxHealth = 315
	health = 315
	speed = 1.5
	harm_intent_damage = 30
	melee_damage_lower = 30
	melee_damage_upper = 30

	speak_emote = list("gnaw")
	emote_hear = list("gnaw")
	tts_seed = "Huskar"
	attack_sound = list('sound/weapons/bite.ogg')

	hulk_powers = list(/obj/effect/proc_holder/spell/hulk_mill,
	/obj/effect/proc_holder/spell/fireball/hulk_spit,
	/obj/effect/proc_holder/spell/fireball/hulk_spit/hulk_lazor)

/mob/living/simple_animal/hulk/Life()
	if(HAS_TRAIT(src, TRAIT_PACIFISM) || GLOB.pacifism_after_gt)
		to_chat(src, "<span class='warning'>You don't want to harm other living beings, your angry is loss! You unmutate!</span>")
		unmutate()
		return

	var/matrix/Mx = matrix()
	if(health < maxHealth * 0.2)
		Mx.Scale(0.75)
		Mx.Translate(0,-5)
	else if(health < maxHealth * 0.4)
		Mx.Scale(0.8)
		Mx.Translate(0,-4)
	else if(health < maxHealth * 0.6)
		Mx.Scale(0.85)
		Mx.Translate(0,-3)
	else if(health < maxHealth * 0.8)
		Mx.Scale(0.9)
		Mx.Translate(0,-2)
	else
		Mx.Scale(1)
		Mx.Translate(0,0)
	transform = Mx

	var/datum/gas_mixture/environment = loc?.return_air()
	var/modifier = 0
	var/pressure = environment?.return_pressure()
	switch(pressure)
		if(-INFINITY to 5)
			modifier = 12
		if(6 to 25)
			modifier = 8
		if(26 to 45)
			modifier = 5
		if(46 to 55)
			modifier = 3
		if(110 to INFINITY)
			modifier = 7

	if(pressure <= 75 && prob(15))
		custom_emote(EMOTE_AUDIBLE, "задыха%(ет,ют)%ся")

	SetWeakened(0)
	adjustBruteLoss(modifier - health_regen)

	if(health < 1)
		death()
		return

	..()


/mob/living/simple_animal/hulk/death(gibbed)
	unmutate()

/mob/living/simple_animal/hulk/proc/unmutate()
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(amount = 10, location = src.loc)
	smoke.start()
	playsound(src, 'sound/effects/bamf.ogg', CHANNEL_BUZZ)

	var/obj/effect/decal/remains/human/RH = new /obj/effect/decal/remains/human(src.loc)
	var/matrix/Mx = matrix()
	Mx.Scale(1.5)
	RH.transform = Mx

	for(var/mob/mob in contents)
		mob.forceMove(loc)
		REMOVE_TRAIT(mob, TRAIT_GODMODE, UNIQUE_TRAIT_SOURCE(src))
		if(isliving(mob))
			var/mob/living/living = mob
			living.Paralyse(30 SECONDS)

	if(mind && original_body)
		mind.transfer_to(original_body)
	original_body.force_gene_block(GLOB.hulkblock, FALSE)
	to_chat(original_body, "<span class='danger'>You suddenly feel very weak.</span>")
	qdel(src)

/mob/living/proc/hulk_scream(obj/target, chance)
	if(prob(chance))
		visible_message("<span class='userdanger'>[src] has punched \the [target]!</span>",\
		"<span class='userdanger'>You punch the [target]!</span>",\
		"<span class='userdanger'>You feel some weird vibration!</span>")
		playsound(target, 'sound/effects/hulk_hit_airlock.ogg', CHANNEL_BUZZ, 75)
		return 0
	else
		say(pick("RAAAAAAAARGH!", "HNNNNNNNNNGGGGGGH!", "GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", "AAAAAAARRRGH!" ))
		visible_message("<span class='userdanger'>[src] has destroyed some mechanic in the [target]!</span>",\
		"<span class='userdanger'>You destroy some mechanic in the [target] door, which holds it in place!</span>",\
		"<span class='userdanger'>You feel some weird vibration!</span>")
		playsound(target, pick('sound/effects/explosion1.ogg', 'sound/effects/explosion2.ogg'), CHANNEL_BUZZ)
		return 1

/mob/living/simple_animal/hulk/proc/attack_hulk(obj/machinery/door/D)
	do_attack_animation(D)
	changeNext_move(CLICK_CD_MELEE)
	if(istype(D,/obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = D
		if(A.welded || A.locked)
			if(hulk_scream(A, 75))
				A.deconstruct(src)
			return
	if(istype(D,/obj/machinery/door/firedoor))
		var/obj/machinery/door/firedoor/F = D
		if(F.welded || F.locked)
			if(hulk_scream(F, 75))
				F.deconstruct(src);
				return
	if(D.density)
		to_chat(src, "<span class='userdanger'>You force your fingers between \
		 the doors and begin to pry them open...</span>")
		playsound(D, 'sound/machines/airlock_force_open.ogg', CHANNEL_BUZZ, 30, null, -4)
		D.open(1)

/mob/living/simple_animal/hulk/New()
	..()
	name = text("[initial(name)] ([rand(1, 1000)])")
	real_name = name
	status_flags ^= CANPUSH
	for(var/spell in hulk_powers)
		src.AddSpell(new spell)
