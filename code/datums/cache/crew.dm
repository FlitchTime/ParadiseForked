GLOBAL_DATUM_INIT(crew_repository, /datum/repository/crew, new())

/datum/repository/crew
	var/static/list/bold_jobs
	var/static/list/security_jobs_list
	var/static/list/mining_jobs_list

/datum/repository/crew/New()
	cache_data = list()
	..()

/datum/repository/crew/proc/health_data(turf/T)
	var/list/crewmembers = list()
	if(!T)
		return crewmembers

	var/z_level = "[T.z]"
	var/datum/cache_entry/cache_entry = cache_data[z_level]
	if(!cache_entry)
		cache_entry = new/datum/cache_entry
		cache_data[z_level] = cache_entry

	if(world.time < cache_entry.timestamp)
		return cache_entry.data

	// Initialize the jobs here because in New(), GLOB.command_positions may not be inited yet
	if(!bold_jobs)
		bold_jobs = list()
		bold_jobs += GLOB.command_positions
		bold_jobs += get_all_centcom_jobs()
		bold_jobs += list(JOB_TITLE_REPRESENTATIVE, JOB_TITLE_BLUESHIELD, JOB_TITLE_JUDGE)

	// It's needed for correct finding security crew in CrewMonitor.js
	if(!security_jobs_list)
		security_jobs_list = list()
		security_jobs_list += GLOB.security_positions

	if(!mining_jobs_list)
		mining_jobs_list = list()
		mining_jobs_list += GLOB.mining_positions

	for(var/thing in GLOB.human_list)
		var/mob/living/carbon/human/H = thing
		var/obj/item/clothing/under/C = H.w_uniform
		if(!C || C.sensor_mode == SUIT_SENSOR_OFF || !C.has_sensor)
			continue
		var/turf/pos = get_turf(C)
		if(!istype(pos) || !T)
			continue
		if((pos.z != T.z) && !(is_station_level(pos.z) && is_station_level(T.z)) && !(HAS_TRAIT(H, TRAIT_MULTIZ_SUIT_SENSORS))) // same z_level or both on STATION_LEVEL or has special trait
			continue
		var/list/crewmemberData = list("dead"=0, "oxy"=-1, "tox"=-1, "fire"=-1, "brute"=-1, "area"="", "x"=-1, "y"=-1, "ref" = "\ref[H]")

		crewmemberData["sensor_type"] = C.sensor_mode
		crewmemberData["name"] = H.get_authentification_name(if_no_id="Unknown")
		crewmemberData["rank"] = H.get_authentification_rank(if_no_id="Unknown", if_no_job="No Job")
		crewmemberData["assignment"] = H.get_assignment(if_no_id="Unknown", if_no_job="No Job")
		crewmemberData["is_command"] = (crewmemberData["rank"] in bold_jobs)
		crewmemberData["is_security"] = (crewmemberData["rank"] in security_jobs_list)
		crewmemberData["is_shaft_miner"] = (crewmemberData["rank"] in mining_jobs_list)

		if(C.sensor_mode >= SUIT_SENSOR_BINARY)
			crewmemberData["dead"] = H.stat == DEAD

		if(C.sensor_mode >= SUIT_SENSOR_VITAL)
			crewmemberData["stat"] = H.stat
			crewmemberData["health"] = H.health
			crewmemberData["oxy"] = round(H.getOxyLoss(), 1)
			crewmemberData["tox"] = round(H.getToxLoss(), 1)
			crewmemberData["fire"] = round(H.getFireLoss(), 1)
			crewmemberData["brute"] = round(H.getBruteLoss(), 1)

		if(C.sensor_mode >= SUIT_SENSOR_TRACKING)
			var/area/A = get_area(H)
			crewmemberData["area"] = A.name
			crewmemberData["x"] = pos.x
			crewmemberData["y"] = pos.y
			crewmemberData["z"] = pos.z

		crewmembers[++crewmembers.len] = crewmemberData

	cache_entry.timestamp = world.time + 5 SECONDS
	cache_entry.data = crewmembers

	return crewmembers
