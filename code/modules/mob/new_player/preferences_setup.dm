/datum/preferences
	//The mob should have a gender you want before running this proc. Will run fine without H
/datum/preferences/proc/random_character(gender_override)
	var/datum/species/S = GLOB.all_species[species]
	if(!istype(S)) //The species was invalid. Set the species to the default, fetch the datum for that species and generate a random character.
		species = initial(species)
		S = GLOB.all_species[species]
	var/datum/robolimb/robohead

	if(S?.bodyflags & ALL_RPARTS)
		var/head_model = "[!rlimb_data["head"] ? "Morpheus Cyberkinetics" : rlimb_data["head"]]"
		robohead = GLOB.all_robolimbs[head_model]
	if(gender_override)
		gender = gender_override
	else
		gender = pick(MALE, FEMALE)
	underwear = random_underwear(gender, species)
	undershirt = random_undershirt(gender, species)
	socks = random_socks(gender, species)
	if(length(GLOB.body_accessory_by_species[species]))
		body_accessory = random_body_accessory(species, S.optional_body_accessory)
	if(S?.bodyflags & (HAS_SKIN_TONE|HAS_ICON_SKIN_TONE))
		s_tone = random_skin_tone(species)
	h_style = random_hair_style(gender, S, robohead)
	f_style = random_facial_hair_style(gender, species, robohead)
	if(species in list(SPECIES_HUMAN, SPECIES_UNATHI, SPECIES_TAJARAN, SPECIES_SKRELL, SPECIES_MACNINEPERSON, SPECIES_WRYN, SPECIES_VULPKANIN, SPECIES_VOX))
		randomize_hair_color("hair")
		randomize_hair_color("facial")
	if(S?.bodyflags & HAS_HEAD_ACCESSORY)
		ha_style = random_head_accessory(species)
		hacc_colour = randomize_skin_color(1)
	if(S?.bodyflags & HAS_HEAD_MARKINGS)
		m_styles["head"] = random_marking_style("head", species, robohead, null, alt_head)
		m_colours["head"] = randomize_skin_color(1)
	if(S?.bodyflags & HAS_BODY_MARKINGS)
		m_styles["body"] = random_marking_style("body", species, gender = src.gender)
		m_colours["body"] = randomize_skin_color(1)
	if(S?.bodyflags & HAS_TAIL_MARKINGS) //Species with tail markings.
		m_styles["tail"] = random_marking_style("tail", species, null, body_accessory)
		m_colours["tail"] = randomize_skin_color(1)
	if(!(S?.bodyflags & ALL_RPARTS))
		randomize_eyes_color()
	if(S?.bodyflags & HAS_SKIN_COLOR && !(S?.bodyflags & HAS_ICON_SKIN_TONE))
		randomize_skin_color()
	backbag = 2
	age = get_rand_age(S)


/datum/preferences/proc/randomize_hair_color(var/target = "hair")
	if(prob (75) && target == "facial") // Chance to inherit hair color
		f_colour = h_colour
		return

	var/red
	var/green
	var/blue

	var/col = pick ("blonde", "black", "chestnut", "copper", "brown", "wheat", "old", "punk")
	switch(col)
		if("blonde")
			red = 255
			green = 255
			blue = 0
		if("black")
			red = 0
			green = 0
			blue = 0
		if("chestnut")
			red = 153
			green = 102
			blue = 51
		if("copper")
			red = 255
			green = 153
			blue = 0
		if("brown")
			red = 102
			green = 51
			blue = 0
		if("wheat")
			red = 255
			green = 255
			blue = 153
		if("old")
			red = rand (100, 255)
			green = red
			blue = red
		if("punk")
			red = rand (0, 255)
			green = rand (0, 255)
			blue = rand (0, 255)

	red = max(min(red + rand (-25, 25), 255), 0)
	green = max(min(green + rand (-25, 25), 255), 0)
	blue = max(min(blue + rand (-25, 25), 255), 0)

	switch(target)
		if("hair")
			h_colour = rgb(red, green, blue)
		if("facial")
			f_colour = rgb(red, green, blue)

/datum/preferences/proc/randomize_eyes_color()
	var/red
	var/green
	var/blue

	var/col = pick ("black", "grey", "brown", "chestnut", "blue", "lightblue", "green", "albino")
	switch(col)
		if("black")
			red = 0
			green = 0
			blue = 0
		if("grey")
			red = rand (100, 200)
			green = red
			blue = red
		if("brown")
			red = 102
			green = 51
			blue = 0
		if("chestnut")
			red = 153
			green = 102
			blue = 0
		if("blue")
			red = 51
			green = 102
			blue = 204
		if("lightblue")
			red = 102
			green = 204
			blue = 255
		if("green")
			red = 0
			green = 102
			blue = 0
		if("albino")
			red = rand (200, 255)
			green = rand (0, 150)
			blue = rand (0, 150)

	red = max(min(red + rand (-25, 25), 255), 0)
	green = max(min(green + rand (-25, 25), 255), 0)
	blue = max(min(blue + rand (-25, 25), 255), 0)

	e_colour = rgb(red, green, blue)

/datum/preferences/proc/randomize_skin_color(var/pass_on)
	var/red
	var/green
	var/blue

	var/col = pick ("black", "grey", "brown", "chestnut", "blue", "lightblue", "green", "albino")
	switch(col)
		if("black")
			red = 0
			green = 0
			blue = 0
		if("grey")
			red = rand (100, 200)
			green = red
			blue = red
		if("brown")
			red = 102
			green = 51
			blue = 0
		if("chestnut")
			red = 153
			green = 102
			blue = 0
		if("blue")
			red = 51
			green = 102
			blue = 204
		if("lightblue")
			red = 102
			green = 204
			blue = 255
		if("green")
			red = 0
			green = 102
			blue = 0
		if("albino")
			red = rand (200, 255)
			green = rand (0, 150)
			blue = rand (0, 150)

	red = max(min(red + rand (-25, 25), 255), 0)
	green = max(min(green + rand (-25, 25), 255), 0)
	blue = max(min(blue + rand (-25, 25), 255), 0)

	if(pass_on)
		return rgb(red, green, blue)
	else
		s_colour = rgb(red, green, blue)

/datum/preferences/proc/blend_backpack(var/icon/clothes_s,var/backbag,var/satchel,var/backpack="backpack")
	switch(backbag)
		if(2)
			clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', backpack), ICON_OVERLAY)
		if(3)
			clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', satchel), ICON_OVERLAY)
		if(4)
			clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
	return clothes_s

#define ICON_SHIFT_XY(I, X, Y)\
	if(X)\
		I.Shift(EAST, X);\
	if(Y)\
		I.Shift(NORTH, Y);\

/datum/preferences/proc/update_preview_icon(for_observer = FALSE)	// seriously. This is horrendous.
	qdel(preview_icon_front)
	qdel(preview_icon_side)
	qdel(preview_icon)

	var/gender_suffix = gender == FEMALE ? "f" : "m"
	var/icon/icobase
	var/datum/species/current_species = GLOB.all_species[species]

	//Icon-based species colour.
	var/coloured_tail
	if(current_species)
		if(current_species.bodyflags & HAS_ICON_SKIN_TONE) //Handling species-specific icon-based skin tones by flagged race.
			var/mob/living/carbon/human/H = new

			if(!H.dna)
				H.dna = new

			H.dna.species = current_species
			H.s_tone = s_tone
			H.dna.species.updatespeciescolor(H, 0) //The mob's species wasn't set, so it's almost certainly different than the character's species at the moment. Thus, we need to be owner-insensitive.

			var/obj/item/organ/external/chest/C = H.get_organ(BODY_ZONE_CHEST)
			icobase = C.icobase ? C.icobase : C.dna.species.icobase
			if(H.dna.species.bodyflags & HAS_TAIL)
				coloured_tail = H.tail ? H.tail : H.dna.species.tail

			qdel(H)
		else
			icobase = current_species.icobase
	else
		icobase = 'icons/mob/human_races/r_human.dmi'

	preview_icon = new /icon(icobase, "torso_[gender_suffix]")
	preview_icon.Blend(new /icon(icobase, "groin_[gender_suffix]"), ICON_OVERLAY)
	var/head = "head"
	if(alt_head && current_species.bodyflags & HAS_ALT_HEADS)
		var/datum/sprite_accessory/alt_heads/H = GLOB.alt_heads_list[alt_head]
		if(H.icon_state)
			head = H.icon_state
	preview_icon.Blend(new /icon(icobase, "[head]_[gender_suffix]"), ICON_OVERLAY)
	var/list/check_list = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_PRECISE_GROIN,
		BODY_ZONE_HEAD,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG,
		BODY_ZONE_PRECISE_L_HAND,
		BODY_ZONE_PRECISE_R_HAND,
		BODY_ZONE_PRECISE_L_FOOT,
		BODY_ZONE_PRECISE_R_FOOT,
	)
	for(var/limb_zone in check_list)
		if(organ_data[limb_zone] == "amputated")
			continue
		if(organ_data[limb_zone] == "cyborg")
			var/datum/robolimb/R
			if(rlimb_data[limb_zone])
				R = GLOB.all_robolimbs[rlimb_data[limb_zone]]
			if(!R)
				R = GLOB.basic_robolimb
			if(limb_zone == BODY_ZONE_CHEST)
				limb_zone = "torso"
			preview_icon.Blend(icon(R.icon, "[limb_zone]"), ICON_OVERLAY) // This doesn't check gendered_icon. Not an issue while only limbs can be robotic.
			continue
		preview_icon.Blend(new /icon(icobase, "[limb_zone]"), ICON_OVERLAY)

	// Skin color
	if(current_species && (current_species.bodyflags & HAS_SKIN_COLOR) && !(current_species.bodyflags & HAS_ICON_SKIN_TONE))
		preview_icon.Blend(s_colour, ICON_ADD)

	// Skin tone
	if(current_species && (current_species.bodyflags & HAS_SKIN_TONE))
		if(s_tone >= 0)
			preview_icon.Blend(rgb(s_tone, s_tone, s_tone), ICON_ADD)
		else
			preview_icon.Blend(rgb(-s_tone,  -s_tone,  -s_tone), ICON_SUBTRACT)

	// Body accessory
	if(current_species && (current_species.bodyflags & HAS_BODY_ACCESSORY))
		var/icon
		var/icon_state
		var/offset_x = 0
		var/offset_y = 0
		var/blend_mode = ICON_ADD
		var/icon/underlay = null

		if(body_accessory)
			var/datum/body_accessory/BA = GLOB.body_accessory_by_name[body_accessory]
			if(BA)
				icon = BA.icon
				icon_state = BA.icon_state
				blend_mode = BA.blend_mode || blend_mode
				offset_x = BA.pixel_x_offset
				offset_y = BA.pixel_y_offset
				// If the body accessory has an underlay, account for it.
				if(BA.has_behind)
					underlay = new(icon, "[icon_state]_BEHIND")
		else if(current_species.bodyflags & HAS_TAIL)
			icon = "icons/effects/species.dmi"
			if(coloured_tail)
				icon_state = "[coloured_tail]_s"
			else
				icon_state = "[current_species.tail]_s"

		if(icon)
			var/icon/temp = new(icon, icon_state)
			if((current_species.name != SPECIES_MOTH) && current_species.bodyflags & HAS_SKIN_COLOR)
				temp.Blend(s_colour, blend_mode)
			if(current_species.bodyflags & HAS_TAIL_MARKINGS)
				var/tail_marking = m_styles["tail"]
				var/datum/sprite_accessory/body_markings/BM = GLOB.marking_styles_list[tail_marking]
				if(BM)
					var/icon/t_marking_s = new(BM.icon, "[BM.icon_state]_s")
					t_marking_s.Blend(m_colours["tail"], ICON_ADD)
					temp.Blend(t_marking_s, ICON_OVERLAY)

			// Body accessory has an underlay, add it too.
			if(underlay)
				ICON_SHIFT_XY(underlay, offset_x, offset_y)
				preview_icon.Blend(underlay, ICON_UNDERLAY)

			ICON_SHIFT_XY(temp, offset_x, offset_y)
			preview_icon.Blend(temp, ICON_OVERLAY)

	//Markings
	if(current_species && ((current_species.bodyflags & HAS_HEAD_MARKINGS) || (current_species.bodyflags & HAS_BODY_MARKINGS)))
		if(current_species.bodyflags & HAS_BODY_MARKINGS) //Body markings.
			var/body_marking = m_styles["body"]
			var/datum/sprite_accessory/body_marking_style = GLOB.marking_styles_list[body_marking]
			if(body_marking_style && body_marking_style.species_allowed)
				var/icon/b_marking_s = new/icon("icon" = body_marking_style.icon, "icon_state" = "[body_marking_style.icon_state]_s")
				b_marking_s.Blend(m_colours["body"], ICON_ADD)
				preview_icon.Blend(b_marking_s, ICON_OVERLAY)
		if(current_species.bodyflags & HAS_HEAD_MARKINGS) //Head markings.
			var/head_marking = m_styles["head"]
			var/datum/sprite_accessory/head_marking_style = GLOB.marking_styles_list[head_marking]
			if(head_marking_style && head_marking_style.species_allowed)
				var/icon/h_marking_s = new/icon("icon" = head_marking_style.icon, "icon_state" = "[head_marking_style.icon_state]_s")
				h_marking_s.Blend(m_colours["head"], ICON_ADD)
				preview_icon.Blend(h_marking_s, ICON_OVERLAY)


	var/icon/face_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = "bald_s")
	if(!(current_species.bodyflags & NO_EYES))
		var/icon/eyes_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = current_species ? current_species.eyes : "eyes_s")
		eyes_s.Blend(e_colour, ICON_ADD)
		face_s.Blend(eyes_s, ICON_OVERLAY)


	var/datum/sprite_accessory/hair_style = GLOB.hair_styles_full_list[h_style]
	if(hair_style)
		var/icon/hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
		if(current_species.name == SPECIES_SLIMEPERSON) // whee I am part of the problem
			hair_s.Blend("[s_colour]A0", ICON_ADD)
		else if(hair_style.do_colouration)
			hair_s.Blend(h_colour, ICON_ADD)

		var/datum/sprite_accessory/hair_gradient/gradient = GLOB.hair_gradients_list[h_grad_style]
		if(gradient)
			var/icon/grad_s = new/icon("icon" = gradient.icon, "icon_state" = gradient.icon_state)
			if(h_grad_offset_x)
				grad_s.Shift(EAST, h_grad_offset_x)
			if(h_grad_offset_y)
				grad_s.Shift(NORTH, h_grad_offset_y)
			grad_s.Blend(hair_s, ICON_ADD)
			grad_s.MapColors(COLOR_BLACK, COLOR_BLACK, COLOR_BLACK, h_grad_colour)
			grad_s.ChangeOpacity(h_grad_alpha / 200)
			hair_s.Blend(grad_s, ICON_OVERLAY)

		if(hair_style.secondary_theme)
			var/icon/hair_secondary_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_[hair_style.secondary_theme]_s")
			if(!hair_style.no_sec_colour && hair_style.do_colouration )
				hair_secondary_s.Blend(h_sec_colour, ICON_ADD)
			hair_s.Blend(hair_secondary_s, ICON_OVERLAY)

		face_s.Blend(hair_s, ICON_OVERLAY)

	//Head Accessory
	if(current_species && (current_species.bodyflags & HAS_HEAD_ACCESSORY))
		var/datum/sprite_accessory/head_accessory_style = GLOB.head_accessory_styles_list[ha_style]
		if(head_accessory_style && head_accessory_style.species_allowed)
			var/icon/head_accessory_s = new/icon("icon" = head_accessory_style.icon, "icon_state" = "[head_accessory_style.icon_state]_s")
			head_accessory_s.Blend(hacc_colour, ICON_ADD)
			face_s.Blend(head_accessory_s, ICON_OVERLAY)

	var/datum/sprite_accessory/facial_hair_style = GLOB.facial_hair_styles_list[f_style]
	if(facial_hair_style && facial_hair_style.species_allowed)
		var/icon/facial_s = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
		if(current_species.name == SPECIES_SLIMEPERSON) // whee I am part of the problem
			facial_s.Blend("[s_colour]A0", ICON_ADD)
		else if(facial_hair_style.do_colouration)
			facial_s.Blend(f_colour, ICON_ADD)

		if(facial_hair_style.secondary_theme)
			var/icon/facial_secondary_s = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_[facial_hair_style.secondary_theme]_s")
			if(!facial_hair_style.no_sec_colour && facial_hair_style.do_colouration)
				facial_secondary_s.Blend(f_sec_colour, ICON_ADD)
			facial_s.Blend(facial_secondary_s, ICON_OVERLAY)

		face_s.Blend(facial_s, ICON_OVERLAY)

	var/icon/underwear_s = null
	if(underwear && (current_species.clothing_flags & HAS_UNDERWEAR))
		var/datum/sprite_accessory/underwear/U = GLOB.underwear_list[underwear]
		if(U)
			var/u_icon = U.sprite_sheets && (current_species.name in U.sprite_sheets) ? U.sprite_sheets[current_species.name] : U.icon //Species-fit the undergarment.
			underwear_s = new/icon(u_icon, "uw_[U.icon_state]_s", ICON_OVERLAY)
			if(U.allow_change_color)
				underwear_s.Blend(underwear_color, ICON_MULTIPLY)

	var/icon/undershirt_s = null
	if(undershirt && (current_species.clothing_flags & HAS_UNDERSHIRT))
		var/datum/sprite_accessory/undershirt/U2 = GLOB.undershirt_list[undershirt]
		if(U2)
			var/u2_icon = U2.sprite_sheets && (current_species.name in U2.sprite_sheets) ? U2.sprite_sheets[current_species.name] : U2.icon
			undershirt_s = new/icon(u2_icon, "us_[U2.icon_state]_s", ICON_OVERLAY)
			if(U2.allow_change_color)
				undershirt_s.Blend(undershirt_color, ICON_MULTIPLY)

	var/icon/socks_s = null
	if(socks && (current_species.clothing_flags & HAS_SOCKS))
		var/datum/sprite_accessory/socks/U3 = GLOB.socks_list[socks]
		if(U3)
			var/u3_icon = U3.sprite_sheets && (current_species.name in U3.sprite_sheets) ? U3.sprite_sheets[current_species.name] : U3.icon
			socks_s = new/icon(u3_icon, "sk_[U3.icon_state]_s", ICON_OVERLAY)

	var/icon/clothes_s = null
	var/uniform_dmi='icons/mob/clothing/uniform.dmi'
	if(job_support_low & JOB_FLAG_CIVILIAN)//This gives the preview icon clothes depending on which job(if any) is set to 'high'
		clothes_s = new /icon(uniform_dmi, "grey_s")
		clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
		if(backbag == 2)
			clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
		else if(backbag == 3 || backbag == 4)
			clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)

	else if(job_support_high)//I hate how this looks, but there's no reason to go through this switch if it's empty
		switch(job_support_high)
			if(JOB_FLAG_HOP)
				clothes_s = new /icon(uniform_dmi, "hop_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "brown"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "ianshirt"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_FLAG_BARTENDER)
				clothes_s = new /icon(uniform_dmi, "ba_suit_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "tophat"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_FLAG_BOTANIST)
				clothes_s = new /icon(uniform_dmi, "hydroponics_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/hands.dmi', "ggloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "apron"), ICON_OVERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "nymph"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-hyd"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_FLAG_CHEF)
				clothes_s = new /icon(uniform_dmi, "chef_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "chef"), ICON_OVERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "apronchef"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_FLAG_JANITOR)
				clothes_s = new /icon(uniform_dmi, "janitor_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "bio_janitor"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_FLAG_LIBRARIAN)
				clothes_s = new /icon(uniform_dmi, "red_suit_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "hairflower"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_FLAG_QUARTERMASTER)
				clothes_s = new /icon(uniform_dmi, "qm_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "brown"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/hands.dmi', "bgloves"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "poncho"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_FLAG_CARGOTECH)
				clothes_s = new /icon(uniform_dmi, "cargotech_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/hands.dmi', "bgloves"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "flat_cap"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_FLAG_MINER)
				clothes_s = new /icon(uniform_dmi, "explorer_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "explorer"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/hands.dmi', "bgloves"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "bearpelt"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "explorerpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-explorer"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_FLAG_MINING_MEDIC)
				clothes_s = new /icon(uniform_dmi, "mining_medic_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "explorer"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/hands.dmi', "bgloves"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "bearpelt"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "explorerpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-explorer"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_FLAG_LAWYER)
				clothes_s = new /icon(uniform_dmi, "internalaffairs_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "brown"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/inhands/items_righthand.dmi', "briefcase"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "suitjacket_blue"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_FLAG_CHAPLAIN)
				clothes_s = new /icon(uniform_dmi, "chapblack_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "imperium_monk"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_FLAG_CLOWN)
				clothes_s = new /icon(uniform_dmi, "clown_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "clown"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/mask.dmi', "clown"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "clownpack"), ICON_OVERLAY)
			if(JOB_FLAG_MIME)
				clothes_s = new /icon(uniform_dmi, "mime_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/hands.dmi', "lgloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/mask.dmi', "mime"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "beret"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "suspenders"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)

	else if(job_medsci_high)
		switch(job_medsci_high)
			if(JOB_FLAG_RD)
				clothes_s = new /icon(uniform_dmi, "director_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "brown"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "labcoat_open"), ICON_OVERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "petehat"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-tox"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_FLAG_SCIENTIST, JOB_FLAG_SCIENTIST_STUDENT)
				clothes_s = new /icon(uniform_dmi, "toxinswhite_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "white"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "labcoat_tox_open"), ICON_OVERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "metroid"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-tox"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_FLAG_CHEMIST)
				clothes_s = new /icon(uniform_dmi, "chemistrywhite_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "white"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "labgreen"), ICON_OVERLAY)
				else
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "labcoat_chem_open"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-chem"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_FLAG_CMO)
				clothes_s = new /icon(uniform_dmi, "cmo_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "brown"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "bio_cmo"), ICON_OVERLAY)
				else
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "labcoat_cmo_open"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "medicalpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-med"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_FLAG_DOCTOR, JOB_FLAG_INTERN)
				clothes_s = new /icon(uniform_dmi, "medical_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "white"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "surgeon"), ICON_OVERLAY)
				else
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "labcoat_open"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "medicalpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-med"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_FLAG_CORONER)
				clothes_s = new /icon(uniform_dmi, "medical_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "white"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "mortician"), ICON_OVERLAY)
				else
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "labcoat_open"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "medicalpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-med"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_FLAG_GENETICIST)
				clothes_s = new /icon(uniform_dmi, "geneticswhite_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "white"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "monkeysuit"), ICON_OVERLAY)
				else
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "labcoat_gen_open"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-gen"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_FLAG_VIROLOGIST)
				clothes_s = new /icon(uniform_dmi, "virologywhite_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "white"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/mask.dmi', "sterile"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "labcoat_vir_open"), ICON_OVERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "plaguedoctor"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "medicalpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-vir"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_FLAG_PSYCHIATRIST)
				clothes_s = new /icon(uniform_dmi, "psych_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "laceups"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "labcoat_open"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_FLAG_PARAMEDIC)
				clothes_s = new /icon(uniform_dmi, "paramedic_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/mask.dmi', "cigoff"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "paramedicsoft"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "medicalpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-med"), ICON_OVERLAY)
			if(JOB_FLAG_ROBOTICIST)
				clothes_s = new /icon(uniform_dmi, "robotics_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/hands.dmi', "bgloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "labcoat_open"), ICON_OVERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/inhands/items_righthand.dmi', "toolbox_blue"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)

	else if(job_engsec_high)
		switch(job_engsec_high)
			if(JOB_FLAG_CAPTAIN)
				clothes_s = new /icon(uniform_dmi, "captain_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "brown"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "centcomcaptain"), ICON_OVERLAY)
				else
					clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "captain"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-cap"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_FLAG_HOS)
				clothes_s = new /icon(uniform_dmi, "hosred_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "jackboots"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/hands.dmi', "bgloves"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "beret_hos"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "securitypack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-sec"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_FLAG_WARDEN)
				clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "warden_s")
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "slippers_worn"), ICON_OVERLAY)
				else
					clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "jackboots"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/hands.dmi', "bgloves"), ICON_UNDERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "securitypack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-sec"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_FLAG_DETECTIVE)
				clothes_s = new /icon(uniform_dmi, "detective_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "brown"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/hands.dmi', "bgloves"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/mask.dmi', "cigaron"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "detective"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "detective"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_FLAG_OFFICER)
				clothes_s = new /icon(uniform_dmi, "secred_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "jackboots"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "beret_officer"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "securitypack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-sec"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_FLAG_CHIEF)
				clothes_s = new /icon(uniform_dmi, "chief_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "brown"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/hands.dmi', "bgloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/belt.dmi', "utility"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "hardhat0_white"), ICON_OVERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/inhands/items_righthand.dmi', "blueprints"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "engiepack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-eng"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_FLAG_ENGINEER, JOB_FLAG_ENGINEER_TRAINEE)
				clothes_s = new /icon(uniform_dmi, "engine_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "orange"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/belt.dmi', "utility"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "hardhat0_yellow"), ICON_OVERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "hazard"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "engiepack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-eng"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_FLAG_ATMOSTECH)
				clothes_s = new /icon(uniform_dmi, "atmos_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/hands.dmi', "bgloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/belt.dmi', "utility"), ICON_OVERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "firesuit"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)

			if(JOB_FLAG_AI)//Gives AI and borgs assistant-wear, so they can still customize their character
				clothes_s = new /icon(uniform_dmi, "grey_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "straight_jacket"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "cardborg_h"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
				else if(backbag == 3 || backbag == 4)
					clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_FLAG_CYBORG)
				clothes_s = new /icon(uniform_dmi, "grey_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "cardborg"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "cardborg_h"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
				else if(backbag == 3 || backbag == 4)
					clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
	else if(job_karma_high)
		switch(job_karma_high)
			if(JOB_FLAG_MECHANIC)
				clothes_s = new /icon(uniform_dmi, "mechanic_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "orange"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/belt.dmi', "utility"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "hardhat0_yellow"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "engiepack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-eng"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_FLAG_PILOT)
				clothes_s = new /icon(uniform_dmi, "secred_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "jackboots"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "bomber"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "securitypack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-sec"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_FLAG_BRIGDOC)
				clothes_s = new /icon(uniform_dmi, "medical_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "white"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "fr_jacket_open"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "medicalpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-med"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_FLAG_REPRESENTATIVE)
				clothes_s = new /icon(uniform_dmi, "officer_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "laceups"), ICON_UNDERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_FLAG_BLUESHIELD)
				clothes_s = new /icon(uniform_dmi, "officer_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "jackboots"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/hands.dmi', "swat_gl"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "blueshield"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "securitypack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)
			if(JOB_FLAG_JUDGE)
				clothes_s = new /icon(uniform_dmi, "really_black_suit_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "laceups"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/head.dmi', "mercy_hood"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "judge"), ICON_UNDERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)

	if(disabilities & DISABILITY_FLAG_NEARSIGHTED)
		preview_icon.Blend(new /icon('icons/mob/clothing/eyes.dmi', "glasses"), ICON_OVERLAY)

	// Observers get tourist outfit.
	if(for_observer)
		clothes_s = new /icon(uniform_dmi, "tourist_s")
		clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
		if(backbag == 2)
			clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "backpack"), ICON_OVERLAY)
		else if(backbag == 3 || backbag == 4)
			clothes_s.Blend(new /icon('icons/mob/clothing/back.dmi', "satchel"), ICON_OVERLAY)

	if(underwear_s)
		preview_icon.Blend(underwear_s, ICON_OVERLAY)
	if(undershirt_s)
		preview_icon.Blend(undershirt_s, ICON_OVERLAY)
	if(socks_s)
		preview_icon.Blend(socks_s, ICON_OVERLAY)
	if(clothes_s)
		preview_icon.Blend(clothes_s, ICON_OVERLAY)
	preview_icon.Blend(face_s, ICON_OVERLAY)
	preview_icon_front = new(preview_icon, dir = SOUTH)
	preview_icon_side = new(preview_icon, dir = WEST)

	qdel(face_s)
	qdel(underwear_s)
	qdel(undershirt_s)
	qdel(socks_s)
	qdel(clothes_s)

#undef ICON_SHIFT_XY
