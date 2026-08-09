extends Panel
class_name PullupMenu

# external variables
@export var TriggerControl:Control
@export var Sensitivity:float = 2.5
@export var max_pos:float = 150
@export var snap_trigger_ratio = 3

# internal variables
var deltaY:float
var holding:bool = false
var original_Y
var triggering = [false,0]

func get_state() -> bool:
	var middle = (size.y/snap_trigger_ratio)
	var trigger_pos = TriggerControl.global_position.y
	
	if trigger_pos < middle:
		return true
	else:
		return false

func trigger(full_screen:bool):
	if not holding or deltaY==0:
		triggering[0] = true
		
		if full_screen:
			triggering[1] = 1
		else:
			triggering[1] = 0

func _ready() -> void:
	if not TriggerControl: return
	original_Y = global_position.y
	TriggerControl.gui_input.connect(on_input)

func on_input(event):
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
	if not TriggerControl: return
	
	if not holding or deltaY == 0:
		# lerp to pos
		
		var middle = (size.y/snap_trigger_ratio)
		var trigger_pos = TriggerControl.global_position.y
		
		if triggering[0] == true:
			if triggering[1] == 1:
				if global_position.y > (max_pos+0.1):
					global_position.y = lerp(global_position.y,max_pos,20*delta)
				else:
					triggering[0] = false
			else:
				if global_position.y < (original_Y-0.1):
					global_position.y = lerp(global_position.y,original_Y,20*delta)
				else:
					triggering[0] = false
		else:
			if trigger_pos < middle:
				# lerp to full screen
				global_position.y = lerp(global_position.y,max_pos,20*delta)
			else:
				# lerp to original Y
				global_position.y = lerp(global_position.y,original_Y,20*delta)
	else:
		# move
		global_position.y = global_position.y + deltaY
