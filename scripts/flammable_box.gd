extends Interactable

@onready var player: CharacterBody3D = $Player
const PowerType = PowerTypes.PowerType
@onready var fire_particles: GPUParticles3D = $"../WoodPlanks2/Cube/FireParticles"

@onready var fire_timer: Timer = $"../FireTimer"


var on_fire: bool = false

func interact(by: Node) -> void:
	print("interacted with flammable box...")
	if on_fire:
		print("box on fire already, do nothing")
		return

	if by.dead == true and by.active_power == PowerType.FIRE:
		ignite()
	else:
		print("nothing	 happens")

func ignite() -> void:
	on_fire = true
	fire_particles.emitting = true
	fire_timer.start()
	print("Box is on fire!")


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		if body.active_power == PowerType.FIRE:
			ignite()
