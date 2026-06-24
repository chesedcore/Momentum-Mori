class_name AoeBoss extends EnemyBlade


@export var aoe_recoil :float = 700
@export var aoe_dmg : float = 15
@export var aoe_duration : float = 2
@export var aoe_cooldown : float = 2

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
			end_aoe()
		}
	}
}


func begin_aoe()->void {
	aoe_visual.visible = true
	
	var aoe_tween = create_tween()
	aoe_tween.tween_property(aoe_visual,"scale",Vector2(10,10),2)
}

func end_aoe()->void{
	aoe_visual.visible = false
	aoe_visual.scale = Vector2(1,1)
}
