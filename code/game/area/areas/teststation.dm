/area/misc/testroom
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	name = "Test Room"
	icon_state = "test_room"

/area/misc/testroom/chamber
	name = "Test Chamber"

/area/misc/testroom/toxatmos
	name = "Teststation Atmospherics"
/area/misc/testroom/botany
	name = "Teststation Botany"
/area/misc/testroom/dbgroom
	name = "Teststation Debug Tool Room"
/area/misc/testroom/cargo
	name = "Teststation Cargo Bay"
/area/misc/testroom/engineercloset
	name = "Teststation Engineering Hole"
/area/misc/testroom/stairway
	name = "Teststation Stairway"
/area/misc/testroom/stairway/second
	name = "Teststation Stairway 2"
/area/misc/testroom/armory
	name = "Teststation Armory"
/area/misc/testroom/medical
	name = "Teststation Medical"
/area/misc/testroom/arrivals
	name = "Teststation Arrivals"
/area/misc/testroom/supermatter
	name = "Teststation Supermatter Room"
/area/misc/testroom/ce
	name = "Teststation Chief Engineer Office"
/area/misc/testroom/kitchen
	name = "Teststation Kitchen"
/area/misc/testroom/coldroom
	name = "Teststation Freezer"
/area/misc/testroom/theatre
	name = "Teststation Theatre"
/area/misc/testroom/theatrebackstage
	name = "Teststation Theatre Backstage"
/area/misc/testroom/recreationhall
	name = "Teststation Recreational Hall"
/area/misc/testroom/arcade
	name = "Teststation Arcade"
/area/misc/testroom/Bar
	name = "Teststation Bar"
	
/area/misc/testroom/maintenance
	name = "Teststation Maintenance"
/area/misc/testroom/maintenance/central
	name = "Teststation Central Maintenance"
/area/misc/testroom/maintenance/midtele
	name = "Teststation Command Maintenance"
/area/misc/testroom/maintenance/dorms 
	name = "Teststation Port Maintenance"


/area/misc/testroom/library
	name = "Teststation Library"
/area/misc/testroom/halls
	name = "Teststation Hallways"
/area/misc/testroom/janitor
	name = "Teststation Janitorial Closet"
/area/misc/testroom/showers
	name = "Teststation Showers"
/area/misc/testroom/restrooms
	name = "Teststation Restrooms"
/area/misc/testroom/dorms
	name = "Teststation Dorms"
/area/misc/testroom/cabin1
	name = "Teststation Cabin 1"
/area/misc/testroom/cabin2
	name = "Teststation Cabin 2"
/area/misc/testroom/cabin3
	name = "Teststation Cabin 3"
/area/misc/testroom/cabin4
	name = "Teststation Cabin 4"
/area/misc/testroom/cabin5
	name = "Teststation Cabin 5"
/area/misc/testroom/cabin6
	name = "Teststation Cabin 6"
/area/misc/testroom/halls
	name = "Teststation Central Hall"
/area/misc/testroom/halls/left
	name = "Teststation Port Hall"
/area/misc/testroom/halls/right
	name = "Teststation Starboard Hall"
/area/misc/testroom/halls/up
	name = "Teststation Fore Hall"
/area/misc/testroom/halls/down
	name = "Teststation South Hall"	
/area/misc/testroom/halls/command
	name = "Teststation Command Hall"	
/area/misc/testroom/garden
	name = "Teststation Garden"
/area/misc/testroom/techstorage
	name = "Teststation Tech Storage"
	/area/misc/testroom/sectech
	name = "Teststation Secure Tech Storage"
/area/misc/testroom/auxtool
	name = "Teststation Auxiliary Tool Storage"
/area/misc/testroom/robotics
	name = "Teststation Robotics"
/area/misc/testroom/depsec/dorms
	name = "Teststation Dorms Security"
/area/misc/testroom/upload
	name = "Teststation Upload"
/area/misc/testroom/bridge
	name = "Teststation Bridge"
/area/misc/testroom/showroom
	name = "Teststation Corporate Showroom"
/area/misc/testroom/captain
	name = "Teststation Captains Quarters"
/area/misc/testroom/hop
	name = "Teststation Head Of Personnels Office"
/area/misc/testroom/gateway
	name = "Teststation Gateway"
/area/misc/testroom/tele
	name = "Teststation Teleporter Room"
/area/misc/testroom/commandstorage
	name = "Teststation Command Storage"
/area/misc/testroom/commisary
	name = "Teststation Vacant Commisary"
/area/station/holodeck/testroom
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	name = "\improper Teststation Recreational Holodeck"
/area/misc/testroom/science
	name = "Teststation Research Division"
/area/misc/testroom/science/genetics
	name = "Teststation Genetics"
/area/misc/testroom/science/rnd
	name = "Teststation Research And Development"

/turf/open/floor/plating/indestructible
/turf/open/floor/plating/indestructible/singularity_act()
	return
/turf/open/floor/plating/indestructible/singularity_pull(S, current_size)
	return
/turf/open/floor/plating/indestructible/crush()
	return
/turf/open/floor/plating/indestructible/break_tile_to_plating()
	return
/turf/open/floor/plating/indestructible/break_tile()
	return
/turf/open/floor/plating/indestructible/burn_tile()
	return
/turf/open/floor/plating/indestructible/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	if(passed_mode == RCD_DECONSTRUCT)
		return
	return ..()
/turf/open/floor/plating/indestructible/burn()
	return
/turf/open/floor/plating/indestructible/narsie_act(force, ignore_mobs, probability = 20)
	return
/turf/open/floor/plating/indestructible/ex_act(severity, target)
	return
/turf/open/floor/plating/indestructible/acid_melt()
	src.hotspot_expose(1000,CELL_VOLUME)
	return

/turf/open/floor/indestructible
	icon_state = "white"
	base_icon_state = "white"
	baseturfs = /turf/open/floor/plating/indestructible

/turf/open/floor/indestructible/singularity_act()
	return
/turf/open/floor/indestructible/singularity_pull(S, current_size)
	return
/turf/open/floor/indestructible/crush()
	return
/turf/open/floor/indestructible/break_tile_to_plating()
	return
/turf/open/floor/indestructible/break_tile()
	return
/turf/open/floor/indestructible/burn_tile()
	return
/turf/open/floor/indestructible/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	if(passed_mode == RCD_DECONSTRUCT)
		return
	return ..()
/turf/open/floor/indestructible/burn()
	return
/turf/open/floor/indestructible/narsie_act(force, ignore_mobs, probability = 20)
	return
/turf/open/floor/indestructible/ex_act(severity, target)
	return
/turf/open/floor/indestructible/acid_melt()
	src.hotspot_expose(1000,CELL_VOLUME)
	return
/turf/open/floor/indestructible/ScrapeAway(amount=1, flags)
	return
/turf/open/floor/indestructible/white
	floor_tile = /obj/item/stack/tile/indestructible

/turf/open/floor/indestructible/dark
	icon_state = "darkfull"
	base_icon_state = "darkfull"
	floor_tile = /obj/item/stack/tile/indestructible/dark

/turf/open/floor/indestructible/regular
	icon_state = "floor"
	base_icon_state = "floor"
	floor_tile = /obj/item/stack/tile/indestructible/regular

/turf/open/floor/indestructible/carpet
	icon_state = "carpet-255"
	base_icon_state = "carpet"
	icon = 'icons/turf/floors/carpet.dmi'
	floor_tile = /obj/item/stack/tile/indestructible/carpet
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET)
	canSmoothWith = list(SMOOTH_GROUP_CARPET)

/turf/open/floor/indestructible/wood
	base_icon_state = "wood"
	icon_state = "wood"
	footstep = FOOTSTEP_WOOD
	tiled_dirt = FALSE
	floor_tile = /obj/item/stack/tile/indestructible/wood

/obj/item/stack/tile/indestructible
	name = "indestructible white tile"
	singular_name = "indestructible white floor tile"
	icon_state = "tile_white"
	turf_type = /turf/open/floor/indestructible
	merge_type = /obj/item/stack/tile/indestructible
/obj/item/stack/tile/indestructible/dark
	name = "indestructible dark tile"
	singular_name = "indestructible dark floor tile"
	icon_state = "tile_dark"
	turf_type = /turf/open/floor/indestructible/dark
	merge_type = /obj/item/stack/tile/indestructible/dark
/obj/item/stack/tile/indestructible/regular
	name = "indestructible tile"
	singular_name = "indestructible floor tile"
	icon_state = "tile"
	turf_type = /turf/open/floor/indestructible/regular
	merge_type = /obj/item/stack/tile/indestructible/regular
/obj/item/stack/tile/indestructible/carpet
	name = "indestructible carpet tiles"
	singular_name = "indestructible carpet tile"
	icon_state = "tile-carpet"
	turf_type = /turf/open/floor/indestructible/carpet
	merge_type = /obj/item/stack/tile/indestructible/carpet
/obj/item/stack/tile/indestructible/wood
	name = "indestructible wood tiles"
	singular_name = "indestructible wood tile"
	icon_state = "tile-wood"
	turf_type = /turf/open/floor/indestructible/wood
	merge_type = /obj/item/stack/tile/indestructible/wood
/obj/structure/closet/can_synthesizer
	name = "\improper debug canister factory"
	desc = "If you see this, yell at adminbus."
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	can_weld_shut = FALSE
	allow_objects = TRUE
	allow_dense = TRUE
	divable = FALSE
	can_install_electronics = FALSE
	///kelvin
	var/temperature = 235
	var/moles = 3500
	var/obj/machinery/portable_atmospherics/canister/can
/obj/structure/closet/can_synthesizer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		if(opened)
			close()
		ui = new(user, src, "debugcanmaker", name)
		ui.open()
/obj/structure/closet/can_synthesizer/after_close(mob/living/user)
	for(var/obj/machinery/portable_atmospherics/canister/c in contents)
		can = c
/obj/structure/closet/can_synthesizer/open(mob/living/user, force = FALSE)
	. = ..()
	can = null
/obj/structure/closet/can_synthesizer/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("removecan")
			if(can)
				open(force = TRUE)
				. = TRUE
		if("addgas")
			var/id_of_gas = (input("Enter a gas ID (no checks)", "Input") as text|null)
			var/datum/gas/gas = gas_exists(id_of_gas)
			if(isnull(gas))
				say("GAS NOT FOUND")
				return FALSE
			if(!can)
				return FALSE
			var/datum/gas_mixture/merger = new
			merger.assert_gas(gas)
			merger.gases[gas][MOLES] = moles
			merger.temperature = temperature
			can.air_contents.merge(merger)
			can.update_appearance()
			. = TRUE
		if("makecan")
			if(can)
				return
			if(opened)
				close()
			can = new /obj/machinery/portable_atmospherics/canister(src)
			can.internal_cell = new /obj/item/stock_parts/cell/infinite(can)
			can.create_gas()
			can.shielding_powered = TRUE
			visible_message(span_notice("[src] produces a new canister."))
		if("temperature")
			var/input = text2num(params["amount"])
			if(input)
				temperature = input
		if("moles")
			var/input = text2num(params["amount"])
			if(input)
				moles = input
	update_appearance()

/obj/structure/closet/can_synthesizer/Destroy()
	QDEL_NULL(can)
	return ..()

/obj/structure/closet/can_synthesizer/ui_data(mob/user)
	. = ..()
	if(can)
		.["canisterLoaded"] = TRUE
		.["gasmixed"] = gas_mixture_parser(can.air_contents, can.name)
	else
		.["canisterLoaded"] = FALSE
	.["temperature"] = temperature
	.["moles"] = moles
	return .

/obj/structure/closet/can_synthesizer/proc/gas_exists(input)
	. = FALSE
	var/datum/gas/gas = gas_id2path(input)
	if(gas != null)
		return gas

/turf/open/floor/catwalk_floor/iron_dark/teststation
	name = "dark plated catwalk floor"
	icon_state = "darkiron_above"
	floor_tile = /obj/item/stack/tile/catwalk_tile/iron_dark
	catwalk_type = "darkiron"
	baseturfs = /turf/open/misc/asteroid/basalt/teststation