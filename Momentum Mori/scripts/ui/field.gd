class_name Field extends Control

signal action_requested
signal chain_spawn_confirmed

signal request_start_adrenaline
signal request_stop_adrenaline
signal request_force_stop_adrenaline

signal started_adrenaline
signal stopped_adrenaline

@export var stadium: Stadium
@export var game_camera: GameCamera
@export var timer: Timer
@export var ui: UI

@export var time_until_chain_disappears := 2.0

@export var max_adrenaline_time_in_seconds := 3.0
@export var adrenaline_recharge_rate := 0.33
@export var time_slow_down_factor := 0.2
@export var minimum_threshold_to_activate_adrenaline := 0.25

var _is_under_adrenaline := false

func _unhandled_input(event: InputEvent) -> void {
	if event.is_action_pressed(&"action") {
		action_requested.emit()
	}
	
	if event.is_action_pressed(&"adrenaline") {
		request_start_adrenaline.emit()
	}
	
	if event.is_action_released(&"adrenaline") {
		request_stop_adrenaline.emit()
	}
}

func _ready() -> void {
	timer.wait_time = max_adrenaline_time_in_seconds
	_inject_deps()
	_wire_up_signals()
}

func _wire_up_signals() -> void {
	action_requested.connect(_on_action_requested)
	request_start_adrenaline.connect(_on_requested_adrenaline_start)
	request_stop_adrenaline.connect(_on_requested_adrenaline_stop)
	request_force_stop_adrenaline.connect(force_stop_adrenaline)
	timer.timeout.connect(_on_timer_expired)
}

func _on_requested_adrenaline_start() -> void {
	if _is_under_adrenaline: return
	if timer.wait_time < minimum_threshold_to_activate_adrenaline: return
	_is_under_adrenaline = true
	Engine.time_scale *= time_slow_down_factor
	timer.start()
	started_adrenaline.emit()
}

func _on_requested_adrenaline_stop() -> void {
	if not _is_under_adrenaline: return
	var remaining := timer.time_left
	timer.stop()
	timer.wait_time = remaining
	force_stop_adrenaline()
}

func _on_timer_expired() -> void {
	timer.stop()
	timer.wait_time = 0.001
	force_stop_adrenaline()
}

func force_stop_adrenaline() -> void {
	_is_under_adrenaline = false
	Engine.time_scale = 1.0
	stopped_adrenaline.emit()
}

func _physics_process(delta: float) -> void {
	tick_up_adrenaline(delta)
}

func tick_up_adrenaline(delta: float) -> void {
	if _is_under_adrenaline: return
	var eff_delta := delta
	
	timer.wait_time = minf(
		max_adrenaline_time_in_seconds, 
		timer.wait_time + eff_delta
	)
	
	#print(timer.wait_time)
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
	t.tween_await(chain_spawn_confirmed).set_timeout(1)
	t.tween_callback(chain.kill)
}

func _inject_deps() -> void {
	game_camera.stadium = stadium
	ui.setup_self_using_field(self)
}
