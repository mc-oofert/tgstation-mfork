/mob/living/basic/boss/juggernaut
	name = "Syndicate Juggernaut"
	desc = "An absolutely massive syndicate commando. Like, 95% muscle, 100% POWAH."
	icon = 'icons/mob/simple/juggernaut.dmi'
	icon_state="juggernaut"
	icon_living="juggernaut"
	health = 2000
	maxHealth = 2000
	combat_mode = TRUE
	sentience_type = SENTIENCE_BOSS
	mob_biotypes = MOB_HUMANOID|MOB_SPECIAL
	faction = list(FACTION_BOSS)
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 0, STAMINA = 0, OXY = 0)
	unsuitable_cold_damage = 0 // PLASTEEL HARD ABS
	unsuitable_heat_damage = 0
	unsuitable_atmos_damage = 0
	melee_damage_lower = 20
	melee_damage_upper = 40
	armour_penetration = 30
	pixel_x = -16
	base_pixel_x = -16
	speed = 3
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = INFINITY
	pull_force = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_HUGE
	layer = LARGE_MOB_LAYER
	plane = GAME_PLANE_UPPER_FOV_HIDDEN
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	speech_span = SPAN_COMMAND
	can_buckle = TRUE
	ai_controller = /datum/ai_controller/basic_controller/juggernaut_syndicate

/mob/living/basic/boss/juggernaut/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/seethrough_mob)
	add_traits(list(TRAIT_NO_TELEPORT, TRAIT_MARTIAL_ARTS_IMMUNE), MEGAFAUNA_TRAIT)
	AddComponent(/datum/component/basic_mob_attack_telegraph, telegraph_state = ATTACK_EFFECT_SMASH,telegraph_duration = 0.3 SECONDS)
	//AddElement(/datum/element/death_drops, string_list(list(/obj/effect/temp_visual/superjail_death)))
	var/datum/action/cooldown/mob_cooldown/charge/grapple/grapple = new(src)
	grapple.Grant(src)
	ai_controller.set_blackboard_key(BB_SJUGGERNAUT_GRAPPLE_ABILITY, grapple)
