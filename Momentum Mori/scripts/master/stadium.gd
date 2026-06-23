class_name Stadium extends Node2D

@export var player: Player
@export var enemies: Node2D

@export var base_knockback: float = 300.0
@export var loser_knockback_multiplier: float = 4
@export var recoil_duration: float = 1

@export var loser_dmg_multiplier : float = 1.5

var collision_cooldown: float = 0.0
const COLLISION_COOLDOWN_DURATION: float = 0.1

func _on_blade_blade_collision(_player: Player, collision: KinematicCollision2D, player_velocity: Vector2) -> void {
	if collision_cooldown > 0.0 {
		return
	}
	collision_cooldown = COLLISION_COOLDOWN_DURATION
	var enemy: EnemyBlade = collision.get_collider()
	var normal := collision.get_normal()
	
	# who was attacking (facing toward the other)
	var player_attacking :bool = -player_velocity.normalized().dot(normal) > 0.5
	var enemy_attacking :bool = enemy.velocity.normalized().dot(normal) > 0.5
	
	if player_attacking and enemy_attacking {
	var player_speed := player_velocity.length()
	var enemy_speed := enemy.velocity.length()
	var total_speed := player_speed + enemy_speed
	
	
	var player_dmg_ratio := roundf(enemy_speed / total_speed)
	
	var enemy_dmg_ratio := roundf(player_speed / total_speed)
	
	player.apply_recoil(normal, base_knockback * player_dmg_ratio, recoil_duration)
	player.take_damage(enemy.base_dmg * player_dmg_ratio)
	enemy.apply_recoil(-normal, base_knockback * enemy_dmg_ratio, recoil_duration)
	enemy.take_damage(player.base_dmg * enemy_dmg_ratio)
	}
	elif player_attacking {
		player.apply_recoil(normal, base_knockback, recoil_duration)
		#so likeeee if the player is going slowww i dont think it should make the enemy explode ya know
		if player_velocity.length()<= enemy.velocity.length(){
			enemy.apply_recoil(-normal, base_knockback, recoil_duration)
			enemy.take_damage(player.base_dmg)
		}
		else{
			enemy.apply_recoil(-normal, base_knockback * loser_knockback_multiplier, recoil_duration)
			enemy.take_damage(player.base_dmg * loser_dmg_multiplier)
		}
	}
	else {
		#SAME HERE I DONT THINK A SLOW ENEMY SHOULD KNOCK THE BLADE MILLION MILES AWAY 
		if player_velocity.length() >= enemy.velocity.length(){
			player.apply_recoil(normal, base_knockback, recoil_duration)
			player.take_damage(enemy.base_dmg )
		}
		else{
			player.apply_recoil(normal, base_knockback * loser_knockback_multiplier, recoil_duration)
			player.take_damage(enemy.base_dmg * loser_dmg_multiplier)
		}
		enemy.apply_recoil(-normal, base_knockback, recoil_duration)
	}
	#uhhh so like the enemy should stop the attack after colliding i think
	enemy.change_to_chasing()
	
	apply_camera_shake()
}

func _process(delta: float) -> void{
	if collision_cooldown > 0.0 {
		collision_cooldown -= delta
	}
}

func iter_blades() -> Array[Blade] {
	var arr: Array[Blade]
	arr.assign(enemies.get_children())
	arr.append(player)
	return arr
}

func  _ready() -> void{
	_starting_camera_zoom = camera.zoom
}

@export var camera: Camera2D
var _starting_camera_zoom : Vector2
func apply_camera_shake() -> void {
	# Camera shake on impact
	camera.offset = Vector2(randf_range(-200.0, 200.0), randf_range(-200.0, 200.0))
	var z_val := randf_range(0.26, 0.3)
	camera.zoom = Vector2(z_val, z_val)

	create_tween().tween_property(camera, "offset", Vector2.ZERO, 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	create_tween().tween_property(camera, "zoom", _starting_camera_zoom, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
}




#@export var base_zoom := Vector2(.3, .3)
#@export var base_camera_location := Vector2.ZERO
#var collision_tween: Tween
#const collision_time :float= 1
#func collision_anim(pos : Vector2) -> void{
	#var impact_zoom = base_zoom * 1.3
	#if collision_tween and collision_tween.is_valid():
		#collision_tween.kill()
#
#
	#Engine.time_scale = 0.05
#
	#collision_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	#collision_tween.set_ignore_time_scale(true)
	#
	#collision_tween.tween_property(camera, "zoom", impact_zoom, collision_time/2)
	#collision_tween.parallel().tween_property(camera,"position",pos,collision_time/2)
	#
	#collision_tween.tween_property(camera, "zoom", base_zoom, collision_time/2)
	#collision_tween.parallel().tween_property(camera,"position",base_camera_location,collision_time/2)
	#collision_tween.parallel().tween_property(Engine, "time_scale", 1.0,collision_time/2)
	#}
	#
