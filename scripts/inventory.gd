class_name Inventory
extends Object

var slots: Array[Slot] = []
var size: int


func _init(init_size: int) -> void:
	size = init_size
	slots = []
	for i in range(size):
		slots.append(Slot.new())


func stack_or_add(new_stack: ItemStack) -> bool:
	if new_stack.is_empty():
		return true

	if not stack_item(new_stack):
		return add_item(new_stack)

	return true


func add_item(new_stack: ItemStack) -> bool:
	for i in range(size):
		if new_stack.is_empty():
			break
		if slots[i].is_empty():
			set_item(i, new_stack)

	return new_stack.is_empty()


func stack_item(stack: ItemStack) -> bool:
	for i in range(size):
		if stack.is_empty():
			break
		stack_item_in_slot(i, stack)

	return stack.is_empty()


static func add_to_multiple_inventories(inventories: Array[Inventory], stack: ItemStack) -> bool:
	for inventory in inventories:
		if stack.is_empty():
			break
		inventory.stack_item(stack)

	for inventory in inventories:
		if stack.is_empty():
			break
		inventory.add_item(stack)

	return stack.is_empty()


func transfer_inventory_to_multiple_inventories(inventories: Array[Inventory]) -> void:
	for slot in slots:
		if slot.is_empty():
			continue
		add_to_multiple_inventories(inventories, slot.stack)


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


func stack_item_in_slot(slot: int, stack: ItemStack, remove_from_stack: bool = true) -> bool:
	if not is_slot_in_bounds(slot):
		return false

	return slots[slot].stack.stack_item(stack, remove_from_stack)


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
