/mob/living/basic/mimic
	response_help_continuous = "touches"
	response_help_simple = "touch"
	response_disarm_continuous = "pushes"
	response_disarm_simple = "push"
	speed = 6
	maxHealth = 250
	health = 250
	gender = NEUTER
	mob_biotypes = NONE
	pass_flags = PASSFLAPS
	melee_damage_lower = 8
	melee_damage_upper = 12
	attack_sound = 'sound/items/weapons/punch1.ogg'
	speak_emote = list("creaks")

	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	unsuitable_atmos_damage = 0

	faction = list(FACTION_MIMIC)
	//move_to_delay = 9
	basic_mob_flags = DEL_ON_DEATH
	combat_mode = TRUE
	/// can we stun people on hit
	var/knockdown_people = FALSE

/mob/living/basic/mimic/melee_attack(mob/living/carbon/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(!. || !knockdown_people || !prob(15) || istype(target))
		return
	target.Paralyze(4 SECONDS)
	target.visible_message(span_danger("\The [src] knocks down \the [target]!"), \
			span_userdanger("\The [src] knocks you down!"))


// ****************************
// CRATE MIMIC
// ****************************

// Aggro when you try to open them. Will also pickup loot when spawns and drop it when dies.
/mob/living/basic/mimic/crate
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/storage/crates.dmi'
	icon_state = "crate"
	icon_living = "crate"
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	speak_emote = list("clatters")
	layer = BELOW_MOB_LAYER
	ai_controller = /datum/ai_controller/basic_controller/mimic_crate
	/// are we open
	var/opened = FALSE
	/// max mob size
	var/max_mob_size = MOB_SIZE_HUMAN
	/// can we be opened or closed, if false we can
	var/locked = FALSE
	/// action to lock us
	var/datum/action/innate/mimic/lock/lock
	///A cap for items in the mimic. Prevents the mimic from eating enough stuff to cause lag when opened.
	var/storage_capacity = 50
	///A cap for mobs. Mobs count towards the item cap. Same purpose as above.
	var/mob_storage_capacity = 10

// Pickup loot
/mob/living/basic/mimic/crate/Initialize(mapload)
	. = ..()
	lock = new
	lock.Grant(src)
	ADD_TRAIT(src, TRAIT_AI_PAUSED, INNATE_TRAIT)
	ai_controller?.set_ai_status(AI_STATUS_OFF) //start inert, let gullible people pull us into cargo or something and then go nuts when opened
	if(mapload) //eat shit
		for(var/obj/item/I in loc)
			I.forceMove(src)

/mob/living/basic/mimic/crate/Destroy()
	lock = null
	return ..()

/mob/living/basic/mimic/crate/attack_hand(mob/living/carbon/human/user, list/modifiers)
	if(user.combat_mode)
		return ..()
	if(trigger())
		return TRUE
	toggle_open(user)
	return TRUE

/mob/living/basic/mimic/crate/melee_attack(mob/living/carbon/target, list/modifiers, ignore_cooldown)
	. = ..()
	toggle_open() // show our cool lid at the dumbass humans

/mob/living/basic/mimic/crate/proc/trigger()
	if(isnull(ai_controller) || client)
		return FALSE
	if(ai_controller.ai_status != AI_STATUS_OFF)
		return FALSE
	visible_message(span_danger("[src] starts to move!"))
	REMOVE_TRAIT(src, TRAIT_AI_PAUSED, INNATE_TRAIT)
	ai_controller.set_ai_status(AI_STATUS_ON)
	if(length(contents))
		locked = TRUE //if this was a crate with loot then we dont want people to just leftclick it to open it then bait it somewhere and steal its loot
	return TRUE

/mob/living/basic/mimic/crate/adjust_health(amount, updating_health = TRUE, forced = FALSE)
	if(amount > 0)
		trigger()
	return ..()

/mob/living/basic/mimic/crate/death()
	var/obj/structure/closet/crate/C = new(get_turf(src))
	// Put loot in crate
	for(var/obj/O in src)
		O.forceMove(C)
	return ..()

/mob/living/basic/mimic/crate/early_melee_attack(atom/target, list/modifiers, ignore_cooldown)
	if(target == src)
		toggle_open()
		return FALSE
	return ..()

/mob/living/basic/mimic/crate/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(istype(mover, /obj/structure/closet))
		return FALSE
/**
* Used to open and close the mimic
*
* Will insert tile contents into the mimic when closing
* Will dump mimic contents into the time when opening
* Does nothing if the mimic locked itself
*/
/mob/living/basic/mimic/crate/proc/toggle_open(mob/user)
	if(locked)
		if(user)
			balloon_alert(user, "too stiff!")
		return
	if(!opened)
		ADD_TRAIT(src, TRAIT_UNDENSE, MIMIC_TRAIT)
		opened = TRUE
		icon_state = "crateopen"
		playsound(src, 'sound/machines/crate/crate_open.ogg', 50, TRUE)
		for(var/atom/movable/movable as anything in src)
			movable.forceMove(loc)
	else
		REMOVE_TRAIT(src, TRAIT_UNDENSE, MIMIC_TRAIT)
		opened = FALSE
		icon_state = "crate"
		playsound(src, 'sound/machines/crate/crate_close.ogg', 50, TRUE)
		for(var/atom/movable/movable as anything in get_turf(src))
			if(movable != src && insert(movable) == -1)
				playsound(src, 'sound/items/trayhit/trayhit2.ogg', 50, TRUE)
				break
/**
* Called by toggle_open to put items inside the mimic when it's being closed
*
* Will return -1 if the insertion fails due to the storage capacity of the mimic having been reached
* Will return FALSE if insertion fails
* Will return TRUE if insertion succeeds
* Arguments:
* * AM - item to be inserted
*/
/mob/living/basic/mimic/crate/proc/insert(atom/movable/movable)
	if(contents.len >= storage_capacity)
		return -1
	if(insertion_allowed(movable))
		movable.forceMove(src)
		return TRUE
	return FALSE

/mob/living/basic/mimic/crate/proc/insertion_allowed(atom/movable/movable)
	if(ismob(movable))
		if(!isliving(movable))  //Don't let ghosts and such get trapped in the beast.
			return FALSE
		var/mob/living/living = movable
		if(living.anchored || living.buckled || living.incorporeal_move || living.has_buckled_mobs())
			return FALSE
		if(living.mob_size > MOB_SIZE_TINY) // Tiny mobs are treated as items.
			if(living.density || living.mob_size > max_mob_size)
				return FALSE
			var/mobs_stored = 0
			for(var/mob/living/living_mob in contents)
				mobs_stored++
				if(mobs_stored >= mob_storage_capacity)
					return FALSE
		living.stop_pulling()

	else if(istype(movable, /obj/structure/closet))
		return FALSE
	else if(isobj(movable))
		if(movable.anchored || movable.has_buckled_mobs())
			return FALSE
		else if(isitem(movable) && !HAS_TRAIT(movable, TRAIT_NODROP))
			return TRUE
	else
		return FALSE
	return TRUE

/mob/living/basic/mimic/crate/xenobio
	health = 210
	maxHealth = 210
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	speak_emote = list("clatters")
	gold_core_spawnable = HOSTILE_SPAWN

/datum/action/innate/mimic
	background_icon_state = "bg_default"
	overlay_icon_state = "bg_default_border"

/datum/action/innate/mimic/lock
	name = "Lock/Unlock"
	desc = "Toggle preventing yourself from being opened or closed."
	button_icon = 'icons/hud/radial.dmi'
	button_icon_state = "radial_lock"

/datum/action/innate/mimic/lock/Activate()
	var/mob/living/basic/mimic/crate/mimic = owner
	mimic.locked = !mimic.locked
	if(!mimic.locked)
		to_chat(mimic, span_warning("You loosen up, allowing yourself to be opened and closed."))
	else
		to_chat(mimic, span_warning("You stiffen up, preventing anyone from opening or closing you."))

// ****************************
// COPYING (actually imitates target object) MIMIC
// ****************************

/mob/living/basic/mimic/copy
	health = 100
	maxHealth = 100
	mob_biotypes = MOB_SPECIAL
	ai_controller = /datum/ai_controller/basic_controller/mimic_copy
	/// our creator
	var/mob/living/creator = null
	/// googly eyes overlay
	var/static/mutable_appearance/googly_eyes = mutable_appearance('icons/mob/simple/mob.dmi', "googly_eyes")
	/// do we overlay googly eyes over whatever we copy
	var/overlay_googly_eyes = TRUE
	/// do we take damage when we are not sentient and have no target
	var/idledamage = TRUE

/mob/living/basic/mimic/copy/Initialize(mapload, obj/copy, mob/living/creator, destroy_original = FALSE, no_googlies = FALSE)
	. = ..()
	ADD_TRAIT(src, TRAIT_PERMANENTLY_MORTAL, INNATE_TRAIT) // They won't remember their original contents upon ressurection and would just be floating eyes
	if (no_googlies)
		overlay_googly_eyes = FALSE
	CopyObject(copy, creator, destroy_original)

/mob/living/basic/mimic/copy/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	..()
	if(idledamage && !ckey && !ai_controller?.blackboard[BB_BASIC_MOB_CURRENT_TARGET]) //Objects eventually revert to normal if no one is around to terrorize
		adjustBruteLoss(0.5 * seconds_per_tick)
	for(var/mob/living/victim in contents) //a fix for animated statues from the flesh to stone spell
		death()

/mob/living/basic/mimic/copy/death()
	for(var/atom/movable/movable as anything in src)
		movable.forceMove(get_turf(src))
	return ..()

/mob/living/basic/mimic/copy/wabbajack(what_to_randomize, change_flags = WABBAJACK)
	visible_message(span_warning("[src] resists polymorphing into a new creature!"))

/mob/living/basic/mimic/copy/animate_atom_living(mob/living/owner)
	change_owner(owner)

/mob/living/basic/mimic/copy/proc/change_owner(mob/owner)
	if(isnull(owner) || creator == owner)
		return
	unfriend(creator)
	befriend(owner)

/mob/living/basic/mimic/copy/proc/check_object(obj/target)
	return ((isitem(target) || isstructure(target)) && !is_type_in_typecache(target, GLOB.animatable_blacklist))

/mob/living/basic/mimic/copy/proc/CopyObject(obj/original, mob/living/user, destroy_original = FALSE)
	if(destroy_original || check_object(original))
		original.forceMove(src)
		name = original.name
		desc = original.desc
		icon = original.icon
		icon_state = original.icon_state
		icon_living = icon_state
		copy_overlays(original)
		if (overlay_googly_eyes)
			add_overlay(googly_eyes)
		if(isstructure(original) || ismachinery(original))
			health = (anchored * 50) + 50
			if(original.density && original.anchored)
				knockdown_people = TRUE
				melee_damage_lower *= 2
				melee_damage_upper *= 2
		else if(isitem(original))
			var/obj/item/I = original
			health = 15 * I.w_class
			melee_damage_lower = 2 + I.force
			melee_damage_upper = 2 + I.force
		maxHealth = health
		if(user)
			befriend(user)
		if(destroy_original)
			qdel(original)
		return TRUE
	return FALSE

/mob/living/basic/mimic/copy/machine
	ai_controller = /datum/ai_controller/basic_controller/mimic_copy/machine
	faction = list(FACTION_MIMIC, FACTION_SILICON)

/mob/living/basic/mimic/copy/ranged
	ai_controller = /datum/ai_controller/basic_controller/mimic_copy/gun
	var/obj/item/gun/gun

/mob/living/basic/mimic/copy/ranged/Destroy()
	gun = null
	return ..()

/mob/living/basic/mimic/copy/ranged/RangedAttack(atom/atom_target, modifiers)
	INVOKE_ASYNC(src, PROC_REF(fire_gun), atom_target, modifiers)

/mob/living/basic/mimic/copy/ranged/proc/fire_gun(atom/target, modifiers) // i cant find any better way to do this
	if(!gun.can_shoot())
		if(istype(gun, /obj/item/gun/ballistic))
			var/obj/item/gun/ballistic/ballistic = gun
			if(!ballistic.chambered || ballistic.bolt_locked)
				ballistic.rack() //we racked so both checked variables should be something else now
			if(!ballistic.chambered?.loaded_projectile && (isnull(ballistic.magazine) || !length(ballistic.magazine.stored_ammo))) // ran out of ammo
				ai_controller?.set_blackboard_key(BB_GUNMIMIC_GUN_EMPTY, TRUE)
		else
			ai_controller?.set_blackboard_key(BB_GUNMIMIC_GUN_EMPTY, TRUE)
	else
		ai_controller?.set_blackboard_key(BB_GUNMIMIC_GUN_EMPTY, FALSE)
	gun.fire_gun(target, user = src, flag = FALSE, params = modifiers) //still make like a cool click click sound if trying to fire empty

/mob/living/basic/mimic/copy/ranged/CopyObject(obj/item/gun/original, mob/living/creator, destroy_original = 0)
	if(..())
		obj_damage = 0
		environment_smash = ENVIRONMENT_SMASH_NONE //needed? seems weird for them to do so
		melee_damage_upper = original.force
		melee_damage_lower = original.force - max(0, (original.force / 2))
		gun = original

/mob/living/basic/mimic/copy/ranged/can_use_guns(obj/item/gun)
	return TRUE
