GLOBAL_LIST_INIT(department_radio_keys, list(
/*
	Busy letters for language:
	a b d f g j k o q v x y
	aa as bo db fa fm fn fs vu

	Busy symbols for language:
	0 1 2 3 4 5 6 7 8 9
	% ? ^


	Busy letters by radio(eng):
	c e h i l m n p r s t u w x


	Busy letters by radio(rus):
	б г д е ё з к р с т у ц ч ш ы ь я э


	Busy symbols by radio:
	~ , $ _ - + *

	CAUTION!	The key must not repeat the key of the languages (language.dm)
				and must not contain prohibited characters!
*/
	// English text lowercase
	  ":r" = "right ear",		"#r" = "right ear",		"№r" = "right ear",		".r" = "right ear",
	  ":l" = "left ear",		"#l" = "left ear",		"№l" = "left ear",		".l" = "left ear",
	  ":i" = "intercom",		"#i" = "intercom",		"№i" = "intercom",		".i" = "intercom",
	  ":h" = "department",		"#h" = "department",	"№h" = "department",	".h" = "department",
	  ":c" = "Command",			"#c" = "Command",		"№c" = "Command",		".c" = "Command",
	  ":n" = "Science",			"#n" = "Science",		"№n" = "Science",		".n" = "Science",
	  ":m" = "Medical",			"#m" = "Medical",		"№m" = "Medical",		".m" = "Medical",
	  ":x" = "Procedure",		"#x" = "Procedure",		"№x" = "Procedure",		".x" = "Procedure",
	  ":e" = "Engineering", 	"#e" = "Engineering",	"№e" = "Engineering",	".e" = "Engineering",
	  ":s" = "Security",		"#s" = "Security",		"№s" = "Security",		".s" = "Security",
	  ":w" = "whisper",			"#w" = "whisper",		"№w" = "whisper",		".w" = "whisper",
	  ":t" = "Syndicate",		"#t" = "Syndicate",		"№t" = "Syndicate",		".t" = "Syndicate",
	  ":'" = "Soviet",			"#'" = "Soviet",		"№'" = "Soviet",		".'" = "Soviet",
	  ":u" = "Supply",			"#u" = "Supply",		"№u" = "Supply",		".u" = "Supply",
	  ":z" = "Service",			"#z" = "Service",		"№z" = "Service",		".z" = "Service",
	  ":p" = "AI Private",		"#p" = "AI Private",	"№p" = "AI Private",	".p" = "AI Private",

	// English text uppercase
	  ":R" = "right ear",		"#R" = "right ear",		"№R" = "right ear",		".R" = "right ear",
	  ":L" = "left ear",		"#L" = "left ear",		"№L" = "left ear",		".L" = "left ear",
	  ":I" = "intercom",		"#I" = "intercom",		"№I" = "intercom",		".I" = "intercom",
	  ":H" = "department",		"#H" = "department",	"№H" = "department",	".H" = "department",
	  ":C" = "Command",			"#C" = "Command",		"№C" = "Command",		".C" = "Command",
	  ":N" = "Science",			"#N" = "Science",		"№N" = "Science",		".N" = "Science",
	  ":M" = "Medical",			"#M" = "Medical",		"№M" = "Medical",		".M" = "Medical",
	  ":X" = "Procedure",		"#X" = "Procedure",		"№X" = "Procedure",		".X" = "Procedure",
	  ":E" = "Engineering",		"#E" = "Engineering",	"№E" = "Engineering",	".E" = "Engineering",
	  ":S" = "Security",		"#S" = "Security",		"№S" = "Security",		".S" = "Security",
	  ":W" = "whisper",			"#W" = "whisper",		"№W" = "whisper",		".W" = "whisper",
	  ":T" = "Syndicate",		"#T" = "Syndicate",		"№T" = "Syndicate",		".T" = "Syndicate",
	  ":'" = "Soviet",			"#'" = "Soviet",		"№'" = "Soviet",		".'" = "Soviet",
	  ":U" = "Supply",			"#U" = "Supply",		"№U" = "Supply",		".U" = "Supply",
	  ":Z" = "Service",			"#Z" = "Service",		"№Z" = "Service",		".Z" = "Service",
	  ":P" = "AI Private",		"#P" = "AI Private",	"№P" = "AI Private",	".P" = "AI Private",

	// Russian text lowercase
	  ":к" = "right ear",		"#к" = "right ear",		"№к" = "right ear",		".к" = "right ear",
	  ":д" = "left ear",		"#д" = "left ear",		"№д" = "left ear",		".д" = "left ear",
	  ":ш" = "intercom",		"#ш" = "intercom",		"№ш" = "intercom",		".ш" = "intercom",
	  ":р" = "department",		"#р" = "department",	"№р" = "department",	".р" = "department",
	  ":с" = "Command",			"#с" = "Command",		"№с" = "Command",		".с" = "Command",
	  ":т" = "Science",			"#т" = "Science",		"№т" = "Science",		".т" = "Science",
	  ":ь" = "Medical",			"#ь" = "Medical",		"№ь" = "Medical",		".ь" = "Medical",
	  ":ч" = "Procedure",		"#ч" = "Procedure",		"№ч" = "Procedure",		".ч" = "Procedure",
	  ":у" = "Engineering", 	"#у" = "Engineering",	"№у" = "Engineering",	".у" = "Engineering",
	  ":ы" = "Security",		"#ы" = "Security",		"№ы" = "Security",		".ы" = "Security",
	  ":ц" = "whisper",			"#ц" = "whisper",		"№ц" = "whisper",		".ц" = "whisper",
	  ":е" = "Syndicate",		"#е" = "Syndicate",		"№е" = "Syndicate",		".е" = "Syndicate",
	  ":э" = "Soviet",			"#э" = "Soviet",		"№э" = "Soviet",		".э" = "Soviet",
	  ":б" = "SyndTaipan",		"#б" = "SyndTaipan",	"№б" = "SyndTaipan",	".б" = "SyndTaipan",
	  ":г" = "Supply",			"#г" = "Supply",		"№г" = "Supply",		".г" = "Supply",
	  ":я" = "Service",			"#я" = "Service",		"№я" = "Service",		".я" = "Service",
	  ":з" = "AI Private",		"#з" = "AI Private",	"№з" = "AI Private",	".з" = "AI Private",
	  ":ё" = "cords",			"#ё" = "cords",			"№ё" = "cords",			".ё" = "cords",

	// Russian text uppercase
	  ":К" = "right ear",		"#К" = "right ear",		"№К" = "right ear",		".К" = "right ear",
	  ":Д" = "left ear",		"#Д" = "left ear",		"№Д" = "left ear",		".Д" = "left ear",
	  ":Ш" = "intercom",		"#Ш" = "intercom",		"№Ш" = "intercom",		".Ш" = "intercom",
	  ":Р" = "department",		"#Р" = "department",	"№Р" = "department",	".Р" = "department",
	  ":С" = "Command",			"#С" = "Command",		"№С" = "Command",		".С" = "Command",
	  ":Т" = "Science",			"#Т" = "Science",		"№Т" = "Science",		".Т" = "Science",
	  ":Ь" = "Medical",			"#Ь" = "Medical",		"№Ь" = "Medical",		".Ь" = "Medical",
	  ":У" = "Engineering",		"#У" = "Engineering",	"№У" = "Engineering",	".У" = "Engineering",
	  ":Ы" = "Security",		"#Ы" = "Security",		"№Ы" = "Security",		".Ы" = "Security",
	  ":Ц" = "whisper",			"#Ц" = "whisper",		"№Ц" = "whisper",		".Ц" = "whisper",
	  ":Е" = "Syndicate",		"#Е" = "Syndicate",		"№Е" = "Syndicate",		".Е" = "Syndicate",
	  ":Э" = "Soviet",			"#Э" = "Soviet",		"№Э" = "Soviet",		".Э" = "Soviet",
	  ":Б" = "SyndTaipan",		"#Б" = "SyndTaipan",	"№Б" = "SyndTaipan",	".Б" = "SyndTaipan",
	  ":Г" = "Supply",			"#Г" = "Supply",		"№Г" = "Supply",		".Г" = "Supply",
	  ":Я" = "Service",			"#Я" = "Service",		"№Я" = "Service",		".Я" = "Service",
	  ":З" = "AI Private",		"#З" = "AI Private",	"№З" = "AI Private",	".З" = "AI Private",
	  ":Ё" = "cords",			"#Ё" = "cords",			"№Ё" = "cords",			".Ё" = "cords",

	// English symbols no case
	  ":~" = "cords",			"#~" = "cords",			"№~" = "cords",			".~" = "cords",
	  ":," = "SyndTaipan",		"#," = "SyndTaipan",	"№," = "SyndTaipan",	".," = "SyndTaipan",
	  ":1" = "Alpha wave",		"#1" = "Alpha wave",	"№1" = "Alpha wave",	".1" = "Alpha wave",
	  ":2" = "Beta wave",		"#2" = "Beta wave",		"№2" = "Beta wave",		".2" = "Beta wave",
	  ":3" = "Gamma wave",		"#3" = "Gamma wave",	"№3" = "Gamma wave",	".3" = "Gamma wave",
	// Russian symbols no case
		// None yet.

	// Special symbols only (that means that they don't have/use an english/russian analogue)
 	  ":*" = "Spider Clan",		"#*" = "Spider Clan",	"№*" = "Spider Clan",	".*" = "Spider Clan",
	  ":$" = "Response Team",	"#$" = "Response Team", "№$" = "Response Team",	".$" = "Response Team",
  	  ":_" = "SyndTeam",		"#_" = "SyndTeam",		"№_" = "SyndTeam",		"._" = "SyndTeam",
	  ":-" = "Special Ops",		"#-" = "Special Ops",	"№-" = "Special Ops",	".-" = "Special Ops",
	  ":+" = "special",			"#+" = "special",		"№+" = "special",		".+" = "special" //activate radio-specific special functions
))


GLOBAL_LIST_EMPTY(channel_to_radio_key)


/proc/get_radio_key_from_channel(channel)
	var/key = GLOB.channel_to_radio_key[channel]
	if(!key)
		for(var/radio_key in GLOB.department_radio_keys)
			if(GLOB.department_radio_keys[radio_key] == channel)
				key = radio_key
				break
		if(!key)
			key = ""
		GLOB.channel_to_radio_key[channel] = key

	return key


/mob/living/proc/binarycheck()
	return FALSE


/mob/proc/get_default_language()
	return null


/mob/living/get_default_language()
	return default_language


/mob/living/proc/handle_speech_problems(list/message_pieces, verb)
	var/robot = ismachineperson(src)
	for(var/datum/multilingual_say_piece/S in message_pieces)
		if(S.speaking && S.speaking.flags & NO_STUTTER)
			continue

		if(HAS_TRAIT(src, TRAIT_HULK) && health >= 25)
			S.message = "[uppertext(S.message)]!!!"
			verb = pick("yells", "roars", "hollers")

		if(AmountSluring())
			if(robot)
				S.message = slur(S.message, list("@", "!", "#", "$", "%", "&", "?"))
			else
				S.message = slur(S.message)
			verb = "slurs"

		if(AmountStuttering())
			if(robot)
				S.message = robostutter(S.message)
			else
				S.message = stutter(S.message)
			verb = "stammers"

		if(AmountCultSlurring())
			S.message = cultslur(S.message)
			verb = "slurs"

		if(AmountClockSlurring())
			S.message = clockslur(S.message)
			verb = "slurs"

		if(!IsVocal())
			S.message = ""

	return list("verb" = verb)


/mob/living/proc/handle_message_mode(message_mode, list/message_pieces, verb, used_radios)
	switch(message_mode)
		if("whisper") //all mobs can whisper by default
			whisper_say(message_pieces)
			return TRUE
	return FALSE


/mob/living/proc/handle_speech_sound()
	var/list/returns[3]
	returns[1] = null
	returns[2] = null
	returns[3] = null
	return returns


/mob/living/say(message, verb = "говор[pluralize_ru(gender, "ит", "ят")]", sanitize = TRUE, ignore_speech_problems = FALSE, ignore_atmospherics = FALSE, ignore_languages = FALSE)
	if(client)
		client.check_say_flood(5)
		if(check_mute(client.ckey, MUTE_IC))
			to_chat(src, span_danger("You cannot speak in IC (Muted)."))
			return FALSE

	var/sigreturn = SEND_SIGNAL(src, COMSIG_MOB_TRY_SPEECH, message)
	if(sigreturn & COMPONENT_CANNOT_SPEAK)
		return FALSE

	if(sanitize)
		message = trim_strip_html_properly(message, 512)

	if(stat)
		if(stat == DEAD)
			return say_dead(message)
		return FALSE

	if(copytext(message, 1, 2) == "*")
		return emote(copytext(message, 2), intentional = TRUE)

	var/ending = copytext(message, length(message))
	if(!(ending in list("!", "?", ",", ".")) && length(message) != 0)
		message += "."

	//parse the language code and consume it
	var/list/message_pieces = list()
	if(ignore_languages)
		message_pieces = message_to_multilingual(message)
	else
		message_pieces = parse_languages(message)

	if(!LAZYLEN(message_pieces))
		. = FALSE
		CRASH("Message failed to generate pieces. [message] - [json_encode(message_pieces)]")

	var/datum/multilingual_say_piece/first_piece = message_pieces[1]

	if(SEND_SIGNAL( \
        src, \
        COMSIG_LIVING_EARLY_SAY, \
        message, \
        verb, \
        ignore_speech_problems, \
        ignore_atmospherics, \
        ignore_languages, \
        first_piece) & COMPONENT_PREVENT_SPEAKING)
		return FALSE

	if(first_piece.speaking?.flags & HIVEMIND)
		first_piece.speaking.broadcast(src, first_piece.message)
		return TRUE

	var/message_mode = parse_message_mode(first_piece.message, "headset")

	//parse the radio code and consume it
	if(message_mode)
		if(message_mode == "headset")
			first_piece.message = copytext_char(first_piece.message, 2)	//it would be really nice if the parse procs could do this for us.
		else
			first_piece.message = copytext_char(first_piece.message, 3)

	//And only after everything is done, we hissin'
	for(var/datum/multilingual_say_piece/piece as anything in message_pieces)
		piece.message = handle_autohiss(piece.message, piece.speaking)

	first_piece.message = trim_left(first_piece.message)
	verb = say_quote(message, first_piece.speaking)

	if(message_mode == "cords")
		if(iscarbon(src))
			var/mob/living/carbon/C = src
			var/obj/item/organ/internal/vocal_cords/V = C.get_int_organ(/obj/item/organ/internal/vocal_cords)
			if(!V || !V.can_speak_with())
				return TRUE

			V.speak_with(message)
			message_pieces = V.handle_speech(message_pieces)
			if(!LAZYLEN(message_pieces))
				return TRUE

			ignore_speech_problems = TRUE
			ignore_atmospherics = TRUE

	if(is_muzzled())
		var/obj/item/organ/internal/cyberimp/mouth/translator/translator = get_organ_slot(INTERNAL_ORGAN_SPEECH_TRANSLATOR)
		if(translator) // we can whisper with translator and muzzle
			whisper_say(message_pieces)
			return TRUE

		var/obj/item/clothing/mask/muzzle/G = wear_mask
		if(G.mute == MUZZLE_MUTE_ALL) //if the mask is supposed to mute you completely or just muffle you
			to_chat(src, span_danger("You're muzzled and cannot speak!"))
			return FALSE
		else if(G.mute == MUZZLE_MUTE_MUFFLE)
			muffledspeech_all(message_pieces)
			verb = "mumbles"

	if(is_facehugged())
		muffledspeech_all(message_pieces)
		verb = "gurgles"

	if(!wear_mask && pulledby && pulledby.grab_state > GRAB_PASSIVE && pulledby.zone_selected == BODY_ZONE_PRECISE_MOUTH)
		muffledspeech_all(message_pieces)
		verb = "mumbles"

	if(!ignore_speech_problems)
		var/list/hsp = handle_speech_problems(message_pieces, verb)
		verb = hsp["verb"]

	if(cannot_speak_loudly())
		return whisper(message)

	var/list/used_radios = list()
	if(handle_message_mode(message_mode, message_pieces, verb, used_radios))
		return TRUE

	// Log of what we've said, plain message, no spans or junk
	// handle_message_mode should have logged this already if it handled it
	add_say_logs(src, "'[message]'", null, message_mode)

	var/list/handle_v = handle_speech_sound()
	var/sound/speech_sound = handle_v[1]
	var/sound_vol = handle_v[2]
	var/sound_frequency = handle_v[3]

	var/italics = 0
	var/message_range = world.view

	//speaking into radios
	if(length(used_radios))
		italics = TRUE
		message_range = 1
		if(first_piece.speaking)
			message_range = first_piece.speaking.get_talkinto_msg_range(message)

		var/msg
		if((!first_piece.speaking || !(first_piece.speaking.flags & NO_TALK_MSG)) && client)
			msg = span_notice("[src] talks into [used_radios[1]]")
			var/static/list/special_radio_channels = list("Syndicate", "SyndTeam", "Security", "Procedure", "Command", "Response Team", "Special Ops", "Spider Clan", "SyndTaipan", "Soviet")
			if(message_mode in special_radio_channels)
				SEND_SOUND(src, sound('sound/items/radio_security.ogg', volume = rand(4, 16) * 5 * client.prefs.get_channel_volume(CHANNEL_RADIO_NOISE), channel = CHANNEL_RADIO_NOISE))
			else
				SEND_SOUND(src, sound('sound/items/radio_common.ogg', volume = rand(4, 16) * 5 * client.prefs.get_channel_volume(CHANNEL_RADIO_NOISE), channel = CHANNEL_RADIO_NOISE))

		if(msg)
			for(var/mob/living/M in hearers(5, src) - src)
				M.show_message(msg)

		if(speech_sound)
			sound_vol *= 0.5

	var/turf/T = get_turf(src)
	var/list/listening = list()
	var/list/listening_obj = list()

	if(T)
		//make sure the air can transmit speech - speaker's side
		var/datum/gas_mixture/environment = T.return_air()
		var/pressure = environment ? environment.return_pressure() : 0
		if(!ignore_atmospherics)
			if(pressure < SOUND_MINIMUM_PRESSURE)
				message_range = 1

			if(pressure < ONE_ATMOSPHERE * 0.4) //sound distortion pressure, to help clue people in that the air is thin, even if it isn't a vacuum yet
				italics = TRUE
				sound_vol *= 0.5 //muffle the sound a bit, so it's like we're actually talking through contact

		var/list/hear = hear(message_range, T)
		var/list/hearturfs = list()

		for(var/I in hear)
			if(ismob(I))
				var/mob/M = I
				listening += M
				hearturfs += get_turf(M)
				for(var/obj/O in M.contents)
					listening_obj |= O
			if(isobj(I))
				var/obj/O = I
				hearturfs += get_turf(O)
				listening_obj |= O

		for(var/mob/M in GLOB.player_list)
			if(!M.client)
				continue

			if(isnewplayer(M))
				continue

			if(isobserver(M))
				if(M.get_preference(PREFTOGGLE_CHAT_GHOSTEARS) && client) // The client check is so that ghosts don't have to listen to mice.
					listening |= M
					continue

				if(message_range < world.view && (get_dist(T, M) <= world.view))
					listening |= M
					continue

			if(get_turf(M) in hearturfs)
				listening |= M

	var/list/speech_bubble_recipients = list()
	var/speech_bubble_test = say_test(message)

	for(var/mob/M in listening)
		M.hear_say(message_pieces, verb, italics, src, speech_sound, sound_vol, sound_frequency, FALSE)
		if(M.client)
			speech_bubble_recipients.Add(M.client)

	if(loc && !isturf(loc))
		var/atom/A = loc //Non-turf, let it handle the speech bubble
		A.speech_bubble("[A.bubble_icon][speech_bubble_test]", A, speech_bubble_recipients)
	else //Turf, leave speech bubbles to the mob
		speech_bubble("[bubble_icon][speech_bubble_test]", src, speech_bubble_recipients)

	hear_message_obj(listening_obj, src, message_pieces, verb)

	return TRUE


/proc/hear_message_obj(list/listening_obj, mob/M, list/message_pieces, verbage)
	var/list/transmited_channels = list()
	for(var/obj/O in listening_obj)
		spawn(0)
			if(O) //It's possible that it could be deleted in the meantime.
				if(isradio(O))
					var/obj/item/radio/radio = O
					if(radio.broadcasting && get_dist(radio, M) <= radio.canhear_range && !(radio.frequency in transmited_channels))
						if(radio.talk_into(M, message_pieces, null, verbage))
							transmited_channels += radio.frequency
				else
					O.hear_talk(M, message_pieces, verbage)


/mob/living/whisper(message as text)
	message = trim_strip_html_properly(message, 512)

	if(!message)
		return

	var/ending = copytext(message, length(message))
	if(!(ending in list("!", "?", ",", ".")))
		message += "."

	//parse the language code and consume it
	var/list/message_pieces = parse_languages(message)
	if(istype(message_pieces, /datum/multilingual_say_piece)) // Little quirk to just easily deal with HIVEMIND languages
		var/datum/multilingual_say_piece/S = message_pieces // Yay BYOND's hilarious typecasting
		S.speaking.broadcast(src, S.message)
		return TRUE
	// Log it here since it skips the default way say handles it
	create_log(SAY_LOG, "(whisper) '[message]'")
	SSspeech_controller.queue_say_for_mob(src, message_pieces, SPEECH_CONTROLLER_QUEUE_WHISPER_VERB)


// for weird circumstances where you're inside an atom that is also you, like pai's
/mob/living/proc/get_whisper_loc()
	return src


/mob/living/whisper_say(list/message_pieces, verb = "шепч%(ет,ут)%")
	if(client && check_mute(client.ckey, MUTE_IC))
		to_chat(src, span_danger("You cannot speak in IC (Muted)."))
		return

	if(stat)
		return

	var/obj/item/organ/internal/cyberimp/mouth/translator/translator = get_organ_slot(INTERNAL_ORGAN_SPEECH_TRANSLATOR)
	if(is_muzzled() && !translator?.active)
		if(istype(wear_mask, /obj/item/clothing/mask/muzzle/tapegag)) //just for tape
			to_chat(src, span_danger("Your mouth is taped and you cannot speak!"))
		else
			to_chat(src, span_danger("You're muzzled and cannot speak!"))
		return

	if(is_facehugged())
		to_chat(src, span_danger("You can't get a word out with this horrible creature on your face!"))
		return

	var/message = multilingual_to_message(message_pieces)

	LAZYADD(say_log, "whisper: [message]")
	log_whisper(message, src)
	var/message_range = 1
	var/eavesdropping_range = 2
	var/watching_range = 5
	var/italics = 1
	var/adverb_added = FALSE
	var/not_heard //the message displayed to people who could not hear the whispering

	var/datum/multilingual_say_piece/first_piece = message_pieces[1]
	if(first_piece.speaking)
		if(first_piece.speaking.whisper_verbs)
			verb = pick(first_piece.speaking.whisper_verbs)
			not_heard = "[verb] что-то"
		else
			var/adverb = pick("еле слышно", "едва слышно", "тихо", "очень тихо", "негромко")
			adverb_added = TRUE
			verb = "[adverb] [genderize_decode(src, pick(first_piece.speaking.speech_verbs))]"
			not_heard = "[adverb] [genderize_decode(src, pick(first_piece.speaking.speech_verbs))] что-то"
	else
		not_heard = "[genderize_decode(src, verb)] что-то"

	var/list/hsp = handle_speech_problems(message_pieces, verb)
	verb = hsp["verb"]
	if(verb == "громко крич%(ит,ат)%")
		verb = "громко бормоч%(ет,ут)%"
	else if(!adverb_added)
		var/adverb = pick("еле слышно", "едва слышно", "тихо", "очень тихо", "негромко")
		verb = "[adverb] [genderize_decode(src, verb)]"

	var/atom/whisper_loc = get_whisper_loc()
	var/list/listening = hear(message_range, whisper_loc)
	listening |= src

	var/list/hearturfs = list()

	// Pass whispers on to anything inside the immediate listeners.
	// This comes before the ghosts do so that ghosts don't act as whisper relays
	for(var/atom/L in listening)
		if(ismob(L))
			for(var/mob/C in L.contents)
				if(isliving(C))
					listening += C
			hearturfs += get_turf(L)
		if(isobj(L))
			hearturfs += get_turf(L)

	// Loop through all players to see if they need to hear it.
	for(var/mob/M in GLOB.player_list)
		if(!M.client)
			continue

		if(isnewplayer(M))
			continue

		if(isobserver(M))
			if(M.get_preference(PREFTOGGLE_CHAT_GHOSTEARS)) // The client check is so that ghosts don't have to listen to mice.
				listening |= M
				continue

			if(message_range < world.view && (get_dist(whisper_loc, M) <= world.view))
				listening |= M
				continue

		if(get_turf(M) in hearturfs)
			listening |= M

	//pass on the message to objects that can hear us.
	hear_message_obj(view(message_range, whisper_loc), src, message_pieces, verb)

	var/list/eavesdropping = hearers(eavesdropping_range, whisper_loc)
	eavesdropping -= src
	eavesdropping -= listening

	var/list/watching = hearers(watching_range, whisper_loc)
	watching  -= src
	watching  -= listening
	watching  -= eavesdropping

	//now mobs
	var/list/speech_bubble_recipients = list()
	var/speech_bubble_test = say_test(message)

	for(var/mob/M in listening)
		M.hear_say(message_pieces, verb, italics, src, use_voice = FALSE, is_whisper = TRUE)
		if(M.client)
			speech_bubble_recipients.Add(M.client)

	if(eavesdropping.len)
		stars_all(message_pieces)	//hopefully passing the message twice through stars() won't hurt... I guess if you already don't understand the language, when they speak it too quietly to hear normally you would be able to catch even less.
		for(var/mob/M in eavesdropping)
			M.hear_say(message_pieces, verb, italics, src, use_voice = FALSE, is_whisper = TRUE)
			if(M.client)
				speech_bubble_recipients.Add(M.client)

	speech_bubble("[bubble_icon][speech_bubble_test]", src, speech_bubble_recipients)

	if(length(watching))
		var/rendered = "<span class='game say'><span class='name'>[name]</span> [not_heard].</span>"
		for(var/mob/M in watching)
			M.show_message(rendered, 2)

	return TRUE


/mob/living/speech_bubble(bubble_state = "", bubble_loc = src, list/bubble_recipients = list())
	var/image/I = image('icons/mob/talk.dmi', bubble_loc, bubble_state, FLY_LAYER)
	SET_PLANE_EXPLICIT(I, ABOVE_GAME_PLANE, src)
	I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	INVOKE_ASYNC(GLOBAL_PROC, /proc/flick_overlay, I, bubble_recipients, 30)

