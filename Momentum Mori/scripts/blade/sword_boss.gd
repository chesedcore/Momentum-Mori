class_name SwordBoss extends  EnemyBlade


@onready var sword_holder: Node2D = $"sword holder"
const SWORD = preload("res://scenes/battle/sword.tscn")







var recoil_resistance :float= 0.5

var attack_counter : int = 0
var num_of_attacks_to_fire : int = 0

const fire_interval:float= 1
var fire_cooldown : float = 0
var num_of_swords:int 
var swords : Array[Node]
func  _ready() -> void:
	num_of_attacks_to_fire = randi_range(1,3)
	num_of_swords =sword_holder.get_child_count()
	swords = sword_holder.get_children()


func _physics_process(delta: float) -> void{
	if recoil_time > 0.0 {
		recoil_time -= delta
		velocity = recoil_velocity * recoil_resistance
		move_and_slide()
		return
	}
	if target{
		var dir :Vector2
		if current_state == STATES.FIRING{
			if fire_cooldown<= fire_interval:
				fire_cooldown+= delta
			dir = global_position.direction_to(target.global_position)
			var target_angle = dir.angle()
			rotation = lerp_angle(rotation,target_angle,turn_speed*delta)
			
		
			if fire_cooldown >= fire_interval{
				if num_of_swords ==0 {
					num_of_swords = 3
					for sword_img : Node2D in sword_holder.get_children(){
						sword_img.visible = true
					}
					attack_counter = 0
					num_of_attacks_to_fire = randi_range(1,3)
					change_to_chasing()
					return
				}
				num_of_swords -= 1
				var sword_sprite : Node2D = swords[num_of_swords]
				var sword: Sword = SWORD.instantiate()
				sword.target=target
				sword.global_transform = sword_sprite.global_transform
				#will spawn proper later
				
				get_parent().add_child(sword)
				sword_sprite.visible = false
				sword.fire()
				
				fire_cooldown = 0
				
				}	
				return
		}
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
	if remaining_attack_duration <= 0{
		remaining_attack_duration = attack_duration
		attack_counter+=1
		if attack_counter == num_of_attacks_to_fire{
			change_to_firing()
		}
		else{
		change_to_chasing()}
	}
	}

func  change_to_firing()->void{
	current_state = STATES.FIRING
	print("firing")
	
	
}


func change_to_chasing()->void{
	speed = chasing_speed
	current_state = STATES.CHASING
}
func update_chasing_state(delta:float)->void{
	if remaining_attack_cooldown <  attack_cooldown{
		remaining_attack_cooldown += delta
		}
}
