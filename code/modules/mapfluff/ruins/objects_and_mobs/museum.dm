/obj/machinery/computer/terminal/museum
	name = "exhibit info terminal"
	desc = "A relatively low-tech info board. Not as low-tech as an actual sign though. Appears to be quite old."
	upperinfo = "Nanotrasen Museum Exhibit Info"
	icon_state = "plaque"
	icon_screen = "plaque_screen"
	icon_keyboard = null

/obj/effect/replica_spawner //description and name are intact, better to make a new fluff object for stuff that is not actually ingame as an object
	name = "replica creator"
	desc = "This creates a fluff object that looks exactly like the input, but like obviously a replica. Do not for the love of god use with stuff that has Initialize sideeffects."
	icon = 'icons/hud/screen_gen.dmi'
	icon_state = "x2"
	invisibility = INVISIBILITY_ABSTRACT //nope, can't see this
	anchored = TRUE
	density = TRUE
	opacity = FALSE
	var/replica_path = /obj/structure/fluff
	var/target_path
	var/obvious_replica = TRUE

/obj/effect/replica_spawner/Initialize(mapload)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(create_replica))
	return INITIALIZE_HINT_QDEL

/obj/effect/replica_spawner/proc/create_replica()
	var/atom/appearance_object = new target_path
	var/atom/new_replica = new replica_path(loc)

	new_replica.icon = appearance_object.icon
	new_replica.icon_state = appearance_object.icon_state
	new_replica.copy_overlays(appearance_object.appearance, cut_old = TRUE)
	new_replica.density = appearance_object.density //for like nondense showers and stuff

	new_replica.name = "[appearance_object.name][obvious_replica ? " replica" : ""]"
	new_replica.desc = "[appearance_object.desc][obvious_replica ? " ..except this one is a replica.": ""]"
	qdel(appearance_object)
	qdel(src)

/obj/structure/fluff/dnamod
	name = "DNA Modifier"
	desc = "DNA Manipulator replica. Essentially just a box of cool lights."
	icon = 'icons/obj/service/hydroponics/equipment.dmi'
	icon_state = "dnamod"
	density = TRUE

/obj/structure/fluff/minecart
	name = "minecart"
	desc = "Ore goes here. Also, there are no rails in space, so this wont budge."
	icon = 'icons/obj/storage/crates.dmi'
	icon_state = "miningcaropen"
	density = TRUE

/obj/structure/fluff/preserved_borer
	name = "preserved borer exhibit"
	desc = "A preserved cortical borer. Probably been there long enough to not last long outside the exhibit."
	icon = 'icons/obj/structures.dmi'
	icon_state = "preservedborer"
	density = TRUE

/obj/structure/fluff/balloon_nuke
	name = "nuclear balloon explosive"
	desc = "You probably shouldn't stick around to see if this is inflated."
	icon = /obj/machinery/nuclearbomb::icon
	icon_state = /obj/machinery/nuclearbomb::icon_state
	density = TRUE
	max_integrity = 5 //one tap

/obj/structure/fluff/balloon_nuke/atom_destruction()
	playsound(loc, 'sound/effects/cartoon_pop.ogg', 75, vary = TRUE)
	..()

/turf/open/mirage
	icon = 'icons/turf/floors.dmi'
	icon_state = "mirage"
	invisibility = INVISIBILITY_ABSTRACT
	/// target turf x and y are offsets from our location instead of a direct coordinate
	var/offset = TRUE
	/// tile range that we show, 2 means that the target tile and two tiles ahead of it in our direction will show
	var/range
	var/target_turf_x = 0
	var/target_turf_y = 0
	/// if not specified, uses our Z
	var/target_turf_z

/turf/open/mirage/Initialize(mapload)
	. = ..()
	if(isnull(range))
		range = world.view
	var/used_z = target_turf_z ? target_turf_z : z //if target z is not defined, use ours
	var/turf/target = locate(offset ? target_turf_x + x : target_turf_x, offset ? target_turf_y + y : target_turf_y, used_z)
	AddElement(/datum/element/mirage_border, target, dir, range)

/obj/effect/mapping_helpers/ztrait_injector/museum
	traits_to_add = list("No Parallax" = TRUE,"No X-Ray" = TRUE, "No Phase" = TRUE, "Baseturf" = /turf/open/indestructible/plating, "Secret" = TRUE)

/obj/effect/smooths_with_walls
	name = "effect that smooths with walls"
	desc = "to supplement /turf/open/mirage."
	icon = 'icons/hud/screen_gen.dmi'
	icon_state = "x2"
	invisibility = INVISIBILITY_ABSTRACT
	anchored = TRUE
	density = TRUE
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
