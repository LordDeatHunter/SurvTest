class_name InventoryUi
extends GridContainer

signal slot_clicked(slot_index: int, stack: ItemStack)

const ITEM_SLOT: PackedScene = preload("res://scenes/ui/inventory_slot.tscn")

@export var inventory_size: int = 9

var inventory: Inventory
var selected_slot: int:
	get:
		return selected_slot
	set(value):
		var previous_slot: InventorySlot = get_child(selected_slot) as InventorySlot
		previous_slot.deselect()
		selected_slot = value
		var new_slot: InventorySlot = get_child(value) as InventorySlot
		new_slot.select()


func _ready():
	_init_inventory()
	selected_slot = 0


func _init_inventory():
	inventory = Inventory.new(inventory_size)

	for child in get_children():
		child.queue_free()

	for i in range(inventory.get_size()):
		var item_slot: InventorySlot = ITEM_SLOT.instantiate()
		item_slot.stack = inventory.items[i]
		item_slot.item_click_pressed.connect(_on_item_slot_pressed.bind(i))

		if not inventory.items[i].is_empty():
			item_slot.set_item(inventory.items[i])

		add_child(item_slot)


func _input(event: InputEvent) -> void:
	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_WHEEL_UP
		and event.is_pressed()
	):
		selected_slot = (selected_slot - 1 + inventory.get_size()) % inventory.get_size()
	elif (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_WHEEL_DOWN
		and event.is_pressed()
	):
		selected_slot = (selected_slot + 1) % inventory.get_size()


func _on_item_slot_pressed(button_index: int, index: int) -> void:
	var stack: ItemStack = inventory.items[index]
	slot_clicked.emit(button_index, index, stack)
	selected_slot = index
