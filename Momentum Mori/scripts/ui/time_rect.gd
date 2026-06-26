class_name TimeRect extends ColorRect

const ORIGINAL_SIZE_X := 520.0

var field: Field

func _process(_delta: float) -> void {
	_update_rect()
}

func _update_rect() -> void {
	if not field: return
	var max_sec := field.max_adrenaline_time_in_seconds
	var current := field.timer.time_left \
		if field._is_under_adrenaline else field.timer.wait_time
	var ratio := current / max_sec
	size.x = ORIGINAL_SIZE_X * ratio
}
