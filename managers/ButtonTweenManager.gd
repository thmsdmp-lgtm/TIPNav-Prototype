extends Node
class_name ButtonTweenManager

var tween:Tween
var node:Control

func button_down(size:Vector2,rot:int,duration:float):
	if not node or not size or not duration: return
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel()
	
	tween.tween_property(node, "scale", size, duration)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "rotation_degrees", [-rot,rot].pick_random(), duration)\
		.set_trans(Tween.TRANS_EXPO)\
			.set_ease(Tween.EASE_OUT)

func button_up(duration:float):
	if not duration: return
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel()
	
	tween.tween_property(node, "scale", Vector2.ONE, duration)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "rotation_degrees", 0, duration)\
		.set_trans(Tween.TRANS_EXPO)\
			.set_ease(Tween.EASE_OUT)
