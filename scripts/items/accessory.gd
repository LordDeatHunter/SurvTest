class_name Accessory
extends Item


func _init(
	name: String,
	description: String,
	icon: Texture2D,
	color: Color = Color.DEEP_PINK,
) -> void:
	super(name, description, icon, 1, Item.ItemType.ACCESSORY, color)


func on_equip(_player: Player) -> void:
	AudioHandlerSingleton.play_sound("equip_accessory")


func on_unequip(_player: Player) -> void:
	AudioHandlerSingleton.play_sound("unequip_accessory")
