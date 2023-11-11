/datum/ai_controller/basic_controller/juggernaut_syndicate //ok so juggernaut was taken
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = DEAD,
	)

	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking
	ai_movement = /datum/ai_movement/jps // its megafauna bro,,, fuck them up
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/opportunistic,
		/datum/ai_planning_subtree/targeted_mob_ability/lethal_drop,
		/datum/ai_planning_subtree/targeted_mob_ability/grapple,
	)

/datum/ai_planning_subtree/targeted_mob_ability/grapple
	ability_key = BB_SJUGGERNAUT_GRAPPLE_ABILITY

/datum/ai_planning_subtree/targeted_mob_ability/grapple/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!controller.blackboard_key_exists(target_key))
		return
	var/atom/movable/target = controller.blackboard[target_key]
	if(QDELETED(target) || !isliving(target))
		return
	var/mob/living/living_target = target
	if(living_target.body_position != STANDING_UP)
		return
	return ..()

/datum/ai_planning_subtree/targeted_mob_ability/lethal_drop
	ability_key = BB_SJUGGERNAUT_FINISHER_ABILITY
