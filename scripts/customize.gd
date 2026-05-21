extends Control

const HITMARKER = preload("res://scenes/hitmarker.tscn")
const SNIPER = preload("res://scenes/sniper.tscn")

@onready var saveSystem: Node = $"Save System"

# Unlocked Camo Vars
var pinkUnlocked = true
var blossomUnlocked = true
var redTigerUnlocked = true
var goldUnlocked = true

# Read in the save data variables
@onready var highScore = saveSystem.highScore
@onready var sanicsSmashed = saveSystem.sanicsSmashed
@onready var maxMultsReached = saveSystem.maxMultsReached
@onready var equippedCamo = saveSystem.gunCamo
@onready var sniperInstance = $Sniper

func _ready() -> void:
	# Check for secret BG
	if saveSystem.secretMenu:
		$BG.texture = load("res://assets/images/backgrounds/menu_gradient.png")
	# Lock camos if needed
	if not maxMultsReached >= 10:
		pinkUnlocked = false
		$"Locks/Pink Lock".visible = true
	if not sanicsSmashed >= 10000:
		blossomUnlocked = false
		$"Locks/Blossom Lock".visible = true
	if not highScore >= 50000:
		redTigerUnlocked = false
		$"Locks/Red Tiger Lock".visible = true
	if not (pinkUnlocked and blossomUnlocked and redTigerUnlocked):
		goldUnlocked = false
		$"Locks/Gold Lock".visible = true

	# Place the selected camo border over the correct camo
	moveBorder()

	# Set the stats
	$"Stats/Score Label".text = "HIGH SCORE: " + str(highScore).pad_zeros(9)
	$"Stats/Sanics Smashed Label".text = "SANICS SMASHED: " + str(sanicsSmashed).pad_zeros(9)
	$"Stats/Max Mults Label".text = "10x MULTIPLIERS REACHED: " + str(maxMultsReached).pad_zeros(9)

func _on_back_pressed() -> void:
	spawnHitmarker()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func spawnHitmarker() -> void:
	var hitmarker = HITMARKER.instantiate()
	hitmarker.global_position = get_viewport().get_mouse_position()
	add_child(hitmarker)

func _on_base_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("click") and equippedCamo != 0:
		spawnHitmarker()
		saveSystem.gunCamo = 0
		saveSystem.save()
		equippedCamo = 0
		reload_sniper()

func _on_pink_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("click") and equippedCamo != 1 and pinkUnlocked:
		spawnHitmarker()
		saveSystem.gunCamo = 1
		saveSystem.save()
		equippedCamo = 1
		reload_sniper()
	elif (event.is_action_pressed("click") and not pinkUnlocked):
		$AudioStreamPlayer2D.play()

func _on_blossom_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("click") and equippedCamo != 2 and blossomUnlocked:
		spawnHitmarker()
		saveSystem.gunCamo = 2
		saveSystem.save()
		equippedCamo = 2
		reload_sniper()
	elif (event.is_action_pressed("click") and not blossomUnlocked):
		$AudioStreamPlayer2D.play()

func _on_red_tiger_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("click") and equippedCamo != 3 and redTigerUnlocked:
		spawnHitmarker()
		saveSystem.gunCamo = 3
		saveSystem.save()
		equippedCamo = 3
		reload_sniper()
	elif (event.is_action_pressed("click") and not redTigerUnlocked):
		$AudioStreamPlayer2D.play()

func _on_gold_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("click") and equippedCamo != 4 and goldUnlocked:
		spawnHitmarker()
		saveSystem.gunCamo = 4
		saveSystem.save()
		equippedCamo = 4
		reload_sniper()
	elif (event.is_action_pressed("click") and not goldUnlocked):
		$AudioStreamPlayer2D.play()
		
func reload_sniper():
	moveBorder()
	$AudioStreamPlayer2D2.play()
	var sniperToErase = get_tree().get_nodes_in_group("Sniper")
	for sniper in sniperToErase:
		sniper.queue_free()
	sniperInstance = SNIPER.instantiate()
	add_child(SNIPER.instantiate())
	var sniperToAnimate = get_tree().get_nodes_in_group("Sniper")
	for sniper in sniperToAnimate:
		sniper.playRecoilAnim()
	
func moveBorder():
	match equippedCamo:
		0:
			$"Camo Select Border".global_position.x = 17
		1:
			$"Camo Select Border".global_position.x = 111
		2:
			$"Camo Select Border".global_position.x = 205
		3:
			$"Camo Select Border".global_position.x = 299
		4: 
			$"Camo Select Border".global_position.x = 393
	
