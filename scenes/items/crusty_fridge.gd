extends Interactable

@onready var area_3d: Area3D = $Cube/Area3D
var is_fixed: bool = false
signal freeze_water()

func interact(by: Node) -> void:
	print("interacted with fridge")
	if is_fixed:
		by.die(PowerTypes.PowerType.FREEZE)
		emit_signal("freeze_water")
