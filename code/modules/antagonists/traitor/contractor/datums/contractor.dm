/**
  * # Contractor antagonist datum
  *
  * A variant of the Traitor, Contractors rely on kidnapping crew members to earn TC.
  *
  * Contractors are supplied with some unique items
  * and three random low cost contraband items to help kickstart their contracts.
  * A Traitor may become a Contractor if given the chance (random).
  * They will forfeit all their initial TC and receive the above items.
  * The opportunity to become a Contractor goes away after some time or if the traitor spends any initial TC.
  */
/datum/antagonist/contractor
	name = "Contractor"
	job_rank = ROLE_TRAITOR
	special_role = SPECIAL_ROLE_TRAITOR
	antag_hud_type = ANTAG_HUD_TRAITOR
	show_in_orbit = FALSE
	antag_menu_name = "Контрактник"
	/// How many telecrystals a traitor must forfeit to become a contractor.
	var/tc_cost = 100
	/// How long a traitor's chance to become a contractor lasts before going away. In deciseconds.
	var/offer_duration = 10 MINUTES
	/// world.time at which the offer will expire.
	var/offer_deadline = -1
	/// indicates whether the offer to become a contractor was given to the player by the admin
	var/is_admin_forced = FALSE
	/// The associated contractor uplink. Only present if the offer was accepted.
	var/obj/item/contractor_uplink/contractor_uplink = null
	/// Show if the offer was accepted.
	var/offer_accepted = FALSE


/datum/antagonist/contractor/Destroy(force)
	var/datum/antagonist/traitor/traitor_datum = owner?.has_antag_datum(/datum/antagonist/traitor)
	if(traitor_datum)
		traitor_datum.hidden_uplink?.contractor = null

	if(contractor_uplink)
		contractor_uplink.hub?.owner = null
		contractor_uplink.hub?.contractor_uplink = null

	return ..()


/datum/antagonist/contractor/add_antag_hud(mob/living/antag_mob)
	if(locate(/datum/objective/hijack) in owner.get_all_objectives())
		antag_hud_name = contractor_uplink ? "hudhijackcontractor" : "hudhijack"
	else
		antag_hud_name = contractor_uplink ? "hudcontractor" : "hudsyndicate"
	return ..()


/datum/antagonist/contractor/finalize_antag()

	// Setup the vars and contractor stuff in the uplink
	var/datum/antagonist/traitor/traitor_datum = owner?.has_antag_datum(/datum/antagonist/traitor)
	if(!traitor_datum)
		return

	var/obj/item/uplink/hidden/hidden_uplink = traitor_datum.hidden_uplink
	if(!hidden_uplink)
		stack_trace("Potential contractor [owner] spawned without a hidden uplink!")
		return

	hidden_uplink.contractor = src
	offer_deadline = world.time + offer_duration


/datum/antagonist/contractor/greet()
	// Greet them with the unique message
	var/list/messages = list()
	var/greet_text = "Контрактники отдают [tc_cost] телекристалл[declension_ru(tc_cost, "", "а", "ов")] за возможность выполнять контракты на похищение, получая за это выплаты в виде ТК и кредитов. Это позволяет заработать гораздо больше, чем они имели раньше.<br>" \
					+ "Если вы заинтересованы, просто зайдите в аплинк и выберите вкладку \"Заключение контракта\" для получения дополнительной информации.<br>"
	messages.Add("<b><font size=4 color=red>Вам предложили стать Контрактником.</font></b><br>")
	messages.Add("<font color=red>[greet_text]</font>")
	if(!is_admin_forced)
		messages.Add("<b><i><font color=red>Не упустите возможность! Вы не единственный, кто получил это предложение. \
					Количество доступных предложений ограничено, и если другие агенты примут их раньше вас, то у вас не останется возможности принять участие.</font></i></b>")
	messages.Add("<b><i><font color=red>Срок действия этого предложения истекает через 10 минут, начиная с этого момента (время истечения: <u>[station_time_timestamp(time = offer_deadline)]</u>).</font></i></b>")
	return messages

/datum/antagonist/contractor/on_gain()
	if(!owner?.current)
		return FALSE

	owner.special_role = special_role
	add_owner_to_gamemode()
	var/list/messages = list()
	messages.Add(greet())
	apply_innate_effects()
	messages.Add(finalize_antag())
	messages.Add("<span class='motd'>С полной информацией вы можете ознакомиться на вики: <a href=\"[CONFIG_GET(string/wikiurl)]/index.php/Contractor\">Контрактор</span>")
	to_chat(owner.current, chat_box_red(messages.Join("<br>")))
	if(is_banned(owner.current) && replace_banned)
		INVOKE_ASYNC(src, PROC_REF(replace_banned_player))
	owner.current.create_log(MISC_LOG, "[owner.current] was made into \an [special_role]")
	return TRUE

/**
  * Accepts the offer to be a contractor if possible.
  */
/datum/antagonist/contractor/proc/become_contractor(mob/living/carbon/human/user, obj/item/uplink/uplink)
	if(contractor_uplink || !istype(user))
		return

	var/offers_availability_check = !(SSticker?.mode?.contractor_accepted < CONTRACTOR_MAX_ACCEPTED || is_admin_forced)
	if(uplink.uses < tc_cost || world.time >= offer_deadline || offers_availability_check)
		var/reason = (uplink.uses < tc_cost) ? \
			"у вас недостаточно телекристаллов (всего требуется [tc_cost])" : \
			(offers_availability_check) ? \
			"все предложения уже приняты другими агентами": \
			"срок предложения истёк"
		to_chat(user, span_warning("Вы больше не можете стать Контрактником, потому что [reason]."))
		return

	// Give the kit
	var/obj/item/storage/box/syndie_kit/contractor/contractor_kit = new(user)
	user.put_in_hands(contractor_kit)
	contractor_uplink = locate(/obj/item/contractor_uplink, contractor_kit)
	contractor_uplink.hub = new(user.mind, contractor_uplink)

	// Update AntagHUD icon
	remove_antag_hud(owner.current)
	add_antag_hud(owner.current)

	// Remove the TC
	uplink.uses -= tc_cost

	show_in_orbit = TRUE
	offer_accepted = TRUE

	if(!is_admin_forced)
		SSticker?.mode?.contractor_accepted++

/datum/antagonist/contractor/check_anatag_menu_ability()
	return offer_accepted
