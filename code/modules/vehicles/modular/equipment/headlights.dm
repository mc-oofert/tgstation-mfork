/obj/item/modcar_equipment/headlights
	name = "basic headlights"
	desc = "A regular set of car headlights."
	slot = CAR_SLOT_HEADLIGHTS
	var/range = 4
	var/power = 1
	var/headlight_color = COLOR_LIGHT_ORANGE

/obj/item/modcar_equipment/headlights/on_attach(mob/user)
	. = ..()
	RegisterSignal(chassis, COMSIG_LIGHT_EATER_ACT, PROC_REF(on_light_eater))
	chassis.set_light(l_range = range, l_power = power, l_color = headlight_color) //the car also works as a flashlight fyi

/obj/item/modcar_equipment/headlights/on_detach(mob/user)
	. = ..()
	UnregisterSignal(chassis, COMSIG_LIGHT_EATER_ACT)
	chassis.set_light(l_range = 0, l_power = 0, l_on = FALSE)

/obj/item/modcar_equipment/headlights/proc/on_light_eater(mob/living/carbon/human/source, datum/light_eater)
	SIGNAL_HANDLER
	qdel(src)
	return COMPONENT_BLOCK_LIGHT_EATER
