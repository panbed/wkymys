extends Node

@onready var player: Player = $Player
@onready var doors: Node = $Doors
@onready var keypad: Node3D = $Interactables/Keypad/Area3D
@onready var stop_door: Node3D = $Doors/StopDoor


func _ready() -> void:
	Dialogic.start('tutorial_ele01')
	Dialogic.signal_event.connect(_on_dialogic_signal)
	player.speed = 0.0;
	keypad.keypad_broken.connect(Callable(self, "keypad_broken"))

func _process(_delta) -> void:
	if (!Dialogic.VAR.playerMove):
		player.speed = 0.0;
	else:
		#player.speed = player.speedConst;
		player.speed = player.speedConst;

func keypad_broken() -> void:
	Dialogic.start('tutorial_ele03')
	doors.queue_free()

func _on_dialogic_signal(argument: String):
	if argument == "water_done":
		stop_door.queue_free()
		


func _on_next_level_portal_body_entered(body: Node3D) -> void:
	# same thing over here..........
	if body.is_in_group("player") and not player.dead:
		get_tree().change_scene_to_file("res://scenes/levels/level3/level3.tscn")
		
