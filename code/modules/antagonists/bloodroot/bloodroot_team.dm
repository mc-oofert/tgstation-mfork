/datum/team/bloodroot
	name = "Bloodroot Infected"

/datum/team/bloodroot/proc/infect(mob/living/infected, source)
	if (isnull(infected) || IS_BLOODROOT(infected))
		return FALSE
#ifndef TESTING
	if(!GET_CLIENT(infected))
		return FALSE
#endif
	for (var/datum/mind/fellow as anything in members)
		if (fellow == infected.mind)
			continue

		to_chat(fellow, span_notice("A prickly feeling throbs in your head... [span_bold("[infected.real_name]")] has been infected."))

	infected.mind.add_antag_datum(/datum/antagonist/bloodroot, src)

	return TRUE
