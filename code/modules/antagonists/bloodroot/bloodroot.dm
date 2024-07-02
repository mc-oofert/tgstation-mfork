/datum/antagonist/bloodroot
	name = "\improper Bloodroot Infectee"
	roundend_category = "Bloodroot Infectee"
	show_in_antagpanel = TRUE
	antagpanel_category = ANTAG_GROUP_BIOHAZARDS
	prevent_roundtype_conversion = FALSE
	antag_hud_name = "bloodroot"
	var/datum/team/bloodroot/our_team
	var/datum/proximity_monitor/advanced/bloodroot/infection_field

/datum/antagonist/bloodroot/get_preview_icon()
	var/icon/icon = icon(/obj/item/food/sandwich/cheese/grilled::icon, /obj/item/food/sandwich/cheese/grilled::icon_state)
	return finish_preview_icon(icon)

/datum/antagonist/bloodroot/greet()
	. = ..()
	to_chat(owner, span_warning("You should not kill the uninfected nor sabotage the station, or do anything that would prevent infection or hinder your fellow infectees."))
	owner.announce_objectives()

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

/datum/antagonist/bloodroot/remove_innate_effects(mob/living/mob_override)
	QDEL_NULL(infection_field)

