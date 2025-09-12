extends Node

const CATEGORY_TREE := {
		"material": [],
		"cooking": ["food", "zutaten"],
		"special": [],
		"tool": [],
}

class ItemInfo extends RefCounted:
		var id: String
		var name: String
		var icon: Texture2D
		var category: String
		var subcategory: String
		var drop_scale: float
		func _init(_id: String, _name: String, _icon_path: String, _category: String, _subcategory: String = "", _drop_scale: float = 1.0) -> void:
				id = _id
				name = _name
				icon = load(_icon_path) as Texture2D
				category = _category
				subcategory = _subcategory
				drop_scale = _drop_scale

var pickup_templates: Dictionary = {}

var data: Dictionary = {
"stone": ItemInfo.new(
				"stone",
				"Stone",
				"res://ui/icons/stone.png",
				"material",
				"",
				6.0
		),
		"wood": ItemInfo.new(
				"wood",
				"Wood",
				"res://ui/icons/wood.png",
				"material",
				"",
				6.0
		),
		"fish": ItemInfo.new(
				"fish",
				"Fish",
				"res://ui/icons/fish.png",
				"cooking",
				"food",
				4.0
		),

		"cake": ItemInfo.new(
				"cake",
				"Cake",
				"res://ui/icons/cake.png",
				"cooking",
				"food",
				1.0
		),
		}
	
func get_categories() -> Array[String]:
		var cats: Array[String] = []
		for c in CATEGORY_TREE.keys():
				cats.append(String(c))
		return cats

func get_subcategories(cat: String) -> Array[String]:
		var subs: Array[String] = []
		for s in CATEGORY_TREE.get(cat, []):
				subs.append(String(s))
		return subs


func get_info(id: String) -> ItemInfo:
	return data.get(id, null)
	
func get_items_in_category(category: String, subcategory: String = "") -> Array[ItemInfo]:
		var result: Array[ItemInfo] = []
		for info in data.values():
				if info.category != category:
						continue
				if subcategory != "" and info.subcategory != subcategory:
						continue
				result.append(info)
		return result

func init_templates(world: Node) -> void:
		var paths := {
				"stone": "Stone",
				"wood": "Wood",
				"fish": "Fish",
				"cake": "Cake",
		}
		for id in paths.keys():
				var node: Node = world.get_node_or_null(paths[id])
				if node:
						pickup_templates[id] = node.duplicate()
						node.queue_free()


func create_pickup(id: String, amount: int = 1) -> RigidBody3D:
		var template: Node = pickup_templates.get(id, null)
		if template:
				var pickup := template.duplicate() as RigidBody3D
				pickup.item_id = id
				pickup.amount = amount
				var info := get_info(id)
				if info:
						for child in pickup.get_children():
								if child is MeshInstance3D or child is CollisionShape3D:
										child.scale = Vector3.ONE * info.drop_scale
						pickup.scale = Vector3.ONE * info.drop_scale
				return pickup
		return null
