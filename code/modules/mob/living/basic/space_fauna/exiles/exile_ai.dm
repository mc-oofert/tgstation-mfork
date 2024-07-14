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
