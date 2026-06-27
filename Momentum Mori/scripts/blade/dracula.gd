class_name Dracula extends EnemyBlade

@onready var visual: Node2D = $Incline/Visual/Visual




var teleport_cooldown : float = 4
var remaining_teleport_cooldown : float = 0


@export var teleport_threshold: float = 0.75

@export var teleport_distance: float = 400

@export var teleport_world_radius: float = 4900


@export var teleport_min_distance: float = 300  
@export var teleport_max_distance: float = 800







const SPINNING_PROJECTILES = preload("res://scenes/battle/spinning_projectiles.tscn")
const SPINNY_PROJECTILEX_6 = preload("res://scripts/battle/spinny_projectilex_6.tscn")

var attack_counter : int = 0
var num_of_attacks_to_fire : int = 0

const fire_interval:float= 1.5
var fire_cooldown : float = 0

func  _ready() -> void{
	super._ready()
	num_of_attacks_to_fire = randi_range(1,3)

}

func _physics_process(delta: float) -> void{
	if remaining_teleport_cooldown >= teleport_cooldown{
		# check the targets velocity to see if its heading towards this blade and teleport this blade behhind  the target 
		var target_velocity = target.velocity
		if target_velocity.length() > 0{
			var target_move_dir = target_velocity.normalized()
			var to_self = target.global_position.direction_to(global_position)
			var dot = target_move_dir.dot(to_self)
			var dist = global_position.distance_to(target.global_position)
			if dot >= teleport_threshold and dist >= teleport_min_distance and dist <= teleport_max_distance{
				teleport_behind_target()
				remaining_teleport_cooldown = 0
			}
		}
	}
	remaining_teleport_cooldown += delta
	
	
	
	
	
	
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
	fire_cooldown = 0
	attack_counter = 0 
	num_of_attacks_to_fire = randi_range(2,3)
	flash()
	
}



func update_firing_state(delta:float)-> void {
	if fire_cooldown<= fire_interval{
		fire_cooldown+= delta
		return
		
	}
	var chosen_attack : int = randi_range(0,1)
	if chosen_attack == 0 {
		dir = global_position.direction_to(target.global_position)
		var spinny : Projectile = SPINNING_PROJECTILES.instantiate()
		spinny.target = target
		spinny.global_position = global_position
		EventBus.spawn_projectile.emit(spinny)
		spinny.fire()
		
		attack_counter = 0
		
	}
	else{
		dir = global_position.direction_to(target.global_position)
		var spinny : Projectile = SPINNY_PROJECTILEX_6.instantiate()
		spinny.target = target
		
		add_child(spinny)
		spinny.fire()
		
		
	}
	change_to_chasing()
	
}
func flash() -> void{
	var tween = create_tween()
	tween.tween_property(visual, "modulate", Color.RED, 0.5)
	tween.tween_property(visual, "modulate", Color.WHITE, 0.5)
	tween.tween_property(visual, "modulate", Color.RED, 0.5)
	tween.tween_property(visual, "modulate", Color.WHITE, 0.5)
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






@onready var circle: Circle = $Incline/Visual/Visual/Control/Circle

func teleport_behind_target() -> void{
	var flash_tween = create_tween()
	flash_tween.tween_property(circle,"modulate",Color.WHITE,0.05)
	await  flash_tween.finished
	var target_move_dir :Vector2= target.velocity.normalized()
	var teleport_position := target.global_position - target_move_dir * teleport_distance
	
	if teleport_position.distance_to(Vector2.ZERO) > teleport_world_radius{
		var unflash_tween = create_tween()
		unflash_tween.tween_property(circle, "modulate", Color(0.137, 0.102, 0.239), 0.05)
		return
	}
	global_position = teleport_position
	var to_target = global_position.direction_to(target.global_position)
	change_to_attack(to_target)
	var unflash_tween = create_tween()
	unflash_tween.tween_property(circle,"modulate",Color(0.137, 0.102, 0.239),0.05)
}
