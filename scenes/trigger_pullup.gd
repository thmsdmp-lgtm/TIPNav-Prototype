extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if %tabHandler.current_tab.name != "map":
				%tabHandler._switch_tab("map")
			%pullup_menu.trigger(true)
