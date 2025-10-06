extends Node

@onready var player: Player = $Player
@onready var campfire: Node3D = $Campfire
@onready var torches: Node3D = $Torches
@onready var stop_door: Node3D = $StopDoor


@onready var torchList = torches.get_children()

var litBothTorches: bool = false

func _ready() -> void:
	Dialogic.start('tutorial_fire01')
	Dialogic.signal_event.connect(_on_dialogic_signal)
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
		

#func delete_doors():
	#if stop_door:
		#queue_free()

func torchCheck():
	var t = torchList.all(func(t:Node3D): return t.find_child("Area3D").on_fire)
	# All torches are on fire
	return t
	
func _on_dialogic_signal(argument: String):
	if argument == "fire_finished":
		stop_door.queue_free()
		


func _on_next_level_body_entered(body: Node3D) -> void:
	# this could probably be a scene but im too lazy
	if body.is_in_group("player") and not player.dead:
		get_tree().change_scene_to_file("res://scenes/levels/tutorial/tutorial03.tscn")
