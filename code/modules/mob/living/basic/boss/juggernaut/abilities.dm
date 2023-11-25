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

/obj/moveloop_abstraction //L37
	invisibility = INVISIBILITY_ABSTRACT

/datum/action/cooldown/mob_cooldown/charge/grapple
	cooldown_time = 2 SECONDS
	charge_damage = 20
	destroy_objects = FALSE //this fucks up in charge_end if the target is destroyed as a result idk how to fix
	charge_delay = 0.8 SECONDS
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
	var/datum/move_loop/new_loop = SSmove_manager.home_onto(abstraction, target, delay = 0.25, timeout = 5 SECONDS, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
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
	if(!isnull(owner.buckled_mobs) && owner.buckled_mobs.len)
		target.Paralyze(1 SECONDS)
		target.throw_at(get_step_away(target, owner), 2, 1)
		target.visible_message(span_danger("[owner] knocks [target] out of their path!"))
	else
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
	desc = "Allows you to jump at a chosen position. People near or under wherever you land are knocked down and damaged. Dead or hard crit people you land on are gibbed."
	cooldown_time = 8 SECONDS
	var/air_time = 1.1 SECONDS
	var/damage = 15

/datum/action/cooldown/mob_cooldown/forearm_drop/Activate(atom/target)
	if(isarea(target))
		return FALSE
	if(HAS_TRAIT(owner, TRAIT_IMMOBILIZED))
		return FALSE
	var/turf/target_turf = get_turf(target)
	StartCooldown(360 SECONDS, 360 SECONDS)
	owner.density = FALSE
	playsound(owner.loc, 'sound/effects/gravhit.ogg', 75, TRUE)
	new /obj/effect/temp_visual/mook_dust(get_turf(owner))

	for(var/turf/open/telegraph_target in RANGE_TURFS(2, target_turf))
		new /obj/effect/temp_visual/telegraphing(telegraph_target)

	var/prior_transform = owner.transform
	animate(owner, transform = turn(owner.transform, 90), time = air_time / 2, flags = ANIMATION_PARALLEL)
	animate(pixel_y = owner.pixel_y + 64, time = air_time / 2, easing = CIRCULAR_EASING | EASE_OUT, flags = ANIMATION_PARALLEL)
	animate(pixel_y = initial(owner.pixel_y), time = air_time / 2, easing = CIRCULAR_EASING | EASE_IN)
	animate(transform = prior_transform, time = 1)
	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, REF(src))

	var/datum/move_loop/new_loop = SSmove_manager.move_to(owner, target_turf, delay = min(1, get_dist(owner, target_turf)) / air_time, min_dist = 0, timeout = air_time, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
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

/datum/action/cooldown/mob_cooldown/ring_shockwaves
	name = "Stomp"
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	desc = "Allows you to charge at a chosen position."
	cooldown_time = 6 SECONDS
	shared_cooldown = NONE
	var/max_dist = 6
	var/delay = 0.8 SECONDS

/datum/action/cooldown/mob_cooldown/ring_shockwaves/Activate(atom/target_atom)
	StartCooldown(360 SECONDS, 360 SECONDS)
	
	animate(owner, pixel_y = owner.pixel_y + 48, time = delay / 2, easing = CIRCULAR_EASING | EASE_OUT, flags = ANIMATION_PARALLEL)
	animate(pixel_y = initial(owner.pixel_y), time = delay / 2, easing = CIRCULAR_EASING | EASE_IN)
	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, REF(src))
	playsound(owner.loc, 'sound/effects/gravhit.ogg', 75, TRUE)
	new /obj/effect/temp_visual/mook_dust(get_turf(owner))
	
	var/distance_is_even = get_dist(owner,target_atom) % 2 == 0 ? TRUE : FALSE
	var/list/targets = list()
	for(var/turf/open/possibility in RANGE_TURFS(max_dist, owner))
		var/distance = get_dist(possibility, owner)
		if((distance % 2 == 0) != distance_is_even) //we try to make rings actually hit the target
			continue
		targets += possibility
		new /obj/effect/temp_visual/telegraphing/short(possibility)
	addtimer(CALLBACK(src, PROC_REF(impact), targets), delay)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/ring_shockwaves/proc/launch_victim(atom/movable/thing, delay = 1 SECONDS)
	if(!istype(thing))
		return
	animate(thing, pixel_y = thing.pixel_y + 48, time = delay / 2, easing = CIRCULAR_EASING | EASE_OUT, flags = ANIMATION_PARALLEL)
	animate(pixel_y = initial(thing.pixel_y), time = delay / 2, easing = CIRCULAR_EASING | EASE_IN)
	addtimer(CALLBACK(src, PROC_REF(on_victim_impact), thing), delay)

/datum/action/cooldown/mob_cooldown/ring_shockwaves/proc/on_victim_impact(atom/movable/thing)
	if(isliving(thing))
		var/mob/living/victim = thing
		victim.Paralyze(1 SECONDS)
		victim.apply_damage(15, BRUTE)
	else
		thing.take_damage(30)

/datum/action/cooldown/mob_cooldown/ring_shockwaves/proc/impact(list/turf/targets)
	REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, REF(src))
	for(var/turf/target as anything in targets)
		for(var/atom/movable/victim in target)
			if(victim == owner)
				continue
			if(victim.anchored)
				continue
			new /obj/effect/temp_visual/mook_dust(target)
			launch_victim(victim)

	playsound(get_turf(owner), 'sound/effects/bang.ogg', 75, TRUE)