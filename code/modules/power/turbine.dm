// TURBINE v2 AKA rev4407 Engine reborn!

// How to use it? - Mappers
//
// This is a very good power generating mechanism. All you need is a blast furnace with soaring flames and output.
// Not everything is included yet so the turbine can run out of fuel quiet quickly. The best thing about the turbine is that even
// though something is on fire that passes through it, it won't be on fire as it passes out of it. So the exhaust fumes can still
// containt unreacted fuel - plasma and oxygen that needs to be filtered out and re-routed back. This of course requires smart piping
// For a computer to work with the turbine the compressor requires a comp_id matching with the turbine computer's id. This will be
// subjected to a change in the near future mind you. Right now this method of generating power is a good backup but don't expect it
// become a main power source unless some work is done. Have fun. At 50k RPM it generates 60k power. So more than one turbine is needed!
//
// - Numbers
//
// Example setup	 S - sparker
//					 B - Blast doors into space for venting
// *BBB****BBB*		 C - Compressor
// S    CT    *		 T - Turbine
// * ^ *  * V *		 D - Doors with firedoor
// **|***D**|**      ^ - Fuel feed (Not vent, but a gas outlet)
//   |      |        V - Suction vent (Like the ones in atmos
//

#define OVERDRIVE 4
#define VERY_FAST 3
#define FAST 2
#define SLOW 1


/obj/machinery/power/compressor
	name = "compressor"
	desc = "The compressor stage of a gas turbine generator."
	icon = 'icons/obj/pipes_and_stuff/atmospherics/pipes.dmi'
	icon_state = "compressor"
	anchored = TRUE
	density = TRUE
	resistance_flags = FIRE_PROOF
	var/obj/machinery/power/turbine/turbine
	var/datum/gas_mixture/gas_contained
	var/turf/simulated/inturf
	var/starter = 0
	var/rpm = 0
	var/rpmtarget = 0
	var/capacity = 1e6
	var/comp_id = 0
	var/efficiency
	var/rpm_threshold = NONE


/obj/machinery/power/turbine
	name = "gas turbine generator"
	desc = "A gas turbine used for backup power generation."
	icon = 'icons/obj/pipes_and_stuff/atmospherics/pipes.dmi'
	icon_state = "turbine"
	anchored = TRUE
	density = TRUE
	resistance_flags = FIRE_PROOF
	var/opened = 0
	var/obj/machinery/power/compressor/compressor
	var/turf/simulated/outturf
	var/lastgen
	var/productivity = 1
	/// If the turbine is outputing enough to visibly affect its sprite
	var/generator_threshold = FALSE

/obj/machinery/computer/turbine_computer
	name = "gas turbine control computer"
	desc = "Компьютер для дистанционного управления газовой турбиной."
	icon_screen = "turbinecomp"
	icon_keyboard = "tech_key"
	circuit = /obj/item/circuitboard/turbine_computer
	var/obj/machinery/power/compressor/compressor
	var/id = 0

// the inlet stage of the gas turbine electricity generator

/obj/machinery/power/compressor/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/power_compressor(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()
// The inlet of the compressor is the direction it faces

	gas_contained = new
	inturf = get_step(src, dir)
	locate_machinery()
	if(!turbine)
		stat |= BROKEN


#define COMPFRICTION 5e5
#define COMPSTARTERLOAD 2800


// Crucial to make things work!!!!
// OLD FIX - explanation given down below.
// /obj/machinery/power/compressor/CanPass(atom/movable/mover, turf/target, height=0)
// 		return !density

/obj/machinery/power/compressor/locate_machinery()
	if(turbine)
		return
	turbine = locate() in get_step(src, get_dir(inturf, src))
	if(turbine)
		turbine.locate_machinery()

/obj/machinery/power/compressor/RefreshParts()
	var/E = 0
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		E += M.rating
	efficiency = E / 6


/obj/machinery/power/compressor/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(exchange_parts(user, I))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/machinery/power/compressor/wrench_act(mob/living/user, obj/item/I)
	. = default_change_direction_wrench(user, I)
	if(!.)
		return .
	turbine = null
	inturf = get_step(src, dir)
	locate_machinery()
	if(turbine)
		to_chat(user, span_notice("The turbine is connected."))
		stat &= ~BROKEN
	else
		to_chat(user, span_warning("The turbine is not connected."))
		stat |= BROKEN


/obj/machinery/power/compressor/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/power/compressor/screwdriver_act(mob/user, obj/item/I)
	if(default_deconstruction_screwdriver(user, initial(icon_state), initial(icon_state), I))
		return TRUE

/obj/machinery/power/compressor/CanAtmosPass(turf/T, vertical)
	return !density

/obj/machinery/power/compressor/process()
	if(!turbine)
		stat = BROKEN
	if(stat & BROKEN || panel_open)
		return
	if(!starter)
		return

	rpm = 0.9* rpm + 0.1 * rpmtarget
	var/datum/gas_mixture/environment = inturf.return_air()

	// It's a simplified version taking only 1/10 of the moles from the turf nearby. It should be later changed into a better version

	var/transfer_moles = environment.total_moles()/10
	//var/transfer_moles = rpm/10000*capacity
	var/datum/gas_mixture/removed = inturf.remove_air(transfer_moles)
	gas_contained.merge(removed)

// RPM function to include compression friction - be advised that too low/high of a compfriction value can make things screwy

	rpm = max(0, rpm - (rpm*rpm)/(COMPFRICTION*efficiency))


	if(starter && !(stat & NOPOWER))
		use_power(2800)
		if(rpm<1000)
			rpmtarget = 1000
	else
		if(rpm<1000)
			rpmtarget = 0


	var/new_rpm_threshold
	switch(rpm)
		if(50001 to INFINITY)
			new_rpm_threshold = OVERDRIVE
		if(10001 to 50000)
			new_rpm_threshold = VERY_FAST
		if(2001 to 10000)
			new_rpm_threshold = FAST
		if(501 to 2000)
			new_rpm_threshold = SLOW
		else
			new_rpm_threshold = NONE

	if(rpm_threshold != new_rpm_threshold)
		rpm_threshold = new_rpm_threshold
		update_icon(UPDATE_OVERLAYS)


/obj/machinery/power/compressor/update_overlays()
	. = ..()
	if(!rpm_threshold)
		return
	. += image(icon, icon_state = "comp-o[rpm_threshold]", layer = FLY_LAYER)


// These are crucial to working of a turbine - the stats modify the power output. TurbGenQ modifies how much raw energy can you get from
// rpms, TurbGenG modifies the shape of the curve - the lower the value the less straight the curve is.

#define TURBPRES 9000000
#define TURBGENQ 100000
#define TURBGENG 0.5

/obj/machinery/power/turbine/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/power_turbine(src)
	component_parts += new /obj/item/stock_parts/capacitor(src)
	component_parts += new /obj/item/stock_parts/capacitor(src)
	component_parts += new /obj/item/stock_parts/capacitor(src)
	component_parts += new /obj/item/stock_parts/capacitor(src)
	component_parts += new /obj/item/stock_parts/capacitor(src)
	component_parts += new /obj/item/stock_parts/capacitor(src)
	component_parts += new /obj/item/stack/cable_coil(src, 5)
	RefreshParts()
// The outlet is pointed at the direction of the turbine component

	outturf = get_step(src, dir)
	locate_machinery()
	if(!compressor)
		stat |= BROKEN

/obj/machinery/power/turbine/RefreshParts()
	var/P = 0
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		P += C.rating
	productivity = P / 6

/obj/machinery/power/turbine/locate_machinery()
	if(compressor)
		return
	compressor = locate() in get_step(src, get_dir(outturf, src))
	if(compressor)
		compressor.locate_machinery()

/obj/machinery/power/turbine/CanAtmosPass(turf/T, vertical)
	return !density

/obj/machinery/power/turbine/process()

	if(!compressor)
		stat = BROKEN

	if((stat & BROKEN) || panel_open)
		return
	if(!compressor.starter)
		return

	// This is the power generation function. If anything is needed it's good to plot it in EXCEL before modifying
	// the TURBGENQ and TURBGENG values

	lastgen = ((compressor.rpm / TURBGENQ)**TURBGENG) * TURBGENQ * productivity

	add_avail(lastgen)

	// Weird function but it works. Should be something else...

	var/newrpm = ((compressor.gas_contained.temperature) * compressor.gas_contained.total_moles())/4

	newrpm = max(0, newrpm)

	if(!compressor.starter || newrpm > 1000)
		compressor.rpmtarget = newrpm

	if(compressor.gas_contained.total_moles()>0)
		var/oamount = min(compressor.gas_contained.total_moles(), (compressor.rpm+100)/35000*compressor.capacity)
		var/datum/gas_mixture/removed = compressor.gas_contained.remove(oamount)
		outturf.assume_air(removed)

	if((lastgen > 100) != generator_threshold)
		generator_threshold = !generator_threshold
		update_icon(UPDATE_OVERLAYS)

	updateDialog()


/obj/machinery/power/turbine/update_overlays()
	. = ..()
	if(!generator_threshold)
		return
	. += image(icon, icon_state = "turb-o", layer = FLY_LAYER)


/obj/machinery/power/turbine/attack_hand(mob/user)

	if(..())
		return

	interact(user)


/obj/machinery/power/turbine/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(exchange_parts(user, I))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/machinery/power/turbine/screwdriver_act(mob/living/user, obj/item/I)
	return default_deconstruction_screwdriver(user, initial(icon_state), initial(icon_state), I)


/obj/machinery/power/turbine/wrench_act(mob/living/user, obj/item/I)
	. = default_change_direction_wrench(user, I)
	if(!.)
		return .
	compressor = null
	outturf = get_step(src, dir)
	locate_machinery()
	if(compressor)
		to_chat(user, span_notice("The compressor is connected."))
		stat &= ~BROKEN
	else
		to_chat(user, span_warning("The compressor is not connected."))
		stat |= BROKEN


/obj/machinery/power/turbine/crowbar_act(mob/living/user, obj/item/I)
	return default_deconstruction_crowbar(user, I)


/obj/machinery/power/turbine/interact(mob/user)

	if( !Adjacent(user)  || (stat & (NOPOWER|BROKEN)) && (!istype(user, /mob/living/silicon)) )
		user.unset_machine(src)
		close_window(user, "turbine")
		return

	var/t = "<tt><b>Gas Turbine Generator</b><hr><pre>"

	t += "Generated power : [round(lastgen)] W<br><br>"

	t += "Turbine: [round(compressor.rpm)] RPM<br>"

	t += "Starter: [ compressor.starter ? "<a href='byond://?src=[UID()];str=1'>Off</a> <b>On</b>" : "<b>Off</b> <a href='byond://?src=[UID()];str=1'>On</a>"]"

	t += "</pre><hr><a href='byond://?src=[UID()];close=1'>Close</a>"

	t += "</tt>"
	var/datum/browser/popup = new(user, "turbine", name, 420, 240, src)
	popup.set_content(t)
	popup.open()

	return

/obj/machinery/power/turbine/Topic(href, href_list)
	if(..())
		return

	if( href_list["close"] )
		close_window(usr, "turbine")
		usr.unset_machine(src)
		return

	else if( href_list["str"] )
		if(compressor)
			compressor.starter = !compressor.starter

	updateDialog()





/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// COMPUTER NEEDS A SERIOUS REWRITE.



/obj/machinery/computer/turbine_computer/Initialize()
	. = ..()
	spawn(10)
		locate_machinery()

/obj/machinery/computer/turbine_computer/locate_machinery()
	compressor = locate(/obj/machinery/power/compressor) in range(5, src)

/obj/machinery/computer/turbine_computer/attack_hand(var/mob/user as mob)
	if(..())
		return

	interact(user)

/obj/machinery/computer/turbine_computer/interact(mob/user)

	var/dat = ""
	if(compressor && compressor.turbine)
		dat += "<br><b>Gas turbine remote control system</b><hr>"
		if(compressor.stat || compressor.turbine.stat)
			dat += "[compressor.stat ? "<b>Compressor is inoperable</b><br>" : "<b>Turbine is inoperable</b>"]"
		else
			dat += {"Turbine status: [ src.compressor.starter ? "<a href='byond://?src=[UID()];str=1'>Off</a> <b>On</b>" : "<b>Off</b> <a href='byond://?src=[UID()];str=1'>On</a>"]
			<br>
			Turbine speed: [src.compressor.rpm]rpm<br>
			Power currently being generated: [src.compressor.turbine.lastgen]W<br>
			Internal gas temperature: [src.compressor.gas_contained.temperature]K<br>
			</pre><hr><a href='byond://?src=[UID()];close=1'>Close</a>
			<br>
			"}
	else
		dat += "<b>There is [!compressor ? "no compressor" : " compressor[!compressor.turbine ? " but no turbine" : ""]"].</b><br>"
		if(!compressor)
			dat += "<a href='byond://?src=[UID()];search=1'>Search for compressor</a>"

	var/datum/browser/popup = new(user, "turbinecomputer", name, 420, 240, src)
	popup.set_content(dat)
	popup.open()
	return

/obj/machinery/computer/turbine_computer/Topic(href, href_list)
	if(..())
		return

	else if( href_list["str"] )
		if(compressor && compressor.turbine)
			compressor.starter = !compressor.starter
	else if( href_list["close"] )
		close_window(usr, "turbinecomputer")
		usr.unset_machine(src)
		return
	else if(href_list["search"])
		locate_machinery()

	src.updateUsrDialog()
	return

/obj/machinery/computer/turbine_computer/process()
	src.updateDialog()
	return

#undef OVERDRIVE
#undef VERY_FAST
#undef FAST
#undef SLOW

