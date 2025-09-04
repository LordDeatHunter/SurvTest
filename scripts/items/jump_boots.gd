class_name JumpBoots
extends Accessory

const BOOTS_ITEM_TEXTURE: Texture2D = preload("res://assets/textures/boots.png")

var added_multijumps: int = 1


func _init() -> void:
	super("Boots", "Placeholder boots item.", BOOTS_ITEM_TEXTURE)


func on_equip(player: Player) -> void:
	super.on_equip(player)
	player.max_multijumps += added_multijumps


func on_unequip(player: Player) -> void:
	super.on_unequip(player)
	player.max_multijumps -= added_multijumps
