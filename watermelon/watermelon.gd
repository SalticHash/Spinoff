extends RigidBody3D

var pitch = 10.0
func _ready() -> void:
	if name == "WatermelonBIG": return
	pitch = randf_range(0.5, 2.0)
	$ExplodeSound.pitch_scale = pitch
	$Chomp.pitch_scale = pitch
	
var gotten: bool = false
func collect():
	if gotten: return
	$Fly.emitting = true
	$Sprite.billboard = VisualShaderNodeBillboard.BillboardType.BILLBOARD_TYPE_DISABLED
	apply_central_impulse(Vector3(0, pitch * 10, 0))
	gotten = true
	$Chomp.play()
	if name == "WatermelonBIG":
		Global.melon += 1224
		var player = get_tree().current_scene.get_node("World/Player")
		player.follow = self
		Global.trapped.emit()
		player.max_locked = true
	Global.melon += 1
	await $Chomp.finished
	explode()

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	for ct: int in range(state.get_contact_count()):
		var obj = state.get_contact_collider_object(ct)
		if !obj: return
		if obj is Player:
			collect()
			break


func explode() -> void:
	if name == "WatermelonBIG":
		Global.explode.emit()
	$Explode.global_position = global_position
	$Explode.restart()
	$Sprite.hide()
	$Fly.emitting = false
	$ExplodeSound.play()
	await $Explode.finished
	if $ExplodeSound.playing: await $ExplodeSound.finished
	
