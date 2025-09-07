class_name SwordItem
extends Item

const SWORD_ITEM_TEXTURE: Texture2D = preload("res://assets/textures/sword.png")


func _init() -> void:
	super(
		"Sword",
		"A basic sword.",
		SWORD_ITEM_TEXTURE,
		1,
		Item.ItemType.GENERIC,
		Color.SILVER,
	)
