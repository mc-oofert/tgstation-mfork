/obj/vehicle/sealed/modular_car
	layer = ABOVE_MOB_LAYER
	move_resist = MOVE_FORCE_VERY_STRONG
	icon = 'icons/mob/rideables/vehicles.dmi'
	icon_state = "engineering_pod" //placeholder

//unoverride this bullshit
/obj/vehicle/sealed/modular_car/relaymove(mob/living/user, direction)
	. = FALSE
	if(!canmove)
		return
	if(!is_driver(user))
		return
	return relaydrive(user, direction)

/obj/vehicle/sealed/modular_car/relaydrive(mob/living/user, direction)
	. = ..()
	if(!.)
		return
	//canmove is already checked in relaymove
	vehicle_move(direction)

/obj/vehicle/sealed/modular_car/vehicle_move(direction)
	//movement goes here
