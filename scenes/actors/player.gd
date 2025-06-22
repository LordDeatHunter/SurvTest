class_name Player
extends CharacterBody3D

const WALK_SPEED: float = 5.0
const SPRINT_SPEED: float = 7.5
const JUMP_VELOCITY: float = 4.5
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
var height: float = 2.0
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

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))


func _physics_process(delta):
	velocity -= Vector3(0, gravity, 0) * delta

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
	if is_on_floor():
		current_multijumps = 0

	var can_jump: bool = is_on_floor() or (current_multijumps < max_multijumps)

	if Input.is_action_just_pressed("jump") and can_jump:
		velocity.y = JUMP_VELOCITY
		if not is_on_floor():
			current_multijumps += 1


func _handle_crouching(delta: float):
	if Input.is_action_just_pressed("crouch"):
		is_crouching = true
	if Input.is_action_just_released("crouch"):
		is_crouching = false

	if not is_on_floor():
		is_crouching = false

	var lerp_amount: float = 10 * delta

	if is_crouching:
		height = CROUCH_HEIGHT
		head.transform.origin.y = lerp(head.transform.origin.y, CAMERA_CROUCH_HEIGHT, lerp_amount)
	else:
		height = DEFAULT_HEIGHT
		head.transform.origin.y = lerp(head.transform.origin.y, CAMERA_HEIGHT, lerp_amount)

	if collision_capsule_shape:
		collision_capsule_shape.height = lerp(collision_capsule_shape.height, height, lerp_amount)
		collision_shape_3d.position.y = lerp(collision_shape_3d.position.y, height / 2, lerp_amount)

	if capsule_mesh:
		capsule_mesh.height = lerp(capsule_mesh.height, height, lerp_amount)
		mesh_instance_3d.position.y = lerp(mesh_instance_3d.position.y, height / 2, lerp_amount)
