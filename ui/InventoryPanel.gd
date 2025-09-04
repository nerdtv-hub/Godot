extends Control
@export var slot_count: int = 24
var current_category: String = ""
var sort_by_amount: bool = false
var sort_button: Button
var category_buttons: Array[Button] = []

func _ready() -> void:
	visible = false
	sort_button = find_child("SortButton") as Button
	if sort_button == null:
			sort_button = find_child("Sort qty") as Button

	var grid := $GridContainer as GridContainer
	for i in range(grid.get_child_count()):
			_prepare_inventory_slot(grid.get_child(i) as Control, Vector2(64, 64))
	Inventory.changed.connect(func(): if visible: _update_all())
	visibility_changed.connect(_on_visibility_changed)
	_update_all()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("inventory_toggle"):
		visible = not visible
		if visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			_update_all()
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			sort_by_amount = false
			current_category = ""
			for btn in category_buttons:
					btn.button_pressed = false
			if sort_button:
					sort_button.button_pressed = false
			_update_all()

func _update_all() -> void:
	var grid := $GridContainer as GridContainer
	var ids: Array[String]
	if sort_by_amount:
		var items: Dictionary = Inventory.items.duplicate()
		ids = items.keys()
		ids.sort_custom(func(a: String, b: String) -> bool:
					return items[b] < items[a])
	else:
		ids = Inventory.get_sorted_ids()

	for i in range(grid.get_child_count()):
		var slot := grid.get_child(i) as Control

		var icon := slot.get_node_or_null("Icon") as TextureRect
		if icon == null:
			var arc := slot.get_node_or_null("IconARC") as AspectRatioContainer
			if arc:
				icon = arc.get_node_or_null("Icon") as TextureRect

		var count := slot.get_node_or_null("Count") as Label
		if icon == null or count == null:
			continue

		if i < ids.size():
			var id: String = ids[i]
			var info: Variant = ItemDB.get_info(id)
			icon.texture = info.icon if info != null else null
			count.text = str(Inventory.count(id))
		else:
			icon.texture = null
			count.text = ""

func _prepare_inventory_slot(slot: Control, min_size: Vector2) -> void:
	slot.clip_contents = true
	slot.custom_minimum_size = min_size
	slot.scale = Vector2.ONE
	slot.size_flags_horizontal = Control.SIZE_FILL
	slot.size_flags_vertical = Control.SIZE_FILL
	

	var icon := slot.get_node_or_null("Icon") as TextureRect
	if icon:
		icon.set_anchors_preset(Control.PRESET_FULL_RECT)
		icon.offset_left = 0
		icon.offset_top = 0
		icon.offset_right = 0
		icon.offset_bottom = 0
		icon.size_flags_horizontal = Control.SIZE_FILL
		icon.size_flags_vertical = Control.SIZE_FILL

		icon.ignore_texture_size = true
		# Wähle einen:
		icon.stretch_mode = TextureRect.STRETCH_SCALE                # exakt in Slot
		#icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED   # reinpassen, Seitenverhältnis

	var count := slot.get_node_or_null("Count") as Label
	if count:
		count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		count.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		count.text = ""
		
func _create_filter_bar() -> void:
		var bar := HBoxContainer.new()
		bar.name = "FilterBar"
		add_child(bar)
		var group := ButtonGroup.new()
		group.allow_unpress = true	

		var all_btn := Button.new()
		all_btn.text = "All"
		all_btn.toggle_mode = true
		all_btn.button_group = group
		all_btn.toggled.connect(func(pressed: bool):
				if pressed:
						current_category = ""
				elif current_category == "":
						current_category = ""
				_update_all()
		)
		bar.add_child(all_btn)
		category_buttons.append(all_btn)

		for cat in ItemDB.get_categories():
				var btn := Button.new()
				btn.text = cat.capitalize()
				btn.toggle_mode = true
				btn.button_group = group
				btn.toggled.connect(func(pressed: bool, c := cat):
					current_category = c if pressed else ""
					_update_all()
		)
				bar.add_child(btn)
				category_buttons.append(btn)

		sort_button = Button.new()
		sort_button.text = "Menge"
		sort_button.toggle_mode = true
		sort_button.toggled.connect(func(pressed: bool):
				sort_by_amount = pressed
				_update_all()
		)
		bar.add_child(sort_button)
		
func _on_visibility_changed() -> void:
		if not visible and sort_by_amount:
				sort_by_amount = false
				if sort_button:
						sort_button.button_pressed = false
				_update_all()

func _on_sort_button_toggled(toggled_on: bool) -> void:
		sort_by_amount = toggled_on
		_update_all()
