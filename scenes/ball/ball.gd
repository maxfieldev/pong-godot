extends Area2D
class_name Ball

const HEIGHT: float = 10
const WIDTH: float = 10
# One-bit monitor glow palette white color
const COLOR: Color = Color(0.94, 0.96, 0.94, 1.0)
const START_SPEED: float = 600
const SPEED_INCREASE_ON_HIT: float = 1.05

var direction: Vector2
var speed: float
var screen_size: Vector2

signal scored

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_configureLine2D()
	_configureCollisionShape2D()
	screen_size = get_viewport_rect().size
	speed = START_SPEED
	direction = Vector2([-1, 1].pick_random(), randf_range(-1, 1))
	direction = direction.normalized()
	area_entered.connect(_on_paddle_collision)

func _configureLine2D() -> void:
	var line2D: Line2D = $Line2D
	line2D.clear_points()
	line2D.add_point(Vector2.ZERO)
	line2D.add_point(Vector2(0, HEIGHT))
	line2D.width = WIDTH
	line2D.default_color = COLOR
	
func _configureCollisionShape2D() -> void:
	var collisionShape2D: CollisionShape2D = $CollisionShape2D
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(WIDTH, HEIGHT)
	collisionShape2D.shape = shape
	collisionShape2D.position = Vector2(0, HEIGHT/2)
	
func update(delta: float) -> void:
	if _did_collide_with_wall():
		direction.y = -direction.y
	position += direction * speed * delta
	if _ball_scored():
		emit_signal("scored")
	
func _did_collide_with_wall() -> bool:
	return position.y < 0 || position.y > screen_size.y-HEIGHT
	
func _on_paddle_collision(paddle: Area2D):
	paddle = paddle as Paddle
	speed *= SPEED_INCREASE_ON_HIT
	direction.x = -direction.x
	
	var ball_center: float = position.y + (HEIGHT/2)
	var paddle_center: float = paddle.position.y + (paddle.HEIGHT/2)
	var collision_diff: float = (ball_center - paddle_center) / (paddle.HEIGHT/2)
	collision_diff = clampf(collision_diff, -1, 1)
	direction.y = collision_diff
	direction = direction.normalized()
	
func _ball_scored() -> bool:
	return position.x < -WIDTH || position.x > screen_size.x+WIDTH
