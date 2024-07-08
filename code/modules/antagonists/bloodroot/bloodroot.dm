/datum/antagonist/bloodroot
	name = "\improper Bloodroot Infectee"
	roundend_category = "Bloodroot Infectee"
	show_in_antagpanel = TRUE
	antagpanel_category = ANTAG_GROUP_BIOHAZARDS
	prevent_roundtype_conversion = FALSE
	antag_hud_name = "bloodroot"
	/// our team
	var/datum/team/bloodroot/our_team
	/// Our infection field
	var/datum/proximity_monitor/advanced/bloodroot/infection_field
	/// Time since we got infected, independent of bloodroot effect
	var/time_since_infection = 0
	/// Have we started being visibly deformed?
	var/blooming = FALSE
	/// bloom overlay
	var/mutable_appearance/bloom_overlay

/datum/antagonist/bloodroot/get_preview_icon()
	var/icon/icon = icon(/obj/item/food/sandwich/cheese/grilled::icon, /obj/item/food/sandwich/cheese/grilled::icon_state)
	return finish_preview_icon(icon)

/datum/antagonist/bloodroot/greet()
	forge_objectives()
	. = ..()
	to_chat(owner, span_warning("You should not kill the uninfected nor sabotage the station, or do anything that would prevent infection or hinder your fellow infectees."))
	owner.announce_objectives()

/datum/antagonist/bloodroot/forge_objectives()
	var/datum/objective/survive/objective = new
	objective.explanation_text = "Spread the infestation by being close to the uninfected."
	objective.owner = owner
	objectives += objective

	objective = new
	objective.owner = owner
	objectives += objective

/datum/antagonist/bloodroot/create_team(datum/team/bloodroot/new_team)
	if(!new_team)
		for(var/datum/antagonist/bloodroot/infected in GLOB.antagonists)
			if(!isnull(infected.owner))
				continue
			if(infected.our_team)
				our_team = infected.our_team
				return
		our_team = new
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	our_team = new_team

/datum/antagonist/bloodroot/get_team()
	return our_team

/datum/antagonist/bloodroot/apply_innate_effects(mob/living/mob_override)
	add_team_hud(mob_override || owner.current)
	infection_field = new(mob_override || owner.current, range = 2, team = get_team())
	var/datum/action/_ability = new /datum/action/cooldown/bloodroot_hivemind(mob_override || owner.current)
	_ability.Grant(mob_override || owner.current)
	START_PROCESSING(SSobj, src)

/datum/antagonist/bloodroot/remove_innate_effects(mob/living/mob_override)
	QDEL_NULL(infection_field)
	var/mob/living/the_guy = mob_override || owner.current
	qdel(locate(/datum/action/cooldown/bloodroot_hivemind) in the_guy.actions)
	revert_bloom()
	STOP_PROCESSING(SSobj, src)

/datum/antagonist/bloodroot/proc/bloom()
	if(blooming)
		return
	blooming = TRUE
	var/mob/living/carbon/human/human_owner = owner.current
	var/datum/physiology/owner_physiology = human_owner.physiology
	owner_physiology.burn_mod += 0.3
	owner_physiology.stamina_mod -= 0.5
	bloom_overlay = mutable_appearance('icons/mob/effects/bloodroot_veins.dmi', "veins", -BODY_ADJ_LAYER)
	bloom_overlay.blend_mode = BLEND_INSET_OVERLAY
	owner.current.add_overlay(bloom_overlay)

/datum/antagonist/bloodroot/proc/revert_bloom()
	if(!blooming)
		return
	blooming = FALSE
	var/mob/living/carbon/human/human_owner = owner.current
	var/datum/physiology/owner_physiology = human_owner.physiology
	owner_physiology.burn_mod -= 0.3
	owner_physiology.stamina_mod += 0.5
	human_owner.cut_overlay(bloom_overlay)

// HORRIBLE idea but
/datum/antagonist/bloodroot/process(seconds_per_tick)
	if(!ishuman(owner.current))
		return
	var/mob/living/carbon/human/us = owner.current
	if(us.stat == DEAD)
		return
	time_since_infection += seconds_per_tick SECONDS
	if(time_since_infection >= 10 MINUTES && !blooming)
		bloom()
		to_chat(owner.current, span_userdanger("Your form begins to decay and bloom..."))
		to_chat(owner.current, span_notice("You are now slightly more resistant to stamina damage."))
		to_chat(owner.current, span_warning("You are weaker to burns."))
		to_chat(owner.current, span_danger("Your form will continue to decay. Its only a matter of time before youre forced to shed your own."))
	else if(time_since_infection >= 35 MINUTES)
		pass()
		//gib + make monster
