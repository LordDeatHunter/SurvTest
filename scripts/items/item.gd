class_name Item
extends Object

enum ItemType {
	GENERIC,
	ACCESSORY,
}

@export var name: String = "Item"
@export var description: String = "An item in the inventory."
@export var icon: Texture2D
@export var max_quantity: int = 99
@export var color: Color = Color.AQUAMARINE
@export var item_type: ItemType = ItemType.GENERIC


func _init(
	name: String,
	description: String,
	icon: Texture2D,
	max_quantity: int = 99,
	item_type: ItemType = ItemType.GENERIC,
	color: Color = Color.AQUAMARINE,
) -> void:
	self.name = name
	self.description = description
	self.icon = icon
	self.max_quantity = max_quantity
	self.item_type = item_type
	self.color = color
