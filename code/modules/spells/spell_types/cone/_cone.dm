/**
 * ## Cone spells
 *
 * Cone spells shoot off as a cone from the caster.
 */
/datum/action/cooldown/spell/cone
	/// This controls how many levels the cone has. Increase this value to make a bigger cone.
	var/cone_levels = 3
	/// This value determines if the cone penetrates walls.
	var/respect_density = FALSE

/datum/action/cooldown/spell/cone/cast(atom/cast_on)
	. = ..()
	var/list/cone_turfs = get_cone_turfs(get_turf(cast_on), cast_on.dir, cone_levels, respect_density)
	SEND_SIGNAL(src, COMSIG_SPELL_CONE_ON_CAST, cone_turfs, cast_on)
	make_cone(cone_turfs, cast_on)

/datum/action/cooldown/spell/cone/proc/make_cone(list/cone_turfs, atom/caster)
	for(var/list/turf_list in cone_turfs)
		do_cone_effects(turf_list, caster)

/// This proc does obj, mob and turf cone effects on all targets in the passed list.
/datum/action/cooldown/spell/cone/proc/do_cone_effects(list/target_turf_list, atom/caster, level = 1)
	SEND_SIGNAL(src, COMSIG_SPELL_CONE_ON_LAYER_EFFECT, target_turf_list, caster, level)
	for(var/turf/target_turf as anything in target_turf_list)
		if(QDELETED(target_turf)) //if turf is no longer there
			continue

		do_turf_cone_effect(target_turf, caster, level)
		if(!isopenturf(target_turf))
			continue

		for(var/atom/movable/movable_content as anything in target_turf)
			if(isobj(movable_content))
				do_obj_cone_effect(movable_content, caster, level)
			else if(isliving(movable_content))
				do_mob_cone_effect(movable_content, caster, level)

///This proc deterimines how the spell will affect turfs.
/datum/action/cooldown/spell/cone/proc/do_turf_cone_effect(turf/target_turf, atom/caster, level)
	return

///This proc deterimines how the spell will affect objects.
/datum/action/cooldown/spell/cone/proc/do_obj_cone_effect(obj/target_obj, atom/caster, level)
	return

///This proc deterimines how the spell will affect mobs.
/datum/action/cooldown/spell/cone/proc/do_mob_cone_effect(mob/living/target_mob, atom/caster, level)
	return

/**
 * Adjusts the width of the cone at the passed level.
 * This is never called on the first level of the cone (level 1 is always 1 width)
 *
 * Return a number - the TOTAL width of the cone at the passed level.
 */
/datum/action/cooldown/spell/cone/proc/calculate_cone_shape(current_level)
	// Default formula: (1 (innate) -> 3 -> 5 -> 5 -> 7 -> 7 -> 9 -> 9 -> ...)
	return current_level + (current_level % 2) + 1

/**
 * ### Staggered Cone
 *
 * Staggered Cone spells will reach each cone level
 * gradually / with a delay, instead of affecting the entire
 * cone area at once.
 */
/datum/action/cooldown/spell/cone/staggered

	/// The delay between each cone level triggering.
	var/delay_between_level = 0.2 SECONDS

/datum/action/cooldown/spell/cone/staggered/make_cone(list/cone_turfs, atom/caster)
	var/level_counter = 0
	for(var/list/turf_list in cone_turfs)
		level_counter++
		addtimer(CALLBACK(src, PROC_REF(do_cone_effects), turf_list, caster, level_counter), delay_between_level * level_counter)
