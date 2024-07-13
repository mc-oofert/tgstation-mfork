/obj/item/modcar_equipment/thrusters
	name = "basic thrusters"
	desc = "A set of spaceworthy car thrusters. Barely works in gravity."
	slot = CAR_SLOT_PROPULSION

/obj/item/modcar_equipment/thrusters/get_speed_multiplier()
	return chassis.has_gravity() ? 0.2 : 1

/obj/item/modcar_equipment/thrusters/on_attach(mob/user)
	. = ..()
	RegisterSignal(chassis, COMSIG_MOVABLE_MOVED, PROC_REF(carmoved))

/obj/item/modcar_equipment/thrusters/on_detach(mob/user)
	. = ..()
	UnregisterSignal(chassis, COMSIG_MOVABLE_MOVED)

/obj/item/modcar_equipment/thrusters/proc/carmoved(atom/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER
	if(forced)
		return
	QDEL_IN(new /obj/effect/particle_effect/ion_trails(old_loc), 1 SECONDS)
