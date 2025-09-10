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
	var mesh: Mesh
	var shape: Shape3D
	var texture: StandardMaterial3D
	var category: String
	var subcategory: String
	var drop_scale: float = 1.0
	func _init(_id: String, _name: String, _icon_path: String, _mesh: Mesh, _shape: Shape3D, _category: String, _subcategory: String = "", _drop_scale: float = 1.0) -> void:
			id = _id
			name = _name
			icon = load(_icon_path) as Texture2D
			mesh = _mesh
			shape = _shape
			category = _category
			subcategory = _subcategory
			drop_scale = _drop_scale
			
# Preload item meshes and collision shapes from OBJ models.
var STONE_MESH: Mesh = load("res://assets/OBJ format/resource-stone.obj")
var STONE_SHAPE: Shape3D = STONE_MESH.create_convex_shape()
var WOOD_MESH: Mesh = load("res://assets/OBJ format/resource-wood.obj")
var WOOD_SHAPE: Shape3D = WOOD_MESH.create_convex_shape()
var FISH_MESH: Mesh = load("res://assets/OBJ format/fish-large.obj")
var FISH_SHAPE: Shape3D = FISH_MESH.create_convex_shape()

var data: Dictionary = {
	"stone": ItemInfo.new(
		"stone",
		"Stone",
		"res://ui/icons/stone.png",
		STONE_MESH,
		STONE_SHAPE,
		"material",
		"",
		6.0
	),
	"wood": ItemInfo.new(
		"wood",
		"Wood",
		"res://ui/icons/wood.png",
		WOOD_MESH,
		WOOD_SHAPE,
		"material",
		"",
		6.0
	),
	"fish": ItemInfo.new(
		"fish",
		"Fish",
		"res://ui/icons/fish.png",
		FISH_MESH,
		FISH_SHAPE,
		"cooking",
		"food",
		4.0
	),
	
	"cake": ItemInfo.new(
		"cake",
		"Cake",
		"res://ui/icons/cake.png",
		TorusMesh.new(),
		CylinderShape3D.new(),
		"cooking",
		"food",
		4.0
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
		mesh_instance.mesh = info.mesh
		mesh_instance.scale = Vector3.ONE * info.drop_scale
		drop.add_child(mesh_instance)
		var coll := CollisionShape3D.new()
		coll.shape = info.shape
		coll.scale = Vector3.ONE * info.drop_scale
		drop.add_child(coll)
		return drop
