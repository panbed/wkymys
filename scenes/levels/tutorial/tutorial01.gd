extends Node

# need to make dialogue pause and then continue once player moves around a bit

@onready var player: Player = $Player

const SOUL_PORTAL = preload("uid://b0nekt6asltut")
var node := SOUL_PORTAL.instantiate()

var secondTutorial: bool = false

func _ready() -> void:
	Dialogic.start('tutorial')
	# Dialogic.paused = true
	player.speed = 0.0;
	
func _process(delta) -> void:
	if (!Dialogic.VAR.playerMove):
		player.speed = 0.0;
	else:
		player.speed = 5.0;
		
	if (player.firstTimeDead and !secondTutorial):
		Dialogic.start('tutorial2')
		secondTutorial = true
		
	if (Dialogic.VAR.soulPortalReveal):
		Dialogic.VAR.soulPortalReveal = false
		spawnSoulPortal()
		
	if (node.firstTimeEnter and node.firstTimeEnterFlag):
		node.firstTimeEnterFlag = false
		Dialogic.start('timeline3')
	
func spawnSoulPortal() -> void:
	node.set_name("SoulPortal")
	add_child(node)
	node.global_transform.origin = Vector3(2.132, 0.011, 6.26)
