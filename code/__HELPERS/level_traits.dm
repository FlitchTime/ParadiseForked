/proc/is_level_reachable(z)
	return check_level_trait(z, REACHABLE)

/proc/is_station_level(z)
	return check_level_trait(z, STATION_LEVEL)

/proc/is_station_contact(z)
	return check_level_trait(z, STATION_CONTACT)

/proc/is_teleport_allowed(z)
	return !check_level_trait(z, BLOCK_TELEPORT)

/proc/is_admin_level(z)
	return check_level_trait(z, ADMIN_LEVEL)

/proc/is_reserved_level(z)
	return check_level_trait(z, RESERVED_LEVEL)

/proc/is_away_level(z)
	return check_level_trait(z, AWAY_LEVEL)

/proc/is_mining_level(z)
	return check_level_trait(z, ORE_LEVEL)

/proc/is_ai_allowed(z)
	return check_level_trait(z, AI_OK)

/proc/level_blocks_magic(z)
	return check_level_trait(z, IMPEDES_MAGIC)

/proc/level_boosts_signal(z)
	return check_level_trait(z, BOOSTS_SIGNAL)

/proc/is_explorable_space(z)
	return check_level_trait(z, SPAWN_RUINS)

/proc/is_taipan(z)
	return check_level_trait(z, TAIPAN)

// Used for the nuke disk, or for checking if players survived through xenos
/proc/is_secure_level(z)
	var/secure = check_level_trait(z, STATION_LEVEL)
	if(!secure)
	// This is to allow further admin levels later, other than centcomm
		secure = (z == level_name_to_num(CENTCOMM))
	return secure

GLOBAL_LIST_INIT(default_map_traits, MAP_TRANSITION_CONFIG)

/proc/check_level_trait(z, trait)
	if(!z)
		return FALSE // If you're nowhere, you have no traits
	var/list/trait_list
	if(GLOB.space_manager.initialized)
		var/datum/space_level/S = GLOB.space_manager.get_zlev(z)
		trait_list = S.flags
	else
		trait_list = GLOB.default_map_traits[z]
		trait_list = trait_list["traits"]
	return ((trait_list[trait]) || (trait in trait_list)) // Return set association to trait(TRAIT = num or string), or 1(as true)

/proc/levels_by_trait(trait)
	var/list/result = list()
	for(var/A in GLOB.space_manager.z_list)
		var/datum/space_level/S = GLOB.space_manager.z_list[A]
		if(trait in S.flags)
			result |= S.zpos
	return result

/proc/level_name_to_num(name)
	var/datum/space_level/S = GLOB.space_manager.get_zlev_by_name(name)
	if(!S)
		CRASH("Unknown z-level name: [name]")
	return S.zpos

/**
  * Proc to get a list of all the linked-together Z-Levels
  *
  * Returns a list of zlevel numbers which can be accessed from travelling space naturally
  * ignores Taipan tho
  */
/proc/get_all_linked_levels_zpos()
	var/list/znums = list()
	for(var/i in GLOB.space_manager.z_list)
		var/datum/space_level/SL = GLOB.space_manager.z_list[i]
		if(SL.linkage == CROSSLINKED && !is_taipan(SL.zpos))
			znums |= SL.zpos
	return znums

/// Checks if both atoms are in same z or in connected z-levels.
/proc/are_zs_connected(atom/A, atom/B)
	A = get_turf(A)
	B = get_turf(B)
	if(isnull(A) || isnull(B))
		return FALSE
	if(A.z == B.z)
		return TRUE
	return (B.z in SSmapping.get_connected_levels(A))
