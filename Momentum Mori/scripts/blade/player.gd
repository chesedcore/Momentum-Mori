class_name Player extends Blade

#signal to the stadium
signal blade_collision

##how fast the blade spins around the orbit center (radians/sec^2)
@export var spin_speed: float = 4.0
##radius of the orbit circle around the orbit center
@export var orbit_radius: float = 60.0
@export var max_follow_speed: float = 5000.0
@export var frictional_damp_delta_inverse: float = 0.92

var _orbit_center: Vector2 = Vector2.ZERO
var _orbit_velocity: Vector2 = Vector2.ZERO
var _angle: float = 0.0

func _ready() -> void {
	_orbit_center = global_position
}

func _physics_process(delta: float) -> void {
	
	if recoil_time > 0.0 {
		recoil_time -= delta
		velocity = recoil_velocity
		
	}
	else{
	
	var mouse_pos: Vector2 = get_global_mouse_position()
	
	var to_mouse := mouse_pos - _orbit_center
	var dist := to_mouse.length()
	
	if dist > 2.0:
		var force := to_mouse.normalized() * pow(dist, 1.5) * 2.0
		_orbit_velocity += force * delta
	
	_orbit_velocity *= pow(frictional_damp_delta_inverse, delta * 60.0)
	_orbit_velocity = _orbit_velocity.limit_length(max_follow_speed)
	_orbit_center += _orbit_velocity * delta
	
	_angle = (global_position - _orbit_center).angle()
	_angle += spin_speed * delta
	
	var target_pos := _orbit_center + Vector2.from_angle(_angle) * orbit_radius
	
	velocity = (target_pos - global_position) / delta
	}
	move_and_slide()
	for i in get_slide_collision_count(){
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is EnemyBlade:
			blade_collision.emit(self,collision)
}
}
