extends Node

class ItemInfo:
	var id: String
	var name: String
	var icon: Texture2D
	func _init(_id: String, _name: String, _icon_path: String) -> void:
		id = _id
		name = _name
		icon = load(_icon_path) as Texture2D

var data: Dictionary = {
	"stone": ItemInfo.new("stone", "Stone", "res://ui/icons/stone.png"),
	"wood": ItemInfo.new("wood", "Wood", "res://ui/icons/wood.png"),
}

func get_info(id: String) -> ItemInfo:
	return data.get(id, null)
	
