class_name Field extends Control

signal action_requested
signal chain_spawn_confirmed

@export var stadium: Stadium
@export var game_camera: GameCamera

func _unhandled_input(event: InputEvent) -> void {
	if event.is_action_pressed("action") {
		action_requested.emit()
	}
}

func _ready() -> void {
	_inject_deps()
	_wire_up_signals()
}

func _wire_up_signals() -> void {
	action_requested.connect(_on_action_requested)
}

func _on_action_requested() -> void {
	var chain := _summon_chain()
	_setup_chain_destructor(chain)
}

func _summon_chain() -> ChainWhip {
	for w: ChainWhip in stadium.get_chain_dock().get_children() {
		w.kill()
	}
	var chain := ChainWhip.summon_chain_from_start_to_end(
		stadium.get_chain_dock(),
		stadium.get_player().get_global_position(),
		get_global_mouse_position()
	)
	get_tree().create_timer(2.0).timeout.connect(chain.kill)
	return chain
}

func _setup_chain_destructor(chain: ChainWhip) -> void {
	var t := create_tween()
	t.tween_await(chain_spawn_confirmed).set_timeout(2)
	t.tween_callback(chain.kill)
}

func _inject_deps() -> void {
	game_camera.stadium = stadium
}
