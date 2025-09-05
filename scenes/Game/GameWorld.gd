extends Node3D


func _ready() -> void:
	var hud: CanvasLayer = CanvasLayer.new()
	add_child(hud)

	var hotbar_scene: PackedScene = load("res://ui/Hotbar.tscn")
	var hotbar: Control = hotbar_scene.instantiate() as Control
	hud.add_child(hotbar)

	var inv_scene: PackedScene = load("res://ui/InventoryPanel.tscn")
	var inventory_panel: Control = inv_scene.instantiate() as Control
	hud.add_child(inventory_panel)

	# Sichtbarkeit testen
	print("HUD added:", hotbar, inventory_panel)


# Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
		pass
