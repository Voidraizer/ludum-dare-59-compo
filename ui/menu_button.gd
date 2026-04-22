extends MenuButton


signal pause_game_pressed
signal quit_game_pressed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    get_popup().add_check_item("Pause Game", 0)
    get_popup().add_item("Quit Game", 1)
    get_popup().id_pressed.connect(_on_item_pressed)


func _on_item_pressed(id: int) -> void:
    match id:
        0:
            get_popup().set_item_checked(0, !get_popup().is_item_checked(0))
            pause_game_pressed.emit()
        1:
            quit_game_pressed.emit()
