extends Interactable

func interact(by: Node) -> void:
	if by.dead:
		var pos = global_transform.origin
		pos.y = 1.0
		by.last_safe_position = pos
