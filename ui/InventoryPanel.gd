extends Control
@export var slot_count: int = 24
var current_category: String = ""
var sort_by_amount: bool = false
var sort_button: Button
var category_buttons: Array[Button] = []

func _ready() -> void:
	visible = false
	var grid := $GridContainer as GridContainer
	_create_filter_bar(grid)
	for i in range(grid.get_child_count()):
			_prepare_inventory_slot(grid.get_child(i) as Control, Vector2(64, 64))
	Inventory.changed.connect(func(): if visible: _update_all())
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
	var ids: Array[String] = Inventory.get_sorted_ids(sort_by_amount)
	if current_category != "":
			var filtered: Array[String] = []
			for id in ids:
					var info := ItemDB.get_info(id)
					if info and info.category == current_category:
							filtered.append(id)
			ids = filtered

	for slot in grid.get_children():
				var icon := slot.get_node_or_null("Icon") as TextureRect
				if icon == null:
						var arc := slot.get_node_or_null("IconARC") as AspectRatioContainer
						if arc:
								icon = arc.get_node_or_null("Icon") as TextureRect
				var count := slot.get_node_or_null("Count") as Label
				if icon:
						icon.texture = null
				if count:
						count.text = ""

	var limit: int = min(ids.size(), grid.get_child_count())
	for i in range(limit):
				var slot := grid.get_child(i) as Control
				var icon := slot.get_node_or_null("Icon") as TextureRect
				if icon == null:
						var arc := slot.get_node_or_null("IconARC") as AspectRatioContainer
						if arc:
								icon = arc.get_node_or_null("Icon") as TextureRect
				var count := slot.get_node_or_null("Count") as Label
				var id: String = ids[i]
				var info: ItemDB.ItemInfo = ItemDB.get_info(id)
				if icon:
						icon.texture = info.icon if info else null
				if count:
						count.text = str(Inventory.count(id)) if info else ""

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
		
func _create_filter_bar(grid: GridContainer) -> void:
		var bar := HBoxContainer.new()
		bar.name = "FilterBar"
		bar.anchor_left = 0.5
		bar.anchor_right = 0.5
		bar.anchor_top = 0.5
		bar.anchor_bottom = 0.5
		bar.offset_left = grid.offset_left
		bar.offset_right = grid.offset_right
		var height := 24
		bar.offset_top = grid.offset_top - height - 4
		bar.offset_bottom = grid.offset_top - 4
		bar.custom_minimum_size.y = height
		bar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
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
				_update_all()
		)
		bar.add_child(all_btn)
		category_buttons.append(all_btn)

		for cat in ItemDB.get_categories():
				var btn := Button.new()
				btn.text = ("Food" if cat == "cooking" else cat.capitalize())
				btn.text = cat.capitalize()
				btn.toggle_mode = true
				btn.button_group = group
				btn.toggled.connect(func(pressed: bool, c := cat):
					if pressed:
							current_category = c
					elif current_category == c:
							current_category = ""
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
