class_name Results extends Control

var won: bool
var stage: StageData

signal finished(p_won: bool, p_stage: StageData)
@export var status: RichTextLabel
@export var bar_container: VBoxContainer

var _prior_offsets: Dictionary[ColorRect, Vector2]

static func from(p_status: bool, p_data: StageData) -> Results {
	var res := Registry.create_results()
	res.won = p_status
	res.stage = p_data
	return res
}

func record_offsets() -> void {
	for bar in iter_bars() {
		_prior_offsets[bar] = bar.offset_transform_position
	}
}

func _ready() -> void {
	set_status_text()
	record_offsets()
	scatter()
	begin()
	await get_tree().create_timer(3).timeout
	_on_finished()
}

func scatter() -> void {
	status.modulate = Color.TRANSPARENT
}

func set_status_text() -> void {
	if won {
		status.text = "VICTORY  VICTORY"
	} else {
		status.text = "DEFEAT  DEFEAT"
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

func make_everything_appear() -> void {
	for bar in iter_bars() {
		t.tween_property(bar, "offset_transform_position", Vector2.ZERO, 0.7)
	}
	t.tween_property(status, "modulate", Color.WHITE, 0.7)
}

func make_everything_disappear() -> void {
	for bar in iter_bars() {
		t.tween_property(bar, "offset_transform_position", _prior_offsets[bar], 0.7)
	}
	t.tween_property(status, "modulate", Color.TRANSPARENT, 0.7)
	t.finished.connect(finished.emit.bind(won, stage))
}

func _on_finished() -> void {
	reset_tween()
	make_everything_disappear()
}
