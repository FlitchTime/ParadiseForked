// This whole file really needs reorganising at some point, or at the very least the construct stuff should be moved somewhere else.
/obj/item/soulstone
	name = "soul stone shard"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "soulstone"
	item_state = "electronic"
	belt_icon = "soul_stone_shard"
	var/icon_state_full = "soulstone2"
	desc = "A fragment of the legendary treasure known simply as the 'Soul Stone'. The shard still flickers with a fraction of the full artifact's power."
	w_class = WEIGHT_CLASS_TINY
	slot_flags = ITEM_SLOT_BELT
	origin_tech = "bluespace=4;materials=5"

	/// Does this soulstone ask the victim whether they want to be turned into a shade
	var/optional = FALSE
	/// Can this soul stone be used by anyone, or only cultists/wizards?
	var/usability = FALSE
	/// Can this soul stone be used more than once?
	var/reusable = TRUE
	/// If the soul stone can only be used once, has it been used?
	var/spent = FALSE

	/// For tracking during the 'optional' bit
	var/opt_in = FALSE
	var/purified = FALSE

/obj/item/soulstone/proc/can_use(mob/living/user)
	if(iscultist(user) && purified && !iswizard(user))
		return FALSE

	if(iscultist(user) || iswizard(user) || usability)
		return TRUE

	return FALSE

/obj/item/soulstone/proc/was_used()
	if(!reusable)
		spent = TRUE
		name = "dull [initial(name)]"
		desc = "A fragment of the legendary treasure known simply as \
			the 'Soul Stone'. The shard lies still, dull and lifeless; \
			whatever spark it once held long extinguished."

/obj/item/soulstone/anybody
	usability = TRUE

/obj/item/soulstone/anybody/purified
	icon_state = "purified_soulstone"
	icon_state_full = "purified_soulstone2"
	purified = TRUE
	optional = TRUE

/obj/item/soulstone/anybody/purified/chaplain
	name = "mysterious old shard"
	reusable = FALSE

/obj/item/soulstone/pickup(mob/living/user)
	. = ..()
	if(iscultist(user) && purified && !iswizard(user))
		to_chat(user, "<span class='danger'>[src] reeks of holy magic. You will need to cleanse it with a ritual dagger before anything can be done with it.</span>")
	if(!can_use(user))
		to_chat(user, "<span class='danger'>An overwhelming feeling of dread comes over you as you pick up [src].</span>")

/obj/item/soulstone/Destroy() //Stops the shade from being qdel'd immediately and their ghost being sent back to the arrival shuttle.
	for(var/mob/living/simple_animal/shade/A in src)
		A.death()
	return ..()


/obj/item/soulstone/update_name(updates = ALL)
	. = ..()
	var/mob/living/simple_animal/shade/shade = locate() in src
	if(shade)
		name = "soulstone: [shade.name]"
	else
		name = initial(name)


/obj/item/soulstone/update_icon_state()
	if(purified)
		icon_state = "purified_soulstone"
		icon_state_full = "purified_soulstone2"
	else
		icon_state = initial(icon_state)
		icon_state_full = initial(icon_state_full)

	var/mob/living/simple_animal/shade/shade = locate() in src
	if(shade)
		icon_state = icon_state_full


//////////////////////////////Capturing////////////////////////////////////////////////////////
/obj/item/soulstone/attack(mob/living/carbon/human/M, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED
	if(M == user)
		return .

	if(!can_use(user))
		user.Weaken(10 SECONDS)
		user.emote("scream")
		to_chat(user, span_userdanger("Your body is wracked with debilitating pain!"))
		return ATTACK_CHAIN_BLOCKED_ALL

	if(spent)
		to_chat(user, span_warning("There is no power left in the shard."))
		return .

	if(!ishuman(M)) //If target is not a human
		return ..()

	if(M.has_brain_worms()) //Borer stuff - RR
		to_chat(user, span_warning("This being is corrupted by an alien intelligence and cannot be soul trapped."))
		return ..()

	if(jobban_isbanned(M, ROLE_CULTIST) || jobban_isbanned(M, ROLE_SYNDICATE))
		to_chat(user, span_warning("A mysterious force prevents you from trapping this being's soul."))
		return ..()

	if(iscultist(user) && iscultist(M))
		to_chat(user, span_cultlarge("\"Come now, do not capture your fellow's soul.\""))
		return ..()

	. = ATTACK_CHAIN_BLOCKED_ALL

	if(optional)
		if(!M.ckey)
			to_chat(user, span_warning("They have no soul!"))
			return ATTACK_CHAIN_PROCEED

		to_chat(user, span_warning("You attempt to channel [M]'s soul into [src]. You must give the soul some time to react and stand still..."))

		var/mob/player_mob = M
		var/ghost = M.get_ghost()
		if(ghost) // In case our player ghosted and we need to throw the alert at their ghost instead
			player_mob = ghost
		var/client/player_client = player_mob.client
		to_chat(player_mob, span_warning("[user] is trying to capture your soul into [src]! Click the button in the top right of the game window to respond."))
		player_client << 'sound/misc/announce_dig.ogg'
		window_flash(player_client)

		var/atom/movable/screen/alert/notify_soulstone/A = player_mob.throw_alert("\ref[src]_soulstone_thingy", /atom/movable/screen/alert/notify_soulstone)
		if(player_client.prefs && player_client.prefs.UI_style)
			A.icon = ui_style2icon(player_client.prefs.UI_style)

		// Pass the stuff to the alert itself
		A.stone = src
		A.stoner = user.real_name

		// Layer shenanigans to make the alert display the soulstone
		var/old_layer = layer
		var/old_plane = plane
		layer = FLOAT_LAYER
		plane = FLOAT_PLANE
		A.add_overlay(src)
		layer = old_layer
		plane = old_plane

		// Give the victim 10 seconds to respond
		sleep(10 SECONDS)

		if(!opt_in)
			to_chat(user, span_warning("The soul resists your attempts at capturing it!"))
			return .

		opt_in = FALSE

		if(spent)//checking one more time against shenanigans
			return .

	if(is_sacrifice_target(M.mind))
		if(iscultist(user))
			SSticker.mode.cult_objs.succesful_sacrifice()
		else if(!SSticker.mode.cult_objs.find_new_sacrifice_target())
			SSticker.mode.cult_objs.ready_to_summon()

	add_attack_logs(user, M, "Stolestone'd with [name]")
	transfer_soul("VICTIM", M, user)


/obj/item/soulstone/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/storage/bible) && !iscultist(user) && user.mind.isholy)
		add_fingerprint(user)
		if(purified)
			to_chat(user, span_warning("The [name] is already purified!"))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You begin to exorcise [src]."))
		playsound(src, 'sound/hallucinations/veryfar_noise.ogg', 40, TRUE)
		if(!do_after(user, 4 SECONDS, src) || purified)
			return ATTACK_CHAIN_PROCEED
		usability = TRUE
		purified = TRUE
		optional = TRUE
		update_icon(UPDATE_ICON_STATE)
		for(var/mob/inhabitant in src)
			if(inhabitant.mind)
				if(iscultist(inhabitant))
					SSticker.mode.remove_cultist(inhabitant.mind, FALSE)
					to_chat(inhabitant, span_userdanger("An unfamiliar white light flashes through your mind, cleansing the taint of [SSticker.cultdat ? SSticker.cultdat.entity_title1 : "Nar'Sie"] and the memories of your time as their servant with it."))
					to_chat(inhabitant, span_danger("Assist [user], your saviour, and get vengeance on those who enslaved you!"))
				else
					to_chat(inhabitant, span_danger("Your soulstone has been exorcised, and you are now bound to obey [user]."))
			if(isshade(inhabitant))
				var/mob/living/simple_animal/shade/shade = inhabitant
				shade.holy = TRUE
				shade.update_icon(UPDATE_ICON_STATE)
		user.visible_message(
			span_notice("[user] purifies [src]!"),
			span_notice("You purify [src]!"),
		)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/melee/cultblade/dagger) && iscultist(user))
		add_fingerprint(user)
		if(!purified)
			to_chat(user, span_warning("The [name] is already cleansed of holy magic!"))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You begin to cleanse [src] of holy magic."))
		if(!do_after(user, 4 SECONDS, src) || !purified)
			return ATTACK_CHAIN_PROCEED
		usability = FALSE
		purified = FALSE
		optional = FALSE
		update_icon(UPDATE_ICON_STATE)
		for(var/mob/inhabitant in src)
			if(inhabitant.mind)
				SSticker.mode.add_cultist(inhabitant.mind)
				to_chat(inhabitant, span_cult("Your shard has been cleansed of holy magic, and you are now bound to the cult's will. Obey them and assist in their goals."))
			if(isshade(inhabitant))
				var/mob/living/simple_animal/shade/shade = inhabitant
				shade.holy = FALSE
				shade.update_icon(UPDATE_ICON_STATE)
		to_chat(user, span_notice("You have cleansed [src] of holy magic."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/item/soulstone/attack_self(mob/living/user)
	if(!in_range(src, user))
		return

	if(!can_use(user))
		user.Weaken(10 SECONDS)
		user.emote("scream")
		to_chat(user, "<span class='userdanger'>Your body is wracked with debilitating pain!</span>")
		return

	release_shades(user)
	return

/obj/item/soulstone/proc/release_shades(mob/user)
	for(var/mob/living/simple_animal/shade/A in src)
		A.forceMove(get_turf(user))
		A.cancel_camera()
		update_appearance(UPDATE_ICON_STATE|UPDATE_NAME)
		if(iscultist(A))
			to_chat(A, "<span class='userdanger'>You have been released from your prison, but you are still bound to the cult's will. Help them succeed in their goals at all costs.</span>")
		else
			to_chat(A, "<span class='userdanger'>You have been released from your prison, but you are still bound to your [purified ? "saviour" : "creator"]'s will.</span>")
		was_used()

///////////////////////////Transferring to constructs/////////////////////////////////////////////////////
/obj/structure/constructshell
	name = "empty shell"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct-cult"
	desc = "A wicked machine used by those skilled in magical arts. It is inactive."
	/// Is someone currently placing a soulstone into the shell
	var/active = FALSE

/obj/structure/constructshell/examine(mob/user)
	. = ..()
	if(in_range(user, src) && (iscultist(user) || iswizard(user) || user.stat == DEAD))
		. += "<span class='cult'>A construct shell, used to house bound souls from a soulstone.</span>"
		. += "<span class='cult'>Placing a soulstone with a soul into this shell allows you to produce your choice of the following:</span>"
		. += "<span class='cultitalic'>An <b>Artificer</b>, which can produce <b>more shells and soulstones</b>, as well as fortifications.</span>"
		. += "<span class='cultitalic'>A <b>Wraith</b>, which does high damage and can jaunt through walls, though it is quite fragile.</span>"
		. += "<span class='cultitalic'>A <b>Juggernaut</b>, which is very hard to kill and can produce temporary walls, but is slow.</span>"


/obj/structure/constructshell/attackby(obj/item/I, mob/living/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/soulstone))
		add_fingerprint(user)
		var/obj/item/soulstone/soulstone = I
		if(!soulstone.can_use(user))
			to_chat(user, span_danger("An overwhelming feeling of dread comes over you as you attempt to place the soulstone into the shell."))
			user.Confused(20 SECONDS)
			return ATTACK_CHAIN_BLOCKED_ALL
		INVOKE_ASYNC(soulstone, TYPE_PROC_REF(/obj/item/soulstone, transfer_soul), "CONSTRUCT", src, user)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/structure/constructshell/holy
	name = "empty holy shell"
	icon_state = "construct-holy"
	desc = "A holy machine used by those who are pure in soul and mind. It is inactive."
	var/defiled = FALSE


/obj/structure/constructshell/holy/update_icon_state()
	icon_state = defiled ? "construct-cult" : initial(icon_state)


/obj/structure/constructshell/holy/update_name(updates = ALL)
	. = ..()
	name = defiled ? "empty shell" : initial(name)


/obj/structure/constructshell/holy/update_desc(updates = ALL)
	. = ..()
	if(!defiled)
		desc = initial(desc)
		return
	desc = "A wicked machine used by those skilled in magical arts. It is inactive."


/obj/structure/constructshell/holy/attackby(obj/item/I, mob/living/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/storage/bible) && !iscultist(user) && user.mind.isholy)
		add_fingerprint(user)
		if(!defiled)
			to_chat(user, span_warning("The [name] is not defiled!"))
			return ATTACK_CHAIN_PROCEED
		defiled = FALSE
		update_appearance(UPDATE_ICON_STATE|UPDATE_NAME|UPDATE_DESC)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/melee/cultblade/dagger) && iscultist(user))
		add_fingerprint(user)
		if(defiled)
			to_chat(user, span_warning("The [name] is already defiled!"))
			return ATTACK_CHAIN_PROCEED
		if(!do_after(user, 4 SECONDS, src) || defiled)
			return ATTACK_CHAIN_PROCEED
		user.visible_message(
			span_warning("[user] defile [src] with dark magic!"),
			span_cult("You sanctified [src]. Yes-yes. I need more acolytes!"),
		)
		defiled = TRUE
		update_appearance(UPDATE_ICON_STATE|UPDATE_NAME|UPDATE_DESC)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/soulstone))
		if(defiled)
			return ..()
		add_fingerprint(user)
		var/obj/item/soulstone/soulstone = I
		if(!soulstone.purified || iscultist(user))
			to_chat(user, span_danger("An overwhelming feeling of dread comes over you as you attempt to place the soulstone into the shell."))
			user.Confused(30 SECONDS)
			return ATTACK_CHAIN_BLOCKED_ALL
		INVOKE_ASYNC(soulstone, TYPE_PROC_REF(/obj/item/soulstone, transfer_soul), "CONSTRUCT", src, user)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


////////////////////////////Proc for moving soul in and out off stone//////////////////////////////////////
/obj/item/soulstone/proc/transfer_soul(choice, target, mob/living/user)
	switch(choice)
		if("FORCE")
			var/mob/living/T = target
			if(T.client && T.ghost_can_reenter())
				init_shade(T, user)
			else
				to_chat(user, "<span class='userdanger'>Capture failed!</span> The soul has already fled its mortal frame. You attempt to bring it back...")
				T.Paralyse(40 SECONDS)
				if(!get_cult_ghost(T, user, TRUE))
					T.dust() //If we can't get a ghost, kill the sacrifice anyway.

		if("VICTIM")
			var/mob/living/carbon/human/T = target
			if(T.stat == 0)
				to_chat(user, "<span class='danger'>Capture failed!</span> Kill or maim the victim first!")
			else
				if(!length(T.client_mobs_in_contents))
					to_chat(user, "<span class='warning'>They have no soul!</span>")
				else
					if(T.client == null)
						to_chat(user, "<span class='userdanger'>Capture failed!</span> The soul has already fled its mortal frame. You attempt to bring it back...")
						get_cult_ghost(T, user, !T.ghost_can_reenter())
					else
						if(length(contents))
							to_chat(user, "<span class='danger'>Capture failed!</span> The soul stone is full! Use or free an existing soul to make room.")
						else
							init_shade(T, user, TRUE)

		if("SHADE")
			var/mob/living/simple_animal/shade/T = target
			if(!can_use(user))
				user.Weaken(10 SECONDS)
				to_chat(user, "<span class='userdanger'>Your body is wracked with debilitating pain!</span>")
				return
			if(T.stat == DEAD)
				to_chat(user, "<span class='danger'>Capture failed!</span> The shade has already been banished!")
			if((iscultist(T) && purified) || (T.holy && !purified))
				to_chat(user, "<span class='danger'>Capture failed!</span> The shade recoils away from [src]!")
			else
				if(length(contents))
					to_chat(user, "<span class='danger'>Capture failed!</span>: The soul stone is full! Use or free an existing soul to make room.")
				else
					T.forceMove(src) // Put the shade into the stone.
					T.health = T.maxHealth
					update_appearance(UPDATE_ICON_STATE|UPDATE_NAME)
					to_chat(T, "<span class='notice'>Your soul has been recaptured by the soul stone, its arcane energies are reknitting your ethereal form</span>")
					to_chat(user, "<span class='notice'>Capture successful!</span> [T.name]'s has been recaptured and stored within the soul stone.")

		if("CONSTRUCT")
			var/obj/structure/constructshell/shell = target
			var/mob/living/simple_animal/shade/shade = locate() in src
			var/list/construct_types = list("Juggernaut" = /mob/living/simple_animal/hostile/construct/armoured,
											"Wraith" = /mob/living/simple_animal/hostile/construct/wraith,
											"Artificer" = /mob/living/simple_animal/hostile/construct/builder)

			var/list/holy_construct_types = list("Juggernaut" = /mob/living/simple_animal/hostile/construct/armoured/holy,
												"Wraith" = /mob/living/simple_animal/hostile/construct/wraith/holy,
												"Artificer" = /mob/living/simple_animal/hostile/construct/builder/holy)
			/// Custom construct icons for different cults
			var/list/construct_icons = list("Juggernaut" = image(icon = 'icons/mob/mob.dmi', icon_state = SSticker.cultdat.get_icon("juggernaut")),
											"Wraith" = image(icon = 'icons/mob/mob.dmi', icon_state = SSticker.cultdat.get_icon("wraith")),
											"Artificer" = image(icon = 'icons/mob/mob.dmi', icon_state = SSticker.cultdat.get_icon("builder")))

			var/list/holy_construct_icons = list("Juggernaut" = image(icon = 'icons/mob/mob.dmi', icon_state = "holy_juggernaut"),
											"Wraith" = image(icon = 'icons/mob/mob.dmi', icon_state = "holy_shifter"),
											"Artificer" = image(icon = 'icons/mob/mob.dmi', icon_state = "holy_artificer"))

			if(shade)
				var/construct_choice = 0
				var/picked_class = 0
				if(purified)
					construct_choice = show_radial_menu(user, shell, holy_construct_icons, custom_check = CALLBACK(src, PROC_REF(radial_check), user), require_near = TRUE)
					picked_class = holy_construct_types[construct_choice]
				else
					construct_choice = show_radial_menu(user, shell, construct_icons, custom_check = CALLBACK(src, PROC_REF(radial_check), user), require_near = TRUE)
					picked_class = construct_types[construct_choice]
				if((picked_class && !QDELETED(shell) && !QDELETED(src)) && user.Adjacent(shell) && !user.incapacitated() && radial_check(user))
					var/mob/living/simple_animal/hostile/construct/C = new picked_class(shell.loc)
					C.init_construct(shade, src, shell)
					to_chat(C, C.playstyle_string)
					was_used()
			else
				to_chat(user, "<span class='danger'>Creation failed!</span>: The soul stone is empty! Go kill someone!")

/obj/item/soulstone/proc/radial_check(mob/user)
	if(!ishuman(user)) // Should never happen, but just in case
		return FALSE

	var/mob/living/carbon/human/H = user
	if(!H.is_type_in_hands(src)) // Not holding the soulstone
		return FALSE
	return TRUE

/mob/living/simple_animal/hostile/construct/proc/init_construct(mob/living/simple_animal/shade/shade, obj/item/soulstone/SS, obj/structure/constructshell/shell)
	if(shade.mind)
		shade.mind.transfer_to(src)
	if(SS.purified)
		set_light_range_power_color(3, 5, LIGHT_COLOR_DARK_BLUE)
		name = "Holy [name]"
		real_name = "Holy [real_name]"


	else if(iscultist(src)) // Re-grant cult actions, lost in the transfer
		var/datum/action/innate/cult/comm/CC = new
		var/datum/action/innate/cult/check_progress/D = new
		CC.Grant(src)
		D.Grant(src)
		SSticker.mode.cult_objs.study(src) // Display objectives again
		to_chat(src, "<span class='userdanger'>You are still bound to serve the cult, follow their orders and help them complete their goals at all costs.</span>")
	else
		to_chat(src, "<span class='userdanger'>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</span>")
	cancel_camera()
	qdel(shell)
	qdel(shade)
	qdel(SS)

/proc/make_new_construct(mob/living/simple_animal/hostile/construct/c_type, mob/target, mob/user, cult_override = FALSE)
	if(jobban_isbanned(target, "cultist"))
		return
	var/mob/living/simple_animal/hostile/construct/C = new c_type(get_turf(target))

	if(istype(c_type, /mob/living/simple_animal/hostile/construct/harvester))
		var/datum/effect_system/fluid_spread/smoke/sleeping/smoke = new
		smoke.set_up(amount = 5, location = target.loc)
		smoke.start()

	C.faction |= "\ref[user]"
	C.key = target.key
	if(user && iscultist(user) || cult_override)
		SSticker.mode.add_cultist(C.mind)
		SSticker.mode.update_cult_icons_added(C.mind)
	if(user && iscultist(user))
		to_chat(C, "<b>You are still bound to serve the cult, follow their orders and help them complete their goals at all costs.</b>")
	else
		to_chat(C, "<b>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</b>")
	C.cancel_camera()

/obj/item/soulstone/proc/init_shade(mob/living/M, mob/user, forced = FALSE)
	var/type = get_shade_type()
	var/mob/living/simple_animal/shade/S = new type(src)

	S.name = "Shade of [M.real_name]"
	S.real_name = "Shade of [M.real_name]"
	S.key = M.key
	S.cancel_camera()

	update_appearance(UPDATE_ICON_STATE|UPDATE_NAME)
	log_game("[S.key] has become [S.name] with [purified ? "holy" : "corrupted"] essence.")
	if(user)
		S.faction |= "\ref[user]" //Add the master as a faction, allowing inter-mob cooperation

		if(S.mind)
			if(iswizard(user))
				SSticker.mode.update_wiz_icons_added(S.mind)
				S.mind.special_role = SPECIAL_ROLE_WIZARD_APPRENTICE

			if(iscultist(user))
				SSticker.mode.add_cultist(S.mind)
				S.mind.special_role = SPECIAL_ROLE_CULTIST
				S.mind.store_memory("<b>Serve the cult's will.</b>")
				to_chat(S, span_userdanger("Your soul has been captured! You are now bound to the cult's will. Help them succeed in their goals at all costs."))

			else
				S.mind.store_memory("<b>Serve [user.real_name], your creator.</b>")
				to_chat(S, span_userdanger("Your soul has been captured! You are now bound to [user.real_name]'s will. Help them succeed in their goals at all costs."))

	if(forced && user)
		to_chat(user, "[span_info("<b>Capture successful!</b>:")] [M.real_name]'s soul has been ripped from [user.p_their()] body and stored within the soul stone.")

	if(isrobot(M))//Robots have to dust or else they spill out an empty robot brain, and unequiping them spills robot components that shouldn't spawn.
		M.dust()

	else
		for(var/obj/item/I in M)
			M.drop_item_ground(I)

		M.dust()

/obj/item/soulstone/proc/get_shade_type()
	if(purified)
		return /mob/living/simple_animal/shade/holy

	return /mob/living/simple_animal/shade/cult

/obj/item/soulstone/proc/get_cult_ghost(mob/living/M, mob/user, get_new_player = FALSE)
	var/mob/dead/observer/chosen_ghost

	if(!get_new_player)
		for(var/mob/dead/observer/ghost in GLOB.player_list) // We put them back in their body
			if(ghost.mind && ghost.mind.current == M && ghost.client)
				chosen_ghost = ghost
				break

	if(!chosen_ghost) // Failing that, we grab a ghost
		var/list/consenting_candidates
		if(purified)
			consenting_candidates = SSghost_spawns.poll_candidates("Would you like to play as a Holy Shade?", ROLE_SENTIENT, FALSE, poll_time = 10 SECONDS, source = /mob/living/simple_animal/shade/holy)
		else
			consenting_candidates = SSghost_spawns.poll_candidates("Would you like to play as a Shade?", ROLE_SENTIENT, FALSE, poll_time = 10 SECONDS, source = /mob/living/simple_animal/shade)
		if(length(consenting_candidates))
			chosen_ghost = pick(consenting_candidates)
	if(!M)
		return FALSE
	if(!chosen_ghost)
		to_chat(user, "<span class='danger'>There were no spirits willing to become a shade.</span>")
		return FALSE
	if(length(contents)) //If they used the soulstone on someone else in the meantime
		return FALSE
	M.ckey = chosen_ghost.ckey
	init_shade(M, user)
	return TRUE
