class_name  ParryBoss extends EnemyBlade

@export var parry_recoil :float = 700
@export var parry_dmg : float = 15
@export var parry_duration : float = 2
@export var parry_cooldown : float = 2
@export var visual: Node2D

var remaining_parry_cooldown : float = 0
var remaining_parry_duration : float = 0
var on_cooldown:bool = false


func _on_area_2d_body_entered(body: Node2D) -> void{
	if body is Player:
		body.apply_recoil(-body.velocity.normalized(),parry_recoil,.5)
		body.take_damage(parry_dmg)
		EventBus.spawn_spark.emit(body)
}

func _physics_process(delta: float) -> void{
	super._physics_process(delta)
	
	if remaining_parry_cooldown <= 0{
		on_cooldown = false
		remaining_parry_cooldown = parry_cooldown
		begin_parry()
	}
	elif on_cooldown{
		remaining_parry_cooldown -=delta
	}
	else{
		remaining_parry_duration += delta
		if remaining_parry_duration >= parry_duration{
			remaining_parry_duration = 0
			on_cooldown = true
			end_parry()
		}
	}
}


var og_color : Color

func begin_parry()->void {
	
	og_color = visual.modulate
	var tween = create_tween()
	tween.set_loops(2)
	tween.tween_property(visual, "modulate", Color.BLUE, 0.15)
	tween.tween_property(visual, "modulate", og_color, 0.15)
	tween.tween_property(visual, "modulate", Color.BLUE, 0.15)
	await  tween.finished
	is_parrying = true
}

func end_parry()->void{
	is_parrying = false
	var tween = create_tween()
	tween.tween_property(visual, "modulate", og_color, 0.15)
}
