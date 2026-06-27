class_name StageHandler extends Control

signal exit(won_stage: bool, with_data: StageData)

@export var stage_dock: Control
@export var intro_dock: Control

var data: StageData
var _field: Field
var _current_wave_idx: int = 0

static func from(stage_data: StageData) -> StageHandler {
	var handler := Registry.create_stage_handler()
	handler.data = stage_data
	return handler
}

func _ready() -> void {
	_initiate_intro_sequence()
}

func _initiate_intro_sequence() -> IntroSequence {
	var intro := IntroSequence.from_lines(data.get_lines())
	intro_dock.add_child(intro)
	intro._internal_finished.connect(start_game, CONNECT_ONE_SHOT)
	return intro
}

func start_game() -> void {
	var field_scene := load("res://scenes/battle/field.tscn") as PackedScene
	_field = field_scene.instantiate() as Field
	stage_dock.add_child(_field)

	#swap the music track defined by this stage
	var track := data.get_current_track_stream()
	if track.is_some() {
		_field.music_player.stream = track.unwrap()
		_field.music_player.play()
	}

	_spawn_wave(_current_wave_idx)
}

# !!!Wave management!!!

func _spawn_wave(wave_idx: int) -> void {
	var blades_opt := data.map_wave_to_blades(wave_idx)
	if blades_opt.is_none() {
		push_error("blades not found!!!!!!!")
		_on_all_waves_cleared()
		return
	}
	
	var blades: Array[Blade] = blades_opt.unwrap()
	var enemies_node := _field.stadium.enemies
	
	
	var count := blades.size()
	for i in count {
		var blade := blades[i]
		
		#angle in a circle while rand-ing radius
		var angle := (TAU / maxf(count, 1)) * i
		var radius := randf_range(600.0, 1200.0)
		blade.global_position = Vector2(cos(angle), sin(angle)) * radius
		
		
		(blade as EnemyBlade).target = _field.stadium.player
		
		enemies_node.add_child(blade)
		blade.died.connect(_on_enemy_died, CONNECT_REFERENCE_COUNTED)
	}
}

func _on_enemy_died() -> void {
	await get_tree().process_frame
	
	var remaining := _field.stadium.enemies.get_child_count()
	if remaining > 0: return
	
	_current_wave_idx += 1
	
	if _current_wave_idx >= data.waves.size() {
		_on_all_waves_cleared()
	} else {
		_spawn_wave(_current_wave_idx)
	}
}

func _on_all_waves_cleared() -> void {
	exit.emit(true, data)
}
