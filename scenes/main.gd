extends Node3D

const DROPPED_ITEM_SCENE: PackedScene = preload("res://scenes/DroppedItem.tscn")
const GRASS_PATCH_SCENE: PackedScene = preload("res://scenes/grass_patch.tscn")
const SLIME_SCENE: PackedScene = preload("res://scenes/slime.tscn")

@export var ground_size: Vector2 = Vector2(32, 32)

@onready var player: Player = $Player
@onready var grass_patches: Node = $GrassPatches


func _spawn_item_above_player(item_stack: ItemStack) -> void:
	var dropped_item: DroppedItem = DROPPED_ITEM_SCENE.instantiate()
	dropped_item.setup(item_stack, player.position + Vector3(0, 2, 0))
	add_child(dropped_item)


func _spawn_items(amount: int) -> void:
	for i in range(amount):
		var quantity: int = randi_range(1, 99)
		var rng: bool = randi() % 2 == 0
		var stack: ItemStack = ItemStack.new(
			Items.example_item_1 if rng else Items.example_item_2, quantity
		)
		_spawn_item_above_player(stack)

	for i in range(4):
		_spawn_item_above_player(ItemStack.new(Items.boots, 1))

	_spawn_item_above_player(ItemStack.new(Items.claws, 1))
	_spawn_item_above_player(ItemStack.new(Items.sword, 1))


func _spawn_slimes(amount: int) -> void:
	for i in range(amount):
		var slime: Slime = SLIME_SCENE.instantiate()
		slime.position = Vector3(
			randf_range(-ground_size.x * 4 / 2, ground_size.x * 4 / 2),
			16,
			randf_range(-ground_size.y * 4 / 2, ground_size.y * 4 / 2)
		)
		add_child(slime)


func _ready():
	AudioHandlerSingleton.play_music("save-as")
	for x in range(-ground_size.x / 2, ground_size.x / 2 + 1):
		for z in range(-ground_size.y / 2, ground_size.y / 2 + 1):
			var grass_patch: StaticBody3D = GRASS_PATCH_SCENE.instantiate()
			grass_patch.position = Vector3(x * 20, 0, z * 20)
			grass_patches.add_child(grass_patch)

	_spawn_items(32)
	_spawn_slimes(10)


func _process(_delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()


func _physics_process(_delta: float) -> void:
	for grass_patch in grass_patches.get_children() as Array[GrassPatch]:
		grass_patch.grass.set_deferred(
			"instance_shader_parameters/player_position", player.position
		)
