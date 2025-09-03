extends Node

class ItemInfo:
	var id: String
	var name: String
	var icon: Texture2D
	var mesh: Mesh
	var shape: Shape3D
	func _init(_id: String, _name: String, _icon_path: String, _mesh: Mesh, _shape: Shape3D) -> void:
			id = _id
			name = _name
			icon = load(_icon_path) as Texture2D
			mesh = _mesh
			shape = _shape

var data: Dictionary = {
	"stone": ItemInfo.new(
		"stone",
		"Stone",
		"res://ui/icons/stone.png",
		BoxMesh.new(),
		BoxShape3D.new()
	),
	"wood": ItemInfo.new(
		"wood",
		"Wood",
		"res://ui/icons/wood.png",
		CylinderMesh.new(),
		CylinderShape3D.new()
	),
	}

func get_info(id: String) -> ItemInfo:
	return data.get(id, null)

func create_pickup(id: String) -> RigidBody3D:
	var info := get_info(id)
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
