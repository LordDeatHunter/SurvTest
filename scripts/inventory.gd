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
		return false

	for i in range(len(items)):
		if items[i].is_empty():
			items[i].copy_from(new_stack)
			return true

		if (
			items[i].item == new_stack.item
			and not items[i].is_full()
			and items[i].add_quantity(new_stack.quantity)
		):
			return true

	return false


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
