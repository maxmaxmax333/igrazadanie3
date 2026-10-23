extends Node2D

class_name WorldItem

@export var item_resources: ItemData
@export var sprite: Sprite2D
@export var remember: bool = true

var pickup_id: String = ""


func _ready() -> void:
	if sprite == null:
		sprite = get_node_or_null("Sprite2D") as Sprite2D
	if item_resources != null and sprite != null:
		sprite.texture = item_resources.icon
	if remember and item_resources != null:
		pickup_id = "%s_%d_%d" % [item_resources.name, int(round(global_position.x)), int(round(global_position.y))]
		if Global.is_collected(pickup_id):
			queue_free()
			return
	if not remember:
		$Area2D.monitoring = false
		await get_tree().create_timer(0.35).timeout
		if not is_inside_tree():
			return
		$Area2D.monitoring = true
	if not $Area2D.body_entered.is_connected(_on_area_2d_body_entered):
		$Area2D.body_entered.connect(_on_area_2d_body_entered)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return
	if item_resources == null:
		return
	if not Global.add_item(item_resources):
		return
	if remember and pickup_id != "":
		Global.mark_collected(pickup_id)
	queue_free()
