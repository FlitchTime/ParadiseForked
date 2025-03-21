/datum/map_template
	var/name = "Default Template Name"
	var/width = 0
	var/height = 0
	var/mappath = null
	var/mapfile = null
	var/loaded = 0 // Times loaded this round

/datum/map_template/New(path = null, map = null, rename = null)
	if(path)
		mappath = path
	if(mappath)
		preload_size(mappath)
	if(map)
		mapfile = map
	if(rename)
		name = rename

/datum/map_template/proc/preload_size(path)
	var/bounds = GLOB.maploader.load_map(wrap_file(path), 1, 1, 1, shouldCropMap = FALSE, measureOnly = TRUE)
	if(bounds)
		width = bounds[MAP_MAXX] // Assumes all templates are rectangular, have a single Z level, and begin at 1,1,1
		height = bounds[MAP_MAXY]
	return bounds

/datum/map_template/proc/load(turf/T, centered = 0)
	var/turf/placement = T
	var/min_x = placement.x
	var/min_y = placement.y
	if(centered)
		min_x -= round(width/2)
		min_y -= round(height/2)

	var/max_x = min_x + width - 1
	var/max_y = min_y + height - 1

	if(!T)
		return 0

	var/turf/bot_left = locate(max(1, min_x), max(1, min_y), placement.z)
	var/turf/top_right = locate(min(world.maxx, max_x), min(world.maxy, max_y), placement.z)

	// 1 bigger, to update the turf smoothing
	var/turf/ST_bot_left = locate(max(1, min_x-1), max(1, min_y-1), placement.z)
	var/turf/ST_top_right = locate(min(world.maxx, max_x+1), min(world.maxy, max_y+1), placement.z)
	// This is to place a freeze on initialization until the map's done loading
	// otherwise atmos and stuff will start running mid-load
	// This system will metaphorically snap in half (not postpone init everywhere)
	// if given a multi-z template
	// it might need to be adapted for that when that time comes
	GLOB.space_manager.add_dirt(placement.z)
	SSicon_smooth.add_halt_source(src)
	try
		var/list/bounds = GLOB.maploader.load_map(get_file(), min_x, min_y, placement.z, shouldCropMap = TRUE)
		if(!bounds)
			return 0
		if(bot_left == null || top_right == null)
			stack_trace("One of the late setup corners is bust")
		if(ST_bot_left == null || ST_top_right == null)
			stack_trace("One of the smoothing corners is bust")
	catch(var/exception/e)
		SSicon_smooth.remove_halt_source(src)
		GLOB.space_manager.remove_dirt(placement.z)
		message_admins("Map template [name] threw an error while loading. Safe exit attempted, but check for errors at [ADMIN_COORDJMP(placement)].")
		log_admin("Map template [name] threw an error while loading. Safe exit attempted.")
		throw e

	SSicon_smooth.remove_halt_source(src)
	GLOB.space_manager.remove_dirt(placement.z)

	add_game_logs("[name] loaded at [min_x],[min_y],[placement.z]")
	return 1

/datum/map_template/proc/get_file()
	if(mapfile)
		. = mapfile
	else if(mappath)
		. = wrap_file(mappath)

	if(!.)
		log_runtime(EXCEPTION("  The file of [src] appears to be empty/non-existent."), src)

/datum/map_template/proc/get_affected_turfs(turf/T, centered = 0)
	var/turf/placement = T
	var/min_x = placement.x
	var/min_y = placement.y
	if(centered)
		min_x -= round(width/2)
		min_y -= round(height/2)

	var/max_x = min_x + width-1
	var/max_y = min_y + height-1
	return block(max(min_x,1), max(min_y,1), placement.z, min(max_x, world.maxx), min(max_y, world.maxy), placement.z)

/datum/map_template/proc/fits_in_map_bounds(turf/T, centered = 0)
	var/turf/placement = T
	var/min_x = placement.x
	var/min_y = placement.y
	if(centered)
		min_x -= round(width/2)
		min_y -= round(height/2)

	var/max_x = min_x + width-1
	var/max_y = min_y + height-1
	if(min_x < 1 || min_y < 1 || max_x > world.maxx || max_y > world.maxy)
		return 0
	else
		return 1


/proc/preloadTemplates(path = "_maps/map_files/templates/") //see master controller setup
	for(var/map in flist(path))
		if(cmptext(copytext(map, length(map) - 3), ".dmm"))
			var/datum/map_template/T = new(path = "[path][map]", rename = "[map]")
			GLOB.map_templates[T.name] = T

	if(!CONFIG_GET(flag/disable_space_ruins)) // so we don't unnecessarily clutter start-up
		preloadRuinTemplates()
	preloadShelterTemplates()
	preloadShuttleTemplates()
	preloadBridgeTemplates()

/proc/preloadRuinTemplates()
	// Still supporting bans by filename
	var/list/banned
	if(fexists("config/spaceRuinBlacklist.txt"))
		banned = generateMapList("config/spaceRuinBlacklist.txt")
	else
		banned = generateMapList("config/example/spaceRuinBlacklist.txt")
	banned += generateMapList("config/lavaRuinBlacklist.txt")

	for(var/item in subtypesof(/datum/map_template/ruin))
		var/datum/map_template/ruin/ruin_type = item
		// screen out the abstract subtypes
		if(!initial(ruin_type.id))
			continue
		var/datum/map_template/ruin/R = new ruin_type()

		if(banned.Find(R.mappath))
			continue

		GLOB.map_templates[R.name] = R
		GLOB.ruins_templates[R.name] = R

		if(istype(R, /datum/map_template/ruin/lavaland))
			GLOB.lava_ruins_templates[R.name] = R
		if(istype(R, /datum/map_template/ruin/space))
			GLOB.space_ruins_templates[R.name] = R

/proc/preloadShelterTemplates()
	for(var/item in subtypesof(/datum/map_template/shelter))
		var/datum/map_template/shelter/shelter_type = item
		if(!(initial(shelter_type.mappath)))
			continue
		var/datum/map_template/shelter/S = new shelter_type()

		GLOB.shelter_templates[S.shelter_id] = S
		GLOB.map_templates[S.shelter_id] = S

/proc/preloadShuttleTemplates()
	for(var/item in subtypesof(/datum/map_template/shuttle))
		var/datum/map_template/shuttle/shuttle_type = item
		if(!initial(shuttle_type.suffix))
			continue

		var/datum/map_template/shuttle/S = new shuttle_type()

		GLOB.shuttle_templates[S.shuttle_id] = S
		GLOB.map_templates[S.shuttle_id] = S

/proc/preloadBridgeTemplates()
	for(var/item in subtypesof(/datum/map_template/ruin/bridge/horizontal))
		var/datum/map_template/ruin/bridge/horizontal/horizontal_type = item
		if(!(initial(horizontal_type.suffix)))
			continue
		var/datum/map_template/ruin/bridge/horizontal/S = new horizontal_type()
		GLOB.bridge_horizontal_templates[S.suffix] = S
		GLOB.map_templates[S.suffix] = S
	for(var/item in subtypesof(/datum/map_template/ruin/bridge/vertical))
		var/datum/map_template/ruin/bridge/horizontal/vertical_type = item
		if(!(initial(vertical_type.suffix)))
			continue
		var/datum/map_template/ruin/bridge/vertical/V = new vertical_type()
		GLOB.bridge_vertical_templates[V.suffix] = V
		GLOB.map_templates[V.suffix] = V
