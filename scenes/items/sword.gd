class_name HeldSword
extends Node3D

var player: Player

@onready var animation_player: AnimationPlayer = %AnimationPlayer


func swing(player: Player) -> void:
	self.player = player
	animation_player.play("attack")


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is RigidBody3D:
		body.apply_force(Vector3(0, 200, 0))


func _on_area_3d_area_entered(area: Area3D) -> void:
	var slime: Slime = area.get_parent_node_3d().get_parent_node_3d() as Slime
	if slime:
		slime.hit(player)
