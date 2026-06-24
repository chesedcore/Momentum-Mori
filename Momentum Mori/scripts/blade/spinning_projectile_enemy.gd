class_name SpinningProjectileEnemy extends  EnemyBlade




const SPINNING_PROJECTILES = preload("res://scenes/battle/spinning_projectiles.tscn")






var attack_counter : int = 0
var num_of_attacks_to_fire : int = 0

const fire_interval:float= 1
var fire_cooldown : float = 0

func  _ready() -> void{
	super._ready()
	num_of_attacks_to_fire = randi_range(1,3)

}

func _physics_process(delta: float) -> void{
	if recoil_time > 0.0 {
		recoil_time -= delta
		velocity = recoil_velocity *recoil_resistance
		move_and_slide()
		return
	}
	if target{
		if current_state == STATES.FIRING{
			update_firing_state(delta)
			
		}
		elif current_state == STATES.CHASING{
			update_chasing_state(delta)
		}
		elif current_state == STATES.ATTACKING{
			dir = players_last_loc
			update_attack_state(delta)
		}
		
		calculate_movement(delta)
		
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
			change_to_chasing()
		}
	}
}

func  change_to_firing()->void{
	current_state = STATES.FIRING
	speed = 0
	print("firing")
	
	
}



func update_firing_state(delta:float)-> void {
	if fire_cooldown<= fire_interval{
		fire_cooldown+= delta
		return
		
	}
	dir = global_position.direction_to(target.global_position)
	var spinny : Projectile = SPINNING_PROJECTILES.instantiate()
	spinny.target = target
	spinny.global_position = global_position
	EventBus.spawn_projectile.emit(spinny)
	spinny.fire()
	num_of_attacks_to_fire = randi_range(2,3)
	attack_counter = 0
	change_to_chasing()
	
}
