/obj/projectile/telegraph_tracer/callback
	telegraph_type = null //honestly lets just make this not spawn telegraphs since we use this to determine the end location of the charge
	var/datum/callback/finish_callback

/obj/projectile/telegraph_tracer/callback/Initialize(mapload, telegraphtype, callback)
	. = ..()
	if(callback)
		finish_callback = callback

/obj/projectile/telegraph_tracer/callback/Impact(atom/hit)
	. = ..()
	if(!.)
		return
	finish_callback?.InvokeAsync(hit)

/obj/moveloop_abstraction
	invisibility = INVISIBILITY_ABSTRACT

/datum/action/cooldown/mob_cooldown/charge/grapple
	cooldown_time = 2 SECONDS
	charge_damage = 20
	destroy_objects = FALSE //this fucks up in charge_end if the target is destroyed as a result idk how to fix
	charge_delay = 1 SECONDS
	shared_cooldown = NONE
	charge_past = 0

/datum/action/cooldown/mob_cooldown/charge/grapple/Activate(atom/target_atom)
	if(HAS_TRAIT(owner, TRAIT_IMMOBILIZED))
		return FALSE
	StartCooldown(360 SECONDS, 360 SECONDS)
	var/obj/projectile/projectile = new /obj/projectile/telegraph_tracer/callback(owner.loc, null, CALLBACK(src, PROC_REF(on_tracer_hit)))
	projectile.fire(get_angle(owner, target_atom))
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/charge/grapple/proc/on_tracer_hit(atom/target)
	var/abstraction = new /obj/moveloop_abstraction(owner.loc) //anyway so practically we need an invisible object since moveloops cant be predicted that good to my knowledge
	var/datum/move_loop/new_loop = SSmove_manager.home_onto(abstraction, target, delay = 0.5, timeout = 5 SECONDS, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	if(!new_loop)
		return
	RegisterSignal(abstraction, COMSIG_MOVABLE_MOVED, PROC_REF(abstract_telegraph))
	charge_sequence(owner, target, charge_delay, charge_past)

/datum/action/cooldown/mob_cooldown/charge/grapple/proc/abstract_telegraph(obj/source)
	SIGNAL_HANDLER
	new /obj/effect/temp_visual/telegraphing/shorter(source.loc)

/datum/action/cooldown/mob_cooldown/charge/grapple/do_charge_indicator(atom/movable/charger, atom/target_atom)
	return // we do our own telegraph

/datum/action/cooldown/mob_cooldown/charge/grapple/hit_target(atom/movable/source, mob/living/target, damage_dealt)
	if(!istype(target))
		return
	source.forceMove(get_turf(target))
	target.visible_message(span_danger("[owner] grapples [target]!"))
	owner.buckle_mob(target, check_loc = FALSE)
	target.apply_damage(damage_dealt, BRUTE)
	playsound(get_turf(target), 'sound/effects/meteorimpact.ogg', 100, TRUE)
	shake_camera(target, 2, 2)

/datum/action/cooldown/mob_cooldown/charge/grapple/charge_end(datum/move_loop/has_target/source)
	. = ..()
	var/turf/target
	if(istype(source))
		target = source.target

	if(!target.is_blocked_turf(exclude_mobs = TRUE, source_atom = owner))
		for(var/mob/living/buckled in owner.buckled_mobs)
			buckled.Paralyze(1 SECONDS)
			owner.unbuckle_mob(buckled)
			buckled.visible_message(span_danger("[buckled] is thrown off by [owner]!"))
			buckled.throw_at(get_step_away(buckled, target), 2, 1)
		return

	for(var/mob/living/buckled in owner.buckled_mobs)
		buckled.Paralyze(1 SECONDS)
		buckled.visible_message(span_danger("[buckled] is slammed into [target] by [owner]!"))
		buckled.apply_damage(charge_damage, BRUTE)
		buckled.throw_at(get_step_away(buckled, target), 2, 1)
		owner.unbuckle_mob(buckled)

	target.Shake(duration = 0.5 SECONDS)
	playsound(get_turf(target), 'sound/effects/meteorimpact.ogg', 100, TRUE)


/datum/action/cooldown/mob_cooldown/forearm_drop //lethal finisher
	name = "Lethal Drop"
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	desc = "Allows you to charge at a chosen position."
	cooldown_time = 15 SECONDS
	var/air_time = 2 SECONDS
	var/damage = 15

/datum/action/cooldown/mob_cooldown/forearm_drop/Activate(atom/target)
	if(isarea(target))
		return FALSE
	var/target_turf = get_turf(target)
	StartCooldown(360 SECONDS, 360 SECONDS)
	owner.density = FALSE
	playsound(owner.loc, 'sound/effects/gravhit.ogg', 75, TRUE)
	new /obj/effect/temp_visual/mook_dust(get_turf(owner))

	for(var/turf/open/telegraph_target in RANGE_TURFS(1, target_turf))
		new /obj/effect/temp_visual/telegraphing(telegraph_target)

	var/prior_transform = owner.transform
	animate(owner, transform = turn(owner.transform, 90), time = air_time / 2, flags = ANIMATION_PARALLEL)
	animate(pixel_y = owner.pixel_y + 64, time = air_time / 2, easing = CIRCULAR_EASING | EASE_OUT, flags = ANIMATION_PARALLEL)
	animate(pixel_y = initial(owner.pixel_y), time = air_time / 2, easing = CIRCULAR_EASING | EASE_IN)
	animate(transform = prior_transform, time = 1)
	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, REF(src))

	var/datum/move_loop/new_loop = SSmove_manager.home_onto(owner, target_turf, delay = 0.25 SECONDS, timeout = air_time, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	if(!new_loop)
		return
	addtimer(CALLBACK(src, PROC_REF(impact)), air_time)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/forearm_drop/proc/impact()
	var/turf/our_loc = get_turf(owner)
	owner.density = initial(owner.density)
	REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, REF(src))
	for(var/turf/open/target in RANGE_TURFS(2, our_loc))
		new /obj/effect/temp_visual/mook_dust(target)
		for(var/mob/living/victim in target)
			if(victim == owner)
				continue
			var/victim_is_under = (victim.loc == our_loc)
			victim.Paralyze(1 SECONDS)
			victim.apply_damage(damage * (victim_is_under ? 2 : 1), BRUTE)
			owner.visible_message(span_danger("[victim] is [victim_is_under ? "crushed" : "thrown off their feet"] by [owner]!"))
			if(!victim_is_under)
				victim.throw_at(get_step_away(victim, our_loc), 2, 1)
			else if (victim_is_under && victim.stat >= HARD_CRIT)
				victim.gib(DROP_ALL_REMAINS)

	playsound(get_turf(owner), 'sound/effects/bang.ogg', 75, TRUE)
	//target.gib(DROP_ALL_REMAINS)
