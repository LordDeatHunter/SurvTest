class_name HeldSword
extends Node3D

@onready var animation_player: AnimationPlayer = %AnimationPlayer

func swing() -> void:
	animation_player.play('attack')


func _on_area_3d_body_entered(body: Node3D) -> void:
	print(body)
	if body is RigidBody3D:
		body.apply_force(Vector3(0, 200, 0))
