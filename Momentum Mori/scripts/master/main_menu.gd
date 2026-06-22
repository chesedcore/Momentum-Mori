class_name MainMenu extends Control

@export var begin: Btn
@export var options: Btn
@export var credits: Btn
@export var menu_rect: MenuRect

enum State {
	OPTIONS,
	CREDITS,
}

var state_stack: Array[State]

func _ready() -> void {
	_wire_up_signals()
}

func _wire_up_signals() -> void {
	begin.clicked.connect(unroll_menu)
}

func unroll_menu() -> void {
	menu_rect.unroll()
}
