/**
  * # Rep Purchase - Blackout and Comms Outage
  */
/datum/rep_purchase/blackout
	name = "Блэкаут"
	description = "Перегружает силовую сеть станции, закорачивая случайные ЛКП."
	cost = 1
	// Settings
	/// How long a contractor must wait before calling another blackout, in deciseconds.
	var/static/cooldown = 15 MINUTES
	// Variables
	/// Static cooldown variable for blackouts.
	var/static/next_blackout = -1

/datum/rep_purchase/blackout/buy(datum/contractor_hub/hub, mob/living/carbon/human/user)
	if(next_blackout > world.time)
		var/timeleft = (next_blackout - world.time) / 10
		to_chat(user, span_warning("Повторный блэкаут не может быть запрошен в течение [seconds_to_clock(timeleft)]."))
		return FALSE
	return ..()

/datum/rep_purchase/blackout/on_buy(datum/contractor_hub/hub, mob/living/carbon/human/user)
	..()
	next_blackout = world.time + cooldown
	power_failure()

/datum/rep_purchase/comms_blackout
	name = "Отключение связи"
	description = "Запрос командования Синдиката на отключение телекоммуникаций станции. Отключает телекоммуникации на станции на определённое время."
	cost = 2
	var/static/cooldown = 10 MINUTES
	var/static/next_commsout = -1

/datum/rep_purchase/comms_blackout/buy(datum/contractor_hub/hub, mob/living/carbon/human/user)
	if(next_commsout > world.time)
		var/timeleft = (next_commsout - world.time) / 10
		to_chat(user, span_warning("Повторное отключение связи не может быть запрошено в течение [seconds_to_clock(timeleft)]."))
		return FALSE
	return ..()

/datum/rep_purchase/comms_blackout/on_buy(datum/contractor_hub/hub, mob/living/carbon/human/user)
	..()
	next_commsout = world.time + cooldown
	var/alert = pick(	"Обнаружено враждебное вмешательство в работу телекоммуникаций. Неизбежен временный сбо*%fj 00)`5 vc-БЗЗЗ", \
						"Обнаружено враждебное вмешательство в работу телекоммуни*3mga;b4;'1v?-БЗЗЗЗ", \
						"Обнаружено враждебное вмешательс#MCi46:5.;@63-БЗЗЗЗЗ", \
						"Обнаружено вражде'fZ\\kg5_0-БЗЗЗЗЗ", \
						"Обнаруж:%? MCayj^j<.3-БЗЗЗЗЗ", \
						"#4nd%;f4де,>?%-БЗЗЗЗЗЗЗ")
	GLOB.event_announcement.Announce(alert)
	for(var/obj/machinery/tcomms/core/T in GLOB.tcomms_machines)
		T.start_ion()
		addtimer(CALLBACK(T, TYPE_PROC_REF(/obj/machinery/tcomms, end_ion)), rand(1800, 3000))


