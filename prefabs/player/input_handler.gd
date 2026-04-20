extends Node2D

@export var _velocity_acceleration: float = 13.0
@export var _rotation_acceleration: float = 0.01

var key_press_queue: Dictionary = {} # Tracks events for each key including repeats
var playback_active: Dictionary = {} # Tracks playback state for each key
var velocity = Vector2.ZERO
var rotation_speed: float = 0.0


signal input_processed_raw(key_name: String, keycode: Key)
signal input_key_pressed(key_name: String, keycode: Key)
signal input_key_released(key_name: String, keycode: Key)
signal new_velocity(velocity: Vector2)
signal new_rotation_speed(rotation_speed: float)

func _input(event: InputEvent) -> void:
    if event is InputEventKey:
        if event.pressed and not event.echo: # `not event.echo` avoids processing repeated key events when holding a key
            if not key_press_queue.has(event.keycode):
                key_press_queue[event.keycode] = []

            key_press_queue[event.keycode].append({
                "start_time": Time.get_ticks_msec(),
                "duration": 0,
                "processed": false
            })

            emit_signal("input_key_pressed", Globals.get_key_name(event.keycode, false), event.keycode)

        elif not event.pressed and not event.echo:
            if key_press_queue.has(event.keycode) and key_press_queue[event.keycode].size() > 0:
                var last_press = key_press_queue[event.keycode].back()

                if last_press["duration"] == 0: # If the key was released before the input delay, process it immediately
                    last_press["duration"] = Time.get_ticks_msec() - last_press["start_time"]

                emit_signal("input_key_released", Globals.get_key_name(event.keycode, false), event.keycode)

            # Emit the raw signal for anything that cares
            var letter = Globals.get_key_name(event.keycode, event.shift_pressed)
            emit_signal("input_processed_raw", letter, event.keycode)


func _process(_delta: float) -> void:
    # Reset
    velocity = Vector2.ZERO
    rotation_speed = 0.0

    # Process playback for each key
    for keycode in key_press_queue.keys():
        var queue = key_press_queue[keycode]

        if queue.size() > 0:
            var press = queue[0]
            var current_time = Time.get_ticks_msec()

            # Check if playback should start
            if not press["processed"] and current_time >= press["start_time"] + int(Globals.input_delay_in_seconds * 1000):
                #Check if the key is still being held down and update duration
                if press["duration"] == 0: # Duration will only be 0 if the key is still being held down
                    press["duration"] = current_time - press["start_time"]

                    # Append a new event to the queue for continuous input
                    queue.append({
                        "start_time": current_time,
                        "duration": 0,
                        "processed": false
                    })

                press["processed"] = true
                playback_active[keycode] = {
                    "remaining_duration": press["duration"]
                }

            # Handle active playback
            if playback_active.has(keycode):
                var playback = playback_active[keycode]
                playback["remaining_duration"] -= int(_delta * 1000)

                if playback["remaining_duration"] <= 0:
                    # Playback finished, clean up
                    playback_active.erase(keycode)
                    queue.pop_front() # Remove the processed key event from the queue
                else:
                    var letter = Globals.get_key_name(keycode, false) # Shift has no bearing on controls
                    var parent_transform: Transform2D = get_parent().transform
                    match letter.to_upper():
                        "W":
                            velocity += -parent_transform.y * _velocity_acceleration
                        "A":
                            rotation_speed -= _rotation_acceleration
                        "S":
                            velocity -= -parent_transform.y * _velocity_acceleration
                        "D":
                            rotation_speed += _rotation_acceleration
                        "Q":
                            velocity += -parent_transform.x * _velocity_acceleration
                        "E":
                            velocity -= -parent_transform.x * _velocity_acceleration
                        _:
                            pass
                            # if Globals.debug:
                            #     print("Playback: Key " + letter)
    # Debugging: Log velocity and rotation speed
    # if Globals.debug:
    #     print("Changes in Velocity: ", velocity, " Rotation Speed: ", rotation_speed)
    emit_signal("new_velocity", velocity)
    emit_signal("new_rotation_speed", rotation_speed)
