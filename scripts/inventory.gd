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

	for i in range(size):
		if new_stack.is_empty():
			break
		if not slots[i].is_empty():
			stack_item(i, new_stack)

	for i in range(size):
		if not new_stack.has_item():
			break
		if slots[i].is_empty():
			set_item(i, new_stack)

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

	if stack.is_empty():
		return false

	var existing_slot: Slot = slots[slot]
	if existing_slot.is_empty():
		return set_item(slot, stack, remove_from_stack)

	return existing_slot.stack.stack_item(stack, remove_from_stack)


func swap_slots(slot_index: int, other_slot: Slot) -> bool:
	if not is_slot_in_bounds(slot_index):
		return false

	return slots[slot_index].swap_slots(other_slot)


func split_stack_half(slot_index: int, other_slot: Slot) -> bool:
	if not is_slot_in_bounds(slot_index):
		return false

	var current_slot: Slot = slots[slot_index]
	var half_amount: int = ceil(current_slot.stack.quantity / 2.0)
	return Slot.transfer_amount_between_slots(current_slot, other_slot, half_amount, false)


func transfer_amount_between_slots(
	slot_index: int, other_slot: Slot, amount: int, exact_amount: bool = true
) -> bool:
	if not is_slot_in_bounds(slot_index):
		return false

	var current_slot: Slot = slots[slot_index]
	return Slot.transfer_amount_between_slots(other_slot, current_slot, amount, exact_amount)
