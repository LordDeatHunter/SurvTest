class_name DroppedItem
extends Node3D

var stack: ItemStack = ItemStack.empty


func setup(item_stack: ItemStack, spawn_position: Vector3 = Vector3.ZERO) -> void:
	stack = item_stack.copy()
	position = spawn_position


func try_pick_up(inventories: Array[Inventory]) -> void:
	if Inventory.add_to_multiple_inventories(inventories, stack):
		queue_free()
