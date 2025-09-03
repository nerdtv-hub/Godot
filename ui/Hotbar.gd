extends Control

@export var slot_count: int = 8

func _ready() -> void:
	Inventory.changed.connect(_on_inventory_changed)
	Inventory.hotbar_selected_changed.connect(_on_selected_changed)
	var box := $HBoxContainer as HBoxContainer
	for i in range(box.get_child_count()):
		fit_slot_icon(box.get_child(i) as Control)
	_update_all()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var n: int = event.keycode - KEY_1
		if n >= 0 and n < slot_count:
			Inventory.set_hotbar_selected(n)
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			Inventory.set_hotbar_selected(Inventory.hotbar_selected - 1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			Inventory.set_hotbar_selected(Inventory.hotbar_selected + 1)

func _on_inventory_changed() -> void:
	_update_all()

func _on_selected_changed(_i: int) -> void:
	_update_selection()

func _update_all() -> void:
	var box := $HBoxContainer as HBoxContainer
	var ids: Array[String] = Inventory.get_hotbar_ids()
	for i in range(box.get_child_count()):
		var slot := box.get_child(i) as Node
		var icon := slot.get_node_or_null("Icon") as TextureRect
		if icon == null:
			icon = slot.get_node_or_null("icon") as TextureRect
		var count := slot.get_node_or_null("Count") as Label
		if count == null:
			count = slot.get_node_or_null("count") as Label

		if icon == null or count == null:
			_print_slot_tree(slot)  # einmal zum Diagnostizieren
			continue

		if i < ids.size():
			var id: String = ids[i]
			var info := ItemDB.get_info(id)
			icon.texture = info.icon if info != null else null
			count.text = str(Inventory.count(id))
		else:
			icon.texture = null
			count.text = ""
	_update_selection()

func _update_selection() -> void:
	var box := get_node("HBoxContainer") as HBoxContainer
	for i in range(slot_count):
		var slot := box.get_child(i) as Control
		slot.modulate = Color(1, 1, 1, 1) if i == Inventory.hotbar_selected else Color(0.8, 0.8, 0.8, 1)
		
func ensure_slot_layout(slot: Control) -> void:
	slot.clip_contents = true
	slot.custom_minimum_size = Vector2(64, 64)

	var arc := slot.get_node_or_null("IconARC") as AspectRatioContainer
	if arc == null:
		arc = AspectRatioContainer.new()
		arc.name = "IconARC"
		arc.ratio = 1.0
		arc.size_flags_horizontal = Control.SIZE_EXPAND
		arc.size_flags_vertical = Control.SIZE_EXPAND
		slot.add_child(arc)

	var icon := slot.get_node_or_null("Icon") as TextureRect
	if icon:
		if icon.get_parent() != arc:
			icon.get_parent().remove_child(icon)
			arc.add_child(icon)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.size_flags_horizontal = Control.SIZE_EXPAND
		icon.size_flags_vertical = Control.SIZE_EXPAND

	var count := slot.get_node_or_null("Count") as Label
	if count:
		count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		count.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM

func _print_slot_tree(root: Node) -> void:
	print("Slot tree: ", root.name)
	_print_tree_rec(root, 0)

func _print_tree_rec(n: Node, depth: int) -> void:
	var ind := ""
	for j in range(depth): ind += "  "
	print(ind, "- ", n.name, " (", n.get_class(), ")")
	for c in n.get_children():
		_print_tree_rec(c, depth + 1)

func fit_slot_icon(slot: Control) -> void:
	slot.clip_contents = true
	slot.custom_minimum_size = Vector2(64, 64)
	slot.size_flags_horizontal = Control.SIZE_EXPAND
	slot.size_flags_vertical = Control.SIZE_EXPAND

	var icon := slot.get_node("Icon") as TextureRect
	icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon.offset_left = 0
	icon.offset_top = 0
	icon.offset_right = 0
	icon.offset_bottom = 0

	# Wichtig: nur diese beiden
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.ignore_texture_size = true

	icon.size_flags_horizontal = Control.SIZE_EXPAND
	icon.size_flags_vertical = Control.SIZE_EXPAND

	var count := slot.get_node("Count") as Label
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	count.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
