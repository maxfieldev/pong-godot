extends Area2D
class_name Paddle

const HEIGHT: int = 80
const WIDTH: int = 10
const PADDLE_COLLISION_BUFFER: int = 3
# One-bit monitor glow palette white color
const PADDLE_COLOR: Color = Color(0.94, 0.96, 0.94, 1.0)
const SPEED: float = 400

var screen_size: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_configureLine2D()
	_configureCollisionShape2D()
	screen_size = get_viewport_rect().size

func _configureLine2D() -> void:
	var line2D: Line2D = $Line2D
	line2D.clear_points()
	line2D.add_point(Vector2.ZERO)
	line2D.add_point(Vector2(0, HEIGHT))
	line2D.width = WIDTH
	line2D.default_color = PADDLE_COLOR
	
func _configureCollisionShape2D() -> void:
	var collisionShape2D: CollisionShape2D = $CollisionShape2D
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(WIDTH+PADDLE_COLLISION_BUFFER, HEIGHT+PADDLE_COLLISION_BUFFER)
	collisionShape2D.shape = shape
	collisionShape2D.position = Vector2(0, HEIGHT/2)
	
func update(direction: float, delta: float) -> void:
	position.y += direction * SPEED * delta
	position = position.clamp(Vector2.ZERO, Vector2(screen_size.x, screen_size.y-HEIGHT))
