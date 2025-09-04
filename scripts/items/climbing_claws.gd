class_name ClimbingClaws
extends Accessory

const CLAWS_ITEM_TEXTURE: Texture2D = preload("res://assets/textures/climbing_claws.png")


func _init() -> void:
	super("Climbing Claws", "Placeholder boots item.", CLAWS_ITEM_TEXTURE, Color.RED)


func on_equip(player: Player) -> void:
	player.can_wallclimb = true


func on_unequip(player: Player) -> void:
	player.can_wallclimb = false
