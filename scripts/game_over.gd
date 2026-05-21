extends Control

const HITMARKER = preload("res://scenes/hitmarker.tscn")

@onready var save_system: Node = $"Save System"
@onready var highScore = save_system.highScore
@onready var lastScore = save_system.lastScore

func _ready() -> void:
	# Check if it was a winning game
	if lastScore >= 50000:
		$Sky.texture = preload("res://assets/images/backgrounds/menu_gradient.png")
		$"Game Over Label".visible = false
		$"You Win Label".visible = true
		$"/root/Music".stream = preload("res://assets/audio/music/smokeweedsongfull.ogg")
		$Sanic.visible = false
		$Chungo.visible = true
		$"Desc Label".text = "Agent B.C. has\nneutralized the targets..."
	else:
		$"/root/Music".stream = preload("res://assets/audio/music/sadviolin.ogg")
	$"/root/Music".play()
	# Set the score
	$"Score Labels/Score Label".text = str(lastScore).pad_zeros(9)
	# Show the high score label if it was a highscore
	if lastScore == highScore:
		$"Score Labels/New High Score Label".visible = true

# Play Again Button Pressed
func _on_play_again_pressed() -> void:
	spawnHitmarker()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://scenes/game.tscn")

# Menu Button Pressed
func _on_menu_pressed() -> void:
	spawnHitmarker()
	await get_tree().create_timer(0.3).timeout
	$"/root/Music".stream = preload("res://assets/audio/music/myhopewillneverdie.ogg")
	$"/root/Music".play()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func spawnHitmarker() -> void:
	var hitmarker = HITMARKER.instantiate()
	hitmarker.global_position = get_viewport().get_mouse_position()
	add_child(hitmarker)
