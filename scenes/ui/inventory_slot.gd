class_name InventorySlot
extends TextureRect

signal item_click_pressed(button_index: int)
signal item_click_released(button_index: int)

const INVENTORY_SLOT_DOWN = preload("res://assets/textures/ui/inventory_slot_down.png")
const INVENTORY_SLOT_NORMAL = preload("res://assets/textures/ui/inventory_slot_normal.png")
const INVENTORY_SLOT_UP = preload("res://assets/textures/ui/inventory_slot_up.png")

var stack: ItemStack
var selected: bool = false

@onready var item_texture: TextureRect = %ItemTexture
@onready var quantity_label: Label = %QuantityLabel


func _ready() -> void:
	mouse_entered.connect(select.bind(false))
	mouse_exited.connect(deselect.bind(false))
	stack.quantity_changed.connect(_update_quantity_label)
	_update_quantity_label(stack.quantity)


func set_item(new_stack: ItemStack) -> void:
	stack.copy_from(new_stack)
	texture = INVENTORY_SLOT_NORMAL
	item_texture.texture = stack.item.icon if not stack.is_empty() else null


func deselect(set_value: bool = true) -> void:
	if selected and not set_value:
		return
	texture = INVENTORY_SLOT_NORMAL
	selected = false


func select(set_value: bool = true) -> void:
	texture = INVENTORY_SLOT_UP
	if set_value:
		selected = true


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			item_click_pressed.emit(event.button_index)
		else:
			item_click_released.emit(event.button_index)


func _update_quantity_label(amount: int = 0) -> void:
	if amount <= 0:
		quantity_label.text = ""
		return
	quantity_label.text = str(amount)
