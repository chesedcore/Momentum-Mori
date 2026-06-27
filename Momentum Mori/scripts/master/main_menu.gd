class_name MainMenu extends Control

@export var begin: Btn
@export var options: Btn
@export var credits: Btn
@export var menu_rect: MenuRect

@export var options_dock: Control
@export var stage_select_dock: Control
@export var game_dock: Control
@export var menu_music: AudioStreamPlayer

@export var clear: CanvasLayer
@export var postproc: CanvasLayer

func _ready() -> void {
	_wire_up_signals()
}

func _wire_up_signals() -> void {
	begin.clicked.connect(_summon_stage_select)
	options.clicked.connect(_summon_options)
}

func _summon_options() -> void {
	unroll_menu()
	var options_pane := Options.create()
	options_dock.add_child(options_pane)
	options_pane.cascaded_out.connect(
		_on_return_to_main_menu, CONNECT_ONE_SHOT
	)
}

func _summon_stage_select() -> void {
	unroll_menu()
	var select_pane := StageSelect.from(0)
	stage_select_dock.add_child(select_pane)
	select_pane.cascaded_out.connect(
		_on_return_to_main_menu, CONNECT_ONE_SHOT
	)
	select_pane.enter_this_stage.connect(
		_on_request_to_enter_this_stage, CONNECT_ONE_SHOT
	)
}

func _on_request_to_enter_this_stage(stage_data: StageData) -> void {
	var handler := StageHandler.from(stage_data)
	setup_canvas_fiddling(handler)
	game_dock.add_child(handler)
}

func setup_canvas_fiddling(handler: StageHandler) -> void {
	handler.request_make_clear_invisible.connect(make_canvases_invisible, CONNECT_ONE_SHOT)
	handler.request_restore_clear_visibility.connect(make_canvases_visible, CONNECT_ONE_SHOT)
}


func _on_return_to_main_menu() -> void {
	roll_menu()
}

func unroll_menu() -> void {
	menu_rect.unroll()
}

func roll_menu() -> void {
	menu_rect.roll()
}

func get_options() -> Option[Options] {
	if options_dock.get_child_count() != 1 {
		return Option.none()
	}

	return Option.some(options_dock.get_child(0) as Options)
}

func make_canvases_invisible() -> void {
	postproc.hide()
	clear.hide()
}

func make_canvases_visible() -> void {
	postproc.show()
	clear.show()
}
