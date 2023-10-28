/datum/action/cooldown/mob_cooldown/missile_burst
	name = "Missile Burst"
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	desc = "Shoots missiles around yourself."
	cooldown_time = 6 SECONDS
	shared_cooldown = NONE
	click_to_activate = FALSE

/datum/action/cooldown/mob_cooldown/missile_burst/Activate(atom/target_atom)
	owner.visible_message(span_boldwarning("[owner] begins firing missiles!"))
	playsound(get_turf(owner), 'sound/weapons/gun/general/rocket_launch.ogg', 65, TRUE)
	var/list/turf/possible_turfs = RANGE_TURFS(7, get_turf(owner))
	var/missiles_sent = 20
	while(missiles_sent)
		var/picked_turf = pick(possible_turfs)
		new /obj/effect/temp_visual/missile(picked_turf)
		possible_turfs -= picked_turf
		missiles_sent--
		
	StartCooldown()
	return TRUE

/obj/effect/temp_visual/telegraphing/short
	duration = 1 SECONDS

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
