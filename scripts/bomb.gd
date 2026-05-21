extends Area2D

var hole

signal bombSmashed(occupiedHole)
signal bombTimeout(occupiedHole)

func _ready() -> void:
	$AnimationPlayer.play("spawn")

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		#print("Clicked Bomb!")
		bombSmashed.emit(hole)
		self.queue_free()

func _on_expiration_timer_timeout() -> void:
	$AnimationPlayer.play("timeout")
	#print("Bomb Timed Out!")
	await get_tree().create_timer(0.5).timeout
	bombTimeout.emit(hole)
	self.queue_free()
