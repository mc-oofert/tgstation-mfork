/datum/ai_controller/basic_controller/juggernaut
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)

	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking
	ai_movement = /datum/ai_movement/jps // its megafauna bro,,, fuck them up
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/targeted_mob_ability/grapple,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_planning_subtree/targeted_mob_ability/grapple
	ability_key = BB_SJUGGERNAUT_GRAPPLE_ABILITY
	//finish_planning = TRUE
