extends Node2D
@onready var warning: Node2D = $warning
@export var projectile_part: Node2D
@export var hit_box_collision_shape_2d: CollisionShape2D
@export var aoe_recoil :float = 700
@export var aoe_dmg : float = 15

func _ready() -> void{
	warn()
}

func warn()->void{
	var warn_tween := create_tween()
	warn_tween.set_loops(3)
	warn_tween.tween_property(warning,"modulate",Color.WHITE,0.25)
	warn_tween.tween_property(warning,"modulate",Color.TRANSPARENT,0.25)
	
	await warn_tween.finished
	expand()
}

func expand()->void{
	projectile_part.visible = true
	hit_box_collision_shape_2d.disabled = false
	var expand_tween := create_tween()
	expand_tween.tween_property(projectile_part,"scale",Vector2(10,10),2)
	
	await expand_tween.finished
	queue_free.call_deferred()
	
}


func _on_area_2d_body_entered(body: Node2D) -> void{
	if body is Player:
		body.apply_recoil(-body.velocity.normalized(),aoe_recoil,.5)
		body.take_damage(aoe_dmg)
		EventBus.spawn_spark.emit(body)
}
