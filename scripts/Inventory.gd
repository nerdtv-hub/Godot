extends Node

signal changed
signal hotbar_selected_changed(index: int)

const HOTBAR_SIZE: int = 8
var items: Dictionary = {}
var item_order: Array[String] = []
var hotbar_selected: int = 0
var hotbar_slots: Array[String] = []


func _ready() -> void:
	hotbar_slots.resize(HOTBAR_SIZE)
	add_item("stone", 20)
	add_item("wood", 3)
	add_item("fish", 3)
	add_item("cake", 3)

func set_hotbar_slot(index: int, id: String) -> void:
		if index < 0 or index >= HOTBAR_SIZE:
			return
		if id != "" and not items.has(id):
			return
		hotbar_slots[index] = id
		changed.emit()

func add_item(id: String, amount: int = 1) -> void:
		if not hotbar_slots.has(id):
			var empty_index := hotbar_slots.find("")
			if empty_index != -1:
				hotbar_slots[empty_index] = id
		var is_new: bool = not items.has(id)
		items[id] = int(items.get(id, 0)) + amount
		if is_new and items[id] > 0:
				item_order.append(id)
		changed.emit()
	
	
func remove_item(id: String, amount: int = 1) -> void:
	#items[id] = int(items.get(id, 0)) - amount
	#emit_signal("changed")
	if not items.has(id):
		return
	items[id] = int(items[id]) - amount
	if items[id] <= 0:
		items.erase(id)
		item_order.erase(id)
		for i in range(HOTBAR_SIZE):
			if hotbar_slots[i] == id:
				hotbar_slots[i] = ""
	changed.emit()
	
func set_hotbar_selected(i: int) -> void:
	hotbar_selected = clamp(i, 0, HOTBAR_SIZE - 1)
	hotbar_selected_changed.emit(hotbar_selected)

func count(id: String) -> int:
	return int(items.get(id, 0))

func _sort_by_amount_desc(a: String, b: String) -> bool:
		return int(items.get(a, 0)) > int(items.get(b, 0))

func _sort_by_amount_asc(a: String, b: String) -> bool:
		return int(items.get(a, 0)) < int(items.get(b, 0))

func get_sorted_ids(sort_order: int = 0, category: String = "", subcategory: String = "") -> Array[String]:
				var ids: Array[String] = item_order.duplicate() as Array[String]
				if sort_order != 0:
								if sort_order > 0:
												ids.sort_custom(_sort_by_amount_desc)
								else:
												ids.sort_custom(_sort_by_amount_asc)
				if category != "":
					var filtered: Array[String] = []
					for id in ids:
						var info := ItemDB.get_info(id)
						if info and info.category == category and (subcategory == "" or info.subcategory == subcategory):
										filtered.append(id)
					ids = filtered
				return ids

func get_hotbar_ids() -> Array[String]:
	return hotbar_slots.duplicate() as Array[String]
	
