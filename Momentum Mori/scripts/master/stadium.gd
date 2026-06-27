class_name Stadium extends Node2D
const SPARKS = preload("res://scenes/particles/sparks.tscn")

@export var player: Player
@export var enemies: Node2D
@export var projectiles: Node2D
@export var chain_dock: ChainDock

@export var base_knockback: float = 300.0
@export var loser_knockback_multiplier: float = 4
@export var recoil_duration: float = 1

@export var loser_dmg_multiplier : float = 1.5
@export var pcam: GameCamera

var collision_cooldown: float = 0.0
const COLLISION_COOLDOWN_DURATION: float = 0.1


func _on_blade_blade_collision(_player: Player, collision: KinematicCollision2D, player_velocity: Vector2) -> void {
	if collision_cooldown > 0.0 {
		return
	}

	SFXPlayer.play_sfx(preload("res://assets/audio/impact.ogg"), _player.global_position)

	pcam.play_impact_shake(_player.velocity.length() / 2500)

	collision_cooldown = COLLISION_COOLDOWN_DURATION
	var enemy: EnemyBlade = collision.get_collider()
	var normal := collision.get_normal()
	#OH BOY HERE I GO DISSAPOINYOMH MONARCH AGAIN
	# ignore everything if the guy is parryinggg
	if enemy.is_parrying {
		player.apply_recoil(normal, base_knockback * loser_knockback_multiplier, recoil_duration)
		player.take_damage(enemy.base_dmg * loser_dmg_multiplier)
		_on_spark_at_node(player)
		return
	}


	# who was attacking (facing toward the other)
	var player_attacking :bool = -player_velocity.normalized().dot(normal) > 0.5
	var enemy_attacking :bool = enemy.velocity.normalized().dot(normal) > 0.5

	## you REALLY know how to make a grown man cry huh
	##  -- monarch

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


		#ok this is probbably the worst way to do it but i am just gonna have the stadium check if the collision had a vamp and allow for lifesteal
		#head on vamp lifesteals  the amouunt the player dealt so they get a net postive spin from head as opposed to the player
		if enemy is VampBoss{
			enemy.life_steal(player.base_dmg * enemy_dmg_ratio)
		}



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

			#sigh.......monarchs gonna kill me

			if enemy is VampBoss{
				enemy.life_steal(enemy.base_dmg * loser_dmg_multiplier)

			}


		}
		enemy.apply_recoil(-normal, base_knockback, recoil_duration)
	}
	#uhhh so like the enemy should stop the attack after colliding i think
	if enemy.current_state == EnemyBlade.STATES.ATTACKING{
	enemy.change_to_chasing()
	}


	#OH BOY SPARKY SPARKY





	#uhh ill put it here to not bloat everything upp therrrr

	#LILI: i just reimplemented gael code with some changes
	var sparks: Node2D = SPARKS.instantiate()
	sparks.global_position = collision.get_position()
	var attack_direction: Vector2
	var sparks_scale : float
	if player_attacking and enemy_attacking {
		#Double the sparks cuz i think maybe that will look cool
		var second_sparks : Node2D = SPARKS.instantiate()
		second_sparks.rotation = enemy.velocity.normalized().angle()
		var second_spark_scale = remap(enemy.velocity.length(),0.0, 800, 0.05, 3.)
		second_sparks.scale = Vector2(second_spark_scale, second_spark_scale)
		second_sparks.global_position = collision.get_position()
		add_child(second_sparks)
		sparks_scale = remap(player_velocity.length(), 0.0, 5000, 0.05, 3.)
		attack_direction = player_velocity.normalized()
	}
	elif player_attacking {
		sparks_scale = remap(player_velocity.length(), 0.0, 5000, 0.05, 3.)
		attack_direction = player_velocity.normalized()
	}
	else {
		sparks_scale = remap(enemy.velocity.length(),0.0, 800, 0.05, 3.)
		attack_direction = enemy.velocity.normalized()
	}
	sparks.rotation = attack_direction.angle()
	sparks.scale = Vector2(sparks_scale, sparks_scale)

	add_child(sparks)
	#
	#pazaz
	#apply_camera_shake()
}

func _process(delta: float) -> void{
	if collision_cooldown > 0.0 {
		collision_cooldown -= delta
	}
}

func iter_enemies() -> Array[Blade] {
	var arr: Array[Blade]
	arr.assign(enemies.get_children())
	return arr
}

func iter_blades() -> Array[Blade] {
	var arr: Array[Blade]
	arr.assign(enemies.get_children())
	arr.append(player)
	return arr
}

func  _ready() -> void {
	_starting_camera_zoom = camera.zoom
	_wire_signals()
}


func _wire_signals()->void {
	EventBus.spawn_projectile.connect(_on_spawn_projectile)
	
	EventBus.spawn_spark.connect(_on_spark_at_node)
}


@export var camera: Camera2D
var _starting_camera_zoom : Vector2
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
#
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
func _on_spawn_projectile(projectile: Node2D)->void{
	projectiles.add_child(projectile)
}

func _on_spawn_blade(blade: Node2D) ->void{
	enemies.add_child(blade)
}

func _on_spark_at_node(node: Node2D){
	var sparks: Node2D = SPARKS.instantiate()
	sparks.global_position = node.global_position
	if node is Blade {
		sparks.rotation = -node.velocity.normalized().angle()
	}
	add_child(sparks)
}

func get_player() -> Player {
	return player
}

func get_chain_dock() -> ChainDock {
	return chain_dock
}


func _on_player_stadium_collision() -> void{
	pcam.play_impact_shake(player.velocity.length() / 2500)
	player.apply_recoil(-player.velocity.normalized(),500,.5)
	_on_spark_at_node(player)

}
