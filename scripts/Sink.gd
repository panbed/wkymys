extends Interactable

#@onready var player: CharacterBody3D = $"../../../Player"
const PowerType = PowerTypes.PowerType

var sink_running: bool = false
var sink_fill: float = 0.0

func _process(delta: float) -> void:
	if sink_running and sink_fill < 1.0:
		sink_fill += delta * 0.25 # fill rate
		print("sink filling... ", sink_fill)
		if sink_fill >= 1.0:
			sink_fill = 1.0
			sink_running = false
			print("sink is full!")

func interact(by: Node) -> void:
	print("sink interact")
	
	if by.dead == false:
		print("interacted with sink, sink is now on since ur a human")
		sink_running = true

		if sink_fill >= 1.0:
			by.die(PowerType.WATER)
	else:
		print("you cant do anything since youre a ghost")
