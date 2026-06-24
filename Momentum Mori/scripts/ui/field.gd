class_name Field extends Control

signal action_requested

@export var stadium: Stadium
@export var game_camera: GameCamera

func _unhandled_input(event: InputEvent) -> void {
	if event is InputEventMouseButton {
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT {
			action_requested.emit()
		}
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
	print_rich(ChainDock.raycast_for_collidables(
		stadium, stadium.player.global_position, 
		get_global_mouse_position(), 2
	))
}

func _inject_deps() -> void {
	game_camera.stadium = stadium
}
