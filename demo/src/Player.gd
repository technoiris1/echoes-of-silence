extends CharacterBody3D
# --- movement ---
const WALK_SPEED := 5.0
const SPRINT_SPEED := 9.0
const JUMP_VELOCITY := 4.5
var GRAVITY: float = 12.0
# --- camera ---
var sensitivity := 0.00175
@onready var camera = $head/ThirdPerson
# --- animations ---
@onready var anim_player: AnimationPlayer = $character/AnimationPlayer
const ANIM_IDLE := "idle"
const ANIM_WALK := "walking"
const ANIM_RUN := "running"
const ANIM_JUMP := "running_jump"
const ANIM_FALL := "fall"
const ANIM_PUNCH := "punching"
var current_anim := ""
var is_punching := false  # Track if we're in a punch animation

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# force-loop normal locomotion animations
	var loop_list = [ANIM_IDLE, ANIM_WALK, ANIM_RUN, ANIM_JUMP, ANIM_FALL]
	for name in loop_list:
		if anim_player and anim_player.has_animation(name):
			anim_player.get_animation(name).loop_mode = Animation.LOOP_LINEAR
	
	# Make sure punch doesn't loop
	if anim_player and anim_player.has_animation(ANIM_PUNCH):
		anim_player.get_animation(ANIM_PUNCH).loop_mode = Animation.LOOP_NONE
	
	# Connect to animation finished signal
	if anim_player:
		anim_player.animation_finished.connect(_on_animation_finished)

func _process(delta):
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(70))

func _physics_process(delta):
	# gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = -0.01
	
	# punch - can punch anytime
	if Input.is_action_just_pressed("attack") and not is_punching:
		is_punching = true
		_play_anim(ANIM_PUNCH)
	
	# jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		if not is_punching:  # Don't override punch with jump anim
			_play_anim(ANIM_JUMP)
	
	# direction
	var input_dir := Input.get_vector("left", "right", "front", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# sprint
	var sprinting := false
	if Input.is_action_pressed("front") and (Input.is_action_pressed("sprint") or Input.is_key_pressed(KEY_CTRL)):
		sprinting = true
	
	var speed := WALK_SPEED
	if sprinting:
		speed = SPRINT_SPEED
	
	# movement
	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed * 8 * delta)
		velocity.z = move_toward(velocity.z, 0, speed * 8 * delta)
	
	move_and_slide()
	_update_anim()

# ---------------------------------------------------------
# ANIMATION LOGIC
# ---------------------------------------------------------
func _play_anim(name: String) -> void:
	if name != current_anim and anim_player and anim_player.has_animation(name):
		current_anim = name
		anim_player.play(name)

func _update_anim():
	if not anim_player:
		return
	
	# Don't override punch animation while it's playing
	if is_punching:
		return
	
	var h_speed := Vector3(velocity.x, 0, velocity.z).length()
	
	if not is_on_floor():
		if velocity.y > 0:
			_play_anim(ANIM_JUMP)
		else:
			_play_anim(ANIM_FALL)
		return
	
	if h_speed < 0.1:
		_play_anim(ANIM_IDLE)
	elif h_speed > (WALK_SPEED + (SPRINT_SPEED - WALK_SPEED) * 0.5):
		_play_anim(ANIM_RUN)
	else:
		_play_anim(ANIM_WALK)

func _on_animation_finished(anim_name: String):
	# When punch finishes, allow normal animations again
	if anim_name == ANIM_PUNCH:
		is_punching = false
		# Immediately update to correct animation based on current state
		_update_anim()
