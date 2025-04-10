/obj/item/ammo_casing/magic
	name = "magic casing"
	desc = "I didn't even know magic needed ammo..."
	projectile_type = /obj/projectile/magic
	muzzle_flash_color = COLOR_BLUE_GRAY
	muzzle_flash_effect = /obj/effect/temp_visual/target_angled/muzzle_flash/magic
	leaves_residue = 0

/obj/item/ammo_casing/magic/change
	projectile_type = /obj/projectile/magic/change

/obj/item/ammo_casing/magic/animate
	projectile_type = /obj/projectile/magic/animate

/obj/item/ammo_casing/magic/heal
	projectile_type = /obj/projectile/magic/resurrection
	harmful = FALSE

/obj/item/ammo_casing/magic/death
	projectile_type = /obj/projectile/magic/death

/obj/item/ammo_casing/magic/teleport
	projectile_type = /obj/projectile/magic/teleport
	harmful = FALSE

/obj/item/ammo_casing/magic/door
	projectile_type = /obj/projectile/magic/door
	harmful = FALSE

/obj/item/ammo_casing/magic/fireball
	projectile_type = /obj/projectile/magic/fireball

/obj/item/ammo_casing/magic/chaos
	projectile_type = /obj/projectile/magic

/obj/item/ammo_casing/magic/spellblade
	projectile_type = /obj/projectile/magic/spellblade

/obj/item/ammo_casing/magic/slipping
	projectile_type = /obj/projectile/magic/slipping

/obj/item/ammo_casing/magic/chaos/newshot()
	projectile_type = pick(typesof(/obj/projectile/magic))
	..()

/obj/item/ammo_casing/magic/arcane_barrage
	projectile_type = /obj/projectile/magic/arcane_barrage

/obj/item/ammo_casing/magic/forcebolt
	projectile_type = /obj/projectile/forcebolt

/obj/item/ammo_casing/syringegun
	name = "syringe gun spring"
	desc = "A high-power spring that throws syringes."
	projectile_type = null
	muzzle_flash_effect = null

/obj/item/ammo_casing/energy/c3dbullet
	projectile_type = /obj/projectile/bullet/midbullet3
	select_name = "spraydown"
	fire_sound = 'sound/weapons/gunshots/1mg2.ogg'
	e_cost = 20
