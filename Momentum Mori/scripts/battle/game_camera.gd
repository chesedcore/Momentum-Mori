@tool
class_name GameCamera extends PhantomCamera2D

var stadium: Stadium


func _process(delta: float) -> void {
	super(delta)
	#_update_camera(delta)
}

func _update_camera(_delta: float) -> void {
	#if not stadium: return
	#
	#var player := stadium.player
	#var blades := stadium.iter_blades()
	#
	#var max_dist := 0.0
	#for blade in blades {
		#var d := player.global_position.distance_to(blade.global_position)
		#if d > max_dist {
			#max_dist = d
		#}
	#}
	#
	#var t := clampf(max_dist / 800.0, 0.0, 1.0)
	#var target_zoom := lerpf(0.5, 0.3, t)
	#zoom = zoom.lerp(Vector2(target_zoom, target_zoom), 3.0 * delta)
}
