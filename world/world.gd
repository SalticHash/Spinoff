extends Node


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Global.end = false
	Global.boxes = 0
	Global.melon = 0

func _process(_delta: float) -> void:
	if $World/WatermelonBIG and $World/WatermelonBIG.is_inside_tree():
		$World/ExplodeCamera.look_at($World/WatermelonBIG.global_position)
	if Global.end:
		$World/ExplodeCamera.make_current()
