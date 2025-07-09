class_name InventoryUi
extends GridContainer

signal slot_clicked(slot_index: int, stack: ItemStack)

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

@onready var item_template: PackedScene = preload("res://scenes/ui/inventory_slot.tscn")


func _ready():
	inventory = Inventory.new(inventory_size)
	inventory.item_added.connect(_update_slot)
	_update_inventory()
	selected_slot = 0


func _update_inventory():
	for child in get_children():
		child.queue_free()

	for i in range(inventory.get_size()):
		var item_slot: InventorySlot = item_template.instantiate()
		item_slot.stack = inventory.items[i]
		item_slot.item_click_pressed.connect(_on_item_slot_pressed.bind(i))

		if not inventory.items[i].is_empty():
			item_slot.set_item(inventory.items[i])

		add_child(item_slot)


func _update_slot(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= inventory.get_size():
		return

	var item_slot: InventorySlot = get_child(slot_index) as InventorySlot
	item_slot.set_item(inventory.items[slot_index])


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


func slot_clicked_with_stack(slot_index: int, stack: ItemStack) -> bool:
	return inventory.stack_item(slot_index, stack)


func set_item(slot_index: int, stack: ItemStack) -> void:
	inventory.set_item(slot_index, stack)


func remove_quantity(slot_index: int, amount: int) -> void:
	if slot_index < 0 or slot_index >= inventory.get_size():
		return

	var item_slot: InventorySlot = get_child(slot_index) as InventorySlot
	item_slot.stack.remove_quantity(amount)


func get_item(slot_index: int) -> ItemStack:
	if slot_index < 0 or slot_index >= inventory.get_size():
		return null

	var item_slot: InventorySlot = get_child(slot_index) as InventorySlot

	return item_slot.stack


func _on_item_slot_pressed(button_index: int, index: int) -> void:
	var stack: ItemStack = inventory.items[index]
	slot_clicked.emit(button_index, index, stack)
	selected_slot = index
