extends RigidBody3D
@export var item_id: String = ""

@export var amount: int = 1

var _settle_time := 0.0
const SETTLE_DELAY := 0.5


func _ready() -> void:
		contact_monitor = true
		max_contacts_reported = 4
		# Place pickups on a dedicated physics layer so they don't collide with each other
		# while still interacting with the default layer used by the player and floor.
		self.collision_layer = 1 << 1  # layer 2: items
		self.collision_mask = 1        # collide only with layer 1 (world & player)
		var info := ItemDB.get_info(item_id)
		if info:
				for child in get_children():
						if child is MeshInstance3D or child is CollisionShape3D:
								child.scale = Vector3.ONE
				scale = Vector3.ONE * info.drop_scale
		linear_damp = 1.0
		angular_damp = 1.0
		body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
		if freeze:
				return
		if linear_velocity.length() < 0.05 and angular_velocity.length() < 0.05:
				_settle_time += delta
				if _settle_time >= SETTLE_DELAY:
						freeze = true
		else:
				_settle_time = 0.0

func interact(_by: Node) -> void:
		Inventory.add_item(item_id, amount)
		queue_free()

func _on_body_entered(collider: Node) -> void:
		if freeze and collider is CharacterBody3D:
				freeze = false
				sleeping = false
