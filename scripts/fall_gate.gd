extends Node

@export var puzzle_scene: PackedScene
@onready var gate_mesh := $wood
@onready var gate_collision := $StaticBody3D/CollisionShape3D
@onready var gate_area := $area
@onready var label := $label

var player_inside := false
var is_holding_interact := false
var hold_time := 0.0
const REQUIRED_HOLD_TIME := 4.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	gate_area.body_entered.connect(_on_body_entered)
	gate_area.body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	if player_inside:
		label.visible = true
		
		if Input.is_action_pressed("interact"):
			is_holding_interact = true
			hold_time += delta
			
			var progress := (hold_time / REQUIRED_HOLD_TIME) * 100.0
			label.text = "Opening... %.0f%%" % progress
			
			if hold_time >= REQUIRED_HOLD_TIME:
				open_gate()
		else:
			is_holding_interact = false
			hold_time = 0.0
			label.text = "Hold E"
	else:
		label.visible = false
		is_holding_interact = false
		hold_time = 0.0

func _on_body_entered(body: Node) -> void:
	if body.name == "player":
		player_inside = true

func _on_body_exited(body: Node) -> void:
	if body.name == "player":
		player_inside = false

func open_gate() -> void:
	gate_mesh.visible = false
	gate_collision.disabled = true
	label.visible = false
	$gate_marker.visible = false
	set_process(false)
	gate_area.body_entered.disconnect(_on_body_entered)
	gate_area.body_exited.disconnect(_on_body_exited)
