class_name SegmentCascade extends CascadeV3

signal stuff_detected(stuff: Array[Node2D])

@export var area: Area2D

func _ready() -> void {
	super()
	_wire_up_signals()
}

func _wire_up_signals() -> void {
	self.cascade_in_chain_finished.connect(sweep_area)
}

func sweep_area() -> void {
	var stuff := area.get_overlapping_bodies()
	if not stuff: return
	stuff_detected.emit(stuff)
}

func get_endpoint_vec() -> Option[Vector2] {
	if not has_node(^"Marker") {
		return Option.none()
	}
	return Option.some(get_node(^"Marker").global_position)
}
