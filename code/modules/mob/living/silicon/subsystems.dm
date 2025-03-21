/mob/living/silicon
	var/register_alarms = TRUE
	var/datum/ui_module/atmos_control/atmos_control
	var/datum/ui_module/crew_monitor/crew_monitor
	var/datum/ui_module/law_manager/law_manager
	var/datum/ui_module/power_monitor/digital/power_monitor
	var/obj/item/areaeditor/blueprints/cyborg/blueprints

/mob/living/silicon
	var/list/silicon_subsystems = list(
		/mob/living/silicon/proc/subsystem_open_gps,
		/mob/living/silicon/proc/subsystem_law_manager
	)

/mob/living/silicon/decoy
	silicon_subsystems = list(
		/mob/living/silicon/proc/subsystem_law_manager
	)

/mob/living/silicon/ai
	silicon_subsystems = list(
		/mob/living/silicon/proc/subsystem_open_gps,
		/mob/living/silicon/proc/subsystem_atmos_control,
		/mob/living/silicon/proc/subsystem_crew_monitor,
		/mob/living/silicon/proc/subsystem_law_manager,
		/mob/living/silicon/proc/subsystem_power_monitor
	)

/mob/living/silicon/robot
	var/datum/ui_module/robot_self_diagnosis/self_diagnosis
	silicon_subsystems = list(
		/mob/living/silicon/proc/subsystem_open_gps,
		/mob/living/silicon/robot/proc/self_diagnosis,
		/mob/living/silicon/proc/subsystem_law_manager
	)

/mob/living/silicon/robot/drone
	silicon_subsystems = list(
		/mob/living/silicon/proc/subsystem_open_gps,
		/mob/living/silicon/robot/proc/self_diagnosis,
		/mob/living/silicon/proc/subsystem_law_manager,
		/mob/living/silicon/proc/subsystem_power_monitor
	)

/mob/living/silicon/robot/cogscarab
	silicon_subsystems = list(
		/mob/living/silicon/proc/subsystem_open_gps,
		/mob/living/silicon/robot/proc/self_diagnosis,
		/mob/living/silicon/proc/subsystem_law_manager
	)

/mob/living/silicon/robot/syndicate
	register_alarms = 0

/mob/living/silicon/proc/init_subsystems()
	atmos_control 	= new(src)
	crew_monitor 	= new(src)
	law_manager		= new(src)
	power_monitor	= new(src)
	gps				= new(src)
	blueprints		= new(src)

/mob/living/silicon/decoy/init_subsystems()
	law_manager = new(src)
	return

/mob/living/silicon/robot/init_subsystems()
	. = ..()
	self_diagnosis  = new(src)

/********************
*	Atmos Control	*
********************/
/mob/living/silicon/proc/subsystem_atmos_control()
	set category = "Subsystems"
	set name = "Atmospherics Control"

	atmos_control.ui_interact(usr)

/********************
*	Crew Monitor	*
********************/
/mob/living/silicon/proc/subsystem_crew_monitor()
	set category = "Subsystems"
	set name = "Crew Monitor"
	crew_monitor.ui_interact(usr)

/****************
*	Law Manager	*
****************/
/mob/living/silicon/proc/subsystem_law_manager()
	set name = "Law Manager"
	set category = "Subsystems"

	law_manager.ui_interact(usr)

/********************
*	Power Monitor	*
********************/
/mob/living/silicon/proc/subsystem_power_monitor()
	set category = "Subsystems"
	set name = "Power Monitor"

	power_monitor.ui_interact(usr)

/********************
*	GPS	*
********************/
/mob/living/silicon/proc/subsystem_open_gps()
	set name = "GPS"
	set category = "Subsystems"

	gps.ui_interact(src)

/********************
*	Blueprints	*
********************/
/mob/living/silicon/proc/subsystem_blueprints()
	set name = "Station Blueprints"
	set category = "Subsystems"

	blueprints.interact_prints(src)

/mob/living/silicon/robot/proc/self_diagnosis()
	set category = "Robot Commands"
	set name = "Self Diagnosis"

	if(!is_component_functioning("diagnosis unit"))
		to_chat(src, "<span class='warning'>Your self-diagnosis component isn't functioning.</span>")
		return

	self_diagnosis.ui_interact(src)
