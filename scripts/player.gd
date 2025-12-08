extends CharacterBody3D

# Movement constants
const WALK_SPEED = 5.0
const SPRINT_SPEED = 9.0
const JUMP_VELOCITY = 4.5
const GRAVITY = 12.0
const ROTATION_SPEED = 10.0

# Camera settings
var mouse_sensitivity = 0.002
var camera_rotation_y = 0.0

# Node references
@onready var camera_pivot = $head
@onready var camera = $head/ThirdPerson
@onready var anim_player = $character/AnimationPlayer

# Animation state
var is_punching = false
var current_anim = ""

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Setup animation loops
	if anim_player:
		var loop_anims = ["idle", "walking", "running", "running_jump", "fall"]
		for anim_name in loop_anims:
			if anim_player.has_animation(anim_name):
				anim_player.get_animation(anim_name).loop_mode = Animation.LOOP_LINEAR
		
		# Punch should not loop
		if anim_player.has_animation("punching"):
			anim_player.get_animation("punching").loop_mode = Animation.LOOP_NONE
			anim_player.animation_finished.connect(_on_animation_finished)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# Store camera rotation
		camera_rotation_y -= event.relative.x * mouse_sensitivity
		
		# Rotate camera pivot
		camera_pivot.rotation.y = camera_rotation_y
		
		# Rotate camera vertically
		camera.rotation.x -= event.relative.y * mouse_sensitivity
		camera.rotation.x = clamp(camera.rotation.x, -1.2, 1.2)

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = -0.01
	
	# Handle punch
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if not is_punching:
			is_punching = true
			play_animation("punching")
	
	# Handle jump
	if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Get input direction
	var input_dir = Vector2.ZERO
	if Input.is_key_pressed(KEY_W):
		input_dir.y = 1
	if Input.is_key_pressed(KEY_S):
		input_dir.y = -1
	if Input.is_key_pressed(KEY_A):
		input_dir.x = -1
	if Input.is_key_pressed(KEY_D):
		input_dir.x = 1
	
	input_dir = input_dir.normalized()
	
	# Check if sprinting
	var is_sprinting = Input.is_key_pressed(KEY_CTRL) and Input.is_key_pressed(KEY_W)
	var current_speed = SPRINT_SPEED if is_sprinting else WALK_SPEED
	
	# Calculate movement direction relative to camera rotation
	var move_direction = Vector3.ZERO
	if input_dir != Vector2.ZERO:
		var forward = Vector3(0, 0, -1).rotated(Vector3.UP, camera_rotation_y)
		var right = Vector3(1, 0, 0).rotated(Vector3.UP, camera_rotation_y)
		
		move_direction = (forward * input_dir.y + right * input_dir.x).normalized()
	
	# Apply movement
	if move_direction != Vector3.ZERO:
		velocity.x = move_direction.x * current_speed
		velocity.z = move_direction.z * current_speed
		
		# Rotate character to face movement direction
		var target_angle = atan2(move_direction.x, move_direction.z)
		rotation.y = lerp_angle(rotation.y, target_angle, ROTATION_SPEED * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed * 8 * delta)
		velocity.z = move_toward(velocity.z, 0, current_speed * 8 * delta)
	
	move_and_slide()
	
	# Update animations
	update_animation(is_sprinting)

func update_animation(sprinting: bool):
	if is_punching:
		return
	
	var horizontal_speed = Vector2(velocity.x, velocity.z).length()
	
	# In air
	if not is_on_floor():
		if velocity.y > 0:
			play_animation("running_jump")
		else:
			play_animation("fall")
		return
	
	# On ground
	if horizontal_speed < 0.1:
		play_animation("idle")
	elif sprinting and horizontal_speed > 6.0:
		play_animation("running")
	elif horizontal_speed > 0.1:
		play_animation("walking")

func play_animation(anim_name: String):
	if anim_player and anim_player.has_animation(anim_name) and current_anim != anim_name:
		current_anim = anim_name
		anim_player.play(anim_name)

func _on_animation_finished(anim_name: String):
	if anim_name == "punching":
		is_punching = false

func _process(_delta):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
