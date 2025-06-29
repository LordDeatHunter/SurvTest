class_name Item
extends Object

@export var name: String = "Item"
@export var description: String = "An item in the inventory."
@export var icon: Texture2D
@export var quantity: int = 1
@export var max_quantity: int = 99


func _init(
	name: String, description: String, icon: Texture2D, quantity: int = 1, max_quantity: int = 99
) -> void:
	self.name = name
	self.description = description
	self.icon = icon
	self.quantity = quantity
	self.max_quantity = max_quantity


func is_full() -> bool:
	return quantity >= max_quantity


func add_quantity(amount: int) -> bool:
	if quantity + amount > max_quantity:
		return false
	quantity += amount
	return true


func remove_quantity(amount: int) -> bool:
	if quantity - amount < 0:
		return false
	quantity -= amount
	return true
