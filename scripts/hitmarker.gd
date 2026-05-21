extends Sprite2D

# Play sound when spawned
func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	self.queue_free()

	
