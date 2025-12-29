extends Node

@export var rotation_speed: float = 1.0

@onready var mesh_instance = $MeshInstance3D  
@onready var collision_body = $StaticBody3D/CollisionShape3D  

func _ready() -> void:
	pass 

func _process(delta: float) -> void:
	if mesh_instance:
		mesh_instance.rotate_y(rotation_speed * delta)
	if collision_body:
		collision_body.rotate_y(rotation_speed * delta)
