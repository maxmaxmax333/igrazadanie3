extends Node2D

@export var item_resources: ItemData

var _chopped := false


func _ready() -> void:
	if not $Area2D.body_entered.is_connected(_on_area_2d_body_entered):
		$Area2D.body_entered.connect(_on_area_2d_body_entered)


func _physics_process(_delta: float) -> void:
	if _chopped:
		return
	for body in $Area2D.get_overlapping_bodies():
		_try_chop(body)


func _on_area_2d_body_entered(body: Node2D) -> void:
	_try_chop(body)


func _try_chop(body: Node) -> void:
	if _chopped or body == null or body.name != "Player":
		return
	if body.equipped_tool and body.equipped_tool.name == "axe":
		_chopped = true
		spawn_wood()
		queue_free()


func spawn_wood() -> void:
	if item_resources == null:
		return
	if Global.add_item(item_resources):
		return
	var packed: PackedScene = load("res://scenes/item.tscn")
	var dropped := packed.instantiate() as WorldItem
	var wood := item_resources.duplicate(true) as ItemData
	wood.amount = 1
	dropped.item_resources = wood
	dropped.remember = false
	dropped.position = position + Vector2(0, 14)
	get_tree().current_scene.add_child(dropped)
