class_name BladeHPBar extends TextureProgressBar

@onready var blade: Blade = owner
@onready var start_color: Color = modulate


func _ready() -> void {
	max_value = blade.hp
	blade.damaged.connect(trigger_show)
}


func _process(delta: float) -> void {
	update(delta)
}


func update(delta: float) -> void {
	value = lerpf(value, blade.hp, 10.0 * delta)
	modulate.a = lerpf(modulate.a, 0.0, 2.0 * delta)
}


func trigger_show() -> void {
	modulate = start_color
}
