# res://welcome_tab.gd
extends Control

var checklist_card: PanelContainer

func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	
	var main_margin := MarginContainer.new()
	main_margin.set_anchors_preset(PRESET_FULL_RECT)
	main_margin.add_theme_constant_override("margin_left", 24)
	main_margin.add_theme_constant_override("margin_right", 24)
	main_margin.add_theme_constant_override("margin_top", 30)
	main_margin.add_theme_constant_override("margin_bottom", 24)
	add_child(main_margin)
	
	var main_vbox := VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 16)
	main_margin.add_child(main_vbox)
	
	# =========================================================================
	# 🔴 CIRCULAR LOGO PLACEHOLDER (TOP CENTER)
	# =========================================================================
	var logo_center_container := CenterContainer.new()
	
	var circular_logo_panel := PanelContainer.new()
	circular_logo_panel.custom_minimum_size = Vector2(90, 90) # Square container for circle
	
	# Circular Styling
	var circle_style := StyleBoxFlat.new()
	circle_style.bg_color = Color("#27272A")
	circle_style.set_corner_radius_all(45) # Half of 90 creates a perfect circle
	circle_style.border_width_left = 2
	circle_style.border_width_top = 2
	circle_style.border_width_right = 2
	circle_style.border_width_bottom = 2
	circle_style.border_color = Color("#3F3F46")
	circular_logo_panel.add_theme_stylebox_override("panel", circle_style)
	
	var logo_label := Label.new()
	logo_label.text = "LOGO"
	logo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	logo_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	logo_label.add_theme_font_size_override("font_size", 14)
	logo_label.modulate = Color(0.8, 0.8, 0.8)
	
	circular_logo_panel.add_child(logo_label)
	logo_center_container.add_child(circular_logo_panel)
	main_vbox.add_child(logo_center_container)
	# =========================================================================
	
	# Welcome Title
	var welcome_lbl := Label.new()
	welcome_lbl.text = "Welcome!"
	welcome_lbl.add_theme_font_size_override("font_size", 20)
	welcome_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(welcome_lbl)
	
	# Question Card Container
	var question_card := PanelContainer.new()
	_apply_card_style(question_card, "#1F2937", 14)
	
	var q_vbox := VBoxContainer.new()
	q_vbox.add_theme_constant_override("separation", 14)
	
	var q_lbl := Label.new()
	q_lbl.text = "Are you a Freshman or Transferee student?"
	q_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	q_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	q_vbox.add_child(q_lbl)
	
	# Buttons Row
	var btn_hbox := HBoxContainer.new()
	btn_hbox.add_theme_constant_override("separation", 12)
	
	var yes_btn := Button.new()
	yes_btn.text = "YES"
	yes_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	yes_btn.custom_minimum_size.y = 44
	yes_btn.pressed.connect(_on_yes_pressed)
	
	var no_btn := Button.new()
	no_btn.text = "NO"
	no_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	no_btn.custom_minimum_size.y = 44
	no_btn.pressed.connect(_on_no_pressed)
	
	btn_hbox.add_child(yes_btn)
	btn_hbox.add_child(no_btn)
	q_vbox.add_child(btn_hbox)
	question_card.add_child(q_vbox)
	main_vbox.add_child(question_card)
	
	# Registration Checklist (Hidden initially)
	checklist_card = PanelContainer.new()
	checklist_card.visible = false
	_apply_card_style(checklist_card, "#2A2A2A", 14)
	
	var chk_vbox := VBoxContainer.new()
	chk_vbox.add_theme_constant_override("separation", 8)
	
	var chk_header := Label.new()
	chk_header.text = "📋 Registration Checklist Requirements:"
	chk_header.add_theme_font_size_override("font_size", 14)
	chk_vbox.add_child(chk_header)
	
	var items := [
		"[ ] Complete Orange Form signatures",
		"[ ] Submit Form 137 / Official Transcript",
		"[ ] Obtain ID Validation Stamp at OSA",
		"[ ] Secure Library Access Pass"
	]
	
	for item in items:
		var item_lbl := Label.new()
		item_lbl.text = item
		item_lbl.add_theme_font_size_override("font_size", 12)
		item_lbl.modulate = Color(0.85, 0.85, 0.85)
		chk_vbox.add_child(item_lbl)
		
	var proceed_btn := Button.new()
	proceed_btn.text = "Proceed to Home →"
	proceed_btn.custom_minimum_size.y = 42
	proceed_btn.pressed.connect(_go_to_home)
	chk_vbox.add_child(proceed_btn)
	
	checklist_card.add_child(chk_vbox)
	main_vbox.add_child(checklist_card)

# --- Callbacks ---

func _on_yes_pressed() -> void:
	checklist_card.visible = true

func _on_no_pressed() -> void:
	_go_to_home()

func _go_to_home() -> void:
	if has_node("/root/SceneTransitionManager"):
		get_node("/root/SceneTransitionManager").change_scene("res://home_tab.tscn")
	else:
		get_tree().change_scene_to_file("res://home_tab.tscn")

func _apply_card_style(card: PanelContainer, hex_bg: String, radius: int = 14) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(hex_bg)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	card.add_theme_stylebox_override("panel", style)
