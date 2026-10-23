extends Node2D

@export var map_size := Vector2i(22, 14)


func _ready() -> void:
	var cam := get_node_or_null("Player/Camera2D") as Camera2D
	if cam == null:
		return
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = map_size.x * 16
	cam.limit_bottom = map_size.y * 16
