extends Area2D

@export var next_scene_path: String = ""
@export var spawn_point: Vector2 = Vector2.ZERO

var next_scene: PackedScene
var _armed := false
var _leaving := false


func _ready() -> void:
	next_scene = load(next_scene_path)
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	monitoring = false
	await get_tree().create_timer(0.3).timeout
	if is_inside_tree() and not _leaving:
		monitoring = true
		_armed = true


func _on_body_entered(body: Node2D) -> void:
	if not _armed or _leaving:
		return
	if body.name != "Player":
		return
	if next_scene == null:
		return
	_leaving = true
	_armed = false
	# Сигнал body_entered нельзя глушить и нельзя из него менять сцену.
	set_deferred("monitoring", false)
	call_deferred("_open_next_scene")


func _open_next_scene() -> void:
	if not is_inside_tree():
		return
	Global.next_spawn = spawn_point
	Global.use_next_spawn = true
	var next := next_scene.instantiate()
	get_tree().root.add_child(next)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = next
