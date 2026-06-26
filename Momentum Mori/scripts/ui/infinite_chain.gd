@tool
class_name InfiniteChain extends TextureRect

enum Colour {
	RUST,
	NONE,
}

@export var colour := Colour.RUST

@warning_ignore("unused_private_class_variable")
@export_tool_button("update") var _btn := update

func _ready() -> void {
	update()
}

func update() -> void {
	match colour:
		Colour.RUST: 
			into(preload("res://assets/chain/tileable_chain.png"))
		Colour.NONE:
			into(preload("res://assets/chain/tileable_chain_uncoloured.png"))
}

func into(tex: Texture) -> void {
	texture = tex
	(material as ShaderMaterial).set_shader_parameter(&"tex", tex)
}
