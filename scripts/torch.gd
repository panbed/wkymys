extends Interactable
class_name Torch

@onready var player: Player = $"../../../Player"
@onready var torches: Node3D = $"../.."
const PowerType = preload("uid://c7iq8laid2oq5").PowerType
@onready var fire_particles: GPUParticles3D = $"../WoodPlanks2/Cube/FireParticles"

@onready var fire_timer: Timer = $"../FireTimer"


var on_fire: bool = false

func interact(by: Node) -> void:
	if !on_fire and by.dead == true and by.active_power == PowerType.FIRE:
		ignite()
	if on_fire and by.dead == true and by.active_power == PowerType.WATER:
		extinguish()

func ignite() -> void:
	on_fire = true
	fire_particles.emitting = true
	
func extinguish() -> void:
	on_fire = false
	fire_particles.emitting = false
	if (get_tree().current_scene.name == "Tutorial03"):
		Dialogic.start('tutorial_water03')
	
