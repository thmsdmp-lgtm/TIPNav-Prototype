extends Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var fps = Engine.get_frames_per_second()
	var res = get_viewport().get_visible_rect().size
	
	text = str("FPS: ",fps," RES: ",res)
