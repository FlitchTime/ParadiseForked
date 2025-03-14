/mob/living
	var/last_taste_time
	var/last_taste_text

/mob/living/proc/get_taste_sensitivity()
	return TASTE_SENSITIVITY_NORMAL

/mob/living/carbon/human/get_taste_sensitivity()
	if(dna.species)
		return dna.species.taste_sensitivity
	else
		return TASTE_SENSITIVITY_NORMAL

// non destructively tastes a reagent container
/mob/living/proc/taste(datum/reagents/from)
	if(last_taste_time + 50 < world.time)
		var/taste_sensitivity = get_taste_sensitivity()
		var/text_output = from.generate_taste_message(taste_sensitivity, src)
		// We dont want to spam the same message over and over again at the
		// person. Give it a bit of a buffer.
		if(AmountHallucinate() > 50 SECONDS && prob(25))
			text_output = "вкус "
			text_output += pick("пауков","мечты","кошмаров","будущего","прошлого","победы",\
			"поражения","боли","блаженства","мести","яда","времени","космоса","смерти","жизни","правды","лжи","справедливости","воспоминаний",\
			"сожалений","души","страданий","музыки","шума","крови","голода")
		if(text_output != last_taste_text || last_taste_time + 100 < world.time)
			to_chat(src, span_notice("Вы чувствуете [text_output]."))
			// "something indescribable" -> too many tastes, not enough flavor.

			last_taste_time = world.time
			last_taste_text = text_output
