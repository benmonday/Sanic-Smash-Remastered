extends Control

const HITMARKER = preload("res://scenes/hitmarker.tscn")

@onready var save_system: Node = $"Save System"

var rng = RandomNumberGenerator.new()
var gold = false
var goldCounter = 0

func _ready() -> void:
	if save_system.secretMenu:
		gold = true
		$Sanic.play("gold_idle")
		$Sky.texture = load("res://assets/images/backgrounds/menu_gradient.png")
		
func _on_play_pressed() -> void:
	spawnHitmarker()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_tutorial_pressed() -> void:
	spawnHitmarker()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://scenes/tutorial.tscn")

func _on_credits_pressed() -> void:
	spawnHitmarker()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://scenes/customize.tscn")

func _on_quit_pressed() -> void:
	spawnHitmarker()
	await get_tree().create_timer(0.3).timeout
	get_tree().quit()

func spawnHitmarker() -> void:
	var hitmarker = HITMARKER.instantiate()
	hitmarker.global_position = get_viewport().get_mouse_position()
	add_child(hitmarker)

func _physics_process(_delta: float) -> void:
	if rng.randi_range(0, 200) == 57:
		var rand = rng.randi_range(0, 1)
		if rand == 0 and gold:
			$Sanic.play("gold_eye_dart")
		elif rand == 0 and not gold:
			$Sanic.play("eye_dart")
		elif rand == 1 and gold:
			$Sanic.play("gold_blink")
		elif rand == 1 and not gold:
			$Sanic.play("blink")

func _input(event: InputEvent) -> void:
	var mousePos = get_viewport().get_mouse_position()
	if not gold and event.is_action_pressed("click") and mousePos.y >= 130 and mousePos.y <= 270 and mousePos.x >= 0 and mousePos.x <= 150 and $Sniper.camo == 4:
		spawnHitmarker()
		goldCounter = goldCounter + 1
		if goldCounter >= 100:
			gold = true
			$Sanic.play("gold_idle")
			$Sky.texture = load("res://assets/images/backgrounds/menu_gradient.png")
			save_system.secretMenu = true
			save_system.save()

func _on_info_pressed() -> void:
	spawnHitmarker()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://scenes/credits.tscn")
