class_name Slime
extends SoftBody3D

enum SlimeState { ROAMING, ATTACKING, DEAD }

const IDLE_COLOR: Color = Color("4f8fbaaa")
const AGGRO_COLOR: Color = Color("a23e8caa")
const CORNER_POINTS: Array[int] = [2, 15, 26, 54, 82, 110]

var state: SlimeState = SlimeState.ROAMING
var attack_target: Node3D = null
var jump_strength: float = 12.0
var jump_cooldown: float = 4.0
var time_since_last_jump: float = 0.0
var target_color: Color = IDLE_COLOR
var surface_material: StandardMaterial3D:
	get:
		return get_surface_override_material(0)
var current_color: Color:
	get:
		return surface_material.albedo_color
	set(value):
		surface_material.albedo_color = value
var health: float = 3.0
var color_tween: Tween

@onready var average_center_position: Vector3 = _get_average_center_point()
@onready var collision_shape_3d: CollisionShape3D = %CollisionShape3D
@onready var inner_nodes: Node3D = $InnerNodes
@onready var death_timer: Timer = $Timer


func jump(direction: Vector3, strength: float) -> void:
	apply_central_impulse((direction + Vector3.UP) * strength)
	time_since_last_jump = 0.0


func _physics_process(_delta: float) -> void:
	average_center_position = _get_average_center_point()
	inner_nodes.global_position = average_center_position


func _process(delta: float) -> void:
	if state == SlimeState.DEAD:
		return
	time_since_last_jump += delta

	current_color = lerp(current_color, target_color, delta)

	match state:
		SlimeState.ROAMING:
			_roam(delta)
		SlimeState.ATTACKING when attack_target:
			_attack(delta)


func _attack(_delta: float) -> void:
	if (
		not attack_target
		or (
			average_center_position.distance_to(attack_target.position)
			> (collision_shape_3d.shape as SphereShape3D).radius * 1.5
		)
	):
		_remove_target()
		return

	if time_since_last_jump >= jump_cooldown:
		var direction_to_target: Vector3 = average_center_position.direction_to(
			attack_target.global_position
		)

		jump(direction_to_target, jump_strength)


func _roam(_delta: float) -> void:
	if time_since_last_jump >= jump_cooldown:
		var roam_direction: Vector3 = (
			Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
		)
		jump(roam_direction, jump_strength)


func _on_detection_area_body_entered(body: Node) -> void:
	if state == SlimeState.DEAD:
		return

	if body is Player:
		state = SlimeState.ATTACKING
		attack_target = body
		target_color = AGGRO_COLOR


func _remove_target() -> void:
	state = SlimeState.ROAMING
	attack_target = null
	target_color = IDLE_COLOR


func _get_average_center_point() -> Vector3:
	var transform_sum: Vector3 = Vector3.ZERO
	for i in CORNER_POINTS:
		transform_sum += get_point_transform(i)
	return transform_sum / CORNER_POINTS.size()


func hit(player: Player) -> void:
	if state == SlimeState.DEAD:
		return

	AudioHandlerSingleton.play_random_indexed_sound("slime_hit")

	health -= 1
	if health <= 0:
		_handle_death()
		return

	current_color = Color(1, 0, 0)
	var knockback: Vector3 = player.global_position.direction_to(average_center_position) * 16
	apply_central_impulse(knockback)


func _handle_death() -> void:
	death_timer.start()
	pressure_coefficient = 0.0
	state = SlimeState.DEAD

	var particles: GPUParticles3D = Imports.SLIME_PARTICLES_SCENE.instantiate()
	inner_nodes.add_child.call_deferred(particles)
	particles.restart()

	color_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	color_tween.tween_property(self, "current_color", Color(1, 1, 1, 0), 6)


func _on_timer_timeout() -> void:
	queue_free()
