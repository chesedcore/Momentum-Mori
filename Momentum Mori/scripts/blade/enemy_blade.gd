class_name EnemyBlade extends Blade

const attack_duration: float = 1
@export_group("Attack","attack")
@export var attack_cooldown : float = 2
@export var attack_speed : float = 1300
@export var attack_dist : float = 300
@export var attack_predict: bool = true
@export var attack_predict_strength: float = 1.0

@export_group("Spiral", "spiral")
@export var spiral_duration: float = 2.8
@export var spiral_speed: float = 1300
@export var spiral_expand_rate: float = 5000
@export var spiral_angular_speed: float = 12

var spiral_angle: float = 0.0
var spiral_radius: float = 0.0
var spiral_origin: Vector2 = Vector2.ZERO
var remaining_spiral_duration: float = 0.0


var is_parrying :bool = false

@export var incline: Incline

@export var chasing_speed: float = 700
@export var turn_speed := 2.5
@export var target: Node2D


@export var escape_duration := 0.5
var escape_dir := Vector2.ZERO
var escape_time := 0.0
@export var minimum_distance_to_target: float = 300


@export var recoil_resistance:float = 1 # 1 means no resist , 0 means no recoil


enum STATES {CHASING,ATTACKING,FIRING,SPIRALING}
var current_state :STATES = STATES.CHASING
var speed := chasing_speed
var remaining_attack_duration :float = attack_duration
var remaining_attack_cooldown := attack_cooldown
var players_last_loc : Vector2



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
		elif  current_state == STATES.SPIRALING{
			update_spiral_state(delta)
		}
		
		calculate_movement(delta)
	}
}

func calculate_movement(delta){
	var target_velocity = dir * speed
	velocity = velocity.lerp(target_velocity, turn_speed * delta)
	display_velocity = velocity
	move_and_slide()
}

func change_to_attack(attack_dir : Vector2)->void {
	#chance to do a sprial instead
	var spiral_chance := randi_range(0,6)
	#print(spiral_chance)
	if spiral_chance == 3 {
		change_to_spiral()
		return
	}
	if attack_predict{
		var target_vel : Vector2= target.velocity
		players_last_loc = calculate_intercept(target.global_position, target_vel)
	} 
	else{
		players_last_loc  = attack_dir
	}
	remaining_attack_cooldown = 0
	current_state = STATES.ATTACKING
	speed = attack_speed
}

func update_attack_state(delta : float)->void {
	remaining_attack_duration -= delta
	if remaining_attack_duration <= 0{
		remaining_attack_duration = attack_duration
		change_to_chasing()
	}
}

func calculate_intercept(target_pos: Vector2, target_vel: Vector2) -> Vector2{
	var dist := global_position.distance_to(target_pos)
	
	var time_to_target := dist / attack_speed
	
	var predicted_pos := target_pos + target_vel * time_to_target * attack_predict_strength
	
	return global_position.direction_to(predicted_pos)
}


func change_to_chasing()->void {
	speed = chasing_speed
	current_state = STATES.CHASING
}

func update_chasing_state(delta:float) -> void {
	if remaining_attack_cooldown <  attack_cooldown{
		remaining_attack_cooldown += delta
		}
	var to_player := global_position.direction_to(target.global_position)
	if global_position.distance_to(target.global_position) <= attack_dist  and remaining_attack_cooldown >= attack_cooldown{
			change_to_attack(to_player)
	}
	else{
		var dist :=global_position.distance_to(target.global_position)
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



func change_to_spiral() -> void{
	current_state = STATES.SPIRALING
	spiral_origin = global_position 
	spiral_angle = 0.0
	spiral_radius = 0.0
	remaining_spiral_duration = spiral_duration
	speed = spiral_speed
}


func update_spiral_state(delta: float) -> void{
	remaining_spiral_duration -= delta
	if remaining_spiral_duration <= 0{
		change_to_chasing()
		return
	}
	spiral_angle += spiral_angular_speed * delta
	spiral_radius += spiral_expand_rate * delta
	var spiral_offset := Vector2(cos(spiral_angle), sin(spiral_angle)) * spiral_radius
	var next_pos := spiral_origin + spiral_offset
	var move_vec := next_pos - global_position
	if move_vec.length() > 0{
		dir = move_vec.normalized()
		speed = move_vec.length()
	}
}
