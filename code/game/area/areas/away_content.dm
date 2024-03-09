/*
Unused icons for new areas are "awaycontent1" ~ "awaycontent30"
*/


// Away Missions
/area/awaymission
	name = "Strange Location"
	icon = 'icons/area/areas_away_missions.dmi'
	icon_state = "away"
	has_gravity = STANDARD_GRAVITY
	ambience_index = AMBIENCE_AWAY
	sound_environment = SOUND_ENVIRONMENT_ROOM
	area_flags = UNIQUE_AREA

/area/awaymission/beach
	name = "Beach"
	icon_state = "away"
	static_lighting = FALSE
	base_lighting_alpha = 255
	base_lighting_color = "#FFFFCC"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	ambientsounds = list('sound/ambience/shore.ogg', 'sound/ambience/seag1.ogg','sound/ambience/seag2.ogg','sound/ambience/seag2.ogg','sound/ambience/ambiodd.ogg','sound/ambience/ambinice.ogg')

/area/awaymission/museum
	name = "Nanotrasen Museum"
	icon_state = "awaycontent28"
	sound_environment = SOUND_ENVIRONMENT_CONCERT_HALL

/area/awaymission/museum/mothroachvoid
	static_lighting = FALSE
	base_lighting_alpha = 200
	base_lighting_color = "#FFF4AA"
	sound_environment = SOUND_ENVIRONMENT_PLAIN
	ambientsounds = list('sound/ambience/shore.ogg', 'sound/ambience/ambiodd.ogg','sound/ambience/ambinice.ogg')

/area/awaymission/museum/cafeteria
	name = "Nanotrasen Museum Cafeteria"
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/awaymission/threat
	name = "Dimensional Incursion"
	icon_state = "awaycontent27"
	sound_environment = SOUND_ENVIRONMENT_QUARRY

/area/awaymission/threat/sewer
	name = "Dimensional Incursion (Sewer)"
	icon_state = "awaycontent25"
	sound_environment = SOUND_ENVIRONMENT_STONEROOM

/area/awaymission/threat/outdoors
	name = "Dimensional Incursion (Outdoors)"
	icon_state = "awaycontent26"
	sound_environment = SOUND_ENVIRONMENT_MOUNTAINS
	outdoors = TRUE

/area/awaymission/threat/outdoors/Initialize(mapload)
	. = ..()
	//Taken (and changed, naturally) from weather code (code/datums/weather)
	for(var/offset in 0 to SSmapping.max_plane_offset)
		/*var/mutable_appearance/glow_overlay = mutable_appearance('icons/effects/glow_weather.dmi', "light_snow", AREA_LAYER, null, ABOVE_LIGHTING_PLANE, 100, offset_const = offset)
		overlays += glow_overlay*/

		var/mutable_appearance/weather_overlay = mutable_appearance('icons/effects/weather_effects.dmi', "light_snow", AREA_LAYER, plane = AREA_PLANE, offset_const = offset)
		overlays += weather_overlay

/area/awaymission/errorroom
	name = "Super Secret Room"
	static_lighting = FALSE
	base_lighting_alpha = 255
	area_flags = UNIQUE_AREA|NOTELEPORT
	has_gravity = STANDARD_GRAVITY

/area/awaymission/secret
	area_flags = UNIQUE_AREA|NOTELEPORT|HIDDEN_AREA

/area/awaymission/secret/unpowered
	always_unpowered = TRUE

/area/awaymission/secret/unpowered/outdoors
	outdoors = TRUE

/area/awaymission/secret/unpowered/no_grav
	has_gravity = FALSE

/area/awaymission/secret/fullbright
	static_lighting = FALSE
	base_lighting_alpha = 255

/area/awaymission/secret/powered
	requires_power = FALSE

/area/awaymission/secret/powered/fullbright
	static_lighting = FALSE
	base_lighting_alpha = 255
