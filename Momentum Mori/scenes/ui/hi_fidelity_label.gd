class_name HFLabel extends HiFidelityLabel

var field: Field

func setup_using_field(p_field: Field) -> void {
	field = p_field
	self.immediately_set_text("Spin Focus")
	field.started_adrenaline.connect(self.morph_into.bind("Take Your Time"))
	field.stopped_adrenaline.connect(self.morph_into.bind("Spin Focus"))
}

func _ready() -> void {
	super()
}
