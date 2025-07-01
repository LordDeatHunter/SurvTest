class_name DroppedItem
extends RigidBody3D

var stack: Item
var size_tween: Tween

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D


func _ready() -> void:
	size_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).set_loops()
	size_tween.tween_property(mesh_instance, "scale", Vector3.ONE * 1.2, 0.75)
	size_tween.tween_property(mesh_instance, "scale", Vector3.ONE * 0.8, 0.75)


func setup(item: Item, spawn_position: Vector3 = Vector3.ZERO) -> void:
	stack = item
	position = spawn_position


func try_pick_up(inventory: Inventory) -> bool:
	if not inventory.add_item(stack):
		return false

	queue_free()
	return true


func set_highlighted(is_highlighted: bool) -> void:
	var material: StandardMaterial3D = _get_standard_material()
	if is_highlighted:
		material.albedo_color = Color(0, 1.0, 0.55, 0.5)
	else:
		material.albedo_color = Color(0, 0.8, 0.35)


func _get_standard_material() -> StandardMaterial3D:
	var mesh: BoxMesh = mesh_instance.mesh as BoxMesh
	return mesh.material as StandardMaterial3D if mesh else null
