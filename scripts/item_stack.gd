class_name ItemStack
extends Object

signal quantity_changed(amount: int)
signal item_changed

var quantity: int:
	get:
		return _quantity
	set(value):
		if _quantity == value:
			return
		_quantity = value

		if _quantity <= 0:
			_quantity = 0
			item = null

		quantity_changed.emit(_quantity)

var item: Item:
	get:
		return _item
	set(value):
		if _item == value:
			return
		_item = value
		if not _item:
			_quantity = 0
		item_changed.emit()

var _quantity: int = 1
var _item: Item = null


func _init(initial_item: Item, amount: int) -> void:
	item = initial_item
	quantity = amount


func is_full() -> bool:
	return item and quantity >= item.max_quantity


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


func is_empty() -> bool:
	return not item or quantity <= 0


func stack_item(other_stack: ItemStack) -> bool:
	if other_stack.is_empty() or is_empty():
		return false

	if item != other_stack.item:
		return false

	if self.is_full():
		return false

	var amount_to_take: int = min(other_stack.quantity, item.max_quantity - quantity)
	if amount_to_take <= 0:
		return false

	self.add_quantity(amount_to_take)
	other_stack.remove_quantity(amount_to_take)

	return true


func copy_from(other_stack: ItemStack) -> void:
	_item = other_stack.item
	_quantity = other_stack.quantity
	quantity_changed.emit(_quantity)
	item_changed.emit()
