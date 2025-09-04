class_name Items

const EXAMPLE_ITEM_1_TEXTURE: Texture2D = preload("res://assets/textures/item1.png")
const EXAMPLE_ITEM_2_TEXTURE: Texture2D = preload("res://assets/textures/item2.png")

static var example_item_1: Item = Item.new(
	"Example Item 1", "This is an example item 1.", EXAMPLE_ITEM_1_TEXTURE, 99
)
static var example_item_2: Item = Item.new(
	"Example Item 2", "This is an example item 2.", EXAMPLE_ITEM_2_TEXTURE, 99
)
static var boots: JumpBoots = JumpBoots.new()
