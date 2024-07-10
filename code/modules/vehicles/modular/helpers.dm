/obj/vehicle/sealed/modular_car/proc/get_all_parts()
	. = list()
	for(var/the_slot as anything in equipment)
		. += equipment[the_slot]

/// Returns the mutually exclusive part
/obj/vehicle/sealed/modular_car/proc/is_mutually_excluded(obj/item/modcar_equipment/the_item)
	. = FALSE
	if(!istype(the_item))
		return //bug
	for(var/obj/item/modcar_equipment/attached as anything in equipment)
		if(is_type_in_typecache(attached, the_item.mutually_exclusive_with))
			return attached
		if(is_type_in_typecache(the_item, attached.mutually_exclusive_with))
			return attached
