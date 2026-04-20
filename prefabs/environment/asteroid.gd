extends RigidBody2D


# Clamps
@export var max_abs_rotation_speed: float = 0.1
@export var max_speed: float = 6.0
@export var min_speed: float = 1.0
var velocity: Vector2 = Vector2.ZERO
var rotation_speed: float = 0.0
var world_size: Vector2 = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    # Set a random rotation, rotation speed, and velocity
    rotation_speed = randf_range(-max_abs_rotation_speed, max_abs_rotation_speed)
    var angle = randf_range(0, 2 * PI)
    linear_velocity = Vector2(cos(angle), sin(angle)) * randf_range(min_speed, max_speed)
    angular_velocity = rotation_speed


func set_world_size(world: Vector2) -> void:
    world_size = world


func _physics_process(_delta: float) -> void:
    # If the asteroid is moving out of bounds, give it a push back towards the center
    if global_position.x < -world_size.x / 2:
        linear_velocity.x = abs(linear_velocity.x)
    elif global_position.x > world_size.x / 2:
        linear_velocity.x = -abs(linear_velocity.x)
    
    if global_position.y < -world_size.y / 2:
        linear_velocity.y = abs(linear_velocity.y)
    elif global_position.y > world_size.y / 2:
        linear_velocity.y = -abs(linear_velocity.y)