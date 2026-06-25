extends SpinningProjectile


func _on_hitbox_body_entered(body: Node2D, extra_arg_0: int) -> void{
	if body is Player {
		body.take_damage(dmg)
		var projectile : Node2D = projectiles[extra_arg_0]
		projectile.queue_free.call_deferred()
		EventBus.spawn_spark.emit(body)
	}
	
}
