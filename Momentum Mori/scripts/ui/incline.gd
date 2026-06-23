@tool
class_name Incline extends SubViewportContainer

@export var target_size := Vector2(100, 100)
@export var target_center_dock: Node2D
@export_tool_button("update size") var upd := _update_size

var blade: Blade

func _update_size() -> void {
	if not target_center_dock: return
	self.custom_minimum_size = target_size
	self.size = target_size
	self.position = -1 * target_size/2
	target_center_dock.position = target_size / 2
}

func _update_incline() -> void {
	var mat := material as ShaderMaterial
	if not mat: return
	
	var velocity_mag_normalised := clampf(blade.velocity.length()/1200, 0.0, 1.0)
	var velocity_strength := 2
	var vel_tilt := velocity_mag_normalised * velocity_strength
	
	var tilt_strength := 30.0 * vel_tilt
	var move_dir := blade.velocity.normalized()
	
	mat.set_shader_parameter(&"x_rot", -move_dir.y * tilt_strength)
	mat.set_shader_parameter(&"y_rot", move_dir.x * tilt_strength)
}

func _process(_delta: float) -> void {
	if Engine.is_editor_hint(): return
	_update_incline()
}
