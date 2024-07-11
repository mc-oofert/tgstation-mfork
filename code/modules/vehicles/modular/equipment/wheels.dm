/obj/item/modcar_equipment/wheels
	name = "basic wheels"
	desc = "A regular set of car wheels."
	slot = CAR_SLOT_WHEELS

	var/wheel_icon_state = "basic_wheels"
	var/wheel_height = 6

/obj/item/modcar_equipment/wheels/get_speed_multiplier()
	return chassis.has_gravity()

/obj/item/modcar_equipment/wheels/get_overlay()
	var/atom/overlay = mutable_appearance('icons/mob/rideables/modular_car/chassis_64x64.dmi', wheel_icon_state)
	overlay.pixel_y = -wheel_height
	return overlay

/obj/item/modcar_equipment/wheels/on_attach()
	chassis.pixel_y += wheel_height

/obj/item/modcar_equipment/wheels/on_detach()
	chassis.pixel_y -= wheel_height
