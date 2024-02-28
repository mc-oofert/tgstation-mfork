/datum/proximity_monitor/advanced/killdrone

/datum/proximity_monitor/advanced/killdrone/field_turf_crossed(mob/living/crossed, turf/location)
	if (!istype(crossed) || crossed.stat == DEAD || !can_see(host, crossed, current_range)) //general checks
		return
	var/obj/structure/killdrone_turret/our_drone = host
	var/list/seen_turfs = our_drone.seen_turfs
	if(!seen_turfs.Find(location))
		return
	our_drone.victim_sighted(crossed)

/obj/structure/killdrone_turret
	name = "Killdrone"
	desc = "A manufactured turret for defense of property. The Threat uses these a lot."
	icon = 'icons/obj/weapons/turrets.dmi'
	icon_state = "machinegun"
	density = TRUE
	anchored = TRUE
	gender = NEUTER
	light_system = OVERLAY_LIGHT_DIRECTIONAL
	light_range = 5
	light_power = 1.5
	light_on = TRUE
	light_color = "#004080"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF //no cheese
	var/datum/weakref/target
	var/datum/proximity_monitor/proximity_monitor
	var/aggro_light_color = "#FDDA0D"
	var/fire_cooldown_time = 2 SECONDS
	var/fire_delay = 0.25 SECONDS
	var/turf/seen_turfs = list()
	var/obj/projectile/ammunition = /obj/projectile/bullet/a223/highvelap
	COOLDOWN_DECLARE(fire_cooldown)

/obj/structure/killdrone_turret/Initialize(mapload)
	. = ..()
	proximity_monitor = new /datum/proximity_monitor/advanced/killdrone(src, light_range)
	update_seen_turfs()

/obj/structure/killdrone_turret/process(seconds_per_tick)
	if(!COOLDOWN_FINISHED(src, fire_cooldown))
		return
	var/mob/living/victim = target.resolve()
	if(isnull(victim) || victim.stat == DEAD)
		lose_target()
		return
	COOLDOWN_START(src, fire_cooldown, fire_cooldown_time)
	for(var/i in 1 to 3)
		addtimer(CALLBACK(src, PROC_REF(fire_async), victim), i * (0.2 SECONDS))

/obj/structure/killdrone_turret/proc/victim_moved(mob/living/source)
	if(!can_see(src, source))
		lose_target()
		return
	var/new_dir = get_dir(src, source)
	var/static/list/diagonal_to_approximation = list(
		"[NORTHWEST]" = WEST,
		"[NORTHEAST]" = EAST,
		"[SOUTHWEST]" = WEST,
		"[SOUTHEAST]" = EAST,
	)
	if(new_dir in GLOB.diagonals)
		new_dir = diagonal_to_approximation[new_dir]
	if(new_dir == dir)
		return
	setDir(new_dir)
	update_seen_turfs()

/obj/structure/killdrone_turret/proc/victim_sighted(mob/living/who)
	if(!isnull(target))
		return FALSE
	RegisterSignal(who, COMSIG_MOVABLE_MOVED, PROC_REF(victim_moved))
	target = WEAKREF(who)
	playsound(src, 'sound/machines/beep.ogg', 75, TRUE)
	set_light_color(aggro_light_color)
	COOLDOWN_START(src, fire_cooldown, fire_delay)
	START_PROCESSING(SSfastprocess, src)
	return TRUE

/obj/structure/killdrone_turret/proc/lose_target()
	if(isnull(target))
		return FALSE
	. = TRUE
	set_light_color(initial(light_color))
	playsound(src, 'sound/machines/beep_low.ogg', 50, TRUE)
	STOP_PROCESSING(SSfastprocess, src)
	var/atom/resolved = target.resolve()
	target = null
	if(isnull(resolved))
		return
	UnregisterSignal(resolved, COMSIG_MOVABLE_MOVED)

/obj/structure/killdrone_turret/proc/fire_async(mob/living/target)
	playsound(src, 'sound/weapons/gun/hmg/hmg.ogg', 100, TRUE)
	var/obj/projectile/bullet = new ammunition(drop_location())
	bullet.original = target
	bullet.fired_from = src
	bullet.firer = src
	bullet.impacted = list(src = TRUE)
	bullet.preparePixelProjectile(target, src)
	bullet.fire()

/obj/structure/killdrone_turret/proc/update_seen_turfs()
	var/shifted_epicentre = get_step(get_turf(src), REVERSE_DIR(dir)) //this means the cone starts a little sooner for a wider field of view and we dont need to add extra code to that proc
	seen_turfs = get_cone_turfs(shifted_epicentre, dir, light_range+1, respect_density = TRUE, as_one_list = TRUE)


/obj/structure/killdrone_turret/returns_to_initial_direction
	var/init_dir
	var/delay_after_no_target = 1.5 SECONDS
	var/return_timer_id

/obj/structure/killdrone_turret/returns_to_initial_direction/Initialize(mapload)
	. = ..()
	init_dir = dir

/obj/structure/killdrone_turret/returns_to_initial_direction/lose_target()
	. = ..()
	if(!.)
		return
	if(return_timer_id)
		return
	return_timer_id = addtimer(CALLBACK(src, PROC_REF(return_to_dir)), delay_after_no_target, TIMER_UNIQUE|TIMER_STOPPABLE)

/obj/structure/killdrone_turret/returns_to_initial_direction/victim_sighted(mob/living/who)
	. = ..()
	if(!.)
		return
	deltimer(return_timer_id)
	return_timer_id = null

/obj/structure/killdrone_turret/returns_to_initial_direction/proc/return_to_dir()
	setDir(init_dir)
	return_timer_id = null
