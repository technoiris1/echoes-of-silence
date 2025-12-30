extends Area3D

@onready var scene = "res://scenes/parkour.tscn"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(_body: Node3D) -> void:
	get_tree().change_scene_to_file(scene)
func _process(_delta: float) -> void:
	pass
