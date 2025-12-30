extends Area3D

var next_scene_path: String = "res://scenes/intro.tscn"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node3D) -> void:
	print("body entered")
	get_tree().change_scene_to_file(next_scene_path)
