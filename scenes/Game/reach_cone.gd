@tool
extends MeshInstance3D

@export var reach_distance: float = 1.25 : set = update_cone
@export var reach_radius:  float = 0.35  : set = update_cone

func _ready() -> void:
	update_cone()

func update_cone(_v := 0.0) -> void:
	var mesh := CylinderMesh.new()
	mesh.top_radius    = 0.0        # Spitze
	mesh.bottom_radius = reach_radius
	mesh.height        = reach_distance
	self.mesh = mesh
	transform = Transform3D(
		Basis().rotated(Vector3.RIGHT, -PI / 2),       # nach vorn kippen
		Vector3(0, 0, -reach_distance * 0.5)           # Spitze an Head
	)
