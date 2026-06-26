extends RigidBody3D

var gotten: bool = false
func collect():
	if gotten: return
	gotten = true
	$Chomp.play()

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if state.get_contact_count() < 1: return
	var obj = state.get_contact_collider_object(0)
	if !obj: return
	if obj is Player:
		collect()
