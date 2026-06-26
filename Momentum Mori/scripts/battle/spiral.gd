@tool
class_name Spiral
extends Node2D

@export var turns: float = 5.0:
	set(value):
		turns = value
		queue_redraw()

@export var spacing: float = 10.0:
	set(value):
		spacing = value
		queue_redraw()

@export var thickness: float = 5.0:
	set(value):
		thickness = value
		queue_redraw()

@export var resolution: int = 200:
	set(value):
		resolution = max(value, 10)
		queue_redraw()

@export var position_offset := Vector2.ZERO:
	set(value):
		position_offset = value
		queue_redraw()

@export var start_angle_deg: float = 0:
	set(value):
		start_angle_deg = value
		queue_redraw()

@export_tool_button("Update")
var redraw_btn = queue_redraw


func _draw() -> void{
	var points: PackedVector2Array

	var max_angle = turns * TAU
	var start_angle = deg_to_rad(start_angle_deg)

	for i in range(resolution + 1):
		var t = float(i) / resolution
		var angle = start_angle + t * max_angle
		
		var radius = spacing * angle / TAU
		var point = position_offset + Vector2.RIGHT.rotated(angle) * radius
		points.append(point)
	if points.size() > 1:
		draw_polyline(points, Color.WHITE, thickness)
}
