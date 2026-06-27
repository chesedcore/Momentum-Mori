class_name StageHandler extends Control

@export var stage_dock: Control
@export var intro_dock: Control

var data: StageData

static func from(stage_data: StageData) -> StageHandler {
	var handler := new()
	handler.data = stage_data
	return handler
}

func _ready() -> void {
	print(get_children())
	await get_tree().process_frame
	var intro := _initiate_intro_sequence()
}

func _initiate_intro_sequence() -> IntroSequence {
	var intro := IntroSequence.from_lines(data.get_lines())
	intro_dock.add_child(intro)
	return intro
}
