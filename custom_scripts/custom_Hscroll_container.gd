extends Control
class_name CustomHScrollContainer
# external variables
@export var ChildContainer:Control
@export var Sensitivity:float = 2.5
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
		var finalSen = clamp(5-Sensitivity,.1,10)
		var dt = get_process_delta_time()
		if dt > 0.0:
			# convert this event's pixel movement into a velocity (px/sec)
			deltaY = (event.relative.x/finalSen) / dt
	elif event is InputEventScreenDrag:
		var finalSen = clamp(5-Sensitivity,.1,10)
		var dt = get_process_delta_time()
		if dt > 0.0:
			deltaY = (event.relative.x/finalSen) / dt
func _process(delta: float) -> void:
	if not ChildContainer: return
	
	# proper frame-rate independent exponential decay (instead of raw lerp with 10*delta)
	deltaY = lerp(deltaY, 0.0, 1.0 - exp(-10.0*delta))
	
	# deltaY is now a velocity (px/sec), so scale by delta to get frame-independent displacement
	var new_x := ChildContainer.global_position.x + deltaY*delta
	var max_x := global_position.x
	var min_x := (global_position.x+size.x)-(ChildContainer.size.x)
	
	ChildContainer.global_position.x = clamp(new_x, min_x, max_x)
