extends Node

@onready var player: Player = $Player
@onready var torch: Node3D = $Torch
@onready var stop_door: Node3D = $StopDoor


var isWater = false

func _ready() -> void:
	Dialogic.start('tutorial_water01')
	Dialogic.signal_event.connect(_on_dialogic_signal)
	player.speed = 0.0;
	torch.find_child("Area3D").ignite()


func _process(_delta) -> void:
	if (!Dialogic.VAR.playerMove):
		player.speed = 0.0;
	else:
		#player.speed = player.speedConst;
		player.speed = player.speedConst;
	
	if (!isWater and player.active_power == player.PowerType.WATER):
		isWater = true
		Dialogic.start('tutorial_water02')


func _on_next_level_portal_body_entered(body: Node3D) -> void:
	# same thing over here..........
	if body.is_in_group("player") and not player.dead:
		get_tree().change_scene_to_file("res://scenes/levels/tutorial/tutorial04.tscn")
		
		
func _on_dialogic_signal(argument: String):
	if argument == "water_done":
		stop_door.queue_free()
		
