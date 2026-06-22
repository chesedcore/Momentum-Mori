class_name Player extends Blade

#signal to the stadium
signal blade_collision

##how fast the blade spins around the orbit center (radians/sec^2)
@export var spin_speed: float = 4.0
##radius of the orbit circle around the orbit center
@export var orbit_radius: float = 60.0
@export var max_follow_speed: float = 5000.0
@export var frictional_damp_delta_inverse: float = 0.92
@export var incline: Incline

var _orbit_center: Vector2 = Vector2.ZERO
var _orbit_velocity: Vector2 = Vector2.ZERO

func _ready() -> void {
	_orbit_center = global_position
	incline.blade = self
}

func _physics_process(delta: float) -> void {
	if recoil_time > 0.0 {
		recoil_time -= delta
		velocity = recoil_velocity
		move_and_slide()

		_orbit_velocity *= pow(frictional_damp_delta_inverse, delta * 60.0)
		_orbit_center += _orbit_velocity * delta

		if recoil_time <= 0.0 {
			# resync so orbit resumes from current position, no snap
			_orbit_center = global_position - Vector2.from_angle(angle) * orbit_radius
		}

		for i in get_slide_collision_count() {
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider is EnemyBlade {
				blade_collision.emit(self, collision)
			}
		}
		return
	}

	var mouse_pos: Vector2 = get_global_mouse_position()
	var to_mouse := mouse_pos - _orbit_center
	var dist := to_mouse.length()

	if dist > 2.0:
		var force := to_mouse.normalized() * pow(dist, 1.5) * 2.0
		_orbit_velocity += force * delta

	_orbit_velocity *= pow(frictional_damp_delta_inverse, delta * 60.0)
	_orbit_velocity = _orbit_velocity.limit_length(max_follow_speed)
	_orbit_center += _orbit_velocity * delta

	angle = (global_position - _orbit_center).angle()
	angle += spin_speed * delta

	var target_pos := _orbit_center + Vector2.from_angle(angle) * orbit_radius

	velocity = (target_pos - global_position) / delta

	var pre_collision_velocity := velocity
	move_and_slide()
	for i in get_slide_collision_count(){
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is Blade:
			blade_collision.emit(self,collision,pre_collision_velocity)
}}

func take_damage(dmg : float ) -> void{
	super.take_damage(dmg)
}

#temp death logic
func die() -> void {
	print("you got out gayed")
	visible = false
}
