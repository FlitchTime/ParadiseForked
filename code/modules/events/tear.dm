/datum/event/tear
	startWhen = 3
	announceWhen = 20
	endWhen = 50
	var/obj/effect/tear/TE

/datum/event/tear/announce(false_alarm)
	var/area/target_area = impact_area
	if(!target_area)
		if(false_alarm)
			target_area = findEventArea()
		else
			log_debug("Tried to announce a tear without a valid area!")
			kill()
			return
	GLOB.event_announcement.Announce("На борту станции зафиксирован пространственно-временной разрыв. Предполагаемая локация: [target_area.name].", "ВНИМАНИЕ: ОБНАРУЖЕНА АНОМАЛИЯ.")

/datum/event/tear/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		TE = new /obj/effect/tear(T.loc)

/datum/event/tear/setup()
	impact_area = findEventArea()

/datum/event/tear/end()
	if(TE)
		qdel(TE)

/obj/effect/tear
	name="Dimensional Tear"
	desc="A tear in the dimensional fabric of space and time."
	icon='icons/effects/tear.dmi'
	icon_state="tear"
	density = FALSE
	anchored = TRUE
	light_range = 3

/obj/effect/tear/Initialize(mapload)
	. = ..()
	var/atom/movable/overlay/animation = new(loc)
	animation.icon_state = "newtear"
	animation.icon = 'icons/effects/tear.dmi'
	animation.master = src

	if(animation)
		addtimer(CALLBACK(GLOBAL_PROC, /proc/qdel, animation), 1.5 SECONDS)

	addtimer(CALLBACK(src, PROC_REF(spew_critters)), rand(30, 120))

/obj/effect/tear/proc/spew_critters()
	for(var/i in 1 to 5)
		var/mob/living/spawned_mob
		spawned_mob  = create_random_mob(get_turf(src), HOSTILE_SPAWN)
		spawned_mob.faction |= "chemicalsummon"
		if(prob(50))
			for(var/j = 1, j <= rand(1, 3), j++)
				step(spawned_mob , pick(NORTH, SOUTH, EAST, WEST))
