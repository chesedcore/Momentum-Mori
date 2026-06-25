class_name ChainWhip extends Node2D

signal stuff_hit(stuff: Node2D)
signal fully_unrolled

@export var segments: Segments

const SEGMENT_LENGTH_X := 220
const TIME_PER_2_MEMBER_SEGMENT := 0.1
const CASCADE_STAGGER := 0.01

var is_being_killed := false

static func summon_chain_from_start_to_end(
	node_to_attach_to: Node2D,
	start_point: Vector2,
	end_point: Vector2
) -> ChainWhip {
	
	var chain_whip := Registry.create_chain_whip()
	chain_whip.segments.start_on_ready = false
	node_to_attach_to.add_child(chain_whip)
	chain_whip.clear_segments()
	
	chain_whip.global_position = start_point
	var angle := start_point.angle_to_point(end_point)
	chain_whip.global_rotation = angle
	
	var distance := start_point.distance_to(end_point)
	var fittable_number_of_segments := ceili(distance / SEGMENT_LENGTH_X)
	chain_whip.summon_these_many_segments(fittable_number_of_segments)
	chain_whip.launch_and_detect_collidables()
	return chain_whip
}

var promise: Promise
func launch_and_detect_collidables() -> void {
	assert(not promise, "A promise has already been made!")
	promise = await segments.launch()
	segments.last_element_cascaded_in.connect(fully_unrolled.emit)
	if promise: promise.resolved.connect(_on_promise_resolved)
}

func _on_promise_resolved(results: Array) -> void {
	
	assert(results, "This result array has nothing!")
	
	if results.size() == 1 {
		stuff_hit.emit(results[0])
		return
	}
	
	#get the nearest hit
	results.sort_custom(
		func(a: Node2D, b: Node2D) -> bool:
			return self.global_position.distance_to(a.global_position) < \
			self.global_position.distance_squared_to(b.global_position)
	)
	
	stuff_hit.emit(results[0])
}

func clear_segments() -> void {
	for segment in segments.get_children() {
		segment.queue_free()
	}
}

func summon_these_many_segments(num: int) -> void {
	var chain_segment := preload("res://scenes/battle/chain_segment.tscn")
	var mace_head := preload("res://scenes/battle/mace_head.tscn")
	for i in (num - 1) {
		segments.add_child(chain_segment.instantiate())
	}
	segments.add_child(mace_head.instantiate())
}

func kill() -> void {
	if is_being_killed: return
	is_being_killed = true
	segments.cancel()
	if promise: promise.deny()
	var children := segments.get_children()
	
	if children.is_empty() {
		queue_free()
		return
	}
	
	var last_cascade: CascadeV3 = children.back()
	last_cascade.cascade_out_chain_finished.connect(queue_free)
	for c: CascadeV3 in children {
		c.cascade_out()
	}
}

func get_timing_until_chain_unroll() -> float {
	return TIME_PER_2_MEMBER_SEGMENT * segments.get_children().filter(
		func(n: Node) -> bool: return not n.is_queued_for_deletion()
	).size() + CASCADE_STAGGER
}

func get_endpoint() -> Option[Vector2] {
	return segments.iter().back().get_endpoint_vec()
}
