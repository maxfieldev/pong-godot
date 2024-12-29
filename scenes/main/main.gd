extends Node2D

@onready var player1: Paddle = $Player1
@onready var player2: Paddle = $Player2
@onready var ball: Ball = $Ball
@onready var ui: UI = $CanvasLayer/UI
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

const PADDLE_SPACING_FROM_EDGE: float = 100
const SERVE_TIME: float = 1.5
const WINNING_THRESHOLD: int = 10
const NETTING_COLOR: Color = Color(0.94, 0.96, 0.94, 1.0)
const NETTING_WIDTH: float = 6
const NETTING_DASH: float = 25

var player1_score: int = 0
var player2_score: int = 0
var screen_size: Vector2
var game_state = GameStates.START
var sounds: Dictionary = {
	"score": preload("res://scenes/main/pong_score.wav"),
	"win": preload("res://scenes/main/pong_win.wav")
}

enum GameStates {GAME, SERVE, GAME_OVER, START}
enum Player {PLAYER1 = 0, PLAYER2 = 1}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	player1.position = Vector2(PADDLE_SPACING_FROM_EDGE, screen_size.y/2)
	player2.position = Vector2(screen_size.x-PADDLE_SPACING_FROM_EDGE, screen_size.y/2)
	ball.visible = false
	ball.reset()
	
	ball.scored.connect(_on_score)
	audio_player.stream = sounds["score"]

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
		ball.visible = true
		ui.on_start_game()
		queue_redraw()

func _draw() -> void:
	if game_state == GameStates.GAME:
		draw_table_netting()

func _on_score() -> void:
	if _player1_scored():
		player1_score += 1
		ui.update_score(Player.PLAYER1, player1_score)
		if _winning_score(player1_score):
			_set_game_over(Player.PLAYER1)
			return
	else:
		player2_score += 1
		ui.update_score(Player.PLAYER2, player2_score)
		if _winning_score(player2_score):
			_set_game_over(Player.PLAYER2)
			return
	ball.reset()
	audio_player.play()
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
		ui.on_game_over("Player 1 WINS!!")
	else:
		ui.on_game_over("Player 2 WINS!!")
	game_state = GameStates.GAME_OVER
	audio_player.stream = sounds["win"]
	audio_player.play()
	queue_redraw()

func draw_table_netting() -> void:
	var top_middle_of_screen: Vector2 = Vector2(screen_size.x/2, 0)
	var btm_middle_of_screen: Vector2 = Vector2(screen_size.x/2, screen_size.y)
	draw_dashed_line(top_middle_of_screen, btm_middle_of_screen, NETTING_COLOR, NETTING_WIDTH, NETTING_DASH)
