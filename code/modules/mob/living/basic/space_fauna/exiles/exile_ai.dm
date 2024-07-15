/datum/ai_controller/basic_controller/exile
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_FLEE_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_REINFORCEMENTS_EMOTE = "lets out a high-pitched signal!"
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	planning_subtrees = list(
		/datum/ai_planning_subtree/exile,
		/datum/ai_planning_subtree/call_reinforcements,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/clear_key,
	)

/// Try and find anyone who harmed us, if we fail, null target and travel to our starting location, otherwise flee and call reinforcements
/datum/ai_planning_subtree/exile/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	controller.queue_behavior(/datum/ai_behavior/target_from_retaliate_list/nearest, BB_BASIC_MOB_RETALIATE_LIST, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)
	if(!controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET))
		controller.queue_behavior(/datum/ai_behavior/travel_towards, BB_TRAVEL_DESTINATION)
		return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_planning_subtree/clear_key
	var/key = BB_BASIC_MOB_CURRENT_TARGET

/datum/ai_planning_subtree/clear_key/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	controller.clear_blackboard_key(key)

/datum/ai_controller/basic_controller/exile/harmful
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)

	ai_movement = /datum/ai_movement/jps //these guys should be a lil smarter
	planning_subtrees = list(
		/datum/ai_planning_subtree/exile,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/exile_burst,
		/datum/ai_planning_subtree/clear_key,
	)

/datum/ai_planning_subtree/basic_ranged_attack_subtree/exile_burst
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/exile_burst

/datum/ai_behavior/basic_ranged_attack/exile_burst
	action_cooldown = 3 SECONDS
	avoid_friendly_fire = TRUE
	required_distance = 0 // they dont care

/datum/ai_behavior/basic_ranged_attack/exile_burst/check_friendly_in_path(mob/living/source, atom/target, datum/targeting_strategy/targeting_strategy)
	var/list/turfs_list = calculate_trajectory(source, target)
	var/prev_turf
	for(var/turf/possible_turf as anything in turfs_list)
		if(is_turf_blocked(from = prev_turf, turf = possible_turf))
			return TRUE
		prev_turf = possible_turf
		for(var/mob/living/potential_friend in possible_turf)
			if(!targeting_strategy.can_attack(source, potential_friend))
				return TRUE

	return FALSE

/datum/ai_behavior/basic_ranged_attack/exile_burst/proc/is_turf_blocked(from, turf/turf)
	. = FALSE
	if(turf.density)
		return TRUE
	for(var/atom/movable/movable as anything in turf.contents)
		if(movable.density && !ismob(movable) && !HAS_TRAIT(movable, TRAIT_CLIMBABLE))
			if(!isnull(from) && movable.CanPass(from, get_dir(from, movable)))
				continue
			return TRUE
