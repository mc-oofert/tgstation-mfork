/obj/item/modcar_equipment/windows
	name = "windows"

	/// The stack of glass used to make this.
	var/obj/item/stack/sheet/glass/glass_stack

	/// Current icon state for the glass overlay.
	var/glass_icon_state

	/// Are the windows made out of reinforced glass? (modifies overlay)
	var/reinforced

	/// Are the windows rolled down?
	var/rolled_down

/obj/item/modcar_equipment/windows/on_detach(mob/user)
	qdel(src)

/*/obj/item/modcar_equipment/windows/get_overlay()
	var/icon_state = rolled_down ? glass_icon_state + "_down" : glass_icon_state
	var/mutable_appearance/overlay = mutable_appearance('icons/mob/rideables/modular_car/chassis_64x64.dmi', icon_state) fix this shit when we have the overlays
	return overlay*/

/obj/item/modcar_equipment/windows/get_drop_item()
	return glass_stack

/obj/item/modcar_equipment/windows/proc/roll_up()

/obj/item/modcar_equipment/windows/proc/roll_down()

/obj/item/modcar_equipment/windows/proc/set_stack(stack)
	glass_stack = stack
	glass_stack.forceMove(src)
