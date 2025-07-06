class_name Item
extends Object

signal quantity_changed(amount: int)

@export var name: String = "Item"
@export var description: String = "An item in the inventory."
@export var icon: Texture2D
@export var quantity: int = 1:
	get:
		return quantity
	set(value):
		quantity = value
		quantity_changed.emit(quantity)
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
#	if quantity - amount < 0:
#		return false
	quantity -= amount
	return true


func stack_item(other_item: Item) -> bool:
	if not other_item or self.name != other_item.name:
		return false

	if self.is_full():
		return false

	var amount_to_take: int = min(other_item.quantity, max_quantity - self.quantity)
	if amount_to_take <= 0:
		return false

	self.add_quantity(amount_to_take)
	other_item.remove_quantity(amount_to_take)

	return true
