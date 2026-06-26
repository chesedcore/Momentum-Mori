class_name MenuRect extends Control

@export var menu_element_cascade: CascadeV3
@export var trigger_rect: ColorRect
@export var title_cascades: Array[CascadeV3]
@export var button_cascade: CascadeV3

func _ready() -> void {
	_wire_up_signals()
}

func _wire_up_signals() -> void {
	menu_element_cascade.cascade_in_finished_for_node.connect(
		_on_cascade_started_for_node
	)
	menu_element_cascade.cascade_in_chain_finished.connect(
		button_cascade.cascade_in
	)
}

func _on_cascade_started_for_node(node: Node) -> void {
	if node == trigger_rect {
		title_cascades.map(
			func(c: CascadeV3): c.cascade_in()
		)
	}
}

func unroll() -> void {
	menu_element_cascade.cascade_out()
	title_cascades.map(func(c: CascadeV3): c.cascade_out())
	button_cascade.cascade_out()
}

func roll() -> void {
	menu_element_cascade.cascade_in()
}
