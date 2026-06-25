class_name AoeBoss extends EnemyBlade

const AOE_PROJECTILE = preload("res://scenes/battle/aoe_projectile.tscn")

@export var aoe_recoil :float = 700
@export var aoe_dmg : float = 15
@export var aoe_duration : float = 2
@export var aoe_cooldown : float = .5

var remaining_aoe_cooldown : float = 0
var remaining_aoe_duration : float = 0
var on_cooldown:bool = false
@export var aoe_visual: Node2D


func _on_area_2d_body_entered(body: Node2D) -> void{
	if body is Player:
		body.apply_recoil(-body.velocity.normalized(),aoe_recoil,.5)
		body.take_damage(aoe_dmg)
		EventBus.spawn_spark.emit(body)
}

func _physics_process(delta: float) -> void{
	super._physics_process(delta)
	
	if remaining_aoe_cooldown <= 0{
		on_cooldown = false
		remaining_aoe_cooldown = aoe_cooldown
		begin_aoe()
	}
	elif on_cooldown{
		remaining_aoe_cooldown -=delta
	}
	else{
		remaining_aoe_duration += delta
		if remaining_aoe_duration >= aoe_duration{
			remaining_aoe_duration = 0
			on_cooldown = true
		}
	}
}


func begin_aoe()->void {
	#5050 if the aoe will be at the boss location or the players location
	var aoe_projectile : Node2D = AOE_PROJECTILE.instantiate()
	
	var aoe_at_player_chance :int =randi_range(0,1)
	if aoe_at_player_chance == 1{
		aoe_projectile.global_position = target.global_position
		EventBus.spawn_projectile.emit(aoe_projectile)
	} 
	else{
		add_child(aoe_projectile)
	}
}
