extends Interactable

@onready var player: CharacterBody3D = $"../../../Player"
const PowerType = PowerTypes.PowerType

var sink_running: bool = false
var sink_fill: float = 0.0

func _process(delta: float) -> void:
	if sink_running and sink_fill < 1.0:
		sink_fill += delta * 0.1 # fill rate
		print("Sink filling... ", sink_fill)
		if sink_fill >= 1.0:
			sink_fill = 1.0
			sink_running = false
			print("Sink is full!")

func interact(by: Node) -> void:
	print("sink interact")
	
	if by.dead == false:
		print("interacted with sink, sink is now on since ur a human")
		sink_running = true
		# start filling the sink until it reaches 1.0



	
		
		
	else:
		print("nothing happens") 
