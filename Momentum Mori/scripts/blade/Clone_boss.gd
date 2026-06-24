class_name  CloneBoss extends EnemyBlade


const ENEMY_BLADE = preload("res://scenes/blade/enemy_blade.tscn")

@export var max_clones :int = 4
var num_of_clones :int = 0
@export var clone_spawn_time: Timer
@export var clone_hp : float = 10


func _on_clone_spawn_time_timeout() -> void:
	var clone:EnemyBlade = ENEMY_BLADE.instantiate()
	clone.global_position = global_position
	clone.target = target
	clone.hp = clone_hp
	clone.died.connect(_on_clone_died)
	EventBus.spawn_blade.emit(clone)
	num_of_clones += 1
	if num_of_clones < max_clones :
		_begin_spawn()

func _begin_spawn():
	clone_spawn_time.start()

func _on_clone_died()->void{
	num_of_clones -= 1
	_begin_spawn()
}
