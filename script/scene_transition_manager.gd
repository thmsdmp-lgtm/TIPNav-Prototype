extends Node

func change_scene(scene_path: String) -> void:
	print("[SceneManager] Attempting to load scene: ", scene_path)
	
	if ResourceLoader.exists(scene_path):
		var error := get_tree().change_scene_to_file(scene_path)
		if error != OK:
			printerr("[SceneManager Error] Failed to change scene! Error code: ", error)
	else:
		printerr("[SceneManager Error] Scene file NOT found at path: '", scene_path, "'. Check if your .tscn file is inside a subfolder like 'res://scenes/home_tab.tscn'!")
