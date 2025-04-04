// foam and foam precursor

/datum/chemical_reaction/surfactant
	name = "Foam surfactant"
	id = "foam surfactant"
	result = "fluorosurfactant"
	required_reagents = list("fluorine" = 2, "carbon" = 2, "sacid" = 1)
	result_amount = 5
	mix_message = "A head of foam results from the mixture's constant fizzing."

/datum/chemical_reaction/foam
	name = "Foam"
	id = "foam"
	result = null
	required_reagents = list("fluorosurfactant" = 1, "water" = 1)
	result_amount = 2

/datum/chemical_reaction/foam/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	holder.my_atom.visible_message("<span class='warning'>The solution spews out foam!</span>")

	var/datum/effect_system/fluid_spread/foam/s = new()
	s.set_up(amount = created_volume, location = location, carry = holder)
	s.start()
	holder.clear_reagents()

/datum/chemical_reaction/firefighting_foam_liguid
	name = "Firefighting foam liquid"
	id = "firefighting_foam_liquid"
	required_reagents = list("firefighting_foam" = 1, "water" = 1)
	result_amount = 2

/datum/chemical_reaction/firefighting_foam_liguid/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	holder.my_atom.visible_message(span_warning("The solution spews out foam!"))

	var/datum/effect_system/fluid_spread/foam/firefighting/s = new()
	s.set_up(amount = created_volume, location = location)
	s.start()
	holder.clear_reagents()


/datum/chemical_reaction/metalfoam
	name = "Metal Foam"
	id = "metalfoam"
	result = null
	required_reagents = list("aluminum" = 3, "fluorosurfactant" = 1, "sacid" = 1)
	result_amount = 5

/datum/chemical_reaction/metalfoam/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)

	holder.my_atom.visible_message("<span class='warning'>The solution spews out a metalic foam!</span>")

	var/datum/effect_system/fluid_spread/foam/metal/s = new()
	s.set_up(amount = created_volume, location = location)
	s.start()


/datum/chemical_reaction/ironfoam
	name = "Iron Foam"
	id = "ironlfoam"
	result = null
	required_reagents = list("iron" = 3, "fluorosurfactant" = 1, "sacid" = 1)
	result_amount = 5

/datum/chemical_reaction/ironfoam/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)

	holder.my_atom.visible_message("<span class='warning'>The solution spews out a metalic foam!</span>")

	var/datum/effect_system/fluid_spread/foam/metal/iron/s = new()
	s.set_up(amount = created_volume, location = location)
	s.start()

/datum/chemical_reaction/resinfoam
	name = "Resin foam"
	id = "resinfoam"
	result = null
	required_reagents = list("oil" = 3, "fluorosurfactant" = 1, "sacid" = 1)
	result_amount = 5

/datum/chemical_reaction/resinfoam/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)

	holder.my_atom.visible_message(span_warning("The solution spews out a resin foam!"))

	var/datum/effect_system/fluid_spread/foam/metal/resin/s = new()
	s.set_up(amount = created_volume, location = location)
	s.start()

	// Synthesizing these three chemicals is pretty complex in real life, but fuck it, it's just a game!
/datum/chemical_reaction/ammonia
	name = "Ammonia"
	id = "ammonia"
	result = "ammonia"
	required_reagents = list("hydrogen" = 3, "nitrogen" = 1)
	result_amount = 3
	mix_message = "The mixture bubbles, emitting an acrid reek."

/datum/chemical_reaction/diethylamine
	name = "Diethylamine"
	id = "diethylamine"
	result = "diethylamine"
	required_reagents = list ("ammonia" = 1, "ethanol" = 1)
	result_amount = 2
	min_temp = T0C + 100
	mix_message = "A horrible smell pours forth from the mixture."

/datum/chemical_reaction/space_cleaner
	name = "Space cleaner"
	id = "cleaner"
	result = "cleaner"
	required_reagents = list("ammonia" = 1, "water" = 1, "ethanol" = 1)
	result_amount = 3
	mix_message = "Ick, this stuff really stinks. Sure does make the container sparkle though!"

/datum/chemical_reaction/sulfuric_acid
	name = "Sulfuric Acid"
	id = "sacid"
	result = "sacid"
	required_reagents = list("sulfur" = 1, "oxygen" = 1, "hydrogen" = 1)
	result_amount = 2
	mix_message = "The mixture gives off a sharp acidic tang."

/datum/chemical_reaction/plastic_polymers
	name = "plastic polymers"
	id = "plastic_polymers"
	result = null
	required_reagents = list("oil" = 5, "sacid" = 2, "ash" = 3)
	min_temp = T0C + 100
	result_amount = 1

/datum/chemical_reaction/plastic_polymers/on_reaction(datum/reagents/holder, created_volume)
	new /obj/item/stack/sheet/plastic(get_turf(holder.my_atom), created_volume * 10)

/datum/chemical_reaction/lube
	name = "Space Lube"
	id = "lube"
	result = "lube"
	required_reagents = list("water" = 1, "silicon" = 1, "oxygen" = 1)
	result_amount = 3
	mix_message = "The substance turns a striking cyan and becomes oily."

/datum/chemical_reaction/holy_water
	name = "Holy Water"
	id = "holywater"
	result = "holywater"
	required_reagents = list("water" = 1, "mercury" = 1, "wine" = 1)
	result_amount = 3
	mix_message = "The water somehow seems purified. Or maybe defiled."

/datum/chemical_reaction/drying_agent
	name = "Drying agent"
	id = "drying_agent"
	result = "drying_agent"
	required_reagents = list("plasma" = 2, "ethanol" = 1, "sodium" = 1)
	result_amount = 3

/datum/chemical_reaction/saltpetre
	name = "saltpetre"
	id = "saltpetre"
	result = "saltpetre"
	required_reagents = list("potassium" = 1, "nitrogen" = 1, "oxygen" = 3)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/fuse.ogg'

/datum/chemical_reaction/acetone
	name = "acetone"
	id = "acetone"
	result = "acetone"
	required_reagents = list("oil" = 1, "fuel" = 1, "oxygen" = 1)
	result_amount = 3
	mix_message = "The smell of paint thinner assaults you as the solution bubbles."

/datum/chemical_reaction/carpet
	name = "carpet"
	id = "carpet"
	result = "carpet"
	required_reagents = list("fungus" = 1, "blood" = 1)
	result_amount = 2
	mix_message = "The substance turns thick and stiff, yet soft."


/datum/chemical_reaction/oil
	name = "Oil"
	id = "oil"
	result = "oil"
	required_reagents = list("fuel" = 1, "carbon" = 1, "hydrogen" = 1)
	result_amount = 3
	mix_message = "An iridescent black chemical forms in the container."

/datum/chemical_reaction/phenol
	name = "phenol"
	id = "phenol"
	result = "phenol"
	required_reagents = list("water" = 1, "chlorine" = 1, "oil" = 1)
	result_amount = 3
	mix_message = "The mixture bubbles and gives off an unpleasant medicinal odor."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/colorful_reagent
	name = "colorful_reagent"
	id = "colorful_reagent"
	result = "colorful_reagent"
	required_reagents = list("plasma" = 1, "radium" = 1, "space_drugs" = 1, "cryoxadone" = 1, "triple_citrus" = 1, "stabilizing_agent" = 1)
	result_amount = 6
	mix_message = "The substance flashes multiple colors and emits the smell of a pocket protector."

/datum/chemical_reaction/corgium
	name = "corgium"
	id = "corgium"
	result = null
	required_reagents = list("nutriment" = 1, "colorful_reagent" = 1, "strange_reagent" = 1, "blood" = 1)
	result_amount = 3
	min_temp = T0C + 100

/datum/chemical_reaction/corgium/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /mob/living/simple_animal/pet/dog/corgi(location)
	..()

/datum/chemical_reaction/flaptonium
	name = "Flaptonium"
	id = "flaptonium"
	result = null
	required_reagents = list("egg" = 1, "colorful_reagent" = 1, "chicken_soup" = 1, "strange_reagent" = 1, "blood" = 1)
	result_amount = 5
	min_temp = T0C + 100
	mix_message = "The substance turns an airy sky-blue and foams up into a new shape."

/datum/chemical_reaction/flaptonium/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /mob/living/simple_animal/parrot(location)
	..()

/datum/chemical_reaction/hair_dye
	name = "hair_dye"
	id = "hair_dye"
	result = "hair_dye"
	required_reagents = list("colorful_reagent" = 1, "hairgrownium" = 1)
	result_amount = 2

/datum/chemical_reaction/hairgrownium
	name = "hairgrownium"
	id = "hairgrownium"
	result = "hairgrownium"
	required_reagents = list("carpet" = 1, "synthflesh" = 1, "ephedrine" = 1)
	result_amount = 3
	mix_message = "The liquid becomes slightly hairy."

/datum/chemical_reaction/super_hairgrownium
	name = "Super Hairgrownium"
	id = "super_hairgrownium"
	result = "super_hairgrownium"
	required_reagents = list("iron" = 1, "methamphetamine" = 1, "hairgrownium" = 1)
	result_amount = 3
	mix_message = "The liquid becomes amazingly furry and smells peculiar."

/datum/chemical_reaction/soapification_apple
	name = "Soapification_apple"
	id = "soapification_apple"
	result = null
	required_reagents = list("liquidgibs" = 10, "lye"  = 10, "applejuice" = 10) // requires two scooped gib tiles
	min_temp = T0C + 100
	result_amount = 1

/datum/chemical_reaction/soapification_apple/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/soap/homemade_apple(location)

/datum/chemical_reaction/soapification_potato
	name = "Soapification"
	id = "soapification"
	result = null
	required_reagents = list("liquidgibs" = 10, "lye"  = 10, "potato" = 10) // requires two scooped gib tiles
	min_temp = T0C + 100
	result_amount = 1

/datum/chemical_reaction/soapification_potato/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/soap/homemade_potato(location)

/datum/chemical_reaction/soapification_pumpkin
	name = "Soapification"
	id = "soapification"
	result = null
	required_reagents = list("liquidgibs" = 10, "lye"  = 10, "pumpkinjuice" = 10) // requires two scooped gib tiles
	min_temp = T0C + 100
	result_amount = 1

/datum/chemical_reaction/soapification_pumpkin/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/soap/homemade_pumpkin(location)

/datum/chemical_reaction/soapification_silver
	name = "Soapification"
	id = "soapification"
	result = null
	required_reagents = list("liquidgibs" = 10, "lye"  = 10, "silver" = 10) // requires two scooped gib tiles
	min_temp = T0C + 100
	result_amount = 1

/datum/chemical_reaction/soapification_silver/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/soap/homemade_silver(location)

/datum/chemical_reaction/soapification_tomato
	name = "Soapification"
	id = "soapification"
	result = null
	required_reagents = list("liquidgibs" = 10, "lye"  = 10, "tomatojuice" = 10) // requires two scooped gib tiles
	min_temp = T0C + 100
	result_amount = 1

/datum/chemical_reaction/soapification_tomato/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/soap/homemade_tomato(location)

/datum/chemical_reaction/soapification_uran
	name = "Soapification"
	id = "soapification"
	result = null
	required_reagents = list("liquidgibs" = 10, "lye"  = 10, "uranium" = 10) // requires two scooped gib tiles
	min_temp = T0C + 100
	result_amount = 1

/datum/chemical_reaction/soapification_uran/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/soap/homemade_uran(location)

/datum/chemical_reaction/soapification_watermelon
	name = "Soapification"
	id = "soapification"
	result = null
	required_reagents = list("liquidgibs" = 10, "lye"  = 10, "watermelonjuice" = 10) // requires two scooped gib tiles
	min_temp = T0C + 100
	result_amount = 1

/datum/chemical_reaction/soapification_watermelon/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/soap/homemade_watermelon(location)

/datum/chemical_reaction/soapification_whiskey
	name = "Soapification"
	id = "soapification"
	result = null
	required_reagents = list("liquidgibs" = 10, "lye"  = 10, "whiskey" = 10) // requires two scooped gib tiles
	min_temp = T0C + 100
	result_amount = 1

/datum/chemical_reaction/soapification_whiskey/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/soap/homemade_whiskey(location)

/datum/chemical_reaction/soapification_banana
	name = "Soapification"
	id = "soapification"
	result = null
	required_reagents = list("liquidgibs" = 10, "lye"  = 10, "banana" = 10) // requires two scooped gib tiles
	min_temp = T0C + 100
	result_amount = 1

/datum/chemical_reaction/soapification_banana/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/soap/homemade_banana(location)

/datum/chemical_reaction/soapification_beer
	name = "Soapification"
	id = "soapification"
	result = null
	required_reagents = list("liquidgibs" = 10, "lye"  = 10, "beer" = 10) // requires two scooped gib tiles
	min_temp = T0C + 100
	result_amount = 1

/datum/chemical_reaction/soapification_beer/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/soap/homemade_beer(location)

/datum/chemical_reaction/soapification_berry
	name = "Soapification"
	id = "soapification"
	result = null
	required_reagents = list("liquidgibs" = 10, "lye"  = 10, "berryjuice" = 10) // requires two scooped gib tiles
	min_temp = T0C + 100
	result_amount = 1

/datum/chemical_reaction/soapification_berry/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/soap/homemade_berry(location)

/datum/chemical_reaction/soapification_carrot
	name = "Soapification"
	id = "soapification"
	result = null
	required_reagents = list("liquidgibs" = 10, "lye"  = 10, "carrotjuice" = 10) // requires two scooped gib tiles
	min_temp = T0C + 100
	result_amount = 1

/datum/chemical_reaction/soapification_carrot/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/soap/homemade_carrot(location)

/datum/chemical_reaction/soapification_chocolate
	name = "Soapification"
	id = "soapification"
	result = null
	required_reagents = list("liquidgibs" = 10, "lye"  = 10, "cocoa" = 10) // requires two scooped gib tiles
	min_temp = T0C + 100
	result_amount = 1

/datum/chemical_reaction/soapification_chocolate/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/soap/homemade_chocolate(location)

/datum/chemical_reaction/soapification_cola
	name = "Soapification"
	id = "soapification"
	result = null
	required_reagents = list("liquidgibs" = 10, "lye"  = 10, "cola" = 10) // requires two scooped gib tiles
	min_temp = T0C + 100
	result_amount = 1

/datum/chemical_reaction/soapification_cola/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/soap/homemade_cola(location)

/datum/chemical_reaction/soapification_corn
	name = "Soapification"
	id = "soapification"
	result = null
	required_reagents = list("liquidgibs" = 10, "lye"  = 10, "corn_starch" = 10) // requires two scooped gib tiles
	min_temp = T0C + 100
	result_amount = 1

/datum/chemical_reaction/soapification_corn/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/soap/homemade_corn(location)

/datum/chemical_reaction/soapification_golden
	name = "Soapification"
	id = "soapification"
	result = null
	required_reagents = list("liquidgibs" = 10, "lye"  = 10, "gold" = 10) // requires two scooped gib tiles
	min_temp = T0C + 100
	result_amount = 1

/datum/chemical_reaction/soapification_golden/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/soap/homemade_golden(location)

/datum/chemical_reaction/soapification_grape
	name = "Soapification"
	id = "soapification"
	result = null
	required_reagents = list("liquidgibs" = 10, "lye"  = 10, "grapejuice" = 10) // requires two scooped gib tiles
	min_temp = T0C + 100
	result_amount = 1

/datum/chemical_reaction/soapification_grape/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/soap/homemade_grape(location)

/datum/chemical_reaction/soapification_lemon
	name = "Soapification"
	id = "soapification"
	result = null
	required_reagents = list("liquidgibs" = 10, "lye"  = 10, "lemonjuice" = 10) // requires two scooped gib tiles
	min_temp = T0C + 100
	result_amount = 1

/datum/chemical_reaction/soapification_lemon/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/soap/homemade_lemon(location)

/datum/chemical_reaction/soapification_lime
	name = "Soapification"
	id = "soapification"
	result = null
	required_reagents = list("liquidgibs" = 10, "lye"  = 10, "limejuice" = 10) // requires two scooped gib tiles
	min_temp = T0C + 100
	result_amount = 1

/datum/chemical_reaction/soapification_lime/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/soap/homemade_lime(location)

/datum/chemical_reaction/soapification_milk
	name = "Soapification"
	id = "soapification"
	result = null
	required_reagents = list("liquidgibs" = 10, "lye"  = 10, "milk" = 10) // requires two scooped gib tiles
	min_temp = T0C + 100
	result_amount = 1

/datum/chemical_reaction/soapification_milk/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/soap/homemade_milk(location)

/datum/chemical_reaction/soapification_orange
	name = "Soapification"
	id = "soapification"
	result = null
	required_reagents = list("liquidgibs" = 10, "lye"  = 10, "orangejuice" = 10) // requires two scooped gib tiles
	min_temp = T0C + 100
	result_amount = 1

/datum/chemical_reaction/soapification_orange/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/soap/homemade_orange(location)

/datum/chemical_reaction/soapification_pineapple
	name = "Soapification"
	id = "soapification"
	result = null
	required_reagents = list("liquidgibs" = 10, "lye"  = 10, "pineapplejuice" = 10) // requires two scooped gib tiles
	min_temp = T0C + 100
	result_amount = 1

/datum/chemical_reaction/soapification_pineapple/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/soap/homemade_pineapple(location)

/datum/chemical_reaction/soapification
	name = "Soapification"
	id = "soapification"
	result = null
	required_reagents = list("liquidgibs" = 10, "lye"  = 10) // requires two scooped gib tiles
	min_temp = T0C + 100
	result_amount = 1

/datum/chemical_reaction/soapification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/soap/homemade(location)

/datum/chemical_reaction/candlefication
	name = "Candlefication"
	id = "candlefication"
	result = null
	required_reagents = list("liquidgibs" = 5, "oxygen"  = 5) //
	min_temp = T0C + 100
	result_amount = 1

/datum/chemical_reaction/candlefication/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/candle(location)

/datum/chemical_reaction/meatification
	name = "Meatification"
	id = "meatification"
	result = null
	required_reagents = list("liquidgibs" = 10, "nutriment" = 10, "carbon" = 10)
	result_amount = 1

/datum/chemical_reaction/meatification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/reagent_containers/food/snacks/meat/slab/meatproduct(location)

/datum/chemical_reaction/lye
	name = "lye"
	id = "lye"
	result = "lye"
	required_reagents = list("sodium" = 1, "hydrogen" = 1, "oxygen" = 1)
	result_amount = 3

/datum/chemical_reaction/love
	name = "pure love"
	id = "love"
	result = "love"
	required_reagents = list("hugs" = 1, "chocolate" = 1)
	result_amount = 2
	mix_message = "The substance gives off a lovely scent!"

/datum/chemical_reaction/jestosterone
	name = "Jestosterone"
	id = "jestosterone"
	result = "jestosterone"
	required_reagents = list("blood" = 1, "sodiumchloride" = 1, "banana" = 1, "lube" = 1, "space_drugs" = 1) //Or one freshly-squeezed clown
	min_temp = T0C + 100
	result_amount = 5
	mix_message = "The substance quickly shifts colour, cycling from red, to yellow, to green, to blue, and finally settles at a vibrant fuchsia."

/datum/chemical_reaction/jestosterone/on_reaction(datum/reagents/holder, created_volume)
	playsound(get_turf(holder.my_atom), 'sound/items/bikehorn.ogg', 50, 1)

/datum/chemical_reaction/royal_bee_jelly
	name = "royal bee jelly"
	id = "royal_bee_jelly"
	result = "royal_bee_jelly"
	required_reagents = list("mutagen" = 10, "honey" = 40)
	result_amount = 5

/datum/chemical_reaction/glycerol
	name = "Glycerol"
	id = "glycerol"
	result = "glycerol"
	required_reagents = list("cornoil" = 3, "sacid" = 1)
	result_amount = 1

/datum/chemical_reaction/condensedcapsaicin
	name = "Condensed Capsaicin"
	id = "condensedcapsaicin"
	result = "condensedcapsaicin"
	required_reagents = list("capsaicin" = 2)
	required_catalysts = list("plasma" = 5)
	result_amount = 1

/datum/chemical_reaction/sodiumchloride
	name = "Sodium Chloride"
	id = "sodiumchloride"
	result = "sodiumchloride"
	required_reagents = list("sodium" = 1, "chlorine" = 1, "water" = 1)
	result_amount = 3
	mix_message = "The solution crystallizes with a brief flare of light."

/datum/chemical_reaction/acetaldehyde
	name = "Acetaldehyde"
	id = "acetaldehyde"
	result = "acetaldehyde"
	required_reagents = list("chromium" = 1, "oxygen" = 1, "copper" = 1, "ethanol" = 1)
	result_amount = 3
	min_temp = T0C + 275
	mix_message = "It smells like a bad hangover in here."

/datum/chemical_reaction/acetic_acid
	name = "Acetic Acid"
	id = "acetic_acid"
	result = "acetic_acid"
	required_reagents = list("acetaldehyde" = 1, "oxygen" = 1, "nitrogen" = 4)
	result_amount = 3
	mix_message = "It smells like vinegar and a bad hangover in here."

/datum/chemical_reaction/ice
	name = "Ice"
	id = "ice"
	result = "ice"
	required_reagents = list("water" = 1)
	result_amount = 1
	max_temp = T0C
	mix_message = "Ice forms as the water freezes."
	mix_sound = null

/datum/chemical_reaction/water
	name = "Water"
	id = "water"
	result = "water"
	required_reagents = list("ice" = 1)
	result_amount = 1
	min_temp = T0C + 29 // In Space.....ice melts at 82F...don't ask
	mix_message = "Water pools as the ice melts."
	mix_sound = null

/datum/chemical_reaction/virus_food
	name = "Virus Food"
	id = "virusfood"
	result = "virusfood"
	required_reagents = list("water" = 1, "milk" = 1, "oxygen" = 1)
	result_amount = 3

/datum/chemical_reaction/virus_food_mutagen
	name = "mutagenic agar"
	id = "mutagenvirusfood"
	result = "mutagenvirusfood"
	required_reagents = list("mutagen" = 1, "virusfood" = 1)
	result_amount = 1

/datum/chemical_reaction/virus_food_diphenhydramine
	name = "virus rations"
	id = "diphenhydraminevirusfood"
	result = "diphenhydraminevirusfood"
	required_reagents = list("diphenhydramine" = 1, "virusfood" = 1)
	result_amount = 1

/datum/chemical_reaction/virus_food_plasma
	name = "virus plasma"
	id = "plasmavirusfood"
	result = "plasmavirusfood"
	required_reagents = list("plasma_dust" = 1, "virusfood" = 1)
	result_amount = 1

/datum/chemical_reaction/virus_food_plasma_diphenhydramine
	name = "weakened virus plasma"
	id = "weakplasmavirusfood"
	result = "weakplasmavirusfood"
	required_reagents = list("diphenhydramine" = 1, "plasmavirusfood" = 1)
	result_amount = 2

/datum/chemical_reaction/virus_food_mutagen_sugar
	name = "sucrose agar"
	id = "sugarvirusfood"
	result = "sugarvirusfood"
	required_reagents = list("sugar" = 1, "mutagenvirusfood" = 1)
	result_amount = 2

/datum/chemical_reaction/virus_food_mutagen_salineglucose
	name = "sucrose agar"
	id = "salineglucosevirusfood"
	result = "sugarvirusfood"
	required_reagents = list("salglu_solution" = 1, "mutagenvirusfood" = 1)
	result_amount = 2

/datum/chemical_reaction/mix_virus
	name = "Mix Virus"
	id = "mixvirus"
	required_reagents = list("virusfood" = 1)
	required_catalysts = list("blood" = 1)
	count_of_catalysts = 1
	var/level_min = 0
	var/level_max = 2

/datum/chemical_reaction/mix_virus/on_reaction(datum/reagents/holder, created_volume)
	for(var/datum/reagent/R in holder.reagent_list)
		if(R.data && R.data["diseases"])
			var/datum/disease/virus/advance/D = locate(/datum/disease/virus/advance) in R.data["diseases"]
			if(D)
				D.Evolve(level_min, level_max)
				return


/datum/chemical_reaction/mix_virus/mix_virus_2
	name = "Mix Virus 2"
	id = "mixvirus2"
	required_reagents = list("mutagen" = 1)
	level_min = 2
	level_max = 4

/datum/chemical_reaction/mix_virus/mix_virus_3
	name = "Mix Virus 3"
	id = "mixvirus3"
	required_reagents = list("plasma_dust" = 1)
	level_min = 4
	level_max = 6

/datum/chemical_reaction/mix_virus/mix_virus_4
	name = "Mix Virus 4"
	id = "mixvirus4"
	required_reagents = list("uranium" = 1)
	level_min = 5
	level_max = 6

/datum/chemical_reaction/mix_virus/mix_virus_5
	name = "Mix Virus 5"
	id = "mixvirus5"
	required_reagents = list("mutagenvirusfood" = 1)
	level_min = 3
	level_max = 3

/datum/chemical_reaction/mix_virus/mix_virus_6
	name = "Mix Virus 6"
	id = "mixvirus6"
	required_reagents = list("sugarvirusfood" = 1)
	level_min = 4
	level_max = 4

/datum/chemical_reaction/mix_virus/mix_virus_7
	name = "Mix Virus 7"
	id = "mixvirus7"
	required_reagents = list("weakplasmavirusfood" = 1)
	level_min = 5
	level_max = 5

/datum/chemical_reaction/mix_virus/mix_virus_8
	name = "Mix Virus 8"
	id = "mixvirus8"
	required_reagents = list("plasmavirusfood" = 1)
	level_min = 6
	level_max = 6

/datum/chemical_reaction/mix_virus/mix_virus_9
	name = "Mix Virus 9"
	id = "mixvirus9"
	required_reagents = list("diphenhydraminevirusfood" = 1)
	level_min = 1
	level_max = 1

/datum/chemical_reaction/mix_virus/rem_virus
	name = "Devolve Virus"
	id = "remvirus"
	required_reagents = list("diphenhydramine" = 1)
	required_catalysts = list("blood" = 1)
	count_of_catalysts = 1

/datum/chemical_reaction/mix_virus/rem_virus/on_reaction(datum/reagents/holder, created_volume)
	for(var/datum/reagent/R in holder.reagent_list)
		if(R.data && R.data["diseases"])
			var/datum/disease/virus/advance/D = locate(/datum/disease/virus/advance) in R.data["diseases"]
			if(D)
				D.Devolve()
				return
