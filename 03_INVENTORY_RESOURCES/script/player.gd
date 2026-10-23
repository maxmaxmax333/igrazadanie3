extends CharacterBody2D

var speed = 40
@export var anim: AnimatedSprite2D
@export var hand: Sprite2D
@export var item_world_scene: PackedScene

var is_sitting = false
var equipped_tool: ItemData
var holstered := false

@onready var name_label: Label = $NameLayer/NameLabel


func _ready() -> void:
	motion_mode = MOTION_MODE_FLOATING
	if hand == null:
		hand = get_node_or_null("Hand") as Sprite2D
	if item_world_scene == null:
		item_world_scene = load("res://scenes/item.tscn")
	if Global.player_name == "":
		name_label.text = "странник"
	else:
		name_label.text = Global.player_name
	if Global.use_next_spawn:
		global_position = Global.next_spawn
		Global.use_next_spawn = false
	anim.play("idle")
	_place_name()
	if not Global.inventory_updated.is_connected(update_hand_visual):
		Global.inventory_updated.connect(update_hand_visual)
	update_hand_visual()


func _process(_delta: float) -> void:
	_place_name()
	_place_hand()


func _place_name() -> void:
	var screen: Vector2 = get_viewport().get_canvas_transform() * global_position
	name_label.position = screen + Vector2(-40, -24)
	name_label.size = Vector2(80, 16)


func _place_hand() -> void:
	if hand == null or anim == null:
		return
	var facing_right := anim.flip_h
	hand.position = Vector2(8 if facing_right else -8, 2)
	hand.flip_h = facing_right


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
		return
	if event.is_action_pressed("interact"):
		if is_sitting:
			is_sitting = false
			anim.play("idle")
		else:
			is_sitting = true
			anim.play("sit")
		return
	if event.is_action_pressed("next_item"):
		change_selection(1)
	elif event.is_action_pressed("prev_item"):
		change_selection(-1)
	elif event.is_action_pressed("use_tool"):
		_toggle_tool()
	elif event.is_action_pressed("drop_item"):
		drop_item()


func change_selection(direction: int) -> void:
	if Global.inventory.is_empty():
		return
	holstered = false
	var size := Global.inventory.size()
	Global.active_slot_index = (Global.active_slot_index + direction) % size
	if Global.active_slot_index < 0:
		Global.active_slot_index = size - 1
	Global.update_selection_visual.emit()
	update_hand_visual()


func update_hand_visual() -> void:
	if hand == null:
		return
	if Global.inventory.is_empty():
		hand.texture = null
		hand.visible = false
		equipped_tool = null
		holstered = false
		return
	Global.active_slot_index = clampi(Global.active_slot_index, 0, Global.inventory.size() - 1)
	var item: ItemData = Global.inventory[Global.active_slot_index]
	if item == null or (item.is_tool and holstered):
		hand.texture = null
		hand.visible = false
		equipped_tool = null
		return
	hand.texture = item.icon
	hand.visible = true
	equipped_tool = item if item.is_tool else null
	_place_hand()


func _toggle_tool() -> void:
	if Global.inventory.is_empty():
		return
	var item: ItemData = Global.inventory[Global.active_slot_index]
	if item == null or not item.is_tool:
		return
	holstered = not holstered
	update_hand_visual()


func drop_item() -> void:
	var item_to_drop := Global.take_active_one()
	if item_to_drop == null:
		return
	spawn_dropped_item(item_to_drop)
	update_hand_visual()


func spawn_dropped_item(item_to_drop: ItemData) -> void:
	if item_world_scene == null:
		return
	var new_item := item_world_scene.instantiate() as WorldItem
	new_item.item_resources = item_to_drop
	new_item.remember = false
	var offset := Vector2.from_angle(randf() * TAU) * randf_range(18, 26)
	new_item.position = position + offset
	get_tree().current_scene.add_child(new_item)


func _physics_process(_delta: float) -> void:
	# Пока герой сидит, движение не считаем.
	if is_sitting:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var input := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	velocity = input.normalized() * speed

	# Поворот спрайта в зависимости от направления.
	if input.x > 0:
		anim.flip_h = true
	elif input.x < 0:
		anim.flip_h = false

	if input != Vector2.ZERO:
		anim.play("walk")
	else:
		anim.play("idle")

	move_and_slide()
