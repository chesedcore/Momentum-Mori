class_name Segments extends HBoxContainer

@export var start_on_ready := true
@export var stagger_time := 0.1

func _ready() -> void {
	if start_on_ready: launch()
}

func launch() -> void {
	for child: CascadeV3 in get_children() {
		
		#this is required. clear_segments() from the chain whip class
		#queues the children to be destroyed, and they might not have been
		#fully freed by the time this function is called.
		if child.is_queued_for_deletion(): continue
		
		child.cascade_in()
		await get_tree().create_timer(stagger_time).timeout
	}
}
