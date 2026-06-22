class_name Blade extends CharacterBody2D

var rpm: float = 2000


var recoil_time: float = 0.0
var recoil_velocity: Vector2 = Vector2.ZERO

func apply_recoil(dir: Vector2, force: float, duration: float) -> void {
	recoil_velocity = dir.normalized() * force
	recoil_time = duration
}
