class_name DroppedItem
extends Node3D

var stack: ItemStack = ItemStack.new(null, 0)


func setup(item_stack: ItemStack, spawn_position: Vector3 = Vector3.ZERO) -> void:
	stack.copy_from(item_stack)
	position = spawn_position


func try_pick_up(inventory: Inventory) -> bool:
	if not inventory.add_item(stack):
		return false

	queue_free()
	return true
