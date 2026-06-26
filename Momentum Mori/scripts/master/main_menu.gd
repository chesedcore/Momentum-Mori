class_name MainMenu extends Control

@export var begin: Btn
@export var options: Btn
@export var credits: Btn
@export var menu_rect: MenuRect

@export var options_dock: Control

func _ready() -> void {
	_wire_up_signals()
}

func _wire_up_signals() -> void {
	begin.clicked.connect(unroll_menu)
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
