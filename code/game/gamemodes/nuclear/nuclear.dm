/datum/game_mode
	var/list/datum/mind/syndicates = list()

/datum/game_mode/nuclear
	name = "nuclear emergency"
	config_tag = "nuclear"
	required_players = 30	// 30 players - 5 players to be the nuke ops = 25 players remaining
	required_enemies = NUKERS_COUNT
	recommended_enemies = NUKERS_COUNT

	var/const/agents_possible = NUKERS_COUNT //If we ever need more syndicate agents.

	var/nukes_left = 1 //Call 3714-PRAY right now and order more nukes! Limited offer!
	var/nuke_off_station = 0 //Used for tracking if the syndies actually haul the nuke to the station
	var/syndies_didnt_escape = 0 //Used for tracking if the syndies got the shuttle off of the z-level
	var/total_tc = 0 //Total amount of telecrystals shared between nuke ops

/datum/game_mode/nuclear/announce()
	to_chat(world, "<b>The current game mode is - Nuclear Emergency!</b>")
	to_chat(world, "<b>A [syndicate_name()] Strike Force is approaching [station_name()]!</b>")
	to_chat(world, "A nuclear explosive was being transported by Nanotrasen to a military base. The transport ship mysteriously lost contact with Space Traffic Control (STC). About that time a strange disk was discovered around [station_name()]. It was identified by Nanotrasen as a nuclear authentication disk and now Syndicate Operatives have arrived to retake the disk and detonate SS13! There are most likely Syndicate starships are in the vicinity, so take care not to lose the disk!\n<b>Syndicate</b>: Reclaim the disk and detonate the nuclear bomb anywhere on SS13.\n<b>Personnel</b>: Hold the disk and <b>escape with the disk</b> on the shuttle!")

/datum/game_mode/nuclear/can_start()
	if(!..())
		return FALSE
	var/list/possible_syndicates = get_players_for_role(ROLE_OPERATIVE)
	var/agent_number = 0

	if(!length(possible_syndicates))
		return FALSE

	if(possible_syndicates.len > agents_possible)
		agent_number = agents_possible
	else
		agent_number = possible_syndicates.len

	var/n_players = num_players()
	if(agent_number > n_players)
		agent_number = n_players / 2

	while(agent_number > 0)
		var/datum/mind/new_syndicate = pick_n_take(possible_syndicates)
		syndicates += new_syndicate
		agent_number--

	return TRUE

/datum/game_mode/nuclear/pre_setup()
	for(var/datum/mind/synd_mind in syndicates)
		synd_mind.assigned_role = SPECIAL_ROLE_NUKEOPS //So they aren't chosen for other jobs.
		synd_mind.special_role = SPECIAL_ROLE_NUKEOPS
	return TRUE

/datum/game_mode/proc/remove_operative(datum/mind/operative_mind)
	if(operative_mind in syndicates)
		SSticker.mode.syndicates -= operative_mind
		operative_mind.special_role = null
		for(var/datum/objective/nuclear/O in operative_mind.objectives)
			operative_mind.objectives -= O
		add_conversion_logs(operative_mind.current, "No longer nuclear operative")
		if(issilicon(operative_mind.current))
			to_chat(operative_mind.current, "<span class='userdanger'>You have been turned into a robot! You are no longer a Syndicate operative.</span>")
		else
			to_chat(operative_mind.current, "<span class='userdanger'>You have been brainwashed! You are no longer a Syndicate operative.</span>")
		SSticker.mode.update_synd_icons_removed(operative_mind)

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/datum/game_mode/proc/update_synd_icons_added(datum/mind/synd_mind)
	var/datum/atom_hud/antag/opshud = GLOB.huds[ANTAG_HUD_OPS]
	opshud.join_hud(synd_mind.current)
	set_antag_hud(synd_mind.current, "hudoperative")

/datum/game_mode/proc/update_synd_icons_removed(datum/mind/synd_mind)
	var/datum/atom_hud/antag/opshud = GLOB.huds[ANTAG_HUD_OPS]
	opshud.leave_hud(synd_mind.current)
	set_antag_hud(synd_mind.current, null)

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/datum/game_mode/nuclear/post_setup()
	var/obj/effect/landmark/nuke_spawn = locate("landmark*Nuclear-Bomb")

	var/nuke_code = rand(10000, 99999)
	var/leader_selected = 0
	var/agent_number = 1
	var/spawnpos = 1

	for(var/datum/mind/synd_mind in syndicates)
		if(spawnpos > GLOB.nukespawn.len)
			spawnpos = 2
		synd_mind.current.loc = GLOB.nukespawn[spawnpos]
		synd_mind.offstation_role = TRUE
		forge_syndicate_objectives(synd_mind)
		create_syndicate(synd_mind)
		greet_syndicate(synd_mind)
		equip_syndicate(synd_mind.current)

		if(!leader_selected)
			prepare_syndicate_leader(synd_mind, nuke_code)
			leader_selected = 1
		else
			synd_mind.current.real_name = "[syndicate_name()] Operative #[agent_number]"
			update_syndicate_id(synd_mind, FALSE)

			agent_number++
		spawnpos++
		update_synd_icons_added(synd_mind)

	scale_telecrystals()
	share_telecrystals()
	if(nuke_spawn && GLOB.nukespawn.len > 0)
		var/obj/machinery/nuclearbomb/syndicate/the_bomb = new /obj/machinery/nuclearbomb/syndicate(nuke_spawn.loc)
		the_bomb.r_code = nuke_code

	return ..()

/datum/game_mode/nuclear/proc/scale_telecrystals()
	var/danger = GLOB.player_list.len
	var/temp_danger = (danger + 9)
	danger = temp_danger - temp_danger % 10
	total_tc += danger * NUKESCALINGMODIFIER

/datum/game_mode/nuclear/proc/share_telecrystals()
	var/player_tc
	var/remainder

	player_tc = round(total_tc / GLOB.nuclear_uplink_list.len) //round to get an integer and not floating point
	remainder = total_tc % GLOB.nuclear_uplink_list.len

	for(var/obj/item/radio/uplink/nuclear/U in GLOB.nuclear_uplink_list)
		U.hidden_uplink.uses += player_tc
	while(remainder > 0)
		for(var/obj/item/radio/uplink/nuclear/U in GLOB.nuclear_uplink_list)
			if(remainder <= 0)
				break
			U.hidden_uplink.uses++
			remainder--

/datum/game_mode/proc/create_syndicate(datum/mind/synd_mind) // So we don't have inferior species as ops - randomize a human
	var/mob/living/carbon/human/M = synd_mind.current

	M.set_species(/datum/species/human, TRUE)
	M.dna.ready_dna(M) // Quadriplegic Nuke Ops won't be participating in the paralympics
	M.dna.species.create_organs(M)
	M.cleanSE() //No fat/blind/colourblind/epileptic/whatever ops.
	M.overeatduration = 0
	M.flavor_text = null

	var/obj/item/organ/external/head/head_organ = M.get_organ(BODY_ZONE_HEAD)
	var/hair_c = pick("#8B4513","#000000","#FF4500","#FFD700") // Brown, black, red, blonde
	var/eye_c = pick("#000000","#8B4513","1E90FF") // Black, brown, blue
	var/skin_tone = pick(-50, -30, -10, 0, 0, 0, 10) // Caucasian/black
	head_organ.facial_colour = hair_c
	head_organ.sec_facial_colour = hair_c
	head_organ.hair_colour = hair_c
	head_organ.sec_hair_colour = hair_c
	M.change_eye_color(eye_c)
	M.s_tone = skin_tone
	head_organ.h_style = random_hair_style(M.gender, head_organ.dna.species)
	head_organ.f_style = random_facial_hair_style(M.gender, head_organ.dna.species.name)
	M.body_accessory = null
	M.regenerate_icons()
	M.update_body()

/datum/game_mode/proc/prepare_syndicate_leader(var/datum/mind/synd_mind, var/nuke_code)
	var/leader_title = pick("Czar", "Boss", "Commander", "Chief", "Kingpin", "Director", "Overlord")
	synd_mind.current.real_name = "[syndicate_name()] Team [leader_title]"
	to_chat(synd_mind.current, "<b>You are the Syndicate leader for this mission. You are responsible for the distribution of telecrystals and your ID is the only one who can open the launch bay doors.</b>")
	to_chat(synd_mind.current, "<b>If you feel you are not up to this task, give your ID to another operative.</b>")
	to_chat(synd_mind.current, "<b>In your hand you will find a special item capable of triggering a greater challenge for your team. Examine it carefully and consult with your fellow operatives before activating it.</b>")

	var/obj/item/nuclear_challenge/challenge = new /obj/item/nuclear_challenge
	synd_mind.current.equip_to_slot_or_del(challenge, ITEM_SLOT_HAND_RIGHT)

	update_syndicate_id(synd_mind, leader_title, TRUE)

	if(nuke_code)
		synd_mind.store_memory("<b>Syndicate Nuclear Bomb Code</b>: [nuke_code]", 0, 0)
		to_chat(synd_mind.current, "The nuclear authorization code is: <b>[nuke_code]</b>")
		var/obj/item/paper/P = new
		P.info = "The nuclear authorization code is: <b>[nuke_code]</b>"
		P.name = "nuclear bomb code"
		P.stamp(/obj/item/stamp/syndicate)

		if(SSticker.mode.config_tag=="nuclear")
			P.forceMove(synd_mind.current.loc)
		else
			var/mob/living/carbon/human/H = synd_mind.current
			P.forceMove(H.loc)
			H.equip_to_slot_or_del(P, ITEM_SLOT_POCKET_RIGHT, 0)
			H.update_icons()

	else
		nuke_code = "code will be provided later"

/datum/game_mode/proc/update_syndicate_id(var/datum/mind/synd_mind, is_leader = FALSE)
	var/list/found_ids = synd_mind.current.search_contents_for(/obj/item/card/id)

	if(LAZYLEN(found_ids))
		for(var/obj/item/card/id/ID in found_ids)
			ID.name = "[synd_mind.current.real_name] ID card"
			ID.registered_name = synd_mind.current.real_name
			if(is_leader)
				ID.access += ACCESS_SYNDICATE_LEADER
	else
		message_admins("Warning: Operative [key_name_admin(synd_mind.current)] spawned without an ID card!")

/datum/game_mode/proc/forge_syndicate_objectives(var/datum/mind/syndicate)
	var/datum/objective/nuclear/syndobj = new
	syndobj.owner = syndicate
	syndicate.objectives += syndobj


/datum/game_mode/proc/greet_syndicate(var/datum/mind/syndicate, var/you_are=1)
	SEND_SOUND(syndicate.current, 'sound/ambience/antag/ops.ogg')
	var/list/messages = list()
	if(you_are)
		messages.Add("<span class='notice'>You are a [syndicate_name()] agent!</span>")
	messages.Add(syndicate.prepare_announce_objectives(FALSE))
	messages.Add("<span class='motd'>С полной информацией вы можете ознакомиться на вики: <a href=\"[CONFIG_GET(string/wikiurl)]/index.php/Nuclear_Agent\">Ядерный Оперативник</a></span>")
	to_chat(syndicate.current, chat_box_red(messages.Join("<br>")))
	return


/datum/game_mode/proc/random_radio_frequency()
	return 1337 // WHY??? -- Doohl


/datum/game_mode/proc/equip_syndicate(mob/living/carbon/human/synd_mob, uplink_uses = 100)
	var/radio_freq = SYND_FREQ

	var/obj/item/radio/R = new /obj/item/radio/headset/syndicate/alt(synd_mob)
	R.set_frequency(radio_freq)
	synd_mob.equip_to_slot_or_del(R, ITEM_SLOT_EAR_LEFT)

	synd_mob.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(synd_mob), ITEM_SLOT_CLOTH_INNER)
	synd_mob.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(synd_mob), ITEM_SLOT_FEET)
	synd_mob.equip_or_collect(new /obj/item/clothing/gloves/combat/swat/syndicate(synd_mob), ITEM_SLOT_GLOVES)
	synd_mob.equip_to_slot_or_del(new /obj/item/card/id/syndicate(synd_mob), ITEM_SLOT_ID)
	synd_mob.equip_to_slot_or_del(new /obj/item/storage/backpack(synd_mob), ITEM_SLOT_BACK)
	synd_mob.equip_to_slot_or_del(new /obj/item/gun/projectile/automatic/pistol(synd_mob), ITEM_SLOT_BELT)
	synd_mob.equip_to_slot_or_del(new /obj/item/storage/box/survival_syndi(synd_mob.back), ITEM_SLOT_BACKPACK)
	synd_mob.equip_to_slot_or_del(new /obj/item/pinpointer/nukeop(synd_mob), ITEM_SLOT_PDA)
	var/obj/item/radio/uplink/nuclear/U = new /obj/item/radio/uplink/nuclear(synd_mob)
	U.hidden_uplink.uplink_owner="[synd_mob.key]"
	U.hidden_uplink.uses = uplink_uses
	synd_mob.equip_to_slot_or_del(U, ITEM_SLOT_BACKPACK)

	if(synd_mob.dna.species)

		/*
		Incase anyone ever gets the burning desire to have nukeops with randomized apperances. -- Dave
		synd_mob.gender = pick(MALE, FEMALE) // Randomized appearances for the nukeops.
		var/datum/preferences/pref = new()
		A.randomize_appearance_for(synd_mob)
		*/

		var/race = synd_mob.dna.species.name

		switch(race)
			if(SPECIES_VOX, SPECIES_VOX_ARMALIS)
				synd_mob.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/syndicate(synd_mob), ITEM_SLOT_MASK)
				synd_mob.equip_to_slot_or_del(new /obj/item/tank/internals/emergency_oxygen/double/vox(synd_mob), ITEM_SLOT_HAND_LEFT)
				synd_mob.internal = synd_mob.l_hand
				synd_mob.update_action_buttons_icon()

			if(SPECIES_PLASMAMAN)
				synd_mob.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/syndicate(synd_mob), ITEM_SLOT_MASK)
				synd_mob.equip_or_collect(new /obj/item/tank/internals/plasmaman(synd_mob), ITEM_SLOT_SUITSTORE)
				synd_mob.equip_or_collect(new /obj/item/extinguisher_refill(synd_mob), ITEM_SLOT_BACKPACK)
				synd_mob.equip_or_collect(new /obj/item/extinguisher_refill(synd_mob), ITEM_SLOT_BACKPACK)
				synd_mob.internal = synd_mob.get_item_by_slot(ITEM_SLOT_SUITSTORE)
				synd_mob.update_action_buttons_icon()

	synd_mob.rejuvenate() //fix any damage taken by naked vox/plasmamen/etc while round setups
	var/obj/item/implant/explosive/E = new/obj/item/implant/explosive(synd_mob)
	E.implant(synd_mob)
	synd_mob.faction |= "syndicate"
	synd_mob.update_icons()
	return 1

/datum/game_mode/nuclear/check_win()
	if(nukes_left == 0)
		return 1
	return ..()


/datum/game_mode/proc/is_operatives_are_dead()
	for(var/datum/mind/operative_mind in syndicates)
		if(!ishuman(operative_mind.current))
			if(operative_mind.current)
				if(operative_mind.current.stat!=2)
					return 0
	return 1


/datum/game_mode/nuclear/declare_completion()
	var/disk_rescued = 1
	for(var/obj/item/disk/nuclear/D in GLOB.poi_list)
		if(!D.onCentcom())
			disk_rescued = 0
			break
	var/crew_evacuated = EMERGENCY_ESCAPED_OR_ENDGAMED
	//var/operatives_are_dead = is_operatives_are_dead()


	//nukes_left
	//station_was_nuked
	//derp //Used for tracking if the syndies actually haul the nuke to the station	//no
	//herp //Used for tracking if the syndies got the shuttle off of the z-level	//NO, DON'T FUCKING NAME VARS LIKE THIS

	if(!disk_rescued && station_was_nuked && !syndies_didnt_escape)
		SSticker.mode_result = "nuclear win - syndicate nuke"
		to_chat(world, "<span style='font-size: 3;'><b>Syndicate Major Victory!</b></span>")
		to_chat(world, "<b>[syndicate_name()] operatives have destroyed [station_name()]!</b>")

	else if(!disk_rescued && station_was_nuked && syndies_didnt_escape)
		SSticker.mode_result = "nuclear halfwin - syndicate nuke - did not evacuate in time"
		to_chat(world, "<span style='font-size: 3;'><b>Total Annihilation</b></span>")
		to_chat(world, "<b>[syndicate_name()] operatives destroyed [station_name()] but did not leave the area in time and got caught in the explosion.</b> Next time, don't lose the disk!")

	else if(!disk_rescued && !station_was_nuked && nuke_off_station && !syndies_didnt_escape)
		SSticker.mode_result = "nuclear halfwin - blew wrong station"
		to_chat(world, "<span style='font-size: 3;'><b>Crew Minor Victory</b></span>")
		to_chat(world, "<b>[syndicate_name()] operatives secured the authentication disk but blew up something that wasn't [station_name()].</b> Next time, don't lose the disk!")

	else if(!disk_rescued && !station_was_nuked && nuke_off_station && syndies_didnt_escape)
		SSticker.mode_result = "nuclear halfwin - blew wrong station - did not evacuate in time"
		to_chat(world, "<span style='font-size: 3;'><b>[syndicate_name()] operatives have earned Darwin Award!</b></span>")
		to_chat(world, "<b>[syndicate_name()] operatives blew up something that wasn't [station_name()] and got caught in the explosion.</b> Next time, don't lose the disk!")

	else if(disk_rescued && is_operatives_are_dead())
		SSticker.mode_result = "nuclear loss - evacuation - disk secured - syndi team dead"
		to_chat(world, "<span style='font-size: 3;'><b>Crew Major Victory!</b></span>")
		to_chat(world, "<b>The Research Staff has saved the disc and killed the [syndicate_name()] Operatives</b>")

	else if(disk_rescued)
		SSticker.mode_result = "nuclear loss - evacuation - disk secured"
		to_chat(world, "<span style='font-size: 3;'><b>Crew Major Victory</b></span>")
		to_chat(world, "<b>The Research Staff has saved the disc and stopped the [syndicate_name()] Operatives!</b>")

	else if(!disk_rescued && is_operatives_are_dead())
		SSticker.mode_result = "nuclear loss - evacuation - disk not secured"
		to_chat(world, "<span style='font-size: 3;'><b>Syndicate Minor Victory!</b></span>")
		to_chat(world, "<b>The Research Staff failed to secure the authentication disk but did manage to kill most of the [syndicate_name()] Operatives!</b>")

	else if(!disk_rescued && crew_evacuated)
		SSticker.mode_result = "nuclear halfwin - detonation averted"
		to_chat(world, "<span style='font-size: 3;'><b>Syndicate Minor Victory!</b></span>")
		to_chat(world, "<b>[syndicate_name()] operatives recovered the abandoned authentication disk but detonation of [station_name()] was averted.</b> Next time, don't lose the disk!")

	else if(!disk_rescued && !crew_evacuated)
		SSticker.mode_result = "nuclear halfwin - interrupted"
		to_chat(world, "<span style='font-size: 3;'><b>Neutral Victory</b></span>")
		to_chat(world, "<b>Round was mysteriously interrupted!</b>")
	..()
	return


/datum/game_mode/proc/auto_declare_completion_nuclear()
	if(syndicates.len || GAMEMODE_IS_NUCLEAR)
		var/text = "<br><FONT size=3><b>The syndicate operatives were:</b></span>"

		var/purchases = ""
		var/TC_uses = 0

		for(var/datum/mind/syndicate in syndicates)

			text += "<br><b>[syndicate.get_display_key()]</b> was <b>[syndicate.name]</b> ("
			if(syndicate.current)
				if(syndicate.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
				if(syndicate.current.real_name != syndicate.name)
					text += " as <b>[syndicate.current.real_name]</b>"
			else
				text += "body destroyed"
			text += ")"
			for(var/obj/item/uplink/H in GLOB.world_uplinks)
				if(H && H.uplink_owner && H.uplink_owner==syndicate.key)
					TC_uses += H.used_TC
					purchases += H.purchase_log

		text += "<br>"

		text += "(Syndicates used [TC_uses] TC) [purchases]"

		if(TC_uses==0 && station_was_nuked && !is_operatives_are_dead())
			text += "<BIG><IMG CLASS=icon SRC=\ref['icons/misc/badass.dmi'] ICONSTATE='badass'></BIG>"

		to_chat(world, text)
	return 1

/proc/nukelastname(var/mob/M as mob) //--All praise goes to NEO|Phyte, all blame goes to DH, and it was Cindi-Kate's idea. Also praise Urist for copypasta ho.
	var/randomname = pick(GLOB.last_names)
	var/newname = sanitize(copytext_char(input(M,"You are the nuke operative [pick("Czar", "Boss", "Commander", "Chief", "Kingpin", "Director", "Overlord")]. Please choose a last name for your family.", "Name change",randomname),1,MAX_NAME_LEN))

	if(!newname)
		newname = randomname

	else
		if(newname == "Unknown" || newname == "floor" || newname == "wall" || newname == "rwall" || newname == "_")
			to_chat(M, "That name is reserved.")
			return nukelastname(M)

	return newname


/datum/game_mode/nuclear/set_scoreboard_vars()
	var/datum/scoreboard/scoreboard = SSticker.score
	var/foecount = 0

	for(var/datum/mind/M in SSticker.mode.syndicates)
		foecount++
		if(!M || !M.current)
			scoreboard.score_ops_killed++
			continue

		if(M.current.stat == DEAD)
			scoreboard.score_ops_killed++

		else if(HAS_TRAIT(M, TRAIT_RESTRAINED))
			scoreboard.score_arrested++

	if(foecount == scoreboard.score_arrested)
		scoreboard.all_arrested = TRUE // how the hell did they manage that

	var/obj/machinery/nuclearbomb/syndicate/nuke = locate() in GLOB.poi_list
	if(nuke?.r_code != "Nope")
		var/area/A = get_area(nuke)

		var/list/thousand_penalty = list(/area/wizard_station, /area/solar)
		var/list/fiftythousand_penalty = list(/area/security/main, /area/security/brig, /area/security/armory, /area/security/checkpoint/south)

		if(is_type_in_list(A, thousand_penalty))
			scoreboard.nuked_penalty = 1000

		else if(is_type_in_list(A, fiftythousand_penalty))
			scoreboard.nuked_penalty = 50000

		else if(istype(A, /area/engineering))
			scoreboard.nuked_penalty = 100000

		else
			scoreboard.nuked_penalty = 10000

	var/killpoints = scoreboard.score_ops_killed * 250
	var/arrestpoints = scoreboard.score_arrested * 1000
	scoreboard.crewscore += killpoints
	scoreboard.crewscore += arrestpoints
	if(scoreboard.nuked)
		scoreboard.crewscore -= scoreboard.nuked_penalty



/datum/game_mode/nuclear/get_scoreboard_stats()
	var/datum/scoreboard/scoreboard = SSticker.score
	var/foecount = 0
	var/crewcount = 0

	var/diskdat = ""
	var/bombdat = null

	for(var/datum/mind/M in SSticker.mode.syndicates)
		foecount++

	for(var/mob in GLOB.mob_living_list)
		var/mob/living/C = mob
		if(ishuman(C) || isAI(C) || isrobot(C))
			if(C.stat == DEAD)
				continue
			if(!C.client)
				continue
			crewcount++

	var/obj/item/disk/nuclear/N = locate() in GLOB.poi_list
	if(istype(N))
		var/atom/disk_loc = N.loc
		while(!isturf(disk_loc))
			if(ismob(disk_loc))
				var/mob/M = disk_loc
				diskdat += "Carried by [M.real_name] "
			if(isobj(disk_loc))
				var/obj/O = disk_loc
				diskdat += "in \a [O]"
			disk_loc = disk_loc.loc
		diskdat += "in [disk_loc.loc]"


	if(!diskdat)
		diskdat = "WARNING: Nuked_penalty could not be found, look at [__FILE__], [__LINE__]."

	var/dat = ""
	dat += "<b><u>Mode Statistics</b></u><br>"

	dat += "<b>Number of Operatives:</b> [foecount]<br>"
	dat += "<b>Number of Surviving Crew:</b> [crewcount]<br>"

	dat += "<b>Final Location of Nuke:</b> [bombdat]<br>"
	dat += "<b>Final Location of Disk:</b> [diskdat]<br>"

	dat += "<br>"

	dat += "<b>Operatives Arrested:</b> [scoreboard.score_arrested] ([scoreboard.score_arrested * 1000] Points)<br>"
	dat += "<b>All Operatives Arrested:</b> [scoreboard.all_arrested ? "Yes" : "No"] (Score tripled)<br>"

	dat += "<b>Operatives Killed:</b> [scoreboard.score_ops_killed] ([scoreboard.score_ops_killed * 1000] Points)<br>"
	dat += "<b>Station Destroyed:</b> [scoreboard.nuked ? "Yes" : "No"] (-[scoreboard.nuked_penalty] Points)<br>"
	dat += "<hr>"

	return dat

