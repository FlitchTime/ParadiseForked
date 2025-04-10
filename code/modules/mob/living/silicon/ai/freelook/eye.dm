// AI EYE
//
// An invisible (no icon) mob that the AI controls to look around the station with.
// It streams chunks as it moves around, which will show it what the AI can and cannot see.

/mob/camera/aiEye
	name = "Inactive AI Eye"

	icon = 'icons/mob/ai.dmi' //Allows ghosts to see what the AI is looking at.
	icon_state = "eye"
	alpha = 127
	invisibility = SEE_INVISIBLE_OBSERVER

	var/list/visibleCameraChunks = list()
	var/mob/living/silicon/ai/ai = null
	var/relay_speech = FALSE
	var/use_static = TRUE
	var/static_visibility_range = 16
	// Decides if it is shown by AI Detector or not
	var/ai_detector_visible = TRUE

/mob/camera/aiEye/Initialize(mapload)
	. = ..()
	setLoc(loc, TRUE)

/// Used in cases when the eye is located in a movable object (i.e. mecha)
/mob/camera/aiEye/proc/update_visibility()
	SIGNAL_HANDLER
	if(use_static)
		ai.camera_visibility(src)

// Use this when setting the aiEye's location.
// It will also stream the chunk that the new loc is in.

/mob/camera/aiEye/setLoc(turf/destination, force_update = FALSE)
	if(!ai)
		return
	if(!isturf(ai.loc))
		return
	destination = get_turf(destination)
	if(!force_update && (destination == get_turf(src)))
		return //we are already here!
	abstract_move(destination)
	SEND_SIGNAL(src, COMSIG_AI_EYE_MOVED, destination)
	if(use_static)
		ai.camera_visibility(src)
	if(ai.client)
		ai.client.set_eye(src)
	update_parallax_contents()
	//Holopad
	if(istype(ai.current, /obj/machinery/hologram/holopad))
		var/obj/machinery/hologram/holopad/H = ai.current
		H.move_hologram(ai, destination)

/mob/camera/aiEye/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	return FALSE

/mob/camera/aiEye/zMove(dir, turf/target, z_move_flags = NONE, recursions_left = 1, list/falling_movs)
	. = ..()
	if(.)
		setLoc(loc, force_update = TRUE)

/mob/camera/aiEye/proc/GetViewerClient()
	if(ai)
		return ai.client
	return null

/mob/camera/aiEye/proc/RemoveImages()
	var/client/C = GetViewerClient()
	if(C && use_static)
		for(var/datum/camerachunk/chunk in visibleCameraChunks)
			chunk.remove(src)

/mob/camera/aiEye/Destroy()
	if(ai)
		ai.all_eyes -= src
		ai = null
	for(var/V in visibleCameraChunks)
		var/datum/camerachunk/chunk = V
		chunk.remove(src)
	return ..()

/atom/proc/move_camera_by_click()
	if(istype(usr, /mob/living/silicon/ai))
		var/mob/living/silicon/ai/AI = usr
		if(AI.eyeobj && (AI.client.eye == AI.eyeobj) && (AI.eyeobj.z == z))
			AI.cameraFollow = null
			if(isturf(loc) || isturf(src))
				AI.eyeobj.setLoc(get_turf(src))

// AI MOVEMENT

// This will move the AIEye. It will also cause lights near the eye to light up, if toggled.
// This is handled in the proc below this one.

/client/proc/AIMove(n, direct, var/mob/living/silicon/ai/user)
	if(world.time < user.last_movement)
		return
	user.last_movement = world.time + 0.5 // cap to 20fps

	var/initial = initial(user.sprint)
	var/max_sprint = 50

	if(user.cooldown && user.cooldown < world.timeofday) // 3 seconds
		user.sprint = initial

	for(var/i = 0; i < max(user.sprint, initial); i += 20)
		var/turf/step = get_turf(get_step(user.eyeobj, direct))
		if(step)
			user.eyeobj.setLoc(step)

	user.cooldown = world.timeofday + 5
	if(user.acceleration)
		user.sprint = min(user.sprint + 0.5, max_sprint)
	else
		user.sprint = initial

	if(!user.tracking)
		user.cameraFollow = null

	//user.unset_machine() //Uncomment this if it causes problems.
	//user.lightNearbyCamera()
	if(user.camera_light_on)
		user.light_cameras()

// Return to the Core.
/mob/living/silicon/ai/proc/core()
	set category = "AI Commands"
	set name = "AI Core"

	view_core()

/mob/living/silicon/ai/proc/view_core()

	current = null
	cameraFollow = null
	unset_machine()

	if(src.eyeobj && src.loc)
		src.eyeobj.loc = src.loc
	else
		to_chat(src, "ERROR: Eyeobj not found. Creating new eye...")
		create_eye()

	eyeobj.setLoc(loc)

/mob/living/silicon/ai/proc/create_eye()
	if(eyeobj)
		return
	eyeobj = new /mob/camera/aiEye()
	all_eyes += eyeobj
	eyeobj.ai = src
	eyeobj.setLoc(loc)
	eyeobj.name = "[name] (AI Eye)"

/mob/living/silicon/ai/proc/toggle_acceleration()
	set category = "AI Commands"
	set name = "Toggle Camera Acceleration"

	if(usr.stat == 2)
		return //won't work if dead
	acceleration = !acceleration
	to_chat(usr, "Camera acceleration has been toggled [acceleration ? "on" : "off"].")

/mob/living/silicon/ai/move_up()
	set name = "Move Upwards"
	set category = "IC"

	if(eyeobj.zMove(UP, z_move_flags = ZMOVE_FEEDBACK))
		to_chat(src, span_notice("You move upwards."))

/mob/living/silicon/ai/move_down()
	set name = "Move Down"
	set category = "IC"

	if(eyeobj.zMove(DOWN, z_move_flags = ZMOVE_FEEDBACK))
		to_chat(src, span_notice("You move down."))


/mob/camera/aiEye/hear_say(list/message_pieces, verb = "says", italics = 0, mob/speaker = null, sound/speech_sound, sound_vol, sound_frequency, use_voice = TRUE, is_whisper = FALSE)
	if(relay_speech)
		if(istype(ai))
			ai.relay_speech(speaker, message_pieces, verb)
		else
			var/mob/M = ai
			M.hear_say(message_pieces, verb, italics, speaker, speech_sound, sound_vol, sound_frequency)
