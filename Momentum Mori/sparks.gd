
extends Node2D



func _ready() -> void:
	$GPUParticles2D.one_shot = true
	$GPUParticles2D.restart()
