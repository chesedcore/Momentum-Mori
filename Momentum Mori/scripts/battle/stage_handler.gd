class_name StageHandler extends Control

@export var stage_dock: Control
@export var intro_dock: Control

var data: StageData

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
	
}
