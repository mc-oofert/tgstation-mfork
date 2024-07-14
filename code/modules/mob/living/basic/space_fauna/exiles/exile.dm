/mob/living/basic/exile
	icon = 'icons/mob/simple/animal.dmi'
	mob_biotypes = MOB_ROBOTIC
	basic_mob_flags = DEL_ON_DEATH
	icon_state = "exile"
	base_icon_state = "exile"
	maxHealth = 300
	health = 300
	combat_mode = TRUE
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, STAMINA = 0, OXY = 0)
	habitable_atmos = null
	maximum_survivable_temperature = INFINITY
	minimum_survivable_temperature = 0
	sentience_type = SENTIENCE_ARTIFICIAL
	status_flags = NONE
	pass_flags = PASSMOB
	verb_say = "states"
	verb_ask = "queries"
	verb_exclaim = "declares"
	verb_yell = "alarms"
	initial_language_holder = /datum/language_holder/synthetic
	bubble_icon = "machine"
	speech_span = SPAN_ROBOT
	faction = list(FACTION_TURRET, FACTION_NEUTRAL, "Exile")
	ai_controller = /datum/ai_controller/basic_controller/exile
	var/floats = TRUE

/mob/living/basic/exile/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/movetype_handler)
	ADD_TRAIT(src, TRAIT_MOVE_FLOATING, INNATE_TRAIT)
	if(!floats)
		ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, INNATE_TRAIT)
	update_appearance()
	AddElement(/datum/element/relay_attackers)
	ai_controller.set_blackboard_key(BB_TRAVEL_DESTINATION, loc) //maintain our spawn location

	RegisterSignal(target, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))

	ADD_TRAIT(target, TRAIT_SUBTREE_REQUIRED_OPERATIONAL_DATUM, type)

/mob/living/basic/exile/proc/on_attacked(mob/victim, mob/living/attacker)
	SIGNAL_HANDLER
	if(istype(attacker) && ("Exile" in attacker.faction))
		return
	victim.ai_controller?.insert_blackboard_key_lazylist(BB_BASIC_MOB_RETALIATE_LIST, attacker)

/mob/living/basic/exile/update_overlays()
	. = ..()
	if(floats)
		. += "exilefloat"

/mob/living/basic/exile/emp_reaction(severity)
	return

/mob/living/basic/exile/bin
	name = "EX-BIN"

/mob/living/basic/exile/hex
	name = "EX-HEX"

/mob/living/basic/exile/dec
	name = "EX-DEC"
	ai_controller = /datum/ai_controller/basic_controller/exile/harmful

/mob/living/basic/exile/dec/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/ranged_attacks,\
		projectile_type = /obj/projectile/ion/hurts,\
		projectile_sound = 'sound/weapons/thermalpistol.ogg',\
		cooldown_time = 3 SECONDS,\
		burst_shots = 2,\
	)

/mob/living/basic/exile/brawn
	name = "8R-AWN"
	icon_state = "exilebrawn"
	ai_controller = /datum/ai_controller/basic_controller/exile/harmful
	floats = FALSE

/mob/living/basic/exile/brawn/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/ranged_attacks,\
		projectile_type = /obj/projectile/bullet/manned_turret/hmg,\
		projectile_sound = 'sound/weapons/gun/hmg/hmg.ogg',\
		cooldown_time = 3 SECONDS,\
		burst_shots = 2,\
	)
