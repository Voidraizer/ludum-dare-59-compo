extends Node2D

@export var _input_delay: float = 1.5
@export var _velocity_acceleration: float = 10.0
@export var _rotation_acceleration: float = 0.005

var key_press_queue: Dictionary = {} # Tracks events for each key including repeats
var playback_active: Dictionary = {} # Tracks playback state for each key
var velocity = Vector2.ZERO
var rotation_speed: float = 0.0


signal input_processed_raw(key_name: String, keycode: Key)
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

        elif not event.pressed and not event.echo:
            if key_press_queue.has(event.keycode) and key_press_queue[event.keycode].size() > 0:
                var last_press = key_press_queue[event.keycode].back()

                if last_press["duration"] == 0: # If the key was released before the input delay, process it immediately
                    last_press["duration"] = Time.get_ticks_msec() - last_press["start_time"]

            # Emit the raw signal for anything that cares
            var letter = _get_key_name(event.keycode, event.shift_pressed)
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
            if not press["processed"] and current_time >= press["start_time"] + int(_input_delay * 1000):
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
                    var letter = _get_key_name(keycode, false) # Shift has no bearing on controls
                    match letter.to_upper():
                        "W":
                            velocity += Vector2.UP * _velocity_acceleration
                        "A":
                            rotation_speed -= _rotation_acceleration
                        "S":
                            velocity -= Vector2.UP * _velocity_acceleration
                        "D":
                            rotation_speed += _rotation_acceleration
                        _:
                            if Globals.debug:
                                print("Playback: Key " + letter)
    
    emit_signal("new_velocity", velocity)
    emit_signal("new_rotation_speed", rotation_speed)


func _get_key_name(keycode: int, shift_pressed: bool) -> String:
    var unicode: int
    var letter := str(keycode)

    if not shift_pressed:
        unicode = keycode | 0x20
    else:
        unicode = keycode

    if unicode > 20 and unicode < 40_000: # filters most control characters
        letter = "(space)" if unicode == 32 else String.chr(unicode)

    return letter
