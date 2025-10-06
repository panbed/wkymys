extends Node3D

@onready var player: CharacterBody3D = $Player

# func _ready() -> void:
# 	keypad.keypad_broken.connect(Callable(self, "keypad_broken"))

# func keypad_broken() -> void:
# 	print("deleting")e
# 	doors.queue_free()

func _on_next_level_portal_body_entered(body: Node3D) -> void:
	if body.name == "Player" and not player.dead:
		get_tree().change_scene_to_file("res://scenes/levels/level4a/level4_a.tscn")
