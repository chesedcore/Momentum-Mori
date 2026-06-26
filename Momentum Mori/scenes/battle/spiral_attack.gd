class_name SpiralAttack extends Node2D

@export var spin_speed :int= 10

var player :Player
@export var host :VampBoss
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D



@export var dmg : float = 5
@export var dmg_tick : float = .5
var remaining_tick : float = 0

func _physics_process(delta: float) -> void{
	rotation += spin_speed * delta
	if player{
		if remaining_tick <= dmg_tick{
			remaining_tick += delta
		}
		else{
			player.take_damage(dmg)
			host.life_steal(dmg)
			remaining_tick = 0
		}
	}
	
	
}
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player and body == player:
		player = null
