/obj/item/organ/internal/heart/gland
	name = "fleshy mass"
	desc = "A nausea-inducing hunk of twisting flesh and metal."
	ru_names = list(
		NOMINATIVE = "мясистая масса",
		GENITIVE = "мясистой массы",
		DATIVE = "мясистой массе",
		ACCUSATIVE = "мясистую массу",
		INSTRUMENTAL = "мясистой массой",
		PREPOSITIONAL = "мясистой массе"
	)
	icon = 'icons/obj/abductor.dmi'
	icon_state = "gland"
	dead_icon = null
	status = ORGAN_ROBOT
	origin_tech = "materials=4;biotech=7;abductor=3"
	beating = TRUE
	var/cooldown_low = 300
	var/cooldown_high = 300
	var/next_activation = 0
	var/uses // -1 For inifinite
	var/human_only = 0
	var/active = 0
	tough = TRUE //not easily broken by combat damage

	var/mind_control_uses = 1
	var/mind_control_duration = 1800
	var/active_mind_control = FALSE

/obj/item/organ/internal/heart/gland/update_icon_state()
	return

/obj/item/organ/internal/heart/gland/proc/ownerCheck()
	if(ishuman(owner))
		return TRUE
	if(!human_only && iscarbon(owner))
		return TRUE
	return FALSE

/obj/item/organ/internal/heart/gland/proc/Start()
	active = 1
	next_activation = world.time + rand(cooldown_low,cooldown_high)

/obj/item/organ/internal/heart/gland/proc/update_gland_hud()
	if(!owner)
		return
	var/image/holder = owner.hud_list[GLAND_HUD]
	var/icon/I = icon(owner.icon, owner.icon_state, owner.dir)
	holder.pixel_y = I.Height() - world.icon_size
	if(active_mind_control)
		holder.icon_state = "hudgland_active"
	else if(mind_control_uses)
		holder.icon_state = "hudgland_ready"
	else
		holder.icon_state = "hudgland_spent"

/obj/item/organ/internal/heart/gland/proc/mind_control(command, mob/living/user)
	if(!ownerCheck() || !mind_control_uses || active_mind_control)
		return
	mind_control_uses--
	to_chat(owner, "<span class='userdanger'>You suddenly feel an irresistible compulsion to follow an order...</span>")
	to_chat(owner, "<span class='mind_control'>[command]</span>")
	active_mind_control = TRUE
	log_admin("[key_name(user)] sent an abductor mind control message to [key_name(owner)]: [command]")
	message_admins("[key_name_admin(user)] sent an abductor mind control message to [key_name_admin(owner)]: [command]")
	add_say_logs(user, "to [owner]: [command]", "Abductor Mind Control")
	update_gland_hud()

	addtimer(CALLBACK(src, PROC_REF(clear_mind_control)), mind_control_duration)

/obj/item/organ/internal/heart/gland/proc/clear_mind_control()
	if(!ownerCheck() || !active_mind_control)
		return
	to_chat(owner, "<span class='userdanger'>You feel the compulsion fade, and you completely forget about your previous orders.</span>")
	active_mind_control = FALSE
	update_gland_hud()

/obj/item/organ/internal/heart/gland/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	active = FALSE
	if(initial(uses) == 1)
		uses = initial(uses)
	var/datum/atom_hud/abductor/hud = GLOB.huds[DATA_HUD_ABDUCTOR]
	hud.remove_from_hud(owner)
	clear_mind_control()
	. = ..()

/obj/item/organ/internal/heart/gland/insert(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	..()
	if(special != ORGAN_MANIPULATION_ABDUCTOR && uses)
		Start()
	var/datum/atom_hud/abductor/hud = GLOB.huds[DATA_HUD_ABDUCTOR]
	hud.add_to_hud(owner)
	update_gland_hud()

/obj/item/organ/internal/heart/gland/on_life()
	if(!beating)
		// alien glands are immune to stopping.
		beating = TRUE
	if(!active)
		return
	if(!ownerCheck())
		active = 0
		return
	if(next_activation <= world.time)
		activate()
		uses--
		next_activation  = world.time + rand(cooldown_low,cooldown_high)
	if(!uses)
		active = 0

/obj/item/organ/internal/heart/gland/proc/activate()
	return

/obj/item/organ/internal/heart/gland/heals
	cooldown_low = 200
	cooldown_high = 400
	uses = -1
	icon_state = "health"
	mind_control_uses = 3
	mind_control_duration = 3000

/obj/item/organ/internal/heart/gland/heals/activate()
	to_chat(owner, "<span class='notice'>You feel curiously revitalized.</span>")
	var/update = NONE
	update |= owner.heal_overall_damage(20, 20, updating_health = FALSE)
	update |= owner.heal_damages(tox = 20, oxy = 20, updating_health = FALSE)
	if(update)
		owner.updatehealth()

/obj/item/organ/internal/heart/gland/slime
	cooldown_low = 600
	cooldown_high = 1200
	uses = -1
	icon_state = "slime"
	mind_control_uses = 1
	mind_control_duration = 2400

/obj/item/organ/internal/heart/gland/slime/insert(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	..()
	owner.faction |= "slime"
	owner.add_language(LANGUAGE_SLIME)

/obj/item/organ/internal/heart/gland/slime/activate()
	to_chat(owner, "<span class='warning'>You feel nauseous!</span>")
	owner.vomit(20)

	var/mob/living/simple_animal/slime/Slime = new(get_turf(owner), "grey")
	Slime.Friends = list(owner)
	Slime.Leader = owner

/obj/item/organ/internal/heart/gland/mindshock
	origin_tech = "materials=4;biotech=4;magnets=6;abductor=3"
	cooldown_low = 400
	cooldown_high = 700
	uses = -1
	icon_state = "mindshock"
	mind_control_uses = 1
	mind_control_duration = 6000

/obj/item/organ/internal/heart/gland/mindshock/activate()
	to_chat(owner, "<span class='notice'>You get a headache.</span>")

	var/turf/T = get_turf(owner)
	for(var/mob/living/carbon/H in orange(4,T))
		if(H == owner)
			continue
		switch(rand(1, 3))
			if(1)
				to_chat(H, "<span class='userdanger'>You hear a loud buzz in your head, silencing your thoughts!</span>")
				H.Stun(6 SECONDS)
			if(2)
				to_chat(H, "<span class='warning'>You hear an annoying buzz in your head.</span>")
				H.AdjustConfused(30 SECONDS)
				H.apply_damage(rand(5, 15), BRAIN)
			if(3)
				H.AdjustHallucinate(60 SECONDS)

/obj/item/organ/internal/heart/gland/pop
	cooldown_low = 900
	cooldown_high = 1800
	uses = -1
	human_only = TRUE
	icon_state = "species"
	mind_control_uses = 5
	mind_control_duration = 3000

/obj/item/organ/internal/heart/gland/pop/activate()
	var/mob/living/carbon/human/h_owner = owner
	to_chat(h_owner, "<span class='notice'>You feel unlike yourself.</span>")
	var/obj/item/organ/internal/heart/gland/pop/gland = locate() in h_owner.internal_organs
	var/old_control_uses = initial(mind_control_uses)
	if(gland)
		old_control_uses = gland.mind_control_uses
	var/list/random_species = list(/datum/species/human, /datum/species/unathi, /datum/species/skrell, /datum/species/diona, /datum/species/tajaran, /datum/species/vulpkanin, /datum/species/kidan, /datum/species/grey)
	random_species -= h_owner.dna.species.type
	h_owner.set_species(pick(random_species), keep_missing_bodyparts = TRUE)
	addtimer(CALLBACK(h_owner, TYPE_PROC_REF(/mob/living/carbon/human, insert_new_gland), old_control_uses), 0)


/mob/living/carbon/human/proc/insert_new_gland(mind_controls)
	if(QDELETED(src))
		return
	var/obj/item/organ/internal/heart/gland/pop/replace_gland = new(src)
	replace_gland.mind_control_uses = mind_controls


/obj/item/organ/internal/heart/gland/ventcrawling
	origin_tech = "materials=4;biotech=5;bluespace=4;abductor=3"
	cooldown_low = 1800
	cooldown_high = 2400
	uses = 1
	icon_state = "vent"
	mind_control_uses = 4
	mind_control_duration = 1800


/obj/item/organ/internal/heart/gland/ventcrawling/activate()
	to_chat(owner, "<span class='notice'>You feel very stretchy.</span>")
	ADD_TRAIT(owner, TRAIT_VENTCRAWLER_ALWAYS, type)


/obj/item/organ/internal/heart/gland/viral
	cooldown_low = 1800
	cooldown_high = 2400
	uses = 1
	icon_state = "viral"
	mind_control_uses = 1
	mind_control_duration = 1800

/obj/item/organ/internal/heart/gland/viral/activate()
	to_chat(owner, "<span class='warning'>You feel sick.</span>")
	var/datum/disease/virus/advance/new_virus
	new_virus = CreateRandomVirus(count_of_symptoms = rand(4, 6), resistance = rand(0,11), stealth = pick(0,0,1,1,2),
								stage_rate = rand(-11,5), transmittable = rand(2,9), severity = rand(0,5))
	var/datum/disease/virus/advance/old_virus = locate() in owner.diseases
	if(old_virus)
		old_virus.cure(need_immunity = FALSE)
	new_virus.Contract(owner, is_carrier = TRUE)

/obj/item/organ/internal/heart/gland/emp //TODO : Replace with something more interesting
	origin_tech = "materials=4;biotech=4;magnets=6;abductor=3"
	cooldown_low = 800
	cooldown_high = 1200
	uses = 10
	icon_state = "emp"
	mind_control_uses = 3
	mind_control_duration = 1800
	emp_proof = TRUE	// EMP should not stop our own heart instantly

/obj/item/organ/internal/heart/gland/emp/activate()
	to_chat(owner, "<span class='warning'>You feel a spike of pain in your head.</span>")
	empulse(get_turf(owner), 2, 5, TRUE, "Alien EMP Organ")

/obj/item/organ/internal/heart/gland/spiderman
	cooldown_low = 450
	cooldown_high = 900
	uses = -1
	icon_state = "spider"
	mind_control_uses = 2
	mind_control_duration = 2400

/obj/item/organ/internal/heart/gland/spiderman/activate()
	to_chat(owner, "<span class='warning'>You feel something crawling in your skin.</span>")
	owner.faction |= "spiders"
	var/obj/structure/spider/spiderling/S = new(owner.loc)
	S.master_commander = owner

/obj/item/organ/internal/heart/gland/egg
	cooldown_low = 300
	cooldown_high = 400
	uses = -1
	icon_state = "egg"
	mind_control_uses = 2
	mind_control_duration = 1800

/obj/item/organ/internal/heart/gland/egg/activate()
	owner.visible_message("<span class='alertalien'>[owner] [pick(EGG_LAYING_MESSAGES)]</span>")
	new /obj/item/reagent_containers/food/snacks/egg/gland(get_turf(owner))

/obj/item/organ/internal/heart/gland/electric
	cooldown_low = 800
	cooldown_high = 1200
	uses = -1
	mind_control_uses = 2
	mind_control_duration = 900

/obj/item/organ/internal/heart/gland/electric/insert(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	if(ishuman(owner))
		owner.gene_stability += GENE_INSTABILITY_MODERATE // give them this gene for free
		owner.force_gene_block(GLOB.shockimmunityblock, TRUE)

/obj/item/organ/internal/heart/gland/electric/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	if(ishuman(owner))
		owner.gene_stability -= GENE_INSTABILITY_MODERATE // but return it to normal once it's removed
		owner.force_gene_block(GLOB.shockimmunityblock, FALSE)
	return ..()

/obj/item/organ/internal/heart/gland/electric/activate()
	owner.visible_message("<span class='danger'>[owner]'s skin starts emitting electric arcs!</span>",\
	"<span class='warning'>You feel electric energy building up inside you!</span>")
	playsound(get_turf(owner), "sparks", 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	addtimer(CALLBACK(src, PROC_REF(zap)), rand(30, 100))

/obj/item/organ/internal/heart/gland/electric/proc/zap()
	tesla_zap(owner, 4, 8000)
	playsound(get_turf(owner), 'sound/magic/lightningshock.ogg', 50, 1)

/obj/item/organ/internal/heart/gland/chem
	cooldown_low = 50
	cooldown_high = 50
	uses = -1
	mind_control_uses = 3
	mind_control_duration = 1200

/obj/item/organ/internal/heart/gland/chem/activate()
	owner.reagents.add_reagent(get_random_reagent_id(), 2)
	owner.adjustToxLoss(-2)
	..()

/obj/item/organ/internal/heart/gland/bloody
	cooldown_low = 200
	cooldown_high = 400
	uses = -1

/obj/item/organ/internal/heart/gland/bloody/activate()
	owner.AdjustBlood(-20)

	owner.visible_message(span_danger("Из кожи [owner] льётся кровь!"), \
	span_userdanger("Из вашей кожи хлещет кровь!"))

	for(var/turf/T in oview(3, owner)) // Make this respect walls and such
		owner.add_splatter_floor(T)

	for(var/mob/living/carbon/human/H in oview(3, owner)) // Blood decals for simple animals would be neat. aka Carp with blood on it.
		H.add_mob_blood(owner)


/obj/item/organ/internal/heart/gland/plasma
	cooldown_low = 1200
	cooldown_high = 1800
	origin_tech = "materials=4;biotech=4;plasmatech=6;abductor=3"
	uses = -1
	mind_control_uses = 1
	mind_control_duration = 800

/obj/item/organ/internal/heart/gland/plasma/activate()
	spawn(0)
		to_chat(owner, "<span class='warning'>You feel bloated.</span>")
		sleep(150)
		if(!owner)
			return
		to_chat(owner, "<span class='userdanger'>A massive stomachache overcomes you.</span>")
		sleep(50)
		if(!owner)
			return
		owner.visible_message("<span class='danger'>[owner] vomits a cloud of plasma!</span>")
		var/turf/simulated/T = get_turf(owner)
		if(istype(T))
			T.atmos_spawn_air(LINDA_SPAWN_TOXINS|LINDA_SPAWN_20C,50)
		owner.vomit()
