extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var doors: Node = $Doors
@onready var keypad: Node3D = $Map/Keypad/Area3D



# func _ready() -> void:
# 	keypad.keypad_broken.connect(Callable(self, "keypad_broken"))

# func keypad_broken() -> void:
# 	print("deleting")e
# 	doors.queue_free()

#func _ready() -> void:
	#if Dialogic.current_timeline != null:
		#return
	#
	#Dialogic.start('tutorial')
	#

var start_pos: Vector3

func _ready() -> void:
	start_pos = player.global_position
	keypad.keypad_broken.connect(Callable(self, "keypad_broken"))

func keypad_broken() -> void:
	print("deleting")
	doors.queue_free()

func _on_next_level_portal_body_entered(body: Node3D) -> void:
	if body.name == "Player" and not player.dead:
		get_tree().change_scene_to_file("res://scenes/world.tscn")


func _on_death_area_body_entered(body: Node3D) -> void:
	player.global_position = start_pos
