/obj/item/modcar_equipment/windows
	name = "windows"

	var/obj/item/stack/sheet/glass/glass_stack

/obj/item/modcar_equipment/windows/proc/set_stack(glass_stack)
	src.glass_stack = glass_stack

/obj/item/modcar_equipment/windows/get_drop_item()
	return glass_stack
