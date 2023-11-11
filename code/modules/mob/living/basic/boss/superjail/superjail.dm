/obj/structure/superjail_generator
	name = "Shield Generator"
	desc = "Powers the shields of the Superjail. Destroying these might be a bad idea."
	density = TRUE
	max_integrity = 50
	anchored = TRUE
	icon = 'icons/mob/simple/hivebot.dmi'
	icon_state = "pow_gen"
	var/beam

/obj/structure/superjail_generator/Initialize(mapload)
	. = ..()
	var/mob/living/basic/boss/super_jail/protected = locate(/mob/living/basic/boss/super_jail) in range(4, src)
	if(!protected)
		qdel(src)
		return
	beam = Beam(protected, icon_state="light_beam", time = INFINITY)
	RegisterSignal(protected, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, PROC_REF(modify_damage))
	RegisterSignals(protected, list(COMSIG_LIVING_DEATH, COMSIG_QDELETING), PROC_REF(destroy_self))

/obj/structure/superjail_generator/proc/destroy_self(datum/source)
	SIGNAL_HANDLER
	atom_destruction(BRUTE)

/obj/structure/superjail_generator/proc/modify_damage(mob/source, list/damage_mods, damage_amount, damagetype, def_zone, sharpness, attack_direction, obj/item/attacking_item)
	SIGNAL_HANDLER
	damage_mods += 0
	do_sparks(3, FALSE, src)

/obj/structure/superjail_generator/atom_destruction(damage_flag)
	visible_message(span_warning("[src] explodes!"))
	explosion(get_turf(src), flame_range = 1, adminlog = FALSE)
	return ..()

/obj/structure/superjail_generator/Destroy(force)
	. = ..()
	qdel(beam)

/mob/living/basic/boss/super_jail
	name = "NT-4 Superjail"
	desc = "A massive cell, for only the most dangerous criminals. Has attack systems."
	icon = 'icons/mob/simple/superjail.dmi'
	icon_state="jail"
	icon_living="jail"
	health = 1000
	maxHealth = 1000
	combat_mode = TRUE
	sentience_type = SENTIENCE_BOSS
	mob_biotypes = MOB_ROBOTIC|MOB_SPECIAL
	light_range = 3
	faction = list(FACTION_BOSS)
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	unsuitable_atmos_damage = 0
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = INFINITY
	pull_force = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_HUGE
	layer = LARGE_MOB_LAYER
	plane = GAME_PLANE_UPPER_FOV_HIDDEN
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	speech_span = SPAN_COMMAND
	basic_mob_flags = DEL_ON_DEATH
	ai_controller = /datum/ai_controller/basic_controller/superjail

/mob/living/basic/boss/super_jail/Initialize(mapload)
	. = ..()
	ai_controller.set_ai_status(AI_STATUS_OFF) //when we get hit and it deals damage, we start the fight
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, INNATE_TRAIT)
	AddComponent(/datum/component/seethrough_mob)
	add_traits(list(TRAIT_NO_TELEPORT, TRAIT_MARTIAL_ARTS_IMMUNE), MEGAFAUNA_TRAIT)
	RegisterSignal(src, COMSIG_MOB_AFTER_APPLY_DAMAGE, PROC_REF(on_damaged))
	AddComponent(/datum/component/appearance_on_aggro, aggro_state = "angy")
	AddElement(/datum/element/death_drops, string_list(list(/obj/effect/temp_visual/superjail_death)))
	
	grant_actions_by_list(list(
		/datum/action/cooldown/mob_cooldown/missile_burst = BB_SUPERJAIL_MISSILEBURST_ABILITY,
		/datum/action/cooldown/mob_cooldown/laser_burst = BB_SUPERJAIL_LASERBURST_ABILITY,
		/datum/action/cooldown/mob_cooldown/projectile_attack/spiral_shots/laser = BB_SUPERJAIL_LASERSPIRAL_ABILITY,
	))

/mob/living/basic/boss/super_jail/emp_reaction(severity)
	switch(severity)
		if(EMP_LIGHT)
			apply_damage(100)
			Shake(duration = 0.5 SECONDS)
		if(EMP_HEAVY)
			apply_damage(150)
			Shake(duration = 0.7 SECONDS)

/mob/living/basic/boss/super_jail/proc/on_damaged(datum/source, damage, damagetype, def_zone, blocked, wound_bonus, bare_wound_bonus, sharpness, attack_direction, attacking_item)
	SIGNAL_HANDLER
	if(!damage)
		return
	if(ai_controller.ai_status == AI_STATUS_ON || stat == DEAD)
		return
	ai_controller.set_ai_status(AI_STATUS_ON) // alright time to fight
	playsound(src, 'sound/machines/engine_alert2.ogg', 60, TRUE)
	visible_message(span_danger("[src] lets out an alert as defense systems begin to activate!"))
	say("COMBATANT DETECTED. ACTIVATING SYSTEMS.")

/obj/effect/temp_visual/superjail_death
	name = "NT-4 Superjail"
	icon = 'icons/mob/simple/superjail.dmi'
	icon_state = "angy"
	desc = "Not a good sign."
	duration = 4.5 SECONDS
	/// on completion we spawn this
	var/spawn_type = /mob/living/basic/boss/juggernaut

/obj/effect/temp_visual/superjail_death/Initialize(mapload)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(cool_animation))

/obj/effect/temp_visual/superjail_death/proc/cool_animation()
	Shake(5, 5, 0.5 SECONDS)
	playsound(src, 'sound/effects/bang.ogg', 50, TRUE)
	sleep(1 SECONDS)
	Shake(5, 5, 0.5 SECONDS)
	playsound(src, 'sound/effects/bang.ogg', 50, TRUE)
	sleep(1 SECONDS)
	Shake(13,13, 1 SECONDS)
	playsound(src, 'sound/effects/bang.ogg', 75, TRUE)
	sleep(1 SECONDS)
	playsound(src, 'sound/effects/explosion2.ogg', 75, TRUE)
	explosion(loc, flame_range = 2, flash_range = 3, silent = TRUE, smoke = FALSE, explosion_cause = src)
	new spawn_type(loc)
	qdel(src)
