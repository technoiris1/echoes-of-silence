extends CharacterBody3D
@export var speed := 7.0
@export var jump_strength := 20.0
@export var gravity := 50.0
@onready var _spring_arm: SpringArm3D = $SpringArm3D
@onready var _model: Node3D = $character
@onready var animation_player = $character/AnimationPlayer

func _ready() -> void:
	animation_player.play("idle")

func _physics_process(delta: float) -> void:
	# Get input relative to camera
	var input_dir := Vector2.ZERO
	input_dir.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_dir.y = Input.get_action_strength("back") - Input.get_action_strength("front")
	input_dir = input_dir.normalized()
	
	# Transform input direction based on camera rotation
	var cam_basis = _spring_arm.global_transform.basis
	var move_direction = (cam_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	move_direction.y = 0  # Keep movement on horizontal plane
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_strength
	
	velocity.x = move_direction.x * speed
	velocity.z = move_direction.z * speed
	
	move_and_slide()
	
	# Handle rotation and animations
	if velocity.length() > 0.2:
		# Make character face movement direction
		_model.rotation.y = atan2(velocity.x, velocity.z)
		
		# Play walking animation when moving
		if animation_player.current_animation != "walking":
			animation_player.play("walking")
	else:
		# Play idle animation when not moving
		if animation_player.current_animation != "idle":
			animation_player.play("idle")
		
func _process(_delta: float) -> void:
	_spring_arm.global_position = global_position
