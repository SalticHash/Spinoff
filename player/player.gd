extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5


func get_angle(angle: float):
	var a = rad_to_deg(angle_difference(0.0, deg_to_rad(angle)) + PI)
	#$Sprite.rotation_degrees.y = 
	$Sprite.rotation_degrees = Vector3(0, snappedf(angle, 45.0), 0)
	match snappedf(a, 45.0):
		0.0: return "north"
		45.0: return "northwest"
		90.0: return "west"
		135.0: return "southwest"
		180.0: return "south"
		225.0: return "southeast"
		270.0: return "east"
		315.0: return "northeast"
		360.0: return "north"
	return "wow"

var frame = 0
var buffer = 0.0
func _physics_process(delta: float) -> void:
	if buffer < 0:
		buffer = 0.1
		frame += 1
		frame %= 4
	buffer -= delta
	
	var new_animation = get_angle(_camera_pivot.rotation_degrees.y)
	if $Sprite.animation != new_animation:
		buffer = 0.1
	$Sprite.animation = new_animation
	$Sprite.frame = frame

	# Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()



# Comment out this existing camera line.
# @onready var _camera := $Target/Camera3D as Camera3D

@onready var _camera := %Camera as Camera3D
@onready var _camera_pivot := %CameraPivot as Node3D

@export_range(0.0, 1.0) var mouse_sensitivity = 0.01
@export var tilt_limit = deg_to_rad(75)


func _unhandled_input(event: InputEvent) -> void:
	# Mouselook implemented using `screen_relative` for resolution-independent sensitivity.
	if event is InputEventMouseMotion:
		_camera_pivot.rotation.x -= event.screen_relative.y * mouse_sensitivity
		# Prevent the camera from rotating too far up or down.
		_camera_pivot.rotation.x = clampf(_camera_pivot.rotation.x, -tilt_limit, tilt_limit)
		_camera_pivot.rotation.y += -event.screen_relative.x * mouse_sensitivity
