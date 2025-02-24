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

@export var can_doublejump: bool = true

var t_bob: int = 0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var has_doublejumped: bool = true

@onready var head = $Head
@onready var camera = $Head/Camera3D


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))


func _physics_process(delta):
	velocity -= Vector3(0, gravity, 0) * delta

	if is_on_floor():
		has_doublejumped = false

	var can_jump = is_on_floor() or (can_doublejump and not has_doublejumped)

	if Input.is_action_just_pressed("jump") and can_jump:
		velocity.y = JUMP_VELOCITY
		if not is_on_floor():
			has_doublejumped = true

	var is_sprinting: bool = Input.is_action_pressed("sprint")
	var speed: float = SPRINT_SPEED if is_sprinting else WALK_SPEED

	var input_dir: Vector2 = Input.get_vector(
		"move_left", "move_right", "move_forward", "move_backward"
	)
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
