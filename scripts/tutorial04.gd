extends Node

@onready var player: Player = $Player
@onready var doors: Node = $Doors
@onready var keypad: Node3D = $Interactables/Keypad/Area3D

func _ready() -> void:
	Dialogic.start('tutorial_ele01')
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
