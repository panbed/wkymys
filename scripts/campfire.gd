extends Node

@onready var player: Player = $"../../Player"

@onready var fire_particles: GPUParticles3D = $"../Sprite3D/FireParticles"
@onready var smoke_particles: GPUParticles3D = $"../Sprite3D/SmokeParticles"

const PowerType = PowerTypes.PowerType
var firstTimeEnter = false
var firstTimeEnterFlag = false

var fire_active = true

func _ready() -> void:
	smoke_particles.emitting = true
	fire_particles.emitting = true
	
func _on_body_entered(body: Node3D) -> void:
	if (body.is_in_group("player") and !body.dead):
		if (!firstTimeEnter and !firstTimeEnterFlag):
			firstTimeEnter = true;
			firstTimeEnterFlag = true;
			Dialogic.start('tutorial_fire02')
		body.die(PowerType.FIRE)
		body.last_safe_position = Vector3(-11.33,1.489,6.184)
