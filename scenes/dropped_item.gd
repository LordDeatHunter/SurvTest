class_name DroppedItem
extends RigidBody3D

var stack: ItemStack = ItemStack.new(null, 0)
var size_tween: Tween
var material_overlay: StandardMaterial3D

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D


func _ready() -> void:
	size_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).set_loops()
	size_tween.tween_property(mesh_instance, "scale", Vector3.ONE * 1.2, 0.75)
	size_tween.tween_property(mesh_instance, "scale", Vector3.ONE * 0.8, 0.75)

	material_overlay = StandardMaterial3D.new()
	mesh_instance.material_overlay = material_overlay
	set_highlighted(false)


func setup(item_stack: ItemStack, spawn_position: Vector3 = Vector3.ZERO) -> void:
	stack.copy_from(item_stack)
	position = spawn_position


func try_pick_up(inventory: Inventory) -> bool:
	if not inventory.add_item(stack):
		return false

	queue_free()
	return true


func set_highlighted(is_highlighted: bool) -> void:
	if is_highlighted:
		material_overlay.albedo_color = Color(0, 1.0, 0.55, 0.5)
	else:
		material_overlay.albedo_color = Color(0, 0.8, 0.35)
