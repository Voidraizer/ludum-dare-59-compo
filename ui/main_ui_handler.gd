extends CanvasLayer


@export var input_label_prefab: PackedScene

@onready var input_container: Control = %InputLogger
@onready var heading_line = %HeadingLine
@onready var velocity_line = %VelocityLine
@onready var speedometer_graph = %SpeedometerGraph
@onready var speedometer_text = %SpeedometerText


# Called when the node enters the scene tree for the first time.
# func _ready() -> void:
#     pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    heading_line.pivot_offset = Vector2(heading_line.size.x / 2, heading_line.size.y / 2)
    velocity_line.pivot_offset = Vector2(velocity_line.size.x / 2, velocity_line.size.y / 2)


func _on_input_key_pressed(key_name: String, keycode: Key) -> void:
    if Globals.is_keycode_mapped(keycode):
        _show_input_label("Key: " + key_name)
    else:
        print("Keycode ", keycode, " is not mapped to any action in the Input Map.")


func _show_input_label(key: String, duration: String = "") -> void:
    var label = input_label_prefab.instantiate()
    label.text = key.to_upper() if not duration else key.to_upper() + " (" + duration + ")"
    input_container.add_child(label)


func _on_update_flight_metrics(_new_position: Vector2, velocity: Vector2, max_speed: float, rotation_current: float, _rotation_speed: float) -> void:
    # print("Velocity: ", velocity, " Max Speed: ", max_speed, " Rotation: ", rotation_current, " Rotation Speed: ", _rotation_speed)
    # Update speedometer line rotation based on velocity magnitude
    var speed = velocity.length()
    speedometer_text.text = str(int(speed * 10)) + " m/s"
    var seperator = max_speed / 11 # 11 because there are 11 sprites in the speedometer graph spritesheet
    var spritesheet_width_factor = 50 # Each sprite in the speedometer graph spritesheet is 50 pixels wide

    # Update line rotations and scales
    heading_line.rotation = rotation_current
    velocity_line.rotation = velocity.normalized().angle() + (PI / 2) if speed > 0 else 0.0 # Only update velocity line rotation if there is some velocity, otherwise default to 0 to avoid NaN issues
    velocity_line.scale.y = speed / max_speed if max_speed != 0 else 1.0 # Avoid division by zero, scale down to 0 if speed is 0, otherwise scale proportionally to speed

    match true:
        _ when speed <= seperator:
            speedometer_graph.texture.set_region(Rect2(0 * spritesheet_width_factor, 0, 50, 200))
        _ when speed <= seperator * 2:
            speedometer_graph.texture.set_region(Rect2(1 * spritesheet_width_factor, 0, 50, 200))
        _ when speed <= seperator * 3:
            speedometer_graph.texture.set_region(Rect2(2 * spritesheet_width_factor, 0, 50, 200))
        _ when speed <= seperator * 4:
            speedometer_graph.texture.set_region(Rect2(3 * spritesheet_width_factor, 0, 50, 200))
        _ when speed <= seperator * 5:
            speedometer_graph.texture.set_region(Rect2(4 * spritesheet_width_factor, 0, 50, 200))
        _ when speed <= seperator * 6:
            speedometer_graph.texture.set_region(Rect2(5 * spritesheet_width_factor, 0, 50, 200))
        _ when speed <= seperator * 7:
            speedometer_graph.texture.set_region(Rect2(6 * spritesheet_width_factor, 0, 50, 200))
        _ when speed <= seperator * 8:
            speedometer_graph.texture.set_region(Rect2(7 * spritesheet_width_factor, 0, 50, 200))
        _ when speed <= seperator * 9:
            speedometer_graph.texture.set_region(Rect2(8 * spritesheet_width_factor, 0, 50, 200))
        _ when speed <= seperator * 10:
            speedometer_graph.texture.set_region(Rect2(9 * spritesheet_width_factor, 0, 50, 200))
        _:
            speedometer_graph.texture.set_region(Rect2(10 * spritesheet_width_factor, 0, 50, 200))
