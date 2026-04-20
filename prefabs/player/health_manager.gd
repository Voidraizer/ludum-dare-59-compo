extends Node2D


@export var max_health: int = 5

var current_health: int = max_health
var heart_sprites: Array[Sprite2D] = []

signal health_changed(current_health: int)
signal player_died()

func _ready() -> void:
    for i in range(max_health):
        var heart_sprite = $HeartCluster.get_node("Heart" + str(i + 1)) as Sprite2D
        heart_sprites.append(heart_sprite)


func lose_health(amount: int = 1) -> void:
    current_health = max(current_health - amount, 0)
    print("Health lost! Current health: ", current_health)
    heart_sprites[current_health].visible = false
    emit_signal("health_changed", current_health)
    if current_health == 0:
        emit_signal("player_died")
