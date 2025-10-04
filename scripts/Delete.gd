extends Node

func _on_fire_timer_timeout() -> void:
	queue_free()
