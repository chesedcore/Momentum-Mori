class_name Blade extends CharacterBody2D

@export var hp : float = 100
@export var base_dmg : float = 10
@export var blade_animator: BladeAnimator
var movement_locked := false

var angle: float = 0.0

var rpm: float = 2000

var recoil_time: float = 0.0
var recoil_velocity: Vector2 = Vector2.ZERO

@warning_ignore("unused_signal")
signal died

func apply_recoil(dir: Vector2, force: float, duration: float) -> void {
	var shake_force : float=  remap(force,300,1200,0.1,1)
	blade_animator.shake(shake_force)
	recoil_velocity = dir.normalized() * force
	recoil_time = duration
}

func take_damage(dmg : float ) -> void {
	#prints(name,hp,dmg)
	hp -= dmg
	if hp <= 0 {
		die()
	}
}

func die() -> void {
	died.emit()
	queue_free.call_deferred()
}
