class_name Accessory
extends Item


func _init(
	name: String,
	description: String,
	icon: Texture2D,
) -> void:
	super(name, description, icon, 1, Item.ItemType.ACCESSORY)


func on_equip(_player: Player) -> void:
	pass


func on_unequip(_player: Player) -> void:
	pass
