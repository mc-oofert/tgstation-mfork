/obj/vehicle/sealed/modular_car
	icon = 'icons/mob/rideables/modular_car/chassis_64x64.dmi'
	icon_state = "chassis"
	layer = ABOVE_MOB_LAYER
	move_resist = MOVE_FORCE_VERY_STRONG
	base_pixel_x = -16
	pixel_x = -16
	max_occupants = 4
	light_system = OVERLAY_LIGHT_DIRECTIONAL

	/// list of attached equipment, format is "equipment[slot] = equipment"
	var/list/obj/item/modcar_equipment/equipment = list()
	/// Is the hood open?
	var/hood_open = FALSE
	/// our air
	var/datum/gas_mixture/air = new(1000)

/obj/vehicle/sealed/modular_car/generate_actions()
	. = ..()
	// physical switches so always present
	initialize_controller_action_type(/datum/action/vehicle/sealed/headlights/modcar, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/modcar_hood, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/modcar_windows, VEHICLE_CONTROL_DRIVE)

/obj/vehicle/sealed/modular_car/update_overlays()
	. = ..()

	. += "carhood_[hood_open ? "open" : "closed"]"

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

	var/speed_multiplier = 1
	for(var/obj/item/modcar_equipment/mod_equipment as anything in get_all_parts())
		speed_multiplier *= mod_equipment.get_speed_multiplier()

	if(speed_multiplier <= 0)
		return

	if(!COOLDOWN_FINISHED(src, cooldown_vehicle_move))
		return

	COOLDOWN_START(src, cooldown_vehicle_move, movedelay / speed_multiplier)

	try_step_multiz(direction)

/obj/vehicle/sealed/modular_car/item_interaction(mob/living/user, obj/item/modcar_equipment/new_equipment, list/modifiers)
	. = NONE
	if(try_glass_act(user, new_equipment))
		return

	if(!istype(new_equipment))
		return

	if(equip_item(user, new_equipment))
		return ITEM_INTERACT_SUCCESS
	else
		return ITEM_INTERACT_BLOCKING


/obj/vehicle/sealed/modular_car/proc/try_glass_act(mob/living/user, obj/item/stack/sheet/glass/stack)
	if(!is_glass_sheet(stack))
		return

	if(stack.get_amount() < 6)
		balloon_alert(user, "not enough!")
		return TRUE

	var/obj/item/modcar_equipment/windows/windows = new
	if(equip_item(user, windows))
		stack = stack.split_stack(user, 6)
		windows.set_stack(stack)
	else
		qdel(windows)

	return TRUE

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
	if(equipment[new_equipment.slot])
		if(user)
			balloon_alert(user, "slot occupied!")
		return

	if(user)
		if(!user.transferItemToLoc(new_equipment, src))
			return
		playsound(src, 'sound/machines/click.ogg')
	else
		new_equipment.forceMove(src)

	equipment[new_equipment.slot] = new_equipment
	new_equipment.chassis = src
	new_equipment.on_attach(user)

	update_appearance()

	return TRUE

/obj/vehicle/sealed/modular_car/proc/unequip_item(mob/living/user, obj/item/modcar_equipment/to_remove)
	var/atom/movable/drop_item = to_remove.get_drop_item()

	if(user)
		user.put_in_hands(drop_item) // this already handles drop_item being null and dropping it on the floor in case of failure
	else if(!QDELETED(drop_item))
		drop_item.forceMove(drop_location())

	to_remove.on_detach(user)
	to_remove.chassis = null
	equipment[to_remove.slot] = null

	update_appearance()

	return TRUE

/obj/vehicle/sealed/modular_car/Destroy()
	. = ..()
	QDEL_LIST_ASSOC_VAL(equipment)

/// Toggles the headlights of the car, if it has any.
/obj/vehicle/sealed/modular_car/proc/toggle_headlights(mob/user)
	var/obj/item/modcar_equipment/headlights/headlights = equipment[CAR_SLOT_HEADLIGHTS]
	if(!headlights)
		return

	/*headlights.toggle_state() fix this once headlights are done properly

	playsound(owner, headlights.on ? 'sound/weapons/magin.ogg' : 'sound/weapons/magout.ogg', 50)*/

/// Toggles the windows of the car, if it has any.
/obj/vehicle/sealed/modular_car/proc/toggle_windows(mob/user)
	var/obj/item/modcar_equipment/windows/windows = equipment[CAR_SLOT_WINDOWS]
	if(!windows)
		return

	windows.toggle_state()

	playsound(src, 'sound/machines/windowdoor.ogg', 75)

	var/datum/gas_mixture/environment_air = loc.return_air()
	if(!isnull(environment_air))
		if(windows.up)
			environment_air.pump_gas_to(air, environment_air.return_pressure())
		else if(loc)
			loc.assume_air(air.remove_ratio(1))

/// Toggles the hood of the car, if it has one.
/obj/vehicle/sealed/modular_car/proc/toggle_hood(mob/user)

/obj/vehicle/sealed/modular_car/remove_air(amount)
	if(are_windows_up())
		return air.remove(amount)
	return ..()

/obj/vehicle/sealed/modular_car/return_air()
	return are_windows_up() ? air : ..()

/obj/vehicle/sealed/modular_car/return_analyzable_air()
	return are_windows_up() ? air : ..()

/obj/vehicle/sealed/modular_car/return_temperature()
	var/datum/gas_mixture/our_air = return_air()
	return our_air?.return_temperature()

// prebuilt

/obj/vehicle/sealed/modular_car/prebuilt

/obj/vehicle/sealed/modular_car/prebuilt/Initialize(mapload)
	. = ..()
	equip_item(new_equipment = new /obj/item/modcar_equipment/wheels)
	equip_item(new_equipment = new /obj/item/modcar_equipment/engine)
	equip_item(new_equipment = new /obj/item/modcar_equipment/headlights)
