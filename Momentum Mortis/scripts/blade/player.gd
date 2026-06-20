class_name Player extends Blade

##how fast the blade spins around the orbit center (radians/sec^2)
@export var spin_speed: float = 4.0

##radius of the orbit circle around the orbit center
@export var orbit_radius: float = 60.0

@export var follow_weight: float = 3.0


var _orbit_center: Vector2 = Vector2.ZERO
var _angle: float = 0.0

func _ready() -> void {
	_orbit_center = global_position
}

func _physics_process(delta: float) -> void {
	var mouse_pos: Vector2 = get_global_mouse_position()
	
	_orbit_center = _orbit_center.lerp(mouse_pos, follow_weight * delta)
	
	_angle = (global_position - _orbit_center).angle()
	_angle += spin_speed * delta
	
	var target_pos := _orbit_center + Vector2.from_angle(_angle) * orbit_radius
	
	velocity = (target_pos - global_position) / delta
	move_and_slide()
}
