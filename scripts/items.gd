class_name Items

const EXAMPLE_ITEM_TEXTURE: Texture2D = preload("res://assets/textures/item1.png")
static var example_item: Item = Item.new(
	"Example Item", "This is an example item.", EXAMPLE_ITEM_TEXTURE, 99
)
