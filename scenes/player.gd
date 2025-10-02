extends CharacterBody3D

@export var grid_map: GridMap
@onready var death_timer: Timer = $DeathTimer
@onready var debug_label: Label3D = $DebugLabel

var tile_names = {
	"floor": 0,
	"stone": 7,
	"water": 9,
}

var dangerous_tiles: Array[String] = ["water"]

# tiles that are wet, which will make the player run faster (or "slip")
var wet_tiles: = {}

@export var speed = 5.0
@export var acceleration = 10.0
@export var friction = 15.0

var dead: bool = false
var last_safe_position: Vector3 = Vector3.ZERO

func _physics_process(delta: float) -> void:
	# get the current tile underneath the player
	var tile_pos = grid_map.local_to_map(global_transform.origin)
	tile_pos.y -= 1
	var tile_id = grid_map.get_cell_item(tile_pos)
	
	if tile_id == tile_names["water"]:
		death_timer.start()
		die("")
	else:
		if death_timer.time_left == 0:
			print("setting safe pos")
			last_safe_position = global_transform.origin
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction.length_squared() > 0.001:
		#velocity.x = direction.x * speed
		#velocity.z = direction.z * speed
		velocity = velocity.move_toward(direction * speed, speed)
	else:
		#velocity.x = move_toward(velocity.x, 0, speed)
		#velocity.z = move_toward(velocity.z, 0, speed)
		velocity = velocity.move_toward(Vector3.ZERO, friction * delta)

	move_and_slide()
		
func _on_death_timer_timeout() -> void:
	# player died, start ghost timer
	self.set_collision_mask_value(2, true)
	debug_text("alive again")
	respawn()
	
	
func die(death_type: String) -> void:
	if dead == true:
		print("you cant die again bro")
		return
		
	dead = true
	debug_text("died")
	
	self.set_collision_mask_value(2, false)
	match death_type:
		"water":
			print("water death")
		_:
			print("idk")
			
func respawn():
	dead = false
	global_transform.origin = last_safe_position
	
func debug_text(text: String):
	debug_label.text = text
	await get_tree().create_timer(1.0).timeout
	debug_label.text = ""
	
	
