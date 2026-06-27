extends EnemyBlade

func die() -> void:
	queue_free.call_deferred()
