extends Control

const HITMARKER = preload("res://scenes/hitmarker.tscn")
@onready var save_system: Node = $"Save System"

func _ready() -> void:
	if save_system.secretMenu:
		$Sky.texture = load("res://assets/images/backgrounds/menu_gradient.png")

func _on_back_pressed() -> void:
	spawnHitmarker()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func spawnHitmarker() -> void:
	var hitmarker = HITMARKER.instantiate()
	hitmarker.global_position = get_viewport().get_mouse_position()
	add_child(hitmarker)

# Press X the Everything App
func _on_x_button_pressed() -> void:
	spawnHitmarker()
	await get_tree().create_timer(0.1).timeout
	OS.shell_open("https://x.com/ih8mondays57")

# Scratch the Itch Button
func _on_itch_button_pressed() -> void:
	spawnHitmarker()
	await get_tree().create_timer(0.1).timeout
	OS.shell_open("https://ih8mondays57.itch.io/")
