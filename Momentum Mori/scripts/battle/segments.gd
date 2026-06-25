class_name Segments extends HBoxContainer

@export var start_on_ready := true
@export var stagger_time := 0.1

signal last_element_cascaded_in

func _ready() -> void {
	if start_on_ready: launch()
}

var _launching := false

func launch() -> void {
	_launching = true
	var children := get_children()
	var last_element: CascadeV3 = get_children().back()
	for child: CascadeV3 in children {
		if not _launching: return
		
		#this is required. clear_segments() from the chain whip class
		#queues the children to be destroyed, and they might not have been
		#fully freed by the time this function is called.
		if child.is_queued_for_deletion(): continue
		
		child.cascade_in()
		await get_tree().create_timer(stagger_time).timeout
	}
	
	_launching = false
	assert(not last_element.is_queued_for_deletion(), "last element is queued for deletion... well, fuck.")
	last_element.cascade_in_chain_finished.connect(
		last_element_cascaded_in.emit,
		CONNECT_ONE_SHOT
	)
}

func cancel() -> void {
	_launching = false
}
