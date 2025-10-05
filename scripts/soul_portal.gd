extends Interactable
@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D

var firstTimeEnter = false;
var firstTimeEnterFlag = false;

func interact(by: Node) -> void:
	if by.dead:
		var pos = global_transform.origin
		pos.y = 1.0
		by.last_safe_position = pos
		gpu_particles_3d.emitting = true


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		if body.dead:
			var pos = global_transform.origin
			pos.y = 1.0
			body.last_safe_position = pos
			gpu_particles_3d.emitting = true
			if (!firstTimeEnter and !firstTimeEnterFlag):
				firstTimeEnter = true;
				firstTimeEnterFlag = true;
				
