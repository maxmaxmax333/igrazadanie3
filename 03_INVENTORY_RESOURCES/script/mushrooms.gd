extends Node2D

@export var item_resources: ItemData
var pickup_id: String = ""


func _ready() -> void:
	pickup_id = "m_%d_%d" % [int(round(global_position.x)), int(round(global_position.y))]
	if Global.is_collected(pickup_id):
		queue_free()
		return
	if not $Area2D.body_entered.is_connected(_on_area_2d_body_entered):
		$Area2D.body_entered.connect(_on_area_2d_body_entered)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return
	if item_resources == null:
		return
	if not Global.add_item(item_resources):
		return
	Global.mark_collected(pickup_id)
	queue_free()
