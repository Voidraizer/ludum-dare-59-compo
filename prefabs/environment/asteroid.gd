extends RigidBody2D


# Clamps
@export var max_abs_rotation_speed: float = 0.1
@export var max_speed: float = 6.0
@export var min_speed: float = 1.0
var velocity: Vector2 = Vector2.ZERO
var rotation_speed: float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    # Set a random rotation, rotation speed, and velocity
    rotation_speed = randf_range(-max_abs_rotation_speed, max_abs_rotation_speed)
    var angle = randf_range(0, 2 * PI)
    linear_velocity = Vector2(cos(angle), sin(angle)) * randf_range(min_speed, max_speed)
    angular_velocity = rotation_speed
