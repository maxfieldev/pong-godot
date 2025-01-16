class_name Ball extends Area2D
## A ball for Pong.
##
## Created by: maxfieldev (2024)

## Plays a sound whenever the ball is hit.
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

## The height of the ball.
const HEIGHT: float = 10.0
## The width of the ball.
const WIDTH: float = 10.0
## The color of the ball, which uses the 
## [url=https://lospec.com/palette-list/1bit-monitor-glow]one-bit monitor glow palette.[/url]
const COLOR: Color = Color(0.94, 0.96, 0.94, 1.0)
## The ball's start speed.
const START_SPEED: float = 600.0
## The multiplier for the speed increase each time the ball is hit by a paddle.
## [br]Makes the game more difficult as a rally continues.
const SPEED_INCREASE_ON_HIT: float = 1.05

## The current direction the ball is moving in.
var direction: Vector2
## The current speed of the ball.
var speed: float
## The size of the game window.
var screen_size: Vector2
## The sound played whenever the ball is hit.
var pong_hit_sound: AudioStream = preload("res://scenes/ball/pong_hit.wav")

## Signal emitted when the ball is scored.
signal scored

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_configureLine2D()
	_configureCollisionShape2D()
	screen_size = get_viewport_rect().size
	# Pick a random player to serve to
	direction.x = [-1.0, 1.0].pick_random()
	area_entered.connect(_on_paddle_collision)
	audio_player.stream = pong_hit_sound

## Configures the ball's visuals.
func _configureLine2D() -> void:
	var line2D: Line2D = $Line2D
	line2D.clear_points()
	line2D.add_point(Vector2.ZERO)
	line2D.add_point(Vector2(0, HEIGHT))
	line2D.width = WIDTH
	line2D.default_color = COLOR

## Configures the ball's collision box.
func _configureCollisionShape2D() -> void:
	var collisionShape2D: CollisionShape2D = $CollisionShape2D
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(WIDTH, HEIGHT)
	collisionShape2D.shape = shape
	collisionShape2D.position = Vector2(0, HEIGHT/2.0)

## Updates the paddle by moving it in its current [member direction] at its
## current [member speed].[br]
## The ball changes its [member direction] when a collision occurs, and emits
## the [signal scored] signal when scored.
func update(delta: float) -> void:
	if _did_collide_with_wall():
		direction.y = -direction.y
		audio_player.play()
	position += direction * speed * delta
	if _ball_scored():
		emit_signal("scored")

## Detects if the ball collided with a wall, with the wall being the screen bounds.
func _did_collide_with_wall() -> bool:
	return position.y < 0 || position.y > screen_size.y-HEIGHT

## Handles when the ball collides with a [Paddle].
## When the ball collides with the given [param paddle], we:[br]
## 1. Increase the ball's speed by [constant SPEED_INCREASE_ON_HIT].[br]
## 2. Change the ball's x-direction.[br]
## 3. Change the ball's y-direction based on how far from the center it collided with the [param paddle].
## The further from the center, the more of an angle it gets.
func _on_paddle_collision(paddle: Area2D):
	paddle = paddle as Paddle
	speed *= SPEED_INCREASE_ON_HIT
	direction.x = -direction.x
	
	# Calculate how far from the center of the paddle the ball collided, and set the
	# new y direction accordingly
	var ball_center: float = position.y + (HEIGHT/2.0)
	var paddle_center: float = paddle.position.y + (paddle.HEIGHT/2.0)
	var collision_diff: float = (ball_center - paddle_center) / (paddle.HEIGHT/2.0)
	# Clamp to account for edge case where can be slightly > 1 or < -1
	collision_diff = clampf(collision_diff, -1.0, 1.0)
	direction.y = collision_diff
	# Normalize to move at consistent speed despite different direction
	direction = direction.normalized()
	audio_player.play()

## Detects if the ball has been scored. The ball has been scored if it goes off the left
## or right side of the screen.
func _ball_scored() -> bool:
	return position.x < -WIDTH || position.x > screen_size.x+WIDTH

## Resets the ball by:[br]
## 1. Setting its position back to the middle.[br]
## 2. Setting its speed back to [constant START_SPEED].[br]
## 3. Moving the ball in a new random y-direction, the x-direction stays the same
## as we let winners serve.
func reset() -> void:
	position = Vector2(screen_size.x/2.0, screen_size.y/2.0)
	speed = START_SPEED
	direction.y = randf_range(-1.0, 1.0)
	direction = direction.normalized()
