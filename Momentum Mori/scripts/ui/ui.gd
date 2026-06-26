class_name UI extends CanvasLayer

var field: Field
@export var time_rect: TimeRect
@export var black_bars: BlackBars

func setup_self_using_field(p_field: Field) -> void {
	field = p_field
	time_rect.field = field
	black_bars.setup_using_field(field)
}
