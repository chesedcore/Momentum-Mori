class_name Segments extends HBoxContainer

@export var start_on_ready := true
@export var stagger_time := 0.1

signal last_element_cascaded_in

func _ready() -> void {
	if start_on_ready: launch()
}

var _launching := false

func launch() -> Promise {
	_launching = true
	var last_element: CascadeV3 = get_children().back()
	for child: CascadeV3 in get_children() {
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
	
	return _generate_promise()
}

func _generate_promise() -> Promise {
	var valid_segments: Array[SegmentCascade]
	valid_segments.assign(
		get_children().filter(func(n: Node): return not n.is_queued_for_deletion())
	)
	return Promise.from_obj_arr(
		&"stuff_detected", valid_segments
	).any()
}

func cancel() -> void {
	_launching = false
}
