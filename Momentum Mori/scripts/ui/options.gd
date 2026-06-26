class_name Options extends Control

signal cascaded_out

@export var options_random_shit_cascade: CascadeV3
@export var actual_options_cascade: CascadeV3
@export var back: Btn

static func create() -> Options {
	return Registry.create_options()
}

func _wire_up_signals() -> void {
	back.clicked.connect(cascade_out)
}

func _reset_signals() -> void {
	Tools.try_disconnect(
		options_random_shit_cascade.cascade_in_chain_finished,
		actual_options_cascade.cascade_in
	)
}

func cascade_in() -> void {
	_reset_signals()
	options_random_shit_cascade.cascade_in()
	options_random_shit_cascade.cascade_in_chain_finished.connect(
		actual_options_cascade.cascade_in, CONNECT_ONE_SHOT
	)
}

func cascade_out() -> void {
	_reset_signals()
	options_random_shit_cascade.cascade_out()
	options_random_shit_cascade.cascade_out_chain_finished.connect(
		_on_random_shit_cascaded_out, CONNECT_ONE_SHOT
	)

}

func _on_random_shit_cascaded_out() -> void {
	actual_options_cascade.cascade_out()
	actual_options_cascade.cascade_out_chain_finished.connect(
		_on_everything_cascaded_out, CONNECT_ONE_SHOT
	)
}

func _on_everything_cascaded_out() -> void {
	cascaded_out.emit()
	queue_free.call_deferred()
}

func _ready() -> void {
	_wire_up_signals()
	cascade_in()
}
