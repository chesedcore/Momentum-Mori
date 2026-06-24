class_name Segments extends HBoxContainer

const SEGMENT_LENGTH_X := 40
@export var start_on_ready := true
@export var stagger_time := 0.1

func _ready() -> void {
	if start_on_ready: launch()
}

func launch() -> void {
	for child: CascadeV3 in get_children() {
		child.cascade_in()
		await get_tree().create_timer(stagger_time).timeout
	}
}
