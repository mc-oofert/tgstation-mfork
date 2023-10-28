/datum/ai_controller/basic_controller/superjail
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/use_mob_ability/missile_burst,
	)

/datum/ai_planning_subtree/use_mob_ability/missile_burst
	ability_key = BB_SUPERJAIL_MISSILEBURST_ABILITY
	finish_planning = TRUE
