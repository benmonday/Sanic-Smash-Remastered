extends AnimatedSprite2D

@onready var save_system: Node = $"Save System"
@onready var camo = save_system.gunCamo

var idleAnimation: String = "idle"
var recoilAnimation: String = "recoil"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match camo:
		0:
			idleAnimation = "idle"
			recoilAnimation = "recoil"
		1:
			idleAnimation = "pink_idle"
			recoilAnimation = "pink_recoil"
		2:
			idleAnimation = "blossom_idle"
			recoilAnimation = "blossom_recoil"
		3:
			idleAnimation = "redtiger_idle"
			recoilAnimation = "redtiger_recoil"
		4:
			idleAnimation = "gold_idle"
			recoilAnimation = "gold_recoil"
	self.play(idleAnimation)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		self.play(recoilAnimation)
		$"/root/SniperSfx".play()
		$Timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var mousePos = get_viewport().get_mouse_position()
	if mousePos.x <= 480 and mousePos.x >= 0 and mousePos.y <= 270 and mousePos.y >= 0:
		self.position.x = 380 + mousePos.x/10
		self.position.y = 210 + mousePos.y/10

func _on_timer_timeout() -> void:
	self.play(idleAnimation)
	
func playRecoilAnim():
	self.play(recoilAnimation)
