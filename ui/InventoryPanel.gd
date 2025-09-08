extends Control
@export var slot_count: int = 24
var current_category: String = ""
var sort_order: int = 0
var sort_button: Button
var category_buttons: Array[Button] = []
@onready var hotbar: Control = get_parent().get_node_or_null("Hotbar")
@onready var grid: GridContainer = $GridContainer

func _ready() -> void:
	visible = false
	var bar: HBoxContainer = _create_filter_bar()
	var layout := VBoxContainer.new()
	layout.alignment = BoxContainer.ALIGNMENT_CENTER
	layout.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	layout.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	layout.add_child(bar)


	# Reparent the existing grid under the layout so it sits below the bar
	grid.reparent(layout)
	grid.set_anchors_preset(Control.PRESET_TOP_LEFT)
	grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	grid.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	# Center the whole layout within this panel
	var center := CenterContainer.new()
	center.name = "InventoryLayout"
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.add_child(layout)
	add_child(center)

	for i in range(grid.get_child_count()):
		_prepare_inventory_slot(grid.get_child(i) as Control, Vector2(64, 64))
	Inventory.changed.connect(func(): if visible: _update_all())
	_update_all()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("inventory_toggle"):
			visible = not visible
			if visible:
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
					if hotbar:
							hotbar.visible = false
					_update_all()
			else:
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
					sort_order = false
					current_category = ""
					for btn in category_buttons:
									btn.button_pressed = false
					if sort_button:
									sort_button.button_pressed = false
					if hotbar:
							hotbar.visible = true
					_update_all()

func _update_all() -> void:
	var ids: Array[String] = Inventory.get_sorted_ids(sort_order, current_category) as Array[String]

	for slot in grid.get_children():
				var icon := slot.get_node_or_null("Icon") as TextureRect
				if icon == null:
						var arc := slot.get_node_or_null("IconARC") as AspectRatioContainer
						if arc:
								icon = arc.get_node_or_null("Icon") as TextureRect
				var count := slot.get_node_or_null("Count") as Label
				if icon:
						icon.texture = null
						icon.visible = false
				if count:
						count.text = ""
						count.visible = false

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
						var amount := Inventory.count(id)
						icon.texture = info.icon if info else null
						icon.visible = amount > 0 and info != null
				if count:
						var amount := Inventory.count(id)
						count.text = str(amount) if info and amount > 0 else ""
						count.visible = info != null and amount > 0

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
		
func _create_filter_bar() -> HBoxContainer:
		var bar := HBoxContainer.new()
		bar.name = "FilterBar"
		bar.custom_minimum_size.y = 24
		bar.size_flags_horizontal = Control.SIZE_FILL
		var group := ButtonGroup.new()
		group.allow_unpress = true

		var all_btn := Button.new()
		all_btn.text = "All"
		all_btn.toggle_mode = true
		all_btn.button_group = group
		all_btn.mouse_filter = Control.MOUSE_FILTER_STOP
		all_btn.toggled.connect(func(pressed: bool):
			if pressed:
				current_category = ""
				sort_order = 0
			_update_all()
		)
		bar.add_child(all_btn)
		category_buttons.append(all_btn)

		for cat in ItemDB.get_categories():
			var btn := Button.new()
			btn.text = ("Food" if cat == "cooking" else cat.capitalize())
			btn.toggle_mode = true
			btn.button_group = group
			btn.mouse_filter = Control.MOUSE_FILTER_STOP
			var category := cat
			btn.toggled.connect(func(pressed: bool):
				if pressed:
						current_category = category
				elif current_category == category:
						current_category = ""
				_update_all()
		)
			bar.add_child(btn)
			category_buttons.append(btn)
		sort_button = Button.new()
		sort_button.text = "Menge"
		sort_button.mouse_filter = Control.MOUSE_FILTER_STOP
		sort_button.pressed.connect(_on_sort_button_pressed)
		bar.add_child(sort_button)
		return bar
			
func _on_sort_button_pressed() -> void:
	if sort_order == 0:
					sort_order = 1
	elif sort_order == 1:
					sort_order = -1
	else:
					sort_order = 1
	_update_all()
