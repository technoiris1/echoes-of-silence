extends CharacterBody3D

@export var speed := 7.0
@export var jump_strength := 20.0
@export var gravity := 50.0

@onready var _spring_arm: SpringArm3D = $SpringArm3D
@onready var _model: Node3D = $character
@onready var animation_player = $character/AnimationPlayer
func _physics_process(delta: float) -> void:
	var move_direction := Vector3.ZERO
	move_direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	move_direction.z = Input.get_action_strength("back") - Input.get_action_strength("front")
	move_direction = move_direction.normalized()
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_strength
	velocity.x = move_direction.x * speed
	velocity.z = move_direction.z * speed
	
	move_and_slide()

	if velocity.length() > 0.2:
		var look_direction = Vector2(velocity.z, velocity.x)
		_model.rotation.y = look_direction.angle()
		
func _process(_delta: float) -> void:
	_spring_arm.global_position = global_position
