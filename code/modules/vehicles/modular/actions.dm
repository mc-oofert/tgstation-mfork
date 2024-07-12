/datum/action/vehicle/sealed/headlights/modcar
	button_icon_state = "vim_headlights"

/datum/action/vehicle/sealed/headlights/modcar/Trigger(trigger_flags)
	if(!vehicle_entered_target:equipment[CAR_SLOT_HEADLIGHTS])
		to_chat(owner, span_warning("You flip the switch for the vehicle's headlights, however nothing happens because there arent any installed. You get the feeling that you look like an idiot for not realizing that."))
		return
	return ..()

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
	name = "Roll Up/Down Windows"
	desc = "Toggles your windows. If the windows are rolled up, the car is airtight, otherwise not."
	background_icon = 'icons/mob/actions/actions_vehicle.dmi'
	background_icon_state = "background"
	button_icon_state = "modcar_windows"

/datum/action/vehicle/sealed/modcar_windows/IsAvailable(feedback = FALSE)
	var/obj/vehicle/sealed/modular_car/car = vehicle_entered_target
	if(!istype(car) || !car.equipment[CAR_SLOT_HEADLIGHTS])
		return FALSE
	return ..()

/datum/action/vehicle/sealed/modcar_windows/Trigger(trigger_flags)
	. = ..()
	var/obj/vehicle/sealed/modular_car/car = vehicle_entered_target
	if(!car.toggle_windows(owner))
		return //failed somehow
	car.balloon_alert(owner, "rolled [car.windows_up ? "up" : "down"], [car.windows_up ? "" : "no longer "]airtight!")
	// move balloon alert to the proc and also add sounds or do it here im not sure but i think the former might be better???
