class_name Item
extends Object

@export var name: String = "Item"
@export var description: String = "An item in the inventory."
@export var icon: Texture2D
@export var max_quantity: int = 99


func _init(name: String, description: String, icon: Texture2D, max_quantity: int = 99) -> void:
	self.name = name
	self.description = description
	self.icon = icon
	self.max_quantity = max_quantity
