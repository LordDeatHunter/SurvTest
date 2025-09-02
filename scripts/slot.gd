class_name Slot
extends TextureRect

signal item_changed(stack: ItemStack)
signal quantity_changed(amount: int)

var stack: ItemStack:
	get:
		return _stack
	set(value):
		if _stack == value:
			return

		_disconnect_stack_signals()

		_stack = value.copy() if value and value.has_item() else ItemStack.empty

		_connect_stack_signals()

		item_changed.emit(_stack)
		quantity_changed.emit(_stack.quantity)

var item_type: Item.ItemType
var _stack: ItemStack = ItemStack.empty


func _exit_tree() -> void:
	_disconnect_stack_signals()


func _update_stack_quantity(amount: int) -> void:
	quantity_changed.emit(amount)

	if amount <= 0:
		stack = ItemStack.empty


func _disconnect_stack_signals() -> void:
	if _stack.has_item() and _stack.quantity_changed.is_connected(_update_stack_quantity):
		_stack.quantity_changed.disconnect(_update_stack_quantity)


func _connect_stack_signals() -> void:
	if _stack.has_item() and not _stack.quantity_changed.is_connected(_update_stack_quantity):
		_stack.quantity_changed.connect(_update_stack_quantity)


func has_item() -> bool:
	return stack and stack.has_item()


func is_empty() -> bool:
	return not stack or stack.is_empty()


func set_stack(new_stack: ItemStack) -> bool:
	if item_type != new_stack.item_type:
		return false

	stack = new_stack
	return true


func copy_from(other_stack: ItemStack) -> bool:
	if item_type != other_stack.item_type:
		return false

	stack = other_stack
	return true


func swap_slots(other_slot: Slot) -> bool:
	if is_empty() and other_slot.is_empty():
		return true

	if is_empty() and other_slot.has_item():
		return other_slot.swap_slots(self)

	if has_item() and other_slot.has_item() and item_type != other_slot.item_type:
		return false

	if has_item() and other_slot.is_empty() and other_slot.item_type != Item.ItemType.GENERIC:
		return false

	var temp_stack: ItemStack = stack
	stack = other_slot.stack
	other_slot.stack = temp_stack

	return true
