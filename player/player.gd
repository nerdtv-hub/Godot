extends CharacterBody3D

@export var speed: float = 6.0
@export var gravity: float = 24.0
@export var jump_velocity: float = 8.0

@export var mouse_sensitivity: float = 0.003
@export var max_pitch_deg: float = 89.0

@export var push_strength: float = 0.05
@export var push_min_speed: float = 0.5
@export var push_max_impulse: float = 50.0
@export var push_horizontal_only: bool = true
@export var push_apply_at_contact: bool = false

@export var interact_distance: float = 5

@export var reach_distance: float = 3
@export var reach_radius: float = 1.25


@onready var head: Node3D = $Head
@onready var camera_pivot: Node3D = $Head/CameraPivot
#@onready var interact_ray: RayCast3D = $Head/InteractRay
@onready var reach_cast: ShapeCast3D = $Head/ReachCast
@onready var reach_cone: MeshInstance3D = $Head/ReachCast/ReachCone

var pitch_rad: float = 0.0

var cone_local := Transform3D(
	Basis()
		.rotated(Vector3.RIGHT, -PI / 2)  # Y → –Z
		.rotated(Vector3.UP, PI),           # +Z → -Z (180° Flip)
	Vector3(0, 0, -reach_distance * 0.5)       # +Z → Spitze im Head
)



func _ready() -> void:
	var floor := $"../Floor" #Pfad zum Boden
	var cone_mesh := CylinderMesh.new()
	cone_mesh.top_radius    = 0.0             # Spitze
	cone_mesh.bottom_radius = reach_radius
	cone_mesh.height        = reach_distance
	reach_cone.mesh = cone_mesh
	#interact_ray.add_exception(floor)
	reach_cast.add_exception(floor)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#interact_ray.enabled = true
	# Eigenen Körper ignorieren (beides schadet nicht):
	#interact_ray.exclude_parent = true
	#interact_ray.add_exception(self)ce
	reach_cast.shape = cone_mesh.create_convex_shape()
	reach_cast.add_exception(self)
	reach_cast.exclude_parent = true

		
		
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		pitch_rad = clamp(
			pitch_rad - event.relative.y * mouse_sensitivity,
			deg_to_rad(-max_pitch_deg),
			deg_to_rad(max_pitch_deg)
		)
		camera_pivot.rotation.x = pitch_rad
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(
			Input.MOUSE_MODE_VISIBLE if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED
		)



func _physics_process(_delta: float) -> void:
	var basis  := camera_pivot.global_transform.basis
	var origin := head.global_transform.origin
	reach_cast.global_transform = Transform3D(basis, origin) * cone_local
	reach_cast.target_position  = Vector3.ZERO
	reach_cone.global_transform = reach_cast.global_transform

	# Ray an Blickrichtung koppeln
	#interact_ray.global_transform = Transform3D(
		#camera_pivot.global_transform.basis,
		#interact_ray.global_transform.origin
	#)
	#interact_ray.target_position = Vector3(0.0, 0.0, -interact_distance)
	
	var input2d: Vector2 = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	var direction: Vector3 = (transform.basis * Vector3(input2d.x, 0.0, input2d.y)).normalized()

	if not is_on_floor():
		velocity.y -= gravity * _delta

	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)
		velocity.z = move_toward(velocity.z, 0.0, speed)

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	var pre_vel: Vector3 = velocity
	move_and_slide()

	for i in range(get_slide_collision_count()):
		var col: KinematicCollision3D = get_slide_collision(i)
		var rb: RigidBody3D = col.get_collider() as RigidBody3D
		if rb == null or rb.freeze:
			continue

		var normal: Vector3 = col.get_normal()
		var n: Vector3 = normal
		if push_horizontal_only:
			n = Vector3(normal.x, 0.0, normal.z)
			if n.length() < 0.001:
				continue
			n = n.normalized()

		# Beiträge beider Seiten entlang der Normalen
		var rb_vel: Vector3 = col.get_collider_velocity()
		var player_in: float = max(0.0, -pre_vel.dot(n))
		var rigid_in: float = max(0.0, rb_vel.dot(n))

		# Nur stoßen, wenn der Spieler "treibend" ist
		if player_in < push_min_speed or player_in <= rigid_in:
			continue

		var net_closing: float = player_in - rigid_in
		var impulse_dir: Vector3 = -n
		var impulse_mag: float = min(push_max_impulse, net_closing * push_strength * max(0.5, rb.mass))
		var impulse: Vector3 = impulse_dir * impulse_mag

		if push_apply_at_contact:
			var contact_world: Vector3 = col.get_position()
			var offset: Vector3 = contact_world - rb.global_transform.origin
			rb.sleeping = false
			rb.apply_impulse(impulse, offset)
		else:
			rb.sleeping = false
			rb.apply_impulse(impulse)
	
	


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		# Erst Nahbereich prüfen
		reach_cast.force_shapecast_update()
		if reach_cast.is_colliding():
			var hit := reach_cast.get_collider(0)
			var target: Node = _resolve_interactable_from_collider(hit)
			if target and target.has_method("interact"):
				target.interact(self)
				return
	if Input.is_action_just_pressed("drop"):
		_drop_selected()
		#_debug_dump_ray()

func _resolve_interactable_from_collider(hit: Object) -> Node:
	var node: Node = hit as Node
	while node:
		if node is Interactable or node.has_method("interact"):
			return node
		node = node.get_parent()
	return null
	
	
func _drop_selected() -> void:
	var ids := Inventory.get_hotbar_ids()
	if Inventory.hotbar_selected >= ids.size():
			return
	var id := ids[Inventory.hotbar_selected]
	if Inventory.count(id) <= 0:
			return
	Inventory.remove_item(id, 1)
	var drop := ItemDB.create_pickup(id)
	if drop == null:
		return
	get_parent().add_child(drop)
	var forward := -camera_pivot.global_transform.basis.z.normalized()
	drop.global_position = head.global_position + forward * 2.0 - Vector3.UP * 0.5
	
	
#func _debug_dump_ray() -> void:
#	print("--- Ray Debug ---")
#	print("origin: ", interact_ray.global_transform.origin)
#	print("dir(-Z): ", -interact_ray.global_transform.basis.z)
#	print("target_position(local): ", interact_ray.target_position)
#	print("end(world): ", interact_ray.to_global(interact_ray.target_position))
#	print("enabled: ", interact_ray.enabled, "  mask: ", interact_ray.collision_mask, "  exclude_parent: ", interact_ray.exclude_parent)
#	print("is_colliding: ", interact_ray.is_colliding())
#	if interact_ray.is_colliding():
#		print("hit: ", interact_ray.get_collider(), "  point: ", interact_ray.get_collision_point(), "  normal: ", interact_ray.get_collision_normal())
#	print("-----------------")
	
