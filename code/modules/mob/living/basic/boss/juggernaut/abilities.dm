/obj/projectile/telegraph_tracer/callback
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

/datum/action/cooldown/mob_cooldown/charge/grapple
	charge_damage = 0
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
	charge_sequence(owner, target, charge_delay, charge_past)

/datum/action/cooldown/mob_cooldown/charge/grapple/do_charge_indicator(atom/movable/charger, atom/target_atom)
	return // we do our telegraph on the projectile instead

