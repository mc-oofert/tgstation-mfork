/obj/item/modcar_equipment/windows
	name = "windows"
	slot = CAR_SLOT_WINDOWS

	/// The stack of glass used to make this.
	var/obj/item/stack/sheet/glass/glass_stack

	/// Current base icon state for the glass overlay.
	var/glass_icon_state = "windows"

	/// Are the windows made out of reinforced glass? (modifies overlay)
	var/reinforced

	/// Are the windows up or rolled down?
	var/up

	var/mutable_appearance/overlay

/obj/item/modcar_equipment/windows/on_detach(mob/user)
	qdel(src)

/obj/item/modcar_equipment/windows/get_overlay()
	if(!overlay)
		overlay = mutable_appearance(chassis.icon, get_overlay_icon_state())
	return overlay

/obj/item/modcar_equipment/windows/get_drop_item()
	return glass_stack

/obj/item/modcar_equipment/windows/proc/get_overlay_icon_state()
	return "[glass_icon_state]_[up ? "up" : "down"]"

/// Toggles whether or not the windows are up or down.
/obj/item/modcar_equipment/windows/proc/toggle_state()
	set_state(!up)

/obj/item/modcar_equipment/windows/proc/set_state(up)
	if(src.up == up)
		return

	src.up = up

	if(overlay)
		overlay.icon_state = get_overlay_icon_state()
		flick("[glass_icon_state]_roll[up ? "up" : "down"]", overlay)

/obj/item/modcar_equipment/windows/proc/set_stack(stack)
	glass_stack = stack
	glass_stack.forceMove(src)
