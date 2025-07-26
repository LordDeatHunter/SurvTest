extends Node3D

@onready var particles: GPUParticles3D = get_parent()


func _ready() -> void:
	particles.restart()
	particles.finished.connect(_on_finished)


func _on_finished() -> void:
	particles.queue_free()
