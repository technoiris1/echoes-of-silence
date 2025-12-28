extends Control

signal puzzle_solved
signal puzzle_closed

const CORRECT_SEQUENCE := [
	"circle",
	"rectangle",
	"star",
	"triangle"
]

@onready var slots := [
	$Panel/Slots/Slot1,
	$Panel/Slots/Slot2,
	$Panel/Slots/Slot3,
	$Panel/Slots/Slot4
]

@onready var buttons_container := $Panel/signbuttons
@onready var message_label := $Panel/Message
@onready var exit_button := $Panel/Exit

var current_slot := 0
var chosen_symbols: Array[String] = []
var solved := false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	for child in buttons_container.get_children():
		if child is TextureButton:
			child.pressed.connect(_on_symbol_pressed.bind(child))

	clear_slots()

func _on_symbol_pressed(button: TextureButton) -> void:
	if current_slot >= 4:
		return

	slots[current_slot].texture = button.texture_normal
	chosen_symbols.append(button.name)
	current_slot += 1

func _on_submit_pressed() -> void:
	if chosen_symbols.size() < 4:
		show_message("Fill all 4 slots first!", Color.RED)
		return

	if chosen_symbols == CORRECT_SEQUENCE:
		show_message("Correct sequence! Press 'Exit'.", Color.GREEN)
		solved = true
	else:
		show_message("Wrong sequence. Try again.", Color.RED)
		clear_slots()

func _on_clear_pressed() -> void:
	clear_slots()
	message_label.text = ""

func clear_slots() -> void:
	for slot in slots:
		slot.texture = null
	chosen_symbols.clear()
	current_slot = 0

func _on_exit_pressed() -> void:
	if solved:
		emit_signal("puzzle_solved")
	else:
		emit_signal("puzzle_closed")
	queue_free()

func show_message(text: String, color: Color) -> void:
	message_label.text = text
	message_label.modulate = color
