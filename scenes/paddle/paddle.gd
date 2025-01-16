class_name Paddle extends Area2D
## A Pong paddle.
##
## Created by: maxfieldev (2024)

## The height of the paddle.
const HEIGHT: float = 80.0
## The width of the paddle.
const WIDTH: float = 10.0
## The collision buffer given to the paddle on all sides.
const PADDLE_COLLISION_BUFFER: float = 3.0
## The color of the paddle, which uses the 
## [url=https://lospec.com/palette-list/1bit-monitor-glow]one-bit monitor glow palette.[/url]
const PADDLE_COLOR: Color = Color(0.94, 0.96, 0.94, 1.0)
## The speed of the paddle.
const SPEED: float = 800.0

## The size of the game window.
var screen_size: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Configure the paddle through code
	_configureLine2D()
	_configureCollisionShape2D()
	screen_size = get_viewport_rect().size

## Configures the paddle's visuals.
func _configureLine2D() -> void:
	var line2D: Line2D = $Line2D
	line2D.clear_points()
	line2D.add_point(Vector2.ZERO)
	line2D.add_point(Vector2(0, HEIGHT))
	line2D.width = WIDTH
	line2D.default_color = PADDLE_COLOR

## Configures the paddle's collision box.
func _configureCollisionShape2D() -> void:
	var collisionShape2D: CollisionShape2D = $CollisionShape2D
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(WIDTH+PADDLE_COLLISION_BUFFER, HEIGHT+PADDLE_COLLISION_BUFFER)
	collisionShape2D.shape = shape
	collisionShape2D.position = Vector2(0, HEIGHT/2.0)

## Updates the paddle by moving it up or down based on the provided [param direction][br]
## [param delta] is passed in so the movement speed is independent of frame rate.
func update(direction: float, delta: float) -> void:
	position.y += direction * SPEED * delta
	# Keep the paddle on screen
	position = position.clamp(Vector2.ZERO, Vector2(screen_size.x, screen_size.y-HEIGHT))
