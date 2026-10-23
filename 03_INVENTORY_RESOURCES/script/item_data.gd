extends Resource

# Шаблон предмета: топор, дерево, гриб и всё, что можно положить в инвентарь.
class_name ItemData

@export var name: String = ""
@export var icon: Texture2D
@export var is_tool: bool = false
@export var damage: int = 0
@export var amount: int = 1
