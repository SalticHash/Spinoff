class_name Box
extends RigidBody3D

var gotten: bool = false
func collect():
	if gotten: return
	gotten = true
	$KnockSound.play()
	Global.boxes += 1

var played = true
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if state.get_contact_count() < 1:
		played = false
		return
	for ct: int in range(state.get_contact_count()):
		var obj = state.get_contact_collider_object(ct)
		if !obj: return
		if obj is Player or (obj is Box and linear_velocity.length_squared() > 1.0):
			collect()
			break
		
