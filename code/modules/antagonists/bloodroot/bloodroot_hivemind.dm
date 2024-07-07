/datum/action/cooldown/bloodroot_hivemind
	name = "Rootmind"
	desc = "Chat with all the other infected."
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "rootmind"
	background_icon_state = "bg_hive"
	overlay_icon_state = "bg_hive_border"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/cooldown/bloodroot_hivemind/Activate(target)
	. = ..()
	var/datum/antagonist/bloodroot/root = IS_BLOODROOT(owner)
	if(isnull(root))
		qdel(src)
		return
	var/datum/team/bloodroot/root_team = root.get_team()
	var/input = tgui_input_text(owner, "What should you say?", "Bloodroot Hivemind")
	if(!input || QDELETED(src) || QDELETED(owner))
		return
	if(is_ic_filtered(input))
		tgui_alert(usr, "That contains a word prohibited in IC chat!")
		return

	var/mob/living/carbon/carbon_owner = owner
	input[1] = uppertext(input[1]) //uppercase first letter
	var/message = span_mind_control("(Rootmind) [istype(carbon_owner) ? carbon_owner.real_name : owner]: [input]")
	for(var/member in root_team.members)
		to_chat(member, message)
	for(var/ghost in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(ghost, owner)
		to_chat(ghost, "[link] [message]")
	owner.log_talk(message, LOG_SAY, tag = "bloodroot hivemind")
