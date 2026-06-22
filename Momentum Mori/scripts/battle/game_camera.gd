@tool
class_name GameCamera extends PhantomCamera2D

var stadium: Stadium

func _process(delta: float) -> void {
	super(delta)
	_update_camera()
}

func _update_camera() -> void {
	#var blades := stadium.iter_blades()
}
