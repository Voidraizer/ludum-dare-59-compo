extends CharacterBody2D


# Clamps
@export var max_abs_rotation_speed: float = 0.1
@export var max_speed: float = 60.0

@onready var input_handler: Node2D = $InputHandler
@onready var health_handler: Node2D = $Health

var raw_velocity_update: Vector2 = Vector2.ZERO
var raw_rotation_update: float = 0.0
var processed_rotation_update: float = 0.0

signal update_flight_metrics(position: Vector2, velocity: Vector2, max_speed: float, rotation: float, rotation_speed: float)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    input_handler.new_velocity.connect(_on_new_velocity)
    input_handler.new_rotation_speed.connect(_on_new_rotation_speed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
    velocity += raw_velocity_update * delta
    velocity = velocity if velocity.length() <= max_speed else velocity.normalized() * max_speed

    # Apply movement
    processed_rotation_update += raw_rotation_update * delta
    processed_rotation_update = clamp(processed_rotation_update, -max_abs_rotation_speed, max_abs_rotation_speed)
    # print("Applying changes in raw_velocity_update: ", raw_velocity_update, " velocity: ", velocity)
    # print("Applying changes in raw_rotation_update: ", raw_rotation_update, " processed_rotation_update: ", processed_rotation_update, " rotation: ", rotation)
    rotation += processed_rotation_update

    # move_and_slide()
    # var coll = get_last_slide_collision()

    # if coll and coll.get_collider().is_in_group("Asteroid"):
    #     _on_asteroid_collision()

    var collision = move_and_collide(velocity)

    if collision and collision.get_collider().is_in_group("Asteroid"):
        velocity = Vector2.ZERO
        processed_rotation_update = 0.0
        _on_asteroid_collision(collision)

    emit_signal("update_flight_metrics", global_position, velocity, max_speed, rotation, processed_rotation_update)


func _on_new_velocity(new_velocity: Vector2) -> void:
    raw_velocity_update = new_velocity


func _on_new_rotation_speed(rotation_speed: float) -> void:
    raw_rotation_update = rotation_speed


func enable_camera() -> void:
    $Camera2D.enabled = true
    $Camera2D.make_current()


func _on_asteroid_collision(collision: KinematicCollision2D) -> void:
    print("Collided with asteroid")
    collision.get_collider().queue_free()
    health_handler.lose_health()
