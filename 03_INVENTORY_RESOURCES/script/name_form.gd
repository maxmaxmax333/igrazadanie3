extends Control

@onready var name_edit: LineEdit = $CenterContainer/Panel/NameEdit
@onready var error_label: Label = $CenterContainer/Panel/ErrorLabel
@export var next_scene: PackedScene


func _ready() -> void:
	error_label.text = ""
	if not name_edit.text_submitted.is_connected(_on_name_edit_text_submitted):
		name_edit.text_submitted.connect(_on_name_edit_text_submitted)
	var button := get_node("CenterContainer/Panel/StartButton") as Button
	if not button.pressed.is_connected(_on_start_button_pressed):
		button.pressed.connect(_on_start_button_pressed)
	name_edit.grab_focus()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()


func _on_start_button_pressed() -> void:
	_try_start()


func _on_name_edit_text_submitted(_new_text: String) -> void:
	_try_start()


func _try_start() -> void:
	var entered := name_edit.text.strip_edges()
	if entered.length() <= 2:
		error_label.text = "Имя должно быть длиннее 2 символов"
		return
	error_label.text = ""
	Global.set_player_name(entered)
	var next := next_scene.instantiate()
	get_tree().root.add_child(next)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = next
