/datum/action/vehicle/sealed/headlights/modcar
	button_icon_state = "vim_headlights"

/datum/action/vehicle/sealed/headlights/modcar/IsAvailable(feedback)
	var/obj/vehicle/sealed/modular_car/car = vehicle_entered_target
	if(!car.equipment[CAR_SLOT_HEADLIGHTS])
		if(feedback)
			car.balloon_alert(owner, "no headlights!")
		return FALSE
	return ..()

/datum/action/vehicle/sealed/headlights/modcar/Trigger(trigger_flags)
	. = ..()
	var/obj/vehicle/sealed/modular_car/car = vehicle_entered_target
	car.toggle_headlights(owner)

/datum/action/vehicle/sealed/modcar_hood
	name = "Toggle Hood Lock"
	desc = "Toggles your hood, necessary for removal and adding of parts."
	background_icon = 'icons/mob/actions/actions_vehicle.dmi'
	background_icon_state = "background"
	button_icon_state = "modcar_hood"

/datum/action/vehicle/sealed/modcar_hood/Trigger(trigger_flags)
	. = ..()
	var/obj/vehicle/sealed/modular_car/car = vehicle_entered_target
	car.hood_open = !car.hood_open
	if(car.hood_open)
		playsound(car, 'sound/effects/bin_open.ogg', 50, TRUE)
	else
		playsound(car, 'sound/effects/bin_close.ogg', 50, TRUE)

	car.update_appearance()

/datum/action/vehicle/sealed/modcar_windows
	name = "Toggle Windows"
	desc = "Toggles your windows. If the windows are up, the car is airtight."
	background_icon = 'icons/mob/actions/actions_vehicle.dmi'
	background_icon_state = "background"
	button_icon_state = "modcar_windows"

/datum/action/vehicle/sealed/modcar_windows/IsAvailable(feedback = FALSE)
	var/obj/vehicle/sealed/modular_car/car = vehicle_entered_target
	if(!car.equipment[CAR_SLOT_WINDOWS])
		if(feedback)
			car.balloon_alert(owner, "no windows!")
		return FALSE
	return ..()

/datum/action/vehicle/sealed/modcar_windows/Trigger(trigger_flags)
	. = ..()
	var/obj/vehicle/sealed/modular_car/car = vehicle_entered_target
	car.toggle_windows(owner)
