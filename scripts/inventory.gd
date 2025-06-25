class_name Inventory
extends Object

var items: Array[Item] = []


func _init(size: int) -> void:
	items = []
	for i in range(size):
		items.append(null)


func get_size() -> int:
	return len(items)
