class_name Results extends Control

signal txt_clicked
signal _internal_finished
signal finished

@export var bar_container: VBoxContainer
@export var text: HiFidelityLabel
@export var skip: RichTextLabel

var _prior_offsets: Dictionary[ColorRect, Vector2]

@export var lines: Array[String]

static func from_lines(arr: Array[String]) -> IntroSequence {
	var intro := Registry.create_intro()
	intro.lines.assign(arr)
	return intro
}

func _unhandled_input(event: InputEvent) -> void {
	if event.is_action_pressed("ui_accept") {
		txt_clicked.emit()
	}
	if event.is_action_pressed("skip") {
		_internal_finished.emit()
	}
}


func record_offsets() -> void {
	for bar in iter_bars() {
		_prior_offsets[bar] = bar.offset_transform_position
	}
}

func _ready() -> void {
	_wire_up_signals()
	record_offsets()
	scatter()
	begin()
}

func _wire_up_signals() -> void {
	_internal_finished.connect(_on_internal_finished, CONNECT_ONE_SHOT)
	text.gui_input.connect(_on_text_gui_input)
}

func _on_text_gui_input(ev: InputEvent) -> void {
	if ev is InputEventMouseButton {
		if ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT {
			txt_clicked.emit()
		}
	}
}

func iter_bars() -> Array[ColorRect] {
	var rects: Array[ColorRect]
	rects.assign(bar_container.get_children())
	return rects
}

var t: Tween

func reset_tween() -> void {
	if t: t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	t.set_parallel(true)
}

func begin() -> void {
	reset_tween()
	make_everything_appear()
}

func scatter() -> void {
	text.immediately_set_text("...")
	text.modulate = Color.TRANSPARENT
	skip.modulate = Color.TRANSPARENT
}

func make_everything_appear() -> void {
	for bar in iter_bars() {
		t.tween_property(bar, "offset_transform_position", Vector2.ZERO, 0.7)
	}
	t.tween_property(text, "modulate", Color.WHITE, 0.7)
	t.tween_property(skip, "modulate", Color.WHITE, 0.7)
	t.finished.connect(recite_lines)
}

func make_everything_disappear() -> void {
	for bar in iter_bars() {
		t.tween_property(bar, "offset_transform_position", _prior_offsets[bar], 0.7)
	}
	t.tween_property(text, "modulate", Color.TRANSPARENT, 0.7)
	t.tween_property(skip, "modulate", Color.TRANSPARENT, 0.7)
	t.finished.connect(finished.emit)
}

var txt_tween: Tween
func recite_lines() -> void {
	txt_tween = create_tween()
	for line in lines {
		txt_tween.tween_callback(text.morph_into.bind(line))
		txt_tween.tween_await(txt_clicked).set_timeout(text.zero_point_three + 2)
	}
	txt_tween.finished.connect(_internal_finished.emit)
}

func ensure_text_killed() -> void {
	if txt_tween: txt_tween.kill()
}

func _on_internal_finished() -> void {
	ensure_text_killed()
	reset_tween()
	make_everything_disappear()
}
