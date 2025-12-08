extends CharacterBody3D

const SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.5

var anim_player: AnimationPlayer

func _ready() -> void:
	anim_player = $character/AnimationPlayer
	anim_player.play("idle")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Determine current speed based on sprint input
	var current_speed = SPRINT_SPEED if Input.is_action_pressed("sprint") else SPEED
	
	var input_dir := Input.get_vector("left", "right", "front", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
	
	# Handle animations based on state (check in-air first!)
	if not is_on_floor():
		anim_player.play("running_jump")
	elif direction:
		# Play appropriate animation based on speed
		if Input.is_action_pressed("sprint"):
			anim_player.play("running")
		else:
			anim_player.play("walking")
	else:
		anim_player.play("idle")
