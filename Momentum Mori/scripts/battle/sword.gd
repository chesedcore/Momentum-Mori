class_name Sword extends CharacterBody2D

@export var speed: float = 600.0
var target: Node2D
var fire_dir: Vector2 = Vector2.ZERO
var is_firing: bool = false

func fire() -> void {
	if target {
		fire_dir = global_position.direction_to(target.global_position)
		rotation = fire_dir.angle()
		is_firing = true
	}
}

func _physics_process(delta: float) -> void {
	if is_firing {
		velocity = fire_dir * speed
		move_and_slide()
	}
}


func _on_visible_on_screen_notifier_2d_screen_exited() -> void{
	queue_free.call_deferred()
}


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage(5)
		queue_free.call_deferred()
