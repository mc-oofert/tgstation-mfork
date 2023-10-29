/datum/ai_controller/basic_controller/superjail
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_TARGETLESS_TIME = 0,
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/sleep_with_no_target/announced, // ok they died time to deactivate
		/datum/ai_planning_subtree/use_mob_ability/missile_burst,
		/datum/ai_planning_subtree/use_mob_ability/laser_burst,
		/datum/ai_planning_subtree/use_mob_ability/laser_spiral,
	)

/datum/ai_planning_subtree/sleep_with_no_target/announced
	sleep_behaviour = /datum/ai_behavior/sleep_after_targetless_time/announced

/datum/ai_behavior/sleep_after_targetless_time/announced
	// when we are going to sleep what do we say
	var/sleep_say = "CANNOT FIND COMBATANT. DEACTIVATING."
	time_to_wait = 3

/datum/ai_behavior/sleep_after_targetless_time/announced/enter_sleep(datum/ai_controller/controller)
	. = ..()
	if(!controller?.pawn) // just in case
		return
	var/mob/living/living_pawn = controller.pawn
	living_pawn.say(sleep_say)

/datum/ai_planning_subtree/use_mob_ability/missile_burst
	ability_key = BB_SUPERJAIL_MISSILEBURST_ABILITY
	finish_planning = TRUE

/datum/ai_planning_subtree/use_mob_ability/laser_burst
	ability_key = BB_SUPERJAIL_LASERBURST_ABILITY
	finish_planning = TRUE

/datum/ai_planning_subtree/use_mob_ability/laser_spiral
	ability_key = BB_SUPERJAIL_LASERSPIRAL_ABILITY
	finish_planning = TRUE
