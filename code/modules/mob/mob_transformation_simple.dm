
//This proc is the most basic of the procs. All it does is make a new mob on the same tile and transfer over a few variables.
//Returns the new mob
//Note that this proc does NOT do MMI related stuff!
/mob/proc/change_mob_type(var/new_type = null, var/turf/location = null, var/new_name = null as text, var/delete_old_mob = 0 as num, var/forcekey = 0)

	if(isnewplayer(src))
		to_chat(usr, "<span class='warning'>cannot convert players who have not entered yet.</span>")
		return

	if(!new_type)
		new_type = clean_input("Mob type path:", "Mob type")

	if(istext(new_type))
		new_type = text2path(new_type)

	if( !ispath(new_type) )
		to_chat(usr, "Invalid type path (new_type = [new_type]) in change_mob_type(). Contact a coder.")
		return

	if( new_type == /mob/new_player )
		to_chat(usr, "<span class='warning'>cannot convert into a new_player mob type.</span>")
		return

	var/mob/M
	if(isturf(location))
		M = new new_type( location )
	else
		M = new new_type( src.loc )

	if(!M || !ismob(M))
		to_chat(usr, "Type path is not a mob (new_type = [new_type]) in change_mob_type(). Contact a coder.")
		qdel(M)
		return

	if( istext(new_name) )
		M.name = new_name
		M.real_name = new_name
	else
		M.name = src.name
		M.real_name = src.real_name

	if(src.dna)
		M.dna = src.dna.Clone()

	if((mind && isliving(M)) && !forcekey)
		mind.transfer_to(M)
	else
		M.key = key
		
	SEND_SIGNAL(src, COMSIG_MOB_CHANGED_TYPE, M)
	
	if(delete_old_mob)
		spawn(1)
			qdel(src)
	return M
