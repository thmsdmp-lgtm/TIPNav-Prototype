# res://home_tab.gd
extends Control

func _ready() -> void:
	# 1. Expand root node to fill screen
	set_anchors_preset(PRESET_FULL_RECT)
	anchor_right = 1.0
	anchor_bottom = 1.0
	
	# 2. Main Outer Layout
	var root_vbox := VBoxContainer.new()
	root_vbox.set_anchors_preset(PRESET_FULL_RECT)
	root_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_vbox.add_theme_constant_override("separation", 0)
	add_child(root_vbox)
	
	# 3. Top Scroll Container (Padded at bottom so content doesn't get hidden under navbar)
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root_vbox.add_child(scroll)
	
	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 80) # Space for bottom navbar
	scroll.add_child(margin)
	
	var mainvbox := VBoxContainer.new()
	mainvbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mainvbox.add_theme_constant_override("separation", 20)
	margin.add_child(mainvbox)
	
	# --- SECTION 1: Search Bar ---
	var search_bar := LineEdit.new()
	search_bar.placeholder_text = "🔍 Search places, rooms, offices..."
	search_bar.custom_minimum_size.y = 48
	search_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var search_style := StyleBoxFlat.new()
	search_style.bg_color = Color("#2A2A2A")
	search_style.set_corner_radius_all(24)
	search_style.content_margin_left = 16.0
	search_style.content_margin_right = 16.0
	search_bar.add_theme_stylebox_override("normal", search_style)
	mainvbox.add_child(search_bar)
	
	# --- SECTION 2: News Banner Card ---
	var news_card := PanelContainer.new()
	_apply_card_style(news_card, "#1E293B")
	var news_vbox := VBoxContainer.new()
	news_vbox.add_theme_constant_override("separation", 8)
	
	var badge_hbox := HBoxContainer.new()
	var news_badge := PanelContainer.new()
	_apply_card_style(news_badge, "#3B82F6", 12, 10.0, 4.0)
	var badge_text := Label.new()
	badge_text.text = "NEWS"
	badge_text.add_theme_font_size_override("font_size", 12)
	news_badge.add_child(badge_text)
	badge_hbox.add_child(news_badge)
	
	var news_title := Label.new()
	news_title.text = "Campus Announcement Headline"
	news_title.add_theme_font_size_override("font_size", 16)
	
	var news_sub := Label.new()
	news_sub.text = "Important updates regarding upcoming events and schedule changes."
	news_sub.modulate = Color(0.7, 0.7, 0.7)
	news_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	news_vbox.add_child(badge_hbox)
	news_vbox.add_child(news_title)
	news_vbox.add_child(news_sub)
	news_card.add_child(news_vbox)
	mainvbox.add_child(news_card)
	
	# --- SECTION 3: Shortcuts Grid ---
	var grid_card := PanelContainer.new()
	_apply_card_style(grid_card, "#2A2A2A")
	
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	
	var shortcuts := ["Campus Map", "Offices / Guidance", "Announcements", "Favorites"]
	for item_name in shortcuts:
		var btn := Button.new()
		btn.text = item_name
		btn.custom_minimum_size = Vector2(0, 50)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(btn)
		
	grid_card.add_child(grid)
	mainvbox.add_child(grid_card)
	
	# --- SECTION 4: Categories Pills ---
	_add_section_header(mainvbox, "Categories")
	var category_scroll := ScrollContainer.new()
	category_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	
	var pill_hbox := HBoxContainer.new()
	pill_hbox.add_theme_constant_override("separation", 8)
	var cat_pills := ["Rooms", "Offices", "Facilities", "Buildings", "Courts", "Labs"]
	for cat_name in cat_pills:
		var pill_btn := Button.new()
		pill_btn.text = cat_name
		pill_btn.custom_minimum_size = Vector2(90, 36)
		pill_hbox.add_child(pill_btn)
		
	category_scroll.add_child(pill_hbox)
	mainvbox.add_child(category_scroll)
	
	# --- SECTION 5: Frequently Visited Places ---
	_add_section_header(mainvbox, "Frequently Visited Places")
	var freq_scroll := ScrollContainer.new()
	freq_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	
	var freq_hbox := HBoxContainer.new()
	freq_hbox.add_theme_constant_override("separation", 12)
	
	var place_list := ["Library", "Canteen", "Chemistry Lab", "Guidance Office"]
	for place_item in place_list:
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(160, 100)
		_apply_card_style(card, "#333333")
		
		var card_lbl := Label.new()
		card_lbl.text = place_item
		card_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		card_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		card.add_child(card_lbl)
		freq_hbox.add_child(card)
		
	freq_scroll.add_child(freq_hbox)
	mainvbox.add_child(freq_scroll)
	
	# --- SECTION 6: Suggested Places ---
	_add_section_header(mainvbox, "Suggested Places")
	var suggested_vbox := VBoxContainer.new()
	suggested_vbox.add_theme_constant_override("separation", 8)
	
	var suggested_list := ["Building 9 - Main Hall", "OSA - Office of Student Affairs", "Courts & Gymnasium"]
	for suggested_item in suggested_list:
		var row := PanelContainer.new()
		_apply_card_style(row, "#2A2A2A", 10, 12.0, 12.0)
		
		var row_lbl := Label.new()
		row_lbl.text = suggested_item
		row.add_child(row_lbl)
		suggested_vbox.add_child(row)
		
	mainvbox.add_child(suggested_vbox)
	
	# --- SECTION 7: FIXED BOTTOM NAVBAR OVERLAY ---
	_build_bottom_navbar(self)

## Helper 1: Builds the fixed bottom navigation bar on top of everything
func _build_bottom_navbar(parent_node: Node) -> void:
	var layer := CanvasLayer.new()
	layer.layer = 100
	
	var nav_panel := PanelContainer.new()
	nav_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	nav_panel.custom_minimum_size.y = 64.0
	nav_panel.offset_top = -64.0
	nav_panel.offset_bottom = 0.0
	
	var nav_style := StyleBoxFlat.new()
	nav_style.bg_color = Color("#18181B")
	nav_panel.add_theme_stylebox_override("panel", nav_style)
	
	var nav_hbox := HBoxContainer.new()
	nav_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	nav_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nav_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var home_btn := Button.new()
	home_btn.text = "Home"
	home_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	home_btn.size_flags_vertical = Control.SIZE_FILL
	
	var cat_btn := Button.new()
	cat_btn.text = "Categories"
	cat_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cat_btn.size_flags_vertical = Control.SIZE_FILL
	cat_btn.pressed.connect(_on_nav_categories_pressed)
	
	var map_btn := Button.new()
	map_btn.text = "Map"
	map_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_btn.size_flags_vertical = Control.SIZE_FILL
	map_btn.pressed.connect(_on_nav_map_pressed)
	
	nav_hbox.add_child(home_btn)
	nav_hbox.add_child(cat_btn)
	nav_hbox.add_child(map_btn)
	
	nav_panel.add_child(nav_hbox)
	layer.add_child(nav_panel)
	parent_node.add_child(layer)

## Helper 2: Adds section header labels
func _add_section_header(parent_node: Control, title_text: String) -> void:
	var lbl := Label.new()
	lbl.text = title_text
	lbl.add_theme_font_size_override("font_size", 18)
	parent_node.add_child(lbl)

## Helper 3: Card styling helper
func _apply_card_style(card_panel: PanelContainer, bg_hex: String, corner_radius: int = 14, margin_lr: float = 16.0, margin_tb: float = 16.0) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(bg_hex)
	style.set_corner_radius_all(corner_radius)
	style.content_margin_left = margin_lr
	style.content_margin_right = margin_lr
	style.content_margin_top = margin_tb
	style.content_margin_bottom = margin_tb
	card_panel.add_theme_stylebox_override("panel", style)

# --- Navigation Callbacks ---

func _on_nav_categories_pressed() -> void:
	if has_node("/root/SceneTransitionManager"):
		get_node("/root/SceneTransitionManager").change_scene("res://category_page.tscn")

func _on_nav_map_pressed() -> void:
	if has_node("/root/SceneTransitionManager"):
		get_node("/root/SceneTransitionManager").change_scene("res://map_tab.tscn")
