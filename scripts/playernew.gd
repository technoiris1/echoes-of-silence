extends CharacterBody3D

const SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.003
const CAMERA_X_ROT_MIN = -89
const CAMERA_X_ROT_MAX = 89
const ROTATION_SPEED = 10.0  # How fast the snap rotation happens

var anim_player: AnimationPlayer
var camera: Camera3D
var camera_pivot: Node3D
var target_rotation: float = 0.0  # Target rotation in radians
var is_rotating: bool = false

func _ready() -> void:
	anim_player = $character/AnimationPlayer
	anim_player.play("idle")
	
	camera_pivot = $head
	camera = $head/ThirdPerson
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	target_rotation = rotation.y

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_pivot.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		
		var camera_rot = camera.rotation_degrees
		camera_rot.x -= event.relative.y * MOUSE_SENSITIVITY * 57.2958
		camera_rot.x = clamp(camera_rot.x, CAMERA_X_ROT_MIN, CAMERA_X_ROT_MAX)
		camera.rotation_degrees = camera_rot
	
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var current_speed = SPRINT_SPEED if Input.is_action_pressed("sprint") else SPEED
	var input_dir := Input.get_vector("left", "right", "front", "back")
	
	# Handle rotation based on input (only when key is JUST pressed)
	if Input.is_action_just_pressed("right"):  # D key
		target_rotation -= PI / 2  # Rotate 90° right
		is_rotating = true
	elif Input.is_action_just_pressed("left"):  # A key
		target_rotation += PI / 2  # Rotate 90° left
		is_rotating = true
	elif Input.is_action_just_pressed("back"):  # S key
		target_rotation += PI  # Rotate 180°
		is_rotating = true
	
	# Smoothly interpolate to target rotation
	if is_rotating:
		rotation.y = lerp_angle(rotation.y, target_rotation, ROTATION_SPEED * delta)
		if abs(angle_difference(rotation.y, target_rotation)) < 0.01:
			rotation.y = target_rotation
			is_rotating = false
	
	# Calculate movement direction relative to camera
	var direction := Vector3.ZERO
	if input_dir != Vector2.ZERO:
		var cam_forward = -camera_pivot.global_transform.basis.z
		var cam_right = camera_pivot.global_transform.basis.x
		
		cam_forward.y = 0
		cam_right.y = 0
		cam_forward = cam_forward.normalized()
		cam_right = cam_right.normalized()
		
		direction = (cam_right * input_dir.x + cam_forward * input_dir.y).normalized()
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
	
	# Animation logic
	if not is_on_floor():
		anim_player.play("running_jump")
	elif direction:
		anim_player.play("running" if Input.is_action_pressed("sprint") else "walking")
	else:
		anim_player.play("idle")
