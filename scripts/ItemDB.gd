extends Node

const CATEGORY_TREE := {
		"material": ["stone", "wood"],
		"food": [],
		"special": [],
		"tool": [],
}

class ItemInfo:
	var id: String
	var name: String
	var icon: Texture2D
	var mesh: Mesh
	var shape: Shape3D
	var category: String
	var subcategory: String
	func _init(_id: String, _name: String, _icon_path: String, _mesh: Mesh, _shape: Shape3D, _category: String, _subcategory: String = "") -> void:
			id = _id
			name = _name
			icon = load(_icon_path) as Texture2D
			mesh = _mesh
			shape = _shape
			category = _category
			subcategory = _subcategory

var data: Dictionary = {
	"stone": ItemInfo.new(
		"stone",
		"Stone",
		"res://ui/icons/stone.png",
		BoxMesh.new(),
		BoxShape3D.new(),
		"material",
		"stone"
	),
	"wood": ItemInfo.new(
		"wood",
		"Wood",
		"res://ui/icons/wood.png",
		CylinderMesh.new(),
		CylinderShape3D.new(),
		"material",
		"wood"
	),
	"food": ItemInfo.new(
		"food",
		"Food",
		"res://ui/icons/food.png",
		PrismMesh.new(),
		BoxShape3D.new(),
		"cooking",
		"food"
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


func create_pickup(id: String) -> RigidBody3D:
	var info: ItemInfo = get_info(id)
	if info == null:
		return null
	var drop := RigidBody3D.new()
	drop.set_script(load("res://scripts/ItemPickup.gd"))
	drop.item_id = id
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = info.mesh.duplicate()
	drop.add_child(mesh_instance)
	var coll := CollisionShape3D.new()
	coll.shape = info.shape.duplicate()
	drop.add_child(coll)
	return drop
