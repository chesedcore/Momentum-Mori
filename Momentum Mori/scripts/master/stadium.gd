extends Node2D


@export var base_knockback: float = 300.0
@export var loser_knockback_multiplier: float = 2.5
@export var recoil_duration: float = 0.5

@export var loser_dmg_multiplier : float = 1.5
@export var camera: Camera2D

@onready var _starting_camera_zoom: Vector2 = camera.zoom


func _on_blade_blade_collision(player :Player,collision :KinematicCollision2D) -> void{
	apply_camera_shake()

	var enemy : Blade = collision.get_collider()
	print("Collision between "+player.name + " and " + enemy.name)

	var normal := collision.get_normal()
	var player_impact = -player.velocity.dot(normal)
	var enemy_impact = enemy.velocity.dot(normal)

	if player_impact > 0 and enemy_impact < 0 {
		print("Both took damage")
		player.apply_recoil(normal, base_knockback, recoil_duration)
		player.take_damage(enemy.base_dmg)
		enemy.apply_recoil(-normal, base_knockback, recoil_duration)
		enemy.take_damage(player.base_dmg)
	} elif player_impact > enemy_impact {
		print("Enemy took damage")
		player.apply_recoil(normal, base_knockback, recoil_duration)
		enemy.apply_recoil(-normal, base_knockback * loser_knockback_multiplier, recoil_duration)
		enemy.take_damage(player.base_dmg * loser_dmg_multiplier)
	} else {
		print("Player took damage")
		player.apply_recoil(normal, base_knockback * loser_knockback_multiplier, recoil_duration)
		player.take_damage(enemy.base_dmg * loser_dmg_multiplier)
		enemy.apply_recoil(-normal, base_knockback, recoil_duration)
	}

	#collision_anim(collision.get_position())
}


func apply_camera_shake() -> void {
	# Camera shake on impact
	camera.offset = Vector2(randf_range(-200.0, 200.0), randf_range(-200.0, 200.0))
	var z_val := randf_range(0.26, 0.3)
	camera.zoom = Vector2(z_val, z_val)

	create_tween().tween_property(camera, "offset", Vector2.ZERO, 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	create_tween().tween_property(camera, "zoom", _starting_camera_zoom, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
}


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
