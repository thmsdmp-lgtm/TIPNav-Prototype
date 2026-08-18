#handle place panel inputs
extends Control

#--------------------------------------#

# tween properties
var panel_rotate_amount:int = 2
var panel_size_amount:Vector2 = Vector2(.9,.9)

var panel_duration:float = .4
var about_duration:float = .2

var panel_tween:ButtonTweenManager
var about_tween:Tween

var data:Dictionary
var about
var ui:CanvasLayer
var trigger:Control

var pressing := false

# setup
func _ready() -> void:
	if data.is_empty():
		print("PLACEMANAGER DATA EMPTY")
		return
	
	# get panel tween
	panel_tween = ButtonTweenManager.new()
	panel_tween.node = self
	add_child(panel_tween)
	
	# get ui
	ui = get_tree().current_scene.get_node("INTERFACE")
	if not ui:
		print("INTERFACE DOES NOT EXIST?")
		return
	
	# set pivot center
	pivot_offset_ratio = Vector2(.5,.5)
	
	# create trigger button
	trigger = Button.new()
	
	# set size
	trigger.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# set theme
	var empty := StyleBoxEmpty.new()
	trigger.add_theme_stylebox_override("normal",empty)
	trigger.add_theme_stylebox_override("pressed",empty)
	trigger.add_theme_stylebox_override("hover",empty)
	trigger.add_theme_stylebox_override("focus", empty)
	
	# parent
	add_child(trigger)
	move_child(trigger,0)
	
	# setup input
	trigger.button_down.connect(on_pressed.bind(true))
	trigger.button_up.connect(on_pressed.bind(false))

# handle input
func on_pressed(state:bool):
	if pressing: return
	pressing = true
	
	if state:
		panel_tween.button_down(panel_size_amount,panel_rotate_amount,panel_duration)
	else:
		panel_tween.button_up(panel_duration)
		await get_tree().create_timer(.1).timeout
		handle_about(true)
		await get_tree().create_timer(.4).timeout
	pressing = false

func handle_about(state:bool):
	if state: # enter about
		if about: return
		
		about = data.about_scene
		
		if not about:
			print("PLACE DOES NOT HAVE ABOUT PAGE")
			return
		
		about = about.instantiate()
		about.pivot_offset_ratio = Vector2(.5,.5)
		about.scale = Vector2.ZERO
		about.modulate.a = 0.0
		
		var back_button:Button = about.get_node("back_button")
		
		var back_tween := ButtonTweenManager.new()
		back_tween.node = back_button
		back_button.add_child(back_tween)
		
		back_button.button_down.connect(func():
			back_tween.button_down(Vector2(.9,.9),2,.4)
			)
		back_button.button_up.connect(func():
			back_tween.button_up(.4)
			handle_about(false)
			)
		
		ui.add_child(about)
		handle_about_tween(true)
	else: # axit about
		if not about: return
		handle_about_tween(false)
		await get_tree().create_timer(.2).timeout 
		about.queue_free()

# tweens
func handle_about_tween(state:bool):
	if not about: return
	
	if state:
		if about_tween:
			about_tween.kill()
		
		about_tween = create_tween()
		about_tween.set_parallel()
		
		about_tween.tween_property(about, "scale", Vector2.ONE, about_duration)\
			.set_trans(Tween.TRANS_EXPO)\
			.set_ease(Tween.EASE_OUT)
		about_tween.tween_property(about, "modulate:a",1.0, about_duration)\
			.set_trans(Tween.TRANS_EXPO)\
			.set_ease(Tween.EASE_OUT)
	else:
		if about_tween:
			about_tween.kill()
		
		about_tween = create_tween()
		about_tween.set_parallel()
		
		about_tween.tween_property(about, "scale", Vector2.ZERO, about_duration)\
			.set_trans(Tween.TRANS_EXPO)\
			.set_ease(Tween.EASE_OUT)
		about_tween.tween_property(about, "modulate:a",0.0, about_duration)\
			.set_trans(Tween.TRANS_EXPO)\
			.set_ease(Tween.EASE_OUT)
