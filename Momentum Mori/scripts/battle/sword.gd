class_name Sword extends Projectile


var homing_time : float = 3
var turn_speed: float = 3.0 

func _on_visible_on_screen_notifier_2d_screen_exited() -> void{
	queue_free.call_deferred()
}


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage(5)
		EventBus.spawn_spark.emit(body)
		queue_free.call_deferred()



func _physics_process(delta: float) -> void {
	if homing_time > 0 {
		homing_time -= delta
		var target_angle = global_position.direction_to(target.global_position).angle()
		var current_angle = fire_dir.angle()
		var new_angle = lerp_angle(current_angle, target_angle, turn_speed * delta)
		fire_dir = Vector2.from_angle(new_angle)
		rotation = new_angle
	} 
	if is_firing {
		velocity = fire_dir * speed
		move_and_slide()
	}
}
