class_name PongGame extends Node2D
## Controller for the Pong game.
##
## This class controls all the core game logic, such as input handling, 
## keeping track of game states, etc.[br][br]
## Created by: maxfieldev (2024)
## @tutorial(Pong in Godot 4 Tutorial Series): https://youtube.com/playlist?list=PLtrIO9PX6m-yF-c7kf81erxjQz-Ii28Cu&si=OPdw7tCb14uQ4LdR

## The [Paddle] controlled by player 1.
@onready var player1: Paddle = $Player1
## The [Paddle] controlled by player 2.
@onready var player2: Paddle = $Player2
## The [Ball].
@onready var ball: Ball = $Ball
## In charge of displaying the score and start / game over messages.
@onready var ui: UI = $CanvasLayer/UI
## Plays audio when there is a score and when the game is over.
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

## The amount of spacing each paddle has from the edge of the screen.
const PADDLE_SPACING_FROM_EDGE: float = 100.0
## The time delay after the [member ball] is scored.
const SERVE_TIME: float = 1.5
## The number of scores to win the game.
const WINNING_THRESHOLD: int = 10
## The color of the table netting drawn down the middle of the screen, which uses the
## [url=https://lospec.com/palette-list/1bit-monitor-glow]one-bit monitor glow palette.[/url]
const NETTING_COLOR: Color = Color(0.94, 0.96, 0.94, 1.0)
## The width of the line used for the table netting.
const NETTING_WIDTH: float = 6.0
## The dash for the table netting.
const NETTING_DASH: float = 25.0

## Player 1's current score.
var player1_score: int = 0
## Player 2's current score.
var player2_score: int = 0
## The size of the game window.
var screen_size: Vector2
## The current game state.
var game_state: GameStates = GameStates.START
## Holds different sounds to be played by the [member audio_player].
var sounds: Dictionary = {
	"score": preload("res://scenes/main/pong_score.wav"),
	"win": preload("res://scenes/main/pong_win.wav")
}

## The different game states for Pong.
enum GameStates {GAME, SERVE, GAME_OVER, START}
## Used to dictate what actions to take based on which player triggered them, prevents
## the use of strings.
enum Player {PLAYER1 = 0, PLAYER2 = 1}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	player1.position = Vector2(PADDLE_SPACING_FROM_EDGE, screen_size.y/2.0)
	player2.position = Vector2(screen_size.x-PADDLE_SPACING_FROM_EDGE, screen_size.y/2.0)
	ball.visible = false
	ball.reset()
	
	ball.scored.connect(_on_score)
	audio_player.stream = sounds["score"]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# We always allow the players to move
	var player1_dir: float = Input.get_axis("player1_up", "player1_down")
	player1.update(player1_dir, delta)
	
	var player2_dir: float = Input.get_axis("player2_up", "player2_down")
	player2.update(player2_dir, delta)
	
	# The ball only moves during the game state
	if game_state == GameStates.GAME:
		ball.update(delta)
	elif game_state == GameStates.GAME_OVER && Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	elif game_state == GameStates.START && Input.is_action_just_pressed("start"):
		_serve_ball()
		ball.visible = true
		ui.on_start_game()
		# Draw the table netting
		queue_redraw()

func _draw() -> void:
	if game_state == GameStates.GAME:
		draw_table_netting()

## Handles when the [member ball] is scored. When the [member ball] is scored, we:[br]
## 1. Update the player scores.[br]
## 2. Check to see if there is a winning score.[br]
## 3. If there is not a winning score, reset the ball and start the next serve.
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

## Serves the ball.
func _serve_ball() -> void:
	game_state = GameStates.GAME

## Detects if [member player1] scored. Player 1 scored if the ball moved off the right side
## of the screen.
func _player1_scored() -> bool:
	return ball.position.x > screen_size.x+ball.WIDTH

## Detects if the given [param score] is a winning score.
func _winning_score(score: int) -> bool:
	return score >= WINNING_THRESHOLD

## Handles setting the game over state. We:[br]
## 1. Tell the [member ui] to display which [enum Player] won.[br]
## 2. Set the [member game_state] to be the game over state.
func _set_game_over(winner: Player) -> void:
	if winner == Player.PLAYER1:
		ui.on_game_over("Player 1 WINS!!")
	else:
		ui.on_game_over("Player 2 WINS!!")
	game_state = GameStates.GAME_OVER
	audio_player.stream = sounds["win"]
	audio_player.play()
	## No longer want to draw the table netting
	queue_redraw()

## Draws a table netting down the middle of the screen.
func draw_table_netting() -> void:
	var top_middle_of_screen: Vector2 = Vector2(screen_size.x/2.0, 0)
	var btm_middle_of_screen: Vector2 = Vector2(screen_size.x/2.0, screen_size.y)
	draw_dashed_line(top_middle_of_screen, btm_middle_of_screen, NETTING_COLOR, NETTING_WIDTH, NETTING_DASH)
