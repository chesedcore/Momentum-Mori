class_name Btn extends Control

signal clicked

@export var backstripes: ColorRect
@export var actual_name: RichTextLabel
@export var both_labels: Array[RichTextLabel]
var t: Tween

var _btn_text: String

func _ready() -> void {
	_btn_text = actual_name.text
	backstripes.scale.y = 0
	_wire_up_signals()
}

func _wire_up_signals() -> void {
	actual_name.mouse_entered.connect(_on_mouse_hovered_text)
	actual_name.mouse_exited.connect(_on_mouse_unhovered_text)
	actual_name.gui_input.connect(_on_gui_input)
}

func reset_tween() -> void {
	if t: t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	t.set_parallel(true)
}

func _on_mouse_hovered_text() -> void {
	reset_tween()
	t.tween_property(backstripes, ^"scale:y", 1.0, 0.3)
	both_labels.map(_make_label_shake)
	for font in _iter_fonts() {
		t.tween_property(font, ^"spacing_glyph", 10, 0.3)
	}
}

func _on_mouse_unhovered_text() -> void {
	reset_tween()
	t.tween_property(backstripes, ^"scale:y", 0.0, 0.3)
	both_labels.map(_reset_label_shake)
	for font in _iter_fonts() {
		t.tween_property(font, ^"spacing_glyph", 0, 0.3)
	}
}

func _on_gui_input(ev: InputEvent) -> void {
	if ev is InputEventMouseButton {
		if ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT {
			clicked.emit()
		}
	}
}

func _make_label_shake(l: RichTextLabel) -> void {
	l.text = "[shake]"+_btn_text
}

func _reset_label_shake(l: RichTextLabel) -> void {
	l.text = _btn_text
}

func _get_font_variation(l: RichTextLabel) -> FontVariation {
	return l.get_theme_font(&"normal_font")
}

func _iter_fonts() -> Array[FontVariation] {
	var fonts: Array[FontVariation]
	fonts.assign(both_labels.map(_get_font_variation))
	return fonts
} 
