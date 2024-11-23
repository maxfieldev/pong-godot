extends Node2D

@onready var player1: Paddle = $Player1
@onready var player2: Paddle = $Player2

const PADDLE_SPACING_FROM_EDGE: float = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var screen_size: Vector2 = get_viewport_rect().size
	player1.position = Vector2(PADDLE_SPACING_FROM_EDGE, screen_size.y/2)
	player2.position = Vector2(screen_size.x-PADDLE_SPACING_FROM_EDGE, screen_size.y/2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var player1_dir: float = Input.get_axis("player1_up", "player1_down")
	player1.update(player1_dir, delta)
	
	var player2_dir: float = Input.get_axis("player2_up", "player2_down")
	player2.update(player2_dir, delta)
