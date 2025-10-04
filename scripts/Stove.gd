extends Interactable

@onready var player: CharacterBody3D = $"../../../Player"
@onready var fire_particles: GPUParticles3D = $"../Sprite3D/FireParticles"
@onready var smoke_particles: GPUParticles3D = $"../Sprite3D/SmokeParticles"

const PowerType = PowerTypes.PowerType

var oven_on = false
var fire_active = false

#func _on_body_entered(body: Node3D) -> void:
	#if body.is_in_group("player"):
		#print("player entered")
		#if player.dead == false and fire_active == true:
			## player is alive, kill them if they get too close lol
			#player.die(PowerType.FIRE)

func interact(by: Node) -> void:
	if by.dead == false:
		if fire_active:
			by.die(PowerType.FIRE)
		else:
			if oven_on == false:
				oven_on = true
				print("oven is now on..")
				smoke_particles.emitting = true
			print("nothing happens!")
	elif by.dead == true and by.active_power == PowerType.WATER and oven_on:
		print("the oven explodes!")
		fire_particles.emitting = true
		fire_active = true
		
