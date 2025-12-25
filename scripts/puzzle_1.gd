extends Control

@onready var slots := [
	$Panel/slots/slot1,
	$Panel/slots/slot2,
	$Panel/slots/slot3,
	$Panel/slots/slot4
]
var chosen_symbols := []
var current_slot := 0

const CORRECT_SEQUENCE = [
	"triangle",
	"circle",
	"star",
	"rect"
]

func symbol_pressed(button: TextureButton) -> void:
	if current_slot >= 4:
		return

	var symbol_name = button.get_meta("symbol")
	var symbol_texture = button.texture_normal

	slots[current_slot].texture = symbol_texture
	chosen_symbols.append(symbol_name)

	current_slot += 1
