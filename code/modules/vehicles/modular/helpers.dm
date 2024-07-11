/obj/vehicle/sealed/modular_car/proc/get_all_parts()
	. = list()
	for(var/the_slot as anything in equipment)
		. += equipment[the_slot]
