/mob/proc/get_screen_colour()

/mob/proc/update_client_colour(var/time = 10) //Update the mob's client.color with an animation the specified time in length.
	if(!client) //No client_colour without client. If the player logs back in they'll be back through here anyway.
		return
	client.colour_transition(get_screen_colour(), time = time) //Get the colour matrix we're going to transition to depending on relevance (magic glasses first, eyes second).

/mob/living/carbon/human/get_screen_colour() //Fetch the colour matrix from wherever (e.g. eyes) so it can be compared to client.color.
	. = ..()
	if(.)
		return .

	var/obj/item/clothing/glasses/worn_glasses = glasses
	var/obj/item/organ/internal/eyes/eyes = get_int_organ(/obj/item/organ/internal/eyes)
	if(istype(worn_glasses) && worn_glasses.color_view) //Check to see if they got those magic glasses and they're augmenting the colour of what the wearer sees. If they're not, color_view should be null.
		return worn_glasses.color_view
	else if(eyes) //If they're not, check to see if their eyes got one of them there colour matrices. Will be null if eyes are robotic/the mob isn't colourblind and they have no default colour matrix.
		return eyes.get_colourmatrix()

/proc/ismindshielded(A) //Checks to see if the person contains a mindshield implant, then checks that the implant is actually inside of them
	for(var/obj/item/implant/mindshield/L in A)
		if(L && L.implanted)
			return 1
	return 0

/proc/isertmindshielded(A) //Checks to see if the person contains a ert mindshield implant, then checks that the implant is actually inside of them
	for(var/obj/item/implant/mindshield/ert/L in A)
		if(L && L.implanted)
			return 1
	return 0


/proc/isLivingSSD(mob/M)
	return istype(M) && !isnull(M.player_logged) && M.stat != DEAD

/proc/isAntag(A)
	if(isliving(A))
		var/mob/living/L = A
		if(L.mind?.special_role)
			return TRUE
	return FALSE

/proc/isNonCrewAntag(A)
	if(!isAntag(A))
		return 0

	var/mob/living/carbon/C = A
	var/special_role = C.mind.special_role
	var/list/crew_roles = list(
		SPECIAL_ROLE_BLOB,
		SPECIAL_ROLE_CULTIST,
		SPECIAL_ROLE_CHANGELING,
		SPECIAL_ROLE_ERT,
		SPECIAL_ROLE_HEAD_REV,
		SPECIAL_ROLE_REV,
		SPECIAL_ROLE_SHADOWLING,
		SPECIAL_ROLE_SHADOWLING_THRALL,
		SPECIAL_ROLE_TRAITOR,
		SPECIAL_ROLE_VAMPIRE,
		SPECIAL_ROLE_VAMPIRE_THRALL,
		SPECIAL_ROLE_THIEF,
		SPECIAL_ROLE_MALFAI
	)
	if(special_role in crew_roles)
		return 0

	return 1

/proc/cannotPossess(A)
	var/mob/dead/observer/G = A
	if(G.has_enabled_antagHUD && CONFIG_GET(flag/antag_hud_restricted))
		return 1
	return 0


/proc/iscuffed(A)
	if(iscarbon(A))
		var/mob/living/carbon/C = A
		if(C.handcuffed)
			return 1
	return 0

/proc/hassensorlevel(A, var/level)
	var/mob/living/carbon/human/H = A
	if(istype(H) && istype(H.w_uniform, /obj/item/clothing/under))
		var/obj/item/clothing/under/U = H.w_uniform
		return U.sensor_mode >= level
	return 0

/proc/getsensorlevel(A)
	var/mob/living/carbon/human/H = A
	if(istype(H) && istype(H.w_uniform, /obj/item/clothing/under))
		var/obj/item/clothing/under/U = H.w_uniform
		return U.sensor_mode
	return SUIT_SENSOR_OFF

/proc/offer_control(mob/offer_mob, hours, hide_role)
	if(HAS_TRAIT(offer_mob, TRAIT_BEING_OFFERED))
		return
	var/minhours
	ADD_TRAIT(offer_mob, TRAIT_BEING_OFFERED, ADMIN_OFFER_TRAIT)
	to_chat(offer_mob, span_warning("Призракам предложен контроль над вашим существом."))
	if(!hours)
		minhours = tgui_input_number(usr, "Минимальное количество часов, необходимое для игры на [offer_mob]?", "Установите число часов", 10)
	else
		minhours = hours
	if(isnull(minhours))
		return
	log_and_message_admins("has offered control of ([key_name_admin(offer_mob)]) to ghosts with [minhours] hrs playtime")
	var/question = "Вы хотите войти в раунд как [offer_mob.real_name ? offer_mob.real_name : offer_mob][offer_mob.job ? " ([offer_mob.job])" : ""]"
	if(isnull(hide_role))
		if(tgui_alert(usr, "Вы хотите показывать спец-роль существа?","Показывать спец-роль", list("Да","Нет")) == "Да")
			question += ", [offer_mob.mind?.special_role || "Нет спец-роли"]"
	else if(!hide_role)
		question += ", [offer_mob.mind?.special_role ? offer_mob.mind?.special_role : "Нет спец-роли"]"
	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("[question]?", poll_time = 10 SECONDS, min_hours = minhours, source = offer_mob)
	var/mob/dead/observer/theghost = null

	REMOVE_TRAIT(offer_mob, TRAIT_BEING_OFFERED, ADMIN_OFFER_TRAIT)

	if(LAZYLEN(candidates))
		theghost = pick(candidates)
		to_chat(offer_mob, span_notice("Контроль над вашим существом был передан призраку!"))
		message_admins("[key_name_admin(theghost)] has taken control of ([key_name_admin(offer_mob)])")
		log_game("[theghost.key] has taken control of [offer_mob] (ckey: [offer_mob.key])")
		offer_mob.ghostize()
		offer_mob.key = theghost.key
	else
		to_chat(offer_mob, span_notice("Не было призраков, желающих взять под свой контроль ваше существо."))
		log_game("No one decided to take control of [offer_mob] (ckey: [offer_mob.key])")
		message_admins("No ghosts were willing to take control of [key_name_admin(offer_mob)])")

/proc/check_zone(zone)
	if(!zone)
		return BODY_ZONE_CHEST
	switch(zone)
		if(BODY_ZONE_PRECISE_EYES)
			zone = BODY_ZONE_HEAD
		if(BODY_ZONE_PRECISE_MOUTH)
			zone = BODY_ZONE_HEAD
	return zone

// Returns zone with a certain probability.
// If the probability misses, returns "chest" instead.
// If "chest" was passed in as zone, then on a "miss" will return "head", "l_arm", or "r_arm"
// Do not use this if someone is intentionally trying to hit a specific body part.
// Use get_zone_with_miss_chance() for that.
/proc/ran_zone(zone, probability = 80)

	zone = check_zone(zone)

	if(prob(probability))
		return zone

	switch(rand(1, 18))	// randomly pick a different zone, or maybe the same one
		if(1)
			return BODY_ZONE_HEAD
		if(2)
			return BODY_ZONE_CHEST
		if(3 to 4)
			return BODY_ZONE_L_ARM
		if(5 to 6)
			return BODY_ZONE_PRECISE_L_HAND
		if(7 to 8)
			return BODY_ZONE_R_ARM
		if(9 to 10)
			return BODY_ZONE_PRECISE_R_HAND
		if(11 to 12)
			return BODY_ZONE_L_LEG
		if(13 to 14)
			return BODY_ZONE_PRECISE_L_FOOT
		if(15 to 16)
			return BODY_ZONE_R_LEG
		if(17 to 18)
			return BODY_ZONE_PRECISE_R_FOOT
	return zone


/proc/above_neck(zone)
	var/list/zones = list(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_PRECISE_EYES)
	if(zones.Find(zone))
		return TRUE
	return FALSE


/proc/stars(n, pr)
	if(pr == null)
		pr = 25
	if(pr <= 0)
		return null
	else
		if(pr >= 100)
			return n
	var/te = n
	var/t = ""
	n = length_char(n)
	var/p = null
	p = 1
	while(p <= n)
		if((copytext_char(te, p, p + 1) == " " || prob(pr)))
			t = text("[][]", t, copytext_char(te, p, p + 1))
		else
			t = text("[]*", t)
		p++
	return t

/proc/stars_all(list/message_pieces, pr)
	for(var/datum/multilingual_say_piece/S in message_pieces)
		S.message = stars(S.message, pr)

/proc/slur(phrase, var/list/slurletters = ("'"))//use a different list as an input if you want to make robots slur with $#@%! characters
	phrase = html_decode(phrase)
	var/leng=length_char(phrase)
	var/counter=length_char(phrase)
	var/newphrase=""
	var/newletter=""
	while(counter>=1)
		newletter=copytext_char(phrase,(leng-counter)+1,(leng-counter)+2)
		if(rand(1,3)==3)
			if(lowertext(newletter)=="o")	newletter="u"
			if(lowertext(newletter)=="s")	newletter="ch"
			if(lowertext(newletter)=="a")	newletter="ah"
			if(lowertext(newletter)=="c")	newletter="k"
			if(lowertext(newletter)=="о")	newletter="у"
			if(lowertext(newletter)=="с")	newletter="ч"
			if(lowertext(newletter)=="а")	newletter="ах"
			if(lowertext(newletter)=="ц")	newletter="к"
			if(lowertext(newletter)=="э")	newletter="о"
			if(lowertext(newletter)=="г")	newletter="х"
		switch(rand(1,8))
			if(1,3,5,8)	newletter="[lowertext(newletter)]"
			if(2,4,6)	newletter="[uppertext(newletter)]"
			if(7)	newletter+=pick(slurletters)
			//if(9,10)	newletter="<b>[newletter]</b>"
			//if(11,12)	newletter="<big>[newletter]</big>"
			//if(13)	newletter="<small>[newletter]</small>"
		newphrase+="[newletter]"
		counter-=1
	return newphrase

/proc/stutter(n)
	var/te = html_decode(n)
	var/t = ""//placed before the message. Not really sure what it's for.
	n = length_char(n)//length of the entire word
	var/p = null
	p = 1//1 is the start of any word
	while(p <= n)//while P, which starts at 1 is less or equal to N which is the length.
		var/n_letter = copytext_char(te, p, p + 1)//copies text from a certain distance. In this case, only one letter at a time.
		if(prob(80) && (lowertext(n_letter) in list("b","c","d","f","g","h","j","k","l","m","n","p","q","r","s","t","v","w","x","y","z","б","в","г","д","ж","з","к","л","м","н","п","р","с","т","ф","х","ц","ч","ш","щ")))
			if(prob(10))
				n_letter = text("[n_letter]-[n_letter]-[n_letter]-[n_letter]")//replaces the current letter with this instead.
			else
				if(prob(20))
					n_letter = text("[n_letter]-[n_letter]-[n_letter]")
				else
					if(prob(5))
						n_letter = null
					else
						n_letter = text("[n_letter]-[n_letter]")
		t = text("[t][n_letter]")//since the above is ran through for each letter, the text just adds up back to the original word.
		p++//for each letter p is increased to find where the next letter will be.
	return sanitize(copytext_char(t,1,MAX_MESSAGE_LEN))

/proc/robostutter(n) //for robutts
	var/te = html_decode(n)
	var/t = ""//placed before the message. Not really sure what it's for.
	n = length_char(n)//length of the entire word
	var/p = null
	p = 1//1 is the start of any word
	while(p <= n)//while P, which starts at 1 is less or equal to N which is the length.
		var/robotletter = pick("@", "!", "#", "$", "%", "&", "?") //for beep boop
		var/n_letter = copytext_char(te, p, p + 1)//copies text from a certain distance. In this case, only one letter at a time.
		if(prob(80) && (lowertext(n_letter) in list("b","c","d","f","g","h","j","k","l","m","n","p","q","r","s","t","v","w","x","y","z","б","в","г","д","ж","з","к","л","м","н","п","р","с","т","ф","х","ц","ч","ш","щ")))
			if(prob(10))
				n_letter = text("[n_letter]-[robotletter]-[n_letter]-[n_letter]")//replaces the current letter with this instead.
			else
				if(prob(20))
					n_letter = text("[n_letter]-[robotletter]-[n_letter]")
				else
					if(prob(5))
						n_letter = robotletter
					else
						n_letter = text("[n_letter]-[n_letter]")
		t = text("[t][n_letter]")//since the above is ran through for each letter, the text just adds up back to the original word.
		p++//for each letter p is increased to find where the next letter will be.
	return sanitize(copytext_char(t,1,MAX_MESSAGE_LEN))


/proc/Gibberish(t, p)//t is the inputted message, and any value higher than 70 for p will cause letters to be replaced instead of added
	/* Turn text into complete gibberish! */
	var/returntext = ""
	for(var/i = 1, i <= length_char(t), i++)

		var/letter = copytext_char(t, i, i+1)
		if(prob(50))
			if(p >= 70)
				letter = ""

			for(var/j = 1, j <= rand(0, 2), j++)
				letter += pick("#","@","*","&","%","$","/", "<", ">", ";","*","*","*","*","*","*","*")

		returntext += letter

	return returntext

/proc/Gibberish_all(list/message_pieces, p)
	for(var/datum/multilingual_say_piece/S in message_pieces)
		S.message = Gibberish(S.message, p)


/proc/muffledspeech(phrase)
	phrase = html_decode(phrase)
	var/leng=length_char(phrase)
	var/counter=length_char(phrase)
	var/newphrase=""
	var/newletter=""
	while(counter>=1)
		newletter=copytext_char(phrase,(leng-counter)+1,(leng-counter)+2)
		if(newletter in list(" ", "!", "?", ".", ","))
			//do nothing
		else if(lowertext(newletter) in list("a", "e", "i", "o", "u", "y", "а", "е", "ё", "и", "о", "у", "ы", "э", "ю", "я"))
			newletter = "пф"
		else
			newletter = "м"
		newphrase+="[newletter]"
		counter-=1
	return newphrase

/proc/muffledspeech_all(list/message_pieces)
	for(var/datum/multilingual_say_piece/S in message_pieces)
		S.message = muffledspeech(S.message)


/// Shake the camera of the person viewing the mob SO REAL!
/proc/shake_camera(mob/M, duration, strength = 1)
	if(!M || !M.client || duration < 1)
		return
	var/client/C = M.client
	var/oldx = C.pixel_x
	var/oldy = C.pixel_y
	var/max = strength * world.icon_size
	var/min = -(strength * world.icon_size)

	for(var/i in 0 to duration - 1)
		if(i == 0)
			animate(C, pixel_x = rand(min, max), pixel_y = rand(min, max), time = 1)
		else
			animate(pixel_x = rand(min, max), pixel_y = rand(min, max), time = 1)
	animate(pixel_x = oldx, pixel_y = oldy, time = 1)


/proc/findname(msg)
	for(var/mob/M in GLOB.mob_list)
		if(M.real_name == text("[msg]"))
			return 1
	return 0


/mob/proc/abiotic(full_body = FALSE)
	if(full_body && ((l_hand && !(l_hand.item_flags & ABSTRACT)) || (r_hand && !(r_hand.item_flags & ABSTRACT)) || (back || wear_mask)))
		return TRUE

	if((l_hand && !(l_hand.item_flags & ABSTRACT)) || (r_hand && !(r_hand.item_flags & ABSTRACT)))
		return TRUE

	return FALSE

//converts intent-strings into numbers and back
GLOBAL_LIST_INIT(intents, list(INTENT_HELP,INTENT_DISARM,INTENT_GRAB,INTENT_HARM))
/proc/intent_numeric(argument)
	if(istext(argument))
		switch(argument)
			if(INTENT_HELP)		return 0
			if(INTENT_DISARM)	return 1
			if(INTENT_GRAB)		return 2
			else			return 3
	else
		switch(argument)
			if(0)			return INTENT_HELP
			if(1)			return INTENT_DISARM
			if(2)			return INTENT_GRAB
			else			return INTENT_HARM

//change a mob's act-intent. Input the intent as a string such as "help" or use "right"/"left
/mob/verb/a_intent_change(input as text)
	set name = "a-intent"
	set hidden = 1

	if(can_change_intents)
		if(ishuman(src) || isalienadult(src) || isbrain(src))
			switch(input)
				if(INTENT_HELP,INTENT_DISARM,INTENT_GRAB,INTENT_HARM)
					a_intent = input
				if("right")
					a_intent = intent_numeric((intent_numeric(a_intent)+1) % 4)
				if("left")
					a_intent = intent_numeric((intent_numeric(a_intent)+3) % 4)
			if(hud_used && hud_used.action_intent)
				hud_used.action_intent.icon_state = "[a_intent]"

		else if(isrobot(src) || islarva(src) || isanimal(src) || isAI(src))
			switch(input)
				if(INTENT_HELP)
					a_intent = INTENT_HELP
				if(INTENT_HARM)
					a_intent = INTENT_HARM
				if("right","left")
					a_intent = intent_numeric(intent_numeric(a_intent) - 3)
			if(hud_used && hud_used.action_intent)
				if(a_intent == INTENT_HARM)
					hud_used.action_intent.icon_state = "harm"
				else
					hud_used.action_intent.icon_state = "help"


/mob/living/verb/mob_sleep()
	set name = "Sleep"
	set category = "IC"

	if(IsSleeping())
		to_chat(src, "<span class='notice'>Вы уже спите.</span>")
		return
	else
		if(tgui_alert(src, "You sure you want to sleep for a while?", "Sleep", list("Yes", "No")) == "Yes")
			SetSleeping(40 SECONDS) //Short nap


/proc/get_multitool(mob/user as mob)
	// Get tool
	var/obj/item/multitool/P
	if(isrobot(user) || ishuman(user))
		P = user.get_active_hand()
	else if(isAI(user))
		var/mob/living/silicon/ai/AI=user
		P = AI.aiMulti

	if(!istype(P))
		return null
	return P

/proc/get_both_hands(mob/living/carbon/M)
	return list(M.l_hand, M.r_hand)


//Direct dead say used both by emote and say
//It is somewhat messy. I don't know what to do.
//I know you can't see the change, but I rewrote the name code. It is significantly less messy now
/proc/say_dead_direct(message, mob/subject = null)
	var/name
	var/keyname
	if(subject && subject.client)
		var/client/C = subject.client
		keyname = (C.holder && C.holder.fakekey) ? C.holder.fakekey : C.key
		if(C.mob) //Most of the time this is the dead/observer mob; we can totally use him if there is no better name
			var/mindname
			var/realname = C.mob.real_name
			if(C.mob.mind)
				mindname = C.mob.mind.name
				if(C.mob.mind.original_mob_name)
					realname = C.mob.mind.original_mob_name
			if(mindname && mindname != realname)
				name = "[realname] died as [mindname]"
			else
				name = realname

	for(var/mob/M in GLOB.player_list)
		if(M.client && ((!isnewplayer(M) && M.stat == DEAD) || check_rights(R_ADMIN|R_MOD,0,M)) && M.get_preference(PREFTOGGLE_CHAT_DEAD))
			var/follow
			var/lname
			if(subject)
				if(subject != M)
					follow = "([ghost_follow_link(subject, ghost=M)]) "
				if(M.stat != DEAD && check_rights(R_ADMIN|R_MOD,0,M))
					follow = "([admin_jump_link(subject)]) "
				var/mob/dead/observer/DM
				if(isobserver(subject))
					DM = subject
				if(check_rights(R_ADMIN|R_MOD, FALSE, M)) 							// What admins see
					lname = "[keyname][(DM?.client.prefs.toggles2 & PREFTOGGLE_2_ANON) ? (@"[ANON]") : (DM ? "" : "^")] ([name])"
				else
					if(DM?.client.prefs.toggles2 & PREFTOGGLE_2_ANON)	// If the person is actually observer they have the option to be anonymous
						lname = "<i>Anon</i> ([name])"
					else if(DM)									// Non-anons
						lname = "[keyname] ([name])"
					else										// Everyone else (dead people who didn't ghost yet, etc.)
						lname = name
				lname = "<span class='name'>[lname]</span> "
			to_chat(M, "<span class='deadsay'>[lname][follow][message]</span>")

/proc/notify_ghosts(message, ghost_sound = null, enter_link = null, title = null, atom/source = null, image/alert_overlay = null, flashwindow = TRUE, var/action = NOTIFY_JUMP) //Easy notification of ghosts.
	for(var/mob/dead/observer/O in GLOB.player_list)
		if(O.client)
			to_chat(O, "<span class='ghostalert'>[message][(enter_link) ? " [enter_link]" : ""]</span>")
			if(ghost_sound)
				O << sound(ghost_sound)
			if(flashwindow)
				window_flash(O.client)
			if(source)
				var/atom/movable/screen/alert/notify_action/A = O.throw_alert("\ref[source]_notify_action", /atom/movable/screen/alert/notify_action)
				if(A)
					if(O.client.prefs && O.client.prefs.UI_style)
						A.icon = ui_style2icon(O.client.prefs.UI_style)
					if(title)
						A.name = title
					A.desc = message
					A.action = action
					A.target = source
					if(!alert_overlay)
						var/old_layer = source.layer
						var/old_plane = source.plane
						source.layer = FLOAT_LAYER
						source.plane = FLOAT_PLANE
						A.add_overlay(source)
						source.layer = old_layer
						source.plane = old_plane
					else
						alert_overlay.layer = FLOAT_LAYER
						alert_overlay.plane = FLOAT_PLANE
						A.add_overlay(alert_overlay)


/**
  * Checks if a mob's ghost can reenter their body or not. Used to check for DNR or AntagHUD.
  *
  * Returns FALSE if there is a ghost, and it can't reenter the body. Returns TRUE otherwise.
  */
/mob/proc/ghost_can_reenter()
	var/mob/dead/observer/ghost = get_ghost(TRUE)
	if(ghost && !ghost.can_reenter_corpse)
		return FALSE
	return TRUE

/mob/proc/switch_to_camera(obj/machinery/camera/C)
	if(!C.can_use() || incapacitated() || (get_dist(C, src) > 1 || machine != src || !has_vision()))
		return FALSE
	check_eye(src)
	return TRUE

/mob/proc/rename_character(oldname, newname)
	if(!newname)
		return 0
	real_name = newname
	name = newname
	if(mind)
		mind.name = newname
	if(dna)
		dna.real_name = real_name

	if(oldname)
		//update the datacore records! This is goig to be a bit costly.
		for(var/list/L in list(GLOB.data_core.general, GLOB.data_core.medical, GLOB.data_core.security, GLOB.data_core.locked))
			for(var/datum/data/record/R in L)
				if(R.fields["name"] == oldname)
					R.fields["name"] = newname
					if(length(R.fields["id"]) == 32)
						R.fields["id"] = md5("[newname][mind.assigned_role]")
					break

		//update our pda and id if we have them on our person
		var/list/searching = GetAllContents(searchDepth = 3)
		var/search_id = 1
		var/search_pda = 1

		for(var/A in searching)
			if( search_id && istype(A,/obj/item/card/id) )
				var/obj/item/card/id/ID = A
				if(ID.registered_name == oldname)
					ID.registered_name = newname
					ID.name = "[newname]'s ID Card ([ID.assignment])"
					ID.RebuildHTML()
					if(!search_pda)	break
					search_id = 0

			else if( search_pda && is_pda(A) )
				var/obj/item/pda/PDA = A
				if(PDA.owner == oldname)
					PDA.update_owner_name(newname)
					PDA.name = "PDA-[newname] ([PDA.ownjob])"
					if(!search_id)	break
					search_pda = 0

		//Fixes renames not being reflected in objective text
		var/length
		var/pos
		for(var/datum/objective/objective in GLOB.all_objectives)
			if(!mind || objective.target != mind)
				continue
			length = length_char(oldname)
			pos = findtextEx_char(objective.explanation_text, oldname)
			objective.explanation_text = copytext_char(objective.explanation_text, 1, pos)+newname+copytext_char(objective.explanation_text, pos+length)
	return 1

/mob/proc/rename_self(var/role, var/allow_numbers = FALSE, var/force = FALSE)
	spawn(0)
		var/oldname = real_name

		var/time_passed = world.time
		var/newname

		for(var/i=1,i<=3,i++)	//we get 3 attempts to pick a suitable name.
			if(force)
				newname = tgui_input_text(src, "Выберите новое имя.", "Смена имени", oldname)
			else
				newname = tgui_input_text(src, "Вы [role]. Не хотите поменять своё имя на другое? У вас есть 3 минуты для выбора нового имени.", "Смена имени", oldname, timeout = 3 MINUTES)
			if(((world.time - time_passed) > 1800) && !force)
				tgui_alert(src, "К сожалению, время для выбора имени кончилось. Если вы киборг, используйте команду «Namepick»; иначе — «Adminhelp».", "Смена имени")
				return	//took too long
			newname = reject_bad_name(newname,allow_numbers)	//returns null if the name doesn't meet some basic requirements. Tidies up a few other things like bad-characters.

			for(var/mob/living/M in GLOB.player_list)
				if(M == src)
					continue
				if(!newname || M.real_name == newname)
					newname = null
					break
			if(newname)
				break	//That's a suitable name!
			to_chat(src, "Извините, но это имя не подходит для роли «[role]». Возможно, оно слишком длинное или короткое, содержит неподходящие символы, либо уже занято.")

		if(!newname)	//we'll stick with the oldname then
			return

		rename_character(oldname, newname)

/proc/cultslur(n) // Inflicted on victims of a stun talisman
	var/phrase = html_decode(n)
	var/leng = length_char(phrase)
	var/counter=length_char(phrase)
	var/newphrase=""
	var/newletter=""
	while(counter>=1)
		newletter=copytext_char(phrase,(leng-counter)+1,(leng-counter)+2)
		if(rand(1,2)==2)
			if(lowertext(newletter)=="o")
				newletter="u"
			if(lowertext(newletter)=="t")
				newletter="ch"
			if(lowertext(newletter)=="a")
				newletter="ah"
			if(lowertext(newletter)=="u")
				newletter="oo"
			if(lowertext(newletter)=="c")
				newletter=" NAR "
			if(lowertext(newletter)=="s")
				newletter=" SIE "
			if(lowertext(newletter)=="о")
				newletter="у"
			if(lowertext(newletter)=="т")
				newletter="ч"
			if(lowertext(newletter)=="а")
				newletter="ах"
			if(lowertext(newletter)=="у")
				newletter="уу"
			if(lowertext(newletter)=="ц")
				newletter=" НАР "
			if(lowertext(newletter)=="с")
				newletter=" СИ "
		if(rand(1,4)==4)
			if(newletter==" ")
				newletter=" no hope... "
			if(newletter=="H")
				newletter=" IT COMES... "
			if(newletter=="Х")
				newletter=" ИДЁТ... "

		switch(rand(1,15))
			if(1)
				newletter="'"
			if(2)
				newletter+="agn"
			if(3)
				newletter="fth"
			if(4)
				newletter="nglu"
			if(5)
				newletter="glor"
			else
				pass()
		newphrase+="[newletter]";counter-=1
	return newphrase

/mob/proc/clockslur(n)
	var/phrase = html_decode(n)
	var/leng = length_char(phrase)
	var/counter=length_char(phrase)
	var/newphrase=""
	var/newletter=""
	while(counter>=1)
		newletter=copytext_char(phrase,(leng-counter)+1,(leng-counter)+2)
		if(rand(1,2)==2)
			if(lowertext(newletter)=="o")
				newletter="UL"
			if(lowertext(newletter)=="n")
				newletter="n-q"
			if(lowertext(newletter)=="a")
				newletter="aha"
			if(lowertext(newletter)=="u")
				newletter="u-"
			if(lowertext(newletter)=="i")
				newletter=" KI "
			if(lowertext(newletter)=="r")
				newletter=" RAT "
			if(lowertext(newletter)=="t")
				newletter=" TV "
			if(lowertext(newletter)=="v")
				newletter=" VAR "
			if(lowertext(newletter)=="о")
				newletter="УЛ"
			if(lowertext(newletter)=="н")
				newletter="н-к"
			if(lowertext(newletter)=="а")
				newletter="аха"
			if(lowertext(newletter)=="у")
				newletter="у-"
			if(lowertext(newletter)=="и")
				newletter=" КИ "
			if(lowertext(newletter)=="р")
				newletter=" РАТ "
			if(lowertext(newletter)=="т")
				newletter=" ТВ "
			if(lowertext(newletter)=="в")
				newletter=" ВАР "
		if(rand(1,4)==4)
			if(newletter==" ")
				newletter=" light... "
			if(newletter=="П")
				newletter=" ПРОСНИСЬ... "
			if(newletter=="К")
				newletter=" УВИДЬ... "
		switch(rand(1,15))
			if(1)
				newletter="'"
			if(2)
				newletter+="n-ta"
			if(3)
				newletter="sg-u"
			if(4)
				newletter="a'tyh"
			if(5)
				newletter="t,ybe"
			else
				pass()
		newphrase+="[newletter]";counter-=1
	return rot13(newphrase)

/mob/proc/get_preference(toggleflag)
	if(!client)
		return FALSE
	if(!client.prefs)
		log_runtime(EXCEPTION("Mob '[src]', ckey '[ckey]' is missing a prefs datum on the client!"))
		return FALSE
	// Cast to 1/0
	return !!(client.prefs.toggles & toggleflag)


/**
 * Helper proc to determine if a mob can use emotes that make sound or not.
 */
/mob/proc/can_use_audio_emote(intentional)
	var/emote_status = intentional ? audio_emote_cd_status : audio_emote_unintentional_cd_status
	switch(emote_status)
		if(EMOTE_INFINITE)  // Spam those emotes
			return TRUE
		if(EMOTE_ADMIN_BLOCKED)  // Cooldown emotes were disabled by an admin, prevent use
			return FALSE
		if(EMOTE_ON_COOLDOWN)	// Already on CD, prevent use
			return FALSE
		if(EMOTE_READY)
			return TRUE

	CRASH("Invalid emote type")


/**
 * Start the cooldown for an emote that plays audio.
 *
 * Arguments:
 * * intentional - Whether or not the user deliberately triggered this emote.
 * * cooldown - The amount of time that should be waited before any other audio emote can fire.
 */
/mob/proc/start_audio_emote_cooldown(intentional, cooldown = AUDIO_EMOTE_COOLDOWN)
	if(!can_use_audio_emote(intentional))
		return FALSE

	var/cooldown_source = intentional ? audio_emote_cd_status : audio_emote_unintentional_cd_status

	if(cooldown_source == EMOTE_READY)
		// we do have to juggle between cooldowns a little bit, but this lets us keep them on separate cooldowns so
		// a user screaming every five seconds doesn't prevent them from sneezing.
		if(intentional)
			audio_emote_cd_status = EMOTE_ON_COOLDOWN	// Starting cooldown
		else
			audio_emote_unintentional_cd_status = EMOTE_ON_COOLDOWN
		addtimer(CALLBACK(src, PROC_REF(on_audio_emote_cooldown_end), intentional), cooldown)
	return TRUE  // proceed with emote


/mob/proc/on_audio_emote_cooldown_end(intentional)
	if(intentional)
		if(audio_emote_cd_status == EMOTE_ON_COOLDOWN)
			// only reset to ready if we're in a cooldown state
			audio_emote_cd_status = EMOTE_READY
	else
		if(audio_emote_unintentional_cd_status == EMOTE_ON_COOLDOWN)
			audio_emote_unintentional_cd_status = EMOTE_READY


/proc/stat_to_text(stat)
	switch(stat)
		if(CONSCIOUS)
			return "conscious"
		if(UNCONSCIOUS)
			return "unconscious"
		if(DEAD)
			return "dead"


// Used to make sure that a player has a valid job preference setup, used to knock players out of eligibility for anything if their prefs don't make sense.
// A "valid job preference setup" in this situation means at least having one job set to low, or not having "return to lobby" enabled
// Prevents "antag rolling" by setting antag prefs on, all jobs to never, and "return to lobby if preferences not availible"
// Doing so would previously allow you to roll for antag, then send you back to lobby if you didn't get an antag role
// This also does some admin notification and logging as well
/mob/proc/has_valid_preferences()
	if(!client)
		return FALSE //Not sure how this would get run without the mob having a client, but let's just be safe.
	if(client.prefs.alternate_option != RETURN_TO_LOBBY)
		return TRUE
	// If they have antags enabled, they're potentially doing this on purpose instead of by accident. Notify admins if so.
	var/has_antags = FALSE
	if(client.prefs.be_special.len > 0)
		has_antags = TRUE
	if(!client.prefs.check_any_job())
		to_chat(src, "<span class='danger'>You have no jobs enabled, along with return to lobby if job is unavailable. This makes you ineligible for any round start role, please update your job preferences.</span>")
		if(has_antags)
			log_admin("[src.ckey] just got booted back to lobby with no jobs, but antags enabled.")
			message_admins("[src.ckey] just got booted back to lobby with no jobs enabled, but antag rolling enabled. Likely antag rolling abuse.")
		return FALSE //This is the only case someone should actually be completely blocked from antag rolling as well
	return TRUE


/mob/proc/can_pass_adjacent(atom/adjacent, list/types_to_exclude)
	if(!isturf(loc))
		return FALSE
	if(!adjacent)
		return FALSE
	if(!isturf(adjacent))
		adjacent = get_turf(adjacent)
		if(!adjacent)
			return FALSE
	if(loc == adjacent)
		return TRUE
	if(!in_range(src, adjacent))
		return FALSE
	var/border_dir = get_dir(adjacent, src)
	if(!is_type_in_list(adjacent, types_to_exclude) && !adjacent.CanPass(src, border_dir))
		return FALSE
	for(var/atom/check_atom as anything in adjacent)
		if(is_type_in_list(check_atom, types_to_exclude))
			continue
		if(!check_atom.CanPass(src, border_dir))
			return FALSE
	return TRUE


/// Takes in an associated list (key `/datum/action` typepaths, value is the AI blackboard key) and handles granting the action and adding it to the mob's AI controller blackboard.
/// This is only useful in instances where you don't want to store the reference to the action on a variable on the mob.
/mob/proc/grant_actions_by_list(list/input)
	if(length(input) <= 0)
		return

	for(var/action in input)
		var/datum/action/ability = new action(src)
		ability.Grant(src)

