class_name EnemyBlade extends Blade




@export var chasing_speed: float = 700
@export var turn_speed := 5.0
@export var target: Node2D

var minimum_distance_to_target: float = 150



enum STATES {CHASING,ATTACKING}
var current_state :STATES = STATES.CHASING

var speed := chasing_speed

@export var attack_dist : float = 300
const attack_duration: float = 1
var remaining_attack_duration :float = attack_duration
@export var attack_speed : float = 1300
const attack_cooldown : float = 2
var remaining_attack_cooldown := attack_cooldown
var players_last_loc : Vector2 

var escape_dir := Vector2.ZERO
var escape_time := 0.0
@export var escape_duration := 0.5



func _physics_process(delta: float) -> void{
	if recoil_time > 0.0 {
		recoil_time -= delta
		velocity = recoil_velocity
		move_and_slide()
		return
	}
	if target{
		var dir :Vector2
		
		if current_state == STATES.CHASING{
			update_chasing_state(delta)
			var to_player = global_position.direction_to(target.global_position)
			var blade_forward = Vector2.RIGHT.rotated(rotation)
			var angle_to_player = rad_to_deg(
				acos(blade_forward.dot(to_player))
			)
			if global_position.distance_to(target.global_position) <= attack_dist and angle_to_player <= 20  and remaining_attack_cooldown >= attack_cooldown{
			change_to_attack(to_player)
			}
			else{
				var dist =global_position.distance_to(target.global_position) 
				if dist <= minimum_distance_to_target{
					escape_dir = -to_player
					escape_time = escape_duration
				}
				if escape_time >=0{
					escape_time -= delta
					dir = escape_dir
				}
				
				else{
					dir = to_player
					}
					
				}
			}
		elif current_state == STATES.ATTACKING{
			dir = players_last_loc
			update_attack_state(delta)
		}
		var target_angle = dir.angle()
		rotation = lerp_angle(rotation,target_angle,turn_speed*delta)
		
		velocity = Vector2.RIGHT.rotated(rotation)* speed
		move_and_slide()
		
		
		}
}

func change_to_attack(attack_dir : Vector2)->void{
	players_last_loc  = attack_dir
	remaining_attack_cooldown = 0
	current_state = STATES.ATTACKING
	speed =attack_speed
	}


func update_attack_state(delta : float)->void{
	remaining_attack_duration -= delta
	if remaining_attack_duration <= 0:
		remaining_attack_duration = attack_duration
		change_to_chasing()
}
func change_to_chasing()->void{
	speed = chasing_speed
	current_state = STATES.CHASING
}
func update_chasing_state(delta:float)->void:
	if remaining_attack_cooldown <  attack_cooldown:
		remaining_attack_cooldown += delta
