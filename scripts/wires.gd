extends Interactable
const PowerType = PowerTypes.PowerType

@onready var sprite_3d: Sprite3D = $Sprite3D

var broken = false
var tutflag01 = false

func interact(by: Node) -> void:
	print("interacted once with wires")
	if by.dead == false:
		broken = true
	if (!tutflag01 and get_tree().current_scene.name == "Tutorial04"):
		Dialogic.start('tutorial_ele02')
		tutflag01 = true
		
	if broken and not by.dead:
		by.die(PowerType.ELECTRIC)
		sprite_3d.texture = load("res://images/wires_broken.png")
		
		
	
	
	
	
