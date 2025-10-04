extends Interactable

@export var goto_scene: String

func interact(by: Node) -> void:
	if by.dead == false:
		# only allow player to enter door if theyre in the mortal form
		get_tree().change_scene_to_file(goto_scene)
