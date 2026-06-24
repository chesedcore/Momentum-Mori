class_name Sword extends Projectile





func _on_visible_on_screen_notifier_2d_screen_exited() -> void{
	queue_free.call_deferred()
}


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage(5)
		EventBus.spawn_spark.emit(body)
		queue_free.call_deferred()
