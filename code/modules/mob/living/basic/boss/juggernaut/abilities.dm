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

/obj/effect/temp_visual/telegraphing/arrow
	icon_state = "arrow"
	duration = 0.5 SECONDS

/datum/action/cooldown/mob_cooldown/charge/grapple
	charge_damage = 10
	charge_delay = 1 SECONDS
	shared_cooldown = NONE
	charge_past = 0

/datum/action/cooldown/mob_cooldown/charge/grapple/Activate(atom/target_atom)
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
	var/atom/target
	if(istype(source))
		target = source.target
	if(!target?.density)
		return

	for(var/mob/living/buckled in owner.buckled_mobs)
		buckled.Paralyze(1 SECONDS)
		buckled.visible_message(span_danger("[buckled] is slammed into [target] by [owner]!"))
		buckled.apply_damage(charge_damage, BRUTE)
		buckled.throw_at(get_step_away(buckled, target), 2, 1)
		owner.unbuckle_mob(buckled)

	target.Shake(duration = 0.5 SECONDS)
	playsound(get_turf(target), 'sound/effects/meteorimpact.ogg', 100, TRUE)
