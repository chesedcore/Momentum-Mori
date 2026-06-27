class_name AngryBoss extends EnemyBlade

var teleport_cooldown : float = 4
var remaining_teleport_cooldown : float = 0


@export var teleport_threshold: float = 0.75

@export var teleport_distance: float = 400

@export var teleport_world_radius: float = 4900


@export var teleport_min_distance: float = 300
@export var teleport_max_distance: float = 800


func  _ready() -> void{
	super._ready()

}

func _physics_process(delta: float) -> void{

	if remaining_teleport_cooldown >= teleport_cooldown{
		# check the targets velocity to see if its heading towards this blade and teleport this blade behhind  the target
		var target_velocity = target.velocity
		if target_velocity.length() > 0{
			var target_move_dir = target_velocity.normalized()
			var to_self = target.global_position.direction_to(global_position)
			var dot = target_move_dir.dot(to_self)
			var dist = global_position.distance_to(target.global_position)
			if dot >= teleport_threshold and dist >= teleport_min_distance and dist <= teleport_max_distance{
				teleport_behind_target()
				remaining_teleport_cooldown = 0
			}
		}
	}
	remaining_teleport_cooldown += delta

	super._physics_process(delta)

}
@onready var circle: Circle = $Incline/Visual/Visual/Control/Circle

func teleport_behind_target() -> void{
	var flash_tween = create_tween()
	flash_tween.tween_property(circle,"modulate",Color.WHITE,0.05)
	await  flash_tween.finished
	var target_move_dir :Vector2= target.velocity.normalized()
	var teleport_position := target.global_position - target_move_dir * teleport_distance
	
	if teleport_position.distance_to(Vector2.ZERO) > teleport_world_radius{
		var unflash_tween = create_tween()
		unflash_tween.tween_property(circle, "modulate", Color.RED, 0.05)
		return
	}
	global_position = teleport_position
	var to_target = global_position.direction_to(target.global_position)
	change_to_attack(to_target)
	var unflash_tween = create_tween()
	unflash_tween.tween_property(circle,"modulate",Color.RED,0.05)
}
