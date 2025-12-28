extends MeshInstance3D

func _process(delta):
	rotate_y(delta * 2.0) # Rotates continuously
