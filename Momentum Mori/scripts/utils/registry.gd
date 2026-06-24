class_name Registry

static func create_chain_whip() -> ChainWhip {
	return preload("res://scenes/battle/repeating_chain.tscn").instantiate()
}
