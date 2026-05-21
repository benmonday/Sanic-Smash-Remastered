extends Area2D

@onready var sanicSprite: AnimatedSprite2D = $Sanic

var hole
var gold = false
var rng = RandomNumberGenerator.new()

signal sanicSmashed(occupiedHole, isGold)
signal sanicTimeout(occupiedHole, isGold)

func _ready() -> void:
	# Roll for a chance at being a gold Sanic
	if rng.randi_range(0, 100) == 57:
		gold = true
		$ExpirationTimer.wait_time = 2
		sanicSprite.play("gold_idle")
	# Play spawn animation
	$AnimationPlayer.play("spawn")
	# Start timer
	$ExpirationTimer.start()

# Play animations randomly
func _physics_process(_delta: float) -> void:
	if rng.randi_range(0, 100) == 57:
		var rand = rng.randi_range(0, 1)
		if rand == 0 and gold:
			sanicSprite.play("gold_eye_dart")
		elif rand == 0 and not gold:
			sanicSprite.play("eye_dart")
		elif rand == 1 and gold:
			sanicSprite.play("gold_blink")
		elif rand == 1 and not gold:
			sanicSprite.play("blink")

# If a Sanic is shot
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		sanicSmashed.emit(hole, gold)
		self.queue_free()

# If a Sanic times out
func _on_expiration_timer_timeout() -> void:
	$AnimationPlayer.play("timeout")
	await get_tree().create_timer(0.5).timeout
	sanicTimeout.emit(hole, gold)
	self.queue_free()
