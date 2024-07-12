/obj/item/modcar_equipment/windows
	name = "windows"

	var/obj/item/stack/sheet/glass/glass_stack

/obj/item/modcar_equipment/windows/set_stack(glass_stack)
	src.glass_stack = glass_stack

/obj/item/modcar_equipment/windows/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if(!glass_stack || !chassis || old_loc != chassis) // in case someone creates special windows that aren't made from sheets, they are dropped instead (signified by glass_stack being null)
		return
	glass_stack.forceMove(chassis.drop_location())
	qdel(src)
