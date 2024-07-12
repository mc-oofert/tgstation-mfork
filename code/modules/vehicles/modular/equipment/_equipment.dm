/obj/item/modcar_equipment
	name = "generic modcar equipment"
	desc = "this is a bug call a coder"
	/// the slot we go in
	var/slot
	/// the chassis we are attached to, null if not
	var/obj/vehicle/sealed/modular_car/chassis

/obj/item/modcar_equipment/Destroy(force)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(unequip)) // there is a do_after that can't be met in the proc hierarchy so thats why this is how it is

/// Return either the icon_state as a string or an overlay outright
/obj/item/modcar_equipment/proc/get_overlay()

/obj/item/modcar_equipment/proc/on_attach(mob/user)

/obj/item/modcar_equipment/proc/on_detach(mob/user)

/obj/item/modcar_equipment/proc/unequip()
	chassis?.unequip_item(null, src)

/// Return FALSE to prevent attaching
/obj/item/modcar_equipment/proc/can_attach(mob/user, obj/target_chassis)
	return TRUE

/obj/item/modcar_equipment/proc/get_speed_multiplier()
	return 1
