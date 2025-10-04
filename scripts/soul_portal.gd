extends Interactable
@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D


func interact(by: Node) -> void:
	if by.dead:
		var pos = global_transform.origin
		pos.y = 1.0
		by.last_safe_position = pos
		gpu_particles_3d.emitting = true
