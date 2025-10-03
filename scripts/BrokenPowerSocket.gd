extends Interactable

const PowerType = preload("uid://c7iq8laid2oq5").PowerType

func interact(by: Node) -> void:
	print("activated broken power socket, player will die...")
	if by.has_method("die"):
		(by as Node).die(PowerType.ELECTRIC) # player will die by electric shock
