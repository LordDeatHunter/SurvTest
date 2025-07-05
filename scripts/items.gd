class_name Items

const EXAMPLE_ITEM_TEXTURE: Texture2D = preload("res://assets/textures/item1.png")


static func create_example_item() -> Item:
	return Item.new("Example Item", "This is an example item.", EXAMPLE_ITEM_TEXTURE, 1, 99)
