class_name Stadium extends Node2D

@export var player: Player
@export var enemies: Node2D

@export var base_knockback: float = 300.0
@export var loser_knockback_multiplier: float = 2.5
@export var recoil_duration: float = 0.5

@export var loser_dmg_multiplier : float = 1.5

var collision_cooldown: float = 0.0
const COLLISION_COOLDOWN_DURATION: float = 0.1

func _on_blade_blade_collision(_player: Player, collision: KinematicCollision2D, player_velocity: Vector2) -> void {
	if collision_cooldown > 0.0 {
		return
	}
	collision_cooldown = COLLISION_COOLDOWN_DURATION

	var enemy: Blade = collision.get_collider()
	var normal := collision.get_normal()
	

	# who was attacking (facing toward the other)
	var player_attacking = -player_velocity.normalized().dot(normal) > 0.5
	var enemy_attacking = enemy.velocity.normalized().dot(normal) > 0.5
	
	if player_attacking and enemy_attacking {
		print("Head on — lower velocity  takes damage")
		player.apply_recoil(normal, base_knockback, recoil_duration)
		enemy.apply_recoil(-normal, base_knockback, recoil_duration)
		if player_velocity.length() > enemy.velocity.length(){
		enemy.take_damage(player.base_dmg)
		
		}
		else{
			player.take_damage(enemy.base_dmg)
		}
		
		
	}
	elif player_attacking {
		print("Player hit enemy — enemy takes damage")
		player.apply_recoil(normal, base_knockback, recoil_duration)
		enemy.apply_recoil(-normal, base_knockback * loser_knockback_multiplier, recoil_duration)
		enemy.take_damage(player.base_dmg * loser_dmg_multiplier)
	}
	else {
		print("Enemy hit player — player takes damage")
		player.apply_recoil(normal, base_knockback * loser_knockback_multiplier, recoil_duration)
		player.take_damage(enemy.base_dmg * loser_dmg_multiplier)
		enemy.apply_recoil(-normal, base_knockback, recoil_duration)
	}
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

#func apply_camera_shake() -> void {
	## Camera shake on impact
	#camera.offset = Vector2(randf_range(-200.0, 200.0), randf_range(-200.0, 200.0))
	#var z_val := randf_range(0.26, 0.3)
	#camera.zoom = Vector2(z_val, z_val)
#
	#create_tween().tween_property(camera, "offset", Vector2.ZERO, 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	#create_tween().tween_property(camera, "zoom", _starting_camera_zoom, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
#}


#
#@export var camera: Camera2D
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
