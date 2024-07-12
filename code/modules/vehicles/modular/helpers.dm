/obj/vehicle/sealed/modular_car/proc/get_all_parts()
	. = list()
	for(var/the_slot as anything in equipment)
		. += equipment[the_slot]

/// Returns whether or not the windows are up. Returns FALSE if there aren't any.
/obj/vehicle/sealed/modular_car/proc/are_windows_up()
	var/obj/item/modcar_equipment/windows/windows = equipment[CAR_SLOT_WINDOWS]
	return windows?.up
