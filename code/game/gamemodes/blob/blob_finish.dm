/datum/game_mode/blob/check_finished()
	if(blob_objective.check_completion())//Blob took over
		return FALSE
	return ..()

/datum/game_mode/proc/start_blob_win()
	if(GLOB.security_level == SEC_LEVEL_DELTA)
		return
	update_blob_objective()
	GLOB.event_announcement.Announce("Объект потерян. Причина: распространение биологической угрозы 5-го уровня. Взведение устройства самоуничтожения персоналом или внешними силами в данный момент не представляется возможным из-за высокого уровня заражения. Активация протоколов изоляции.",
										"Отчёт об объекте [station_name()]")
	blob_stage = (delay_blob_end)? BLOB_STAGE_POST_END : BLOB_STAGE_END
	if(blob_stage == BLOB_STAGE_END)
		end_game()


/datum/game_mode/proc/delay_blob_win()
	delay_blob_end = TRUE

/datum/game_mode/proc/return_blob_win()
	delay_blob_end = FALSE

/datum/game_mode/proc/declare_blob_completion()
	if(station_was_nuked && blob_stage != BLOB_STAGE_POST_END)
		if(GAMEMODE_IS_BLOB)
			SSticker.mode_result = "blob halfwin - nuke"
			add_game_logs("Blob mode completed with a tie (station destroyed).")
		to_chat(world, span_fontsize3("<br><b>Частичная победа блоба!</b>"))
		to_chat(world, "<b>Станция была уничтожена!</b>")
		to_chat(world, "<b>Директива 7-12 успешно выполнена, предотвращая распространение блоба.</b>")
	else if(blob_objective.check_completion())
		if(GAMEMODE_IS_BLOB)
			SSticker.mode_result = "blob win - blob took over"
			add_game_logs("Blob mode completed with a blob victory.")
		to_chat(world, span_fontsize3("<br><b>Полная победа блоба!</b>"))
		to_chat(world, "<b>Блоб захватил станцию!</b>")
		to_chat(world, "<b>Вся станция была поглощена блобом.</b>")
	else if(!GLOB.blob_cores.len)
		if(GAMEMODE_IS_BLOB)
			add_game_logs("Blob mode completed with a crew victory.")
			SSticker.mode_result = "blob loss - blob eliminated"
		to_chat(world, span_fontsize3("<br><b>Полная победа персонала станции!</b>"))
		to_chat(world, "<b>Экипаж защитил станцию от блоба!</b>")
		to_chat(world, "<b>Инопланетный организм был истреблен.</b>")
	else
		if(GAMEMODE_IS_BLOB)
			add_game_logs("Blob mode completed with a draw.")
			SSticker.mode_result = "draw - the station was not destroyed, blob is alife "
		to_chat(world, span_fontsize3("<br><b>Ничья!</b>"))
		to_chat(world, "<b>Экипаж эвакуирован!</b>")
		to_chat(world, "<b>Инопланетный организм не был истреблен.</b>")
	to_chat(world, "<b>Целью блобов было:</b>")
	if(blob_objective.check_completion() && (!station_was_nuked || blob_stage == BLOB_STAGE_POST_END))
		to_chat(world, "<br/>[blob_objective.explanation_text] <font color='green'><b>Успех!</b></font>")
		SSblackbox.record_feedback("nested tally", "traitor_objective", 1, list("[blob_objective.type]", "SUCCESS"))
	else
		to_chat(world, "<br/>[blob_objective.explanation_text] <font color='red'>Провал.</font>")
		SSblackbox.record_feedback("nested tally", "traitor_objective", 1, list("[blob_objective.type]", "FAIL"))
	return TRUE


/datum/game_mode/proc/auto_declare_completion_blob()
	var/list/blob_infected = blobs["infected"]
	var/list/blob_offsprings = blobs["offsprings"]
	var/list/minions = blobs["minions"]
	if(blob_infected?.len)
		declare_blob_completion()
		var/list/text = list("<br/><span style='font-size: 2;'><b>Блоб[(blob_infected.len > 1 ? "ами были" : "ом был")]:</b></pan>")

		for(var/datum/mind/blob in blob_infected)
			text += "<br/><b>[blob.key]</b> был <b>[blob.name]</b>"

		if(blob_offsprings?.len)
			text += "<br/><br/><span style='font-size: 2;'><b>Потомк[(blob_offsprings.len > 1 ? "ами блоба были" : "ом блоба был")]:</b></span>"
			for(var/datum/mind/blob in blob_offsprings)
				text += "<br/><b>[blob.key]</b> был <b>[blob.name]</b>"

		if(minions?.len)
			text += "<br/><br/><span style='font-size: 2;'><b>Миньoн[(minions.len > 1 ? "ами были" : "ом был")]:</b></span>"
			for(var/datum/mind/blob in minions)
				text += "<br/><b>[blob.key]</b> был <b>[blob.name]</b>"

		return text.Join("")


/datum/game_mode/proc/end_game()
	if(!SSticker)
		return
	SSticker.current_state = GAME_STATE_FINISHED
