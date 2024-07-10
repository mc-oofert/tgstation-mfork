/obj/vehicle/sealed/modular_car
	/// car slot to max amount of equipment in that slot
	var/list/slot_max = list(
		CAR_ENGINE = 1, //duh
		CAR_PROPULSION = 1, //single set of four wheels or four thrusters
		CAR_MISC = 4,
	)
	/// list of attached equipment, format; slot = list(equipment)
	var/list/equipment = list()
