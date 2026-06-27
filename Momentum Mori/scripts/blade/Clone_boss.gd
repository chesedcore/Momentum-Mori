class_name  CloneBoss extends EnemyBlade


const CLONE_BOSS_CLONE = preload("res://scenes/blade/clone_boss_clone.tscn")
const SKULL = preload("res://scenes/battle/skull.tscn")


@export var max_clones :int = 4
var num_of_clones :int = 0
@export var clone_spawn_time: Timer
@export var clone_hp : float = 10


func _on_clone_spawn_time_timeout() -> void:
	var clone:EnemyBlade = CLONE_BOSS_CLONE.instantiate()
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


func _on_skull_cooldown_timeout() -> void:
	var skull: Sword = SKULL.instantiate()
	skull.target=target
	skull.global_position = global_position
	skull.fire()
	EventBus.spawn_projectile.emit(skull)
	
