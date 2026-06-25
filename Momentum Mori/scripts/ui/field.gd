class_name Field extends Control

signal action_requested
signal chain_spawn_confirmed

@export var stadium: Stadium
@export var game_camera: GameCamera
@export var time_until_chain_disappears := 2.0

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

	var final_point := get_global_mouse_position()

	stadium.get_player().begin_chain_hold()
	var chain := ChainWhip.summon_chain_from_start_to_end(
	stadium.get_chain_dock(),
		stadium.get_player().get_global_position(),
		final_point
	)

	_try_setup_chain_raycast(chain, final_point)

	get_tree().create_timer(time_until_chain_disappears)          \
		.timeout.connect(chain.kill)

	return chain
}

func _try_setup_chain_raycast(chain: ChainWhip, final: Vector2) -> void {
	if not is_instance_valid(chain): return

	var time_to_complete_chain := chain.get_timing_until_chain_unroll()

	if time_to_complete_chain > time_until_chain_disappears {
		push_error("The chain will take too long to complete!", time_to_complete_chain)
		return
	}

	_raycast_collidables_for_chain(chain, final)
}

func _raycast_collidables_for_chain(
	chain: ChainWhip, final: Vector2
) -> void {
	if not is_instance_valid(chain): return
	if chain.is_being_killed: return

	chain.fully_unrolled.connect(_on_chain_fully_unrolled.bind(chain, final))
	chain.stuff_hit.connect(_on_stuff_hit.bind(chain, final))
}

func _on_chain_fully_unrolled(chain: ChainWhip, final: Vector2) -> void {
	stadium.get_player().begin_chain_pull(chain.get_endpoint().unwrap_or(final))
}

func _on_stuff_hit(stuff_arr: Array, chain: ChainWhip, final: Vector2) -> void {
	var stuff := Tools.flatten_array(stuff_arr) as PhysicsBody2D
	print(stuff)
	if chain.fully_unrolled.is_connected(_on_chain_fully_unrolled) {
		chain.fully_unrolled.disconnect(_on_chain_fully_unrolled)
	}
	stadium.get_player().begin_chain_pull(chain.get_endpoint().unwrap_or(final))
}

func _setup_chain_destructor(chain: ChainWhip) -> void {
	var t := create_tween()
	t.tween_await(chain_spawn_confirmed).set_timeout(2)
	t.tween_callback(chain.kill)
}

func _inject_deps() -> void {
	game_camera.stadium = stadium
}
