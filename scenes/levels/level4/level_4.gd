extends Node3D
@onready var timer: Timer = $Map/water/Timer
@onready var player: CharacterBody3D = $Player
@onready var sprite_3d: AnimatedSprite3D = $Player/AnimatedSprite3D
@onready var siren_mesh: MeshInstance3D = $Map/siren/SirenMEsh
@onready var siren_audio: AudioStreamPlayer = $Map/siren/SirenMEsh/AudioStreamPlayer
const fail_sound = preload("uid://darn4rocoywow")
const success_sound = preload("uid://d1tiikc6urbp8")
var done :=false
@onready var water: MeshInstance3D = $Map/water
@onready var cylinder: MeshInstance3D = $Map/bullseye/Cylinder
@onready var crusty_fridge: Node3D = $Interactables/crustyFridge/Cube/Area3D
@export var freeze_time := 1.0
var frozen := false
var speed_threshold: float = 10.0
var is_fridge_fixed := false

@export var success_color: Color = Color(0.2, 1.0, 0.2)
@export var fail_color: Color = Color(1.0, 0.25, 0.25)
@export var flash_count := 6
@export var flash_period := 0.12
@export var emission_energy := 1.8
var _siren_mat: StandardMaterial3D

func _ready() -> void:
	print("ready")
	var mat := water.get_active_material(0) as ShaderMaterial
	var tw:= create_tween()
	mat.set_shader_parameter("freeze", 0.0)
	crusty_fridge.freeze_water.connect(Callable(self, "freeze_water"))
	if Dialogic.current_timeline != null:
		return
	Dialogic.start('waterFreeze')
	player.last_safe_position = player.global_position

	
func _process(delta: float) -> void:
	pass
	
	

func _on_area_3d_body_entered(body: Node3D) -> void:
	print("area entered")
	if body.name == "Player":
		print("players power type ", body.PowerType)
		if body.dead and body.active_power == PowerTypes.PowerType.FREEZE:
			water.static_body_3d.collision_layer= 1
			frozen = true
			sprite_3d.render_priority =1
			animate_freeze()
			#do some shit with the shader
			
		else:
			print("HELP")
			body.gravity = 1
			timer.start()
		


func _on_timer_timeout() -> void:
	print("we start time")
	player.die(PowerTypes.PowerType.WATER)
	player.global_position = player.last_safe_position
	timer.stop()
	


func _on_bullseye_ran_into(body: Node3D) -> void:
	if body.name == "Player":
		var wall_normal: Vector3 = -cylinder.global_basis.z.normalized()
		var impact_speed: Vector3 = (body as CharacterBody3D).velocity
		var speed := impact_speed.dot(wall_normal)
		print("speed is :" , speed)
		if speed >= speed_threshold and not done:
			print("WE DID IT")
			is_fridge_fixed = true
			crusty_fridge.is_fixed = true
			siren_audio.stream = success_sound
			siren_audio.play()
			pulse_green()
			#play a good sound and make siren flash green
			
		elif not done:
			pass
			#play a sound and make siren flash red
			pulse_red()
			siren_audio.stream = fail_sound
			siren_audio.play()
			
		
		
func freeze_water() -> void:
	#water.static_body_3d.collision_layer= 1
	player.active_power = PowerTypes.PowerType.FREEZE
	print("player active power is : ", player.active_power)
	
func animate_freeze():
	print("animating")
	var mat := water.get_active_material(0) as ShaderMaterial
	if mat == null: 
		push_warning("not a shader amterial wtf")
		return
	
	var tw:= create_tween()
	tw.tween_method(func(v): mat.set_shader_parameter("freeze", v), 0.0, 1.0, freeze_time)


func pulse_red():
	var mat = siren_mesh.get_active_material(1)
	siren_mesh.set_surface_override_material(1, mat)
	mat.albedo_color = Color(0.941, 0.0, 0.0, 1.0)
	
	
func pulse_green():
	done = true
	var mat = siren_mesh.get_active_material(1)
	siren_mesh.set_surface_override_material(1, mat)
	mat.albedo_color = Color(0.0, 0.604, 0.268, 1.0)
