extends Node

@onready var player: Player = $Player
@onready var torch: Node3D = $Torch

var isWater = false

func _ready() -> void:
	Dialogic.start('tutorial_water01')
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
