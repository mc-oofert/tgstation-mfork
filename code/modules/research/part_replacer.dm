///RPED. Allows installing & exchaging parts on machines
/obj/item/storage/part_replacer
	name = "rapid part exchange device"
	desc = "Special mechanical module made to store, sort, and apply standard machine parts."
	icon_state = "RPED"
	inhand_icon_state = "RPED"
	worn_icon_state = "RPED"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	storage_type = /datum/storage/rped

/obj/item/storage/part_replacer/interact_with_atom(obj/attacked_object, mob/living/user, list/modifiers)
	if(user.combat_mode || !istype(attacked_object) || HAS_TRAIT(attacked_object, TRAIT_COMBAT_MODE_SKIP_INTERACTION))
		return ITEM_INTERACT_SKIP_TO_ATTACK

	//its very important to NOT block so frames can still interact with it
	if(!ismachinery(attacked_object) || istype(attacked_object, /obj/machinery/computer))
		return NONE

	var/obj/machinery/attacked_machinery = attacked_object
	if(!LAZYLEN(attacked_machinery.component_parts))
		return ITEM_INTERACT_FAILURE

	return attacked_machinery.exchange_parts(user, src) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_FAILURE

///Plays the sound for RPED exhanging or installing parts.
/obj/item/storage/part_replacer/proc/play_rped_sound()
	playsound(src, 'sound/items/tools/rped.ogg', 40, TRUE)

/**
 * Gets parts sorted in order of their tier
 * Arguments
 *
 * * ignore_stacks - should the final list contain stacks
 */
/obj/item/storage/part_replacer/proc/get_sorted_parts(ignore_stacks = FALSE)
	RETURN_TYPE(/list/obj/item)

	var/list/obj/item/part_list = list()
	//Assemble a list of current parts, then sort them by their rating!
	for(var/obj/item/component_part in contents)
		//No need to put circuit boards in this list or stacks when exchanging parts
		if(istype(component_part, /obj/item/circuitboard) || (ignore_stacks && istype(component_part, /obj/item/stack)))
			continue
		part_list += component_part
		//Sort the parts. This ensures that higher tier items are applied first.
	sortTim(part_list, GLOBAL_PROC_REF(cmp_rped_sort))

	return part_list

///Bluespace RPED. Allows exchanging parts from a distance & through cameras
/obj/item/storage/part_replacer/bluespace
	name = "bluespace rapid part exchange device"
	desc = "A version of the RPED that allows for replacement of parts and scanning from a distance, along with higher capacity for parts."
	icon_state = "BS_RPED"
	inhand_icon_state = "BS_RPED"
	w_class = WEIGHT_CLASS_NORMAL
	storage_type = /datum/storage/rped/bluespace

/obj/item/storage/part_replacer/bluespace/Initialize(mapload)
	. = ..()

	RegisterSignal(src, COMSIG_ATOM_ENTERED, PROC_REF(on_part_entered))
	RegisterSignal(src, COMSIG_ATOM_EXITED, PROC_REF(on_part_exited))

/obj/item/storage/part_replacer/bluespace/interact_with_atom(obj/attacked_object, mob/living/user, list/modifiers)
	. = ..()
	if(. & ITEM_INTERACT_ANY_BLOCKER)
		user.Beam(attacked_object, icon_state = "rped_upgrade", time = 0.5 SECONDS)

/obj/item/storage/part_replacer/bluespace/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	return interact_with_atom(interacting_with, user, modifiers)

/obj/item/storage/part_replacer/bluespace/play_rped_sound()
	if(prob(1))
		playsound(src, 'sound/items/pshoom/pshoom_2.ogg', 40, TRUE)
		return
	playsound(src, 'sound/items/pshoom/pshoom.ogg', 40, TRUE)

/**
 * Signal handler for when a part has been inserted into the BRPED.
 *
 * If the inserted item is a rigged or corrupted cell, does some logging.
 *
 * If it has a reagent holder, clears the reagents and registers signals to prevent new
 * reagents being added and registers clean up signals on inserted item's removal from
 * the BRPED.
 */
/obj/item/storage/part_replacer/bluespace/proc/on_part_entered(datum/source, obj/item/inserted_component)
	SIGNAL_HANDLER

	if(istype(inserted_component, /obj/item/stock_parts/power_store))
		var/obj/item/stock_parts/power_store/inserted_cell = inserted_component
		if(inserted_cell.rigged || inserted_cell.corrupted)
			message_admins("[ADMIN_LOOKUPFLW(usr)] has inserted rigged/corrupted [inserted_cell] into [src].")
			usr.log_message("has inserted rigged/corrupted [inserted_cell] into [src].", LOG_GAME)
			usr.log_message("inserted rigged/corrupted [inserted_cell] into [src]", LOG_ATTACK)
		return

	if(inserted_component.reagents)
		if(length(inserted_component.reagents.reagent_list))
			inserted_component.reagents.clear_reagents()
			to_chat(usr, span_notice("[src] churns as [inserted_component] has its reagents emptied into bluespace."))
		RegisterSignal(inserted_component.reagents, COMSIG_REAGENTS_PRE_ADD_REAGENT, PROC_REF(on_insered_component_reagent_pre_add))

/**
 * Signal handler for when the reagents datum of an inserted part has reagents added to it.
 *
 * Registers the PRE_ADD variant which allows the signal handler to stop reagents being
 * added.
 *
 * Simply returns COMPONENT_CANCEL_REAGENT_ADD. We never want to allow people to add
 * reagents to beakers in BRPEDs as they can then be used for spammable remote bombing.
 */
/obj/item/storage/part_replacer/bluespace/proc/on_insered_component_reagent_pre_add(datum/source, reagent, amount, reagtemp, data, no_react)
	SIGNAL_HANDLER

	return COMPONENT_CANCEL_REAGENT_ADD

/**
 * Signal handler for a part is removed from the BRPED.
 *
 * Does signal registration cleanup on its reagents, if it has any.
 */
/obj/item/storage/part_replacer/bluespace/proc/on_part_exited(datum/source, obj/item/removed_component)
	SIGNAL_HANDLER

	if(removed_component.reagents)
		UnregisterSignal(removed_component.reagents, COMSIG_REAGENTS_PRE_ADD_REAGENT)

//RPED with tiered contents
/obj/item/storage/part_replacer/bluespace/tier1/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/stock_parts/capacitor(src)
		new /obj/item/stock_parts/scanning_module(src)
		new /obj/item/stock_parts/servo(src)
		new /obj/item/stock_parts/micro_laser(src)
		new /obj/item/stock_parts/matter_bin(src)
		new /obj/item/stock_parts/power_store/cell/high(src)

/obj/item/storage/part_replacer/bluespace/tier2/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/stock_parts/capacitor/adv(src)
		new /obj/item/stock_parts/scanning_module/adv(src)
		new /obj/item/stock_parts/servo/nano(src)
		new /obj/item/stock_parts/micro_laser/high(src)
		new /obj/item/stock_parts/matter_bin/adv(src)
		new /obj/item/stock_parts/power_store/cell/super(src)

/obj/item/storage/part_replacer/bluespace/tier3/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/stock_parts/capacitor/super(src)
		new /obj/item/stock_parts/scanning_module/phasic(src)
		new /obj/item/stock_parts/servo/pico(src)
		new /obj/item/stock_parts/micro_laser/ultra(src)
		new /obj/item/stock_parts/matter_bin/super(src)
		new /obj/item/stock_parts/power_store/cell/hyper(src)

/obj/item/storage/part_replacer/bluespace/tier4/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/stock_parts/capacitor/quadratic(src)
		new /obj/item/stock_parts/scanning_module/triphasic(src)
		new /obj/item/stock_parts/servo/femto(src)
		new /obj/item/stock_parts/micro_laser/quadultra(src)
		new /obj/item/stock_parts/matter_bin/bluespace(src)
		new /obj/item/stock_parts/power_store/cell/bluespace(src)

//used in a cargo crate
/obj/item/storage/part_replacer/cargo/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/stock_parts/capacitor(src)
		new /obj/item/stock_parts/scanning_module(src)
		new /obj/item/stock_parts/servo(src)
		new /obj/item/stock_parts/micro_laser(src)
		new /obj/item/stock_parts/matter_bin(src)

///Cyborg variant
/obj/item/storage/part_replacer/cyborg
	name = "rapid part exchange device"
	desc = "Special mechanical module made to store, sort, and apply standard machine parts. This one has an extra large compartment for more parts."
	icon_state = "borgrped"
	inhand_icon_state = "RPED"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	storage_type = /datum/storage/rped/bluespace
