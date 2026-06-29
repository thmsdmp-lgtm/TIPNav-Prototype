extends Button

func _on_pressed() -> void:
	%gpsManager.start_watching_gps()
