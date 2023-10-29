// missiles
/datum/action/cooldown/mob_cooldown/missile_burst
	name = "Missile Burst"
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	desc = "Shoots missiles around yourself."
	cooldown_time = 6 SECONDS
	shared_cooldown = NONE
	click_to_activate = FALSE
	/// range we will missile
	var/range = 7
	/// missiles to shoot
	var/missiles = 20

/datum/action/cooldown/mob_cooldown/missile_burst/Activate(atom/target_atom)
	owner.visible_message(span_boldwarning("[owner] begins firing missiles!"))
	playsound(get_turf(owner), 'sound/weapons/gun/general/rocket_launch.ogg', 65, TRUE)
	var/list/turf/possible_turfs = RANGE_TURFS(range, get_turf(owner))
	var/missiles_sent = missiles
	while(missiles_sent)
		var/picked_turf = pick(possible_turfs)
		new /obj/effect/temp_visual/missile(picked_turf)
		possible_turfs -= picked_turf
		missiles_sent--
		
	StartCooldown()
	return TRUE

/obj/effect/temp_visual/telegraphing/short
	duration = 1 SECONDS

/obj/effect/temp_visual/telegraphing/shorter
	duration = 0.5 SECONDS

/obj/effect/temp_visual/missile
	icon = 'icons/effects/effects.dmi'
	icon_state = "rocket_incoming"
	name = "missile"
	desc = "If youre examining this youre fucked!"
	layer = FLY_LAYER
	plane = ABOVE_GAME_PLANE
	randomdir = FALSE
	duration = 0.9 SECONDS
	pixel_z = 270

/obj/effect/temp_visual/missile/Initialize(mapload)
	. = ..()
	new /obj/effect/temp_visual/telegraphing/short(loc)
	animate(src, pixel_z = 0, time = duration)
	addtimer(CALLBACK(src, PROC_REF(explode)), duration)

/obj/effect/temp_visual/missile/proc/explode()
	explosion(loc, light_impact_range = 1, flame_range = 2, adminlog = FALSE, explosion_cause = src)

//lasers
/datum/action/cooldown/mob_cooldown/laser_burst
	name = "Laser Burst"
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	desc = "Shoots laser around yourself."
	cooldown_time = 6 SECONDS
	shared_cooldown = NONE
	click_to_activate = FALSE
	var/projectile_type = /obj/projectile/beam/laser/hitscan

/datum/action/cooldown/mob_cooldown/laser_burst/Activate(atom/target_atom)
	owner.visible_message(span_boldwarning("[owner] begins firing lasers!"))
	for(var/dir in GLOB.alldirs)
		var/obj/projectile/projectile = new /obj/projectile/telegraph_tracer(owner.loc) //we can assume that this mob can never be put inside stuff
		projectile.fire(dir2angle(dir))
		addtimer(CALLBACK(src, PROC_REF(fire_projectile), dir), 0.5 SECONDS)
	playsound(src, 'sound/weapons/emitter.ogg', 50, TRUE)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/laser_burst/proc/fire_projectile(direction)
	var/obj/projectile/projectile = new projectile_type(owner.loc)
	projectile.fire(dir2angle(direction))

/obj/projectile/telegraph_tracer
	name = ""
	icon_state = ""
	hitscan = TRUE
	damage = 0
	projectile_phasing = PASSMOB|PASSVEHICLE
	phasing_ignore_direct_target = TRUE

	/// spawned telegraph type
	var/telegraph_type = /obj/effect/temp_visual/telegraphing/shorter

/obj/projectile/telegraph_tracer/Initialize(mapload, telegraphtype)
	. = ..()
	if(telegraphtype)
		telegraph_type = telegraphtype

/obj/projectile/telegraph_tracer/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	new telegraph_type(loc)

/datum/action/cooldown/mob_cooldown/projectile_attack/spiral_shots/laser
	name = "Spiral Lasers"
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	desc = "Fires projectiles in a spiral pattern."
	cooldown_time = 10 SECONDS
	projectile_type = /obj/projectile/telegraph_tracer
	shared_cooldown = NONE
	click_to_activate = FALSE
	//projectile_sound = 'sound/magic/clockwork/invoke_general.ogg'
	fire_delay = 0.3 SECONDS

/datum/action/cooldown/mob_cooldown/projectile_attack/spiral_shots/laser/shoot_projectile(atom/origin, atom/target, set_angle, mob/firer, projectile_spread, speed_multiplier, override_projectile_type, override_homing)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(fire_projectile), set_angle), 0.5 SECONDS)

/datum/action/cooldown/mob_cooldown/projectile_attack/spiral_shots/laser/proc/fire_projectile(angle)
	var/obj/projectile/projectile = new /obj/projectile/beam/laser/hitscan(owner.loc)
	projectile.fire(angle)
