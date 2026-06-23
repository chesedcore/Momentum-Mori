class_name BladeAnimator extends Node

@export var shake_multiplier: float = 100.0
@export var amp: float = 0.15
@export var freq: float = 75.0
@export var blade_visual_node: Node2D
var blade_orignal_scale : Vector2 
var _time: float = 0.0

var shake_time: float = 0.0:
	set(value):
		shake_time = value
		shake_time = clampf(shake_time, 0.0, 10.0)


func _process(delta: float) -> void {
	if Input.is_action_just_pressed("ui_accept") {shake(2.0)}
	_time += delta
	shake_update(delta)
}


func shake(time: float, override: bool = false) -> void {
	if override {
		shake_time = time
	} else {
		shake_time += time
	}
}



func _ready() -> void{
	blade_orignal_scale = blade_visual_node.scale
}

func shake_update(delta: float) -> void {
	shake_time -= delta * 4.0
	var shake_val: float = (sin(freq * _time) * amp) * shake_multiplier * clampf(shake_time, 0.0, 2.0)

	# Offset position using sin value.
	blade_visual_node.position.x = shake_val * randf_range(0.25, 1.0)
	blade_visual_node.position.y = shake_val * randf_range(0.25, 1.0)

	# randomly scale to make impacts more crazy looking. using sin value.
	if shake_time <= 0.0 {
		blade_visual_node.scale.x = lerpf(blade_visual_node.scale.x, blade_orignal_scale.x, 2 * delta)
		blade_visual_node.scale.y = lerpf(blade_visual_node.scale.y, blade_orignal_scale.y, 2 * delta)
	} else {
		# Holy magic numbers batman.
		blade_visual_node.scale.x = lerpf(blade_visual_node.scale.x, blade_orignal_scale.x * clampf(shake_val * 0.5, 1.0, 2.0), 25 * delta)
		blade_visual_node.scale.y = lerpf(blade_visual_node.scale.y, blade_orignal_scale.y * clampf(shake_val * 0.25, 1.0, 2.0), 25 * delta)
	}
}
