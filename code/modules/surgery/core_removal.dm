/datum/surgery/core_removal
	name = "core removal"
	steps = list(/datum/surgery_step/slime/cut_flesh, /datum/surgery_step/slime/extract_core)
	target_mobtypes = list(/mob/living/simple_animal/slime)
	possible_locs = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
		BODY_ZONE_L_ARM,
		BODY_ZONE_PRECISE_L_HAND,
		BODY_ZONE_R_ARM,
		BODY_ZONE_PRECISE_R_HAND,
		BODY_ZONE_R_LEG,
		BODY_ZONE_PRECISE_R_FOOT,
		BODY_ZONE_L_LEG,
		BODY_ZONE_PRECISE_L_FOOT,
		BODY_ZONE_PRECISE_GROIN,
		BODY_ZONE_TAIL,
		BODY_ZONE_WING,
	)

/datum/surgery/core_removal/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	return . && target.stat == DEAD


/datum/surgery_step/slime

/datum/surgery_step/slime/cut_flesh
	begin_sound = 'sound/surgery/scalpel1.ogg'
	end_sound = 'sound/surgery/scalpel2.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	allowed_tools = list(
		TOOL_SCALPEL = 100,
		/obj/item/melee/energy/sword = 75,
		/obj/item/kitchen/knife = 65,
		/obj/item/shard = 45
	)
	time = 1.6 SECONDS

/datum/surgery_step/slime/cut_flesh/begin_step(mob/user, mob/living/simple_animal/slime/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts cutting through [target]'s flesh with \the [tool].", "You start cutting through [target]'s flesh with \the [tool].", chat_message_type = MESSAGE_TYPE_COMBAT)
	return ..()

/datum/surgery_step/slime/cut_flesh/end_step(mob/living/user, mob/living/simple_animal/slime/target, target_zone, obj/item/tool)
	user.visible_message(span_notice("[user] cuts through [target]'s flesh with \the [tool]."),
	span_notice(" You cut through [target]'s flesh with \the [tool], revealing its silky innards."), chat_message_type = MESSAGE_TYPE_COMBAT)
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/slime/cut_flesh/fail_step(mob/living/user, mob/living/simple_animal/slime/target, target_zone, obj/item/tool)
	user.visible_message(
		span_warning("[user]'s hand slips, tearing [target]'s flesh with \the [tool]!"),
		span_warning("Your hand slips, tearing [target]'s flesh with \the [tool]!"), chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return SURGERY_STEP_RETRY

/datum/surgery_step/slime/extract_core
	name = "extract core"
	allowed_tools = list(TOOL_HEMOSTAT = 100, TOOL_CROWBAR = 100)
	time = 1.6 SECONDS

/datum/surgery_step/slime/extract_core/begin_step(mob/user, mob/living/simple_animal/slime/target, target_zone, obj/item/tool)
	user.visible_message(
		span_notice("[user] begins to extract a core from [target]."),
		span_notice("You begin to extract a core from [target]...")
	)
	return ..()


/datum/surgery_step/slime/extract_core/end_step(mob/user, mob/living/simple_animal/slime/slime, target_zone, obj/item/tool)
	if(slime.cores > 0)
		slime.cores--
		user.visible_message(
			span_notice("[user] successfully extracts a core from [slime]!"),
			span_notice("You successfully extract a core from [slime]. [slime.cores] core\s remaining."),
			chat_message_type = MESSAGE_TYPE_COMBAT
			)

		new slime.coretype(slime.loc)

		if(slime.cores <= 0)
			return SURGERY_STEP_CONTINUE
		else
			return SURGERY_STEP_INCOMPLETE
	else
		to_chat(user, span_warning("There aren't any cores left in [slime]!"))
		return SURGERY_STEP_CONTINUE

/datum/surgery_step/slime/extract_core/fail_step(mob/living/user, mob/living/simple_animal/slime/target, target_zone, obj/item/tool)
	user.visible_message(
		span_warning("[user]'s hand slips, tearing [target]'s flesh with \the [tool]!"),
		span_warning("Your hand slips, tearing [target]'s flesh with \the [tool]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return SURGERY_STEP_RETRY
