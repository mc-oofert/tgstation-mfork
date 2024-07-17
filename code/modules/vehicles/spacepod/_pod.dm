//
// space pods
//

// TODO:
// proper space movement
// construction
// equipment
// make them move different onstation, perhaps restrict to engine tiles only
// control scheme/whatever idk how to drive these
// slots: comms (radio and something else), sensors(HUDs or something, mesons??), engine, 1 secondary slot (cargo and shit), 1 primary slot(tools or gun???), infinite misc modules (locks and shit), armor would either be added during construction or as a slot
// power costs, either only megacell or only cell, how would you charge this??
// although im not so sure about power costs i dont know why it would need them but ideally a space pod should be capable of functioning for 10-15 minutes of nonstop acceleration by default
// innate armor potentially, also actual armor and also figure out integrity and inertia_force_weight
// ALSO DO NOT FORGET TO REMOVE THIS HUGE ASS COMMENT before finishing

/obj/vehicle/sealed/space_pod
	layer = ABOVE_MOB_LAYER
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	resistance_flags = FIRE_PROOF | ACID_PROOF
	icon = 'icons/mob/rideables/vehicles.dmi' //placeholder
	icon_state = "engineering_pod" //placeholder
	light_system = OVERLAY_LIGHT_DIRECTIONAL
	light_on = FALSE
	/// air in the pod
	var/datum/gas_mixture/air = new(TANK_STANDARD_VOLUME * 5)
	/// Max count of a certain slot. If it is not defined here, it is assumed to be one (1)
	var/list/slot_max = list(
		POD_SLOT_MISC = 3,
	)
	/// Equipment we have, slot = equipment, or slot = list(equipment)
	var/list/equipped = list()
	/// is our panel open? required for adding and removing parts
	var/panel_open = FALSE
	/// ion trail effect
	var/datum/effect_system/trail_follow/ion/trail
	/// max drift speed we can get via moving intentionally
	var/max_speed = 10 NEWTONS //fucking balls value change this
	/// Force per tick movement held down
	var/force_per_move = 3 NEWTONS
	/// Force per process run to bring us to a halt
	var/stabilizer_force = 1 NEWTONS
	/// are stabilizers on
	var/stabilizers_on = FALSE
	/// is our cabin closed? if so, retain atmos
	var/closed_cabin = FALSE // figure out how to do this properly, generally exitting the pod and venting everything to space is bad
	// but the cabin is empty by default so how would we do this?? innate air tank??? air tank slot???
	// air tank slot is maybe a good choice but we can also make it inserted via maintenance panel
	// like imagine you find someones unguarded pod and replace its tank with hot plasma that would be extremely funny


/obj/vehicle/sealed/space_pod/Initialize(mapload)
	. = ..()
	trail = new
	trail.auto_process = FALSE
	trail.set_up(src)
	trail.start()
	// todo
	//START_PROCESSING(SSnewtonian_movement, src)

/obj/vehicle/sealed/space_pod/Destroy()
	. = ..()
	QDEL_NULL(air)
	equipped = null // equipment gets deleted already because its in our contents

/obj/vehicle/sealed/space_pod/update_overlays()
	. = ..()
	for(var/obj/item/pod_equipment/equipment as anything in get_all_parts())
		var/overlay = equipment.get_overlay()
		if(isnull(overlay))
			continue
		. += overlay

/*
/obj/vehicle/sealed/space_pod/process()
	if (!stabilizers_on || isnull(user.drift_handler))
		return

	var/max_drift_force = (DEFAULT_INERTIA_SPEED / user.cached_multiplicative_slowdown - 1) / INERTIA_SPEED_COEF + 1
	drift_handler.stabilize_drift(dir2angle(dir), user.client.intended_direction ? max_drift_force : 0, stabilizer_force)
*/

/obj/vehicle/sealed/space_pod/vehicle_move(direction)
	. = ..()
	if(has_gravity())
		if(!COOLDOWN_FINISHED(src, cooldown_vehicle_move))
			return
		COOLDOWN_START(src, cooldown_vehicle_move, 1 SECONDS) // INTENTIONALLY make it painful to use onstation
		after_move(direction)
		return try_step_multiz(direction)
	if(direction != dir)
		setDir(direction) //first press changes dir
		return
	trail.generate_effect()
// may or may not work havent tested
	newtonian_move(dir2angle(dir), drift_force = force_per_move, controlled_cap = max_speed)
	setDir(direction)

// atmos
/obj/vehicle/sealed/space_pod/remove_air(amount)
	return closed_cabin ? air.remove(amount) : ..()
/obj/vehicle/sealed/space_pod/return_air()
	return closed_cabin ? air : ..()
/obj/vehicle/sealed/space_pod/return_analyzable_air()
	return air
/obj/vehicle/sealed/space_pod/return_temperature()
	var/datum/gas_mixture/air = return_air()
	return air?.return_temperature()

/obj/vehicle/sealed/space_pod/proc/toggle_air_seal(mob/user, state)
	// some sort of cooldown?

	closed_cabin = state

	var/datum/gas_mixture/outside_air = loc.return_air()
	if(!isnull(outside_air))
		if(closed_cabin)
			outside_air.pump_gas_to(air, outside_air.return_pressure())
		else
			loc.assume_air(air.remove_ratio(1))

	//visual or sound feedback idk???

