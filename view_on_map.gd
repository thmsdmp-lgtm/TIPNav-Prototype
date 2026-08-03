# res://view_on_map.gd
extends Control

func _ready() -> void:
	# 1. Expand screen layout
	set_anchors_preset(PRESET_FULL_RECT)
	
	# 2. Main Outer Layout
	var main_layout := VBoxContainer.new()
	main_layout.set_anchors_preset(PRESET_FULL_RECT)
	main_layout.add_theme_constant_override("separation", 0)
	add_child(main_layout)
	
	# 3. Top Navigation Header (Back Button + Title)
	var top_nav_bar := PanelContainer.new()
	top_nav_bar.custom_minimum_size.y = 56.0
	_apply_card_style(top_nav_bar, "#18181B", 0, 16.0, 10.0)
	
	var header_hbox := HBoxContainer.new()
	header_hbox.add_theme_constant_override("separation", 12)
	
	var back_button := Button.new()
	back_button.text = "← Back"
	back_button.custom_minimum_size = Vector2(80, 36)
	back_button.pressed.connect(_on_back_button_pressed)
	
	var screen_title := Label.new()
	screen_title.text = "Building Information"
	screen_title.add_theme_font_size_override("font_size", 18)
	
	header_hbox.add_child(back_button)
	header_hbox.add_child(screen_title)
	top_nav_bar.add_child(header_hbox)
	main_layout.add_child(top_nav_bar)
	
	# 4. Scrollable Detail Area
	var content_scroll := ScrollContainer.new()
	content_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main_layout.add_child(content_scroll)
	
	var content_padding := MarginContainer.new()
	content_padding.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_padding.add_theme_constant_override("margin_left", 20)
	content_padding.add_theme_constant_override("margin_right", 20)
	content_padding.add_theme_constant_override("margin_top", 20)
	content_padding.add_theme_constant_override("margin_bottom", 20)
	content_scroll.add_child(content_padding)
	
	var details_vbox := VBoxContainer.new()
	details_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details_vbox.add_theme_constant_override("separation", 16)
	content_padding.add_child(details_vbox)
	
	# --- MEDIA CAROUSEL CONTAINER (Placeholder for Images/Videos/3D Preview) ---
	var media_carousel_card := PanelContainer.new()
	media_carousel_card.custom_minimum_size.y = 220.0
	_apply_card_style(media_carousel_card, "#2A2A2A", 16)
	
	var carousel_vbox := VBoxContainer.new()
	carousel_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	var media_placeholder_label := Label.new()
	media_placeholder_label.text = "[ Image / Video Carousel ]"
	media_placeholder_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	var pagination_dots := Label.new()
	pagination_dots.text = "•  •  •"
	pagination_dots.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pagination_dots.modulate = Color(0.6, 0.6, 0.6)
	
	carousel_vbox.add_child(media_placeholder_label)
	carousel_vbox.add_child(pagination_dots)
	media_carousel_card.add_child(carousel_vbox)
	details_vbox.add_child(media_carousel_card)
	
	# --- BUILDING TITLE BAR ---
	var building_title := Label.new()
	building_title.text = "Building 9 - Main Academic Hall"
	building_title.add_theme_font_size_override("font_size", 20)
	details_vbox.add_child(building_title)
	
	# --- DETAILED DESCRIPTION BLOCK ---
	var description_card := PanelContainer.new()
	_apply_card_style(description_card, "#222222", 12)
	
	var description_text := Label.new()
	description_text.text = "Building 9 houses the primary engineering lecture rooms, computer laboratories, and faculty offices. " + \
		"Equipped with modern smart displays and fully air-conditioned study halls. " + \
		"\n\nOperating Hours: 7:00 AM - 8:30 PM\nFloors: 5 Storeys"
	description_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_text.modulate = Color(0.85, 0.85, 0.85)
	
	description_card.add_child(description_text)
	details_vbox.add_child(description_card)
	
	# --- ACTION BUTTON (Locate on Map) ---
	var locate_on_map_button := Button.new()
	locate_on_map_button.text = "📍 Locate Building on Interactive Map"
	locate_on_map_button.custom_minimum_size.y = 48
	locate_on_map_button.pressed.connect(_on_locate_on_map_pressed)
	details_vbox.add_child(locate_on_map_button)

# --- Button Handlers ---

func _on_back_button_pressed() -> void:
	if has_node("/root/SceneTransitionManager"):
		get_node("/root/SceneTransitionManager").change_scene("res://category_page.tscn")

func _on_locate_on_map_pressed() -> void:
	if has_node("/root/SceneTransitionManager"):
		get_node("/root/SceneTransitionManager").change_scene("res://map_tab.tscn")

## Card styling helper
func _apply_card_style(card_panel: PanelContainer, bg_hex: String, corner_radius: int = 14, margin_lr: float = 16.0, margin_tb: float = 16.0) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(bg_hex)
	style.set_corner_radius_all(corner_radius)
	style.content_margin_left = margin_lr
	style.content_margin_right = margin_lr
	style.content_margin_top = margin_tb
	style.content_margin_bottom = margin_tb
	card_panel.add_theme_stylebox_override("panel", style)
