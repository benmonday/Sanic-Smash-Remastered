extends Node

@onready var save_system: Node = $"../Save System"
@onready var spawnPoints = get_tree().get_nodes_in_group("Object Spawn Points")

# Event Objects
const AIRHORN = preload("res://scenes/event_objects/airhorn.tscn")
const DORITOS = preload("res://scenes/event_objects/doritos.tscn")
const FAZE = preload("res://scenes/event_objects/faze.tscn")
const GLASSES = preload("res://scenes/event_objects/glasses.tscn")
const ILLUMINATI = preload("res://scenes/event_objects/illuminati.tscn")
const MLG = preload("res://scenes/event_objects/mlg.tscn")
const MTNDEW = preload("res://scenes/event_objects/mtndew.tscn")
const WEED = preload("res://scenes/event_objects/weed.tscn")

var eventObjects = [AIRHORN, DORITOS, FAZE, GLASSES, ILLUMINATI, MLG, MTNDEW, WEED]
var lastObject = null
var sanicsShot = 0
var smokingWeed = false

# Create RNG
var rng = RandomNumberGenerator.new()

# Play sound when a bomb is shot
func _on_game_manager_bomb_shot() -> void:
	$BombSFX.play()
	if smokingWeed:
		$"Smoke Weed Song".stop()
		_on_smoke_weed_song_finished()

# Play sounds when multiplier is increased
func _on_game_manager_mult_increased(multiplier: int) -> void:
	if multiplier == 3:
		$TripleSFX.play()
	elif multiplier == 6:
		$WomboSFX.play()
	elif multiplier == 10:
		smokingWeed = true
		$"/root/Music".stream_paused = true
		AudioServer.set_bus_mute(3, not AudioServer.is_bus_mute(3))
		$"Smoke Weed Song".play()
		$"../Blunt".visible = true
		$"../Green Filter".visible = true
		save_system.maxMultsReached = save_system.maxMultsReached + 1

# Spawn event objects when a Sanic is shot
func _on_game_manager_sanic_shot(_score: Variant) -> void:
	sanicsShot = sanicsShot + 1
	if rng.randf() >= 0.77:
		spawnObject(chooseSpawnPoint())

# Play sounds and save data when game is ending
func _on_game_manager_game_over(score: int) -> void:
	# Update persistent data and save it
	save_system.lastScore = score
	if score > save_system.highScore:
		save_system.highScore = score
	save_system.sanicsSmashed = save_system.sanicsSmashed + sanicsShot
	save_system.save()

# Function to spawn an event object
func spawnObject(chosenSpawnPoint: Node) -> void:
	# Choose a random object to spawn
	var chosenObject
	while true:
		chosenObject = eventObjects[rng.randi_range(0, eventObjects.size() - 1)]
		if chosenObject != lastObject:
			lastObject = chosenObject
			break
	# Instantiate the chosen object
	var instance = chosenObject.instantiate()
	# Set the Object's position to the spawn point
	instance.position = Vector2(chosenSpawnPoint.pos.x, chosenSpawnPoint.pos.y)
	# Set the Object's spawn point to the chosen spawn point
	instance.spawnPoint = chosenSpawnPoint
	# Create the Object
	add_child(instance)

# Function to choose an empty spawn point
func chooseSpawnPoint() -> Node:
	var emptySpawnPoints = []
	# Find which spawn points are currently empty
	for spawnPoint in spawnPoints:
		if spawnPoint.occupied:
			continue
		else:
			emptySpawnPoints.append(spawnPoint)
	if emptySpawnPoints.size() == 0:
		return spawnPoints[0]
	# Get a random hole from the list of empty holes
	var randomNum = rng.randi_range(0, emptySpawnPoints.size() - 1)
	# Set the chosen hole to be occupied
	emptySpawnPoints[randomNum].occupied = true
	# Return the chosen hole
	return emptySpawnPoints[randomNum]

# When song ends resume music
func _on_smoke_weed_song_finished() -> void:
	AudioServer.set_bus_mute(3, not AudioServer.is_bus_mute(3))
	$"/root/Music".stream_paused = false
	$"../Blunt".visible = false
	$"../Green Filter".visible = false
	smokingWeed = false

# Shot missed
func _on_game_manager_missed_shot() -> void:
	if smokingWeed:
		$"Smoke Weed Song".stop()
		_on_smoke_weed_song_finished()
	
# Sanic escaped
func _on_game_manager_sanic_escaped() -> void:
	$"Sanic Escaped SFX".play()
	if smokingWeed:
		$"Smoke Weed Song".stop()
		_on_smoke_weed_song_finished()
