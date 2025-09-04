extends Node

signal changed
signal hotbar_selected_changed(index: int)

const HOTBAR_SIZE: int = 8
var items: Dictionary = {}
var hotbar_selected: int = 0

func add_item(id: String, amount: int = 1) -> void:
	items[id] = int(items.get(id, 0)) + amount
	emit_signal("changed")
	
	
func remove_item(id: String, amount: int = 1) -> void:
	#items[id] = int(items.get(id, 0)) - amount
	#emit_signal("changed")
	if not items.has(id):
		return
	items[id] = int(items[id]) - amount
	if items[id] <= 0:
		items.erase(id)
	emit_signal("changed")
	
func set_hotbar_selected(i: int) -> void:
	hotbar_selected = clamp(i, 0, HOTBAR_SIZE - 1)
	emit_signal("hotbar_selected_changed", hotbar_selected)

func count(id: String) -> int:
	return int(items.get(id, 0))

func get_sorted_ids(category: String = "", sort_by_amount: bool = false) -> Array[String]:
	var ids: Array[String] = []
	for k in items.keys():
		var info := ItemDB.get_info(String(k))
		if category == "" or (info != null and info.category == category):
			ids.append(String(k))
	if sort_by_amount:
			ids.sort_custom(func(a, b): return items[b] < items[a])
	else:
			ids.sort()
	return ids

func get_hotbar_ids() -> Array[String]:
	var ids := get_sorted_ids()
	return ids.slice(0, HOTBAR_SIZE)
