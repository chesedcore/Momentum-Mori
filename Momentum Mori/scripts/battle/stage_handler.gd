class_name StageHandler extends Control

signal request_make_clear_invisible
signal request_restore_clear_visibility
signal exit(won_stage: bool, with_data: StageData)

@export var stage_dock: Control
@export var intro_dock: Control
@export var results_dock: Control

var data: StageData
var _field: Field
var _current_wave_idx: int = 0
var _stage_finished := false

static func from(stage_data: StageData) -> StageHandler {
	var handler := Registry.create_stage_handler()
	handler.data = stage_data
	return handler
}

func _unhandled_key_input(event: InputEvent) -> void {
	if event.is_action_pressed(&"help_me_im_fucking_dying") {
		_spawn_win_status_screen()
	}
	if event.is_action_pressed(&"harakiri") {
		_spawn_loss_status_screen()
	}
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
	intro_dock.hide()
	request_make_clear_invisible.emit()
	var field_scene := load("res://scenes/battle/field.tscn") as PackedScene
	_field = field_scene.instantiate() as Field
	_field.player_died.connect(_spawn_loss_status_screen)
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

	if _stage_finished:
		return

	if not is_instance_valid(_field):
		return

	if _field.stadium.player.hp <= 0:
		_spawn_loss_status_screen()
		return
	
	var remaining := _field.stadium.enemies.get_child_count()
	if remaining > 0:
		return
	
	_current_wave_idx += 1
	
	if _current_wave_idx >= data.waves.size() {
		_on_all_waves_cleared()
	} else {
		_spawn_wave(_current_wave_idx)
	}
}

func _on_all_waves_cleared() -> void {
	await get_tree().process_frame

	if _stage_finished:
		return

	if not is_instance_valid(_field):
		return

	if _field.stadium.player.hp <= 0:
		_spawn_loss_status_screen()
		return

	_spawn_win_status_screen()
}

func _finish_stage(won: bool) -> void {
	if _stage_finished:
		return

	_stage_finished = true

	var res := Results.from(won, data)
	res.finished.connect(exit.emit)
	results_dock.add_child(res)

	if is_instance_valid(_field):
		_field.queue_free()
}

func _spawn_win_status_screen() -> void {
	_finish_stage(true)
}

func _spawn_loss_status_screen() -> void {
	_field.stadium.get_player().hp = -INF
	_finish_stage(false)
}

func _exit_tree() -> void {
	request_restore_clear_visibility.emit()
}
