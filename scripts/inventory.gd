class_name Inventory
extends Object

var items: Array[ItemStack] = []


func _init(size: int) -> void:
	items = []
	for i in range(size):
		items.append(ItemStack.new(null, 0))


func get_size() -> int:
	return len(items)


func add_item(new_stack: ItemStack) -> bool:
	if new_stack.is_empty():
		return true

	var i: int = 0
	while not new_stack.is_empty() and i < len(items):
		if items[i].is_empty():
			items[i].copy_from(new_stack)
			new_stack.remove_quantity(new_stack.quantity)
			break

		items[i].stack_item(new_stack)

		i += 1

	return new_stack.is_empty()


func set_item(slot: int, stack: ItemStack) -> bool:
	if slot < 0 or slot >= len(items):
		return false

	items[slot].copy_from(stack)
	return true


func stack_item(slot: int, stack: ItemStack) -> bool:
	if slot < 0 or slot >= len(items):
		return false

	var existing_item: ItemStack = items[slot]
	if existing_item.is_empty():
		return set_item(slot, stack)

	return existing_item.stack_item(stack)
