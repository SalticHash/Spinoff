extends AnimatedSprite3D


## In radians.
func get_cam_angle() -> float:
	var cam = get_viewport().get_camera_3d()
	var cam_pos = Vector2(cam.global_position.x, cam.global_position.z)
	var pos = Vector2(global_position.x, global_position.z)
	var cam_angle = cam_pos.angle_to_point(pos)
	return cam_angle

## Gets the cardinal name of the angle for the animations.
func get_angle_name(angle: float):
	var a = angle_difference(0.0, -angle) + PI
	match snappedf(rad_to_deg(a), 45.0):
		0.0: return "north"
		45.0: return "northwest"
		90.0: return "west"
		135.0: return "southwest"
		180.0: return "south"
		225.0: return "southeast"
		270.0: return "east"
		315.0: return "northeast"
		360.0: return "north"
	return "error"


var current_frame: int = 0 :
	set(value):
		current_frame = value % 4
		frame = current_frame
var walk_speed: float = 0.1
var walk_frame_buffer: float = 0.0
var walking: bool = false :
	set(value):
		walking = value
		if walking == false: current_frame = 0

func _process(delta: float) -> void:
	var cam_angle: float = get_cam_angle()
	var new_animation = get_angle_name(cam_angle + PI/2 + global_rotation.y)
	if animation != new_animation:
		walk_frame_buffer = walk_speed
		animation = new_animation
	
	if !get_parent().is_on_floor():
		frame = 1
		return
	if walk_frame_buffer < 0.0:
		walk_frame_buffer = walk_speed
		current_frame += 1
		if frame == 0 or frame == 2:
			%StepSound.play()
		
	if walking: walk_frame_buffer -= delta
