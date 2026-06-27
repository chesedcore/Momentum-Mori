class_name SwordBoss extends  EnemyBlade

@onready var sword_holder: CascadeV3 = $"sword holder"

const SWORD = preload("res://scenes/battle/sword.tscn")









var attack_counter : int = 0
var num_of_attacks_to_fire : int = 0

const fire_interval:float= 1
var fire_cooldown : float = 0
var num_of_swords:int
var swords : Array[Node]
func  _ready() -> void{
	super._ready()
	num_of_attacks_to_fire = randi_range(1,3)
	num_of_swords =sword_holder.get_child_count()
	swords = sword_holder.get_children()
	sword_holder.cascade_in_started_for_node.connect(play_spawn_sfx)
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
		elif current_state == STATES.SPIRALING{
			update_spiral_state(delta)
		}

		calculate_movement(delta)

		sword_holder.rotation = (target.global_position - global_position).angle()
	}
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
	sword_holder.visible = true
	sword_holder.cascade_in()
	print("firing")


}



func update_firing_state(delta:float)-> void {
	if fire_cooldown<= fire_interval{
		fire_cooldown+= delta
	}
	dir = global_position.direction_to(target.global_position)

	if fire_cooldown >= fire_interval{
		#this part ends the firing state
		if num_of_swords ==0 {
			num_of_swords = 3
			for sword_img : Node2D in sword_holder.get_children(){
				sword_img.visible = true
			}
			attack_counter = 0
			num_of_attacks_to_fire = randi_range(1,3)
			fire_cooldown = 0
			sword_holder.visible = false
			change_to_chasing()
			return
		}
		num_of_swords -= 1
		var sword_sprite : Node2D = swords[num_of_swords]
		var sword: Sword = SWORD.instantiate()
		sword.target=target
		sword.global_transform = sword_sprite.global_transform
		#will spawn proper later
		EventBus.spawn_projectile.emit(sword)
		play_shoot_sfx()
		sword_sprite.visible = false
		sword.fire()
		fire_cooldown = 0

	}
}


func update_spiral_state(delta: float) -> void{
	remaining_spiral_duration -= delta
	if remaining_spiral_duration <= 0{
		attack_counter+=1
		if attack_counter == num_of_attacks_to_fire{
			change_to_firing()
		}
		else{
			change_to_chasing()
		}
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


func play_spawn_sfx(_node: Node) -> void {
	SFXPlayer.play_sfx(preload("res://assets/audio/enemies/sword.ogg"), position)
}


func play_shoot_sfx() -> void {
	SFXPlayer.play_sfx(preload("res://assets/audio/enemies/sword_shoot.ogg"), position)
}
