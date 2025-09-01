class_name ItemStack
extends Object

signal quantity_changed(amount: int)

static var empty: ItemStack = ItemStack.new(null, 0)

var quantity: int:
	get:
		return _quantity
	set(value):
		if _quantity == value:
			return

		_quantity = clamp(value, 0, item.max_quantity if item else 0)

		quantity_changed.emit(_quantity)

var item_type: Item.ItemType:
	get:
		return item.item_type
var item: Item
var _quantity: int = 1


func _init(initial_item: Item, amount: int) -> void:
	item = initial_item
	quantity = amount


func copy() -> ItemStack:
	var new_stack: ItemStack = ItemStack.new(item, quantity)
	return new_stack


func is_full() -> bool:
	return quantity >= item.max_quantity


func is_empty() -> bool:
	return quantity <= 0


func has_item() -> bool:
	return quantity > 0


func clear() -> void:
	quantity = 0


func add_quantity(amount: int) -> bool:
	if is_empty():
		return false

	quantity += amount
	return true


func remove_quantity(amount: int) -> bool:
	if is_empty() or quantity - amount < 0:
		return false

	quantity -= amount

	return true


func stack_item(other_stack: ItemStack, remove_from_stack: bool = true) -> bool:
	if is_empty() or other_stack.is_empty():
		return false

	if item != other_stack.item:
		return false

	if self.is_full():
		return false

	var amount_to_take: int = min(other_stack.quantity, item.max_quantity - quantity)
	if amount_to_take <= 0:
		return false

	self.add_quantity(amount_to_take)
	if remove_from_stack:
		other_stack.remove_quantity(amount_to_take)

	return true
