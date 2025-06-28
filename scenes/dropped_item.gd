class_name DroppedItem
extends RigidBody3D

var stack: Item


func setup(item: Item, spawn_position: Vector3 = Vector3.ZERO) -> void:
	stack = item
	position = spawn_position


func pick_up() -> Item:
	queue_free()
	return stack
