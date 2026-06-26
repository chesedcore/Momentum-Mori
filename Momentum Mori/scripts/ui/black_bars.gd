class_name BlackBars extends Control

var field: Field

@export var top: ColorRect
@export var bottom: ColorRect

func setup_using_field(p_field: Field) -> void {
	field = p_field
	field.started_adrenaline.connect(show_bars)
	field.stopped_adrenaline.connect(hide_bars)
}

var t: Tween

func reset_tween() -> void {
	if t: t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	t.set_parallel(true).set_ignore_time_scale(true)
}

func show_bars() -> void {
	reset_tween()
	t.tween_property(top, "offset_transform_position:y", 0, 0.4)
	t.tween_property(bottom, "offset_transform_position:y", 0, 0.4)
}

func hide_bars() -> void {
	reset_tween()
	t.tween_property(top, "offset_transform_position:y", -50, 0.4)
	t.tween_property(bottom, "offset_transform_position:y", 50, 0.4)
}
