extends Node

@export var puzzle_scene: PackedScene

@onready var gate_mesh := $door
@onready var gate_collision := $collisions/collisionbody
@onready var gate_area := $area
@onready var UILayer := $Ui_Layer

var player_inside := false
var solved := false
var puzzle_instance: Control = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE

	gate_area.body_entered.connect(_on_body_entered)
	gate_area.body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	# Open puzzle
	if player_inside and not solved and Input.is_action_just_pressed("interact"):
		open_puzzle()

	# ESC closes puzzle if it's open
	if puzzle_instance != null and Input.is_action_just_pressed("ui_cancel"):
		close_puzzle()

func _on_body_entered(body: Node) -> void:
	if body.name == "player":
		player_inside = true

func _on_body_exited(body: Node) -> void:
	if body.name == "player":
		player_inside = false

func open_puzzle() -> void:
	if puzzle_instance != null:
		return

	get_tree().paused = true

	puzzle_instance = puzzle_scene.instantiate()
	puzzle_instance.process_mode = Node.PROCESS_MODE_ALWAYS

	puzzle_instance.puzzle_solved.connect(_on_puzzle_solved)
	puzzle_instance.puzzle_closed.connect(_on_puzzle_closed)

	UILayer.add_child(puzzle_instance)

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_puzzle_solved() -> void:
	solved = true
	close_puzzle()
	open_gate()

func _on_puzzle_closed() -> void:
	close_puzzle()

func close_puzzle() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if puzzle_instance != null:
		puzzle_instance.queue_free()
		puzzle_instance = null

func open_gate() -> void:
	gate_mesh.visible = false
	gate_collision.disabled = true
