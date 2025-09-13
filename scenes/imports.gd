class_name Imports
extends Object

const SPREAD_CLOUD_PARTICLES: PackedScene = preload("res://scenes/SpreadCloudParticles.tscn")
const HELD_SWORD_SCENE: PackedScene = preload("res://scenes/items/sword.tscn")

# SFX
const SFX: Dictionary = {
	"poof": preload("res://assets/sounds/poof.wav"),
	"equip_accessory": preload("res://assets/sounds/equip_accessory.wav"),
	"unequip_accessory": preload("res://assets/sounds/unequip_accessory.wav"),
	"slime_hit_1": preload("res://assets/sounds/slime_hit_1.wav"),
}

const MUSIC: Dictionary = {
	"save-as": preload("res://assets/music/save-as-115826.mp3"),
	"pixel-quest": preload("res://assets/music/pixel-quest-364092.mp3"),
}
