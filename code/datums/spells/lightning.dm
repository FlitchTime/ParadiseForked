/obj/effect/proc_holder/spell/charge_up/bounce/lightning
	name = "Lightning Bolt"
	desc = "Throws a lightning bolt at your enemies. Classic. When clicked will start to charge in power. Then click on a mob to send the bolt before it overloads with power."
	base_cooldown = 30 SECONDS
	cooldown_min = 3 SECONDS
	clothes_req = TRUE
	invocation = "UN'LTD P'WAH!"
	invocation_type = "shout"
	action_icon_state = "lightning"
	charge_sound = new /sound('sound/magic/lightning_chargeup.ogg', channel = 7)
	max_charge_time = 10 SECONDS
	stop_charging_text = "You stop charging the lightning around you."
	stop_charging_fail_text = "The lightning around you is too strong to stop now!"
	start_charging_text = "You start gathering lightning around you."
	bounce_hit_sound = 'sound/magic/lightningshock.ogg'
	var/damaging = TRUE
	var/energy_divisor = 2


/obj/effect/proc_holder/spell/charge_up/bounce/lightning/lightnian
	clothes_req = FALSE
	invocation_type = "none"
	damaging = FALSE


/obj/effect/proc_holder/spell/charge_up/bounce/lightning/guardian
	name = "Малая молния"
	desc = "Копит в себе заряд электричества, поражающий всех врагов. Чем больше зарядка, тем выше урон и дальность. Не так силен как оригинал, но все ещё опасен. После выпуска молнии имеет перезарядку в 30 секунд."
	clothes_req = FALSE
	invocation = "За С+инд+ик+ат!"
	energy_divisor = 4
	human_req = FALSE


/obj/effect/proc_holder/spell/charge_up/bounce/lightning/New()
	..()
	charge_up_overlay = image(icon = 'icons/effects/effects.dmi', icon_state = "electricity", layer = EFFECTS_LAYER)


/obj/effect/proc_holder/spell/charge_up/bounce/lightning/get_bounce_energy()
	if(damaging)
		return max(15, get_energy_charge() / energy_divisor)
	return 0


/obj/effect/proc_holder/spell/charge_up/bounce/lightning/get_bounce_amount()
	if(damaging)
		return 5
	return round(get_energy_charge() / 20)


/obj/effect/proc_holder/spell/charge_up/bounce/lightning/create_beam(mob/origin, mob/target)
	origin.Beam(target, icon_state = "lightning[rand(1, 12)]", icon = 'icons/effects/effects.dmi', time = 0.5 SECONDS)


/obj/effect/proc_holder/spell/charge_up/bounce/lightning/apply_bounce_effect(mob/origin, mob/living/target, energy, mob/user)
	if(HAS_TRAIT(target, TRAIT_SHOCKIMMUNE))
		return

	if(damaging)
		target.electrocute_act(energy, "молнии", flags = SHOCK_NOGLOVES)
	else
		target.AdjustJitter(2000 SECONDS) //High numbers for violent convulsions
		target.AdjustStuttering(4 SECONDS)
		target.Slowed(6 SECONDS)
		addtimer(CALLBACK(target, TYPE_PROC_REF(/mob/living, AdjustJitter), -2000 SECONDS, 10), 2 SECONDS) //Still jittery, but vastly less

