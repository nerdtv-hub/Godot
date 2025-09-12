extends Interactable

@export var item_id: String = ""

@export var amount: int = 1

func interact(_by: Node) -> void:
	Inventory.add_item(item_id, amount)
	queue_free()
	self.collision_layer = 1 << 1  # layer 2: items
	self.collision_mask = 1        # collide only with layer 1 (world & player)
