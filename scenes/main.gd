extends Node3D

func _ready() -> void:
	var hud: CanvasLayer = CanvasLayer.new()
	add_child(hud)

	var hotbar_scene: PackedScene = load("res://ui/Hotbar.tscn")
	var hotbar: Control = hotbar_scene.instantiate() as Control
	hotbar.name = "Hotbar"
	hud.add_child(hotbar)

	var inv_scene: PackedScene = load("res://ui/InventoryPanel.tscn")
	var inventory_panel: Control = inv_scene.instantiate() as Control
	inventory_panel.name = "InventoryPanel"
	hud.add_child(inventory_panel)
