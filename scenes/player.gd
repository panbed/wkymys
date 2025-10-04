extends CharacterBody3D

@onready var death_timer: Timer = $DeathTimer
@onready var safe_after_death_timer: Timer = $SafeAfterDeathTimer
@onready var debug_label: Label3D = $DebugLabel
@onready var sprite_3d: Sprite3D = $Sprite3D
@onready var power_label: Label3D = $PowerLabel
@onready var raycast_3d: RayCast3D = $RayCast3D

@export var grid_map: GridMap
@export var lock_last_safe_pos: bool = false
@export var regular_speed := 5.0
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

# tiles that are wet, which will make the player run faster (or "slip")
var tiles_data: = {}
var dead: bool = false
var can_move: bool = true

var last_safe_position: Vector3 = Vector3.ZERO
var last_input_direction: Vector3 = Vector3.FORWARD

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
	var tile_pos = grid_map.local_to_map(global_transform.origin)
	tile_pos.y -= 1
	var tile_id = grid_map.get_cell_item(tile_pos)
	var tile_pos_str = vector3i_to_str(tile_pos)
	var on_wet = (dead == false) and tiles_data.has(tile_pos_str) and tiles_data[tile_pos_str] == "wet"
	#print("tile pos is: ", tile_pos)
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

	var target_speed = lerp(regular_speed, wet_speed, slip_amount)

	var hv := Vector2(velocity.x, velocity.z)
	var desired
	var rate
	if has_input:
		desired = Vector2(direction.x, direction.z) * target_speed
		rate = accel_ground
		last_input_direction = direction
	else:
		desired = Vector2.ZERO
		rate = decel_ground
	hv = hv.move_toward(desired, rate * get_physics_process_delta_time())
	velocity.x = hv.x
	velocity.z = hv.y


	if not lock_last_safe_pos:
		if tile_id == tile_names["water"]:
			# death_timer.start()
			die(PowerType.WATER)
		else:
			if death_timer.time_left == 0:
				# print("setting safe pos")
				last_safe_position = global_transform.origin

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# DEBUG button:
	if Input.is_action_just_pressed("debug"):
		die(PowerType.FIRE)

	# handle powers
	match active_power:
		PowerType.WATER:
			# leaving a trail of water will set that tile as wet
			if tile_pos is Vector3i:
				tiles_data[tile_pos_str] = "wet"

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
	print(death_type)

	# when we're a ghost we can phase through walls, so disable the "wall" mask
	self.set_collision_mask_value(2, false)
	active_power = death_type

func respawn():
	sprite_3d.texture = preload("uid://gfgffufbojyc")
	dead = false
	active_power = PowerType.NONE
	global_transform.origin = last_safe_position

	can_move = false
	safe_after_death_timer.start()


func debug_text(text: String, time: float = 1):
	debug_label.text = text
	await get_tree().create_timer(time).timeout
	debug_label.text = ""

func _on_safe_after_death_timer_timeout() -> void:
	can_move = true
	debug_text("can move again", 1)
