extends CharacterBody3D

const PowerType = preload("uid://c7iq8laid2oq5").PowerType
var active_power: PowerType = PowerType.NONE
@export var grid_map: GridMap
@onready var death_timer: Timer = $DeathTimer
@onready var safe_after_death_timer: Timer = $SafeAfterDeathTimer
@onready var debug_label: Label3D = $DebugLabel
@onready var sprite_3d: Sprite3D = $Sprite3D
@onready var power_label: Label3D = $PowerLabel
@onready var raycast_3d: RayCast3D = $RayCast3D

@onready var water_particles: GPUParticles3D = $WaterParticles
@onready var fire_particles: GPUParticles3D = $FireParticles
@onready var lightning_particles: GPUParticles3D = $LightningParticles


var puddle_scene := preload("res://scenes/puddle.tscn")

var tile_names = {
	"floor": 0,
	"stone": 7,
	"water": 9,
}

var dangerous_tiles: Array[String] = ["water"]

# tiles that are wet, which will make the player run faster (or "slip")
var tiles_data: = {}

@export var speed = 5.0
@export var acceleration = 10.0
@export var friction = 15.0

var dead: bool = false
var can_move: bool = true

var last_safe_position: Vector3 = Vector3.ZERO
var last_input_direction: Vector3 = Vector3.FORWARD

var last_tile_pos: Vector3i = Vector3i(0, 0, 0)
var tile_pos: Vector3i = Vector3i(0, 0, 0)
var tile_id: int = -1
var tile_pos_str: String = ""
	
func vector3i_to_str(v: Vector3i) -> String:
	return str(v.x) + "," + str(v.y) + "," + str(v.z)
	
func str_to_vector3i(s: String) -> Vector3i:
	var parts = s.split(",")
	if parts.size() != 3:
		print("Invalid Vector3i string!")
		return Vector3.ZERO
	
	var x = int(parts[0])
	var y = int(parts[1])
	var z = int(parts[2])
	return Vector3i(x, y, z)
	
func create_puddle(tile_pos: Vector3i):
	var puddle = puddle_scene.instantiate()
	var world_pos = grid_map.map_to_local(tile_pos)
	var tile_pos_id = grid_map.get_cell_item(world_pos)
	
	print(tile_pos_id)
	if tile_names["water"] != tile_pos_id:
		puddle.global_transform.origin = world_pos + Vector3(0, 2, 0)
		get_parent().add_child(puddle)
	

func _physics_process(delta: float) -> void:
	# DEBUG: change text of power label
	match active_power:
		PowerType.NONE:
			power_label.text = "None"
		PowerType.FIRE:
			power_label.text = "Fire"
		PowerType.WATER:
			power_label.text = "Water"
		PowerType.ELECTRIC:
			power_label.text = "Electric"
		_:
			power_label.text = "????????"

	# get the current tile underneath the player
	if grid_map != null:
		tile_pos = grid_map.local_to_map(global_transform.origin)
		tile_pos.y -= 1
		tile_id = grid_map.get_cell_item(tile_pos)
		
		if tile_id == tile_names["water"]:
			# death_timer.start()
			die(PowerType.WATER)
		else:
			if death_timer.time_left == 0:
				# print("setting safe pos")
				last_safe_position = global_transform.origin
	
	# Add the gravity.
	if not is_on_floor():
		print("not on floor")
		print("delta is ", delta)
		velocity.y -= 9.8 * delta
		print("velocity.y is ", velocity.y)
		
	if grid_map != null:
		tile_pos_str = vector3i_to_str(tile_pos)

	# DEBUG button:
	if Input.is_action_just_pressed("debug"):
		die(PowerType.FIRE)
		
	# handle powers
	match active_power:
		PowerType.WATER:
			# leaving a trail of water will set that tile as wet
			if grid_map != null and tile_pos is Vector3i:
				tiles_data[tile_pos_str] = "wet"
				print(tile_pos)
				print(last_tile_pos)
				if tile_pos != last_tile_pos:
					create_puddle(tile_pos)
					last_tile_pos = tile_pos
					
			
	
	if dead == false and grid_map != null and tile_pos_str in tiles_data and tiles_data[tile_pos_str] == "wet":
		speed = 10.0
		friction = 1.0
	else:
		speed = 5.0
		friction = 15.0

	# if the user presses the "death" button, die
	if Input.is_action_just_pressed("ghost"):
		die(PowerType.NONE)

	# also if the player presses the "interact" button, check if we hit something on the raycast3d
	if Input.is_action_just_pressed("interact"):
		print("interact pressed")
		if raycast_3d.is_colliding():
			print("raycast is colliding")
			var collider = raycast_3d.get_collider()
			print(collider)
			if collider is Interactable:
				(collider as Interactable).interact(self)
				
	# reset level
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
		
	# get the input direction and handle the movement/deceleration,
	# as well as change the raycast direction to match the last input direction
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var bedVelocity
	if not dead:
		if direction.length_squared() > 0.001:
			last_input_direction = direction
			#IF YOU COMMENT OUT THESE 2 LIENS BELOW, GRAVITY WILL ONLY WORK WHEN TAPPING MOVEMENT
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			#velocity = velocity.move_toward(direction * speed, speed)
		else:
			#IF YOU COMMENT OUT THESE 2 LIENS BELOW, GRAVITY WILL ONLY WORK WHEN TAPPING MOVEMENT
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
			#velocity = velocity.move_toward(Vector3.ZERO, friction * delta)
	else:
		if direction.length_squared() > 0.001:
			last_input_direction = direction
			#IF YOU COMMENT OUT THESE 2 LIENS BELOW, GRAVITY WILL ONLY WORK WHEN TAPPING MOVEMENT
			#velocity.x = direction.x * speed
			#velocity.z = direction.z * speed
			bedVelocity = velocity.move_toward(direction * speed, speed)
		else:
			#IF YOU COMMENT OUT THESE 2 LIENS BELOW, GRAVITY WILL ONLY WORK WHEN TAPPING MOVEMENT
			#velocity.x = move_toward(velocity.x, 0, speed)
			#velocity.z = move_toward(velocity.z, 0, speed)
			bedVelocity = velocity.move_toward(Vector3.ZERO, friction * delta)
	#PRESERVE GRAVITY(velocity.y) WITH THE BED VAR
	if bedVelocity:
		velocity.x = bedVelocity.x
		velocity.z = bedVelocity.z
	raycast_3d.target_position = last_input_direction.normalized() * 4.0

	if can_move == true:
		move_and_slide()

func _on_death_timer_timeout() -> void:
	# player died, start ghost timer
	self.set_collision_mask_value(2, true)
	debug_text("alive again", 0.5)
	respawn()
	
func die(death_type: PowerType) -> void:
	if dead == true:
		return

	death_timer.start()
		
	# set sprite to ghost
	sprite_3d.texture = preload("uid://bv8fju4tqp14c")
		
	dead = true
	debug_text("died")
	
	# when we're a ghost we can phase through walls, so disable the "wall" mask
	self.set_collision_mask_value(2, false)
	
	active_power = death_type
	
	match death_type:
		PowerType.WATER:
			print("water ,,")
			water_particles.emitting = true
		PowerType.ELECTRIC:
			print("electric death")
			lightning_particles.emitting = true
		PowerType.FIRE:
			print("fir.")
			fire_particles.emitting = true
		PowerType.NONE:
			print("back 2 nromal")
		_:
			print("idk")

func stop_all_particles():
	water_particles.emitting = false
	fire_particles.emitting = false
	lightning_particles.emitting = false

func respawn():
	sprite_3d.texture = preload("uid://gfgffufbojyc")
	dead = false
	active_power = PowerType.NONE
	global_transform.origin = last_safe_position
	
	stop_all_particles()
	
	can_move = false
	safe_after_death_timer.start()
	
func debug_text(text: String, time: float = 1):
	debug_label.text = text
	await get_tree().create_timer(time).timeout
	debug_label.text = ""

func _on_safe_after_death_timer_timeout() -> void:
	can_move = true
	debug_text("can move again", 1)
