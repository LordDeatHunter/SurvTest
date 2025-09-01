class_name Inventory
extends Object

var slots: Array[Slot] = []
var size: int


func _init(init_size: int) -> void:
	size = init_size
	slots = []
	for i in range(size):
		slots.append(Slot.new())


func add_item(new_stack: ItemStack) -> bool:
	if new_stack.is_empty():
		return true

	var i: int = 0
	while new_stack.has_item() and i < size:
		stack_item(i, new_stack)
		i += 1

	return new_stack.is_empty()


func is_slot_in_bounds(slot: int) -> bool:
	return slot >= 0 and slot < size


func set_item(slot: int, stack: ItemStack, remove_from_stack: bool = true) -> bool:
	if not is_slot_in_bounds(slot):
		return false

	if not slots[slot].copy_from(stack):
		return false

	if remove_from_stack:
		stack.clear()

	return true


func stack_item(slot: int, stack: ItemStack, remove_from_stack: bool = true) -> bool:
	if not is_slot_in_bounds(slot):
		return false

	var existing_slot: Slot = slots[slot]
	if existing_slot.is_empty():
		return set_item(slot, stack, remove_from_stack)

	return existing_slot.stack.stack_item(stack, remove_from_stack)


func swap_slots(slot_index: int, other_slot: Slot) -> bool:
	if not is_slot_in_bounds(slot_index):
		return false

	var slot: Slot = slots[slot_index]
	if slot.item_type != other_slot.item_type:
		return false

	slot.swap_slots(other_slot)
	return true
