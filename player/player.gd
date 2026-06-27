class_name Player
extends CharacterBody3D

var max_locked: bool = true
var follow: Node3D = null
const RISE_GRAVITY: float = -30
const FALL_GRAVITY: float = -70
const SPEED: float = 5.0

const ACCEL: float = 15.0
const DECEL: float = 15.0
const AIR_ACCEL: float = 2.0
const AIR_DECEL: float = 2.0

const MAX_TURN_SPEED: float = 1.25
const TURN_ACCEL: float = 0.02
const TURN_DECEL: float = 0.08
const AIR_TURN_ACCEL: float = 0.006
const AIR_TURN_DECEL: float = 0.015
var turn_speed: float = 0.0

const JUMP_VELOCITY = 16

const MAX_SPEED: float = 32.0
var speed: float = 0.0
var last_dir: float = 1.0
var locked: bool = true
var accel_dir: float = 0.0

var jump_buffer: float = 0.0
const JUMP_BUFFER: float = 0.25
var floor_buffer: float = 0.0
const FLOOR_BUFFER: float = 0.25
func animate(delta: float) -> void:
	$HamsterWheel.rotate_x(speed * PI / 32 * delta)
	$Sprite.walking = speed != 0
	var rot = create_tween()
	rot.tween_property($Sprite, "rotation_degrees", Vector3(0, 180 if (accel_dir == -1.0) else 0, 0), 0.2)
	$Sprite.walk_speed = clamp(remap(abs(speed), 0, MAX_SPEED, 0.2, 0.025), 0.025, 0.2)

var was_on_floor: bool = false
var last_floor_position: Vector3 = Vector3.ZERO

func _ready() -> void:
	Global.explode.connect(func(): hide())
	Global.dialog_ended.connect(func(): max_locked = false)
var wall_stun: float = 0.0
var WALL_STUN: float = 0.1
func _physics_process(delta: float) -> void:
	if follow and follow.is_inside_tree():
		$Collision.disabled = true
		Global.end = true
		global_position = follow.global_position + Vector3(0, -4, 2)
	if max_locked: return
	if $WallRay/Coll.disabled:
		wall_stun -= delta
	if wall_stun <= 0.0:
		$WallRay/Coll.disabled = false
	if $WallRay.has_overlapping_bodies():
		$WallRay/Coll.disabled = true
		wall_stun = WALL_STUN
		if abs(speed) > 10:
			velocity.y = max(abs(speed) / MAX_SPEED * JUMP_VELOCITY, 5.0)
		speed = min(abs(speed), 10.0) * -sign(speed)
	
	if speed >= MAX_SPEED * 1.5:
		locked = false
		Global.set_free.emit()
		_camera.make_current()
	
	if is_on_floor() and !was_on_floor:
		if jump_buffer <= 0 and floor_buffer <= 0:
			$Sprite/AnimationPlayer.stop()
			$Sprite/AnimationPlayer.speed_scale = 1.0
			
			$Sprite/AnimationPlayer.play("squash")
			$LandSound.play()
		$LandWheelSound.play()
		
	was_on_floor = is_on_floor()
	# Add the gravity.
	if not is_on_floor() and !locked:
		var grav = FALL_GRAVITY if velocity.y < 0 else RISE_GRAVITY
		velocity.y += grav * delta
	
	if $FloorRay.is_colliding():
		last_floor_position = global_position
	
	if global_position.y < -10:
		global_position = last_floor_position
		velocity = Vector3.ZERO
		speed = 0.0
		turn_speed = 0.0
#

	if abs(speed) > 0.0 and (is_on_floor() or locked):
		$Sprite/AnimationPlayer.speed_scale = remap(abs(speed), 0.0, MAX_SPEED, 0.1, 1.0)
		if !$Sprite/AnimationPlayer.is_playing() and $Sprite/AnimationPlayer.current_animation != "hops":
			$Sprite/AnimationPlayer.play("hops")
	else:
		if $Sprite/AnimationPlayer.current_animation == "hops":
			$Sprite/AnimationPlayer.stop()
			
	## Handle jump.
	if is_on_floor(): floor_buffer = FLOOR_BUFFER
	if Input.is_action_just_pressed("jump"): jump_buffer = JUMP_BUFFER
	if floor_buffer > 0 and jump_buffer > 0:
		velocity.y = JUMP_VELOCITY
		jump_buffer = 0
		floor_buffer = 0
		$Sprite/AnimationPlayer.stop()
		$Sprite/AnimationPlayer.speed_scale = 0.7
		
		$Sprite/AnimationPlayer.advance(0)
		$Sprite/AnimationPlayer.play("strech")
		$JumpSound.play()
	if floor_buffer > 0: floor_buffer -= delta
	if jump_buffer > 0: jump_buffer -= delta
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	accel_dir = Input.get_axis("backward", "forward")
	if locked and accel_dir < 0: accel_dir = 0
	var turn_dir: float = Input.get_axis("turn_left", "turn_right")
	var turn_accel = TURN_ACCEL if is_on_floor() else AIR_TURN_ACCEL
	var turn_decel = TURN_DECEL if is_on_floor() else AIR_TURN_DECEL
	if turn_dir and !locked: turn_speed = move_toward(turn_speed, MAX_TURN_SPEED * turn_dir, turn_accel)
	else:turn_speed = move_toward(turn_speed, 0.0, turn_decel)
	rotate_y(-turn_speed * TAU * delta) 

	_camera_pivot.global_position = global_position + Vector3(0,3.5,0)
	var accel = ACCEL if is_on_floor() or locked else AIR_ACCEL
	var decel = DECEL if is_on_floor() or locked else AIR_DECEL
	if accel_dir:
		last_dir = sign(accel_dir)
		speed = move_toward(speed, MAX_SPEED * accel_dir * (1.5 if locked else 1.0), delta * accel)
	else:
		speed = move_toward(speed, 0.0, delta * decel)
	
	$DustParticles.amount_ratio = abs(speed) / MAX_SPEED if is_on_floor() else 0.0
	
	if $RollSound.playing:
		if abs(speed) + abs(turn_speed) == 0.0 or !is_on_floor(): $RollSound.stop()
		$RollSound.pitch_scale = \
		remap(abs(speed), 0.0, MAX_SPEED, 0.7, 2.0) + \
		remap(abs(turn_speed), 0.0, MAX_TURN_SPEED, 0.1, 1.0)
	else:
		if abs(speed) + abs(turn_speed) != 0.0 or is_on_floor(): $RollSound.play()
	animate(delta)
	
	if abs(speed) > 0.0:
		if !$MoveMusic.playing: $MoveMusic.play()
		$MoveMusic.pitch_scale = remap(abs(speed), 0.0, MAX_SPEED, 0.75, 1.25)
		$MoveMusic.volume_linear = remap(abs(speed), 0.0, MAX_SPEED, 0.1, 0.2)
	else:
		$MoveMusic.pitch_scale = 0.01
		$MoveMusic.volume_linear = 0.01

	var direction := (transform.basis * Vector3.BACK).normalized()
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	
	if locked: return
	move_and_slide()



# Comment out this existing camera line.
# @onready var _camera := $Target/Camera3D as Camera3D

@onready var _camera := %Camera as Camera3D
@onready var _camera_pivot := %CameraPivot as Node3D

@export_range(0.0, 1.0) var mouse_sensitivity = 0.01
@export var tilt_limit = deg_to_rad(75)


func _unhandled_input(event: InputEvent) -> void:
	if locked: return
	# Mouselook implemented using `screen_relative` for resolution-independent sensitivity.
	if event is InputEventMouseMotion:
		_camera_pivot.rotation.x -= event.screen_relative.y * mouse_sensitivity
		# Prevent the camera from rotating too far up or down.
		_camera_pivot.rotation.x = clampf(_camera_pivot.rotation.x, -tilt_limit, tilt_limit)
		_camera_pivot.rotation.y += -event.screen_relative.x * mouse_sensitivity
