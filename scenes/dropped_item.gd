class_name DroppedItem
extends Node3D

var stack: ItemStack = ItemStack.new(null, 0)


func setup(item_stack: ItemStack, spawn_position: Vector3 = Vector3.ZERO) -> void:
	stack = item_stack.copy()
	position = spawn_position


func try_pick_up(inventories: Array[Inventory]) -> void:
	for inventory in inventories:
		inventory.add_item(stack)

		if stack.is_empty():
			queue_free()
			break
