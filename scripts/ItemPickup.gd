extends Interactable

@export var item_id: String = ""

@export var amount: int = 1

func interact(_by: Node) -> void:
	Inventory.add_item(item_id, amount)
	queue_free()
