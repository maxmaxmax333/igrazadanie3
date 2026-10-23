extends Node

signal inventory_updated
signal update_selection_visual
signal inventory_full

var player_name: String = ""
var collected := {}
var next_spawn := Vector2.ZERO
var use_next_spawn := false

var inventory: Array[ItemData] = []
var active_slot_index: int = 0
@export var max_inventory_size: int = 10


func set_player_name(value: String) -> void:
	player_name = value


func mark_collected(id: String) -> void:
	collected[id] = true


func is_collected(id: String) -> bool:
	return collected.has(id)


func add_item(item: ItemData) -> bool:
	if item == null:
		return false
	var adding := maxi(item.amount, 1)
	for have in inventory:
		if have.name == item.name:
			have.amount += adding
			inventory_updated.emit()
			update_selection_visual.emit()
			return true
	if inventory.size() >= max_inventory_size:
		inventory_full.emit()
		return false
	var stack := item.duplicate(true) as ItemData
	stack.amount = adding
	inventory.append(stack)
	if inventory.size() == 1:
		active_slot_index = 0
	inventory_updated.emit()
	update_selection_visual.emit()
	return true


func take_active_one() -> ItemData:
	if inventory.is_empty():
		return null
	active_slot_index = clampi(active_slot_index, 0, inventory.size() - 1)
	var stack := inventory[active_slot_index]
	var dropped := stack.duplicate(true) as ItemData
	dropped.amount = 1
	stack.amount -= 1
	if stack.amount <= 0:
		inventory.remove_at(active_slot_index)
		if inventory.is_empty():
			active_slot_index = 0
		else:
			active_slot_index = mini(active_slot_index, inventory.size() - 1)
	inventory_updated.emit()
	update_selection_visual.emit()
	return dropped
