extends Node2D

@onready var main_scene = "res://scenes/world.tscn"
@onready var animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect to the animation_finished signal
	animation_player.animation_finished.connect(_on_animation_finished)
	# Play the animation
	animation_player.play("intro")

# Called when the animation finishes
func _on_animation_finished(anim_name: String) -> void:
	# Change to the main scene
	get_tree().change_scene_to_file(main_scene)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
