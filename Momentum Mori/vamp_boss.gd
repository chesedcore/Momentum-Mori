class_name VampBoss extends EnemyBlade

@export var visual: Node2D
@onready var spiral: SpiralAttack = $Spiral

@onready var spiral_attack_duration: Timer = $SpiralAttackDuration
@onready var spiral_attack_cooldown: Timer = $SpiralAttackCooldown



func life_steal(amount: float)->void{
	hp += amount
	print("Life STEALLLL i took " + str(amount) + " spin from you  and i now have "+ str(hp) +" amount of spiin")
	flash() 
}
func flash() -> void{
	var tween = create_tween()
	tween.tween_property(visual, "modulate", Color.RED, 0.5)
	tween.tween_property(visual, "modulate", Color.WHITE, 0.5)
	tween.tween_property(visual, "modulate", Color.RED, 0.5)
	tween.tween_property(visual, "modulate", Color.WHITE, 0.5)
}


func _on_spiral_cooldown_timeout() -> void{
	spiral.collision_shape_2d.disabled = false
	spiral.visible = true
	spiral_attack_duration.start()
}





func _on_spiral_attack_duration_timeout() -> void{
	spiral.collision_shape_2d.disabled = true
	spiral.visible = false
	spiral_attack_cooldown.start()
}
