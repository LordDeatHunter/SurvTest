class_name DroppedItem
extends Node3D

var stack: ItemStack = ItemStack.empty

@onready var loot_mesh: MeshInstance3D = %LootMesh


func _ready() -> void:
	(loot_mesh.material_override as ShaderMaterial).set_shader_parameter(
		"glow_color", stack.item.color
	)


func setup(item_stack: ItemStack, spawn_position: Vector3 = Vector3.ZERO) -> void:
	stack = item_stack.copy()
	position = spawn_position


func try_pick_up(inventories: Array[Inventory]) -> void:
	if Inventory.add_to_multiple_inventories(inventories, stack):
		queue_free()
