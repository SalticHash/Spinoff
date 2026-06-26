extends RigidBody3D

var gotten: bool = false
func collect():
	if gotten: return
	gotten = true
	$Chomp.play()
