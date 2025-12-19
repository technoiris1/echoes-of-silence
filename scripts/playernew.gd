extends CharacterBody3D

const SPEED := 5.0
const SPRINT_SPEED := 8.0
const JUMP_VELOCITY := 4.5
const MOUSE_SENSITIVITY := 0.003
const CAMERA_X_ROT_MIN := deg_to_rad(-89)
const CAMERA_X_ROT_MAX := deg_to_rad(89)
const ROTATION_SPEED := 12.0

@onready var anim_player: AnimationPlayer = $character/AnimationPlayer
@onready var camera_pivot: Node3D = $head
@onready var camera: Camera3D = $head/ThirdPerson

var camera_x_rot := 0.0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Yaw
		camera_pivot.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)

		# Pitch
		camera_x_rot -= event.relative.y * MOUSE_SENSITIVITY
		camera_x_rot = clamp(camera_x_rot, CAMERA_X_ROT_MIN, CAMERA_X_ROT_MAX)
		camera.rotation.x = camera_x_rot

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = (
			Input.MOUSE_MODE_VISIBLE
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
			else Input.MOUSE_MODE_CAPTURED
		)

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# --- INPUT ---
	var input_dir := Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("back") - Input.get_action_strength("front")
	)

	var direction := Vector3.ZERO

	if input_dir.length() > 0:
		var basis := camera_pivot.global_transform.basis
		var forward := -basis.z
		var right := basis.x

		direction = (right * input_dir.x + forward * input_dir.y).normalized()

		# Rotate player to face movement direction
		var target_yaw := atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_yaw, ROTATION_SPEED * delta)

	# Speed
	var speed := SPRINT_SPEED if Input.is_action_pressed("sprint") else SPEED

	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	# --- ANIMATIONS ---
	if not is_on_floor():
		anim_player.play("running_jump")
	elif direction != Vector3.ZERO:
		anim_player.play("running" if Input.is_action_pressed("sprint") else "walking")
	else:
		anim_player.play("idle")
