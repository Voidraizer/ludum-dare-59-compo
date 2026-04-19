extends CanvasLayer


@export var input_label_prefab: PackedScene

var input_container: Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    input_container = $MarginContainer/InputContainer


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    pass


func _on_input_processed(key_name: String, _keycode: Key) -> void:
    if Globals.debug:
        _show_input_label("Key: " + key_name)


func _show_input_label(key: String, duration: String = "") -> void:
    var label = input_label_prefab.instantiate()
    label.text = key if not duration else key + " (" + duration + ")"
    input_container.add_child(label)
    await get_tree().create_timer(3.0).timeout
    label.queue_free()