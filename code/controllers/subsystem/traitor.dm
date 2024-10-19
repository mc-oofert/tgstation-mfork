SUBSYSTEM_DEF(traitor)
	name = "Traitor"
	flags = SS_NO_FIRE

	/// A list of all uplink items mapped by type
	var/list/uplink_items_by_type = list()
	/// A list of all uplink items
	var/list/uplink_items = list()


/datum/controller/subsystem/traitor/Initialize()
	return SS_INIT_SUCCESS
