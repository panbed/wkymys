extends Node

@onready var player: Player = $Player
@onready var campfire: Node3D = $Campfire
@onready var torches: Node3D = $Torches

@onready var torchList = torches.get_children()

var litBothTorches: bool = false

func _ready() -> void:
	Dialogic.start('tutorial_fire01')
	player.speed = 0.0;

func _process(_delta) -> void:
	if (!Dialogic.VAR.playerMove):
		player.speed = 0.0;
	else:
		#player.speed = player.speedConst;
		player.speed = player.speedConst;
	
	if !litBothTorches and torchCheck():
		Dialogic.start("tutorial_fire03") # Start the dialogue when both are lit
		litBothTorches = true

func torchCheck():
	var t = torchList.all(func(t:Node3D): return t.find_child("Area3D").on_fire)
	# All torches are on fire
	return t
		
