// MARK: Force martial art

/datum/martial_art/force
	name = "Force Arts"
	weight = 11
	has_explaination_verb = TRUE
	has_dirslash = TRUE

	combos = list(
		/datum/martial_combo/force/leg_sweep,
		/datum/martial_combo/force/cleaving_slash,
		/datum/martial_combo/force/hilt_feint,
	)

	var/obj/item/bound_esword
	var/datum/action/innate/force_esword_pull/esword_pull_action

	var/setting_force_grab = FALSE
	var/mob/living/force_grab_target

	var/used_inactive_hilt = FALSE
	var/last_pierce_time = 0

	COOLDOWN_DECLARE(force_lightning_cd)
	COOLDOWN_DECLARE(force_pierce_cd)
	COOLDOWN_DECLARE(force_esword_pull_cd)

/datum/martial_art/force/teach(mob/living/carbon/human/H, make_temporary = FALSE)
	. = ..()
	if(!.)
		return

	RegisterSignal(H, COMSIG_MOB_ATTACK_RANGED_SECONDARY, PROC_REF(on_ranged_secondary_attack))
	RegisterSignal(H, COMSIG_MOB_ITEM_ATTACK, PROC_REF(on_mob_item_attack))
	RegisterSignal(H, COMSIG_LIVING_START_PULL, PROC_REF(on_start_pull))
	RegisterSignal(H, COMSIG_ATOM_NO_LONGER_PULLING, PROC_REF(on_no_longer_pulling))
	RegisterSignal(H, COMSIG_MOB_CLICKON, PROC_REF(on_clickon))

	esword_pull_action = new(src)
	esword_pull_action.Grant(H)

	to_chat(H, span_notice("Вы чувствуете странное спокойствие. Вы постигли Путь Силы."))
	to_chat(H, span_notice("Призыв меча: свяжите энергетический меч или двойной энергетический меч в руках со своей аурой, чтобы затем призывать его обратно в руку."))
	to_chat(H, span_notice("Силовой захват: в режиме GRAB нажмите на цель в пределах 4 тайлов, чтобы схватить её на расстоянии."))
	to_chat(H, span_notice("Силовая молния: в режиме DISARM нажмите правой кнопкой мыши в пределах 4 тайлов. Перезарядка: 15 секунд."))

/datum/martial_art/force/remove(mob/living/carbon/human/H)
	. = ..()
	if(!istype(H))
		return .

	clear_force_grab(H)

	UnregisterSignal(H, list(
		COMSIG_MOB_ATTACK_RANGED_SECONDARY,
		COMSIG_MOB_ITEM_ATTACK,
		COMSIG_LIVING_START_PULL,
		COMSIG_ATOM_NO_LONGER_PULLING,
		COMSIG_MOB_CLICKON
	))

	QDEL_NULL(esword_pull_action)
	clear_bound_esword()
	return .

/datum/martial_art/force/explaination_header(user)
	to_chat(user, "<b><i>Вы сосредотачиваетесь и чувствуете, как Сила течет сквозь вас...</i></b>")

/datum/martial_art/force/explaination_combos(user)
	to_chat(user, span_notice("Комбо с мечом (энергетический меч / двойной энергетический меч):"))
	to_chat(user, span_notice(" - Подсечка: HARM мечом, DISARM мечом, HARM мечом -> сбивает с ног + отрубает одну ногу ногу."))
	to_chat(user, span_notice(" - Рассекающий удар: HARM мечом, HARM мечом -> 40% шанс отрубить выбранную конечность (кроме головы/груди/паха)."))
	to_chat(user, span_notice(" - Финт рукоятью: HARM мечом, DISARM рукоятью меча, GRAB рукой -> мгновенно переходит в захват за шею."))
	to_chat(user, span_notice("Особое:"))
	to_chat(user, span_notice(" - Силовой захват: в режиме GRAB нажмите на цель в пределах 4 тайлов, чтобы схватить её на расстоянии."))
	to_chat(user, span_notice(" - Силовая молния: в режиме DISARM нажмите правой кнопкой мыши в пределах 4 тайлов. На 5 секунд оглушает цель шоком, игнорируя защиту от тока. Перезарядка: 15 секунд."))
	to_chat(user, span_notice(" - Пронзание: удерживая цель за шею или в удушающем захвате, ударьте цель выключенным мечом в режиме HARM -> активирует лезвие внутри цели и наносит 70 урона груди (игнорирует броню). Перезарядка: 5 сек."))

/datum/martial_art/force/explaination_footer(user)
	to_chat(user, "<b><i>Используйте свои способности с умом.</i></b>")

/datum/martial_art/force/explaination_notice(user)
	return

// MARK: FORCE RECALL

/datum/martial_art/force/proc/clear_bound_esword()
	if(bound_esword)
		UnregisterSignal(bound_esword, COMSIG_QDELETING)
	bound_esword = null

/datum/martial_art/force/proc/bind_esword(obj/item/I, mob/living/carbon/human/user)
	if(!I || !user)
		return FALSE
	if(!(istype(I, /obj/item/melee/energy/sword) || istype(I, /obj/item/twohanded/dualsaber)))
		return FALSE

	clear_bound_esword()
	bound_esword = I
	RegisterSignal(bound_esword, COMSIG_QDELETING, PROC_REF(on_bound_esword_qdel))
	to_chat(user, span_notice("Вы связываете [bound_esword] с вашей волей."))
	return TRUE

/datum/martial_art/force/proc/on_bound_esword_qdel(datum/source)
	SIGNAL_HANDLER
	clear_bound_esword()

/datum/martial_art/force/proc/try_recall_bound_esword(mob/living/carbon/human/user)
	if(!user)
		return

	if(!bound_esword || QDELETED(bound_esword))
		to_chat(user, span_warning("Вы не ощущаете присутствие вашего оружия."))
		return

	if(bound_esword in user)
		return

	if(ismob(bound_esword.loc))
		var/mob/holder = bound_esword.loc
		if(!holder.drop_item_ground(bound_esword, force = TRUE))
			bound_esword.forceMove(get_turf(bound_esword))
	else if(!isturf(bound_esword.loc))
		bound_esword.forceMove(get_turf(bound_esword))

	if(!(bound_esword in view(user)))
		return

	if(QDELETED(bound_esword))
		return

	SEND_SIGNAL(bound_esword, COMSIG_ITEM_RECALL, user)

// MARK: FORCE GRAB

/datum/martial_art/force/proc/on_clickon(mob/living/source, atom/target, list/modifiers)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/user = source
	if(!istype(user) || user.mind?.martial_art != src)
		return
	if(user.a_intent != INTENT_GRAB)
		return
	if(!isliving(target) || target == user)
		return
	var/mob/living/victim = target
	var/dist = get_dist(user, victim)
	if(dist <= 1)
		return
	if(dist > 4)
		return
	if(user.z != victim.z)
		return
	if(!user.can_see(victim, 4))
		return
	if(user.pulling)
		to_chat(user, span_warning("Вы уже кого-то держите."))
		return COMSIG_MOB_CANCEL_CLICKON

	INVOKE_ASYNC(src, PROC_REF(try_force_grab), user, victim)
	return COMSIG_MOB_CANCEL_CLICKON

/datum/martial_art/force/proc/try_force_grab(mob/living/carbon/human/user, mob/living/victim)
	if(QDELETED(user) || QDELETED(victim) || user.mind?.martial_art != src)
		return
	if(user.a_intent != INTENT_GRAB)
		return
	var/dist = get_dist(user, victim)
	if(dist <= 1 || dist > 4)
		return
	if(!user.can_see(victim, 4))
		return
	if(user.pulling)
		to_chat(user, span_warning("Вы уже кого-то держите."))
		return

	if(!victim.grabbedby(user, supress_message = TRUE))
		return
	if(user.pulling != victim)
		return
	if(!victim.grippedby(user, grab_state_override = GRAB_AGGRESSIVE))
		return

	set_force_grab_target(user, victim)

	user.visible_message(
		span_warning("[user] взмахивает рукой, и [victim] оказывается захвачен невидимой силой!"),
		span_notice("Вы захватываете [victim] Силой!")
	)
	playsound(user, 'sound/magic/force_choke.ogg', 50, TRUE)

/datum/martial_art/force/proc/set_force_grab_target(mob/living/carbon/human/user, mob/living/victim)
	if(!user || !victim)
		return

	clear_force_grab(user)
	force_grab_target = victim

	ADD_TRAIT(victim, TRAIT_FORCE_GRASPED, UNIQUE_TRAIT_SOURCE(src))
	ADD_TRAIT(victim, TRAIT_MOVE_FLYING, UNIQUE_TRAIT_SOURCE(src))

	RegisterSignal(victim, COMSIG_LIVING_LIFE, PROC_REF(on_force_grabbed_life))
	RegisterSignal(victim, COMSIG_QDELETING, PROC_REF(on_force_grabbed_qdeleting))

/datum/martial_art/force/proc/clear_force_grab(mob/living/carbon/human/user = null)
	if(!force_grab_target)
		return

	var/mob/living/target = force_grab_target
	UnregisterSignal(target, list(COMSIG_LIVING_LIFE, COMSIG_QDELETING))
	REMOVE_TRAIT(target, TRAIT_FORCE_GRASPED, UNIQUE_TRAIT_SOURCE(src))
	REMOVE_TRAIT(target, TRAIT_MOVE_FLYING, UNIQUE_TRAIT_SOURCE(src))

	force_grab_target = null

/datum/martial_art/force/proc/on_force_grabbed_life(mob/living/source, seconds, times_fired)
	SIGNAL_HANDLER
	if(!source || source != force_grab_target)
		return
	if(!source.pulledby || source.pulledby.pulling != source || source.pulledby.mind?.martial_art != src)
		clear_force_grab()
		return

/datum/martial_art/force/proc/on_force_grabbed_qdeleting(mob/living/source)
	SIGNAL_HANDLER
	if(source == force_grab_target)
		clear_force_grab()

/datum/martial_art/force/proc/on_start_pull(mob/living/source, atom/movable/pulled, state, force)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/user = source
	if(!istype(user) || user.mind?.martial_art != src)
		return
	if(isliving(pulled) && pulled == force_grab_target)
		var/mob/living/victim = pulled
		ADD_TRAIT(victim, TRAIT_FORCE_GRASPED, UNIQUE_TRAIT_SOURCE(src))
		ADD_TRAIT(victim, TRAIT_MOVE_FLYING, UNIQUE_TRAIT_SOURCE(src))

/datum/martial_art/force/proc/on_no_longer_pulling(mob/living/source, atom/movable/old_pulling)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/user = source
	if(!istype(user) || user.mind?.martial_art != src)
		return
	if(isliving(old_pulling) && old_pulling == force_grab_target)
		clear_force_grab(user)

// MARK: FORCE LIGHTNING

/datum/martial_art/force/proc/on_ranged_secondary_attack(mob/living/source, atom/target, list/modifiers)
	SIGNAL_HANDLER

	var/mob/living/carbon/human/user = source
	if(!istype(user))
		return
	if(user.mind?.martial_art != src)
		return
	if(user.a_intent != INTENT_DISARM)
		return
	if(!target)
		return
	if(get_dist(user, target) > 4)
		return
	if(user.z != target.z)
		return
	if(!user.can_see(target, 4))
		return

	if(!COOLDOWN_FINISHED(src, force_lightning_cd))
		user.balloon_alert(user, "не готово!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	COOLDOWN_START(src, force_lightning_cd, 15 SECONDS)

	playsound(get_turf(user), 'sound/magic/lightningbolt.ogg', 50, TRUE, -1)

	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		return COMPONENT_CANCEL_ATTACK_CHAIN

	user.Beam(target, icon_state = "lightning[rand(1, 12)]", icon = 'icons/effects/effects.dmi', time = 1 SECONDS)

	var/list/turfs = get_line(user, target_turf)
	var/mob/living/primary_mob = isliving(target) ? target : null

	for(var/turf/turf as anything in turfs)
		for(var/mob/living/target_mob in turf)
			if(target_mob == user)
				continue
			if(primary_mob && target_mob == primary_mob)
				continue
			target_mob.electrocute_act(15, user, flags = SHOCK_NOSTUN)

	if(primary_mob)
		if(ishuman(primary_mob) || iscarbon(primary_mob))
			primary_mob.electrocute_act(25, user, flags = SHOCK_IGNORE_IMMUNITY, stun_duration = 6 SECONDS)
		else
			primary_mob.electrocute_act(25, user, stun_duration = 1 SECONDS)

	return COMPONENT_CANCEL_ATTACK_CHAIN

// MARK: COMBO

/datum/martial_art/force/proc/get_sword_status(mob/living/carbon/human/attacker)
	var/obj/item/weapon = attacker.get_active_hand()
	if(!weapon)
		return "hand"
	if(istype(weapon, /obj/item/melee/energy/sword))
		var/obj/item/melee/energy/sword/S = weapon
		return S.active ? "active" : "inactive"
	if(istype(weapon, /obj/item/twohanded/dualsaber))
		return HAS_TRAIT(weapon, TRAIT_WIELDED) ? "active" : "inactive"
	return "wrong"

/datum/martial_art/force/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/status = get_sword_status(A)
	if(status == "active")
		return act(MARTIAL_COMBO_STEP_HARM, A, D)
	return FALSE

/datum/martial_art/force/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/status = get_sword_status(A)

	if(status == "inactive")
		used_inactive_hilt = TRUE
	else
		used_inactive_hilt = FALSE

	if(status == "active" || status == "inactive")
		return act(MARTIAL_COMBO_STEP_DISARM, A, D)
	
	return ..()

/datum/martial_art/force/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!A.get_active_hand())
		return act(MARTIAL_COMBO_STEP_GRAB, A, D)
	return FALSE

/datum/martial_art/force/proc/on_mob_item_attack(mob/living/source, mob/living/target, list/modifiers, def_zone)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/attacker = source
	var/mob/living/carbon/human/defender = target
	
	if(!istype(attacker) || !istype(defender) || attacker.mind?.martial_art != src)
		return

	var/status = get_sword_status(attacker)
	if(status == "wrong")
		return

	if(status == "inactive" && attacker.a_intent == INTENT_HARM)
		if(attacker.pulling == defender && attacker.grab_state >= GRAB_AGGRESSIVE)
			if(try_force_pierce(attacker, defender))
				return COMPONENT_SKIP_ATTACK

	var/combo_result = FALSE
	if(attacker.a_intent == INTENT_HARM)
		combo_result = harm_act(attacker, defender)
	else if(attacker.a_intent == INTENT_DISARM)
		combo_result = disarm_act(attacker, defender)

	if(combo_result)
		return COMPONENT_SKIP_ATTACK

/datum/martial_art/force/proc/try_force_pierce(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(world.time < last_pierce_time + 5 SECONDS)
		user.balloon_alert(user, "не готово!")
		return FALSE
	
	var/obj/item/weapon = user.get_active_hand()
	last_pierce_time = world.time

	user.visible_message(span_danger("[user] вонзает рукоять в грудь [target] и активирует лезвие!"), \
						 span_danger("Вы вонзаете рукоять в грудь [target] и активируете меч!"))
	
	if(istype(weapon, /obj/item/melee/energy/sword))
		var/obj/item/melee/energy/sword/S = weapon
		S.attack_self(user)
	
	playsound(target, 'sound/weapons/blade1.ogg', 50, TRUE)
	
	target.apply_damage(70, BRUTE, BODY_ZONE_CHEST, forced = TRUE) 
	
	add_attack_logs(user, target, "Force Arts: Pierce", ATKLOG_ALL)
	return TRUE

// MARK: datum action

/datum/action/innate/force_esword_pull
	name = "Призыв меча"
	desc = "Связывает энергетический меч или двойной меч в руках с вашей аурой, либо призывает связанный меч обратно в руку."
	button_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "summons"
	background_icon_state = ACTION_BUTTON_DEFAULT_BACKGROUND
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_HANDS_BLOCKED

/datum/action/innate/force_esword_pull/Activate()
	var/mob/living/carbon/human/user = owner
	var/datum/martial_art/force/F = target
	if(!istype(user) || !istype(F))
		return

	var/obj/item/held = user.get_active_hand()
	if(!held)
		held = user.get_inactive_hand()

	if(istype(held, /obj/item/melee/energy/sword) || istype(held, /obj/item/twohanded/dualsaber))
		if(held != F.bound_esword)
			F.bind_esword(held, user)
			return

	F.try_recall_bound_esword(user)
