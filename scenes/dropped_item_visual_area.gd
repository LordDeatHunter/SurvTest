class_name DroppedItemVisualArea
extends Area3D

@export var dropped_item: DroppedItem

var material_overlay: StandardMaterial3D
var size_tween: Tween

@onready var mesh_instance: MeshInstance3D = %MainMesh


func _ready() -> void:
	size_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).set_loops()
	size_tween.tween_property(self, "scale", Vector3.ONE * 1.2, 0.75)
	size_tween.tween_property(self, "scale", Vector3.ONE * 0.8, 0.75)

	material_overlay = StandardMaterial3D.new()
	mesh_instance.material_overlay = material_overlay
	set_highlighted(false)


func set_highlighted(is_highlighted: bool) -> void:
	if is_highlighted:
		material_overlay.albedo_color = Color(0, 1.0, 0.55, 0.5)
	else:
		material_overlay.albedo_color = Color(0, 0.8, 0.35)
