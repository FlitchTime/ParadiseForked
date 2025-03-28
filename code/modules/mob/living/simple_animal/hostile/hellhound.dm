// Hellhound
/mob/living/simple_animal/hostile/hellhound
	// Sprites by FoS: https://www.paradisestation.org/forum/profile/335-fos
	name = "lesser hellhound"
	desc = "A demonic-looking black canine monster with glowing red eyes and sharp teeth. A firey, lava-like substance drips from it."
	icon_state = "hellhound"
	icon_living = "hellhound"
	icon_dead = "hellhound_dead"
	icon_resting = "hellhound_rest"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	mobility_flags = MOBILITY_FLAGS_REST_CAPABLE_DEFAULT
	melee_damage_lower = 10 // slightly higher than araneus
	melee_damage_upper = 30
	a_intent = INTENT_HARM
	environment_smash = 1
	speak_chance = 0
	speed = 0
	maxHealth = 250 // same as sgt araneus
	health = 250
	obj_damage = 50
	robust_searching = 1
	stat_attack = UNCONSCIOUS
	attacktext = "кусает"
	attack_sound = 'sound/effects/bite.ogg'
	speak_emote = list("growls")
	nightvision = 9
	universal_understand = 1
	wander = 0
	AI_delay_max = 0.5 SECONDS
	var/life_regen_cycles = 0
	var/life_regen_cycle_trigger = 10 // heal once for every X number of cycles spent resting
	var/life_regen_amount = -10 // negative, because negative = healing
	var/smoke_lastuse = 0
	var/smoke_freq = 300 // 30 seconds
	var/datum/action/innate/demon/whisper/whisper_action


/mob/living/simple_animal/hostile/hellhound/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_BREATH, INNATE_TRAIT)
	whisper_action = new()
	whisper_action.Grant(src)

/mob/living/simple_animal/hostile/hellhound/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		minbodytemp = 0, \
		maxbodytemp = INFINITY, \
	)

/mob/living/simple_animal/hostile/hellhound/handle_automated_action()
	if(!..())
		return
	if(resting)
		if(!wants_to_rest())
			custom_emote(EMOTE_AUDIBLE, "рыч%(ит,ат)% и поднима%(ет,ют)%ся.")
			playsound(get_turf(src), 'sound/hallucinations/growl2.ogg', 50, 1)
			set_resting(FALSE, instant = TRUE)
	else if(wants_to_rest())
		custom_emote(EMOTE_VISIBLE, "лож%(ит,ат)%ся и начина%(ет,ют)% зализывать свои раны.")
		set_resting(TRUE, instant = TRUE)

/mob/living/simple_animal/hostile/hellhound/examine(mob/user)
	. = ..()
	if(stat != DEAD)
		var/list/msgs = list()
		if(key)
			msgs += "<span class='warning'>Its eyes have the spark of intelligence.</span>"
		if(health > (maxHealth*0.95))
			msgs += "<span class='notice'>It appears to be in excellent health.</span>"
		else if(health > (maxHealth*0.75))
			msgs += "<span class='notice'>It has a few injuries.</span>"
		else if(health > (maxHealth*0.55))
			msgs += "<span class='warning'>It has many injuries.</span>"
		else if(health > (maxHealth*0.25))
			msgs += "<span class='warning'>It is covered in wounds!</span>"
		if(resting)
			if(getBruteLoss() || getFireLoss())
				msgs += "<span class='warning'>It is currently licking its wounds, regenerating the damage to its body!</span>"
			else
				msgs += "<span class='notice'>It is currently resting.</span>"
		. += msgs.Join("<br>")

/mob/living/simple_animal/hostile/hellhound/Life(seconds, times_fired)
	. = ..()
	if(stat != DEAD && resting && (getBruteLoss() || getFireLoss()))
		if(life_regen_cycles >= life_regen_cycle_trigger)
			life_regen_cycles = 0
			to_chat(src, "<span class='notice'>You lick your wounds, helping them close.</span>")
			heal_overall_damage(life_regen_amount, life_regen_amount)
		else
			life_regen_cycles++

/mob/living/simple_animal/hostile/hellhound/proc/wants_to_rest()
	if(target)
		return FALSE
	if(getBruteLoss() || getFireLoss())
		return TRUE
	return FALSE


/mob/living/simple_animal/hostile/hellhound/attackby(obj/item/I, mob/user, params)
	var/current_health = health
	. = ..()
	if(ATTACK_CHAIN_CANCEL_CHECK(.) || health >= current_health)
		return .
	var/mob/living/living_target = target
	if(isliving(target) && living_target.stat != CONSCIOUS)
		GiveTarget(user)


/mob/living/simple_animal/hostile/hellhound/greater
	name = "greater hellhound"
	desc = "A demonic-looking black canine monster with glowing red eyes and sharp teeth. Greater hounds are far stronger than their lesser kin, and typically employed by powerful bluespace entities."
	icon_state = "hellhoundgreater"
	icon_living = "hellhoundgreater"
	icon_resting = "hellhoundgreater_sit"
	maxHealth = 400
	health = 400
	force_threshold = 5 // no punching
	universal_speak = 1
	smoke_freq = 200
	life_regen_cycle_trigger = 5
	melee_damage_lower = 20
	melee_damage_upper = 30
	environment_smash = 2

/mob/living/simple_animal/hostile/hellhound/greater/Initialize(mapload)
	. = ..()
	// Movement
	AddSpell(new /obj/effect/proc_holder/spell/ethereal_jaunt/shift)
	var/obj/effect/proc_holder/spell/area_teleport/teleport/telespell = new
	telespell.clothes_req = FALSE
	telespell.human_req = FALSE
	telespell.invocation_type = "none"
	AddSpell(telespell)
	var/obj/effect/proc_holder/spell/aoe/knock/knockspell = new
	knockspell.invocation_type = "none"
	AddSpell(knockspell)
	// Defense
	var/obj/effect/proc_holder/spell/forcewall/greater/wallspell = new
	wallspell.clothes_req = FALSE
	wallspell.human_req = FALSE
	wallspell.invocation_type = "none"
	AddSpell(wallspell)
	// Offense
	var/obj/effect/proc_holder/spell/aoe/conjure/creature/summonspell = new
	summonspell.base_cooldown = 1
	summonspell.invocation_type = "none"
	summonspell.summon_type = list(/mob/living/simple_animal/hostile/hellhound)
	summonspell.summon_amt = 1
	AddSpell(summonspell)

/mob/living/simple_animal/hostile/hellhound/greater/AttackingTarget()
	. = ..()
	if(. && ishuman(target) && (!client || a_intent == INTENT_HARM))
		special_aoe()

/mob/living/simple_animal/hostile/hellhound/greater/proc/special_aoe()
	if(world.time < (smoke_lastuse + smoke_freq))
		return
	smoke_lastuse = world.time
	var/datum/effect_system/fluid_spread/smoke/sleeping/smoke = new
	smoke.set_up(amount = 10, location = loc)
	smoke.start()
