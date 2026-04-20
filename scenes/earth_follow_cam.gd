extends Sprite2D


@export var earth_offset: Vector2 = Vector2.ZERO

var player: CharacterBody2D = null


signal earth_signal_origin_moved(new_position: Vector2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    if player:
        # Follow the player camera's position
        global_position = player.global_position + earth_offset
        emit_signal("earth_signal_origin_moved", $SignalOrigin.global_position)


func set_player(player_node: CharacterBody2D) -> void:
    player = player_node
