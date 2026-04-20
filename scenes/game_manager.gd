extends Node2D


@export_group("Prefabs")
@export var main_ui_prefab: PackedScene
@export var asteroid_prefab: PackedScene
@export var player_prefab: PackedScene
@export var control_signal_prefab: PackedScene

@export_group("Settings")
@export var asteroid_count: int = 150
@export var world_size: Vector2 = Vector2(3000, 3000)
@export var goal_distance_from_edge: float = 150.0

var main_ui: CanvasLayer
var player: CharacterBody2D
var input_handler: Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    randomize()
    main_ui = main_ui_prefab.instantiate()
    add_child(main_ui)

    player = player_prefab.instantiate() as CharacterBody2D
    player.position = Vector2.ZERO
    add_child(player)
    $Earth.set_player(player)

    input_handler = player.get_node("InputHandler")

    # Connect signals
    input_handler.input_key_pressed.connect(main_ui._on_input_key_pressed)
    input_handler.input_key_pressed.connect(_on_input_key_pressed)
    player.update_flight_metrics.connect(main_ui._on_update_flight_metrics)
    player.get_node("Health").player_died.connect(_on_player_lost)
    $Goal.body_entered.connect(_on_player_won)

    move_child(main_ui, 0)

    if not Globals.debug:
        _load_level()


func _load_level() -> void:
    var spawn_min = Vector2(-world_size.x, -world_size.y) / 2
    var spawn_max = Vector2(world_size.x, world_size.y) / 2
    var safe_radius = 200.0
    var asteroid_radius = 10.0
    var max_attempts = 10
    var spawned_positions = []

    for i in range(asteroid_count):
        var attempts = 0
        var valid_position = false
        var spawn_position = Vector2.ZERO

        while not valid_position and attempts < max_attempts:
            spawn_position = Vector2(randf_range(spawn_min.x, spawn_max.x), randf_range(spawn_min.y, spawn_max.y))
            if spawn_position.distance_to(player.global_position) < safe_radius + asteroid_radius:
                attempts += 1
                continue
            
            valid_position = true

            for other_asteroid in spawned_positions:
                if spawn_position.distance_to(other_asteroid) < asteroid_radius * 2:
                    valid_position = false
                    break

            attempts += 1
        
        if valid_position:
            var asteroid = asteroid_prefab.instantiate() as RigidBody2D
            asteroid.position = spawn_position
            asteroid.rotation = randf_range(0, 2 * PI)
            asteroid.set_world_size(world_size)
            $AsteroidBelt.add_child(asteroid)
            # asteroid.body_entered.connect(player._on_asteroid_collision)
            spawned_positions.append(spawn_position)
        else:
            print("Failed to find valid spawn position for asteroid ", i, " after ", max_attempts, " attempts.")
    
    var edge = randi() % 4 # Randomly select one of the four edges
    var goal_position = Vector2.ZERO

    match edge:
        0: # Top edge
            goal_position = Vector2(randf_range(spawn_min.x, spawn_max.x), spawn_min.y - goal_distance_from_edge)
        1: # Bottom edge
            goal_position = Vector2(randf_range(spawn_min.x, spawn_max.x), spawn_max.y + goal_distance_from_edge)
        2: # Left edge
            goal_position = Vector2(spawn_min.x - goal_distance_from_edge, randf_range(spawn_min.y, spawn_max.y))
        3: # Right edge
            goal_position = Vector2(spawn_max.x + goal_distance_from_edge, randf_range(spawn_min.y, spawn_max.y))
    
    $Goal.global_position = goal_position

    await get_tree().create_timer(0.5).timeout
    player.enable_camera()


func _on_input_key_pressed(_key_name: String, keycode: Key) -> void:
    if Globals.debug and keycode == 32: # Space key
        _debug_spawn_asteroid()

    if Globals.is_keycode_mapped(keycode) and not keycode == 32:
        var new_signal = control_signal_prefab.instantiate() as Line2D
        new_signal.start_laser($Earth/SignalOrigin.global_position, player.global_position, keycode)
        player.update_flight_metrics.connect(new_signal._on_player_position_updated)
        $Earth.earth_signal_origin_moved.connect(new_signal._on_earth_position_updated)
        input_handler.input_key_released.connect(new_signal._on_input_key_released)
        add_child(new_signal)


func _debug_spawn_asteroid() -> void:
    var asteroid = asteroid_prefab.instantiate() as RigidBody2D
    var asteroid_size = asteroid.get_node("Sprite2D").texture.get_size() / 2
    var player_camera = player.get_node("Camera2D") as Camera2D
    var screen_size = player_camera.get_viewport_rect().size
    var camera_visible_rect = screen_size / player_camera.zoom as Vector2
    var camera_center = player_camera.global_position as Vector2
    var spawn_min = camera_center - camera_visible_rect / 2 + asteroid_size
    var spawn_max = camera_center + camera_visible_rect / 2 - asteroid_size
    # print("Spawning asteroid at position between ", spawn_min, " and ", spawn_max)
    asteroid.position = Vector2(randf_range(spawn_min.x, spawn_max.x),
        randf_range(spawn_min.y, spawn_max.y))
    asteroid.rotation = randf_range(0, 2 * PI)
    $AsteroidBelt.add_child(asteroid)


func _on_player_won(body: Node) -> void:
    if body.name == "Player":
        var game_over_label = main_ui.get_node("MarginContainer/VBoxContainer/CenterContainer/EndGameLabel") as Label
        game_over_label.text = "YOU WIN"
        game_over_label.visible = true


func _on_player_lost() -> void:
    var game_over_label = main_ui.get_node("MarginContainer/VBoxContainer/CenterContainer/EndGameLabel") as Label
    game_over_label.text = "GAME OVER"
    game_over_label.visible = true
