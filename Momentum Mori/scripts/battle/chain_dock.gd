class_name ChainDock extends Node2D

static func raycast_for_collidables(
	anchor: Node2D, 
	start: Vector2, 
	end: Vector2, 
	scan_mask: int = 0xFFFF_FFFF
) -> Option[PhysicsBody2D] {
	var space_state := anchor.get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(start, end, scan_mask)
	
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var res := space_state.intersect_ray(query)
	if not res: return Option.none()
	if not res.collider: return Option.none()
	if res.collider is not PhysicsBody2D: return Option.none()
	return Option.some(res.collider)
}

func summon_chain(from: Vector2, to: Vector2) -> void {
	var angle_to_end := from.angle_to_point(to)
	var chain := Registry.create_chain_whip()
	self.add_child(chain)
	chain.rotation = angle_to_end
	chain.global_position = from
}
