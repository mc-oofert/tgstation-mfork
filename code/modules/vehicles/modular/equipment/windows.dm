/obj/item/modcar_equipment/windows
	name = "windows"

/obj/item/modcar_equipment/windows/on_attach(mob/user)

/obj/item/modcar_equipment/windows/on_detach(mob/user)
	for(var/atom/movable/cont as anything in contents)
		cont.forceMove(chassis.drop_location())
		user?.put_in_hands(cont)

