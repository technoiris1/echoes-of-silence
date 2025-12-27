extends CharacterBody3D

@export var walk_speed := 7.0
@export var sprint_speed := 12.0
@export var jump_strength := 15.0
@export var gravity := 50.0

@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var model: Node3D = $character
@onready var animation_player: AnimationPlayer = $character/AnimationPlayer

var is_sprinting := false

func _ready() -> void:

	process_mode = Node.PROCESS_MODE_PAUSABLE

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	animation_player.play("idle")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		get_tree().paused = !get_tree().paused

		Input.mouse_mode = (
			Input.MOUSE_MODE_VISIBLE
			if get_tree().paused
			else Input.MOUSE_MODE_CAPTURED
		)

func _physics_process(delta: float) -> void:
	var input_dir := Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("back") - Input.get_action_strength("front")
	).normalized()

	var cam_basis := spring_arm.global_transform.basis
	var move_dir := cam_basis * Vector3(input_dir.x, 0, input_dir.y)
	move_dir.y = 0
	move_dir = move_dir.normalized()

	is_sprinting = Input.is_action_pressed("sprint")
	var speed := sprint_speed if is_sprinting else walk_speed

	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_strength
		animation_player.play("running_jump")

	velocity.x = move_dir.x * speed
	velocity.z = move_dir.z * speed

	move_and_slide()

	if move_dir.length() > 0.1:
		model.rotation.y = atan2(velocity.x, velocity.z)

	if not is_on_floor():
		pass
	elif move_dir.length() > 0.1:
		animation_player.play("running" if is_sprinting else "walking")
	else:
		animation_player.play("idle")

func _process(_delta: float) -> void:
	spring_arm.global_position = global_position
