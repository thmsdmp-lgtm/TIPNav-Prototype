# res://category_page.gd
extends Control

func _ready() -> void:
	# Clean up any leftover children if nodes were manually added in the editor
	for child in get_children():
		child.queue_free()
		
	set_anchors_preset(PRESET_FULL_RECT)
	
	var margin := MarginContainer.new()
	margin.set_anchors_preset(PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	margin.add_child(vbox)
	
	# =========================================================================
	# TOP HEADER ROW WITH HOME BUTTON
	# =========================================================================
	var header_hbox := HBoxContainer.new()
	header_hbox.add_theme_constant_override("separation", 10)
	
	var back_btn := Button.new()
	back_btn.text = "← Home"
	back_btn.custom_minimum_size = Vector2(85, 42)
	back_btn.pressed.connect(_on_home_pressed) # Direct signal connection
	
	var title_lbl := Label.new()
	title_lbl.text = "Category: Offices & Facilities"
	title_lbl.add_theme_font_size_override("font_size", 18)
	
	header_hbox.add_child(back_btn)
	header_hbox.add_child(title_lbl)
	vbox.add_child(header_hbox)
	
	# =========================================================================
	# PLACES LIST
	# =========================================================================
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	
	var list_vbox := VBoxContainer.new()
	list_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_vbox.add_theme_constant_override("separation", 10)
	
	var places := ["Building 9 - Main Hall", "Guidance Office", "Chemistry Labs", "Library", "Canteen"]
	for place_name in places:
		var place_btn := Button.new()
		place_btn.text = place_name
		place_btn.custom_minimum_size.y = 50
		place_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		place_btn.pressed.connect(func(): _go_to("res://view_on_map.tscn"))
		list_vbox.add_child(place_btn)
		
	scroll.add_child(list_vbox)
	vbox.add_child(scroll)

# =========================================================================
# NAVIGATION HANDLERS & FALLBACK
# =========================================================================
func _on_home_pressed() -> void:
	print("[CategoryPage] Back to Home pressed!")
	_go_to("res://home_tab.tscn")

func _go_to(path: String) -> void:
	print("[CategoryPage] Attempting transition to: ", path)
	if has_node("/root/SceneTransitionManager"):
		get_node("/root/SceneTransitionManager").change_scene(path)
	else:
		# Direct engine scene change as fallback
		var err := get_tree().change_scene_to_file(path)
		if err != OK:
			printerr("[CategoryPage Error] Failed to load scene file at: ", path)
