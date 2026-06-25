class_name VampBoss extends EnemyBlade

@export var visual: Node2D


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
