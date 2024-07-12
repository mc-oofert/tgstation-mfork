/obj/item/modcar_equipment/wheels
	name = "basic wheels"
	desc = "A regular set of car wheels."
	slot = CAR_SLOT_WHEELS

	var/wheel_icon_state = "wheels"
	var/wheel_height = 5

/obj/item/modcar_equipment/wheels/get_speed_multiplier()
	return chassis.has_gravity()

/obj/item/modcar_equipment/wheels/get_overlay()
	var/atom/overlay = mutable_appearance(chassis.icon, wheel_icon_state)
	overlay.pixel_y = -wheel_height
	return overlay

/obj/item/modcar_equipment/wheels/on_attach(mob/user)
	chassis.pixel_y += wheel_height

/obj/item/modcar_equipment/wheels/on_detach(mob/user)
	chassis.pixel_y -= wheel_height

/obj/item/modcar_equipment/wheels/thrusters
	name = "basic thrusters"
	desc = "A set of spaceworthy car thrusters. Barely works in gravity."

/obj/item/modcar_equipment/wheels/thrusters/get_speed_multiplier()
	return chassis.has_gravity() ? 0.2 : 1

/obj/item/modcar_equipment/wheels/thrusters/on_attach(mob/user)
	. = ..()
	RegisterSignal(chassis, COMSIG_MOVABLE_MOVED, PROC_REF(carmoved))

/obj/item/modcar_equipment/wheels/thrusters/on_detach(mob/user)
	. = ..()
	UnregisterSignal(chassis, COMSIG_MOVABLE_MOVED)

/obj/item/modcar_equipment/wheels/thrusters/proc/carmoved(atom/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER
	if(forced)
		return
	QDEL_IN(new /obj/effect/particle_effect/ion_trails(old_loc), 1 SECONDS)
