/mob/living/Logout()
	update_pipe_vision()
	update_z(null)
	if(ranged_ability && client)
		ranged_ability.remove_mousepointer(client)
	..()
	if(mind)
		if(!key) //key and mind have become seperated. I believe this is for when a staff member aghosts.
			mind.active = FALSE	//This is to stop say, a mind.transfer_to call on a corpse causing a ghost to re-enter its body.
		if(mind.active)
			last_logout = world.time

	set_SSD(TRUE)

