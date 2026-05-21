extends Sprite2D

var spawnPoint

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AudioStreamPlayer2D.play()

func _on_audio_stream_player_2d_finished() -> void:
	$AnimationPlayer.play("despawn")
	await get_tree().create_timer(0.5).timeout
	spawnPoint.occupied = false
	self.queue_free()
