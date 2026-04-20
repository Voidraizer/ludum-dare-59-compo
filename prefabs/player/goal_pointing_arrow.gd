extends Sprite2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    var goal_position: Vector2 = get_node("/root/Game/Goal").global_position
    var direction = (goal_position - get_parent().global_position).normalized()
    global_rotation = direction.angle() + (PI / 2)
