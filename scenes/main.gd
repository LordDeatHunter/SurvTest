extends Node3D

@export var ground_size: Vector2 = Vector2(32, 32)
@export var grass_cull_distance: float = 150

var grass_patch_scene: PackedScene = preload("res://scenes/grass_patch.tscn")

@onready var player: Player = $Player
@onready var grass_patches: Node = $GrassPatches


func _ready():
	for x in range(-ground_size.x / 2, ground_size.x / 2 + 1):
		for z in range(-ground_size.y / 2, ground_size.y / 2 + 1):
			var grass_patch: StaticBody3D = grass_patch_scene.instantiate()
			grass_patch.position = Vector3(x * 20, 0, z * 20)
			grass_patches.add_child(grass_patch)

	_on_hide_patches_timeout()


func _process(_delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()


func _on_hide_patches_timeout():
	for grass_patch in grass_patches.get_children() as Array[GrassPatch]:
		grass_patch.grass.visible = (
			player.global_position.distance_to(grass_patch.global_position) < grass_cull_distance
		)


func _physics_process(_delta: float) -> void:
	for grass_patch in grass_patches.get_children() as Array[GrassPatch]:
		grass_patch.grass.set_deferred(
			"instance_shader_parameters/player_position", player.position
		)
