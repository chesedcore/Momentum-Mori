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

@export var mouse_smooth_factor_min: float = 0.1  #smooth when fast
@export var mouse_smooth_factor_max: float = 0.9  #try not to smooth when slow
@export var smooth_speed_threshold: float = 800.0  #velocity at which smoothing maxes out (for now)

##how fast the player is pulled to the dig point once the chain lands
@export var chain_pull_speed: float = 3000.0

var _orbit_center: Vector2 = Vector2.ZERO
var _orbit_velocity: Vector2 = Vector2.ZERO
var _smoothed_mouse: Vector2 = Vector2.ZERO

##Chain anchor state
enum ChainState { 
	NONE,   #a chain is not out.
	HELD,   #a chain is out and moving, but it has not struck its target.
	PULLING #the chain head pulls the blade towards it. 
}
var _chain_state: ChainState = ChainState.NONE
var _chain_anchor: Vector2 = Vector2.ZERO     # where the blade is frozen during HELD
var _chain_dig_point: Vector2 = Vector2.ZERO  # where the mace dug in, pull target

func _ready() -> void {
	_smoothed_mouse = get_global_mouse_position()
	_orbit_center = global_position
	incline.blade = self
}

##use when a chain is summoned. freezes the player at their current spot.
func begin_chain_hold() -> void {
	_chain_state = ChainState.HELD
	_chain_anchor = global_position
	_orbit_center = global_position
	_orbit_velocity = Vector2.ZERO
}

##use when the chain fully unrolls OR strikes a target.
##starts pulling the player toward dig_point.
func begin_chain_pull(dig_point: Vector2) -> void {
	_chain_state = ChainState.PULLING
	_chain_dig_point = dig_point
}

##use to fully release chain control (after arriving, or chain killed early).
func release_chain() -> void {
	_chain_state = ChainState.NONE
	#resync orbit center
	_orbit_center = global_position - Vector2.from_angle(angle) * orbit_radius
	_orbit_velocity = Vector2.ZERO
}

var pre_collision_velocity: Vector2

func _physics_process(delta: float) -> void {
	if recoil_time > 0.0 {
		
		recoil_time -= delta
		velocity = recoil_velocity
		pre_collision_velocity = velocity
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
				blade_collision.emit(self, collision,pre_collision_velocity)
			}
		}
		return
	}
	
	##this block cannot be put into a function scope trivially as
	##the return forces an exit away from scope...
	##you can do this with a temporary break var, 
	##but as of now that's how it is
	match _chain_state:
		ChainState.HELD:
			#pin the blade to the anchor and eat all input
			velocity = (_chain_anchor - global_position) / delta
			pre_collision_velocity = velocity
			move_and_slide()
			return
		
		ChainState.PULLING:
			#move toward the dig point at chain_pull_speed
			var to_dig := _chain_dig_point - global_position
			if to_dig.length() <= chain_pull_speed * delta {
				#arrived!!snap exactly and hand control back
				global_position = _chain_dig_point
				velocity = Vector2.ZERO
				release_chain()
			} else {
				velocity = to_dig.normalized() * chain_pull_speed
				pre_collision_velocity = velocity
				move_and_slide()
			}
			return

	var mouse_pos := get_global_mouse_position()
	var speed_t := clampf(velocity.length() / smooth_speed_threshold, 0.0, 1.0)
	var smooth_factor := lerpf(mouse_smooth_factor_max, mouse_smooth_factor_min, speed_t)
	_smoothed_mouse = _smoothed_mouse.lerp(mouse_pos, smooth_factor)

	var to_mouse := _smoothed_mouse - _orbit_center
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
	pre_collision_velocity = velocity
	move_and_slide()
	for i in get_slide_collision_count(){
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is Blade:
			blade_collision.emit(self,collision,pre_collision_velocity)
	}
}



#temp death logic
func die() -> void {
	print("you got out gayed")
	visible = false
}
