extends Line2D


var start_position: Vector2 = Vector2.ZERO # Satellite dish position
var end_position: Vector2 = Vector2.ZERO # Player position
var growing: bool = false # Whether the laser is growing
var shrinking: bool = false # Whether the laser is shrinking
var my_keycode: Key # The keycode associated with this laser, if any
var laser_start_time: float = 0.0 # Time when the laser started growing
var laser_key_released_time: float = 0.0 # Time when the trigger key was released
var waiting_for_key_release: bool = true # flip this on first release so we can handle repeated inputs of the same keycode

#TODO add a small variance on the start and maybe end positions so you can see multiple lasers without perfect overlap

# Called when the node enters the scene tree for the first time.
# func _ready() -> void:
#     clear_points()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    if points.size() < 2:
        print("Laser has ", points.size(), " points. This should not happen.")
        return

    var laser_end_point_duration = Time.get_ticks_msec() - laser_start_time
    var laser_start_point_duration = Time.get_ticks_msec() - laser_key_released_time

    if growing and shrinking:
        print("Warning: Laser is both growing and shrinking. This should not happen.")

    
    var direction = (end_position - start_position).normalized()

    if (not growing and not shrinking):
        var end_progress = (laser_end_point_duration / (Globals.input_delay_in_seconds * 1000))
        end_progress = end_progress if end_progress <= 1.0 else 1.0
        var end_length = end_progress * (end_position - start_position).length()
        # print("Laser steady. End Progress: ", end_progress)

        var current_end = start_position + direction * end_length

        set_point_position(1, current_end)

        if end_progress >= 1.0 and not waiting_for_key_release:
            shrinking = true

        var current_start = start_position

        if not waiting_for_key_release:
            var start_progress = (laser_start_point_duration / (Globals.input_delay_in_seconds * 1000))
            start_progress = start_progress if start_progress <= 1.0 else 1.0
            var start_length = start_progress * (end_position - start_position).length()
            # print("Laser steady. Start Progress: ", start_progress)

            current_start = start_position + direction * start_length

        set_point_position(0, current_start)
    elif growing:
        var progress = (laser_end_point_duration / (Globals.input_delay_in_seconds * 1000))
        progress = progress if progress <= 1.0 else 1.0
        var length = progress * (end_position - start_position).length()
        # print("Laser growing. Progress: ", progress)

        var current_end = start_position + direction * length

        set_point_position(0, start_position)
        set_point_position(1, current_end)

        if progress >= 1.0:
            growing = false

            if not waiting_for_key_release:
                shrinking = true

    elif shrinking:
        var current_start = start_position

        if not waiting_for_key_release:
            var progress = (laser_start_point_duration / (Globals.input_delay_in_seconds * 1000))
            progress = progress if progress <= 1.0 else 1.0
            var length = progress * (end_position - start_position).length()
            # print("Laser shrinking. Progress: ", progress)

            current_start = start_position + direction * length

            if progress >= 1.0:
                queue_free()

        set_point_position(0, current_start)
        set_point_position(1, end_position)


func start_laser(start: Vector2, end: Vector2, keycode: Key) -> void:
    start_position = start
    end_position = end
    growing = true
    my_keycode = keycode
    shrinking = false
    laser_start_time = Time.get_ticks_msec()
    add_point(start_position)
    add_point(end_position)


func _on_player_position_updated(new_position: Vector2, _velocity: Vector2, _max_speed: float, _rotation: float, _rotation_speed: float) -> void:
    end_position = new_position


func _on_earth_position_updated(new_position: Vector2) -> void:
    start_position = new_position


func _on_input_key_released(_key_name: String, keycode: Key) -> void:
    if keycode == my_keycode and waiting_for_key_release:
        # print("Keycode ", keycode, " released for laser with keycode ", my_keycode)
        laser_key_released_time = Time.get_ticks_msec()
        growing = false
        waiting_for_key_release = false
