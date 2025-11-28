extends CharacterBody3D

const WALK_SPEED := 5.0
const SPRINT_SPEED := 9.0
const JUMP_VELOCITY := 4.5
var GRAVITY: float = 12.0  

var sensitivity := 0.00175
@onready var camera = $head/ThirdPerson

@onready var anim_player: AnimationPlayer = $character/AnimationPlayer

const ANIM_IDLE := "idle"
const ANIM_WALK := "walking"
const ANIM_RUN := "running"
const ANIM_JUMP := "running_jump" 
const ANIM_FALL := "fall"


var desired_anim := ""
var current_velocity := Vector3.ZERO

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


	if anim_player:
		var anims_to_loop = [
			ANIM_IDLE,
			ANIM_WALK,
			ANIM_RUN,
			ANIM_JUMP,
			ANIM_FALL
		]

		for name in anims_to_loop:
			if anim_player.has_animation(name):
				var a: Animation = anim_player.get_animation(name)
				if a:
					a.loop = true
			else:
				push_warning("Animation not found: %s" % name)

func _process(delta):
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(70))

func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = -0.01

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		_set_anim(ANIM_JUMP)

	var input_dir := Input.get_vector("left", "right", "front", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	var sprint_key := Input.is_action_pressed("sprint") or Input.is_key_pressed(KEY_CTRL)
	var forward_pressed := Input.is_action_pressed("front")
	var is_sprinting := forward_pressed and sprint_key

	var move_speed := WALK_SPEED
	if is_sprinting:
		move_speed = SPRINT_SPEED


	if direction != Vector3.ZERO:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed * 8.0 * delta)
		velocity.z = move_toward(velocity.z, 0, move_speed * 8.0 * delta)

	move_and_slide()

	_update_anim()

func _update_anim() -> void:
	if not anim_player:
		return

	var horizontal_speed := Vector3(velocity.x, 0, velocity.z).length()

	var anim := ANIM_IDLE

	if not is_on_floor():
		if velocity.y > 0.1:
			anim = ANIM_JUMP
		else:
			anim = ANIM_FALL
	else:
		if horizontal_speed < 0.1:
			anim = ANIM_IDLE
		else:
			if horizontal_speed > (WALK_SPEED + (SPRINT_SPEED - WALK_SPEED) * 0.5):
				anim = ANIM_RUN
			else:
				anim = ANIM_WALK

	_set_anim(anim)

func _set_anim(name: String) -> void:
	if name != desired_anim and anim_player.has_animation(name):
		desired_anim = name
		anim_player.play(name)
