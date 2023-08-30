/obj/effect/forcefield/wizard/heretic
	name = "consecrated lintel passage"
	desc = "A field of papers flying in the air, repulsing heathens with impossible force."
	icon_state = "lintel"
	initial_duration = 8 SECONDS

/obj/effect/forcefield/wizard/heretic/Bumped(mob/living/bumpee)
	. = ..()
	if(istype(bumpee) && !IS_HERETIC_OR_MONSTER(bumpee))
		var/throwtarget = get_edge_target_turf(loc, get_dir(loc, get_step_away(bumpee, loc)))
		bumpee.safe_throw_at(throwtarget, 10, 1, force = MOVE_FORCE_EXTREMELY_STRONG)

/obj/item/heretic_lintel
	name = "consecrated lintel"
	desc = "Some kind of book, its contents make your head hurt, the material is not known to you and it seems to shift and twist unnaturally."
	icon = 'icons/obj/service/library.dmi'
	icon_state = "hereticlintel"
	force = 10
	damtype = BURN
	worn_icon_state = "book"
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb_continuous = list("bashes", "curses")
	attack_verb_simple = list("bash", "curse")
	resistance_flags = FLAMMABLE
	drop_sound = 'sound/items/handling/book_drop.ogg'
	pickup_sound = 'sound/items/handling/book_pickup.ogg'
	var/barrier_type = /obj/effect/forcefield/wizard/heretic
	var/uses = 3

/obj/item/heretic_lintel/examine(mob/user)
	. = ..()
	if(IS_HERETIC_OR_MONSTER(user))
		. += span_hypnophrase("It can materialize a barrier at any tile in sight that only you can pass. Lasts 8 seconds.")
		. += span_hypnophrase("It has <b>[uses]</b> uses left.")

/obj/item/heretic_lintel/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(IS_HERETIC(user))
		var/turf/turf_target = get_turf(target)
		if(locate(barrier_type) in turf_target)
			user.balloon_alert(user, "there is already one there!")
			return
		turf_target.visible_message(span_warning("A storm of paper materializes!"))
		new /obj/effect/temp_visual/paper_scatter(turf_target)
		playsound(turf_target, 'sound/magic/smoke.ogg', 30)
		new barrier_type(turf_target, user)
		uses--
		if(!uses)
			to_chat(user, span_warning("[src] falls apart, turning into ash and dust!"))
			qdel(src)
	else
		var/mob/living/carbon/human/human_user = user
		to_chat(human_user, span_userdanger("Your mind burns as you stare deep into the book, a headache setting in like your brain is on fire!"))
		human_user.adjustOrganLoss(ORGAN_SLOT_BRAIN, 30, 190)
		human_user.add_mood_event("gates_of_mansus", /datum/mood_event/gates_of_mansus)
		human_user.dropItemToGround(src)
