class_name Field extends Control

@export var stadium: Stadium
@export var game_camera: GameCamera


func _ready() -> void {
	_inject_deps()
}

func _inject_deps() -> void {
	game_camera.stadium = stadium
}
