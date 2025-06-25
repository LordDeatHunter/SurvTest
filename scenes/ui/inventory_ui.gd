class_name InventoryUi
extends GridContainer

var inventory: Inventory = Inventory.new(9)
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
	_update_inventory()
	selected_slot = 0


func _update_inventory():
	for child in get_children():
		child.queue_free()

	for i in range(inventory.get_size()):
		var item_slot: InventorySlot = item_template.instantiate()
		item_slot.item = inventory.items[i]

		if inventory.items[i] is Item:
			item_slot.set_item(inventory.items[i] as Item)

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
	elif (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and event.is_pressed()
	):
		var mouse_pos: Vector2 = get_global_mouse_position()
		for i in range(get_child_count()):
			var slot: InventorySlot = get_child(i) as InventorySlot
			if slot.get_global_rect().has_point(mouse_pos):
				selected_slot = i
				break
