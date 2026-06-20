@tool
class_name Circle extends Node2D

@export var thickness: float = 10
@export var radius: float = 30
@export var arc_angle_degrees: float = 360
@export var position_offset := Vector2.ZERO
@export var start_angle_offset: float = 0
@export var resolution_points: int = 80
@export_tool_button("update") var btn: Callable = update

func _draw() -> void {
	draw_arc(
		position_offset, radius, start_angle_offset,
		start_angle_offset + arc_angle_degrees,
		resolution_points, Color.WHITE, thickness,
		true
	)
}

func update() -> void {
	queue_redraw()
}
