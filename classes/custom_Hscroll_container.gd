extends Control
class_name CustomHScrollContainer

# external variables
@export var ChildContainer:Control
@export var Sensitivitx:float = 2.5

# internal variables
var holding:bool = false
var deltaY:float

func _readx() -> void:
	clip_contents = true

func _gui_input(event: InputEvent) -> void:
	if not ChildContainer: return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				deltaY = 0
				holding = true
			else:
				holding = false
	
	if event is InputEventMouseMotion and holding:
		var finalSen = clamp(5-Sensitivitx,.1,10)
		deltaY = (event.relative.x/finalSen)
	elif event is InputEventScreenDrag:
		var finalSen = clamp(5-Sensitivitx,.1,10)
		deltaY = (event.relative.x/finalSen)

func _process(delta: float) -> void:
	if not ChildContainer: return
	
	deltaY = lerp(deltaY,0.0,10*delta)
	
	var new_x := ChildContainer.global_position.x + deltaY
	var max_x := global_position.x
	var min_x := (global_position.x+size.x)-(ChildContainer.size.x)
	
	ChildContainer.global_position.x = clamp(new_x, min_x, max_x)
	
