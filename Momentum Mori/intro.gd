extends Control

@export var next_scene : String




func _on_timer_timeout() -> void:
	Transition.scene_to_transition_to(next_scene)
