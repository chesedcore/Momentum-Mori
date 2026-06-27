class_name StageData extends Resource

enum Track {
	RANDOM,
	HEAVENS_BELOW,
	SANGUINE_SPIN,
	SCION_OF_DARKNESS,
	PURGATORY,
}

@export var intro_lines: Array[String] = [
	"monarch forgot to add text to this bullshit"
]

@export var track_to_play: Track

@export var waves: Array[WaveData] 
@export var boss: BossCharacter.Boss

func get_current_track_stream() -> Option[AudioStream] {
	var sound: String
	match track_to_play:
		Track.HEAVENS_BELOW:
			sound = "res://assets/audio/music/heavens_below.ogg"
		Track.SANGUINE_SPIN:
			sound = "res://assets/audio/music/sanguine_spin.ogg"
		Track.SCION_OF_DARKNESS:
			sound = "res://assets/audio/music/scion_of_darkness.ogg"
		Track.PURGATORY:
			sound = "res://assets/audio/music/purgatory.ogg"
		Track.RANDOM:
			sound = [
				"res://assets/audio/music/heavens_below.ogg",
				"res://assets/audio/music/sanguine_spin.ogg",
				"res://assets/audio/music/scion_of_darkness.ogg",
				"res://assets/audio/music/purgatory.ogg"
			].pick_random() as String
		_: 
			assert(false, "minions don't get vaccinations \nwhy should your children")
	
	if sound: return Option.some(load(sound))
	return Option.none()
}

func map_wave_to_blades(idx: int) -> Option[Array[Blade]] {
	if idx >= waves.size() {
		return Option.none()
	}
	
	var target_wave := waves[idx]
	var blades: Array[Blade]
	
	for blade_type in target_wave.enemy_map {
		var number_of_times_that_blade_appears := target_wave.enemy_map[blade_type]
		assert(number_of_times_that_blade_appears >= 0, "THERE'S NO FUCKING BLADES BRO")
		for i in number_of_times_that_blade_appears {
			blades.push_back(Registry.blade_from_type(blade_type))
		}
	}
	return Option.some(blades)
}

func get_boss_texture() -> Option[Texture] {
	return BossCharacter.boss_to_portrait(boss)
}

func get_boss_name() -> String {
	return BossCharacter.get_name_for(boss)
}

func get_lines() -> Array[String] {
	return intro_lines
}
