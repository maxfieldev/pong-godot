class_name UI extends Control
## Handles the user interface for Pong.
## 
## Created by: maxfieldev (2024)

## The player scores.
@onready var scores: HBoxContainer = $Scores
## The menu used for the start / game over messages.
@onready var message_menu: VBoxContainer = $MessageMenu
## Message to restart the game on game over.
@onready var restart_game_message: Label = $MessageMenu/RestartGameMessage
## The [member message_menu] title.
@onready var title: Label = $MessageMenu/Title
## The [member message_menu] subtitle.
@onready var subtitle: Label = $MessageMenu/Subtitle

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Configure for the start game message
	scores.visible = false
	restart_game_message.visible = false
	title.text = "PONG"
	subtitle.text = "Press enter to start the game"

## Updates the [member scores] labels with the given [param player]'s given [param score].
func update_score(player: int, score: int) -> void:
	var player_score_text: Label = scores.get_children()[player]
	player_score_text.text = str(score)

## Updates the UI when the game starts.
func on_start_game() -> void:
	scores.visible = true
	message_menu.visible = false

## Updates the UI when the game is over. The given [param subtitle_message] displays
## which player won the game.
func on_game_over(subtitle_message: String) -> void:
	message_menu.visible = true
	restart_game_message.visible = true
	
	title.text = "GAME OVER!!"
	subtitle.text = subtitle_message
	restart_game_message.text = "Press r to restart the game"
