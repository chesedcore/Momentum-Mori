class_name HiFidelityLabel extends Control

signal finished_morphing

@export_range(4, 500, 1) var max_glyphs: int = 256
@export var letter_spacing: float = 0.0
@export var baseline_y: float = 0.0
@export var zero_point_three: float = 0.3
@export var font_size := 10
@export var override_font: Font
@export_enum("Left", "Center", "Right") var alignment: int = 1
@export var t_ease: Tween.EaseType = Tween.EASE_OUT
@export var t_trans: Tween.TransitionType = Tween.TRANS_EXPO

@export_category("Multiline settings")
@export var multiline: bool = false
@export var max_width: float = 0.0
@export var line_spacing: float = 0.0
@export var word_wrap: bool = true

var _font: Font

var _label_pool: Array[Label] = []
var _free_label_indices := PackedInt32Array()
var _active_glyphs: Array[Glyph] = []
var _active_morph_tweens: Array[Tween] = []

class Glyph:
	var repr: String:
		set(string):
			if string.length() > 1: string = string[0]; push_warning("Nonchar string passed.")
			repr = string
	var label_idx := -1
	var pos := Vector2.ZERO
	var target_pos := Vector2.ZERO
	var tween: Tween = null
	var is_alive: bool = false

	static func from(c: String, lbl_idx: int, start_pos: Vector2) -> Glyph:
		var g := Glyph.new()
		g.repr = c
		g.label_idx = lbl_idx
		g.pos = start_pos
		g.target_pos = start_pos
		g.is_alive = true
		return g

	func stop_tween() -> void:
		if tween: tween.kill()
		tween = null

	func kill() -> void:
		is_alive = false


func _ready() -> void:
	_preallocate_pool()

func _try_set_label_font(label: Label) -> void:
	if not _font:
		if override_font:
			_font = override_font
		else:
			_font = label.get_theme_font(&"font")
	label.add_theme_font_override(&"font", _font)

func _preallocate_pool() -> void:
	for i in max_glyphs:
		var label := Label.new()
		label.visible = false
		label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.focus_mode = Control.FOCUS_NONE
		_try_set_label_font(label)
		label.add_theme_font_size_override(&"font_size", font_size)
		self.add_child(label)
		_label_pool.push_back(label)
		_free_label_indices.push_back(i)

func _pop_i32_arr(arr: PackedInt32Array) -> int:
	var last_idx := arr.size() - 1
	var item := arr[last_idx]
	arr.remove_at(last_idx)
	return item

func _spawn_glyph(ch: String) -> Glyph:
	assert(_free_label_indices.size() > 0, "Improper handling: no more space left free for this glyph.")
	var idx: int = _pop_i32_arr(_free_label_indices)
	var label := _label_pool[idx]
	label.text = ch
	label.visible = true
	label.modulate.a = 1.0
	return Glyph.from(ch, idx, label.position)

func _destroy_glyph(glyph: Glyph) -> void:
	assert(glyph, "This glyph doesn't even exist!")
	glyph.is_alive = false
	glyph.stop_tween()
	var lbl_idx := glyph.label_idx
	if lbl_idx < 0 or lbl_idx >= _label_pool.size():
		push_error("Ran into an invalid state, how did this even happen?")
		print_stack()
	var label := _label_pool[lbl_idx]
	var t := create_tween().set_ease(t_ease).set_trans(t_trans)
	label.visible = true
	t.tween_property(label, "modulate:a", 0.0, zero_point_three)
	t.tween_callback(_reset_glyph.bind(lbl_idx))

func _reset_glyph(label_idx: int) -> void:
	var label := _label_pool[label_idx]
	label.visible = false
	label.text = ""
	_free_label_indices.push_back(label_idx)

func _pop_nearest(list_idx_arr: Array, target_idx: int) -> int:
	if not list_idx_arr: return -1
	var best_j := 0
	var best_cost := absi(list_idx_arr[0] - target_idx)
	for j in list_idx_arr.size():
		var c := absi(list_idx_arr[j] - target_idx)
		if c < best_cost:
			best_cost = c
			best_j = j
	var chosen: int = list_idx_arr[best_j]
	list_idx_arr.remove_at(best_j)
	return chosen


func _compute_singleline_targets(full_text: String) -> Array[Vector2]:
	var targets: Array[Vector2] = []
	var x_positions := _compute_glyph_positions_from_string(full_text)

	var total_width := 0.0
	if x_positions.size() > 0:
		total_width = x_positions[-1] + (x_positions.size() - 1) * letter_spacing

	var x_offset := 0.0
	match alignment:
		1: x_offset = (size.x - total_width) * 0.5
		2: x_offset = size.x - total_width
		_: x_offset = 0.0

	for i in x_positions.size():
		var x := 0.0
		if i > 0:
			x = x_positions[i - 1]
		x += i * letter_spacing + x_offset
		targets.append(Vector2(x, 0.0))

	return targets


func _relayout_immediately() -> void:
	var full_text := ""
	for g in _active_glyphs:
		full_text += g.repr

	var targets := \
		_compute_multiline_targets(full_text) if multiline \
		else _compute_singleline_targets(full_text)

	for i in _active_glyphs.size():
		var g := _active_glyphs[i]
		var target := targets[i] + Vector2(0.0, baseline_y)
		g.pos = target
		g.target_pos = target
		_set_label_text_and_pos(g.label_idx, g.repr, target)


func _relayout_animated() -> void:
	var full_text := ""
	for g in _active_glyphs:
		full_text += g.repr

	var targets := \
		_compute_multiline_targets(full_text) if multiline \
		else _compute_singleline_targets(full_text)

	_active_morph_tweens.clear()

	for i in _active_glyphs.size():
		var g := _active_glyphs[i]
		var target := targets[i] + Vector2(0.0, baseline_y)
		_set_label_text_and_pos(g.label_idx, g.repr, g.pos)
		g.stop_tween()
		var lbl := _label_pool[g.label_idx]
		var t := create_tween().set_ease(t_ease).set_trans(t_trans)
		t.tween_property(lbl, "position", target, zero_point_three)
		g.tween = t
		g.target_pos = target
		g.pos = target
		_active_morph_tweens.append(t)

	if _active_morph_tweens.size() > 0:
		_active_morph_tweens[-1].finished.connect(_on_morph_complete, CONNECT_ONE_SHOT)


func _on_morph_complete() -> void:
	finished_morphing.emit()

func _set_label_text_and_pos(label_idx: int, ch: String, pos: Vector2) -> void:
	var lbl := _label_pool[label_idx]
	lbl.text = ch
	lbl.position = pos
	lbl.visible = true
	lbl.modulate = Color.WHITE


func _compute_glyph_positions_from_string(full_text: String) -> PackedFloat32Array:
	var result := PackedFloat32Array()
	if not _font:
		push_error("Font cache missing.")
		return result
	var run := ""
	for i in full_text.length():
		run += full_text.substr(i, 1)
		var _size := _font.get_string_size(run, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		result.push_back(_size.x)
	return result


func _compute_multiline_targets(text: String) -> Array[Vector2]:
	var targets: Array[Vector2] = []
	var limit := max_width if max_width > 0.0 else size.x
	var lines: Array[Array] = []
	var current_line: Array[Dictionary] = []
	var line_x := 0.0
	var last_word_break := -1
	
	for i in text.length():
		var ch := text.substr(i, 1)
	
		if ch == "\n":
			lines.append(current_line)
			current_line = []
			line_x = 0.0
			last_word_break = -1
			continue
	
		var ch_width := _font.get_string_size(ch, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	
		if line_x + ch_width > limit and current_line.size() > 0:
			if word_wrap and last_word_break >= 0:
				var chars_to_move: Array[Dictionary] = []
				var new_line_x := 0.0
				for j in range(last_word_break + 1, current_line.size()):
					var char_data: Dictionary = current_line[j]
					chars_to_move.append({"char": char_data["char"], "width": char_data["width"], "x": new_line_x})
					new_line_x += char_data["width"] + letter_spacing
				current_line.resize(last_word_break + 1)
				lines.append(current_line)
				current_line = chars_to_move
				line_x = new_line_x
				last_word_break = -1
			else:
				lines.append(current_line)
				current_line = []
				line_x = 0.0
				last_word_break = -1
		
		if ch == " ":
			last_word_break = current_line.size()
		
		current_line.append({"char": ch, "width": ch_width, "x": line_x})
		line_x += ch_width + letter_spacing
	
	if current_line.size() > 0:
		lines.append(current_line)
	
	var cursor_y := 0.0
	for line in lines:
		if line.size() == 0:
			cursor_y += _get_line_height() + line_spacing
			continue
		var last_char: Dictionary = line[-1]
		var line_width := last_char["x"] + last_char["width"] as float
		var x_offset := 0.0
		var align_width := limit if multiline else size.x
		match alignment:
			1: x_offset = (align_width - line_width) * 0.5
			2: x_offset = align_width - line_width
			_: x_offset = 0.0
		for char_data in line:
			targets.append(Vector2(char_data["x"] + x_offset, cursor_y))
		cursor_y += _get_line_height() + line_spacing
	
	return targets


func _get_label_pos(label_idx: int) -> Vector2:
	return _label_pool[label_idx].position

func _immediately_destroy_all_glyphs() -> void:
	for g in _active_glyphs:
		g.stop_tween()
		var lbl := _label_pool[g.label_idx]
		lbl.visible = false
		lbl.text = ""
		lbl.modulate = Color.WHITE
		_free_label_indices.push_back(g.label_idx)
	_active_glyphs.clear()

func _get_line_height() -> float:
	if not _font: return font_size
	return _font.get_height(font_size)


func immediately_set_text(string: String) -> void:
	_immediately_destroy_all_glyphs()
	for i in string.length():
		var ch := string.substr(i, 1)
		if ch == "\n": continue
		var g := _spawn_glyph(ch)
		_active_glyphs.append(g)
	_relayout_immediately()
	finished_morphing.emit.call_deferred()


func morph_into(new_text: String) -> void:
	if not _active_glyphs:
		immediately_set_text(new_text)
		return

	var bucket: Dictionary[String, Array] = {}
	for i in _active_glyphs.size():
		var g := _active_glyphs[i]
		if not bucket.has(g.repr):
			bucket[g.repr] = []
		bucket[g.repr].append(i)

	var new_active: Array[Glyph] = []
	for new_idx in new_text.length():
		var ch := new_text.substr(new_idx, 1)
		if ch == "\n": continue
		var reused: Glyph
		if bucket.has(ch):
			var list := bucket[ch]
			var old_idx := _pop_nearest(list, new_idx)
			if old_idx >= 0: reused = _active_glyphs[old_idx]
		if reused:
			reused.stop_tween()
			reused.is_alive = true
			new_active.append(reused)
		else:
			var ng := _spawn_glyph(ch)
			new_active.append(ng)
	
	for key in bucket.keys():
		var list_rem: Array = bucket[key]
		for rem_idx in list_rem:
			_destroy_glyph(_active_glyphs[rem_idx])
	
	_active_glyphs.assign(new_active)
	
	if _active_glyphs.size() == 0:
		finished_morphing.emit.call_deferred()
	else:
		_relayout_animated()
