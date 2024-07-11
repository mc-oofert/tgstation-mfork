/obj/vehicle/sealed/modular_car
	icon = 'icons/mob/rideables/modular_car/chassis_64x64.dmi'
	icon_state = "basic_chassis"
	layer = ABOVE_MOB_LAYER
	base_pixel_x = -16
	pixel_x = -16
	max_occupants = 4

	/// list of attached equipment, format is "equipment[slot] = equipment"
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

/obj/vehicle/sealed/modular_car/vehicle_move(direction)
	if(!equipment[CAR_SLOT_ENGINE])
		return
	if(!equipment[CAR_SLOT_WHEELS])
		return
	var/obj/item/modcar_equipment/propulsion/propulsion = equipment[CAR_SLOT_ENGINE]
	return propulsion.vehicle_move(direction)

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

	if(equipment[new_equipment.slot])
		balloon_alert(user, "slot occupied!")
		return

	equip_item(user, new_equipment)

/obj/vehicle/sealed/modular_car/crowbar_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return

	var/chosen_part = tgui_input_list(user, "Choose a piece of equipment to remove.", "Equipment Removal", get_all_parts())
	if(!chosen_part || !can_interact(user))
		return ITEM_INTERACT_BLOCKING

	if(unequip_item(user, chosen_part))
		tool.play_tool_sound(src)
		return ITEM_INTERACT_SUCCESS
	else
		balloon_alert(user, "it's stuck!")
		return ITEM_INTERACT_BLOCKING

/obj/vehicle/sealed/modular_car/proc/equip_item(mob/living/user, obj/item/modcar_equipment/new_equipment)
	. = FALSE

	if(!isnull(user))
		if(!user.transferItemToLoc(new_equipment, src))
			return
	else
		new_equipment.forceMove(src)

	equipment[new_equipment.slot] = new_equipment
	new_equipment.chassis = src
	new_equipment.on_attach()

	update_appearance()

	return TRUE

/obj/vehicle/sealed/modular_car/proc/unequip_item(mob/living/user, obj/item/modcar_equipment/to_remove)
	. = FALSE

	if(user)
		user.put_in_hands(to_remove) // this already handles dropping it on the floor in case of failure
	else if(!QDELING(to_remove))
		to_remove.forceMove(drop_location())

	to_remove.on_detach()
	to_remove.chassis = null
	equipment[to_remove.slot] = null

	update_appearance()

	return TRUE

/obj/vehicle/sealed/modular_car/Destroy()
	. = ..()
	QDEL_LIST_ASSOC_VAL(equipment)

// prebuilt

/obj/vehicle/sealed/modular_car/prebuilt

/obj/vehicle/sealed/modular_car/prebuilt/Initialize(mapload)
	. = ..()
	equip_item(new_equipment = new /obj/item/modcar_equipment/propulsion/wheels)
	//todo line with the actual engine that we dont have
