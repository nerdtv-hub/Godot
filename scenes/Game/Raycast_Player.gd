extends RayCast3D

@export var interact_distance: float = 3.0

@onready var interact_ray: RayCast3D = $Head/InteractRay
@onready var camera_pivot: SpringArm3D = $CameraPivot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Ray soll den Spieler/Körper nicht treffen
	self.enabled = true
	if self.has_method("set_exclude_parent_body"):
		# Falls verfügbar
		self.set_exclude_parent_body(true)
	
func _process(_delta: float) -> void:
	# Nur die Rotation vom SpringArm/CameraPivot übernehmen
	interact_ray.global_transform.basis = camera_pivot.global_transform.basis
	# Ray zeigt lokal nach -Z; Länge nach vorne ab der Spielerposition
	interact_ray.target_position = Vector3(0.0, 0.0, -interact_distance)

	# Vor der Abfrage aktualisieren (weil wir im _process, nicht Physik-Tick sind)
	interact_ray.force_raycast_update()

	if Input.is_action_just_pressed("interact") and interact_ray.is_colliding():
		var collider = interact_ray.get_collider()
		if collider:
			var node = collider
			if node is CollisionObject3D and node.owner:
				node = node.owner
			if node is Interactable:
				node.interact(self)
