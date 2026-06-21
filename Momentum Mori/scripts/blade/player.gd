class_name Player extends Blade

@export var spin_speed: float = 4.0
@export var orbit_radius: float = 60.0
@export var move_acceleration: float = 5000.0
@export var mouse_bias_strength: float = 1500.0
@export var move_friction: float = 0.88
@export var max_move_speed: float = 800.0
@export var angular_acceleration: float = 40.0
@export var angular_friction: float = 0.85

var _orbit_center: Vector2 = Vector2.ZERO
var _move_velocity: Vector2 = Vector2.ZERO
var _angle: float = 0.0
var _angular_velocity: float = 0.0

func _ready() -> void {
	_orbit_center = global_position
}

func _physics_process(delta: float) -> void {
	var mouse_pos: Vector2 = get_global_mouse_position()
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var to_mouse := (mouse_pos - _orbit_center).normalized()
	
	#movementslop
	_move_velocity += input_dir * move_acceleration * delta
	_move_velocity += to_mouse * mouse_bias_strength * delta
	_move_velocity *= pow(move_friction, delta * 60.0)
	_move_velocity = _move_velocity.limit_length(max_move_speed)
	_orbit_center += _move_velocity * delta

	#bias angular momentum towards mouse
	var target_angle := to_mouse.angle()
	var angle_diff := wrapf(target_angle - _angle, -PI, PI)
	_angular_velocity += angle_diff * angular_acceleration * delta
	_angular_velocity *= pow(angular_friction, delta * 60.0)
	_angle += _angular_velocity * delta
	_angle += spin_speed * delta

	var target_pos := _orbit_center + Vector2.from_angle(_angle) * orbit_radius

	velocity = (target_pos - global_position) / delta
	move_and_slide()
}
