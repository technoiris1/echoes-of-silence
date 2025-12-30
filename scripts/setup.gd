extends Node

@onready var main_scene = "res://scenes/intro.tscn"

func _ready() -> void:
	get_tree().create_timer(1.0)
	get_tree().change_scene_to_file(main_scene)

func _process(delta: float) -> void:
	pass
