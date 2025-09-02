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


func copy_from(other_stack: ItemStack) -> bool:
	if item_type != Item.ItemType.GENERIC and item_type != other_stack.item_type:
		return false

	stack = other_stack
	return true


func is_slot_compatible(check_stack: ItemStack) -> bool:
	if has_item():
		return stack.item == check_stack

	return item_type == Item.ItemType.GENERIC or item_type == check_stack.item_type


func swap_slots(other_slot: Slot) -> bool:
	if is_empty() and other_slot.is_empty():
		return true

	if is_empty() and other_slot.has_item():
		return other_slot.swap_slots(self)

	if other_slot.has_item() and item_type != other_slot.item_type:
		return false

	if other_slot.is_empty() and other_slot.item_type != Item.ItemType.GENERIC:
		return false

	var temp_stack: ItemStack = stack
	stack = other_slot.stack
	other_slot.stack = temp_stack

	return true


static func transfer_amount_between_slots(
	from_slot: Slot, to_slot: Slot, amount, exact_amount: bool
) -> bool:
	if from_slot.is_empty() or amount <= 0:
		return false
	if exact_amount and from_slot.stack.quantity < amount:
		return false

	var available_amount_in_from_slot: int = from_slot.stack.quantity
	var transfer_amount: int = min(amount, available_amount_in_from_slot)

	if to_slot.is_empty():
		var new_stack: ItemStack = ItemStack.new(from_slot.stack.item, transfer_amount)
		if not to_slot.is_slot_compatible(new_stack):
			return false

		to_slot.stack = new_stack
		from_slot.stack.remove_quantity(transfer_amount)
		return true

	if to_slot.stack.is_full():
		return false
	if from_slot.stack.item != to_slot.stack.item:
		return false

	var free_space_in_to_slot: int = to_slot.stack.item.max_quantity - to_slot.stack.quantity
	transfer_amount = min(transfer_amount, free_space_in_to_slot)

	if transfer_amount <= 0:
		return false
	if exact_amount and transfer_amount < amount:
		return false

	from_slot.stack.remove_quantity(transfer_amount)
	to_slot.stack.add_quantity(transfer_amount)

	return true
