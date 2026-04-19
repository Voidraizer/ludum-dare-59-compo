extends Node2D


@export_group("Prefabs")
@export var main_ui_prefab: PackedScene
@export var asteroid_prefab: PackedScene
@export var player_prefab: PackedScene

@export_group("Settings")
@export var asteroid_count: int = 5


var main_ui: CanvasLayer
var player: CharacterBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    main_ui = main_ui_prefab.instantiate()
    add_child(main_ui)

    player = player_prefab.instantiate() as CharacterBody2D
    player.position = get_viewport().get_visible_rect().size / 2
    add_child(player)

    var input_handler = player.get_node("InputHandler")
    input_handler.input_processed_raw.connect(main_ui._on_input_processed)
    input_handler.input_processed_raw.connect(_on_input_processed)

    if not Globals.debug:
        for i in range(asteroid_count):
            _spawn_asteroid()

# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(_delta: float) -> void:
    # pass

func _on_input_processed(_key_name: String, keycode: Key) -> void:
    if Globals.debug and keycode == 32: # Space key
        _spawn_asteroid()


func _spawn_asteroid() -> void:
    var asteroid = asteroid_prefab.instantiate() as RigidBody2D
    var asteroid_size = asteroid.get_node("Sprite2D").texture.get_size() / 2
    var screen_size = get_viewport().get_visible_rect().size
    asteroid.position = Vector2(randf_range(0 + asteroid_size.x, screen_size.x - asteroid_size.x),
        randf_range(0 + asteroid_size.y, screen_size.y - asteroid_size.y))
    asteroid.rotation = randf_range(0, 2 * PI)
    $AsteroidBelt.add_child(asteroid)
