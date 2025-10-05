extends CharacterBody3D
class_name Player

@onready var death_timer: Timer = $DeathTimer
@onready var safe_after_death_timer: Timer = $SafeAfterDeathTimer
@onready var debug_label: Label3D = $DebugLabel
@onready var sprite_3d: AnimatedSprite3D = $AnimatedSprite3D
@onready var power_label: Label3D = $PowerLabel
@onready var raycast_3d: RayCast3D = $RayCast3D
@onready var shape_cast_3d: ShapeCast3D = $ShapeCast3D

@onready var water_particles: GPUParticles3D = $WaterParticles
@onready var fire_particles: GPUParticles3D = $FireParticles
@onready var lightning_particles: GPUParticles3D = $LightningParticles


# for tutorial dialogue
var firstTimeDead = false;

var puddle_scene := preload("res://scenes/puddle.tscn")
@export var grid_map: GridMap
@export var lock_last_safe_pos: bool = false
@export var speedConst = 5.0
@export var speed = speedConst
@export var wet_speed := 20.0
@export var accel_ground := 25.0
@export var decel_ground := 10.0
@export var slip_gain := 2.5
@export var slip_hold_time :=0.5
@export var slip_decay := 3.0

const PowerType = preload("uid://c7iq8laid2oq5").PowerType
var active_power: PowerType = PowerType.NONE
var slip_amount := 0.0
var slip_hold := 0.0
var gravity = 9.8
var tile_names = {
	"floor": 0,
	"stone": 7,
	"water": 9,
}
var dangerous_tiles: Array[String] = ["water"]
var tiles_data: = {}
var dead: bool = false
var can_move: bool = true

var last_safe_position: Vector3 = Vector3.ZERO
var last_input_direction: Vector3 = Vector3.FORWARD

var last_tile_pos: Vector3i = Vector3i(0, 0, 0)
var tile_pos: Vector3i = Vector3i(0, 0, 0)
var tile_id: int = -1
var tile_pos_str: String = ""

var current_anim: String = ""

func vector3i_to_str(v: Vector3i) -> String:
	return str(v.x) + "," + str(v.y) + "," + str(v.z)

func str_to_vector3i(s: String) -> Vector3i:
	var parts = s.split(",")
	if parts.size() != 3:
		# print("Invalid Vector3i string!")
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
	#if tile_names["water"] != tile_pos_id:
	puddle.global_transform.origin = world_pos + Vector3(0, 1.25, 0)
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

	var on_wet = (dead == false) and tiles_data.has(tile_pos_str) and tiles_data[tile_pos_str] == "wet"
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var has_input := direction.length_squared() > 0.0001
	if on_wet and has_input:
		slip_amount = min(1.0, slip_amount + slip_gain * get_physics_process_delta_time())
		slip_hold = slip_hold_time
	else:
		if slip_hold > 0.0:
			slip_hold -= get_physics_process_delta_time()
		else:
			slip_amount = max(0.0, slip_amount - slip_decay * get_physics_process_delta_time())

	var target_speed = lerp(speed, wet_speed, slip_amount)

	var hv := Vector2(velocity.x, velocity.z)
	var desired
	var rate
	if has_input:
		desired = Vector2(direction.x, direction.z) * target_speed
		rate = accel_ground
		last_input_direction = direction
		_update_flip_from_direction()
		
	else:
		desired = Vector2.ZERO
		rate = decel_ground
	_update_animation(has_input, Vector3(velocity.x, 0.0, velocity.z))
	hv = hv.move_toward(desired, rate * get_physics_process_delta_time())
	velocity.x = hv.x
	velocity.z = hv.y


	if not lock_last_safe_pos:
		if tile_id == tile_names["water"]:
			die(PowerType.WATER)
		else:
			if death_timer.time_left == 0:
				last_safe_position = global_transform.origin


	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

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

				if tile_pos != last_tile_pos:
					create_puddle(tile_pos)
					last_tile_pos = tile_pos

	# if the user presses the "death" button, die
	if Input.is_action_just_pressed("ghost"):
		die(PowerType.NONE)

	# also if the player presses the "interact" button, check if we hit something on the raycast3d
	if Input.is_action_just_pressed("interact"):
		print("interact pressed")
		if raycast_3d.is_colliding():
			print("raycast is colliding")
			var collider = raycast_3d.get_collider()
			print("collider: ", collider)
			print("interactable check: ",collider is Interactable)
			print("torch check:", collider is Torch)
			if collider is Interactable:
				(collider as Interactable).interact(self)
		elif shape_cast_3d.is_colliding():
			for ci in shape_cast_3d.get_collision_count():
				var collider = shape_cast_3d.get_collider(ci)
				print(collider)
				
				if collider is Interactable:
					(collider as Interactable).interact(self)
			
			
				
		# reset level
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	raycast_3d.target_position = last_input_direction.normalized() * 4.0

	if can_move == true:
		move_and_slide()

func _on_death_timer_timeout() -> void:
	# player died, start ghost timer
	self.set_collision_mask_value(2, true)
	# debug_text("alive again", 0.5)
	respawn()

func die(death_type: PowerType) -> void:
	if dead == true:
		return
		
	death_timer.start()
	dead = true
	current_anim = "float"
	sprite_3d.play("float")
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
			# print("back 2 nromal")
			return
		_:
			# print("idk")
			return

func stop_all_particles():
	water_particles.emitting = false
	fire_particles.emitting = false
	lightning_particles.emitting = false

func respawn():
	current_anim = "idle"
	sprite_3d.play("idle")
	dead = false
	active_power = PowerType.NONE
	global_transform.origin = last_safe_position

	stop_all_particles()

	can_move = false
	safe_after_death_timer.start()
	
	if (!firstTimeDead):
		firstTimeDead = true;
		print("FIRST TIME?")

func debug_text(text: String, time: float = 1):
	debug_label.text = text
	await get_tree().create_timer(time).timeout
	debug_label.text = ""

func _on_safe_after_death_timer_timeout() -> void:
	can_move = true
	# debug_text("can move again", 1)
	
func _pick_dir4(dir: Vector3) -> String:
	var v := Vector2(dir.x, dir.z)
	if v.length() < 0.001:
		return "idle"

	if abs(v.x) > abs(v.y):
		return "right" if v.x > 0.0 else "left"
	else:
		return "up" if v.y > 0.0 else "down"

func _update_animation(has_input: bool, move_vec: Vector3) -> void:
	if dead:
		if current_anim != "float":
			current_anim = "float"
			sprite_3d.play("float")
		return

	var anim := "walk" if has_input and move_vec.length() > 0.01 else "idle"
	if anim != current_anim:
		current_anim = anim
		sprite_3d.play(current_anim)

func _update_flip_from_direction():
	if dead:
		return
	# use last facing; only change when there's meaningful X
	var x := last_input_direction.x
	if abs(x) > 0.001:
		sprite_3d.flip_h = x < 0.0  # face left => flip_h = true
