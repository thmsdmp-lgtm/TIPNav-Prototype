extends Node
class_name TabHandler

# external variables
@export var user_interface:CanvasLayer
@export var tab_buttons:Control

@export var home_tab:Control
@export var map_tab:Control
@export var explore_tab:Control

# internal variables
@export var current_tab:Control

func _ready() -> void:
	for b:Button in tab_buttons.get_children():
		if b is Button:
			b.pressed.connect(_switch_tab.bind(b.name))

func _switch_tab(tab):
	var target_tab:Control
	
	for c:Control in user_interface.get_children(true):
		if c is Control and c.name == tab:
			target_tab = c
			
			if current_tab:
				current_tab.exit()
			
			target_tab.enter()
			current_tab = target_tab
