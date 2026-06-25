class_name SpinningProjectile extends Projectile

@export var projectile_holder: CascadeV3

@export var spin_speed : float = 2.5

@export var movement_time : float = 2.5

@export var expansion_speed : float = 100

@export var life_time: float = 10


func _physics_process(delta: float) -> void{
	
	projectile_holder.rotation += spin_speed * delta
	#move in the direction of the target for bit
	if is_firing and movement_time > 0 {
		velocity = fire_dir * speed
		move_and_slide()
		movement_time -= delta
		
	}
	#Now EXPANNDDDDD
	elif movement_time <= 0{
		for projectile :Node2D in projectile_holder.get_children(){
			projectile.position += projectile.position.normalized() * expansion_speed * delta
			
		}
		#but die eventually
		life_time -= delta
		if life_time <= 0:
			queue_free.call_deferred() 
	}
	
}

var projectiles : Array[Node]

func _ready() -> void:
	projectiles = projectile_holder.get_children()
	projectile_holder.cascade_in()

@export var dmg : float = 5

func _on_hitbox_body_entered(body: Node2D, extra_arg_0: int) -> void{
	if body is Player {
		body.take_damage(dmg)
		var projectile : Node2D = projectiles[extra_arg_0]
		projectile.queue_free.call_deferred()
		EventBus.spawn_spark.emit(body)
	}
	
}
