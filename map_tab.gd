# res://map_tab.gd
extends Control

# Viewport & Mesh References
var map_3d_viewport_container: SubViewportContainer
var map_test_building_mesh: MeshInstance3D

# Drawer Drag State
var drawer_container: MarginContainer
var is_dragging_drawer := false
var drag_start_mouse_y := 0.0
var drag_start_drawer_offset_y := 0.0

func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	anchor_right = 1.0
	anchor_bottom = 1.0
	
	# =========================================================================
	# 1. 3D MAP VIEWPORT CONTAINER (BACKGROUND LAYER)
	# =========================================================================
	map_3d_viewport_container = SubViewportContainer.new()
	map_3d_viewport_container.set_anchors_preset(PRESET_FULL_RECT)
	map_3d_viewport_container.stretch = true
	add_child(map_3d_viewport_container)
	
	var viewport := SubViewport.new()
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	map_3d_viewport_container.add_child(viewport)
	
	var node_3d := Node3D.new()
	viewport.add_child(node_3d)
	
	var camera := Camera3D.new()
	camera.position = Vector3(0, 3, 5)
	camera.look_at(Vector3.ZERO)
	node_3d.add_child(camera)
	
	var light := DirectionalLight3D.new()
	light.position = Vector3(2, 5, 2)
	node_3d.add_child(light)
	
	map_test_building_mesh = MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(1.5, 2.0, 1.5)
	map_test_building_mesh.mesh = box_mesh
	node_3d.add_child(map_test_building_mesh)
	
	# =========================================================================
	# 2. UI OVERLAY CANVAS LAYER
	# =========================================================================
	var ui_canvas_layer := CanvasLayer.new()
	ui_canvas_layer.layer = 10
	add_child(ui_canvas_layer)
	
	var ui_root_control := Control.new()
	ui_root_control.set_anchors_preset(PRESET_FULL_RECT)
	ui_canvas_layer.add_child(ui_root_control)
	
	# --- TOP HEADER ROW (HOME + SEARCH BAR) ---
	var top_header_margin := MarginContainer.new()
	top_header_margin.set_anchors_preset(PRESET_TOP_WIDE)
	top_header_margin.add_theme_constant_override("margin_left", 12)
	top_header_margin.add_theme_constant_override("margin_right", 12)
	top_header_margin.add_theme_constant_override("margin_top", 16)
	
	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 8)
	
	var back_home_btn := Button.new()
	back_home_btn.text = "← Home"
	back_home_btn.custom_minimum_size = Vector2(80, 42)
	back_home_btn.pressed.connect(_on_back_home_pressed)
	
	var floating_search_input := LineEdit.new()
	floating_search_input.placeholder_text = "Search map locations, facilities..."
	floating_search_input.custom_minimum_size.y = 42
	floating_search_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var search_style := StyleBoxFlat.new()
	search_style.bg_color = Color("#18181B")
	search_style.set_corner_radius_all(21)
	search_style.content_margin_left = 12.0
	search_style.content_margin_right = 12.0
	floating_search_input.add_theme_stylebox_override("normal", search_style)
	
	top_row.add_child(back_home_btn)
	top_row.add_child(floating_search_input)
	top_header_margin.add_child(top_row)
	ui_root_control.add_child(top_header_margin)
	
	# --- SLIDING BOTTOM DRAWER (BOUNDED WITHIN SCREEN) ---
	drawer_container = MarginContainer.new()
	drawer_container.set_anchors_preset(PRESET_BOTTOM_WIDE)
	drawer_container.anchor_top = 1.0
	drawer_container.anchor_bottom = 1.0
	drawer_container.offset_top = -200.0   # Sits nicely above screen bottom
	drawer_container.offset_bottom = -12.0 # Leaves gap at the very bottom edge
	drawer_container.add_theme_constant_override("margin_left", 12)
	drawer_container.add_theme_constant_override("margin_right", 12)
	
	var drawer_card := PanelContainer.new()
	_apply_card_style(drawer_card, "#1F2937", 16, 12.0, 10.0)
	
	var drawer_vbox := VBoxContainer.new()
	drawer_vbox.add_theme_constant_override("separation", 8)
	
	# Drag Handle Indicator Bar
	var drag_handle_center := CenterContainer.new()
	var drag_handle_bar := PanelContainer.new()
	drag_handle_bar.custom_minimum_size = Vector2(50, 8)
	drag_handle_bar.gui_input.connect(_on_drag_handle_gui_input)
	
	var handle_style := StyleBoxFlat.new()
	handle_style.bg_color = Color("#6B7280")
	handle_style.set_corner_radius_all(4)
	drag_handle_bar.add_theme_stylebox_override("panel", handle_style)
	
	drag_handle_center.add_child(drag_handle_bar)
	drawer_vbox.add_child(drag_handle_center)
	
	# Drawer Title Label
	var drawer_title := Label.new()
	drawer_title.text = "[TEST PLACEHOLDER] Building 9 Details"
	drawer_title.add_theme_font_size_override("font_size", 14)
	drawer_vbox.add_child(drawer_title)
	
	# Horizontal Scroll Container (Prevents right-side text clipping)
	var horizontal_scroll := ScrollContainer.new()
	horizontal_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	horizontal_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	horizontal_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var drawer_cards_hbox := HBoxContainer.new()
	drawer_cards_hbox.add_theme_constant_override("separation", 8)
	
	var quick_info_list := [
		"[TEST PLACEHOLDER] Floors: 5",
		"[TEST PLACEHOLDER] Rooms: 32",
		"[TEST PLACEHOLDER] Status: Open"
	]
	for info_item in quick_info_list:
		var mini_card := PanelContainer.new()
		_apply_card_style(mini_card, "#374151", 8, 10.0, 8.0)
		
		var info_label := Label.new()
		info_label.text = info_item
		info_label.add_theme_font_size_override("font_size", 12)
		mini_card.add_child(info_label)
		drawer_cards_hbox.add_child(mini_card)
		
	horizontal_scroll.add_child(drawer_cards_hbox)
	drawer_vbox.add_child(horizontal_scroll)
	drawer_card.add_child(drawer_vbox)
	drawer_container.add_child(drawer_card)
	ui_root_control.add_child(drawer_container)

# =========================================================================
# PROCESS & DRAG INTERACTION
# =========================================================================
func _process(delta: float) -> void:
	if is_instance_valid(map_test_building_mesh):
		map_test_building_mesh.rotate_y(delta * 0.8)

func _on_drag_handle_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging_drawer = true
			drag_start_mouse_y = get_global_mouse_position().y
			drag_start_drawer_offset_y = drawer_container.offset_top
		else:
			is_dragging_drawer = false

	elif event is InputEventMouseMotion and is_dragging_drawer:
		var delta_y := get_global_mouse_position().y - drag_start_mouse_y
		drawer_container.offset_top = clamp(drag_start_drawer_offset_y + delta_y, -360.0, -140.0)

# =========================================================================
# NAVIGATION & HELPER
# =========================================================================
func _on_back_home_pressed() -> void:
	if has_node("/root/SceneTransitionManager"):
		get_node("/root/SceneTransitionManager").change_scene("res://home_tab.tscn")
	else:
		get_tree().change_scene_to_file("res://home_tab.tscn")

func _apply_card_style(card_panel: PanelContainer, bg_hex: String, corner_radius: int = 14, margin_lr: float = 12.0, margin_tb: float = 10.0) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(bg_hex)
	style.set_corner_radius_all(corner_radius)
	style.content_margin_left = margin_lr
	style.content_margin_right = margin_lr
	style.content_margin_top = margin_tb
	style.content_margin_bottom = margin_tb
	card_panel.add_theme_stylebox_override("panel", style)
