/mob/living/basic/boss/juggernaut
	name = "Syndicate Juggernaut"
	desc = "An absolutely massive syndicate commando. Like, 95% muscle, 100% POWAH."
	icon = 'icons/mob/simple/juggernaut.dmi'
	icon_state="juggernaut"
	icon_living="juggernaut"
	icon_dead="juggernaut" // didnt know how to sprite sorry
	health = 2000
	maxHealth = 2000
	mob_biotypes = MOB_HUMANOID|MOB_SPECIAL
	faction = list(FACTION_BOSS)
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 0, STAMINA = 0, OXY = 0)
	melee_damage_lower = 20
	melee_damage_upper = 40
	armour_penetration = 30
	pixel_x = -16
	base_pixel_x = -16
	speed = 3
	move_resist = INFINITY
	speech_span = SPAN_COMMAND
	can_buckle = TRUE
	max_buckled_mobs = 1
	basic_mob_flags = REMAIN_DENSE_WHILE_DEAD | FLIP_ON_DEATH
	ai_controller = /datum/ai_controller/basic_controller/juggernaut_syndicate

/mob/living/basic/boss/juggernaut/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/wall_tearer)
	AddElement(/datum/element/death_drops, string_list(list(/obj/item/mod/control/pre_equipped/nuclear/unrestricted/juggernaut_drop)))
	ai_controller.set_blackboard_key(BB_BASIC_MOB_SPEAK_LINES, list(
		BB_EMOTE_SAY = list("NANOTRASEN SCUM!", "YOU WILL PAY FOR WHAT YOU DID!!!", "FIGHT ME!", "I EAT NANOTRASEN WORMS LIKE YOU FOR BREAKFAST!!"),
		BB_EMOTE_SEE = list("flexes his muscles in a threatening manner"),
		BB_SPEAK_CHANCE = 10,
	))
	grant_actions_by_list(list(
		/datum/action/cooldown/mob_cooldown/charge/grapple = BB_SJUGGERNAUT_GRAPPLE_ABILITY,
		/datum/action/cooldown/mob_cooldown/forearm_drop = BB_SJUGGERNAUT_FINISHER_ABILITY,
		/datum/action/cooldown/mob_cooldown/ring_shockwaves = BB_SJUGGERNAUT_SHOCKWAVE_ABILITY,
	))

/obj/item/mod/control/pre_equipped/nuclear/unrestricted/juggernaut_drop

/obj/item/mod/control/pre_equipped/nuclear/unrestricted/juggernaut_drop/Initialize(mapload)
	. = ..()
	var/module = locate(/obj/item/mod/module/storage) in contents
	new /obj/item/photo/juggernaut_grandma(module)
	new /obj/item/toy/balloon/red(module)
	new /obj/item/book/granter/martial/cqc(module)

/obj/item/photo/juggernaut_grandma
	scribble = "Hope to see you soon again! -Grandma 2.9.2543"

/obj/item/photo/juggernaut_grandma/show(mob/user)
	user << browse_rsc(icon(file("icons/ui_icons/static_photo/grandma.png")), "tmp_photograndma.png")
	user << browse("<html><head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><title>[name]</title></head>" \
		+ "<body style='overflow:hidden;margin:0;text-align:center'>" \
		+ "<img src='tmp_photograndma.png' width='480' style='-ms-interpolation-mode:nearest-neighbor' />" \
		+ "[scribble ? "<br>Written on the back:<br><i>[scribble]</i>" : ""]"\
		+ "</body></html>", "window=photo_showing;size=480x468")
	onclose(user, "[name]")