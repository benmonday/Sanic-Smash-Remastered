extends Marker2D

var pos
var occupied = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pos = self.get_global_position()
