extends Control
class_name UI

@onready var scores: HBoxContainer = $Scores
@onready var message_menu: VBoxContainer = $MessageMenu
@onready var restart_game_message: Label = $MessageMenu/RestartGameMessage
@onready var title: Label = $MessageMenu/Title
@onready var subtitle: Label = $MessageMenu/Subtitle

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scores.visible = false
	restart_game_message.visible = false
	title.text = "PONG"
	subtitle.text = "Press enter to start the game"

func update_score(player: int, score: int) -> void:
	var player_score_text: Label = scores.get_children()[player]
	
	player_score_text.text = str(score)

func on_start_game() -> void:
	scores.visible = true
	message_menu.visible = false

func on_game_over(subtitle_message: String) -> void:
	message_menu.visible = true
	restart_game_message.visible = true
	
	title.text = "GAME OVER!!"
	subtitle.text = subtitle_message
	restart_game_message.text = "Press r to restart the game"
