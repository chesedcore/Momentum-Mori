class_name Trail2D extends Line2D

const MAX_POINTS = 30
@onready var curve = Curve2D.new()

func _process(_delta: float) -> void {
	curve.add_point(get_parent().position)
	if curve.get_baked_points().size() > MAX_POINTS {
		curve.remove_point(0)
	}
	points = curve.get_baked_points()
}

func stop() -> void {
	set_process(false)
	var tw := get_tree().create_tween()
	tw.tween_property(self, "modulate:a", 0.0,3.0)
	await tw.finished
	queue_free()
}

static func create() -> Trail2D {
	var scn = preload("res://scenes/particles/trail2d.tscn")
	return scn.instantiate()
}
	
