class_name EnemyBlade extends Blade

const attack_duration: float = 1
const attack_cooldown : float = 2

@export var incline: Incline

@export var chasing_speed: float = 700
@export var turn_speed := 2.5
@export var target: Node2D
@export var escape_duration := 0.5
@export var attack_speed : float = 1300
@export var attack_dist : float = 300

var minimum_distance_to_target: float = 150

@export var recoil_resistance:float = 1 # 1 means no resist , 0 means no recoil


enum STATES {CHASING,ATTACKING,FIRING}
var current_state :STATES = STATES.CHASING
var speed := chasing_speed
var remaining_attack_duration :float = attack_duration
var remaining_attack_cooldown := attack_cooldown
var players_last_loc : Vector2

var escape_dir := Vector2.ZERO
var escape_time := 0.0


var display_velocity: Vector2 = Vector2.ZERO

func _ready() -> void {
	incline.blade = self
	speed = chasing_speed
}

var dir :Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void {
	if recoil_time > 0.0 {
		recoil_time -= delta
		velocity = recoil_velocity * recoil_resistance
		move_and_slide()
		return
	}
	if target{
		
		if current_state == STATES.CHASING{
			update_chasing_state(delta)
		}
		elif current_state == STATES.ATTACKING{
			dir = players_last_loc
			update_attack_state(delta)
		}
		calculate_movement(delta)
	}
}

func calculate_movement(delta){
	var target_angle = dir.angle()
	#so get the angel from  the blade facing to the uhh player and fuck yeah if its away(close to ) pi we turn sloowww but the as the angle diff goes down the  turning goes NYOOMM
	# EASE IN BASSICALLY  
	var angle_diff = abs(angle_difference(rotation, target_angle))
	var ease_factor = remap(angle_diff, 0.0, PI, turn_speed * delta, 0.02)
	rotation = lerp_angle(rotation, target_angle, ease_factor)
	velocity = Vector2.RIGHT.rotated(rotation)* speed
	display_velocity = velocity
	move_and_slide()
}

func change_to_attack(attack_dir : Vector2)->void {
	players_last_loc  = attack_dir
	remaining_attack_cooldown = 0
	current_state = STATES.ATTACKING
	speed =attack_speed
}

func update_attack_state(delta : float)->void {
	remaining_attack_duration -= delta
	if remaining_attack_duration <= 0{
		remaining_attack_duration = attack_duration
		change_to_chasing()
	}
}

func change_to_chasing()->void {
	speed = chasing_speed
	current_state = STATES.CHASING
}

func update_chasing_state(delta:float) -> void {
	if remaining_attack_cooldown <  attack_cooldown{
		remaining_attack_cooldown += delta
		}
	var to_player = global_position.direction_to(target.global_position)
	var blade_forward = Vector2.RIGHT.rotated(rotation)
	var angle_to_player = rad_to_deg(acos(blade_forward.dot(to_player)))
	if global_position.distance_to(target.global_position) <= attack_dist and angle_to_player <= 20  and remaining_attack_cooldown >= attack_cooldown{
			change_to_attack(to_player)
	}
	else{
		var dist =global_position.distance_to(target.global_position)
		if dist <= minimum_distance_to_target{
			escape_dir = -to_player
			escape_time = escape_duration
		}
	}
	if escape_time >=0{
		escape_time -= delta
		dir = escape_dir
	}
	else{
		dir = to_player
	}
}
