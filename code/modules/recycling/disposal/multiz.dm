#define MULTIZ_PIPE_UP 1 ///Defines for determining which way a multiz disposal element should travel
#define MULTIZ_PIPE_DOWN 2 ///Defines for determining which way a multiz disposal element should travel


/obj/structure/disposalpipe/trunk/multiz
	name = "Disposal trunk that goes up"
	icon_state = "pipe-up"
	base_icon_state = "pipe-up"
	var/multiz_dir = MULTIZ_PIPE_UP ///Set the multiz direction of your trunk. 1 = up, 2 = down


/obj/structure/disposalpipe/trunk/multiz/down
	name = "Disposal trunk that goes down"
	icon_state = "pipe-down"
	base_icon_state = "pipe-down"
	multiz_dir = MULTIZ_PIPE_DOWN


/obj/structure/disposalpipe/trunk/multiz/transfer(obj/structure/disposalholder/holder)
	//Since we're a trunk, you can still place a chute / bin over us. If theyve entered from there, treat this as a normal trunk
	if(holder.dir == DOWN)
		return ..()

	//If we for some reason do not have a multiz dir, just like, use the default logic
	if(!multiz_dir)
		return ..()

	//Are we a trunk that goes up? Or down?
	var/turf/target = get_turf(src)
	switch(multiz_dir)
		if(MULTIZ_PIPE_UP)
			target = GET_TURF_ABOVE(target)
		if(MULTIZ_PIPE_DOWN)
			target = GET_TURF_BELOW(target)
	if(!target) //Nothing located.
		return

	var/obj/structure/disposalpipe/trunk/multiz/pipe = locate(/obj/structure/disposalpipe/trunk/multiz) in target
	if(!pipe)
		return
	var/obj/structure/disposalholder/destination = new(pipe) //For future reference, the disposal holder is the thing that carries mobs
	destination.merge(holder) //This takes the contents of H (Our disposal holder that's travelling into us) and puts them into the destination holder
	destination.active = TRUE //Active allows it to process and move
	destination.setDir(DOWN) //This tells the trunk above us NOT to loop it back down to us, or else you get an infinite loop
	destination.start_moving()

#undef MULTIZ_PIPE_UP
#undef MULTIZ_PIPE_DOWN
