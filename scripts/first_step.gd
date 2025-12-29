extends Node
# Rotation speed in radians per second
@export var rotation_speed: float = 1.0
@onready var mesh_instance = $MeshInstance3D
@onready var collision_body = $StaticBody3D/CollisionShape3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Rotate the mesh
	if mesh_instance:
		mesh_instance.rotate_y(rotation_speed * delta)
	
	# Rotate the collision body
	if collision_body:
		collision_body.rotate_y(rotation_speed * delta)
