class_name Registry

const BladeType = WaveData.BladeType

static func create_chain_whip() -> ChainWhip {
	return preload("res://scenes/battle/repeating_chain.tscn").instantiate()
}

static func create_options() -> Options {
	return load("res://scenes/ui/options_pane.tscn").instantiate()
}

static func create_stage_select() -> StageSelect {
	return load("res://scenes/ui/stage_select.tscn").instantiate()
}

static func create_stage_handler() -> StageHandler {
	return load("res://scenes/master/stage_handler.tscn").instantiate()
}

static func create_intro() -> IntroSequence {
	return load("res://scenes/master/intro_sequence.tscn").instantiate()
}

static func create_results() -> Results {
	return preload("res://scenes/master/results.tscn").instantiate()
}

static func blade_from_type(type: BladeType) -> Blade {
	var scene: String
	match type:
		BladeType.ANGRY_GUY:
			scene = "res://scenes/blade/angry_boss.tscn"
		BladeType.AOE_GUY:
			scene = "res://scenes/blade/aoe_boss.tscn"
		BladeType.CLONE_GUY:
			scene = "res://scenes/blade/clone_boss.tscn"
		BladeType.DRACULA_HIMSELF:
			scene = "res://scenes/blade/dracula.tscn"
		BladeType.SOME_GUY:
			scene = "res://scenes/blade/enemy_blade.tscn"
		BladeType.PROJECTILE_GUY:
			scene = "res://scenes/blade/spinning_projectile_enemy.tscn"
		BladeType.SWORD_GUY:
			scene = "res://scenes/blade/sword_boss.tscn"
		BladeType.TANKY_GUY:
			scene = "res://scenes/blade/parry_boss.tscn"
		BladeType.VAMP_GUY:
			scene = "res://scenes/blade/vamp_boss.tscn"
		_:
			assert(false, "go kill monarch")
			return null
	if scene: return load(scene).instantiate()
	return null
}
