class_name BladeSparks extends Node2D

func _ready() -> void:
	$GPUParticles2D.restart()

func set_sparks_rotation(to_mouse : Vector2) -> void {
	rotation = to_mouse.angle()
}
	
func should_emit(yes : bool) -> void {
	$GPUParticles2D.emitting = yes
}

func set_amount(amount : float) -> void {
	$GPUParticles2D.amount_ratio = amount
}
