//This infection is gained by being around the infected. The mindshielded gain it slower and lose it faster.
/datum/status_effect/bloodroot_infection
	id = "bloodroot"
	duration = -1
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	/// How infection?
	var/infection = 1 SECONDS
	/// The threshold for when we remove ourselves and convert the victim
	var/infection_threshold = 90 SECONDS // 1 minute 30 seconds, 3 minutes for the mindshielded
	/// the latest bloodroot infection that incremented our infection
	var/datum/team/bloodroot/latest_team_source
	/// infection hud
	var/datum/weakref/infection_hud
	/// cooldown that starts if we increment infection, disallows healing infection for 3 seconds
	COOLDOWN_DECLARE(last_infected)

/datum/status_effect/bloodroot_infection/on_apply()
	var/image/hud = image('icons/blanks/32x32.dmi', owner, "nothing")
	SET_PLANE_EXPLICIT(hud, ABOVE_GAME_PLANE, owner)
	infection_hud = WEAKREF(owner.add_alt_appearance(
		/datum/atom_hud/alternate_appearance/basic/has_antagonist,
		"infecthud_[REF(src)]",
		hud,
		/datum/antagonist/bloodroot,
	))
	return TRUE

/datum/status_effect/bloodroot_infection/on_remove()
	latest_team_source = null
	var/fuckin_hud = infection_hud.resolve()
	if(fuckin_hud)
		qdel(fuckin_hud)
	QDEL_NULL(infection_hud)

/datum/status_effect/bloodroot_infection/proc/infect_further(amount, team)
	latest_team_source = team
	infection += HAS_TRAIT(owner, TRAIT_MINDSHIELD) ? amount / 2 : amount
	update_maptext()
	COOLDOWN_START(src, last_infected, 3 SECONDS) //the person being affected is unable to heal off the infection for 3 seconds
	if(infection >= infection_threshold)
		latest_team_source.infect(owner)
		qdel(src)

/datum/status_effect/bloodroot_infection/tick(seconds_between_ticks)
	if(!COOLDOWN_FINISHED(src, last_infected))
		return
	infection -= (HAS_TRAIT(owner, TRAIT_MINDSHIELD) ? seconds_between_ticks * 2 : seconds_between_ticks) SECONDS
	update_maptext()
	if(infection <= 0)
		qdel(src)

/datum/status_effect/bloodroot_infection/proc/update_maptext()
	var/datum/atom_hud/alternate_appearance/basic/our_hud = infection_hud.resolve()
	our_hud.image.maptext = MAPTEXT("[ceil((infection / infection_threshold)*100)]%")

/datum/proximity_monitor/advanced/bloodroot
	edge_is_a_field = TRUE
	/// list of people we are infecting
	var/list/tracked_mobs = list()
	var/datum/team/bloodroot/team


/datum/proximity_monitor/advanced/bloodroot/New(atom/_host, range, _ignore_if_not_on_turf = TRUE, team)
	. = ..()
	START_PROCESSING(SSobj, src)
	src.team = team

/datum/proximity_monitor/advanced/bloodroot/Destroy()
	tracked_mobs = null
	team = null
	return ..()

/datum/proximity_monitor/advanced/bloodroot/field_turf_crossed(mob/living/carbon/human/entered, turf/old_location, turf/new_location)
	if (!istype(entered) || !entered.mind)
		return

	if (entered in tracked_mobs)
		return

	if(IS_BLOODROOT(entered))
		return

	if(!has_unblocked_line(new_location))
		return

	tracked_mobs += entered

	RegisterSignal(entered, COMSIG_QDELETING, PROC_REF(mob_destroyed))

/datum/proximity_monitor/advanced/bloodroot/field_turf_uncrossed(mob/exited, turf/old_location, turf/new_location)
	if (!(exited in tracked_mobs))
		return
	if (exited.z == host.z && get_dist(exited, host) <= current_range && has_unblocked_line(new_location))
		return
	tracked_mobs -= exited
	UnregisterSignal(exited, COMSIG_QDELETING)

/datum/proximity_monitor/advanced/bloodroot/recalculate_field(full_recalc = FALSE)
	. = ..()
	for(var/mob/tracked as anything in tracked_mobs)
		field_turf_uncrossed(tracked, null, get_turf(tracked))
	for(var/mob/living/carbon/carbon in view(current_range, host))
		field_turf_crossed(carbon, null, get_turf(carbon))


/// Remove references on mob deletion
/datum/proximity_monitor/advanced/bloodroot/proc/mob_destroyed(mob/former_mob)
	SIGNAL_HANDLER
	if (former_mob in tracked_mobs)
		tracked_mobs -= former_mob

/datum/proximity_monitor/advanced/bloodroot/proc/can_we_convert_this_dude(mob/living/carbon/human/carbon)
	if(!istype(carbon))
		return FALSE
	if(!carbon.has_dna())
		return FALSE // gtfo people with blood only
	if(IS_BLOODROOT(carbon))
		return FALSE // i mean we also check it in the process but in process its needed to remove them from the list
	if(IS_CHANGELING(carbon) || IS_CULTIST(carbon))
		return FALSE //the biological horror and the bloodcult is immune
	if(carbon.head?.get_armor_rating(BIO) + carbon.wear_suit?.get_armor_rating(BIO) > 200)
		return FALSE //biosuit
	return TRUE

/datum/proximity_monitor/advanced/bloodroot/process(seconds_per_tick)
	var/mob/living/our_host = host
	if(our_host.stat == DEAD)
		return // u ded get lost bozo

	for(var/mob/living/carbon/carbon as anything in tracked_mobs)
		if(IS_BLOODROOT(carbon))
			tracked_mobs -= carbon //theyve just been infected
			continue
		if(!can_we_convert_this_dude(carbon))
			continue
		var/datum/status_effect/bloodroot_infection/infection = carbon.has_status_effect(/datum/status_effect/bloodroot_infection)
		if(!istype(infection))
			infection = carbon.apply_status_effect(/datum/status_effect/bloodroot_infection)
		infection.infect_further(seconds_per_tick SECONDS, team)

/// if we have an unblocked line to the destination, ignoring border objects we can pass or climbable objects, and ignoring mobs
/datum/proximity_monitor/advanced/bloodroot/proc/has_unblocked_line(destination)
	for(var/turf/potential_blockage as anything in get_line(host, destination))
		if(potential_blockage.density)
			return FALSE
		for(var/atom/movable/movable as anything in potential_blockage.contents)
			if(movable.density && !ismob(movable) && !HAS_TRAIT(movable, TRAIT_CLIMBABLE))
				if(movable.CanPass(host, get_dir(src, host)))
					continue
				return FALSE
	return TRUE
