/obj/projectile/forcebolt
	name = "force bolt"
	icon = 'icons/obj/weapons/projectiles.dmi'
	icon_state = "ice_1"
	damage = 20
	flag = "energy"

/obj/projectile/forcebolt/strong
	name = "force bolt"

/obj/projectile/forcebolt/on_hit(var/atom/target, var/blocked = 0)
	. = ..()
	if(blocked < 100)
		var/obj/T = target
		var/throwdir = get_dir(firer,target)
		T.throw_at(get_edge_target_turf(target, throwdir),10,10)
