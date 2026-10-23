extends CanvasLayer

const FONT := preload("res://assets/ComicoroRu_0.ttf")
const SELECTED := preload("res://assets/slot_selected.tres")
const NORMAL := preload("res://assets/slot_normal.tres")

@export var grid: GridContainer
@export var full_label: Label


func _ready() -> void:
	if grid == null:
		grid = get_node_or_null("MarginContainer/VBoxContainer/GridContainer") as GridContainer
	if full_label == null:
		full_label = get_node_or_null("MarginContainer/VBoxContainer/FullLabel") as Label
	if full_label:
		full_label.text = ""
	if not Global.inventory_updated.is_connected(refresh_ui):
		Global.inventory_updated.connect(refresh_ui)
	if not Global.update_selection_visual.is_connected(update_selection_visual):
		Global.update_selection_visual.connect(update_selection_visual)
	if not Global.inventory_full.is_connected(_on_inventory_full):
		Global.inventory_full.connect(_on_inventory_full)
	refresh_ui()


func refresh_ui() -> void:
	if grid == null:
		return
	for child in grid.get_children():
		grid.remove_child(child)
		child.queue_free()
	for item in Global.inventory:
		var slot := Button.new()
		slot.icon = item.icon
		slot.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		slot.custom_minimum_size = Vector2(20, 20)
		slot.focus_mode = Control.FOCUS_NONE
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var amount := Label.new()
		amount.text = str(item.amount)
		amount.mouse_filter = Control.MOUSE_FILTER_IGNORE
		amount.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		amount.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		amount.add_theme_font_override("font", FONT)
		amount.add_theme_font_size_override("font_size", 16)
		amount.add_theme_color_override("font_color", Color(0.964706, 0.945098, 0.894118))
		amount.set_anchors_preset(Control.PRESET_FULL_RECT)
		amount.offset_right = -1
		amount.offset_bottom = 2
		slot.add_child(amount)
		grid.add_child(slot)
	update_selection_visual()


func update_selection_visual() -> void:
	if grid == null:
		return
	var slots := grid.get_children()
	for i in slots.size():
		var slot := slots[i] as Button
		if slot == null:
			continue
		if i == Global.active_slot_index:
			slot.add_theme_stylebox_override("normal", SELECTED)
			slot.add_theme_stylebox_override("focus", SELECTED)
		else:
			slot.add_theme_stylebox_override("normal", NORMAL)
			slot.add_theme_stylebox_override("focus", NORMAL)


func _on_inventory_full() -> void:
	if full_label == null:
		return
	full_label.text = "полно"
	await get_tree().create_timer(1.2).timeout
	if is_inside_tree() and full_label:
		full_label.text = ""
