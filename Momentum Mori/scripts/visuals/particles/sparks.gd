extends Node2D



func _ready() -> void:
	$GPUParticles2D.one_shot = true
	$GPUParticles2D.restart()
	




func _on_gpu_particles_2d_finished() -> void:
	queue_free.call_deferred()
