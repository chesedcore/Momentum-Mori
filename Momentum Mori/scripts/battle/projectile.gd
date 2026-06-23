class_name Projectile extends CharacterBody2D


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
