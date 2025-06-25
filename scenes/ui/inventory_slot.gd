class_name InventorySlot
extends TextureRect

const INVENTORY_SLOT_DOWN = preload("res://assets/textures/ui/inventory_slot_down.png")
const INVENTORY_SLOT_NORMAL = preload("res://assets/textures/ui/inventory_slot_normal.png")
const INVENTORY_SLOT_UP = preload("res://assets/textures/ui/inventory_slot_up.png")

var item: Item = null
var selected: bool = false


func _ready() -> void:
	mouse_entered.connect(select.bind(false))
	mouse_exited.connect(deselect.bind(false))


func set_item(new_item: Item) -> void:
	item = new_item
	texture = INVENTORY_SLOT_NORMAL


func deselect(set_value: bool = true) -> void:
	if selected and not set_value:
		return
	texture = INVENTORY_SLOT_NORMAL
	selected = false


func select(set_value: bool = true) -> void:
	texture = INVENTORY_SLOT_UP
	if set_value:
		selected = true
