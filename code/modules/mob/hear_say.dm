#define EMPHASIS_LETTERS_REGEX "\[^\\+\\|_%]"
// At minimum every mob has a hear_say proc.

/mob/proc/combine_message(list/message_pieces, mob/speaker, always_stars = FALSE)
	var/iteration_count = 0
	var/msg = ""
	for(var/datum/multilingual_say_piece/SP in message_pieces)
		iteration_count++
		var/piece = SP.message
		if(piece == "")
			continue

		if(SP.speaking && SP.speaking.flags & INNATE) // If message contains noise lang parts other parts will be skipped
			return SP.speaking.format_message(piece, speaker)

		if(iteration_count == 1)
			var/static/regex/my_regex = regex(EMPHASIS_LETTERS_REGEX)
			var/capital_letter = my_regex.Find(piece)
			if(capital_letter)
				piece = my_regex.Replace_char(piece, uppertext(piece[capital_letter]), 1, capital_letter+1)

		if(always_stars)
			piece = stars(piece)
		else if(!say_understands(speaker, SP.speaking))
			if(isanimal(speaker))
				var/mob/living/simple_animal/S = speaker
				if(LAZYLEN(S.speak))
					piece = pick(S.speak)
				else
					piece = stars(piece)
			else if(SP.speaking)
				piece = SP.speaking.scramble(piece)
			else
				piece = stars(piece)
		if(SP.speaking)
			piece = SP.speaking.format_message(piece, speaker)
		else
			piece = "<span class='message'><span class='body'>[piece]</span></span>"
		msg += (piece + " ")

	if(msg == "")
		. = ""
		return

	if(isliving(src))
		for(var/datum/component/codeword_hearing/hearing_datum in GetComponents(/datum/component/codeword_hearing))
			var/tmp_msg = hearing_datum.handle_hearing(msg)
			if(!tmp_msg)
				continue
			msg = tmp_msg
			//log_debug(msg)

	return trim(msg)

#undef EMPHASIS_LETTERS_REGEX

/mob/proc/combine_message_tts(list/message_pieces, mob/speaker, always_stars = FALSE)
	var/iteration_count = 0
	var/msg = ""
	for(var/datum/multilingual_say_piece/SP in message_pieces)
		iteration_count++
		var/piece = SP.message
		if(piece == "")
			continue

		if(SP.speaking == GLOB.all_languages[LANGUAGE_NOISE]) // TTS should not read emotes like "laughts"
			return ""

		if(iteration_count == 1)
			piece = capitalize(piece)

		if(always_stars)
			continue
		if(!say_understands(speaker, SP.speaking))
			if(isanimal(speaker))
				var/mob/living/simple_animal/S = speaker
				if(LAZYLEN(S.speak))
					piece = pick(S.speak)
				else
					continue
			else if(SP.speaking)
				piece = SP.speaking.scramble(piece)
			else
				continue
		msg += (piece + " ")
	return trim(msg)

/mob/proc/verb_message(list/message_pieces, message, verb)
	if(!verb)
		return message
	if(message == "")
		return ""
	for(var/datum/multilingual_say_piece/SP in message_pieces)
		if(SP.speaking == GLOB.all_languages[LANGUAGE_NOISE]) // Message contains only emoutes, no need to add verb
			return message
	return "[verb]: \"[message]\""

/mob/proc/hear_say(list/message_pieces, verb = "говор%(ит,ят)%", italics = FALSE, mob/speaker = null, sound/speech_sound, sound_vol, sound_frequency, use_voice = TRUE, is_whisper = FALSE)
	if(!client)
		return 0



	if(isobserver(src) && client.prefs.toggles & PREFTOGGLE_CHAT_GHOSTEARS)
		if(speaker && !speaker.client && !(speaker in view(src)))
			//Does the speaker have a client?  It's either random stuff that observers won't care about (Experiment 97B says, 'EHEHEHEHEHEHEHE')
			//Or someone snoring.  So we make it where they won't hear it.
			return 0

	//make sure the air can transmit speech - hearer's side
	var/turf/T = get_turf(src)
	if(T && !isobserver(src))
		var/datum/gas_mixture/environment = T.return_air()
		var/pressure = environment ? environment.return_pressure() : 0
		if(pressure < SOUND_MINIMUM_PRESSURE && get_dist(speaker, src) > 1)
			return FALSE

		if(pressure < ONE_ATMOSPHERE * 0.4) //sound distortion pressure, to help clue people in that the air is thin, even if it isn't a vacuum yet
			italics = TRUE
			sound_vol *= 0.5

	if(stat == UNCONSCIOUS)
		hear_sleep(multilingual_to_message(message_pieces))
		return 0

	var/speaker_name = speaker.name
	if(use_voice && ishuman(speaker))
		var/mob/living/carbon/human/H = speaker
		speaker_name = H.GetVoice()

	var/message_clean = say_emphasis(combine_message(message_pieces, speaker))
	message_clean = replace_characters(message_clean, list("+"))
	if(message_clean == "")
		return

	var/message_tts = combine_message_tts(message_pieces, speaker)
	var/message = message_clean

	if(italics)
		message = "<i>[message]</i>"

	var/track = null
	if(isobserver(src))
		if(speaker_name != speaker.real_name && speaker.real_name)
			speaker_name = "[speaker.real_name] ([speaker_name])"
		track = "([ghost_follow_link(speaker, ghost=src)]) "
		if(client.prefs.toggles & PREFTOGGLE_CHAT_GHOSTEARS && (speaker in view(src)))
			message = "<b>[message]</b>"

	speaker_name = colorize_name(speaker, speaker_name)
	// Ensure only the speaker is forced to emote, and that the spoken language is inname
	for(var/datum/multilingual_say_piece/SP in message_pieces)
		if(SP.speaking == GLOB.all_languages[LANGUAGE_NOISE])
			if(speaker == src)
				custom_emote(EMOTE_AUDIBLE, message_clean, TRUE)
			return

	if(!can_hear())
		// INNATE is the flag for audible-emote-language, so we don't want to show an "x talks but you cannot hear them" message if it's set
		// if(!language || !(language.flags & INNATE))
		if(speaker == src)
			to_chat(src, span_warning("Вы не слышите собственной речи!"))
		else
			to_chat(src, "[span_name(speaker.name)] что-то говор[pluralize_ru(speaker.gender, "ит", "ят")], но вы ничего не слышите!")
	else
		to_chat(src, span_gamesay("[span_name(speaker_name)][speaker.GetAltName()] [track][verb_message(message_pieces, message, genderize_decode(speaker, verb))]"))

		// Create map text message
		if(client?.prefs.toggles2 & PREFTOGGLE_2_RUNECHAT) // can_hear is checked up there on L99
			create_chat_message(speaker, message_clean, italics ? list("italics") : null, get_runechat_language(message_pieces))

		var/effect = SOUND_EFFECT_NONE
		if(isrobot(speaker))
			effect = SOUND_EFFECT_ROBOT
		var/traits = TTS_TRAIT_RATE_FASTER
		if(is_whisper)
			traits |= TTS_TRAIT_PITCH_WHISPER
		INVOKE_ASYNC(GLOBAL_PROC, /proc/tts_cast, speaker, src, message_tts, speaker.tts_seed, TRUE, effect, traits)

		if(speech_sound && (get_dist(speaker, src) <= world.view && src.z == speaker.z))
			var/turf/source = speaker? get_turf(speaker) : get_turf(src)
			playsound_local(source, speech_sound, sound_vol, 1, sound_frequency)

/mob/proc/colorize_name(mob/speaker = null, speaker_name)
	if(!speaker.ckey)
		return speaker_name

	if (!speaker.chat_color || speaker.chat_color_name != speaker.name)

		var/step = round(length_char(speaker_name)/3)
		var/rgb[3]
		for(var/i = 1 to 3)
			rgb[i] = text2ascii_char(speaker_name, step*i)
			if(rgb[i] > 1071) rgb[i] -= 1072
			if(rgb[i] > 1039) rgb[i] -= 1040
			if(rgb[i] > 96) rgb[i] -= 97
			if(rgb[i] > 64) rgb[i] -= 65
			if(rgb[i] > 31) rgb[i] -= 32
			rgb[i] = rgb[i]*4 + 63 // base brightness

		speaker.chat_color = rgb(rgb[1],rgb[2],rgb[3])
		speaker.chat_color_darkened = rgb(rgb[1]-23,rgb[2]-23,rgb[3]-23)
		speaker.chat_color_name = speaker_name

		return "<font color=[rgb(rgb[1],rgb[2],rgb[3])]>[speaker_name]</font>"
	else
		return "<font color=[speaker.chat_color]>[speaker_name]</font>"

/mob/proc/hear_radio(list/message_pieces, verb = "говор%(ит,ят)%", part_a, part_b, mob/speaker = null, hard_to_hear = 0, vname = "", atom/follow_target)
	if(!client)
		return

	if(stat == UNCONSCIOUS) //If unconscious or sleeping
		hear_sleep(multilingual_to_message(message_pieces))
		return

	var/message_clean = combine_message(message_pieces, speaker, always_stars = hard_to_hear)
	message_clean = replace_characters(message_clean, list("+"))

	if(message_clean == "")
		return

	var/message = verb_message(message_pieces, message_clean, genderize_decode(speaker, genderize_decode(speaker, verb)))
	var/message_tts = combine_message_tts(message_pieces, speaker, always_stars = hard_to_hear)

	var/track = null
	if(!follow_target)
		follow_target = speaker

	var/speaker_name = handle_speaker_name(speaker, vname, hard_to_hear)
	speaker_name = colorize_name(speaker, speaker_name)
	track = handle_track(message, genderize_decode(speaker, verb), speaker, speaker_name, follow_target, hard_to_hear)

	if(!can_hear())
		if(prob(20))
			to_chat(src, span_warning("Ваша гарнитура вибрирует, но вы не слышите ни звука!"))
	else
		to_chat(src, "[part_a][track || speaker_name][part_b][message]</span></span>")
		if(client?.prefs.toggles2 & PREFTOGGLE_2_RUNECHAT)
			create_chat_message(speaker, message_clean, list("radio"))
		if(src != speaker || isrobot(src) || isAI(src))
			var/effect = SOUND_EFFECT_RADIO
			if(isrobot(speaker))
				effect = SOUND_EFFECT_RADIO_ROBOT
			INVOKE_ASYNC(GLOBAL_PROC, /proc/tts_cast, src, src, message_tts, speaker.tts_seed, FALSE, effect, null, null, 'sound/effects/radio_chatter.ogg')

/mob/proc/handle_speaker_name(mob/speaker = null, vname, hard_to_hear)
	var/speaker_name = "неизвестный"
	if(speaker)
		speaker_name = speaker.name

	if(vname)
		speaker_name = vname

	if(hard_to_hear)
		speaker_name = "неизвестный"

	return speaker_name

/mob/proc/handle_track(message, verb = "говор%(ит,ят)%", mob/speaker = null, speaker_name, atom/follow_target, hard_to_hear)
	return

/mob/proc/hear_sleep(message)
	var/heard = ""
	if(prob(15))
		message = strip_html_properly(message)
		var/list/punctuation = list(",", "!", ".", ";", "?")
		var/list/messages = splittext(message, " ")
		if(messages.len > 0)
			var/R = rand(1, messages.len)
			var/heardword = messages[R]
			if(copytext(heardword,1, 1) in punctuation)
				heardword = copytext(heardword,2)
			if(copytext(heardword,-1) in punctuation)
				heardword = copytext(heardword,1,length(heardword))
			heard = span_gamesay("...<i>Вы слышите что-то про<i>... \"[heardword]\"...")
		else
			heard = span_gamesay("...<i>Вы почти что смогли расслышать что-то</i>...")
	else
		heard = span_gamesay("...<i>Вы едва слышите, как кто-то говорит</i>...")

	to_chat(src, heard)

/mob/proc/hear_holopad_talk(list/message_pieces, verb = "говор%(ит,ят)%", mob/speaker = null, obj/effect/overlay/holo_pad_hologram/H)
	if(stat == UNCONSCIOUS)
		hear_sleep(multilingual_to_message(message_pieces))
		return

	if(!can_hear())
		return

	var/message_clean = combine_message(message_pieces, speaker)
	message_clean = replace_characters(message_clean, list("+"))

	if(message_clean == "")
		return

	var/message = verb_message(message_pieces, message_clean, genderize_decode(speaker, verb))
	var/message_tts = combine_message_tts(message_pieces, speaker)

	var/name = speaker.name
	if(!say_understands(speaker))
		name = speaker.voice_name

	if((client?.prefs.toggles2 & PREFTOGGLE_2_RUNECHAT) && can_hear())
		create_chat_message(H, message_clean, list("radio"))

	var/effect = SOUND_EFFECT_RADIO
	if(isrobot(speaker))
		effect = SOUND_EFFECT_RADIO_ROBOT
	INVOKE_ASYNC(GLOBAL_PROC, /proc/tts_cast, H, src, message_tts, speaker.tts_seed, TRUE, effect)

	var/rendered = span_gamesay("[span_name(name)] + [message]")
	to_chat(src, rendered)


/// Gets language for runechat message.
/// Will return first found language if more than one is present, cause I have no time to remake this for now.
/proc/get_runechat_language(list/message_pieces)
	for(var/datum/multilingual_say_piece/piece as anything in message_pieces)
		if(!piece.message)
			continue
		if(piece.speaking?.runechat_span)
			return piece.speaking
