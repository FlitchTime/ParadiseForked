/atom/movable/screen/human
	icon = 'icons/mob/screen_midnight.dmi'

/atom/movable/screen/human/toggle
	name = "toggle"
	icon_state = "toggle"

/atom/movable/screen/human/toggle/Click()
	var/mob/targetmob = usr

	if(isobserver(usr))
		if(ishuman(usr.client.eye) && (usr.client.eye != usr))
			var/mob/my_eye = usr.client.eye
			targetmob = my_eye

	if(usr.hud_used.inventory_shown && targetmob.hud_used)
		usr.hud_used.inventory_shown = FALSE
		usr.client.screen -= targetmob.hud_used.toggleable_inventory
	else
		usr.hud_used.inventory_shown = TRUE
		usr.client.screen += targetmob.hud_used.toggleable_inventory

	targetmob.hud_used.hidden_inventory_update(usr)

/atom/movable/screen/human/equip
	name = "equip"
	icon_state = "act_equip"

/atom/movable/screen/human/equip/Click()
	if(ismecha(usr.loc)) // stops inventory actions in a mech
		return TRUE

	if(is_ventcrawling(usr)) // stops inventory actions in vents
		return TRUE

	var/mob/living/carbon/human/H = usr
	H.quick_equip()

/atom/movable/screen/ling
	invisibility = INVISIBILITY_ABSTRACT

/atom/movable/screen/ling/sting
	name = "current sting"
	screen_loc = ui_lingstingdisplay

/atom/movable/screen/ling/sting/Click()
	if(isobserver(usr))
		return
	var/datum/antagonist/changeling/cling = usr?.mind?.has_antag_datum(/datum/antagonist/changeling)
	cling?.chosen_sting?.unset_sting()

/atom/movable/screen/ling/chems
	name = "chemical storage"
	icon_state = "power_display"
	screen_loc = ui_lingchemdisplay

/atom/movable/screen/devil
	invisibility = INVISIBILITY_ABSTRACT

/atom/movable/screen/devil/soul_counter
	icon = 'icons/mob/screen_gen.dmi'
	name = "souls owned"
	icon_state = "Devil-6"
	screen_loc = ui_devilsouldisplay

/atom/movable/screen/devil/soul_counter/proc/update_counter(souls = 0)
	invisibility = 0
	maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#FF0000'>[souls]</font></div>"
	switch(souls)
		if(0,null)
			icon_state = "Devil-1"
		if(1,2)
			icon_state = "Devil-2"
		if(3 to 5)
			icon_state = "Devil-3"
		if(6 to 8)
			icon_state = "Devil-4"
		if(9 to INFINITY)
			icon_state = "Devil-5"
		else
			icon_state = "Devil-6"

/atom/movable/screen/devil/soul_counter/proc/clear()
	invisibility = INVISIBILITY_ABSTRACT


/datum/hud/human
	var/hud_alpha = 255

/datum/hud/human/New(mob/living/carbon/human/owner)
	..()
	owner.overlay_fullscreen("see_through_darkness", /atom/movable/screen/fullscreen/see_through_darkness)
	var/atom/movable/screen/using
	var/atom/movable/screen/inventory/inv_box
	var/client/client = owner.client
	var/ui_style = ui_style2icon(client.prefs.UI_style)
	var/ui_color = client.prefs.UI_style_color
	var/ui_alpha = client.prefs.UI_style_alpha

	hud_alpha = ui_alpha

	using = new /atom/movable/screen/craft(null, src)
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	static_inventory += using

	using = new /atom/movable/screen/language_menu(null, src)
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	static_inventory += using

	using = new /atom/movable/screen/act_intent(null, src)
	using.icon_state = mymob.a_intent
	using.alpha = ui_alpha
	static_inventory += using
	action_intent = using

	using = new /atom/movable/screen/mov_intent(null, src)
	using.icon = ui_style
	using.update_icon(UPDATE_ICON_STATE)
	using.screen_loc = ui_movi
	using.color = ui_color
	using.alpha = ui_alpha
	static_inventory += using
	move_intent = using

	using = new /atom/movable/screen/drop(null, src)
	using.icon = ui_style
	using.screen_loc = ui_drop_throw
	using.color = ui_color
	using.alpha = ui_alpha
	static_inventory += using

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "i_clothing"
	inv_box.icon = ui_style
	inv_box.slot_id = ITEM_SLOT_CLOTH_INNER
	inv_box.icon_state = "uniform"
	inv_box.screen_loc = ui_iclothing
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "o_clothing"
	inv_box.icon = ui_style
	inv_box.slot_id = ITEM_SLOT_CLOTH_OUTER
	inv_box.icon_state = "suit"
	inv_box.screen_loc = ui_oclothing
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory/hand(null, src)
	inv_box.name = "r_hand"
	inv_box.icon = ui_style
	inv_box.icon_state = "hand_r"
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	inv_box.screen_loc = ui_rhand
	inv_box.slot_id = ITEM_SLOT_HAND_RIGHT
	static_inventory += inv_box
	hand_slots += inv_box

	inv_box = new /atom/movable/screen/inventory/hand(null, src)
	inv_box.name = "l_hand"
	inv_box.icon = ui_style
	inv_box.icon_state = "hand_l"
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	inv_box.screen_loc = ui_lhand
	inv_box.slot_id = ITEM_SLOT_HAND_LEFT
	static_inventory += inv_box
	hand_slots += inv_box

	using = new /atom/movable/screen/swap_hand(null, src)
	using.name = "hand"
	using.icon = ui_style
	using.icon_state = "swap_1"
	using.screen_loc = ui_swaphand1
	using.color = ui_color
	using.alpha = ui_alpha
	static_inventory += using

	using = new /atom/movable/screen/swap_hand(null, src)
	using.name = "hand"
	using.icon = ui_style
	using.icon_state = "swap_2"
	using.screen_loc = ui_swaphand2
	using.color = ui_color
	using.alpha = ui_alpha
	static_inventory += using

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "id"
	inv_box.icon = ui_style
	inv_box.icon_state = "id"
	inv_box.screen_loc = ui_id
	inv_box.slot_id = ITEM_SLOT_ID
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	static_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "pda"
	inv_box.icon = ui_style
	inv_box.icon_state = "pda"
	inv_box.screen_loc = ui_pda
	inv_box.slot_id = ITEM_SLOT_PDA
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	static_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "mask"
	inv_box.icon = ui_style
	inv_box.icon_state = "mask"
	inv_box.screen_loc = ui_mask
	inv_box.slot_id = ITEM_SLOT_MASK
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "neck"
	inv_box.icon = ui_style
	inv_box.icon_state = "neck"
	inv_box.screen_loc = ui_neck
	inv_box.slot_id = ITEM_SLOT_NECK
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "back"
	inv_box.icon = ui_style
	inv_box.icon_state = "back"
	inv_box.screen_loc = ui_back
	inv_box.slot_id = ITEM_SLOT_BACK
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	static_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "storage1"
	inv_box.icon = ui_style
	inv_box.icon_state = "pocket"
	inv_box.screen_loc = ui_storage1
	inv_box.slot_id = ITEM_SLOT_POCKET_LEFT
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	static_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "storage2"
	inv_box.icon = ui_style
	inv_box.icon_state = "pocket"
	inv_box.screen_loc = ui_storage2
	inv_box.slot_id = ITEM_SLOT_POCKET_RIGHT
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	static_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "suit storage"
	inv_box.icon = ui_style
	inv_box.icon_state = "suit_storage"
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	inv_box.screen_loc = ui_sstore1
	inv_box.slot_id = ITEM_SLOT_SUITSTORE
	static_inventory += inv_box

	using = new /atom/movable/screen/resist(null, src)
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	using.screen_loc = ui_pull_resist
	hotkeybuttons += using

	using = new /atom/movable/screen/human/toggle(null, src)
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	using.screen_loc = ui_inventory
	static_inventory += using

	using = new /atom/movable/screen/human/equip(null, src)
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	using.screen_loc = ui_equip
	static_inventory += using

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "gloves"
	inv_box.icon = ui_style
	inv_box.icon_state = "gloves"
	inv_box.screen_loc = ui_gloves
	inv_box.slot_id = ITEM_SLOT_GLOVES
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "eyes"
	inv_box.icon = ui_style
	inv_box.icon_state = "glasses"
	inv_box.screen_loc = ui_glasses
	inv_box.slot_id = ITEM_SLOT_EYES
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "l_ear"
	inv_box.icon = ui_style
	inv_box.icon_state = "ears"
	inv_box.screen_loc = ui_l_ear
	inv_box.slot_id = ITEM_SLOT_EAR_LEFT
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "r_ear"
	inv_box.icon = ui_style
	inv_box.icon_state = "ears"
	inv_box.screen_loc = ui_r_ear
	inv_box.slot_id = ITEM_SLOT_EAR_RIGHT
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "head"
	inv_box.icon = ui_style
	inv_box.icon_state = "head"
	inv_box.screen_loc = ui_head
	inv_box.slot_id = ITEM_SLOT_HEAD
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "shoes"
	inv_box.icon = ui_style
	inv_box.icon_state = "shoes"
	inv_box.screen_loc = ui_shoes
	inv_box.slot_id = ITEM_SLOT_FEET
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	toggleable_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "belt"
	inv_box.icon = ui_style
	inv_box.icon_state = "belt"
	inv_box.screen_loc = ui_belt
	inv_box.slot_id = ITEM_SLOT_BELT
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	static_inventory += inv_box

	mymob.throw_icon = new /atom/movable/screen/throw_catch(null, src)
	mymob.throw_icon.icon = ui_style
	mymob.throw_icon.screen_loc = ui_drop_throw
	mymob.throw_icon.color = ui_color
	mymob.throw_icon.alpha = ui_alpha
	hotkeybuttons += mymob.throw_icon

	mymob.healths = new /atom/movable/screen/healths(null, src)
	infodisplay += mymob.healths

	mymob.healthdoll = new(null, src)
	infodisplay += mymob.healthdoll

	mymob.pullin = new /atom/movable/screen/pull(null, src)
	mymob.pullin.icon = ui_style
	mymob.pullin.update_icon(UPDATE_ICON_STATE)
	mymob.pullin.screen_loc = ui_pull_resist
	static_inventory += mymob.pullin

	mymob.stamina_bar = new /atom/movable/screen/stamina_bar(null, src)
	infodisplay += mymob.stamina_bar

	lingchemdisplay = new /atom/movable/screen/ling/chems(null, src)
	infodisplay += lingchemdisplay

	lingstingdisplay = new /atom/movable/screen/ling/sting(null, src)
	infodisplay += lingstingdisplay

	devilsouldisplay = new /atom/movable/screen/devil/soul_counter(null, src)
	infodisplay += devilsouldisplay

	zone_select =  new /atom/movable/screen/zone_sel(null, src, ui_style, ui_alpha, ui_color)
	static_inventory += zone_select

	combo_display = new(null, src)
	infodisplay += combo_display


	for(var/atom/movable/screen/inventory/inv in (static_inventory + toggleable_inventory))
		if(inv.slot_id)
			inv_slots[TOBITSHIFT(inv.slot_id) + 1] = inv
			inv.update_appearance()

	update_locked_slots()


/datum/hud/human/update_locked_slots()
	if(!mymob)
		return
	var/mob/living/carbon/human/H = mymob
	if(!istype(H) || !H.dna.species)
		return
	var/datum/species/S = H.dna.species
	for(var/atom/movable/screen/inventory/inv in (static_inventory + toggleable_inventory))
		if(inv.slot_id)
			if(inv.slot_id in S.no_equip)
				inv.alpha = hud_alpha / 2
			else
				inv.alpha = hud_alpha
	for(var/atom/movable/screen/craft/crafting in static_inventory)
		if(!S.can_craft)
			crafting.invisibility = INVISIBILITY_ABSTRACT
			H.handcrafting.close(H)
		else
			crafting.invisibility = initial(crafting.invisibility)

/datum/hud/human/hidden_inventory_update(mob/viewer)
	if(!mymob?.client)
		return
	var/mob/living/carbon/human/H = mymob
	var/mob/screenmob = viewer || H

	if(screenmob.hud_used.inventory_shown && screenmob.hud_used.hud_shown)
		if(H.shoes)
			H.shoes.screen_loc = ui_shoes
			screenmob.client.screen += H.shoes
		if(H.gloves)
			H.gloves.screen_loc = ui_gloves
			screenmob.client.screen += H.gloves
		if(H.l_ear)
			H.l_ear.screen_loc = ui_l_ear
			screenmob.client.screen += H.l_ear
		if(H.r_ear)
			H.r_ear.screen_loc = ui_r_ear
			screenmob.client.screen += H.r_ear
		if(H.glasses)
			H.glasses.screen_loc = ui_glasses
			screenmob.client.screen += H.glasses
		if(H.w_uniform)
			H.w_uniform.screen_loc = ui_iclothing
			screenmob.client.screen += H.w_uniform
		if(H.wear_suit)
			H.wear_suit.screen_loc = ui_oclothing
			screenmob.client.screen += H.wear_suit
		if(H.wear_mask)
			H.wear_mask.screen_loc = ui_mask
			screenmob.client.screen += H.wear_mask
		if(H.neck)
			H.neck.screen_loc = ui_neck
			screenmob.client.screen += H.neck
		if(H.head)
			H.head.screen_loc = ui_head
			screenmob.client.screen += H.head
	else
		if(H.shoes)
			screenmob.client.screen -= H.shoes
		if(H.gloves)
			screenmob.client.screen -= H.gloves
		if(H.l_ear)
			screenmob.client.screen -= H.l_ear
		if(H.r_ear)
			screenmob.client.screen -= H.r_ear
		if(H.glasses)
			screenmob.client.screen -= H.glasses
		if(H.w_uniform)
			screenmob.client.screen -= H.w_uniform
		if(H.wear_suit)
			screenmob.client.screen -= H.wear_suit
		if(H.wear_mask)
			screenmob.client.screen -= H.wear_mask
		if(H.neck)
			screenmob.client.screen -= H.neck
		if(H.head)
			screenmob.client.screen -= H.head

/datum/hud/human/persistent_inventory_update(mob/viewer)
	if(!mymob)
		return
	var/mob/living/carbon/human/H = mymob
	var/mob/screenmob = viewer || H

	if(screenmob.hud_used.hud_shown)
		if(H.s_store)
			H.s_store.screen_loc = ui_sstore1
			screenmob.client.screen += H.s_store
		if(H.wear_id)
			H.wear_id.screen_loc = ui_id
			screenmob.client.screen += H.wear_id
		if(H.wear_pda)
			H.wear_pda.screen_loc = ui_pda
			screenmob.client.screen += H.wear_pda
		if(H.belt)
			H.belt.screen_loc = ui_belt
			screenmob.client.screen += H.belt
		if(H.back)
			H.back.screen_loc = ui_back
			screenmob.client.screen += H.back
		if(H.l_store)
			H.l_store.screen_loc = ui_storage1
			screenmob.client.screen += H.l_store
		if(H.r_store)
			H.r_store.screen_loc = ui_storage2
			screenmob.client.screen += H.r_store
	else
		if(H.s_store)
			screenmob.client.screen -= H.s_store
		if(H.wear_id)
			screenmob.client.screen -= H.wear_id
		if(H.wear_pda)
			screenmob.client.screen -= H.wear_pda
		if(H.belt)
			screenmob.client.screen -= H.belt
		if(H.back)
			screenmob.client.screen -= H.back
		if(H.l_store)
			screenmob.client.screen -= H.l_store
		if(H.r_store)
			screenmob.client.screen -= H.r_store

	if(hud_version != HUD_STYLE_NOHUD)
		if(H.r_hand)
			H.r_hand.screen_loc = ui_rhand
			screenmob.client.screen += H.r_hand
		if(H.l_hand)
			H.l_hand.screen_loc = ui_lhand
			screenmob.client.screen += H.l_hand
	else
		if(H.r_hand)
			screenmob.client.screen -= H.r_hand
		if(H.l_hand)
			screenmob.client.screen -= H.l_hand

