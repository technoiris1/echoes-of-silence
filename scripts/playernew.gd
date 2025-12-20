extends CharacterBody3D
@export var walk_speed := 7.0
@export var sprint_speed := 12.0
@export var jump_strength := 20.0
@export var gravity := 50.0


@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var model: Node3D = $character
@onready var animation_player: AnimationPlayer = $character/AnimationPlayer


var game_active := true
var is_sprinting := false


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	animation_player.play("idle")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		game_active = !game_active
		Input.mouse_mode = (
			Input.MOUSE_MODE_CAPTURED
			if game_active
			else Input.MOUSE_MODE_VISIBLE
		)


func _physics_process(delta: float) -> void:
	if not game_active:
		return
	var input_dir := Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("back") - Input.get_action_strength("front")
	).normalized()

	var cam_basis := spring_arm.global_transform.basis
	var move_dir := cam_basis * Vector3(input_dir.x, 0, input_dir.y)
	move_dir.y = 0
	move_dir = move_dir.normalized()


	is_sprinting = Input.is_action_pressed("sprint")
	var current_speed := sprint_speed if is_sprinting else walk_speed


	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_strength
		animation_player.play("running_jump")


	velocity.x = move_dir.x * current_speed
	velocity.z = move_dir.z * current_speed

	move_and_slide()

	if move_dir.length() > 0.1:
		model.rotation.y = atan2(velocity.x, velocity.z)

	if not is_on_floor():
		pass 
	elif move_dir.length() > 0.1:
		if is_sprinting:
			if animation_player.current_animation != "running":
				animation_player.play("running")
		else:
			if animation_player.current_animation != "walking":
				animation_player.play("walking")
	else:
		if animation_player.current_animation != "idle":
			animation_player.play("idle")

func _process(_delta: float) -> void:
	spring_arm.global_position = global_position
