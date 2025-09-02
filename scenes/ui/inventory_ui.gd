class_name InventoryUi
extends GridContainer

signal slot_clicked(slot_index: int, stack: Slot)

const ITEM_SLOT: PackedScene = preload("res://scenes/ui/inventory_slot.tscn")

@export var inventory_size: int = 9
@export var item_type: Item.ItemType

var slots: Array[InventorySlot]
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
	slots = []

	for child in get_children():
		child.queue_free()

	for i in range(inventory_size):
		var ui_slot: InventorySlot = ITEM_SLOT.instantiate()
		ui_slot.slot = inventory.slots[i]
		ui_slot.slot.item_type = item_type
		ui_slot.item_click_pressed.connect(_on_item_slot_pressed.bind(i))

		slots.append(ui_slot)
		add_child(ui_slot)


func _on_item_slot_pressed(button_index: int, index: int) -> void:
	var slot: Slot = slots[index].slot
	slot_clicked.emit(button_index, index, slot)
	selected_slot = index


func increment_selected_slot(amount: int) -> void:
	selected_slot = (selected_slot + amount + inventory_size) % inventory_size
