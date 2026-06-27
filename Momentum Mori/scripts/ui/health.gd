class_name Health extends Control

var field: Field
@export var arr_text: Array[RichTextLabel]
@export var health: ColorRect
@export var health_underbar: ColorRect
@export var speed: float = 40

func setup(p_field: Field) -> void {
	field = p_field
}

func _process(delta: float) -> void {
	health.rotation_degrees += delta * speed
	health_underbar.rotation_degrees += delta * speed * 2
	for lbl in arr_text {
		lbl.text = str(int(field.stadium.get_player().hp))
	}
}
