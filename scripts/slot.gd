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

		_stack = value if value and value.has_item else null
		item_changed.emit(_stack)
var item_type: Item.ItemType
var _stack: ItemStack = ItemStack.new(null, 0)


func _ready() -> void:
	stack.quantity_changed.connect(_validate_stack_quantity)
	_validate_stack_quantity(stack.quantity)


func _validate_stack_quantity(amount: int) -> void:
	quantity_changed.emit(amount)
	if amount > 0:
		return

	var had_item: bool = stack.has_item()
	stack = null
	if had_item:
		item_changed.emit(stack)

	return


func has_item() -> bool:
	return stack and stack.has_item()


func is_empty() -> bool:
	return not stack or stack.is_empty()


func set_stack(new_stack: ItemStack) -> bool:
	if item_type != new_stack.item_type:
		return false

	stack = new_stack
	return true


func copy_from(other_slot: ItemStack) -> bool:
	if item_type != other_slot.item_type:
		return false

	stack = other_slot.copy()

	return true


func swap_slots(other_slot: Slot) -> bool:
	if item_type != other_slot.item_type:
		return false

	var temp_stack: ItemStack = stack
	stack = other_slot.stack
	other_slot.stack = temp_stack

	return true
