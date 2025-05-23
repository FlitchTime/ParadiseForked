#define BAD_INIT_QDEL_BEFORE 1
#define BAD_INIT_DIDNT_INIT 2
#define BAD_INIT_SLEPT 4
#define BAD_INIT_NO_HINT 8

SUBSYSTEM_DEF(atoms)
	name = "Atoms"
	init_order = INIT_ORDER_ATOMS
	flags = SS_NO_FIRE
	ss_id = "atoms"

	var/old_initialized

	var/list/late_loaders

	var/list/BadInitializeCalls = list()


/datum/controller/subsystem/atoms/Initialize()
	setupgenetics()
	initialized = INITIALIZATION_INNEW_MAPLOAD
	InitializeAtoms()
	return SS_INIT_SUCCESS


/datum/controller/subsystem/atoms/proc/InitializeAtoms(list/atoms, noisy = TRUE)
	if(initialized == INITIALIZATION_INSSATOMS)
		return

	SSicon_smooth.add_halt_source(src)
	initialized = INITIALIZATION_INNEW_MAPLOAD

	LAZYINITLIST(late_loaders)

	var/watch = start_watch()
	if(noisy)
		log_startup_progress("Initializing atoms...")
	else
		log_debug("Initializing atoms...")
	var/count
	var/list/mapload_arg = list(TRUE)
	if(atoms)
		count = atoms.len
		for(var/I in 1 to atoms.len)
			var/atom/A = atoms[I]
			if(!(A.flags & INITIALIZED))
				InitAtom(A, mapload_arg)
				CHECK_TICK
	else
		count = 0
		for(var/atom/A as anything in world)
			if(!(A.flags & INITIALIZED))
				InitAtom(A, mapload_arg)
				++count
				CHECK_TICK

	if(noisy)
		log_startup_progress("Initialized [count] atoms in [stop_watch(watch)]s")
	else
		log_debug("	Initialized [count] atoms in [stop_watch(watch)]s")
	pass(count)

	initialized = INITIALIZATION_INNEW_REGULAR

	if(late_loaders.len)
		watch = start_watch()
		if(noisy)
			log_startup_progress("Late-initializing atoms...")
		else
			log_debug("Late-initializing atoms...")
		for(var/I in 1 to late_loaders.len)
			var/atom/A = late_loaders[I]
			if(QDELETED(A))	// hate this, but qdel check is a must
				continue
			A.LateInitialize()
			CHECK_TICK
		if(noisy)
			log_startup_progress("Late initialized [length(late_loaders)] atoms in [stop_watch(watch)]s")
		else
			log_debug("	Late initialized [length(late_loaders)] atoms in [stop_watch(watch)]s")
		late_loaders.Cut()

	SSicon_smooth.remove_halt_source(src)

/datum/controller/subsystem/atoms/proc/InitAtom(atom/A, list/arguments)
	var/the_type = A.type
	if(QDELING(A))
		BadInitializeCalls[the_type] |= BAD_INIT_QDEL_BEFORE
		return TRUE

	var/start_tick = world.time

	var/result = A.Initialize(arglist(arguments))

	if(start_tick != world.time)
		BadInitializeCalls[the_type] |= BAD_INIT_SLEPT

	var/qdeleted = FALSE

	switch(result)
		if(INITIALIZE_HINT_NORMAL)
			EMPTY_BLOCK_GUARD // Pass
		if(INITIALIZE_HINT_LATELOAD)
			if(arguments[1])	//mapload
				late_loaders += A
			else
				A.LateInitialize()
		if(INITIALIZE_HINT_QDEL)
			qdel(A)
			qdeleted = TRUE
		else
			BadInitializeCalls[the_type] |= BAD_INIT_NO_HINT

	if(!A)	//possible harddel
		qdeleted = TRUE
	else if(!(A.flags & INITIALIZED))
		BadInitializeCalls[the_type] |= BAD_INIT_DIDNT_INIT
	else
		SEND_SIGNAL(A, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZE)
		var/atom/location = A.loc
		if(location)
			/// Sends a signal that the new atom `src`, has been created at `loc`
			SEND_SIGNAL(location, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, A, arguments[1])


	return qdeleted || QDELING(A)


/datum/controller/subsystem/atoms/proc/map_loader_begin()
	old_initialized = initialized
	initialized = INITIALIZATION_INSSATOMS
	SSicon_smooth.add_halt_source(src)


/datum/controller/subsystem/atoms/proc/map_loader_stop()
	initialized = old_initialized
	SSicon_smooth.remove_halt_source(src)

/datum/controller/subsystem/atoms/Recover()
	initialized = SSatoms.initialized
	if(initialized == INITIALIZATION_INNEW_MAPLOAD)
		InitializeAtoms()
	old_initialized = SSatoms.old_initialized
	BadInitializeCalls = SSatoms.BadInitializeCalls


/client/proc/debug_atom_init()
	set name = "Atom Init Log"
	set category = "Debug"
	set desc = "Shows what failed to init this round"

	if(!check_rights(R_DEBUG|R_VIEWRUNTIMES))
		return

	var/list/html_data = list()
	html_data += "<h1>Bad Initialize() Calls</h1><table border='1'><tr><th scope='col'>Type</th><th scope='col'>Qdeleted before init</th><th scope='col'>Did not init</th><th scope='col'>Slept during init</th><th scope='col'>No init hint</th></tr>"

	for(var/typepath in SSatoms.BadInitializeCalls)
		var/val = SSatoms.BadInitializeCalls[typepath]

		html_data += "<tr><td>[typepath]</td><td>[val & BAD_INIT_QDEL_BEFORE ? "X" : "&nbsp;"]</td><td>[val & BAD_INIT_DIDNT_INIT ? "X" : "&nbsp;"]</td><td>[val & BAD_INIT_SLEPT ? "X" : "&nbsp;"]</td><td>[val & BAD_INIT_NO_HINT ? "X" : "&nbsp;"]</td></tr>"

	html_data += "</table>"

	var/datum/browser/popup = new(usr, "initdebug", "Init Debug")
	popup.set_content(html_data.Join())
	popup.open(FALSE)

