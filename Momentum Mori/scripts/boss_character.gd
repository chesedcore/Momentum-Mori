class_name BossCharacter

enum Boss {
	OLIVIER,   #swords
	DWAYNE,    #defense
	METEONIS,  #aoe
	ONIBANCHO, #aggro
	COUNT_DRACULA, #you won't believe this
	BABA_YAGA, #clones
	FRAULEIN,  #lifestyle
}

static func boss_to_portrait(b: Boss) -> Option[Texture] {
	var path: String
	match b:
		Boss.OLIVIER:
			path = "res://assets/characters/olivier.webp"
		Boss.DWAYNE:
			path = "res://assets/characters/dwayne.webp"
		Boss.METEONIS:
			path = "res://assets/characters/meteonis.webp"
		Boss.ONIBANCHO:
			path = "res://assets/characters/youre_finished.webp"
		Boss.COUNT_DRACULA:
			path = "res://assets/characters/dracula.webp"
		Boss.BABA_YAGA:
			path = "res://assets/characters/baba yaga.webp"
		Boss.FRAULEIN:
			path = "res://assets/characters/fraulein.webp"
		_:
			assert(false, "oops")
	if not path: return Option.none()
	return Option.some(load(path))
}

static func get_name_for(b: Boss) -> String {
	return (Boss.find_key(b) as String).capitalize()
}
