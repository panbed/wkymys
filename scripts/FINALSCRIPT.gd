extends Node

func _ready() -> void:
	Dialogic.start('FINAL_DIALOGUE')

func _process(delta: float) -> void:
	if (Dialogic.VAR.endGame):
		get_tree().quit()
