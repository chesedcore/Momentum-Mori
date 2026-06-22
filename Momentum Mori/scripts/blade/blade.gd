class_name Blade extends CharacterBody2D

@export var hp : float = 100
@export var base_dmg : float = 10
@export var blade_animator: BladeAnimator
var angle: float = 0.0

var rpm: float = 2000

var recoil_time: float = 0.0
var recoil_velocity: Vector2 = Vector2.ZERO

func apply_recoil(dir: Vector2, force: float, duration: float) -> void {
	blade_animator.shake(randf_range(0.5, 2.5))
	recoil_velocity = dir.normalized() * force
	recoil_time = duration
}

func take_damage(dmg : float ) -> void {
	prints(name,hp,dmg)
	hp -= dmg
	if hp <= 0 {
		die()
	}
}

func die() -> void {
	queue_free.call_deferred()
}
