/obj/item/modcar_equipment
	name = "generic modcar equipment"
	desc = "this is a bug call a coder"
	/// the slot we go in
	var/slot = CAR_MISC
	/// Typecache of parts we are exclusive with, this means if it and all subtypes are present you may not put this part in
	var/list/mutually_exclusive_with
	/// the chassis we are attached to, null if not
	var/obj/vehicle/sealed/modular_car/chassis

/obj/item/modcar_equipment/Destroy(force)
	. = ..()
	chassis = null

/obj/item/modcar_equipment/proc/on_attach()

/obj/item/modcar_equipment/proc/on_detach()
