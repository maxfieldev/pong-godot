extends Area2D

const HEIGHT: int = 80
const WIDTH: int = 10
const PADDLE_COLLISION_BUFFER: int = 3


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_configureLine2D()
	_configureCollisionShape2D()

func _configureLine2D() -> void:
	var line2D: Line2D = $Line2D
	line2D.clear_points()
	line2D.add_point(Vector2.ZERO)
	line2D.add_point(Vector2(0, HEIGHT))
	line2D.width = WIDTH
	# One-bit monitor glow palette white color
	line2D.default_color = Color(0.94, 0.96, 0.94, 1.0)
	
func _configureCollisionShape2D() -> void:
	var collisionShape2D: CollisionShape2D = $CollisionShape2D
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(WIDTH+PADDLE_COLLISION_BUFFER, HEIGHT+PADDLE_COLLISION_BUFFER)
	collisionShape2D.shape = shape
	collisionShape2D.position = Vector2(0, HEIGHT/2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
