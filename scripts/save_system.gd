extends Node

var savePath = "user://SanicSmashSaveData.save"

var highScore: int = 0
var sanicsSmashed: int = 0
var maxMultsReached: int = 0
var gunCamo: int = 0
var lastScore: int = 0

func save():
	var file = FileAccess.open(savePath, FileAccess.WRITE)
	file.store_var(highScore)
	file.store_var(sanicsSmashed)
	file.store_var(maxMultsReached)
	file.store_var(gunCamo)
	file.store_var(lastScore)
	file.close()
	
func load_save():
	if FileAccess.file_exists(savePath):
		var file = FileAccess.open(savePath, FileAccess.READ)
		highScore = file.get_var(highScore)
		sanicsSmashed = file.get_var(sanicsSmashed)
		maxMultsReached = file.get_var(maxMultsReached)
		gunCamo = file.get_var(gunCamo)
		lastScore = file.get_var(lastScore)
		#print("Save Data Found!\nHighscore: " + str(highScore) + "\nSanics Smashed: " + str(sanicsSmashed) + "\n 10x Mults Reached: " + str(maxMultsReached) + "\nEquipped Camo: " + str(gunCamo))
		file.close()
	else:
		#print("No Save Data Found")
		highScore = 0
		sanicsSmashed = 0
		maxMultsReached = 0
		gunCamo = 0
		lastScore = 0
		
func _ready() -> void:
	load_save()
