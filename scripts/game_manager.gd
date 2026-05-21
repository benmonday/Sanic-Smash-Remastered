extends Node

# Get relevant nodes
const SANIC = preload("res://scenes/sanic.tscn")
const BOMB = preload("res://scenes/bomb.tscn")
const EMPTY_HEART = preload("res://assets/images/sprites/empty_heart.png")
const HITMARKER = preload("res://scenes/hitmarker.tscn")
const SMOKE = preload("res://scenes/smoke.tscn")
const EXPLOSION = preload("res://scenes/explosion.tscn")

@onready var score_label: Label = $"../HUD/Score Label"
@onready var multiplier_label: Label = $"../HUD/Multiplier Label"
@onready var multiplier_bar: TextureProgressBar = $"../HUD/Multiplier Bar"
@onready var life_1: TextureRect = $"../HUD/Lives/Life1"
@onready var life_2: TextureRect = $"../HUD/Lives/Life2"
@onready var life_3: TextureRect = $"../HUD/Lives/Life3"
@onready var holes = get_tree().get_nodes_in_group("Holes")

# Define signals
signal bombShot()
signal sanicShot(score:int)
signal missedShot()
signal multIncreased(multiplier: int)
signal gameOver(score: int)
signal sanicEscaped()

# Declare variables
var score = 0
var shownScore = 0
var maxSanics = 4
var liveSanics = 0
var lives = 3
var multiplier: int = 1
var multSegments = 0

# Create RNG
var rng = RandomNumberGenerator.new()

# On Ready, everything that needs to happen at the start
func _ready() -> void:
	# Change the music
	$"/root/Music".stream = preload("res://assets/audio/music/sanic.ogg")
	$"/root/Music".play()
	# Create the first Sanic
	addNewSanic()
	# Start the timer for another Sanic to spawn
	$"Add Sanic Timer".start()

# Run on physics process (not tied to frames)
func _physics_process(_delta: float) -> void:
	if shownScore < score:
		shownScore = shownScore + 5
	score_label.text = str(shownScore).pad_zeros(9)

# Logic to run when an event is received to check for a miss
func _input(event: InputEvent) -> void:
	# Get mouse position at event
	var mousePos = get_viewport().get_mouse_position()
	# Check if its a click
	if event.is_action_pressed("click"):
		var hit = false
		# Get all sanics
		var sanics = get_tree().get_nodes_in_group("Sanics")
		# If there are active sanics
		if sanics != null:
			# Iterate through the active sanics and see if click is within range of a Sanic
			for sanic in sanics:
				if detectSanicClick(mousePos, sanic.get_child(1).get_global_position()):
					hit = true
		# If the click did not hit a Sanic reset the multiplier
		if hit == false:
			print("Missed!")
			missedShot.emit()
			resetMultiplier()

# Detect if a mouse click was in range of a Sanic
func detectSanicClick(mousePos: Vector2, sanicPos: Vector2) -> bool:
	if mousePos.x >= sanicPos.x - 18 and mousePos.x <= sanicPos.x + 18 and mousePos.y >= sanicPos.y - 18 and mousePos.y <= sanicPos.y + 18:
		var hitmarker = HITMARKER.instantiate()
		hitmarker.global_position = mousePos
		add_child(hitmarker)
		return true
	else:
		return false

# Function to reset the multiplier
func resetMultiplier() -> void:
	multiplier = 1
	multSegments = 0
	multiplier_label.text = str(multiplier) + "x"
	multiplier_bar.value = 0

# Choose an available hole to spawn a Sanic
func chooseSpawnPoint() -> Node:
	var emptyHoles = []
	# Find which holes are currently empty
	for hole in holes:
		if hole.occupied:
			continue
		else:
			emptyHoles.append(hole)
	# Get a random hole from the list of empty holes
	var randomNum = rng.randi_range(0, emptyHoles.size() - 1)
	# Set the chosen hole to be occupied
	emptyHoles[randomNum].occupied = true
	# Return the chosen hole
	return emptyHoles[randomNum]
	
# Create a new Sanic in the chosen hole
func instantiateNewSanic(chosenHole: Node):
	# Choose if the next spawned object will be a bomb or a Sanic
	if rng.randi_range(0, 15) == 5:
		var instance = BOMB.instantiate()
		# Set the Bomb's position to the chosen hole
		instance.position = Vector2(chosenHole.pos.x, chosenHole.pos.y - 5)
		# Connect the smashed signal back to the game manager
		instance.connect("bombSmashed", Callable(self, "_on_bomb_smashed"))
		# Connect the timeout signal back to the game manager
		instance.connect("bombTimeout", Callable(self, "_on_bomb_timeout"))
		# Set the Bomb's occupied hole to the chosen hole
		instance.hole = chosenHole
		#Create the Bomb
		add_child(instance)
	else:
		# Instantiate a Sanic scene
		var instance = SANIC.instantiate()
		# Set the Sanic's position to the chosen hole
		instance.position = Vector2(chosenHole.pos.x, chosenHole.pos.y - 5)
		# Connect the smashed signal back to the game manager
		instance.connect("sanicSmashed", Callable(self, "_on_sanic_smashed"))
		# Connect the timeout signal back to the game manager
		instance.connect("sanicTimeout", Callable(self, "_on_sanic_timeout"))
		# Set the Sanic's occupied hole to the chosen hole
		instance.hole = chosenHole
		#Create the Sanic
		add_child(instance)

# Logic to execute when a Sanic is smashed
func _on_sanic_smashed(occupiedHole, isGold) -> void:
	# Reduce the live Sanic counter
	liveSanics = liveSanics - 1
	# Play smoke anim
	var smokeFX = SMOKE.instantiate()
	smokeFX.global_position = Vector2(occupiedHole.get_global_position().x, occupiedHole.get_global_position().y - 5)
	add_child(smokeFX)
	# Increase the score
	if isGold:
		score = score + (100 * multiplier)
	else:
		score = score + (10 * multiplier)
	score_label.text = "Score: " + str(score)
	# Emit signal with score to the event manager
	sanicShot.emit(score)
	# Increase the multiplier segment and multiplier if needed
	if multSegments < 10:
		multSegments = multSegments + 1
	if multSegments >= 10 and multiplier < 10:
		multiplier = multiplier + 1
		multSegments = 0
		multIncreased.emit(multiplier)
	multiplier_label.text = str(multiplier) + "x"
	multiplier_bar.value = multSegments
	# Call the function to create a new Sanic
	addNewSanic()
	# Set the hole the Sanic occupied to be empty (Done after instantiating to prevent respawning in the same hole)
	occupiedHole.occupied = false
	
# Add an additional Sanic to the game
func addNewSanic() -> void:
	instantiateNewSanic(chooseSpawnPoint())
	# Increment the live Sanics counter
	liveSanics = liveSanics + 1

func _on_add_sanic_timer_timeout() -> void:
	# If not at max Sanic's add another
	if liveSanics < maxSanics:
		addNewSanic()

func _on_sanic_timeout(occupiedHole, isGold) -> void:
	if not isGold:
		sanicEscaped.emit()
	# Reduce the live Sanic counter
	liveSanics = liveSanics - 1
	# Reset the multiplier
	resetMultiplier()
	# Remove a life if the Sanic is not gold
	if not isGold:
		lives = lives - 1
		if lives == 2:
			life_3.texture = EMPTY_HEART
		elif lives == 1:
			life_2.texture = EMPTY_HEART
		else:
			gameOver.emit(score)
			await get_tree().create_timer(0.5).timeout
			get_tree().change_scene_to_file("res://scenes/game_over.tscn")
	# Call the function to create a new Sanic
	addNewSanic()
	# Set the hole the Sanic occupied to be empty (Done after instantiating to prevent respawning in the same hole)
	occupiedHole.occupied = false

# Function for when a bomb is clicked
func _on_bomb_smashed(occupiedHole) -> void:
	# Emit signal to event manager
	bombShot.emit()
	# Play smoke anim
	var explosionFX = EXPLOSION.instantiate()
	explosionFX.global_position = Vector2(occupiedHole.get_global_position().x, occupiedHole.get_global_position().y - 7)
	add_child(explosionFX)
	# Reduce the live Sanic counter
	liveSanics = liveSanics - 1
	# Reset the multiplier
	resetMultiplier()
	# Remove a life
	lives = lives - 1
	if lives == 2:
		life_3.texture = EMPTY_HEART
	elif lives == 1:
		life_2.texture = EMPTY_HEART
	else:
		gameOver.emit(score)
		await get_tree().create_timer(1).timeout
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")
	# Call the function to create a new Sanic
	addNewSanic()
	# Set the hole the Bomb occupied to be empty (Done after instantiating to prevent respawning in the same hole)
	occupiedHole.occupied = false
	
# Function for when a bomb expires
func _on_bomb_timeout(occupiedHole) -> void:
	# Reduce the live Sanic counter
	liveSanics = liveSanics - 1
	# Call the function to create a new Sanic
	addNewSanic()
	# Set the hole the Bomb occupied to be empty (Done after instantiating to prevent respawning in the same hole)
	occupiedHole.occupied = false
