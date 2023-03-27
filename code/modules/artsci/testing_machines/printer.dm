/datum/export/analyzed_artifact
	cost = -CARGO_CRATE_VALUE
	k_elasticity = 0
	unit_name = "artifact"
	allow_negative_cost = TRUE
	export_types = list(/obj)

/datum/export/analyzed_artifact/applies_to(obj/object, apply_elastic = TRUE)
	if(object.GetComponent(/datum/component/artifact))
		return TRUE
	return ..()

/datum/export/analyzed_artifact/get_cost(obj/object)
	var/datum/component/artifact/art = object.GetComponent(/datum/component/artifact)
	if(!art || !art.analysis)
		return -CARGO_CRATE_VALUE
	return art.analysis.get_export_value(art)

/obj/item/sticker/analysis_form
	name = "analysis form"
	desc = "An analysis form for artifacts, has adhesive on the back."
	gender = NEUTER
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "analysisform"
	inhand_icon_state = "paper"
	throwforce = 0
	throw_range = 1
	throw_speed = 1
	max_integrity = 50
	drop_sound = 'sound/items/handling/paper_drop.ogg'
	pickup_sound = 'sound/items/handling/paper_pickup.ogg'
	contraband = STICKER_NOSPAWN
	var/chosen_origin = ""
	var/list/chosentriggers = list()
	var/chosentype = ""

/obj/item/sticker/analysis_form/attackby(obj/item/item, mob/living/user, params)
	if(istype(item, /obj/item/pen))
		ui_interact(user)
	else
		return ..()

/obj/item/sticker/analysis_form/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ArtifactForm", name)
		ui.open()

/obj/item/sticker/analysis_form/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(!istype(usr.get_active_held_item(), /obj/item/pen))
		to_chat(usr, span_notice("You need a pen to write on [src]!"))
		return
	switch(action)
		if("origin")
			chosen_origin = params["origin"]
		if("type")
			chosentype = params["type"]
		if("trigger")
			var/trig = params["trigger"]
			if(trig in chosentriggers)
				chosentriggers -= trig
			else
				chosentriggers += trig
	if(attached)
		analyze_attached()

/obj/item/sticker/analysis_form/ui_static_data(mob/user)
	. = ..()
	.["allorigins"] = SSartifacts.artifact_origin_name_to_typename
	.["alltypes"] = SSartifacts.artifact_type_names
	.["alltriggers"] = SSartifacts.artifact_trigger_name_to_type
	return

/obj/item/sticker/analysis_form/ui_data(mob/user)
	. = ..()
	.["chosenorigin"] = chosen_origin
	.["chosentype"] = chosentype
	.["chosentriggers"] = chosentriggers
	return .

/obj/item/sticker/analysis_form/can_interact(mob/user)
	if(attached && user.Adjacent(attached))
		return TRUE
	return ..()
	
/obj/item/sticker/analysis_form/register_signals(mob/living/user)
	. = ..()
	RegisterSignal(attached, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/obj/item/sticker/analysis_form/unregister_signals(datum/source)
	. = ..()
	UnregisterSignal(attached, list(COMSIG_PARENT_EXAMINE))

/obj/item/sticker/analysis_form/examine(mob/user)
	. = ..()
	if(!in_range(user, (attached ? attached : src)) && !isobserver(user))
		return
	ui_interact(user)

/obj/item/sticker/analysis_form/proc/on_examine(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_notice("It has an artifact analysis form attached to it...")
	ui_interact(user)

/obj/item/sticker/analysis_form/examine(mob/user)
	. = ..()
	if(!in_range(user, (attached ? attached : src)) && !isobserver(user))
		return
	ui_interact(user)

/obj/item/sticker/analysis_form/ui_status(mob/user,/datum/ui_state/ui_state)
	if(!in_range(user, (attached ? attached : src)) && !isobserver(user))
		return UI_CLOSE
	if(user.incapacitated(IGNORE_RESTRAINTS|IGNORE_GRAB) || (isobserver(user) && !isAdminGhostAI(user)))
		return UI_UPDATE
	if(user.is_blind())
		to_chat(user, span_warning("You are blind!"))
		return UI_CLOSE
	if(!user.can_read(src))
		return UI_CLOSE
	if(attached && in_range(user, attached))
		return UI_INTERACTIVE
	return ..()
//analysis

/obj/item/sticker/analysis_form/stick(atom/target, mob/living/user, px,py)
	..()
	analyze_attached()

/obj/item/sticker/analysis_form/peel(atom/source)
	SIGNAL_HANDLER
	deanalyze_attached()
	..()

/obj/item/sticker/analysis_form/proc/analyze_attached()
	var/datum/component/artifact/to_analyze = attached.GetComponent(/datum/component/artifact)
	if(!to_analyze)
		return
	if(chosen_origin)
		to_analyze.holder.name = to_analyze.names[chosen_origin]
	if(chosentype)
		to_analyze.holder.name += " ([chosentype])"

/obj/item/sticker/analysis_form/proc/deanalyze_attached()
	var/datum/component/artifact/to_analyze = attached.GetComponent(/datum/component/artifact)
	if(!to_analyze)
		return
	to_analyze.holder.name = to_analyze.fake_name

/obj/item/sticker/analysis_form/proc/get_export_value(datum/component/artifact/art)
	var/correct = 0
	var/total_guesses = 0 

	if(art.artifact_origin.type_name == chosen_origin)
		correct += 1
	if(chosen_origin)
		total_guesses += 1
	if(chosentype)
		total_guesses += 1
	if(art.type_name == chosentype)
		correct += 1
	for(var/name in chosentriggers)
		total_guesses += 1
		if(locate(SSartifacts.artifact_trigger_name_to_type[name]) in art.triggers)
			correct += 1

	var/incorrect = total_guesses - correct
	return round((CARGO_CRATE_VALUE/4) * art.potency * (max((ARTIFACT_COMMON - art.weight) * 0.01, 0.01) * max(correct - incorrect, 0.01)))
