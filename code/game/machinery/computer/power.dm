/obj/machinery/computer/monitor
	name = "power monitoring console"
	desc = "Используется для мониторинга уровня энергопотребления на всей станции."
	icon_screen = "power"
	icon_keyboard = "power_key"
	use_power = ACTIVE_POWER_USE
	idle_power_usage = 20
	active_power_usage = 80
	light_color = LIGHT_COLOR_ORANGE
	circuit = /obj/item/circuitboard/powermonitor
	var/datum/powernet/powernet = null
	var/datum/ui_module/power_monitor/power_monitor
	/// Will this monitor be hidden from viewers?
	var/is_secret_monitor = FALSE
	/// How many records to keep of supply and demand
	var/record_size = 60
	/// Interval between power snapshots
	var/record_interval = 5 SECONDS
	/// Time to next record power
	var/next_record = 0
	/// The history list itself of the power
	var/list/history = list()

/obj/machinery/computer/monitor/secret //Hides the power monitor (such as ones on ruins & CentCom) from PDA's to prevent metagaming.
	name = "outdated power monitoring console"
	desc = "Используется для отслеживания уровня энергопотребления в локальной сети."
	circuit = /obj/item/circuitboard/powermonitor/secret
	is_secret_monitor = TRUE

/obj/machinery/computer/monitor/secret/old_frame
	icon = 'icons/obj/machines/computer3.dmi'
	icon_screen = "power_oldframe"
	icon_state = "frame-eng"
	icon_keyboard = "kb11"

/obj/machinery/computer/monitor/New()
	..()
	GLOB.power_monitors += src
	GLOB.power_monitors = sortAtom(GLOB.power_monitors)
	power_monitor = new(src)

/obj/machinery/computer/monitor/Initialize()
	. = ..()
	if(!is_secret_monitor && !(stat & (NOPOWER|BROKEN)))
		GLOB.powermonitor_repository.add_to_cache(src)
	powernet = find_powernet()
	history["supply"] = list()
	history["demand"] = list()

/obj/machinery/computer/monitor/Destroy()
	GLOB.power_monitors -= src
	GLOB.powermonitor_repository.remove_from_cache(src)
	QDEL_NULL(power_monitor)
	return ..()

/obj/machinery/computer/monitor/power_change(forced = FALSE)
	. = ..()
	if(is_secret_monitor)
		return
	if(!(stat & (NOPOWER|BROKEN)))
		GLOB.powermonitor_repository.add_to_cache(src)
	else
		GLOB.powermonitor_repository.remove_from_cache(src)

/obj/machinery/computer/monitor/proc/find_powernet()
	var/obj/structure/cable/attached = null
	var/turf/T = loc
	if(isturf(T))
		attached = locate() in T
	if(attached)
		return attached.powernet

/obj/machinery/computer/monitor/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/computer/monitor/attack_hand(mob/user)
	if(stat & (BROKEN|NOPOWER))
		return

	if(..())
		return TRUE

	add_fingerprint(user)
	// Update the powernet
	powernet = find_powernet()
	ui_interact(user)

/obj/machinery/computer/monitor/ui_interact(mob/user, datum/tgui/ui = null)
	power_monitor.ui_interact(user, ui)

/obj/machinery/computer/monitor/interact(mob/user)
	power_monitor.ui_interact(user)

/obj/machinery/computer/monitor/process()
	record()

/**
  * Power snapshot recording proc
  *
  * This proc handles recording powernet history for the graph on the TGUI
  * It is called every process(), but only logs every 5 seconds
  */
/obj/machinery/computer/monitor/proc/record()
	if(world.time >= next_record)
		next_record = world.time + record_interval
		if(!powernet)
			return

		var/list/supply = history["supply"]
		supply += powernet.viewavail
		if(length(supply) > record_size)
			supply.Cut(1, 2)

		var/list/demand = history["demand"]
		demand += powernet.viewload
		if(length(demand) > record_size)
			demand.Cut(1, 2)
