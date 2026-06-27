extends Node2D

@export var next_scene : String

@onready var enemies: Node2D = $Field/Stadium/Enemies
@onready var player: Player = $Field/Stadium/Player

var num_of_enemies :int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for enemy :EnemyBlade in enemies.get_children():
		enemy.died.connect(check_enemies)
		num_of_enemies +=1
	player.died.connect(_retry)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _retry():
	get_tree().reload_current_scene()
func check_enemies():
	print("da enemies are dying")
	num_of_enemies -=1
	if num_of_enemies ==0:
		Transition.scene_to_transition_to(next_scene)
