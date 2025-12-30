extends Node2D

@onready var main_scene = "res://scenes/world.tscn"
@onready var animation_player = $AnimationPlayer

func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)
	animation_player.play("intro")

func _on_animation_finished(anim_name: String) -> void:
	get_tree().change_scene_to_file(main_scene)

func _process(delta: float) -> void:
	pass
