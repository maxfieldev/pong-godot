extends Node2D

@onready var player1: Paddle = $Player1
@onready var player2: Paddle = $Player2
@onready var ball: Ball = $Ball

const PADDLE_SPACING_FROM_EDGE: float = 100
const SERVE_TIME: float = 1.5
const WINNING_THRESHOLD: int = 1

var player1_score: int = 0
var player2_score: int = 0
var screen_size: Vector2
var game_state = GameStates.START

enum GameStates {GAME, SERVE, GAME_OVER, START}
enum Player {PLAYER1, PLAYER2}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	player1.position = Vector2(PADDLE_SPACING_FROM_EDGE, screen_size.y/2)
	player2.position = Vector2(screen_size.x-PADDLE_SPACING_FROM_EDGE, screen_size.y/2)
	ball.reset()
	
	ball.scored.connect(_on_score)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var player1_dir: float = Input.get_axis("player1_up", "player1_down")
	player1.update(player1_dir, delta)
	
	var player2_dir: float = Input.get_axis("player2_up", "player2_down")
	player2.update(player2_dir, delta)
	
	if game_state == GameStates.GAME:
		ball.update(delta)
	elif game_state == GameStates.GAME_OVER && Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	elif game_state == GameStates.START && Input.is_action_just_pressed("start"):
		_serve_ball()

func _on_score() -> void:
	if _player1_scored():
		player1_score += 1
		if _winning_score(player1_score):
			_set_game_over(Player.PLAYER1)
			return
	else:
		player2_score += 1
		if _winning_score(player2_score):
			_set_game_over(Player.PLAYER2)
			return
	print("Player 1 Score: " + str(player1_score))
	print("Player 2 Score: " + str(player2_score))
	ball.reset()
	game_state = GameStates.SERVE
	get_tree().create_timer(SERVE_TIME).timeout.connect(_serve_ball)
	
func _serve_ball() -> void:
	game_state = GameStates.GAME
	
func _player1_scored() -> bool:
	return ball.position.x > screen_size.x+ball.WIDTH

func _winning_score(score: int) -> bool:
	return score >= WINNING_THRESHOLD

func _set_game_over(winner: Player) -> void:
	if winner == Player.PLAYER1:
		print("PLAYER 1 WINS!!!!")
	else:
		print("PLAYER 2 WINS!!!!")
	game_state = GameStates.GAME_OVER
