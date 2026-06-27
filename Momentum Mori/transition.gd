extends Control
@onready var color_rect: ColorRect = $ColorRect


func scene_to_transition_to(scene : String){
	var transition_tween = create_tween()
	transition_tween.tween_property(color_rect,"modulate",Color.WHITE,.5)
	await transition_tween.finished
	get_tree().change_scene_to_file(scene)
	var transition_out_tween = create_tween()
	transition_out_tween.tween_property(color_rect,"modulate",Color.TRANSPARENT,.5)
}
