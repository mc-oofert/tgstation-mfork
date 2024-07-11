/obj/vehicle/sealed/modular_car
	icon = 'icons/mob/rideables/modular_car/chassis_64x64.dmi'
	icon_state = "basic_car"
	layer = ABOVE_MOB_LAYER
	move_resist = MOVE_FORCE_VERY_STRONG
	base_pixel_x = -16
	pixel_x = -16
	max_occupants = 4
	/// car slot to max amount of equipment in that slot
	var/list/slot_max = list(
		CAR_ENGINE = 1, //duh
		CAR_PROPULSION = 1, //single set of four wheels or four thrusters
		CAR_MISC = 4,
	)
	/// list of attached equipment, format; slot = list(equipment)
	var/list/obj/item/modcar_equipment/equipment = list()
	/// Is the hood open?
	var/hood_open = FALSE

/obj/vehicle/sealed/modular_car/update_overlays()
	. = ..()

	//hood goes here

	for(var/obj/item/modcar_equipment/attachment as anything in get_all_parts())
		var/overlay = attachment.get_overlay()
		if(!overlay) //this probably handles nulls on its own but just to be safe
			continue
		. += overlay

//todo put this in some sort of action button or UI button
/obj/vehicle/sealed/modular_car/proc/toggle_hood()
	hood_open = !hood_open
	if(hood_open)
		playsound(src, 'sound/effects/bin_open.ogg', 50, TRUE)
	else
		playsound(src, 'sound/effects/bin_close.ogg', 50, TRUE)

	update_appearance()

/obj/vehicle/sealed/modular_car/item_interaction(mob/living/user, obj/item/modcar_equipment/new_equipment, list/modifiers)
	. = NONE
	if(!istype(new_equipment))
		return

	if(!hood_open)
		balloon_alert(user ,"open hood!")
		return ITEM_INTERACT_BLOCKING

	var/what_slot
	if(islist(new_equipment.slot))
		var/list/notfullslots = list()
		for(var/slot in equipment)
			if(length(equipment[slot] >= slot_max[slot]))
				continue
			notfullslots += slot

		what_slot = length(notfullslots) >= 1 ? tgui_input_list(user, "What slot?", "What slot?", notfullslots) : pick(notfullslots)
		if(!what_slot)
			balloon_alert(user, "not enough space!")
			return ITEM_INTERACT_BLOCKING
	else
		what_slot = new_equipment.slot
		if(length(equipment[what_slot]) >= slot_max[what_slot])
			balloon_alert(user, "not enough space in the [what_slot]!")
			return ITEM_INTERACT_BLOCKING

	var/exclusive_part = is_mutually_excluded(new_equipment)
	if(exclusive_part)
		balloon_alert(user, "exclusive with [exclusive_part]!")
		return ITEM_INTERACT_BLOCKING

	if(equip_item(user, new_equipment, what_slot))
		to_chat(user, span_notice("You equip the car with [new_equipment]."))
		balloon_alert(user, "equipped")
		return ITEM_INTERACT_SUCCESS

/obj/vehicle/sealed/modular_car/crowbar_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return

	if(!hood_open)
		balloon_alert(user, "open hood!")
		return ITEM_INTERACT_BLOCKING

	var/chosen_part = tgui_input_list(user, "Remove what?", "Equipment Removal", get_all_parts())
	if(!chosen_part || !can_interact(user))
		return ITEM_INTERACT_BLOCKING

	if(unequip_item(user, chosen_part))
		tool.play_tool_sound(src)
		return ITEM_INTERACT_SUCCESS
	else
		return ITEM_INTERACT_BLOCKING

/obj/vehicle/sealed/modular_car/proc/equip_item(mob/living/user, obj/item/modcar_equipment/new_equipment, slot)
	. = FALSE
	if(!istype(new_equipment))
		CRASH("somehow tried to equip nonequipment into a modular car") //stop

	if(!(slot in new_equipment.slot))
		return

	if(new_equipment.chassis)
		CRASH("tried to equip equipped equipment into a modular car")

	if(length(equipment[slot]) >= slot_max[slot])
		return

	if(!isnull(user))
		if(!user.transferItemToLoc(new_equipment, src))
			return
	else
		new_equipment.forceMove(src)

	LAZYADD(equipment[slot], new_equipment)
	new_equipment.chassis = src
	new_equipment.equipped_slot = slot
	new_equipment.on_attach()

	update_appearance()

	return TRUE

/obj/vehicle/sealed/modular_car/proc/unequip_item(mob/living/user, obj/item/modcar_equipment/to_remove)
	. = FALSE
	if(!istype(to_remove))
		CRASH("somehow tried to unequip nonequipment from a modular car") //stop

	if(isnull(user) || !user.put_in_hands(to_remove))
		to_remove.forceMove(drop_location())

	LAZYREMOVE(equipment[to_remove.slot], to_remove)
	to_remove.chassis = null
	to_remove.equipped_slot = null
	to_remove.on_detach()

	update_appearance()

	return TRUE
