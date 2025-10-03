extends Area3D
class_name Interactable

signal interacted(by)

func interact(by: Node) -> void:
	emit_signal("interacted", by)
