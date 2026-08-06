extends Control
class_name CustomScrollContainer2

# external variables
@export var ChildContainer:Control
@export var Sensitivity:float = 2.5

# internal variables
var holding:bool = false
var deltaY:float

func _ready() -> void:
	clip_contents = true
	gui_input.connect(on_input)

func on_input(event: InputEvent) -> void:
	if not ChildContainer: return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				deltaY = 0
				holding = true
			else:
				holding = false
	
	if event is InputEventMouseMotion and holding:
		var finalSen = clamp(5-Sensitivity,.1,10)
		deltaY = (event.relative.y/finalSen)
	elif event is InputEventScreenDrag:
		var finalSen = clamp(5-Sensitivity,.1,10)
		deltaY = (event.relative.y/finalSen)

func _process(delta: float) -> void:
	deltaY = lerp(deltaY,0.0,10*delta)
	
	var new_y := ChildContainer.global_position.y + deltaY
	var max_y := global_position.y
	var min_y := (global_position.y+size.y)-(ChildContainer.size.y)
	
	ChildContainer.global_position.y = clamp(new_y, min_y, max_y)
	
