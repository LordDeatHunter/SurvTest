class_name Player
extends CharacterBody3D

const WALK_SPEED: float = 5.0
const SPRINT_SPEED: float = 7.5
const JUMP_VELOCITY: float = 4.5
const WALL_JUMP_VELOCITY: float = 12.0
const SENSITIVITY: float = 0.004
const BOB_FREQ: float = 0.25
const BOB_AMP: float = 0.1
const BASE_FOV: int = 75
const WALK_FOV_MULT: float = 1.3
const SPRINT_FOV_MULT: float = 2.6
const DEFAULT_HEIGHT: float = 2.0
const CROUCH_HEIGHT: float = 1.5
const CAMERA_HEIGHT: float = 1.75
const CAMERA_CROUCH_HEIGHT: float = 1.25
const DASH_VELOCITY: float = 40.0
const MAX_DASH_COOLDOWN: float = 1.0

const DROPPED_ITEM_SCENE: PackedScene = preload("res://scenes/DroppedItem.tscn")

@export var max_multijumps: int = 0
var t_bob: int = 0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var current_multijumps: int = 0
var is_sprinting: bool = false
var time_since_last_press: Dictionary[String, float] = {
	"move_forward": 1.0, "move_left": 1.0, "move_right": 1.0
}
var max_dash_press_delay: float = 0.2
var collision_capsule_shape: CapsuleShape3D:
	get:
		if not collision_shape_3d.shape:
			return null
		return collision_shape_3d.shape as CapsuleShape3D
var capsule_mesh: CapsuleMesh:
	get:
		if not mesh_instance_3d.mesh:
			return null
		return mesh_instance_3d.mesh as CapsuleMesh
var is_crouching: bool = false
var held_stack: ItemStack = ItemStack.new(null, 0)
var prev_collider: Object = null
var current_dash_cooldown: float = 0.0

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var hotbar: InventoryUi = %HotbarUi
@onready var inventory: InventoryUi = %InventoryUi
@onready var held_item_node: Node2D = %HeldItem
@onready var held_item_sprite: Sprite2D = %HeldItem/Sprite2D
@onready var ray_cast: RayCast3D = %RayCast
@onready var crosshair: TextureRect = %Crosshair


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	held_stack.item_changed.connect(_handle_held_item_changed)
	hotbar.inventory.set_item(3, ItemStack.new(Items.example_item, 15))
	hotbar.inventory.set_item(0, ItemStack.new(Items.example_item, 2))
	hotbar.inventory.set_item(1, ItemStack.new(Items.example_item, 3))
	hotbar.slot_clicked.connect(_handle_slot_clicked.bind(hotbar))
	inventory.slot_clicked.connect(_handle_slot_clicked.bind(inventory))
	inventory.hide()


func _handle_held_item_changed(item: Item) -> void:
	held_item_sprite.texture = item.icon if not held_stack.is_empty() else null


func _input(event):
	var mouse_mode: int = Input.get_mouse_mode()
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_TAB:
		if mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			crosshair.hide()
			inventory.show()
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			crosshair.show()
			inventory.hide()

	elif (
		event is InputEventMouseButton
		and mouse_mode == Input.MOUSE_MODE_VISIBLE
		and event.is_pressed()
		and (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT)
		and not hotbar.get_rect().has_point(event.position)
		and not inventory.get_rect().has_point(event.position)
	):
		if not held_stack.is_empty():
			var amount: int = held_stack.quantity if event.button_index == MOUSE_BUTTON_LEFT else 1
			var dropped_item: DroppedItem = DROPPED_ITEM_SCENE.instantiate()
			var drop_position: Vector3 = (
				head.global_transform.origin + -head.global_transform.basis.z * 0.5
			)
			dropped_item.setup(ItemStack.new(held_stack.item, amount), drop_position)
			held_stack.remove_quantity(amount)
			get_parent().add_child.call_deferred(dropped_item)

	if (
		prev_collider
		and prev_collider is DroppedItemVisualArea
		and Input.is_action_just_pressed("interact")
	):
		var dropped_item_visual: DroppedItemVisualArea = prev_collider as DroppedItemVisualArea
		var dropped_item: DroppedItem = dropped_item_visual.dropped_item
		dropped_item.try_pick_up(hotbar.inventory)

	if (
		event is InputEventMouseButton
		and (
			event.button_index == MOUSE_BUTTON_WHEEL_UP
			or event.button_index == MOUSE_BUTTON_WHEEL_DOWN
		)
		and event.is_pressed()
	):
		hotbar.increment_selected_slot(1 if event.button_index == MOUSE_BUTTON_WHEEL_DOWN else -1)


func _unhandled_input(event):
	var mouse_mode: int = Input.get_mouse_mode()
	if event is InputEventMouseMotion:
		if mouse_mode == Input.MOUSE_MODE_CAPTURED:
			head.rotate_y(-event.relative.x * SENSITIVITY)
			camera.rotate_x(-event.relative.y * SENSITIVITY)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		elif mouse_mode == Input.MOUSE_MODE_VISIBLE:
			var mouse_pos: Vector2 = get_viewport().get_mouse_position()
			held_item_node.position = mouse_pos


func _physics_process(delta):
	velocity -= Vector3(0, gravity, 0) * delta

	_handle_wall_sliding(delta)
	_handle_jumping()
	_handle_crouching(delta)
	_handle_sprinting()

	var speed: float = SPRINT_SPEED if is_sprinting else WALK_SPEED

	var input_dir: Vector2 = get_input_vector()
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	var target_velocity: Vector3 = direction * speed if direction else Vector3.ZERO

	velocity.x = lerp(velocity.x, target_velocity.x, delta * 10)
	velocity.z = lerp(velocity.z, target_velocity.z, delta * 10)

	_handle_dash(delta)

	for action in time_since_last_press.keys():
		if Input.is_action_just_pressed(action):
			time_since_last_press[action] = 0.0
		else:
			time_since_last_press[action] += delta

	t_bob += velocity.length() * float(is_on_floor()) * delta * 10
	camera.transform.origin = _headbob(t_bob)

	var xz_velocity: Vector3 = Vector3(velocity.x, 0, velocity.z)

	var velocity_clamped = clamp(xz_velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = (
		BASE_FOV + (SPRINT_FOV_MULT if is_sprinting else WALK_FOV_MULT) * velocity_clamped
	)
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

	move_and_slide()


func _process(_delta: float) -> void:
	var result: Object = ray_cast.get_collider()
	if result == prev_collider:
		return

	if prev_collider and prev_collider is DroppedItemVisualArea:
		var prev_dropped_item: DroppedItemVisualArea = prev_collider as DroppedItemVisualArea
		prev_dropped_item.set_highlighted(false)

	if result and result is DroppedItemVisualArea:
		var dropped_item: DroppedItemVisualArea = result as DroppedItemVisualArea
		dropped_item.set_highlighted(true)

	prev_collider = result


func _headbob(time) -> Vector3:
	var pos: Vector3 = Vector3.ZERO
	pos.y = sin(t_bob * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos


func get_height() -> float:
	return head.transform.origin.y


func get_input_vector() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_forward", "move_backward")


func _handle_sprinting():
	if Input.is_action_just_pressed("sprint"):
		is_sprinting = true

	if not Input.is_action_pressed("move_forward") or is_crouching:
		is_sprinting = false


func _handle_jumping():
	if is_on_floor() or is_on_wall():
		current_multijumps = 0

	var can_jump: bool = is_on_floor() or is_on_wall() or (current_multijumps < max_multijumps)

	if Input.is_action_just_pressed("jump") and can_jump:
		if is_on_wall():
			var push_velocity: Vector3 = get_wall_normal() * WALL_JUMP_VELOCITY
			velocity = Vector3(push_velocity.x, JUMP_VELOCITY, push_velocity.z)
		else:
			velocity.y = JUMP_VELOCITY

		if not is_on_floor() and not is_on_wall():
			current_multijumps += 1


func _get_max_standing_height() -> float:
	var length: float = DEFAULT_HEIGHT - collision_capsule_shape.height
	var start: Vector3 = position + Vector3(0, collision_capsule_shape.height, 0)
	var end: Vector3 = start + Vector3(0, length, 0)

	var intersect_ray: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		start, end, 1, [self]
	)

	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var result: Dictionary = space_state.intersect_ray(intersect_ray)

	return DEFAULT_HEIGHT if result.is_empty() else collision_capsule_shape.height


func _handle_crouching(delta: float):
	if Input.is_action_just_pressed("crouch"):
		is_crouching = true
	if Input.is_action_just_released("crouch"):
		is_crouching = false

	if not is_on_floor():
		is_crouching = false

	var lerp_amount: float = 10 * delta

	var target_height: float = CROUCH_HEIGHT if is_crouching else _get_max_standing_height()
	var head_target_height: float = target_height * 0.875

	head.transform.origin.y = lerp(head.transform.origin.y, head_target_height, lerp_amount)
	collision_capsule_shape.height = lerp(
		collision_capsule_shape.height, target_height, lerp_amount
	)
	collision_shape_3d.position.y = lerp(
		collision_shape_3d.position.y, target_height / 2, lerp_amount
	)
	capsule_mesh.height = lerp(capsule_mesh.height, target_height, lerp_amount)
	mesh_instance_3d.position.y = lerp(mesh_instance_3d.position.y, target_height / 2, lerp_amount)


func _handle_wall_sliding(delta: float) -> void:
	if not is_on_wall_only() or velocity.y > 0:
		return

	var wall_normal: Vector3 = get_wall_normal()
	if wall_normal.y > 0.5:
		return

	velocity.x = lerp(velocity.x, 0.0, delta * 10)
	velocity.z = lerp(velocity.z, 0.0, delta * 10)
	velocity.y = lerp(velocity.y, -0.25, delta * 10)


func _handle_slot_clicked(
	button_index: int, slot_index: int, stack: ItemStack, inventory_ui: InventoryUi
) -> void:
	if button_index == MOUSE_BUTTON_LEFT:
		_handle_slot_lclicked(slot_index, stack, inventory_ui)
	elif button_index == MOUSE_BUTTON_RIGHT:
		_handle_slot_rclicked(slot_index, stack, inventory_ui)


func _handle_slot_lclicked(slot_index: int, stack: ItemStack, inventory_ui: InventoryUi) -> void:
	if not stack.is_empty() and held_stack.is_empty():
		held_stack.copy_from(stack)
		inventory_ui.inventory.set_item(slot_index, ItemStack.new(null, 0))
		return

	if stack.is_empty() and not held_stack.is_empty():
		inventory_ui.inventory.set_item(slot_index, held_stack)
		held_stack.item = null
		return

	inventory_ui.inventory.stack_item(slot_index, held_stack)


func _handle_slot_rclicked(slot_index: int, stack: ItemStack, inventory_ui: InventoryUi) -> void:
	if not stack.is_empty() and held_stack.is_empty():
		var half_quantity: int = floor(stack.quantity / 2.0)
		held_stack.copy_from(ItemStack.new(stack.item, half_quantity))
		inventory_ui.inventory.set_item(
			slot_index, ItemStack.new(stack.item, stack.quantity - half_quantity)
		)
		return

	if stack.is_empty() and not held_stack.is_empty():
		inventory_ui.inventory.set_item(slot_index, ItemStack.new(held_stack.item, 1))
		held_stack.remove_quantity(1)
		return

	if not stack.is_empty() and not stack.is_full() and not held_stack.is_empty():
		inventory_ui.inventory.set_item(
			slot_index, ItemStack.new(held_stack.item, stack.quantity + 1)
		)
		held_stack.remove_quantity(1)
		return


func _handle_dash(delta: float) -> void:
	var direction: Vector3 = Vector3.ZERO
	if (
		Input.is_action_just_pressed("move_forward")
		and time_since_last_press["move_forward"] < max_dash_press_delay
	):
		direction = -head.transform.basis.z.normalized()
	elif (
		Input.is_action_just_pressed("move_left")
		and time_since_last_press["move_left"] < max_dash_press_delay
	):
		direction = -head.transform.basis.x.normalized()
	elif (
		Input.is_action_just_pressed("move_right")
		and time_since_last_press["move_right"] < max_dash_press_delay
	):
		direction = head.transform.basis.x.normalized()

	if current_dash_cooldown <= 0.0 and direction.length() > 0:
		velocity += direction * DASH_VELOCITY
		current_dash_cooldown = MAX_DASH_COOLDOWN
	else:
		current_dash_cooldown = max(current_dash_cooldown - delta, 0.0)
