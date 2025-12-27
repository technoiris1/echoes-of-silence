extends Control

@onready var slots := [
	$Panel/Slots/Slot1,
	$Panel/Slots/Slot2,
	$Panel/Slots/Slot3,
	$Panel/Slots/Slot4
]

@onready var buttons_container := $Panel/signbuttons

var current_slot := 0
var chosen_symbols: Array[String] = []

const CORRECT_SEQUENCE := [
	"triangle",
	"circle",
	"star",
	"rectangle"
]

func _ready():
	for child in buttons_container.get_children():
		if child is TextureButton:
			child.pressed.connect(_on_symbol_pressed.bind(child))
func _on_symbol_pressed(button: TextureButton) -> void:
	if current_slot >= 4:
		return

	var symbol_name := button.name
	var symbol_texture := button.texture_normal

	slots[current_slot].texture = symbol_texture
	chosen_symbols.append(symbol_name)

	current_slot += 1
func _on_submit_pressed() -> void:
	if chosen_symbols.size() < 4:
		return

	if chosen_symbols == CORRECT_SEQUENCE:
		print("PUZZLE SOLVED")
	else:
		clear_slots()
func _on_clear_pressed() -> void:
	clear_slots()

func clear_slots() -> void:
	for slot in slots:
		slot.texture = null

	chosen_symbols.clear()
	current_slot = 0
