//Helper object for picking dionaea (and other creatures) up.
/obj/item/holder
	name = "holder"
	desc = "You shouldn't ever see this."
	icon = 'icons/obj/objects.dmi'
	lefthand_file = 'icons/mob/inhands/mobs_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/mobs_righthand.dmi'
	slot_flags = ITEM_SLOT_HEAD
	origin_tech = "biotech=2"
	holder_flags = HUMAN_HOLDER


/obj/item/holder/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/holder/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/holder/process()

	if(istype(loc,/turf) || !(contents.len))

		for(var/mob/M in contents)

			var/atom/movable/mob_container
			mob_container = M
			mob_container.forceMove(get_turf(src))

		qdel(src)


/obj/item/holder/attackby(obj/item/I, mob/user, params)
	for(var/mob/living/animal in contents)
		return animal.attackby(I, user, params)
	return ..()


/obj/item/holder/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(target == user && ishuman(user))	//eating holder
		for(var/mob/living/mob in contents)
			if(mob.devoured(user))
				qdel(src)
				return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/item/holder/proc/show_message(message, m_type, chat_message_type)
	for(var/mob/living/M in contents)
		M.show_message(message, m_type, chat_message_type)

/obj/item/holder/emp_act(intensity)
	for(var/mob/living/M in contents)
		M.emp_act(intensity)

/obj/item/holder/ex_act(intensity)
	for(var/mob/living/M in contents)
		M.ex_act(intensity)

/obj/item/holder/container_resist(mob/living/L)
	var/mob/M = src.loc                      //Get our mob holder (if any).

	if(istype(M))
		M.drop_item_ground(src)
		to_chat(M, "[src.name] вырывается из вашей хватки!")
		to_chat(L, "Вы вырываетесь из хвата [M.name]!")
	else if(isitem(loc))
		to_chat(L, "Вы выбираетесь из [loc].")
		forceMove(get_turf(src))

	if(istype(M))
		for(var/atom/A in M.contents)
			if(istype(A,/mob/living/simple_animal/borer) || istype(A,/obj/item/holder))
				return
		M.status_flags &= ~PASSEMOTES


//Mob procs and vars for scooping up
/mob/living
	var/holder_type = null

/mob/living/simple_animal/MouseDrop(atom/over_object)
	var/mob/living/carbon/human_to_ask = over_object

	if(!istype(human_to_ask))
		return ..()

	if(holder_type)
		var/obj/item/holder = holder_type
		var/holder_flags = holder.holder_flags
		if(!(holder_flags & ALIEN_HOLDER && isalien(human_to_ask)) && \
		!(holder_flags & HUMAN_HOLDER && ishuman(human_to_ask)))
			return ..()

	if(human_to_ask.incapacitated() || HAS_TRAIT(human_to_ask, TRAIT_HANDS_BLOCKED) || !Adjacent(human_to_ask) || !holder_type)
		return ..()

	if(usr == src)
		switch(tgui_alert(human_to_ask, "[src] wants you to pick [p_them()] up. Do it?",,list("Yes","No")))
			if("Yes")
				if(Adjacent(human_to_ask))
					pick_up_mob(human_to_ask)
				else
					to_chat(src, "<span class='warning'>You need to stay in reaching distance to be picked up.</span>")
			if("No")
				to_chat(src, "<span class='warning'>[human_to_ask] decided not to pick you up.</span>")
	else
		return ..()

/mob/living/simple_animal/proc/pick_up_mob(mob/living/carbon/human_to_ask)
	get_scooped(human_to_ask)

/mob/living/proc/get_scooped(mob/living/carbon/grabber)
	if(!holder_type)
		return

	var/obj/item/holder/H = new holder_type(loc)
	src.forceMove(H)
	H.name = name
	H.icon = icon
	H.icon_state = icon_state
	if(desc)
		H.desc = desc
	H.attack_hand(grabber)
	to_chat(grabber, "<span class='notice'>Вы подняли [src.name].")
	to_chat(src, "<span class='notice'>[grabber.name] поднял[genderize_ru(grabber.gender,"","а","о","и")] вас.</span>")
	grabber.status_flags |= PASSEMOTES

	switch(mob_size)
		if(MOB_SIZE_TINY)
			H.w_class = WEIGHT_CLASS_TINY
		if(MOB_SIZE_SMALL)
			H.w_class = WEIGHT_CLASS_SMALL
		if(MOB_SIZE_HUMAN)
			H.w_class = WEIGHT_CLASS_NORMAL
		if(MOB_SIZE_LARGE)
			H.w_class = WEIGHT_CLASS_HUGE

	return H

//Mob specific holders.

/obj/item/holder/diona
	name = "diona nymph"
	desc = "It's a tiny plant critter."
	icon_state = "nymph"
	origin_tech = "biotech=5"

/obj/item/holder/drone
	name = "maintenance drone"
	desc = "It's a small maintenance robot."
	icon_state = "drone"
	origin_tech = "materials=3;programming=4;powerstorage=3;engineering=4"

/obj/item/holder/drone/emagged
	name = "maintenance drone"
	icon_state = "drone-emagged"
	origin_tech = "materials=3;programming=4;powerstorage=3;engineering=4;syndicate=3"

/obj/item/holder/cogscarab
	name = "cogscarab"
	desc = "A strange, drone-like machine. It constantly emits the hum of gears."
	icon_state = "drone_holder"
	origin_tech = "materials=3;magnets=4;powerstorage=9;bluespace=4"

/obj/item/holder/pai
	name = "pAI"
	desc = "It's a little robot."
	icon_state = "pai"
	origin_tech = "materials=3;programming=4;engineering=4"

/obj/item/holder/mouse
	name = "mouse"
	desc = "It's a small, disease-ridden rodent."
	icon = 'icons/mob/animal.dmi'
	icon_state = "mouse_gray"

/obj/item/holder/monkey
	name = "monkey"
	desc = "It's a monkey"
	icon_state = "monkey"
	origin_tech = "biotech=3"

/obj/item/holder/farwa
	name = "farwa"
	desc = "It's a farwa"
	icon_state = "farwa"
	origin_tech = "biotech=3"

/obj/item/holder/stok
	name = "stok"
	desc = "It's a stok"
	icon_state = "stok"
	origin_tech = "biotech=3"

/obj/item/holder/neara
	name = "neara"
	desc = "It's a neara"
	icon_state = "neara"
	origin_tech = "biotech=3"

/obj/item/holder/corgi
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/pets.dmi'
	icon_state = "corgi"

/obj/item/holder/lisa
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/pets.dmi'
	icon_state = "lisa"

/obj/item/holder/old_corgi
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/pets.dmi'
	icon_state = "old_corgi"

/obj/item/holder/borgi
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/pets.dmi'
	icon_state = "borgi"

/obj/item/holder/void_puppy
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/pets.dmi'
	icon_state = "void_puppy"
	origin_tech = "biotech=4;bluespace=5"

/obj/item/holder/slime_puppy
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/pets.dmi'
	icon_state = "slime_puppy"
	origin_tech = "biotech=6"

/obj/item/holder/narsian
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/pets.dmi'
	icon_state = "narsian"
	slot_flags = null
	origin_tech = "bluespace=10"

/obj/item/holder/pug
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/pets.dmi'
	icon_state = "pug"

/obj/item/holder/fox
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/pets.dmi'
	icon_state = "fox"

/obj/item/holder/sloth
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/pets.dmi'
	icon_state = "sloth"
	slot_flags = null

/obj/item/holder/cat
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/pets.dmi'
	icon_state = "cat"

/obj/item/holder/crusher
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/pets.dmi'
	icon_state = "crusher"

/obj/item/holder/cat2
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/pets.dmi'
	icon_state = "cat2"

/obj/item/holder/cak
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/pets.dmi'
	icon_state = "cak"
	origin_tech = "biotech=5"

/obj/item/holder/original
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/pets.dmi'
	icon_state = "original"

/obj/item/holder/spacecat
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/pets.dmi'
	icon_state = "spacecat"

/obj/item/holder/fatcat
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/iriska.dmi'
	icon_state = "iriska"
	slot_flags = null

/obj/item/holder/bullterrier
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/pets.dmi'
	icon_state = "bullterrier"
	slot_flags = null

/obj/item/holder/crab
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/animal.dmi'
	icon_state = "crab"

/obj/item/holder/evilcrab
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/animal.dmi'
	icon_state = "evilcrab"

/obj/item/holder/snake
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/animal.dmi'
	icon_state = "snake"
	slot_flags = ITEM_SLOT_HEAD|ITEM_SLOT_NECK

/obj/item/holder/parrot
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/animal.dmi'
	icon_state = "parrot_fly"

/obj/item/holder/axolotl
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/animal.dmi'
	icon_state = "axolotl"

/obj/item/holder/lizard
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/animal.dmi'
	icon_state = "lizard"

/obj/item/holder/chick
	name = "pet"
	desc = "It's a small chicken"
	icon = 'icons/mob/animal.dmi'
	icon_state = "chick"

/obj/item/holder/chicken
	name = "pet"
	desc = "It's a chicken"
	icon = 'icons/mob/animal.dmi'
	icon_state = "chicken_brown"
	slot_flags = null

/obj/item/holder/cock
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/animal.dmi'
	icon_state = "cock"
	slot_flags = null

/obj/item/holder/hamster
	name = "pet"
	desc = "It's a pet"
	icon = 'icons/mob/animal.dmi'
	icon_state = "hamster"

/obj/item/holder/hamster_rep
	name = "Представитель Алексей"
	desc = "Уважаемый хомяк"
	icon = 'icons/mob/animal.dmi'
	icon_state = "hamster_rep"

/obj/item/holder/fennec
	name = "fennec"
	desc = "It's a fennec. Yiff!"
	icon_state = "fennec"
	origin_tech = "biotech=4"

/obj/item/holder/mothroach
	name = "mothroach"
	desc = "Bzzzz"
	icon = 'icons/mob/pets.dmi'
	icon_state = "mothroach"
	origin_tech = "biotech=4"

/obj/item/holder/moth
	name = "moth"
	desc = "Bzzzz"
	icon = 'icons/mob/animal.dmi'
	icon_state = "moth"
	origin_tech = "biotech=4"

/obj/item/holder/headslug
	name = "headslug"
	desc = "It's a headslug. Ewwww..."
	icon = 'icons/mob/mob.dmi'
	icon_state = "headslug"
	origin_tech = "biotech=6"

/obj/item/holder/possum
	name = "possum"
	desc = "It's a possum. Ewwww..."
	icon = 'icons/mob/pets.dmi'
	icon_state = "possum"
	origin_tech = "biotech=3"

/obj/item/holder/possum/poppy
	name = "poppy"
	desc = "It's a possum Poppy. Ewwww..."
	icon = 'icons/mob/pets.dmi'
	icon_state = "possum_poppy"

/obj/item/holder/frog
	name = "frog"
	desc = "It's a wednesday, my dudes."
	icon = 'icons/mob/animal.dmi'
	icon_state = "frog"

/obj/item/holder/frog/toxic
	name = "rare frog"
	desc = "It's a toxic wednesday, my dudes."
	icon_state = "rare_frog"

/obj/item/holder/snail
	name = "snail"
	desc = "Slooooow"
	icon = 'icons/mob/animal.dmi'
	icon_state = "snail"
	slot_flags = null

/obj/item/holder/turtle
	name = "yeeslow"
	desc = "Slooooow"
	icon = 'icons/mob/animal.dmi'
	icon_state = "yeeslow"
	slot_flags = null

/obj/item/holder/clowngoblin
	name = "clowngoblin"
	desc = "Honk honk"
	icon = 'icons/mob/animal.dmi'
	icon_state = "clowngoblin"
