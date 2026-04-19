extends CharacterBody2D


# Clamps
@export var max_abs_rotation_speed: float = 0.1
@export var max_speed: float = 10.0
@export var min_speed: float = 0.0

@onready var input_handler: Node2D = $InputHandler

var velocity_update: Vector2 = Vector2.ZERO
var spin_speed: float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    input_handler.new_velocity.connect(_on_new_velocity)
    input_handler.new_rotation_speed.connect(_on_new_rotation_speed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
    spin_speed = clamp(spin_speed * delta, -max_abs_rotation_speed, max_abs_rotation_speed)
    velocity += velocity_update * delta

    # Apply movement
    rotation += spin_speed
    move_and_slide()


func _on_new_velocity(new_velocity: Vector2) -> void:
    velocity_update = Vector2.ZERO
    velocity_update = (new_velocity.normalized() * new_velocity.length())
    velocity_update = velocity_update.clampf(min_speed, max_speed)

func _on_new_rotation_speed(rotation_speed: float) -> void:
    spin_speed += rotation_speed
