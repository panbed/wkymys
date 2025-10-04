extends MeshInstance3D

@onready var static_body_3d: StaticBody3D = $StaticBody3D

var is_frozen := false

func interact(by: Node) -> void:
	print("interacted with flammable box...")
	if is_frozen:
		print("box on fire already, do nothing")
		return

	if by.dead == true and by.active_power == PowerTypes.PowerType.FREEZE:
		freeze_water()
	else:
		print("nothing	 happens")
		
func freeze_water():
	print("making water collision 1")
	static_body_3d.collision_layer= 1
