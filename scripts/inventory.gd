class_name Inventory
extends Object

signal item_added(slot: int)

var items: Array[Item] = []


func _init(size: int) -> void:
	items = []
	for i in range(size):
		items.append(null)


func get_size() -> int:
	return len(items)


func add_item(item: Item) -> bool:
	if not item:
		return false

	for i in range(len(items)):
		if not items[i]:
			items[i] = item
			item_added.emit(i)
			return true

		if items[i].name == item.name and not items[i].is_full():
			item_added.emit(i)
			return items[i].add_quantity(item.quantity)

	return false


func set_item(slot: int, item: Item) -> bool:
	if slot < 0 or slot >= len(items):
		return false

	if items[slot] and item and items[slot].name == item.name:
		return items[slot].add_quantity(item.quantity)

	items[slot] = item
	item_added.emit(slot)
	return true
