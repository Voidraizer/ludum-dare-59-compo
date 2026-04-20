extends Node

var debug: bool = false
var input_delay_in_seconds: float = 1.0 # Delay in seconds before input playback starts

func is_keycode_mapped(keycode: Key) -> bool:
    var event = InputEventKey.new()
    event.keycode = keycode

    # Iterate through all actions in the Input Map
    for action in InputMap.get_actions():
        # print("Checking if keycode ", keycode, " is mapped to action: ", action)
        if InputMap.action_has_event(action, event):
            return true # Keycode is mapped to an action

    return false # Keycode is not mapped


func get_key_name(keycode: int, shift_pressed: bool) -> String:
    var unicode: int
    var letter := str(keycode)

    if not shift_pressed:
        unicode = keycode | 0x20
    else:
        unicode = keycode

    if unicode > 20 and unicode < 40_000: # filters most control characters
        letter = "(space)" if unicode == 32 else String.chr(unicode)

    # print("Keycode: ", keycode, " Letter: ", letter, " unicode: ", unicode)
    match keycode:
        4194319: # Left arrow
            letter = "Left"
        4194320: # Up arrow
            letter = "Up"
        4194321: # Right arrow
            letter = "Right"
        4194322: # Down arrow
            letter = "Down"

    return letter