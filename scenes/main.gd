extends Node3D


func _ready():
	pass


func _process(_delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
