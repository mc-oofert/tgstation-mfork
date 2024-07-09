/mob/living/basic/root_monster
	name = "Bloody Horror"
	desc = "A victim of bloodroot infection. Little traces of the former self remain, and weak to burns. Regardless, run."
	icon = 'icons/mob/nonhuman-player/bloodroot.dmi'
	icon_state = "horror1"
	faction = list(FACTION_HOSTILE, FACTION_VINES, FACTION_PLANTS)
	basic_mob_flags = DEL_ON_DEATH
	gender = NEUTER
	mob_biotypes = MOB_ORGANIC | MOB_PLANT
	maxhealth = 300

	habitable_atmos = null
	damage_coeff = list(BRUTE = 0.5, BURN = 2, TOX = 0, STAMINA = 0, OXY = 0)
	speed = 0.5
	melee_attack_cooldown = CLICK_CD_MELEE

	attack_sound = 'sound/weapons/pierce_slow.ogg'
	response_help_continuous = "thinks better of touching"
	response_help_simple = "think better of touching"
	response_disarm_continuous = "flails at"
	response_disarm_simple = "flail at"
	response_harm_continuous = "rips"
	response_harm_simple = "tear"

	unsuitable_atmos_damage = 0

	combat_mode = TRUE
	ai_controller = null
	gold_core_spawnable = NO_SPAWN

	melee_damage_upper = 30

/mob/living/basic/root_monster/Initialize(mapload)
	. = ..()
	icon_state = "horror[rand(1,1)]" //todo more sprites

/mob/living/basic/root_monster/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	if(target == src)
		return //youre not getting revived stop hitting yourself
	. = ..()
