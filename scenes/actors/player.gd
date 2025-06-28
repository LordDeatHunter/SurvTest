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

@export var max_multijumps: int = 0

var t_bob: int = 0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var current_multijumps: int = 0
var is_sprinting: bool = false
var time_since_last_forward: float = 1.0
var max_sprint_press_delay: float = 0.5
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
var held_stack: Item = null

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var hotbar: InventoryUi = %InventoryUi


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hotbar.set_item(3, Items.example_item)
	hotbar.slot_clicked.connect(_on_inventory_slot_clicked)


func _input(event):
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_TAB:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))


func _physics_process(delta):
	velocity -= Vector3(0, gravity, 0) * delta

	_handle_wall_sliding(delta)
	_handle_jumping()
	_handle_crouching(delta)
	_handle_sprinting(delta)

	var speed: float = SPRINT_SPEED if is_sprinting else WALK_SPEED

	var input_dir: Vector2 = get_input_vector()
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		if is_on_floor():
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 10)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 10)
	else:
		velocity.x = lerpf(velocity.x, 0, delta * 10)
		velocity.z = lerpf(velocity.z, 0, delta * 10)

	t_bob += velocity.length() * float(is_on_floor()) * delta * 10
	camera.transform.origin = _headbob(t_bob)

	var xz_velocity: Vector3 = Vector3(velocity.x, 0, velocity.z)

	var velocity_clamped = clamp(xz_velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = (
		BASE_FOV + (SPRINT_FOV_MULT if is_sprinting else WALK_FOV_MULT) * velocity_clamped
	)
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

	move_and_slide()


func _headbob(time) -> Vector3:
	var pos: Vector3 = Vector3.ZERO
	pos.y = sin(t_bob * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos


func get_height() -> float:
	return head.transform.origin.y


func get_input_vector() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_forward", "move_backward")


func _handle_sprinting(delta: float):
	if (
		Input.is_action_just_pressed("sprint")
		or (
			Input.is_action_just_pressed("move_forward")
			and time_since_last_forward < max_sprint_press_delay
		)
	):
		is_sprinting = true

	if Input.is_action_just_pressed("move_forward"):
		time_since_last_forward = 0.0
	else:
		time_since_last_forward += delta

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


func _on_inventory_slot_clicked(slot_index: int, item: Item):
	var prev_held_stack: Item = held_stack
	held_stack = item
	hotbar.set_item(slot_index, prev_held_stack)
