/obj/item/modcar_equipment/windows
	name = "windows"

	var/obj/item/stack/sheet/glass/glass_stack

	/// Current icon state for the glass overlay.
	var/glass_icon_state

	/// Are the windows made out of reinforced glass? (modifies overlay)
	var/reinforced

	/// Are the windows rolled down?
	var/rolled_down

/obj/item/modcar_equipment/windows/proc/roll_up()

/obj/item/modcar_equipment/windows/proc/roll_down()

/obj/item/modcar_equipment/windows/proc/set_stack(glass_stack)
	src.glass_stack = glass_stack
	reinforced = is_glass_sheet

/obj/item/modcar_equipment/windows/proc/get_overlay()
	var/icon_state = rolled_down ? glass_icon_state : glass_icon_state + "_down"

/obj/item/modcar_equipment/windows/get_drop_item()
	return glass_stack
