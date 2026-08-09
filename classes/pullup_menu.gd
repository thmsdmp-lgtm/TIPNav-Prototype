extends Panel
class_name PullupMenu

# EXTERNAL VARIABLES
@export var TriggerControl: Control
@export var Sensitivity: float = 2.5

# Fully opened Y position
@export var max_pos: float = 150.0

# Used to determine where the menu snaps
@export var snap_trigger_ratio: float = 3.0


# INTERNAL VARIABLES
var holding: bool = false
var original_Y: float

# true = currently forcing a triggered position
var triggering: bool = false
var trigger_fullscreen: bool = false

func _ready() -> void:
	if not TriggerControl:
		return
	
	original_Y = global_position.y
	TriggerControl.gui_input.connect(on_input)

# INPUT
func on_input(event: InputEvent) -> void:
	# MOUSE INPUT
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			
			if event.pressed:
				holding = true
				triggering = false
			else:
				holding = false
	
	# MOBILE TOUCH INPUT
	elif event is InputEventScreenTouch:
		
		if event.pressed:
			holding = true
			triggering = false
		else:
			holding = false
	
	# MOUSE DRAG
	elif event is InputEventMouseMotion and holding:
		move_menu(event.relative.y)
	
	# MOBILE DRAG
	elif event is InputEventScreenDrag and holding:
		move_menu(event.relative.y)


# MOVE MENU
func move_menu(relative_y: float) -> void:
	
	var final_sensitivity = clamp(
		5.0 - Sensitivity,
		0.1,
		10.0
	)
	
	var movement = relative_y / final_sensitivity
	
	global_position.y += movement
	
	# Prevent dragging beyond allowed positions
	global_position.y = clamp(
		global_position.y,
		min(max_pos, original_Y),
		max(max_pos, original_Y)
	)

# PROCESS / SNAP
func _process(delta: float) -> void:
	
	if not TriggerControl:
		return
	
	
	# Do nothing while dragging
	if holding:
		return
	
	var target_y: float
	
	# EXTERNAL TRIGGER
	if triggering:
		
		if trigger_fullscreen:
			target_y = max_pos
		else:
			target_y = original_Y
	
	
	# NORMAL SNAP
	else:
		
		var middle = size.y / snap_trigger_ratio
		var trigger_pos = TriggerControl.global_position.y
		
		if trigger_pos < middle:
			target_y = max_pos
		else:
			target_y = original_Y
	
	
	# Smoothly move toward target
	global_position.y = lerp(
		global_position.y,
		target_y,
		20 * delta
	)
	
	
	# Stop triggered state once destination is reached
	if triggering and is_equal_approx(global_position.y, target_y):
		triggering = false

# EXTERNAL TRIGGER
func trigger(full_screen: bool) -> void:
	
	# Don't interrupt the user's drag
	if holding:
		return
	
	triggering = true
	trigger_fullscreen = full_screen

# GET STATE
func get_state() -> bool:
	
	var middle = size.y / snap_trigger_ratio
	var trigger_pos = TriggerControl.global_position.y
	
	return trigger_pos < middle
